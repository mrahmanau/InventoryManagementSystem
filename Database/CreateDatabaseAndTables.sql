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
	ProfileImagePath NVARCHAR(200),
	EmailConfirmed BIT DEFAULT 0,
    EmailConfirmationToken NVARCHAR(200) NULL, 
	TwoFactorCode NVARCHAR(6) NULL,
    TwoFactorCodeExpiration DATETIME NULL,
	PasswordResetToken NVARCHAR(200) NULL,
	PasswordResetTokenExpiration DATETIME NULL,
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

-- Create the UserActivityLog table
IF OBJECT_ID('UserActivityLog', 'U') IS NOT NULL
DROP TABLE UserActivityLog

CREATE TABLE UserActivityLog (
    Id INT PRIMARY KEY IDENTITY,
    UserId INT NOT NULL,
    Action NVARCHAR(255) NOT NULL,
    Timestamp DATETIME NOT NULL,
    Details NVARCHAR(255),
    FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE
);

-- Create the Payments table
IF OBJECT_ID('Payments', 'U') IS NOT NULL
DROP TABLE Payments

CREATE TABLE Payments (
    PaymentId INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL,
    PaymentIntentId NVARCHAR(50) NOT NULL,
    Amount BIGINT NOT NULL,
    Currency NVARCHAR(10) NOT NULL,
    Status NVARCHAR(20) NOT NULL,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    FOREIGN KEY (UserId) REFERENCES Users(UserId)
);


-- Create the Contacts table
IF OBJECT_ID('Contacts', 'U') IS NOT NULL
DROP TABLE Contacts

CREATE TABLE Contacts (
    ContactId INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    Subject NVARCHAR(200) NOT NULL,
    Message NVARCHAR(MAX) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);


/*

	Database Type: SeedData

*/

-- Insert into Roles table
INSERT INTO Roles (RoleName) VALUES ('Admin'), ('User');

-- Insert into Users table
INSERT INTO Users (FirstName, LastName, Username, Email, HashedPassword, RoleId)
VALUES 
    ('Mahfuzur', 'Rahman', 'mahfuz', 'mrahmanlinks@gmail.com', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '1234@Abcd'), 2), 1),
    ('Shah', 'Alom', 'salom', 'shahalom.talha@yahoo.com', LOWER(CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '1234@Abcd'), 2)), 1),
    ('Shawon', 'Alom', 'shawon', 'shawon.alom@outlook.com', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '1234@Abcd'), 2), 2),
    ('Emily', 'Davis', 'emilyd', 'emily.davis@example.com', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '1234@Abcd'), 2), 2),
    ('David', 'Brown', 'davidb', 'david.brown@example.com', CONVERT(VARCHAR(64), HASHBYTES('SHA2_256', '1234@Abcd'), 2), 2);

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
    @RoleId INT,
	@EmailConfirmed BIT,
	@EmailConfirmationToken NVARCHAR(200),
	@ProfileImagePath NVARCHAR(200)
AS
BEGIN
    INSERT INTO Users (FirstName, LastName, Username, Email, HashedPassword, RoleId, EmailConfirmed, EmailConfirmationToken, ProfileImagePath)
    VALUES (@FirstName, @LastName, @Username, @Email, @HashedPassword, @RoleId, @EmailConfirmed, @EmailConfirmationToken, @ProfileImagePath);

	SELECT SCOPE_IDENTITY() AS UserId;
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

-- Get users
CREATE OR ALTER PROCEDURE spGetUsers
AS
BEGIN
	SELECT UserId, FirstName, LastName
	FROM Users
	ORDER BY LastName ASC
END;
GO

-- Get user by Id
CREATE OR ALTER PROCEDURE spGetUserById
    @UserId INT
