
==========================================================================================
-- 1. 01_Create_Database.sql
==========================================================================================

IF DB_ID('HospitalDB') IS NULL CREATE DATABASE HospitalDB;
GO
USE HospitalDB;
GO


==========================================================================================
-- 2. 02_Create_Tables.sql
==========================================================================================

USE HospitalDB;
GO
CREATE TABLE Departments(DepartmentID INT PRIMARY KEY,DepartmentName NVARCHAR(100) NOT NULL,Location NVARCHAR(100),Phone VARCHAR(20));
CREATE TABLE Employees(EmployeeID INT PRIMARY KEY,FullName NVARCHAR(150) NOT NULL,JobTitle NVARCHAR(50) NOT NULL,DepartmentID INT NOT NULL,Phone VARCHAR(20),Email VARCHAR(150),Salary DECIMAL(12,2),HireDate DATE,Shift NVARCHAR(20),Status NVARCHAR(30),FOREIGN KEY(DepartmentID) REFERENCES Departments(DepartmentID));
CREATE TABLE Patients(PatientID INT PRIMARY KEY,FullName NVARCHAR(150) NOT NULL,Gender NVARCHAR(20),DateOfBirth DATE,Phone VARCHAR(20),Address NVARCHAR(250),BloodType VARCHAR(5),EmergencyContact VARCHAR(20),RegistrationDate DATE);
CREATE TABLE Rooms(RoomID INT PRIMARY KEY,RoomNumber VARCHAR(20) NOT NULL,RoomType NVARCHAR(50),DepartmentID INT NOT NULL,Capacity INT,Status NVARCHAR(30),FOREIGN KEY(DepartmentID) REFERENCES Departments(DepartmentID));
CREATE TABLE Attendance(AttendanceID INT PRIMARY KEY,EmployeeID INT NOT NULL,AttendanceDate DATE,CheckIn TIME,CheckOut TIME,Status NVARCHAR(30),WorkingHours DECIMAL(5,2),FOREIGN KEY(EmployeeID) REFERENCES Employees(EmployeeID));
CREATE TABLE Appointments(AppointmentID INT PRIMARY KEY,PatientID INT NOT NULL,DoctorID INT NOT NULL,AppointmentDate DATE,AppointmentTime TIME,Status NVARCHAR(30),Reason NVARCHAR(250),FOREIGN KEY(PatientID) REFERENCES Patients(PatientID),FOREIGN KEY(DoctorID) REFERENCES Employees(EmployeeID));
CREATE TABLE Admissions(AdmissionID INT PRIMARY KEY,PatientID INT NOT NULL,RoomID INT NOT NULL,DoctorID INT NOT NULL,AdmissionDate DATE,DischargeDate DATE,Status NVARCHAR(30),FOREIGN KEY(PatientID) REFERENCES Patients(PatientID),FOREIGN KEY(RoomID) REFERENCES Rooms(RoomID),FOREIGN KEY(DoctorID) REFERENCES Employees(EmployeeID));
CREATE TABLE MedicalRecords(MedicalRecordID INT PRIMARY KEY,PatientID INT NOT NULL,DoctorID INT NOT NULL,Diagnosis NVARCHAR(250),Treatment NVARCHAR(250),Notes NVARCHAR(500),RecordDate DATE,FOREIGN KEY(PatientID) REFERENCES Patients(PatientID),FOREIGN KEY(DoctorID) REFERENCES Employees(EmployeeID));
CREATE TABLE Medicines(MedicineID INT PRIMARY KEY,MedicineName NVARCHAR(150) NOT NULL,Category NVARCHAR(100),Price DECIMAL(12,2),Quantity INT,ExpiryDate DATE,SupplierName NVARCHAR(150),MinimumStock INT);
CREATE TABLE Prescriptions(PrescriptionID INT PRIMARY KEY,PatientID INT NOT NULL,DoctorID INT NOT NULL,MedicineID INT NOT NULL,Quantity INT,Dosage NVARCHAR(150),PrescriptionDate DATE,FOREIGN KEY(PatientID) REFERENCES Patients(PatientID),FOREIGN KEY(DoctorID) REFERENCES Employees(EmployeeID),FOREIGN KEY(MedicineID) REFERENCES Medicines(MedicineID));
CREATE TABLE Invoices(InvoiceID INT PRIMARY KEY,PatientID INT NOT NULL,InvoiceDate DATE,ConsultationCost DECIMAL(12,2),TreatmentCost DECIMAL(12,2),MedicineCost DECIMAL(12,2),RoomCost DECIMAL(12,2),OtherCost DECIMAL(12,2),TotalAmount DECIMAL(12,2),PaidAmount DECIMAL(12,2),RemainingAmount DECIMAL(12,2),Status NVARCHAR(30),FOREIGN KEY(PatientID) REFERENCES Patients(PatientID));
CREATE TABLE Payments(PaymentID INT PRIMARY KEY,InvoiceID INT NOT NULL,PaymentDate DATE,Amount DECIMAL(12,2),PaymentMethod NVARCHAR(50),FOREIGN KEY(InvoiceID) REFERENCES Invoices(InvoiceID));
GO


