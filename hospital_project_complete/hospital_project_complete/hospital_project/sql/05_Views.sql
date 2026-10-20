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