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
-- Create the Role table
IF OBJECT_ID('Roles', 'U') IS NOT NULL
DROP TABLE Roles;

CREATE TABLE Roles (
    RoleId INT IDENTITY(1,1) PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL
);
-- Create the Users table
IF OBJECT_ID('Users', 'U') IS NOT NULL
DROP TABLE Users;

CREATE TABLE Users (
    UserId INT PRIMARY KEY IDENTITY(1,1),
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
    Username NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    HashedPassword NVARCHAR(200) NOT NULL,
    RoleId INT NOT NULL,
	Version ROWVERSION,
    FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)
);



/*

	Database Type: SeedData

*/

-- Insert into Roles table
INSERT INTO Roles (RoleName) VALUES ('Admin'), ('User');

GO



/*

	Database Type: Stored Procedure

*/



-- Get user by username
CREATE OR ALTER PROCEDURE spGetUserByUsername
    @Username NVARCHAR(50)
AS
BEGIN
    SELECT u.UserId, u.FirstName, u.LastName, u.Username, u.Email, u.HashedPassword, u.RoleId, r.RoleName
    FROM Users u
    INNER JOIN Roles r ON u.RoleId = r.RoleId
    WHERE u.Username = @Username;
END;
GO

-- Create User
CREATE OR ALTER PROCEDURE spAddUser
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Username NVARCHAR(50),
    @Email NVARCHAR(100),
    @HashedPassword NVARCHAR(200),
    @RoleId INT
AS
BEGIN
    INSERT INTO Users (FirstName, LastName, Username, Email, HashedPassword, RoleId)
    VALUES (@FirstName, @LastName, @Username, @Email, @HashedPassword, @RoleId);
END;
GO

-- User Login
CREATE OR ALTER PROCEDURE spGetUserByUsernameAndPassword
	@Username NVARCHAR(50),
	@HashedPassword NVARCHAR(200)
AS
BEGIN
	SELECT u.*, r.RoleName
	FROM Users u
	INNER JOIN Roles r on u.RoleId = r.RoleId
	WHERE u.Username = @Username AND u.HashedPassword = @HashedPassword;
END;
GO

-- Get user by id
CREATE OR ALTER PROCEDURE spGetUserById
    @UserId INT
AS
BEGIN
    SELECT u.UserId, u.FirstName, u.LastName, u.Username, u.Email, u.HashedPassword, u.RoleId, r.RoleName
    FROM Users u
    INNER JOIN Roles r ON u.RoleId = r.RoleId
    WHERE u.UserId = @UserId;
END;
GO