AS
BEGIN
    SELECT u.UserId, u.FirstName, u.LastName, u.Username, u.Email, u.HashedPassword, u.RoleId, u.TwoFactorCode, u.TwoFactorCodeExpiration, u.ProfileImagePath, r.RoleName,
	(SELECT COUNT(*) FROM UserActivityLog WHERE UserId = @UserId) AS TotalLogs,
	(SELECT MAX(Timestamp) FROM UserActivityLog WHERE UserId = @UserId) AS LastActivity,
	(SELECT TOP 1 Action FROM UserActivityLog WHERE UserId = @UserId ORDER BY Timestamp DESC) AS LastAction
    FROM Users u
    INNER JOIN Roles r ON u.RoleId = r.RoleId
    WHERE u.UserId = @UserId;
END;
GO

-- Update user
CREATE OR ALTER PROCEDURE spUpdateUser
	@UserId INT,
    @FirstName NVARCHAR(255),
    @LastName NVARCHAR(255),
    @Username NVARCHAR(255),
    @Email NVARCHAR(255),
    @RoleId INT
AS
BEGIN
	    -- Check if the username already exists for another user
	IF EXISTS(SELECT 1 FROM Users WHERE Username = @Username AND UserId != @UserId)
	BEGIN
        RAISERROR('Duplicate username.', 16, 1);
        RETURN;
    END

	    -- Update the user details
		UPDATE Users
		SET
			FirstName = @FirstName,
			LastName = @LastName,
			Username = @Username,
			Email = @Email,
			RoleId = @RoleId
		WHERE UserId = @UserId;
END;
GO

-- Update profile
CREATE OR ALTER PROCEDURE spUpdateUserProfile
    @UserId INT,
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @Username NVARCHAR(50)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE Username = @Username AND UserId != @UserId)
    BEGIN
        RAISERROR('Username already exists.', 16, 1);
        RETURN;
    END

    UPDATE Users
    SET FirstName = @FirstName,
        LastName = @LastName,
        Email = @Email,
        Username = @Username
    WHERE UserId = @UserId;
END;
GO

-- Get user's hashed password
CREATE OR ALTER PROCEDURE spGetHashedPassword
    @UserId INT
AS
BEGIN
    SELECT HashedPassword
    FROM Users
    WHERE UserId = @UserId;
END;
GO


-- Update password
CREATE OR ALTER PROCEDURE spUpdatePassword
    @UserId INT,
    @NewPassword NVARCHAR(200)
AS
BEGIN
    UPDATE Users
    SET HashedPassword = @NewPassword
    WHERE UserId = @UserId;
END;
GO

-- Reset password
CREATE OR ALTER PROCEDURE spResetPassword
    @UserId INT,
    @NewPassword NVARCHAR(200)
AS
BEGIN
    UPDATE Users
    SET HashedPassword = @NewPassword, PasswordResetToken = NULL, PasswordResetTokenExpiration = NULL
    WHERE UserId = @UserId;
END;
GO

-- Get user by reset token
CREATE OR ALTER PROCEDURE spGetUserByResetToken
    @PasswordResetToken NVARCHAR(200)
AS
BEGIN
    SELECT 
        UserId,
        FirstName,
        LastName,
        Username,
        Email,
        RoleId,
        EmailConfirmed
    FROM Users
    WHERE PasswordResetToken = @PasswordResetToken AND PasswordResetTokenExpiration > GETUTCDATE();
END;
GO






-- Delete user
CREATE OR ALTER PROCEDURE spDeleteUser
	@UserId INT
AS
BEGIN
	DELETE FROM Users
	WHERE UserId = @UserId;
END;
GO

-- Add user activity log
CREATE OR ALTER PROCEDURE spAddUserActivityLog
	@UserId INT,
	@Action NVARCHAR(255),
	@Timestamp DATETIME,
	@Details NVARCHAR (255)
AS
BEGIN
	INSERT INTO UserActivityLog (UserId, Action, Timestamp, Details)
	VALUES(@UserId, @Action, @Timestamp, @Details)
END
GO

