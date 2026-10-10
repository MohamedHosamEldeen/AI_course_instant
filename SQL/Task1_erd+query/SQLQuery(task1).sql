create database AcadmyhomeworkDB;
use AcadmyhomeworkDB

create table Students(
student_id Int identity(1,1)  primary key,
Full_name nvarchar(100) not null,
email varchar(150) unique not null,
phone varchar(100),
city nvarchar(100),
date_time date default getdate()
);



create table Course(
Course_id Int identity(1,1)  primary key,
Course_name nvarchar(100) not null,
price decimal(10,2) not null,
duration_hs int,
city nvarchar(100),
is_active bit default 1
);



create table Enrollment(
Enrollment_id Int identity(1,1)  primary key,
student_id int not null,
Course_id int not null,
payment_date date not null,
method varchar(150),
satus varchar(150) default 'active',
foreign key (student_id) references Students (student_id),
foreign key (Course_id) references Course (Course_id),
);
create table payment(
payment_id Int primary key,
Enrollment_id int not null,
amout decimal(10,2),
payment_date date,
method varchar(150),
status varchar(150) default 'pending'
foreign key (Enrollment_id) references Enrollment (Enrollment_id),
);
alter table Students 
add nationality nvarchar(150);



INSERT INTO Students
(Full_name,email,phone,city,nationality)
VALUES
('Mohamed Hosam','mohamed@gmail.com','01011111111','Mansoura','Egypt'),
('Ahmed Ali','ahmed@gmail.com','01022222222','Cairo','Egypt'),
('Sara Mohamed','sara@gmail.com','01033333333','Alexandria','Egypt'),
('Omar Hassan','omar@gmail.com','01044444444','Tanta','Egypt'),
('Mona Adel','mona@gmail.com','01055555555','Mansoura','Egypt'),
('Youssef Khaled','youssef@gmail.com','01066666666','Giza','Egypt');



INSERT INTO Enrollment
(student_id,Course_id,payment_date,method)
VALUES
(1,1,'2026-07-01','Cash'),
(2,2,'2026-07-02','Visa'),
(3,3,'2026-07-03','Cash'),
(4,4,'2026-07-04','Vodafone Cash'),
(5,5,'2026-07-05','Visa'),
(6,1,'2026-07-06','Cash');


INSERT INTO Payment
(payment_id,Enrollment_id,amout,payment_date,method)
VALUES
(1,1,2500,'2026-07-01','Cash'),
(2,2,3500,'2026-07-02','Visa'),
(3,3,4000,'2026-07-03','Cash'),
(4,4,6000,'2026-07-04','Vodafone Cash'),
(5,5,3000,'2026-07-05','Visa'),
(6,6,2500,'2026-07-06','Cash');

INSERT INTO Course
(Course_name,price,duration_hs,city)
VALUES
('SQL',2500,30,'Online'),
('Python',3500,40,'Cairo'),
('Data Analysis',4000,45,'Mansoura'),
('Machine Learning',6000,60,'Online'),
('Power BI',3000,25,'Alexandria');

CREATE TABLE Leads (
    Lead_ID INT IDENTITY(1,1) PRIMARY KEY,
    Full_Name NVARCHAR(100),
    Source VARCHAR(50),
    Status VARCHAR(50)
);

INSERT INTO Leads (Full_Name, Source, Status)
VALUES
('Ali Hassan', 'Facebook', 'New'),
('Mona Ahmed', 'Instagram', 'Contacted'),
('Omar Samy', 'Website', 'Qualified');


SELECT *
FROM Enrollment;

SELECT *
FROM Students
WHERE city = 'Mansoura';

SELECT *
FROM Students
WHERE student_id > 3;

SELECT *
FROM Course
WHERE price > 3000;


SELECT *
FROM Course
WHERE price BETWEEN 2500 AND 4000;



SELECT *
FROM Students
WHERE city IN ('Cairo','Alexandria');


SELECT *
FROM Students
WHERE Full_name LIKE 'M%';

SELECT *
FROM Students
WHERE Full_name LIKE '%d';

SELECT *
FROM Course
ORDER BY price DESC;


SELECT TOP 3 *
FROM Course;

SELECT *
FROM Payment
WHERE amout >= 3000SELECT DISTINCT city
FROM Students;

SELECT DISTINCT method
FROM Payment;

SELECT Full_name, city
FROM Students;

SELECT Course_name, price
FROM Course;

SELECT amout, method
FROM Payment;

SELECT *
FROM Students
WHERE (city = 'Mansoura' OR city = 'Cairo')
AND nationality = 'Egypt';

INSERT INTO Students
(Full_name,email,city,nationality)
VALUES
('Ali Mohamed','ali@gmail.com','Cairo','Egypt');

SELECT *
FROM Students
WHERE phone IS NULL;


SELECT *
FROM Students
WHERE nationality = 'Egypt';


#4

SELECT COUNT(*) AS Total_Students
FROM Students;

SELECT COUNT(*) AS Total_Courses
FROM Course;

SELECT SUM(amout) AS Total_Revenue
FROM Payment;

SELECT AVG(amout) AS Average_Payment
FROM Payment;


SELECT
    c.Course_name,
    SUM(p.amout) AS Total_Revenue
FROM Course c
JOIN Enrollment e
    ON c.Course_id = e.Course_id
JOIN Payment p
    ON e.Enrollment_id = p.Enrollment_id
GROUP BY c.Course_name;


SELECT
    c.Course_name,
    AVG(p.amout) AS Average_Payment
FROM Course c
JOIN Enrollment e
    ON c.Course_id = e.Course_id
JOIN Payment p
    ON e.Enrollment_id = p.Enrollment_id
GROUP BY c.Course_name;



SELECT
    city,
    COUNT(*) AS Total_Students
FROM Students
GROUP BY city;


SELECT
    c.Course_name,
    COUNT(*) AS Enrollment_Count
FROM Course c
JOIN Enrollment e
    ON c.Course_id = e.Course_id
GROUP BY c.Course_name
HAVING COUNT(*) > 1;




--Show each student's enrollment details, total paid, and payment status for 2026 enrollments.
SELECT
    s.Full_name AS student_name,
    c.Course_name AS course_name,
    e.payment_date AS enrollment_date,
    ISNULL(SUM(p.amout), 0) AS total_paid,
    CASE
        WHEN SUM(p.amout) IS NULL THEN 'Unpaid'
        ELSE 'Paid'
    END AS payment_status
FROM Students s
INNER JOIN Enrollment e
    ON s.student_id = e.student_id
INNER JOIN Course c
    ON e.Course_id = c.Course_id
LEFT JOIN Payment p
    ON e.Enrollment_id = p.Enrollment_id
WHERE YEAR(e.payment_date) = 2026
GROUP BY
    s.Full_name,
    c.Course_name,
    e.payment_date
ORDER BY
    s.Full_name,
    c.Course_name;


