USE HospitalDB;
GO
CREATE OR ALTER PROCEDURE sp_GetPatientInvoices @PatientID INT AS SELECT * FROM vw_PatientBilling WHERE PatientID=@PatientID ORDER BY InvoiceDate DESC;
GO
CREATE OR ALTER PROCEDURE sp_GetLowStockMedicines AS SELECT * FROM vw_MedicineInventory WHERE StockStatus='Low Stock' ORDER BY Quantity;
GO
CREATE OR ALTER PROCEDURE sp_GetDoctorAppointments @DoctorID INT AS SELECT * FROM vw_DoctorAppointments WHERE EXISTS(SELECT 1 FROM Employees e WHERE e.EmployeeID=@DoctorID AND e.FullName=DoctorName) ORDER BY AppointmentDate,AppointmentTime;
GO