-- Get user by token
CREATE OR ALTER PROCEDURE spGetUserByToken
    @Token NVARCHAR(200)
AS
BEGIN
    SELECT 
        Users.UserId,
        Users.FirstName,
        Users.LastName,
        Users.Username,
        Users.Email,
        Users.HashedPassword,
        Users.RoleId,
        Users.EmailConfirmed,
        Users.EmailConfirmationToken,
		Roles.RoleName
    FROM Users
	JOIN Roles ON Users.RoleId = Roles.RoleId
    WHERE Users.EmailConfirmationToken = @Token;
END;
GO

-- Update Email Confirmation Status
CREATE OR ALTER PROCEDURE spUpdateEmailConfirmationStatus
    @UserId INT,
    @EmailConfirmed BIT,
    @EmailConfirmationToken NVARCHAR(200)
AS
BEGIN
    UPDATE Users
    SET EmailConfirmed = @EmailConfirmed,
        EmailConfirmationToken = @EmailConfirmationToken
    WHERE UserId = @UserId;
END;
GO

CREATE OR ALTER PROCEDURE spUpdateTwoFactorCode
    @UserId INT,
    @TwoFactorCode NVARCHAR(6) = NULL,
    @TwoFactorCodeExpiration DATETIME = NULL
AS
BEGIN
    UPDATE Users
    SET TwoFactorCode = @TwoFactorCode,
        TwoFactorCodeExpiration = @TwoFactorCodeExpiration
    WHERE UserId = @UserId;
END;
GO

-- Get user by email
CREATE OR ALTER PROCEDURE spGetUserByEmail
    @Email NVARCHAR(100)
AS
BEGIN
    SELECT 
        UserId,
        FirstName,
        LastName,
        Username,
        Email,
        RoleId,
        EmailConfirmed
    FROM Users
    WHERE Email = @Email;
END;
GO

-- Update password reset token
CREATE OR ALTER PROCEDURE spUpdatePasswordResetToken
    @UserId INT,
    @ResetToken NVARCHAR(200),
    @Expiration DATETIME
AS
BEGIN
    UPDATE Users
    SET 
        PasswordResetToken = @ResetToken,
        PasswordResetTokenExpiration = @Expiration
    WHERE UserId = @UserId;
END;
GO



-- Add payment details
CREATE OR ALTER PROCEDURE spAddPayment
    @UserId INT,
    @PaymentIntentId NVARCHAR(50),
    @Amount BIGINT,
    @Currency NVARCHAR(10),
    @Status NVARCHAR(20),
    @CreatedAt DATETIME
AS
BEGIN
    INSERT INTO Payments (UserId, PaymentIntentId, Amount, Currency, Status, CreatedAt)
    VALUES (@UserId, @PaymentIntentId, @Amount, @Currency, @Status, @CreatedAt);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS PaymentId;
END;
GO

-- Get paymentintentid 
CREATE OR ALTER PROCEDURE spGetPaymentByIntentId
    @PaymentIntentId NVARCHAR(50)
AS
BEGIN
    SELECT *
    FROM Payments
    WHERE PaymentIntentId = @PaymentIntentId;
END;
GO


-- Update payment status
CREATE OR ALTER PROCEDURE spUpdatePayment
    @PaymentIntentId NVARCHAR(50),
    @Status NVARCHAR(20)
AS
BEGIN
    UPDATE Payments
    SET Status = @Status
    WHERE PaymentIntentId = @PaymentIntentId;
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

-- Add contact messages
CREATE OR ALTER PROCEDURE spAddContact
    @Name NVARCHAR(100),
    @Email NVARCHAR(100),
    @Subject NVARCHAR(200),
    @Message NVARCHAR(MAX)
AS
BEGIN
    INSERT INTO Contacts (Name, Email, Subject, Message, CreatedAt)
    VALUES (@Name, @Email, @Subject, @Message, GETDATE());

    SELECT SCOPE_IDENTITY() AS ContactId;
END;
GO

