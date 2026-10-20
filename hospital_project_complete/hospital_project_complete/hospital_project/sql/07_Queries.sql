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