/*

	Project Name: Inventory Management System
	Date: 24/05/2024
	Author: Mahfuzur Rahman
	Database Type: Database Generation, SeedData, and Stored Procedures

*/

USE master;
GO

-- Drop the database if it exists
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'InventoryManagementSystem')
DROP DATABASE InventoryManagementSystem;

-- Create the database
CREATE DATABASE InventoryManagementSystem;
GO

USE InventoryManagementSystem;
GO

-- Create the Users table
IF OBJECT_ID('Users', 'U') IS NOT NULL
DROP TABLE Users;

CREATE TABLE Users (
    UserId INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    HashedPassword NVARCHAR(200) NOT NULL,
    Role NVARCHAR(20) NOT NULL,
	Version ROWVERSION
);

-- Create the Role table
IF OBJECT_ID('Roles', 'U') IS NOT NULL
DROP TABLE Roles;

CREATE TABLE Roles (
    RoleId INT IDENTITY(1,1) PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL
);





/*

	Database Type: SeedData

*/

-- Insert into Roles table
INSERT INTO Roles (RoleName) VALUES ('Admin'), ('User');


-- Insert data into the Job table
INSERT INTO Job (Job_Assignment)
VALUES 
('Software Developer'),
('Financial Analyst'),
('HR Manager'),
('Marketing Specialist'),
('Sales Representative'),
('Operations Manager'),
('Legal Counsel'),
('Research Scientist'),
('Customer Service Representative'),
('Administrative Assistant'),
('Network Administrator'),
('Data Analyst'),
('Product Manager'),
('Project Manager'),
('Graphic Designer'),
('Quality Assurance Engineer'),
('Business Analyst'),
('Supply Chain Coordinator'),
('Executive Assistant'),
('IT Support Specialist');


-- Insert data into the Role table
INSERT INTO Role (Role_Name) VALUES
('HR Supervisor'),
('HR Employee'),
('Regular Supervisor'),
('Regular Employee');


-- Insert data into Employee_Status
INSERT INTO Employee_Status (Status_Name) VALUES
('Active'),
('Retired'),
('Terminated');

-- Insert CEO first
INSERT INTO Employee (
    First_Name, Last_Name, Middle_Initial, HashedPassword, Street_Address, 
    City, Postal_Code, Date_Of_Birth, SIN, Seniority_Date, Job_Start_Date, 
    Work_Phone_Number, Cell_Phone_Number, Email_Address, Supervisor_ID, 
    Supervisor_Indicator, Department_ID, Job_ID, Role_ID, Employee_Status_ID
)
VALUES 
('Tousif', 'Mahbub', 'S', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '1309 Mountain Road', 'Moncton', 'E1C 2T9', '1987-01-01', '123 456 789', '2005-01-01', '2005-01-15', '(123) 456-7890', '(123) 456-7891', 'john.doe@example.com', NULL, 1, 1, 1, 4, 1);