==========================================================================================
-- 3. 03_Insert_Data.sql
==========================================================================================

/*
Import the 12 files from data/cleaned using SQL Server Import Flat File Wizard.
Load in FK-safe order:
Departments, Employees, Patients, Rooms, Attendance, Appointments,
Admissions, MedicalRecords, Medicines, Prescriptions, Invoices, Payments.
*/



==========================================================================================
-- 4. 04_Constraints.sql
==========================================================================================

USE HospitalDB;
GO
ALTER TABLE Employees ADD CONSTRAINT CK_Employees_Salary CHECK(Salary>=0);
ALTER TABLE Medicines ADD CONSTRAINT CK_Medicines_Amounts CHECK(Price>=0 AND Quantity>=0 AND MinimumStock>=0);
ALTER TABLE Payments ADD CONSTRAINT CK_Payments_Amount CHECK(Amount>=0);
ALTER TABLE Invoices ADD CONSTRAINT CK_Invoices_Amounts CHECK(TotalAmount>=0 AND PaidAmount>=0 AND RemainingAmount>=0);
GO


==========================================================================================
-- 5. 05_Views.sql
==========================================================================================

USE HospitalDB;
GO
CREATE OR ALTER VIEW vw_EmployeeAttendance AS SELECT e.EmployeeID,e.FullName,e.JobTitle,a.AttendanceDate,a.Status,a.WorkingHours FROM Employees e JOIN Attendance a ON e.EmployeeID=a.EmployeeID;
GO
CREATE OR ALTER VIEW vw_DoctorAppointments AS SELECT a.AppointmentID,p.FullName PatientName,e.FullName DoctorName,a.AppointmentDate,a.AppointmentTime,a.Status,a.Reason FROM Appointments a JOIN Patients p ON a.PatientID=p.PatientID JOIN Employees e ON a.DoctorID=e.EmployeeID;
GO
CREATE OR ALTER VIEW vw_PatientBilling AS SELECT p.PatientID,p.FullName,i.InvoiceID,i.InvoiceDate,i.TotalAmount,i.PaidAmount,i.RemainingAmount,i.Status FROM Patients p JOIN Invoices i ON p.PatientID=i.PatientID;
GO
CREATE OR ALTER VIEW vw_MedicineInventory AS SELECT *,CASE WHEN Quantity<=MinimumStock THEN 'Low Stock' ELSE 'OK' END StockStatus FROM Medicines;
GO


==========================================================================================
-- 6. 06_Stored_Procedures.sql
==========================================================================================

USE HospitalDB;
GO
CREATE OR ALTER PROCEDURE sp_GetPatientInvoices @PatientID INT AS SELECT * FROM vw_PatientBilling WHERE PatientID=@PatientID ORDER BY InvoiceDate DESC;
GO
CREATE OR ALTER PROCEDURE sp_GetLowStockMedicines AS SELECT * FROM vw_MedicineInventory WHERE StockStatus='Low Stock' ORDER BY Quantity;
GO
CREATE OR ALTER PROCEDURE sp_GetDoctorAppointments @DoctorID INT AS SELECT * FROM vw_DoctorAppointments WHERE EXISTS(SELECT 1 FROM Employees e WHERE e.EmployeeID=@DoctorID AND e.FullName=DoctorName) ORDER BY AppointmentDate,AppointmentTime;
GO


