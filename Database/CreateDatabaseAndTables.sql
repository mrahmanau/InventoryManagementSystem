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

-- Create the Categories table
IF OBJECT_ID('Categories', 'U') IS NOT NULL
DROP TABLE Categories;

CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY IDENTITY(1,1),
    CategoryName VARCHAR(255) NOT NULL
);

-- Create the Products table
IF OBJECT_ID('Products', 'U') IS NOT NULL
DROP TABLE Products;

CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(255) NOT NULL,
    CategoryID INT,
    Quantity INT DEFAULT 0,
    Price DECIMAL(10, 2),
	Version ROWVERSION,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);


/*

	Database Type: SeedData

*/

-- Insert into Roles table
INSERT INTO Roles (RoleName) VALUES ('Admin'), ('User');

-- Insert into Users table
INSERT INTO Users (FirstName, LastName, Username, Email, HashedPassword, RoleId)
VALUES 
    ('Mahfuzur', 'Rahman', 'mahfuz', 'mrahmanlinks@gmail.com', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), 1),
    ('Shah', 'Alom', 'salom', 'shahalom.talha@yahoo.com', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), 1),
    ('Shawon', 'Alom', 'shawon', 'shawon.alom@outlook.com', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), 2),
    ('Emily', 'Davis', 'emilyd', 'emily.davis@example.com', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), 2),
    ('David', 'Brown', 'davidb', 'david.brown@example.com', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '123@Abc'), 2), 2);

-- Insert into Categories table
INSERT INTO Categories (CategoryName)
VALUES 
    ('Electronics'),
    ('Furniture'),
    ('Clothing'),
    ('Books'),
    ('Sports');

-- Insert into Products table
INSERT INTO Products (ProductName, CategoryID, Quantity, Price)
VALUES 
    ('Laptop', 1, 10, 999.99),
    ('Smartphone', 1, 25, 699.99),
    ('Headphones', 1, 50, 199.99),
    ('Sofa', 2, 5, 499.99),
    ('Dining Table', 2, 10, 299.99),
    ('T-shirt', 3, 100, 19.99),
    ('Jeans', 3, 75, 39.99),
    ('Jacket', 3, 30, 89.99),
    ('Novel', 4, 200, 9.99),
    ('Textbook', 4, 150, 49.99),
    ('Basketball', 5, 20, 29.99),
    ('Soccer Ball', 5, 30, 24.99),
    ('Tennis Racket', 5, 15, 79.99),
    ('Smartwatch', 1, 40, 199.99),
    ('Office Chair', 2, 20, 149.99);

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

-- Add a product
CREATE OR ALTER PROCEDURE spAddProduct
	@ProductName NVARCHAR(255),
	@Quantity INT,
	@Price DECIMAL (10, 2),
	@CategoryId INT

AS
BEGIN
	INSERT INTO Products (ProductName, Quantity, Price, CategoryID)
	VALUES(@ProductName, @Quantity, @Price, @CategoryId)
END;
GO

-- Update product
CREATE OR ALTER PROCEDURE spUpdateProduct
    @ProductId INT,
    @ProductName NVARCHAR(255),
    @Quantity INT,
    @Price DECIMAL,
    @CategoryId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Update the product
    UPDATE Products
    SET ProductName = @ProductName,
        Quantity = @Quantity,
        Price = @Price,
        CategoryId = @CategoryId
    WHERE ProductId = @ProductId;
END;
GO

-- Delete product
CREATE OR ALTER PROCEDURE spDeleteProduct
	@ProductId INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM Products
	WHERE ProductID = @ProductId;
END;
GO

-- Search products
CREATE OR ALTER PROCEDURE spSearchProducts
	@ProductName NVARCHAR(255) = NULL,
	@CategoryId INT = NULL,
	@MinPrice DECIMAL = NULL,
	@MaxPrice DECIMAL = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT *
    FROM Products
    WHERE (@ProductName IS NULL OR ProductName LIKE '%' + @ProductName + '%')
      AND (@CategoryId IS NULL OR CategoryID = @CategoryId)
      AND (@MinPrice IS NULL OR Price >= @MinPrice)
      AND (@MaxPrice IS NULL OR Price <= @MaxPrice);
END;
GO


-- Get product by name
CREATE OR ALTER PROCEDURE spGetProductByName
    @ProductName NVARCHAR(255)
AS
BEGIN
    SELECT ProductId, ProductName, Quantity, Price, CategoryId, Version
    FROM Products
    WHERE ProductName = @ProductName;
END;
GO

-- Get all products
CREATE OR ALTER PROCEDURE spGetAllProducts
AS
BEGIN
	SELECT ProductID, ProductName, Quantity, Price, CategoryID, Version 
	FROM Products;
END;
GO

-- Get categories
CREATE OR ALTER PROCEDURE spGetCategories
AS
	BEGIN
		SELECT CategoryID, CategoryName
		FROM Categories
		ORDER BY CategoryName ASC;
	END;
GO