-- Drop trigger if it already exists
IF OBJECT_ID('dbo.trg_SupervisorLimit', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_SupervisorLimit;
GO

-- Create or alter the trigger
CREATE OR ALTER TRIGGER trg_SupervisorLimit
ON Employee
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Check for supervisors exceeding the limit of 10 employees
    IF EXISTS (
        SELECT Supervisor_ID
        FROM Employee
        WHERE Supervisor_ID IS NOT NULL
        GROUP BY Supervisor_ID
        HAVING COUNT(*) > 10
    )
    BEGIN
        RAISERROR('Please choose another supervisor, the supervisor already has 10 employees assigned.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Insert multiple employees with hashed passwords
INSERT INTO Employee (
    First_Name, Last_Name, Middle_Initial, HashedPassword, Street_Address, 
    City, Postal_Code, Date_Of_Birth, SIN, Seniority_Date, Job_Start_Date, Work_Phone_Number, Cell_Phone_Number, Email_Address, Supervisor_ID, Supervisor_Indicator, Department_ID, Job_ID, Role_ID, Employee_Status_ID,
    Retirement_Date, Termination_Date
)
VALUES 
-- Mahfuzur Rahman already has 10 employees under his supervisor (Department ID 2 - Finance) 
('Mahfuzur', 'Rahman', 'B', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '1309 Mountain Road', 'Moncton', 'E1C 2T9', '1987-01-01', '224 336 448', '2010-02-01', '2010-02-15', '(123) 456-7892', '(123) 456-7893', 'mrahmanlinks@gmail.com', 1, 1, 2, 2, 2, 1, NULL, NULL), -- HR Employee 
('Blake', 'Stewart', 'C', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '789 Pine St', 'Moncton', 'E1C 1A9', '1990-03-03', '224 336 449', '2015-03-01', '2015-03-15', '(123) 456-7894', '(123) 456-7895', 'alice.johnson@example.com', 1, 1, 3, 3, 2, 1, NULL, NULL), -- HR Employee
-- Bob Brown has the ability to be assigned more regular employees
('Bob', 'Brown', 'D', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '101 Maple St', 'Springfield', 'E1C 1A9', '1995-04-04', '224 336 450', '2020-04-01', '2020-04-15', '(123) 456-7896', '(123) 456-7897', 'bob.brown@example.com', 2, 1, 2, 2, 2, 1, NULL, NULL), -- HR Employee
('Carol', 'Davis', 'E', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '202 Birch St', 'Springfield', 'E1G 4X9', '1988-05-05', '224 336 451', '2008-05-01', '2008-05-15', '(123) 456-7898', '(123) 456-7899', 'carol.davis@example.com', 2, 4, 1, 4, 3, 1, NULL, NULL),-- Regular Supervisor
-- David Wilson, his age is 47 years old, he cannot retire before the age of 65 and he can retire on or after 2042
-- Retirement date must needed if his staus set to retired
('David', 'Wilson', 'F', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '303 Cedar St', 'Springfield', 'E1G 4X9', '1977-06-06', '224 336 452', '1997-06-01', '1997-06-15', '(123) 456-7900', '(123) 456-7901', 'david.wilson@example.com', 2, 1, 3, 6, 3, 1, NULL, NULL), -- Regular Supervisor
('Eve', 'Miller', 'G', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '404 Walnut St', 'Springfield', 'B3N 3H5', '1982-07-07', '224 336 453', '2002-07-01', '2002-07-15', '(123) 456-7902', '(123) 456-7903', 'eve.miller@example.com', 2, 1, 4, 5, 3, 1, NULL, NULL), -- Regular Supervisor
('Frank', 'Taylor', 'H', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '505 Poplar St', 'Springfield', 'B3N 3H5', '1987-08-08', '224 336 454', '2007-08-01', '2007-08-15', '(123) 456-7904', '(123) 456-7905', 'frank.taylor@example.com', 2, 1, 5, 8, 4, 1, NULL, NULL),
('Grace', 'Anderson', 'I', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '606 Ash St', 'Springfield', 'B3N 3H5', '1976-09-09', '224 336 455', '1996-09-01', '1996-09-15', '(123) 456-7906', '(123) 456-7907', 'grace.anderson@example.com', 2, 1, 6, 9, 4, 1, NULL, NULL),
('Henry', 'Thomas', 'J', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '707 Willow St', 'Springfield', 'B3N 3H5', '1992-10-10', '224 336 456', '2012-10-01', '2012-10-15', '(123) 456-7908', '(123) 456-7909', 'henry.thomas@example.com', 2, 1, 6, 10, 4, 1, NULL, NULL),
('Isaac', 'Clark', 'K', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '808 Elm St', 'Springfield', 'E1G 0V2', '1983-11-11', '224 336 457', '2003-11-01', '2003-11-15', '(123) 456-7910', '(123) 456-7911', 'isaac.clark@example.com', 2, 1, 7, 3, 4, 1, NULL, NULL),
('Karen', 'Martinez', 'M', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '1010 Spruce St', 'Springfield', 'E1G 0V2', '1986-01-13', '224 336 458', '2006-01-01', '2006-01-15', '(123) 456-7912', '(123) 456-7913', 'karen.martinez@example.com', 2, 1, 7, 3, 4, 1, NULL, NULL),
('Leo', 'Garcia', 'N', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '1111 Hickory St', 'Springfield', 'E1G 0V2', '1999-02-14', '224 336 459', '2019-02-01', '2019-02-15', '(123) 456-7914', '(123) 456-7915', 'leo.garcia@example.com', 3, 1, 7, 2, 4, 1, NULL, NULL),
('Oliver', 'Gonzalez', 'Q', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '1414 Pine St', 'Springfield', 'E1G 0V2', '1981-05-17', '224 336 460', '2001-05-01', '2001-05-15', '(123) 456-7916', '(123) 456-7917', 'oliver.gonzalez@example.com', 1, 1, 8, 8, 4, 1, NULL, NULL),
('Jack', 'Harris', 'L', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '909 Chestnut St', 'Springfield', 'E1A 2R9', '1994-12-12', '224 336 461', '2014-12-01', '2014-12-15', '(123) 456-7918', '(123) 456-7919', 'jack.harris@example.com', 2, 0, 8, 4, 4, 2, NUll, NULL),
('Mia', 'Martinez', 'O', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '1212 Cypress St', 'Springfield', 'E1A 2R9', '1991-03-15', '224 336 462', '2011-03-01', '2011-03-15', '(123) 456-7920', '(123) 456-7921', 'mia.martinez@example.com', 1, 0, 9, 4, 4, 1, NULL, NULL),
--Nina Loperz (Terminated, her status can be changed to active but retirement date cannot be changed)
('Nina', 'Lopez', 'P', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '1313 Fir St', 'Springfield', 'E1A 1X2', '1989-04-16', '224 336 463', '2009-04-01', '2009-04-15', '(123) 456-7922', '(123) 456-7923', 'nina.lopez@example.com', 1, 1, 9, 5, 4, 2, '2024-08-01', NULL), -- Retired
('Paula', 'Kim', 'R', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '1515 Maple St', 'Springfield', 'E1A 1X2', '1984-06-18', '224 336 464', '2004-06-01', '2004-06-15', '(123) 456-7924', '(123) 456-7925', 'paula.kim@example.com', 1, 1, 10, 3, 4, 2, '2018-07-01', NULL), -- Retired
-- Quincy Perez is termintated, her status can be changed to active and the termination date will be reset
('Quincy', 'Perez', 'S', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '1616 Oak St', 'Springfield', 'E1A 1X2', '1975-07-19', '224 336 465', '1995-07-01', '1995-07-15', '(123) 456-7926', '(123) 456-7927', 'quincy.perez@example.com', 1, 1, 2, 6, 4, 3, NULL, '2020-01-01'), -- Terminated
('Rachel', 'White', 'T', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), '1717 Cedar St', 'Springfield', 'E1A 1X2', '1993-08-20', '224 336 466', '2013-08-01', '2013-08-15', '(123) 456-7928', '(123) 456-7929', 'rachel.white@example.com', 1, 1, 3, 9, 4, 3, NULL, '2005-01-01'); -- Terminated


-- Insert initial data into the Rating table
INSERT INTO Rating (Rating_Description)
VALUES ('Below Expectations'), ('Meets Expectations'), ('Exceeds Expectations');

-- Insert the quarters
INSERT INTO Quarter (Quarter_ID, Quarter_Name, Start_Month, Start_Day, End_Month, End_Day)
VALUES
(1, 'Q1: Jan 1 - Mar 31', 1, 1, 3, 31),
(2, 'Q2: Apr 1 - Jun 30', 4, 1, 6, 30),
(3, 'Q3: Jul 1 - Sep 30', 7, 1, 9, 30),
(4, 'Q4: Oct 1 - Dec 31', 10, 1, 12, 31);

-- Insert sample reviews into the Employee_Review table
INSERT INTO Employee_Review (Employee_ID, Supervisor_ID, Review_Date, Rating_ID, Comments, Quarter_ID)
VALUES 
(1, 3, '2024-01-15', 2, 'Meeting expectations consistently.', 1), -- Q1
(2, 4, '2024-04-20', 3, 'Exceeding expectations in all areas.', 2), -- Q2
(3, 5, '2024-07-10', 1, 'Below expectations, needs improvement.', 3), -- Q3
(4, 6, '2024-10-05', 2, 'Meeting expectations with some areas for improvement.', 4), -- Q4
(5, 7, '2024-01-20', 3, 'Excellent performance.', 1), -- Q1
(6, 8, '2024-04-25', 1, 'Needs significant improvement.', 2), -- Q2
(7, 9, '2024-07-15', 2, 'Meeting expectations.', 3), -- Q3
(8, 10, '2024-10-10', 3, 'Outstanding achievements.', 4), -- Q4
(9, 3, '2024-02-28', 2, 'Consistent and reliable.', 1), -- Q1
(10, 4, '2024-05-15', 1, 'Requires attention to detail.', 2); -- Q2




INSERT INTO Purchase_Order_Status (Purchase_Order_Status_ID, Purchase_Order_Status_Name) VALUES
(1, 'Active'),
(2, 'Inactive'),
(3, 'Pending'),
(4, 'Completed'),
(5, 'Cancelled'),
(6, 'On Hold'),
(7, 'Under Review'),
(8, 'Closed')

INSERT INTO Order_Item_Status(Order_Item_Status_ID, Order_Item_Status_Name) VALUES
(1, 'Pending'),
(2, 'Approved'),
(3, 'Denied')

-- Insert data into the Purchase_Order table
INSERT INTO Purchase_Order (Purchase_Order_Number, Employee_ID, Purchase_Order_Status_ID, Creation_Date) VALUES
('00000101', 1, 7, '2024-04-01'),
('00000102',2, 3, '2024-03-15'),
('00000103',3, 3, '2024-03-20'),
('00000104',1, 2, '2024-01-25'),
('00000105',1, 5, '2024-02-11'),
('00000106',5, 3, '2024-02-24'),
('00000107',2, 3, '2024-03-05'),
('00000108',2, 7, '2024-5-14'),
('00000109',3, 7, '2024-5-24'),
('00000110', 5, 7, '2024-05-10'),
('00000111', 5, 3, '2024-05-12'),
('00000112', 6, 2, '2024-05-14'),
('00000113', 6, 7, '2024-05-16'),
('00000114', 7, 3, '2024-05-18'),
('00000115', 7, 7, '2024-05-20');


-- Insert data into the Order_Item table including Status_ID
INSERT INTO Order_Item (Purchase_Order_Number, Name, Description, Quantity, Price, Justification, Purchase_Location, Order_Item_Status_ID) VALUES
('00000101', 'Laptop', 'Dell XPS 15 - High-performance laptop for software development', 10, 1899.99, 'Team hardware upgrade', 'Dell Online Store', 1),
('00000101', 'Mouse', 'Logitech MX Master 3 - Advanced wireless mouse', 10, 99.99, 'Team hardware upgrade', 'Amazon', 1),
('00000101', 'Software License', 'Microsoft Office 365 Business License', 5, 149.99, 'New hires', 'Microsoft Store', 3),
('00000102', 'Chair', 'Ergonomic Office Chair', 5, 320.50, 'Office refurbishment', 'Office Depot', 1),
('00000102', 'Desk', 'Standing Desk - Adjustable height', 7, 400.00, 'Office refurbishment', 'Ikea', 1),
('00000102', 'Monitor', '27\" 4K UHD Monitor', 7, 449.99, 'Team hardware upgrade', 'Best Buy', 1),
('00000103', 'Keyboard', 'Mechanical Keyboard - Cherry MX Brown Switches', 15, 120.00, 'Team hardware upgrade', 'Newegg', 1),
('00000103', 'Webcam', '1080p HD Webcam', 15, 89.99, 'Remote work setup', 'Amazon', 1),
('00000103', 'Notebook', 'Professional Moleskine Notebook', 25, 19.99, 'Conference supplies', 'Staples', 1),
('00000104', 'Pen', 'Pilot G2 Premium Gel Roller', 50, 1.99, 'Conference supplies', 'Staples', 1),
('00000104', 'Coffee Machine', 'Keurig K-Cafe Coffee Maker', 1, 199.99, 'Kitchen equipment', 'Walmart', 1),
('00000104', 'Water Dispenser', 'Bottled Water Dispenser', 1, 149.99, 'Kitchen equipment', 'Costco', 3),
('00000105', 'Router', 'Wi-Fi 6 Router', 2, 259.99, 'Network upgrade', 'Best Buy', 1),
('00000105', 'NAS Storage', 'Synology DS920+ NAS Storage', 1, 550.00, 'Data backup solutions', 'Amazon', 2),
('00000105', 'Printer', 'HP LaserJet Pro Printer', 2, 389.99, 'Office equipment', 'HP Online Store', 3),
('00000106', 'Scanner', 'Fujitsu ScanSnap iX1500', 2, 419.99, 'Office equipment', 'Fujitsu Store', 1),
('00000106', 'Projector', 'Epson 1080p Projector', 1, 645.00, 'Presentation equipment', 'Epson Store', 2),
('00000106', 'Whiteboard', 'Magnetic Dry Erase Board', 3, 150.00, 'Meeting rooms', 'Office Depot', 3),
('00000106', 'Smartphone', 'Samsung Galaxy S21', 20, 799.99, 'Employee phones', 'Samsung Store', 1),
('00000107', 'Tablet', 'Apple iPad Pro 11-inch', 20, 749.00, 'Employee tablets', 'Apple Store', 1),
('00000108', 'Printer Ink', 'HP Printer Ink Cartridges', 3, 45.99, 'Office supplies replenishment', 'Office Depot', 1),
('00000108', 'External Hard Drive', '2TB External Hard Drive', 4, 99.99, 'Data backup solutions', 'Best Buy', 2),
('00000108', 'Desk Lamp', 'LED Desk Lamp', 2, 29.99, 'Office lighting', 'Amazon', 3),
('00000109', 'Desk Organizer', 'Mesh Desk Organizer', 5, 19.99, 'Office organization', 'Staples', 1),
('00000109', 'Cable Management Kit', 'Under Desk Cable Management Tray', 10, 12.99, 'Office cable management', 'Amazon', 2),
('00000109', 'Standing Desk Mat', 'Anti-Fatigue Standing Desk Mat', 3, 39.99, 'Standing desk accessory', 'Office Depot', 3),
('00000110', 'Headphones', 'Noise Cancelling Headphones', 15, 299.99, 'Employee equipment', 'Amazon', 1),
('00000110', 'Laptop Stand', 'Adjustable Laptop Stand', 15, 49.99, 'Employee equipment', 'Amazon', 1),
('00000111', 'Office Chair Mat', 'PVC Chair Mat for Carpeted Floors', 10, 34.99, 'Office supplies', 'Office Depot', 3),
('00000111', 'Foot Rest', 'Ergonomic Foot Rest', 10, 24.99, 'Office supplies', 'Staples', 1),
('00000112', 'Conference Phone', 'Polycom SoundStation IP 6000', 1, 499.99, 'Meeting room equipment', 'Amazon', 1),
('00000112', 'Network Switch', '24-Port Gigabit Switch', 2, 179.99, 'Office network upgrade', 'Best Buy', 1),
('00000113', 'Projector Screen', '120" Pull-Down Projector Screen', 1, 129.99, 'Presentation equipment', 'Walmart', 1),
('00000113', 'Server Rack', '42U Server Rack', 1, 899.99, 'Data center equipment', 'Newegg', 3),
('00000114', 'USB Hub', '10-Port USB 3.0 Hub', 5, 39.99, 'Office supplies', 'Amazon', 1),
('00000114', 'Portable SSD', '1TB Portable SSD', 10, 149.99, 'Employee equipment', 'Best Buy', 1),
('00000115', 'Office Desk', 'Executive Office Desk', 3, 699.99, 'Office furniture', 'Ikea', 3),
('00000115', 'Office Sofa', 'Leather Office Sofa', 2, 899.99, 'Office furniture', 'Ikea', 3);
GO


/*

	Team Name: Kilo (Blake Stewart and Mahfuzur Rahman)
	WMAD
	Date: 30/04/2024
	Description: Capstone Project
	Database Type: Stored Procedure

*/


-- Get All Departments
CREATE OR ALTER PROCEDURE spGetDepartments
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Department_ID,
        Department_Name,
        Description,
        Invocation_Date
    FROM Department
    ORDER BY Department_Name;
END
GO


-- Get Department By ID
CREATE OR ALTER PROCEDURE spGetDepartmentById
    @Department_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Department_ID,
        Department_Name,
        Description,
        Invocation_Date
    FROM
        Department
    WHERE
        Department_ID = @Department_ID;

    SET NOCOUNT OFF;
END
GO

CREATE OR ALTER PROCEDURE spGetDepartmentByName
    @Department_Name VARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Department_ID,
        Department_Name,
        Description,
        Invocation_Date
    FROM
        Department
    WHERE
        Department_Name = @Department_Name;

    SET NOCOUNT OFF;
END
GO

-- Get active departments
CREATE OR ALTER PROCEDURE spGetActiveEDepartments
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        d.Department_ID, 
        d.Department_Name, 
        d.Description, 
        d.Invocation_Date, 
        d.Version,
        STRING_AGG(CAST(emp.Employee_ID AS VARCHAR(10)), ',') AS SupervisorIDs  -- This must appear in the output
    FROM Department d
    LEFT JOIN Employee emp ON d.Department_ID = emp.Department_ID AND emp.Supervisor_Indicator = 1
    WHERE d.Invocation_Date <= GETDATE()
    GROUP BY d.Department_ID, d.Department_Name, d.Description, d.Invocation_Date, d.Version
    ORDER BY d.Department_Name ASC;

    SET NOCOUNT OFF;
END
GO



-- Update Department
CREATE OR ALTER PROCEDURE spUpdateDepartment
    @DepartmentID INT,
    @DepartmentName NVARCHAR(128),
    @DepartmentDescription NVARCHAR(512),
    @InvocationDate DATE,
    @Version ROWVERSION
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExistingInvocationDate DATE;

    -- Retrieve the existing invocation date
    SELECT @ExistingInvocationDate = Invocation_Date
    FROM Department
    WHERE Department_ID = @DepartmentID;

    -- Check if the current version matches
    IF NOT EXISTS (
        SELECT 1
        FROM Department
        WHERE Department_ID = @DepartmentID AND Version = @Version
    )
    BEGIN
        RAISERROR('The record has been modified by another user.', 16, 1);
        RETURN;
    END

    -- Check if the new invocation date is in the past relative to the existing invocation date
    IF @InvocationDate < @ExistingInvocationDate
    BEGIN
        RAISERROR('The new invocation date cannot be earlier than the existing invocation date.', 16, 1);
        RETURN;
    END

    -- Proceed with the update
    UPDATE Department
    SET
        Department_Name = @DepartmentName,
        Description = @DepartmentDescription,
        Invocation_Date = @InvocationDate
    WHERE Department_ID = @DepartmentID AND Version = @Version;

    -- Check if the update was successful
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR('No department record was updated.', 16, 1);
    END

    SET NOCOUNT OFF;
END
GO




CREATE OR ALTER PROCEDURE spGetSupervisorDepartmentById
    @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        * 
    FROM Department
    WHERE Department_ID = @DepartmentID;
END
GO



-- Get Supervisor by Department ID
CREATE OR ALTER PROCEDURE spGetSupervisorByDepartmentId
    @DepartmentID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        e.Employee_ID,
        e.First_Name AS First_Name,
        e.Last_Name AS Last_Name,
        e.Supervisor_Indicator,
        e.Department_ID,
        e.Supervisor_ID
    FROM 
        Employee e
    WHERE 
        e.Department_ID = @DepartmentID 
        AND e.Supervisor_Indicator = 1;
END
GO

-- Add Department
CREATE OR ALTER PROCEDURE spAddDepartment
    @Department_ID INT OUTPUT,
    @Department_Name VARCHAR(128),
    @Description VARCHAR(512),
    @Invocation_Date DATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Department (Department_Name, Description, Invocation_Date)
    VALUES (@Department_Name, @Description, @Invocation_Date);

    SET @Department_ID = SCOPE_IDENTITY();

    SET NOCOUNT OFF;
END
GO

-- Get Job Assignemnts
CREATE OR ALTER PROCEDURE spGetJobAssignments
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Job_ID, Job_Assignment
    FROM Job;
END
GO

-- Get all Roles
CREATE OR ALTER PROCEDURE spGetAllRoles
AS
BEGIN
    SELECT Role_ID, Role_Name
    FROM Role;
END
GO

-- Get last Employee Number
CREATE OR ALTER PROCEDURE spGetLastEmployeeNumber
AS
BEGIN
    SET NOCOUNT ON;

    -- Retrieve the last Employee Number
    SELECT MAX(Employee_Number) AS LastEmployeeNumber
    FROM Employee;
END
GO

-- Adding an Employee
--CREATE OR ALTER PROCEDURE spAddEmployee
--    @First_Name NVARCHAR(50),
--    @Last_Name NVARCHAR(50),
--    @Middle_Initial CHAR(1) = NULL,
--    @HashedPassword VARCHAR(64),
--    @Street_Address VARCHAR(50),
--    @City VARCHAR(50),
--    @Postal_Code VARCHAR(10),
--    @Date_Of_Birth DATE,
--    @SIN VARCHAR(11),
--    @Seniority_Date DATE,
--    @Job_Start_Date DATE,
--	@Work_Phone_Number VARCHAR(14),
--    @Cell_Phone_Number VARCHAR(14) = NULL,
--    @Email_Address VARCHAR(50),
--    @Supervisor_ID INT = NULL,
--	@Supervisor_Indicator BIT,
--	@Department_ID INT,
--    @Job_ID INT,
--    @Role_ID INT,
--	@Employee_Status_ID INT,
--    @Retirement_Date DATE = NULL,
--    @Termination_Date DATE = NULL
--AS
--BEGIN
--    SET NOCOUNT ON;
    
--    BEGIN TRY
--        -- Start the transaction
--        BEGIN TRANSACTION;

--		-- Check if the SIN already exists
--        IF EXISTS (SELECT 1 FROM Employee WHERE SIN = @SIN)
--        BEGIN
--            RAISERROR('The Social Insurance Number (SIN) already exists. Please provide a unique SIN.', 16, 1);
--            ROLLBACK TRANSACTION;
--            RETURN;
--        END

--		-- Insert the employee record
--        INSERT INTO Employee (First_Name, 
--            Last_Name, 
--            Middle_Initial, 
--            HashedPassword, 
--            Street_Address, 
--            City, 
--            Postal_Code, 
--            Date_Of_Birth, 
--            SIN, 
--            Seniority_Date, 
--            Job_Start_Date, 
--            Department_ID, 
--            Supervisor_ID, 
--            Work_Phone_Number, 
--            Cell_Phone_Number, 
--            Email_Address, 
--            Job_ID, 
--            Role_ID, 
--            Supervisor_Indicator, 
--            Employee_Status_ID, 
--            Retirement_Date, 
--            Termination_Date
--			)
--	   VALUES (@First_Name, 
--            @Last_Name, 
--            @Middle_Initial, 
--            @HashedPassword, 
--            @Street_Address, 
--            @City, 
--            @Postal_Code, 
--            @Date_Of_Birth, 
--            @SIN, 
--            @Seniority_Date, 
--            @Job_Start_Date, 
--            @Department_ID, 
--            @Supervisor_ID, 
--            @Work_Phone_Number, 
--            @Cell_Phone_Number, 
--            @Email_Address, 
--            @Job_ID, 
--            @Role_ID, 
--            @Supervisor_Indicator, 
--            @Employee_Status_ID,
--            @Retirement_Date, 
--            @Termination_Date
--		   );

--        -- Commit the transaction
--        COMMIT TRANSACTION;

--    END TRY
--    BEGIN CATCH
--        -- Rollback the transaction if an error occurs
--        IF @@TRANCOUNT > 0
--            ROLLBACK TRANSACTION;

--        -- Raise an error or handle it as required
--        THROW;
--    END CATCH;
--END
--GO

CREATE OR ALTER PROCEDURE spAddEmployee
    @First_Name NVARCHAR(50),
    @Last_Name NVARCHAR(50),
    @Middle_Initial CHAR(1) = NULL,
    @HashedPassword VARCHAR(64),
    @Street_Address VARCHAR(50),
    @City VARCHAR(50),
    @Postal_Code VARCHAR(10),
    @Date_Of_Birth DATE,
    @SIN VARCHAR(11),
    @Seniority_Date DATE,
    @Job_Start_Date DATE,
    @Work_Phone_Number VARCHAR(14),
    @Cell_Phone_Number VARCHAR(14) = NULL,
    @Email_Address VARCHAR(50),
    @Supervisor_ID INT = NULL,
    @Supervisor_Indicator BIT,
    @Department_ID INT,
    @Job_ID INT,
    @Role_ID INT,
    @Employee_Status_ID INT,
    @Retirement_Date DATE = NULL,
    @Termination_Date DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate the SIN
    IF EXISTS (SELECT 1 FROM Employee WHERE SIN = @SIN)
    BEGIN
        RAISERROR('The Social Insurance Number (SIN) already exists. Please provide a unique SIN.', 16, 1);
        RETURN;
    END

    -- Validate the job start date
    IF @Job_Start_Date < @Seniority_Date
    BEGIN
        RAISERROR('The job start date cannot be prior to the seniority date.', 16, 1);
        RETURN;
    END

    -- Start the transaction
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert the employee record
        INSERT INTO Employee (
            First_Name, 
            Last_Name, 
            Middle_Initial, 
            HashedPassword, 
            Street_Address, 
            City, 
            Postal_Code, 
            Date_Of_Birth, 
            SIN, 
            Seniority_Date, 
            Job_Start_Date, 
            Department_ID, 
            Supervisor_ID, 
            Work_Phone_Number, 
            Cell_Phone_Number, 
            Email_Address, 
            Job_ID, 
            Role_ID, 
            Supervisor_Indicator, 
            Employee_Status_ID, 
            Retirement_Date, 
            Termination_Date
        ) VALUES (
            @First_Name, 
            @Last_Name, 
            @Middle_Initial, 
            @HashedPassword, 
            @Street_Address, 
            @City, 
            @Postal_Code, 
            @Date_Of_Birth, 
            @SIN, 
            @Seniority_Date, 
            @Job_Start_Date, 
            @Department_ID, 
            @Supervisor_ID, 
            @Work_Phone_Number, 
            @Cell_Phone_Number, 
            @Email_Address, 
            @Job_ID, 
            @Role_ID, 
            @Supervisor_Indicator, 
            @Employee_Status_ID,
            @Retirement_Date, 
            @Termination_Date
        );

        -- Commit the transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback the transaction if an error occurs
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Raise an error or handle it as required
        THROW;
    END CATCH;
END
GO


-- Update Job Information
CREATE OR ALTER PROCEDURE spUpdateJobInformation
    @EmployeeID int,
    @SIN varchar(50),
    @Seniority_Date date,
	@Job_Start_Date date,
    @Job_ID int,
    @Supervisor_ID int,
    @Department_ID int,
    @Work_Phone_Number varchar(14),
    @Email_Address varchar(50),
    @Version ROWVERSION
AS
BEGIN
    SET NOCOUNT ON;

    -- Check for unique SIN before updating
    IF EXISTS (SELECT 1 FROM Employee WHERE SIN = @SIN AND Employee_ID != @EmployeeID)
    BEGIN
        RAISERROR('The Social Insurance Number (SIN) already exists. Please provide a unique SIN.', 16, 1);
        RETURN;
    END

    -- Update job information and reset Job Start Date
    UPDATE Employee
    SET 
        SIN = @SIN,
        Seniority_Date = @Seniority_Date,
        Job_ID = @Job_ID,
        Job_Start_Date = @Job_Start_Date,
        Supervisor_ID = @Supervisor_ID,
        Department_ID = @Department_ID,
        Work_Phone_Number = @Work_Phone_Number,
        Email_Address = @Email_Address
       
    WHERE Employee_ID = @EmployeeID AND Version = @Version;

    IF @@ROWCOUNT = 0
    BEGIN
        -- Check if the concurrency check failed
        IF NOT EXISTS (SELECT 1 FROM Employee WHERE Employee_ID = @EmployeeID AND Version = @Version)
        BEGIN
            RAISERROR('The record has been modified by another user. Please refresh and try again.', 16, 1);
        END
        ELSE
        BEGIN
            RAISERROR('No record updated. Please check your input.', 16, 1);
        END
    END

    RETURN;
END
GO

-- Get the Employee Status
CREATE OR ALTER PROCEDURE spGetEmployeeStatus
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Employee_Status_ID, Status_Name
    FROM Employee_Status
    ORDER BY Employee_Status_ID; 
END
GO

-- Get the Employee Status By Id
CREATE OR ALTER PROCEDURE GetStatusNameById
    @StatusID INT
AS
BEGIN
    SELECT Status_Name
    FROM Employee_Status
    WHERE Employee_Status_ID = @StatusID;
END
GO

---- Update the employement status
--CREATE OR ALTER PROCEDURE spUpdateEmploymentStatus
--    @EmployeeID INT,
--    @Employee_Status_ID INT,
--    @TerminationDate DATETIME = NULL,
--    @RetirementDate DATETIME = NULL,
--    @Version ROWVERSION 
--AS
--BEGIN
--    SET NOCOUNT ON;

--    DECLARE @DateOfBirth DATE;
--    SELECT @DateOfBirth = Date_Of_Birth FROM Employee WHERE Employee_ID = @EmployeeID;

--    -- Check if the status is 'Terminated' and ensure TerminationDate is provided
--    IF (@Employee_Status_ID = (SELECT Employee_Status_ID FROM Employee_Status WHERE Status_Name = 'Terminated') AND @TerminationDate IS NULL)
--    BEGIN
--        RAISERROR ('Termination date must be provided for terminated status.', 16, 1);
--        RETURN;
--    END

--    -- Check if the status is 'Retired' and ensure RetirementDate is provided
--    IF (@Employee_Status_ID = (SELECT Employee_Status_ID FROM Employee_Status WHERE Status_Name = 'Retired') AND @RetirementDate IS NULL)
--    BEGIN
--        RAISERROR ('Retirement date must be provided for retired status.', 16, 1);
--        RETURN;
--    END

--    -- Ensure retirement date cannot be changed once set
--    IF (@Employee_Status_ID = (SELECT Employee_Status_ID FROM Employee_Status WHERE Status_Name = 'Retired') 
--        AND EXISTS (SELECT 1 FROM Employee WHERE Employee_ID = @EmployeeID AND Retirement_Date IS NOT NULL AND Retirement_Date <> @RetirementDate))
--    BEGIN
--        RAISERROR ('Retirement date cannot be changed once set.', 16, 1);
--        RETURN;
--    END

--    -- Ensure employees cannot retire before the age of 65
--    IF (@Employee_Status_ID = (SELECT Employee_Status_ID FROM Employee_Status WHERE Status_Name = 'Retired') 
--        AND @RetirementDate < DATEADD(YEAR, 65, @DateOfBirth))
--    BEGIN
--        RAISERROR ('Employees cannot retire before the age of 65.', 16, 1);
--        RETURN;
--    END

--    -- Update the employee status
--    UPDATE Employee
--    SET Employee_Status_ID = @Employee_Status_ID,
--        Termination_Date = CASE WHEN @Employee_Status_ID = (SELECT Employee_Status_ID FROM Employee_Status WHERE Status_Name = 'Terminated') THEN @TerminationDate ELSE NULL END,
--        Retirement_Date = CASE WHEN @Employee_Status_ID = (SELECT Employee_Status_ID FROM Employee_Status WHERE Status_Name = 'Retired') THEN @RetirementDate ELSE Retirement_Date END
--    WHERE Employee_ID = @EmployeeID AND Version = @Version;

--    -- Check for concurrency issues
--    IF @@ROWCOUNT = 0
--    BEGIN
--        RAISERROR ('Concurrency error: The employee record was modified by another process.', 16, 1);
--        RETURN;
--    END
--END
--GO


CREATE OR ALTER PROCEDURE spUpdateEmploymentStatus
    @EmployeeID INT,
    @Employee_Status_ID INT,
    @TerminationDate DATETIME = NULL,
    @RetirementDate DATETIME = NULL,
    @SeniorityDate DATETIME = NULL,  -- New parameter
    @JobStartDate DATETIME = NULL,   -- New parameter
    @Version ROWVERSION 
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DateOfBirth DATE;
    SELECT @DateOfBirth = Date_Of_Birth FROM Employee WHERE Employee_ID = @EmployeeID;

    -- Check if the status is 'Terminated' and ensure TerminationDate is provided
    IF (@Employee_Status_ID = (SELECT Employee_Status_ID FROM Employee_Status WHERE Status_Name = 'Terminated') AND @TerminationDate IS NULL)
    BEGIN
        RAISERROR ('Termination date must be provided for terminated status.', 16, 1);
        RETURN;
    END

    -- Check if the status is 'Retired' and ensure RetirementDate is provided
    IF (@Employee_Status_ID = (SELECT Employee_Status_ID FROM Employee_Status WHERE Status_Name = 'Retired') AND @RetirementDate IS NULL)
    BEGIN
        RAISERROR ('Retirement date must be provided for retired status.', 16, 1);
        RETURN;
    END

    -- Ensure retirement date cannot be changed once set
    IF (@Employee_Status_ID = (SELECT Employee_Status_ID FROM Employee_Status WHERE Status_Name = 'Retired') 
        AND EXISTS (SELECT 1 FROM Employee WHERE Employee_ID = @EmployeeID AND Retirement_Date IS NOT NULL AND Retirement_Date <> @RetirementDate))
    BEGIN
        RAISERROR ('Retirement date cannot be changed once set.', 16, 1);
        RETURN;
    END

    -- Ensure employees cannot retire before the age of 65
    IF (@Employee_Status_ID = (SELECT Employee_Status_ID FROM Employee_Status WHERE Status_Name = 'Retired') 
        AND @RetirementDate < DATEADD(YEAR, 65, @DateOfBirth))
    BEGIN
        RAISERROR ('Employees cannot retire before the age of 65.', 16, 1);
        RETURN;
    END

    -- Update the employee status
    UPDATE Employee
    SET Employee_Status_ID = @Employee_Status_ID,
        Termination_Date = CASE WHEN @Employee_Status_ID = (SELECT Employee_Status_ID FROM Employee_Status WHERE Status_Name = 'Terminated') THEN @TerminationDate ELSE NULL END,
        Retirement_Date = CASE WHEN @Employee_Status_ID = (SELECT Employee_Status_ID FROM Employee_Status WHERE Status_Name = 'Retired') THEN @RetirementDate ELSE Retirement_Date END,
        Seniority_Date = CASE WHEN @Employee_Status_ID = (SELECT Employee_Status_ID FROM Employee_Status WHERE Status_Name = 'Active') THEN @SeniorityDate ELSE Seniority_Date END,
        Job_Start_Date = CASE WHEN @Employee_Status_ID = (SELECT Employee_Status_ID FROM Employee_Status WHERE Status_Name = 'Active') THEN @JobStartDate ELSE Job_Start_Date END
    WHERE Employee_ID = @EmployeeID AND Version = @Version;

    -- Check for concurrency issues
    IF @@ROWCOUNT = 0
    BEGIN
        RAISERROR ('Concurrency error: The employee record was modified by another process.', 16, 1);
        RETURN;
    END
END
GO






-- Search Employee Directory
CREATE OR ALTER PROCEDURE spSearchEmployeeDirectory
    @DepartmentId INT = NULL,
    @EmployeeId INT = NULL,
    @LastName VARCHAR(50) = NULL
AS
BEGIN
    SELECT 
        e.Employee_ID AS EmployeeID,
        e.Last_Name AS LastName,
        e.First_Name AS FirstName,
        j.Job_Assignment AS Position
    FROM 
        Employee e
    INNER JOIN 
        Job j ON e.Job_ID = j.Job_ID
    INNER JOIN
        Employee_Status es ON e.Employee_Status_ID = es.Employee_Status_ID
    WHERE 
        (e.Department_ID = @DepartmentId OR @DepartmentId IS NULL) AND
        (e.Employee_ID = @EmployeeId OR @EmployeeId IS NULL) AND
        (e.Last_Name LIKE '%' + @LastName + '%' OR @LastName IS NULL) AND
        e.Employee_Status_ID = 1
END
GO


CREATE OR ALTER PROCEDURE spGetJobSupervisors
    @EmployeeID INT
AS
BEGIN
    SELECT 
        e.Employee_ID,
        e.First_Name + ' ' + e.Last_Name AS FullName
    FROM Employee e
    WHERE e.Supervisor_ID = @EmployeeID
END
GO



-- Search Employee
CREATE OR ALTER PROCEDURE SearchEmployees
    @Department_Name VARCHAR(50) = NULL,
    @Employee_ID INT = NULL,
    @Last_Name VARCHAR(50) = NULL
AS
BEGIN
    IF (@Department_Name IS NOT NULL)
    BEGIN
        SELECT e.*
        FROM Employee e
        INNER JOIN Department d ON e.Department_ID = d.Department_ID
        WHERE d.Department_Name = @Department_Name
    END
    ELSE IF (@Employee_ID IS NOT NULL)
    BEGIN
        SELECT e.*
        FROM Employee e
        WHERE e.Employee_ID = @Employee_ID
    END
    ELSE IF (@Last_Name IS NOT NULL)
    BEGIN
        SELECT e.*
        FROM Employee e
        WHERE e.Last_Name LIKE '%' + @Last_Name + '%'
    END
    ELSE
    BEGIN
        SELECT e.*
        FROM Employee e
    END
END
GO

-- Get employee details for rest api
CREATE OR ALTER PROCEDURE spGetEmployeeDetails
    @EmployeeID INT
AS
BEGIN
    SELECT 
        Employee_ID,
        First_Name,
        Last_Name,
        Middle_Initial,
        Street_Address,
        City,
        Postal_Code,
        Work_Phone_Number,
        Cell_Phone_Number,
        Email_Address
    FROM Employee
    WHERE Employee_ID = @EmployeeID;
END;
GO

-- Get Search Employee Details for front end
CREATE OR ALTER PROCEDURE spSearchEmployeeDetails
    @EmployeeID INT = NULL,
    @LastName NVARCHAR(50) = NULL
AS
BEGIN
    SELECT 
        Employee_ID,
        First_Name,
        Last_Name,
        Middle_Initial,
        Street_Address,
        City,
        Postal_Code,
        Work_Phone_Number,
        Cell_Phone_Number,
        Email_Address
    FROM Employee
    WHERE 
        (@EmployeeID IS NULL OR Employee_ID = @EmployeeID)
        AND (@LastName IS NULL OR Last_Name LIKE '%' + @LastName + '%')
    ORDER BY Last_Name, First_Name;
END;
GO

-- Modify Personal Information (Employee)
CREATE OR ALTER PROCEDURE spUpdatePersonalInformation
    @EmployeeID INT,
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @MiddleInitial CHAR(1) = NULL,
    @StreetAddress NVARCHAR(50),
    @City NVARCHAR(50),
    @PostalCode VARCHAR(10),
    @Password VARCHAR(64),
    @Version ROWVERSION
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Start the transaction
        BEGIN TRANSACTION;

        -- Update employee information with concurrency check
        UPDATE Employee
        SET 
            First_Name = @FirstName,
            Last_Name = @LastName,
            Middle_Initial = @MiddleInitial,
            Street_Address = @StreetAddress,
            City = @City,
            Postal_Code = @PostalCode,
            HashedPassword = CASE
        WHEN LEN(@Password) = 64 AND @Password LIKE '[0-9A-Fa-f]%' THEN @Password
        ELSE CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', @Password), 2)
    END
        WHERE Employee_ID = @EmployeeID
        AND Version = @Version;

        -- Check if the update succeeded (Version matched)
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('The record has been modified by another user. Please refresh and try again.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Commit the transaction
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        -- Rollback the transaction if an error occurs
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Raise an error or handle it as required
        THROW;
    END CATCH;
END
GO


-- Get Supervisors
CREATE OR ALTER PROCEDURE spGetSupervisors
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Employee_ID, 
        CONCAT(First_Name, ' ', Last_Name) AS Full_Name
    FROM 
        Employee
    WHERE 
        Supervisor_ID IS NOT NULL; -- Only select employees who are supervisors
END
GO

-- Create or alter the employee review stored procedure
CREATE OR ALTER PROCEDURE spAddEmployeeReview
    @Employee_ID INT,
    @Supervisor_ID INT,
    @Review_Date DATE,
    @Rating_ID INT,
    @Comments TEXT,
    @Quarter_ID INT
AS
BEGIN
    BEGIN TRY
        -- Check if the review date is not in the future
        IF @Review_Date > GETDATE()
        BEGIN
            THROW 50000, 'Review date cannot be in the future.', 1;
        END

        -- Insert the review into the Employee_Review table
        INSERT INTO Employee_Review (Employee_ID, Supervisor_ID, Review_Date, Rating_ID, Comments, Quarter_ID)
        VALUES (@Employee_ID, @Supervisor_ID, @Review_Date, @Rating_ID, @Comments, @Quarter_ID);
    END TRY
    BEGIN CATCH
        -- Handle errors
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO


-- Get the ratings
CREATE OR ALTER PROCEDURE spGetRatings
AS
BEGIN
    SELECT Rating_ID, Rating_Description FROM Rating;
END
GO


-- Get current quarter id
CREATE OR ALTER PROCEDURE spGetCurrentQuarterId
@ReviewDate DATE,
    @QuarterId INT OUTPUT
AS
BEGIN
    SELECT @QuarterId = Quarter_ID
    FROM Quarter
    WHERE @ReviewDate BETWEEN DATEFROMPARTS(YEAR(@ReviewDate), Start_Month, Start_Day) AND DATEFROMPARTS(YEAR(@ReviewDate), End_Month, End_Day);
END
GO

-- Get employees due for review
CREATE OR ALTER PROCEDURE spGetEmployeesDueForReview
AS
BEGIN
    -- Get the current date
    DECLARE @CurrentDate DATE = GETDATE();

    -- Determine the current quarter based on the current date
    DECLARE @CurrentQuarterID INT;

    -- Select the current quarter ID based on the current date
    SELECT @CurrentQuarterID = Quarter_ID
    FROM Quarter
    WHERE 
        (MONTH(@CurrentDate) > Start_Month OR (MONTH(@CurrentDate) = Start_Month AND DAY(@CurrentDate) >= Start_Day)) 
        AND 
        (MONTH(@CurrentDate) < End_Month OR (MONTH(@CurrentDate) = End_Month AND DAY(@CurrentDate) <= End_Day));

    -- Select employees who have not been reviewed in the current quarter
    SELECT 
        e.Employee_ID, 
        e.First_Name, 
        e.Last_Name, 
        ISNULL(MAX(er.Review_Date), '1900-01-01') AS LastReviewDate
    FROM 
        Employee e
    LEFT JOIN 
        Employee_Review er ON e.Employee_ID = er.Employee_ID
    WHERE 
        e.Employee_ID NOT IN (
            SELECT Employee_ID 
            FROM Employee_Review 
            WHERE Quarter_ID = @CurrentQuarterID
        )
    GROUP BY 
        e.Employee_ID, e.First_Name, e.Last_Name
    ORDER BY 
        e.Last_Name, e.First_Name;
END
GO

--CREATE OR ALTER PROCEDURE spGetEmployeesDueForReview
--    @Supervisor_ID INT
--AS
--BEGIN
--    SELECT 
--        e.Employee_ID,
--        e.First_Name,
--        e.Last_Name,
--        ISNULL(
--            (SELECT MAX(Review_Date) FROM Employee_Review er 
--             WHERE er.Employee_ID = e.Employee_ID AND er.Quarter_ID = 
--             (SELECT Quarter_ID FROM Quarter WHERE GETDATE() BETWEEN 
--             DATEFROMPARTS(YEAR(GETDATE()), Start_Month, Start_Day) AND 
--             DATEFROMPARTS(YEAR(GETDATE()), End_Month, End_Day))), 
--            '1900-01-01') AS LastReviewDate
--    FROM Employee e
--    WHERE e.Supervisor_ID = @Supervisor_ID
--      AND NOT EXISTS (
--          SELECT 1 
--          FROM Employee_Review er 
--          WHERE er.Employee_ID = e.Employee_ID 
--          AND er.Quarter_ID = (SELECT Quarter_ID 
--                               FROM Quarter 
--                               WHERE GETDATE() BETWEEN DATEFROMPARTS(YEAR(GETDATE()), Start_Month, Start_Day) AND DATEFROMPARTS(YEAR(GETDATE()), End_Month, End_Day))
--      )
--    ORDER BY e.Last_Name, e.First_Name;
--END
--GO


-- Login
CREATE OR ALTER PROCEDURE spLogin
    @EmployeeId INT,
    @HashedPassword NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        e.Employee_Id,
        e.First_Name,
        e.Last_Name,
        e.Middle_Initial,
        e.Employee_Number,
        e.HashedPassword,
        e.Street_Address,
        e.City,
        e.Postal_Code,
        e.Date_Of_Birth,
        e.SIN,
        e.Seniority_Date,
        e.Job_Start_Date,
        e.Department_Id,
        e.Work_Phone_Number,
        e.Cell_Phone_Number,
        e.Email_Address,
        e.Supervisor_Id,
        e.Supervisor_Indicator,
        e.Role_Id,
        r.Role_Name,
        e.Job_Id
    FROM 
        Employee e
    INNER JOIN 
        Role r ON e.Role_ID = r.Role_ID
    WHERE 
        e.Employee_Id = @EmployeeId
        AND e.HashedPassword = @HashedPassword;
END
GO


CREATE OR ALTER PROCEDURE spCreatePurchaseOrder
    @PurchaseOrderNumber VARCHAR(8),
    @EmployeeID INT,
    @PurchaseOrderStatusID INT,
    @OrderItems AS dbo.OrderItem READONLY
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ErrorMessage NVARCHAR(MAX);
 
    BEGIN TRY
        BEGIN TRANSACTION;
 
        -- Insert into Purchase_Order
        INSERT INTO Purchase_Order (Purchase_Order_Number, Employee_ID, Purchase_Order_Status_ID, Creation_Date)
        VALUES (@PurchaseOrderNumber, @EmployeeID, @PurchaseOrderStatusID, GETDATE());

        --DECLARE @DeliberateError INT;
        --SET @DeliberateError = NULL;
        --INSERT INTO Purchase_Order (Purchase_Order_Number, Employee_ID, Purchase_Order_Status_ID, Creation_Date)
        --VALUES (@DeliberateError, @EmployeeID, @PurchaseOrderStatusID, GETDATE());

        -- Insert into Order_Item
        INSERT INTO Order_Item (Name, Description, Quantity, Price, Justification, Purchase_Location, Denial_Reason, Modify_Reason, Order_Item_Status_ID, Purchase_Order_Number)
        SELECT Name, Description, Quantity, Price, Justification, Purchase_Location, Denial_Reason, Modify_Reason, Status_ID, @PurchaseOrderNumber
        FROM @OrderItems;
 
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ErrorMessage = ERROR_MESSAGE();
        THROW 51000, 'Transaction rolled back due to an error.', 1;
    END CATCH;
END
GO


CREATE OR ALTER PROCEDURE spUpdatePurchaseOrder
    @PurchaseOrderNumber VARCHAR(8),
    @EmployeeID INT,
    @PurchaseOrderStatusID INT,
    @OrderItems AS dbo.OrderItem READONLY
AS
BEGIN
    DECLARE @ErrorMessage NVARCHAR(MAX);

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE Purchase_Order 
        SET Employee_ID = @EmployeeID,
            Purchase_Order_Status_ID = @PurchaseOrderStatusID
        WHERE Purchase_Order_Number = @PurchaseOrderNumber

        DELETE FROM Order_Item WHERE Purchase_Order_Number = @PurchaseOrderNumber;

        INSERT INTO Order_Item (Name, Description, Quantity, Price, Justification, Purchase_Location, Denial_Reason, Modify_Reason, Order_Item_Status_ID, Purchase_Order_Number)
        SELECT Name, Description, Quantity, Price, Justification, Purchase_Location, Denial_Reason, Modify_Reason, Status_ID, @PurchaseOrderNumber
        FROM @OrderItems;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @ErrorMessage = ERROR_MESSAGE();
        THROW;
    END CATCH;
END
GO

CREATE OR ALTER PROCEDURE spAddOrderItem
    @ItemID INT OUTPUT,
    @Name NVARCHAR(45),
    @Description NVARCHAR(255),
    @Quantity INT,
    @Price DECIMAL(18,2),
    @Justification NVARCHAR(50),
    @PurchaseLocation NVARCHAR(255),
    @OrderItemStatusID INT,
    @PurchaseOrderNumber VARCHAR(8)
AS
BEGIN
    INSERT INTO Order_Item (Name, Description, Quantity, Price, Justification, Purchase_Location, Order_Item_Status_ID, Purchase_Order_Number)
    VALUES (@Name, @Description, @Quantity, @Price, @Justification, @PurchaseLocation, @OrderItemStatusID, @PurchaseOrderNumber);

    SET @ItemID = SCOPE_IDENTITY();
END
GO

CREATE OR ALTER PROCEDURE spGetEmployee
    @EmployeeID INT
AS
BEGIN
    SELECT *
    FROM Employee
    WHERE Employee_ID = @EmployeeID;
END;
GO

CREATE OR ALTER PROCEDURE spGetSupervisorFullName
    @SupervisorID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        First_Name,
        Last_Name
    FROM 
        Employee
    WHERE 
        Employee_ID = @SupervisorID;
END
GO


CREATE OR ALTER PROCEDURE spGetDepartment
    @Department_ID INT
AS
BEGIN
    SELECT Department_ID, Department_Name, Description, Invocation_Date
    FROM Department
    WHERE Department_ID = @Department_ID;
END
GO

CREATE OR ALTER PROCEDURE GetTotalPurchaseOrdersCount
AS
BEGIN
    SELECT COUNT(*) FROM Purchase_Order;
END
GO

CREATE OR ALTER PROCEDURE spGetLastPurchaseOrderNumber
AS
BEGIN
    SELECT TOP 1 Purchase_Order_Number
    FROM Purchase_Order
    ORDER BY Purchase_Order_Number DESC;
END;
GO

CREATE OR ALTER PROCEDURE spSearchPurchaseOrders
    @EmployeeID INT = NULL,
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @PurchaseOrderNumber VARCHAR(50) = NULL
AS
BEGIN
    IF (@EmployeeID IS NULL AND @StartDate IS NULL AND @EndDate IS NULL AND @PurchaseOrderNumber IS NULL)
    BEGIN
		SELECT 
			po.Purchase_Order_Number,
			po.Creation_Date,
			po.Employee_ID,
			po.Purchase_Order_Status_ID,
			oi.Item_ID, 
			oi.Name AS Order_Item_Name,
			oi.Quantity AS Order_Item_Quantity,
			oi.Price AS Order_Item_Price
		FROM 
			Purchase_Order po
		LEFT JOIN 
			Order_Item oi ON po.Purchase_Order_Number = oi.Purchase_Order_Number
        ORDER BY 
            po.Creation_Date DESC;
    END
    ELSE
    BEGIN
		SELECT 
			po.Purchase_Order_Number,
			po.Creation_Date,
			po.Employee_ID,
			po.Purchase_Order_Status_ID,
			oi.Item_ID,
			oi.Name AS Order_Item_Name,
			oi.Quantity AS Order_Item_Quantity,
			oi.Price AS Order_Item_Price
		FROM 
			Purchase_Order po
		LEFT JOIN 
			Order_Item oi ON po.Purchase_Order_Number = oi.Purchase_Order_Number
        WHERE 
            (@EmployeeID IS NULL OR po.Employee_ID = @EmployeeID)
            AND (@StartDate IS NULL OR po.Creation_Date >= @StartDate)
            AND (@EndDate IS NULL OR po.Creation_Date <= @EndDate)
            AND (@PurchaseOrderNumber IS NULL OR po.Purchase_Order_Number = @PurchaseOrderNumber)
        ORDER BY 
            po.Creation_Date DESC;
    END
END
GO

CREATE OR ALTER PROCEDURE spSearchPurchaseOrdersSupervisor
    @DepartmentID INT = NULL,
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @PurchaseOrderNumber VARCHAR(50) = NULL,
    @EmployeeName VARCHAR(100) = NULL,
    @PurchaseOrderStatusIds VARCHAR(MAX) = NULL
AS
BEGIN
    IF (@DepartmentID IS NULL AND @StartDate IS NULL AND @EndDate IS NULL AND @PurchaseOrderNumber IS NULL AND @EmployeeName IS NULL AND @PurchaseOrderStatusIds IS NULL)
    BEGIN
		SELECT 
			po.Purchase_Order_Number,
			po.Creation_Date,
			po.Employee_ID,
            CONCAT(e.First_Name, ' ', e.Last_Name) AS Employee_Name,
			po.Purchase_Order_Status_ID,
			oi.Item_ID, 
			oi.Name AS Order_Item_Name,
			oi.Quantity AS Order_Item_Quantity,
			oi.Price AS Order_Item_Price
		FROM 
			Purchase_Order po
		LEFT JOIN 
			Order_Item oi ON po.Purchase_Order_Number = oi.Purchase_Order_Number
        LEFT JOIN 
            Employee e ON po.Employee_ID = e.Employee_ID
        ORDER BY 
            po.Creation_Date DESC;
    END
    ELSE
    BEGIN
		SELECT 
			po.Purchase_Order_Number,
			po.Creation_Date,
			po.Employee_ID,
            CONCAT(e.First_Name, ' ', e.Last_Name) AS Employee_Name,
			po.Purchase_Order_Status_ID,
			oi.Item_ID,  
			oi.Name AS Order_Item_Name,
			oi.Quantity AS Order_Item_Quantity,
			oi.Price AS Order_Item_Price
		FROM 
			Purchase_Order po
		LEFT JOIN 
			Order_Item oi ON po.Purchase_Order_Number = oi.Purchase_Order_Number
        LEFT JOIN 
            Employee e ON po.Employee_ID = e.Employee_ID
        WHERE 
            (@DepartmentID IS NULL OR e.Department_ID = @DepartmentID)
            AND (@StartDate IS NULL OR po.Creation_Date >= @StartDate)
            AND (@EndDate IS NULL OR po.Creation_Date <= @EndDate)
            AND (@PurchaseOrderNumber IS NULL OR po.Purchase_Order_Number = @PurchaseOrderNumber)
            AND (@EmployeeName IS NULL OR CONCAT(e.First_Name, ' ', e.Last_Name) LIKE '%' + @EmployeeName + '%')
            AND (@PurchaseOrderStatusIds IS NULL OR po.Purchase_Order_Status_ID IN (SELECT value FROM STRING_SPLIT(@PurchaseOrderStatusIds, ','))) 
        ORDER BY 
            po.Creation_Date DESC;
    END
END
GO


CREATE OR ALTER PROCEDURE spGetEmployeeDetails
    @EmployeeID INT
AS
BEGIN
    SELECT 
        Employee_ID,
        First_Name,
        Last_Name,
        Middle_Initial,
        Street_Address,
        City,
        Postal_Code,
        Work_Phone_Number,
        Cell_Phone_Number,
        Email_Address
    FROM Employee
    WHERE Employee_ID = @EmployeeID;
END;
GO

CREATE OR ALTER PROCEDURE spGetEmployeesByDepartment
    @DepartmentID INT
AS
BEGIN
    SELECT 
        Employee_ID,
        First_Name,
        Last_Name,
        Middle_Initial,
        Employee_Number,
        HashedPassword,
        Street_Address,
        City,
        Postal_Code,
        Date_Of_Birth,
        SIN,
        Seniority_Date,
        Job_Start_Date,
        Department_ID,
        Supervisor_ID,
        Work_Phone_Number,
        Cell_Phone_Number,
        Email_Address,
        Job_ID,
        Role_ID,
		Retirement_Date,
		Termination_Date
    FROM 
        Employee
    WHERE 
        Department_ID = @DepartmentID;
END
GO


CREATE OR ALTER PROCEDURE spGetPurchaseOrderStatus
    @PurchaseOrderStatusID INT
AS
BEGIN
    SELECT Purchase_Order_Status_ID, Purchase_Order_Status_Name
    FROM Purchase_Order_Status
    WHERE Purchase_Order_Status_ID = @PurchaseOrderStatusID;
END;
GO

CREATE OR ALTER PROCEDURE spGetOrderItemStatus
    @OrderItemStatusID INT
AS
BEGIN
    SELECT Order_Item_Status_ID, Order_Item_Status_Name
    FROM Order_Item_Status
    WHERE Order_Item_Status_ID = @OrderItemStatusID;
END;
GO

CREATE OR ALTER PROCEDURE spSearchPurchaseOrdersInActiveDepartments
    @ActiveDepartmentIds NVARCHAR(MAX),
    @ActiveDepartmentNames NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        DECLARE @DepartmentIdsTable TABLE (DepartmentId INT);
        INSERT INTO @DepartmentIdsTable (DepartmentId)
        SELECT value FROM STRING_SPLIT(@ActiveDepartmentIds, ',');

        DECLARE @DepartmentNamesTable TABLE (DepartmentName NVARCHAR(100));
        INSERT INTO @DepartmentNamesTable (DepartmentName)
        SELECT value FROM STRING_SPLIT(@ActiveDepartmentNames, ',');

        SELECT 
            po.Purchase_Order_Number AS [PO Number],
            po.Creation_Date AS [PO Creation Date],
            ps.Purchase_Order_Status_Name AS [PO Status],
            e.Employee_ID,
            e.Supervisor_ID  -- Return the supervisor's ID
        FROM 
            Purchase_Order po
        INNER JOIN 
            Employee e ON po.Employee_ID = e.Employee_ID
        INNER JOIN 
            Department d ON e.Department_ID = d.Department_ID
        LEFT JOIN 
            Employee supervisor ON e.Supervisor_ID = supervisor.Employee_ID
        LEFT JOIN 
            Purchase_Order_Status ps ON po.Purchase_Order_Status_ID = ps.Purchase_Order_Status_ID
        WHERE 
            (d.Department_ID IN (SELECT DepartmentId FROM @DepartmentIdsTable)
            OR d.Department_Name IN (SELECT DepartmentName FROM @DepartmentNamesTable))
            AND po.Purchase_Order_Status_ID IN (
                SELECT Purchase_Order_Status_ID 
                FROM Purchase_Order_Status 
                WHERE Purchase_Order_Status_Name IN ('Pending', 'Under Review')
            );
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO


CREATE OR ALTER PROCEDURE spGetPurchaseOrderDetails
    @PurchaseOrderNumber NVARCHAR(50)
AS
BEGIN
    SELECT 
        po.Purchase_Order_Number AS [PO Number],
        e.Supervisor_ID AS [Supervisor_ID],  
        ps.Purchase_Order_Status_Name AS [PO Status],
        e.Employee_ID  
    FROM 
        Purchase_Order po
    LEFT JOIN 
        Employee e ON po.Employee_ID = e.Employee_ID
    LEFT JOIN 
        Purchase_Order_Status ps ON po.Purchase_Order_Status_ID = ps.Purchase_Order_Status_ID
    WHERE 
        po.Purchase_Order_Number = @PurchaseOrderNumber;
END
GO

CREATE OR ALTER PROCEDURE spGetSupervisorName
    @SupervisorId INT
AS
BEGIN
    SELECT First_Name + ' ' + Last_Name AS SupervisorName
    FROM Employee
    WHERE Employee_ID = @SupervisorId;
END
GO

CREATE OR ALTER PROCEDURE spGetPurchaseOrderById
    @Purchase_Order_Number VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Purchase_Order_Number,
        Creation_Date,
        Employee_ID,
        Purchase_Order_Status_ID,
		Rowversion
    FROM
        Purchase_Order
    WHERE
        Purchase_Order_Number = @Purchase_Order_Number;
END;
GO

CREATE OR ALTER PROCEDURE spGetOrderItemsByPurchaseOrderId
    @Purchase_Order_Number VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Item_ID,
        Name,
        Description,
        Quantity,
        Price,
        Justification,
        Purchase_Location,
        Order_Item_Status_ID,
        Purchase_Order_Number
    FROM
        Order_Item
    WHERE
        Purchase_Order_Number = @Purchase_Order_Number;
END;
GO	

CREATE OR ALTER PROCEDURE spGetActiveDepartments
AS
BEGIN
    SELECT Department_ID, Department_Name, Description, Invocation_Date, Version
    FROM Department
    WHERE Invocation_Date <= GETDATE(); 
END
GO

CREATE OR ALTER PROCEDURE spGetDepartmentByName
    @DepartmentName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Department_ID, Department_Name, Description, Invocation_Date
    FROM Department
    WHERE Department_Name = @DepartmentName;
END
GO

CREATE OR ALTER PROCEDURE spUpdateOrderItem
    @ItemID INT,
    @Name NVARCHAR(45),
    @Description NVARCHAR(255),
    @Quantity INT,
    @Price DECIMAL(18,2),
    @Justification NVARCHAR(50),
    @PurchaseLocation NVARCHAR(255),
    @OrderItemStatus INT,
    @PurchaseOrderNumber VARCHAR(100),
    @DenialReason NVARCHAR(255) = NULL,
    @ModifyReason NVARCHAR(255) = NULL
AS
BEGIN

    UPDATE Order_Item
    SET Name = @Name,
        Description = @Description,
        Quantity = @Quantity,
        Price = @Price,
        Justification = @Justification,
        Purchase_Location = @PurchaseLocation,
        Order_Item_Status_ID = @OrderItemStatus,
        Purchase_Order_Number = @PurchaseOrderNumber,
        Denial_Reason = @DenialReason,
        Modify_Reason = @ModifyReason
    WHERE Item_ID = @ItemID;

    IF @@ROWCOUNT > 0
        SELECT 'OrderItem updated successfully' AS Result;
    ELSE
        SELECT 'No order item found for the provided ID' AS Result;
END
GO

CREATE OR ALTER PROCEDURE spUpdatePurchaseOrderDetails
    @PurchaseOrderNumber VARCHAR(100),
    @EmployeeID INT,
    @PurchaseOrderStatusID INT
AS
BEGIN

    BEGIN TRY
        UPDATE Purchase_Order
        SET Employee_ID = @EmployeeID,
            Purchase_Order_Status_ID = @PurchaseOrderStatusID
        WHERE Purchase_Order_Number = @PurchaseOrderNumber;

        SELECT 'Purchase order details updated successfully.' AS Result;
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS Result;
    END CATCH;
END























