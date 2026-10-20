USE HospitalDB;
GO
ALTER TABLE Employees ADD CONSTRAINT CK_Employees_Salary CHECK(Salary>=0);
ALTER TABLE Medicines ADD CONSTRAINT CK_Medicines_Amounts CHECK(Price>=0 AND Quantity>=0 AND MinimumStock>=0);
ALTER TABLE Payments ADD CONSTRAINT CK_Payments_Amount CHECK(Amount>=0);
ALTER TABLE Invoices ADD CONSTRAINT CK_Invoices_Amounts CHECK(TotalAmount>=0 AND PaidAmount>=0 AND RemainingAmount>=0);
GO