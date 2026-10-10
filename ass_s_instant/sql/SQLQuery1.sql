-- حذف قاعدة البيانات إذا كانت موجودة

USE master;
GO

IF DB_ID('AcademyDB') IS NOT NULL
BEGIN
    ALTER DATABASE AcademyDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AcademyDB;
END;
GO

-- إنشاء قاعدة البيانات من جديد

CREATE DATABASE AcademyDB;
GO

USE AcademyDB;
GO

CREATE TABLE Students(
    student_id INT IDENTITY(1,1) PRIMARY KEY,
    full_name NVARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20),
    city NVARCHAR(100),
    enrollment_date DATE DEFAULT GETDATE()
);

INSERT INTO Students(full_name,email,phone,city)
VALUES
('anas emad ali','anasemad@gmail.com','010180745345','cairo'),
('ali','ali@gmail.com','0113737494','giza'),
('Mohamed Hosam','mohamed@gmail.com','01011111111','Mansoura'),
('Ahmed Mostafa','ahmed@gmail.com','01122222222','Alexandria'),
('Sara Ali','sara@gmail.com','01233333333','Cairo');

----------------------------------------------------
-- Leads
----------------------------------------------------
CREATE TABLE Leads(
    lead_id INT IDENTITY(1,1) PRIMARY KEY,
    lead_name NVARCHAR(100),
    phone VARCHAR(20),
    source NVARCHAR(50),
    created_at DATE DEFAULT GETDATE()
);

INSERT INTO Leads(lead_name,phone,source)
VALUES
('Ali Hassan','01012345678','Facebook'),
('Mona Ahmed','01198765432','LinkedIn'),
('Youssef Mohamed','01245678901','Instagram'),
('Nada Ibrahim','01511112222','Website'),
('Karim Adel','01099998888','Referral');

----------------------------------------------------
-- Courses
----------------------------------------------------
CREATE TABLE Courses(
    course_id INT IDENTITY(1,1) PRIMARY KEY,
    course_name NVARCHAR(150) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    duration_hrs INT,
    instructor NVARCHAR(100),
    is_active BIT DEFAULT 1
);

INSERT INTO Courses(course_name,price,duration_hrs,instructor)
VALUES
('AI',10000,3,'Anas Emad'),
('Data Analysis',8000,4,'Ahmed Ali'),
('Machine Learning',12000,6,'Mohamed Hassan'),
('Deep Learning',15000,8,'Sara Ibrahim'),
('Flutter Development',9000,5,'Omar Khaled'),
('Python Programming',7000,4,'Mona Ahmed'),
('SQL Server',6000,3,'Ali Mahmoud'),
('Java Spring Boot',14000,7,'Hossam Adel'),
('Power BI',7500,4,'Nour Elsayed'),
('Data Science',13000,6,'Youssef Tarek'),
('C# Programming',8500,5,'Mahmoud Ali'),
('React JS',9500,6,'Ahmed Adel'),
('Cyber Security',15000,8,'Omar Hassan');

----------------------------------------------------
-- Enrollments
----------------------------------------------------
CREATE TABLE Enrollments(
    enrollment_id INT IDENTITY(1,1) PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrolled_at DATETIME DEFAULT GETDATE(),
    status VARCHAR(20) DEFAULT 'Active',

    CONSTRAINT fk_student
        FOREIGN KEY(student_id)
        REFERENCES Students(student_id),

    CONSTRAINT fk_course
        FOREIGN KEY(course_id)
        REFERENCES Courses(course_id)
);

INSERT INTO Enrollments(student_id,course_id,status)
VALUES
(1,1,'completed'),
(1,2,'hold'),
(1,3,'active'),
(1,7,'dropped'),
(2,7,'active');

----------------------------------------------------
-- Update
----------------------------------------------------
UPDATE Students
SET city='Giza'
WHERE student_id=1;

----------------------------------------------------
-- SELECT
----------------------------------------------------
SELECT * FROM Students;
SELECT * FROM Courses;
SELECT * FROM Leads;
SELECT * FROM Enrollments;

SELECT TOP 10 *
FROM Leads
ORDER BY created_at DESC;

SELECT DISTINCT source
FROM Leads;

SELECT *
FROM Students
ORDER BY enrollment_date DESC;


