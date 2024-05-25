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