==========================================================================================
-- 7. 07_Queries.sql
==========================================================================================

USE HospitalDB;
GO
-- 1 Employees by job
SELECT JobTitle,COUNT(*) EmployeeCount FROM Employees GROUP BY JobTitle ORDER BY EmployeeCount DESC;
-- 2 Doctors
SELECT EmployeeID,FullName,DepartmentID FROM Employees WHERE JobTitle='Doctor';
-- 3 Nurses
SELECT EmployeeID,FullName,DepartmentID FROM Employees WHERE JobTitle='Nurse';
-- 4 Appointments by doctor
SELECT e.FullName,COUNT(a.AppointmentID) AppointmentCount FROM Employees e LEFT JOIN Appointments a ON e.EmployeeID=a.DoctorID WHERE e.JobTitle='Doctor' GROUP BY e.FullName ORDER BY AppointmentCount DESC;
-- 5 Billing by patient
SELECT p.FullName,SUM(i.TotalAmount) TotalBilled,SUM(i.PaidAmount) TotalPaid,SUM(i.RemainingAmount) Remaining FROM Patients p JOIN Invoices i ON p.PatientID=i.PatientID GROUP BY p.FullName ORDER BY TotalBilled DESC;
-- 6 Low stock
SELECT MedicineName,Quantity,MinimumStock FROM Medicines WHERE Quantity<=MinimumStock ORDER BY Quantity;
-- 7 Revenue
SELECT YEAR(PaymentDate) Y,MONTH(PaymentDate) M,SUM(Amount) Revenue FROM Payments GROUP BY YEAR(PaymentDate),MONTH(PaymentDate) ORDER BY Y,M;
-- 8 Attendance
SELECT Status,COUNT(*) Records FROM Attendance GROUP BY Status;
GO


==========================================================================================
-- 8. 08_Testing.sql
==========================================================================================

USE HospitalDB;
GO
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME;
SELECT 'Departments' T,COUNT(*) C FROM Departments UNION ALL SELECT 'Employees',COUNT(*) FROM Employees UNION ALL SELECT 'Patients',COUNT(*) FROM Patients UNION ALL SELECT 'Rooms',COUNT(*) FROM Rooms UNION ALL SELECT 'Appointments',COUNT(*) FROM Appointments UNION ALL SELECT 'Invoices',COUNT(*) FROM Invoices;
GO


==========================================================================================
-- 9. 09_HospitalAppDB.sql
==========================================================================================

IF DB_ID('HospitalAppDB') IS NULL CREATE DATABASE HospitalAppDB;
GO
USE HospitalAppDB;
GO
CREATE TABLE Roles(RoleID INT IDENTITY PRIMARY KEY,RoleName NVARCHAR(50) UNIQUE NOT NULL);
CREATE TABLE Users(UserID INT IDENTITY PRIMARY KEY,Username NVARCHAR(100) UNIQUE NOT NULL,PasswordHash NVARCHAR(255) NOT NULL,RoleID INT NOT NULL,IsActive BIT DEFAULT 1,CreatedAt DATETIME2 DEFAULT SYSDATETIME(),FOREIGN KEY(RoleID) REFERENCES Roles(RoleID));
CREATE TABLE AuditLogs(AuditID BIGINT IDENTITY PRIMARY KEY,UserID INT,Action NVARCHAR(100) NOT NULL,TableName NVARCHAR(100),RecordID NVARCHAR(100),ActionDate DATETIME2 DEFAULT SYSDATETIME(),FOREIGN KEY(UserID) REFERENCES Users(UserID));
INSERT INTO Roles(RoleName) VALUES('Admin'),('Doctor'),('Nurse'),('Receptionist'),('Accountant');
GO

