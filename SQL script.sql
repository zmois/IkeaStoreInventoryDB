-- SQL Script for Code Louisville SQL Class 2020 by EVM  

-- Create IkeaStoreInventory database 
CREATE DATABASE IkeaStoreInventory;
GO

-- Change to the IkeaStoreInventory database 
USE IkeaStoreInventory;
GO

-- If exists, drop tables and indexes 

DROP TABLE IF EXISTS [dbo].StoresProducts;
DROP TABLE IF EXISTS [dbo].Inventory;
DROP TABLE IF EXISTS [dbo].Products;
DROP TABLE IF EXISTS [dbo].Stores;
DROP TABLE IF EXISTS [dbo].Series;

DROP INDEX IF EXISTS Products.IX_Price;
DROP INDEX IF EXISTS Stores.IX_Location;
DROP INDEX IF EXISTS Products.IX_SKUAssembly;
GO

--Create tables 
CREATE TABLE dbo.Series
(  
    SeriesID int NOT NULL,
    SeriesName varchar(25) NOT NULL,
    Category varchar(30) NOT NULL,
    PRIMARY KEY (SeriesID)
);

CREATE TABLE dbo.Stores
(  
    ID int NOT NULL,
    StoreID int NOT NULL,
    City varchar(25) NOT NULL,
    [State] varchar(5) NOT NULL,
    [Address] varchar(40) NOT NULL,
    ZipCode varchar(5) NOT NULL, 
    PRIMARY KEY (StoreID)
);

CREATE TABLE dbo.Products
(  
    ProductID int NOT NULL,
    SKU varchar(10) NOT NULL,
    ProductDescription varchar(40) NOT NULL,
    ProductColor varchar(30) NOT NULL,
    SeriesID int NOT NULL,
    Price DECIMAL(10,2) NULL,
    AssemblyRequired bit NULL,
    PRIMARY KEY (SKU),
    FOREIGN KEY(SeriesID) REFERENCES Series(SeriesID)
);

CREATE TABLE dbo.StoresProducts(
    CodeID varchar(5) NOT NULL,
    StoreID int FOREIGN KEY REFERENCES Stores(StoreID),
    SKU varchar(10) FOREIGN KEY REFERENCES Products(SKU),
    SeriesID int FOREIGN KEY REFERENCES Series(SeriesID),
    PRIMARY KEY (CodeID)
);

CREATE TABLE dbo.Inventory
(  
    CodeID varchar(5) NOT NULL,
    Quantity int NOT NULL,
    Delivery bit NULL,
    FOREIGN KEY(CodeID) REFERENCES StoresProducts(CodeID)
);
GO

-- Bulk upload of the data from csv files to the DB tables

BULK INSERT IkeaStoreInventory.[dbo].Inventory
    FROM '/Inventory.csv'
    WITH
        (   FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n'
        );

BULK INSERT IkeaStoreInventory.[dbo].Series
    FROM '/Series.csv'
    WITH
        (   FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n'
        );

BULK INSERT IkeaStoreInventory.[dbo].Stores
    FROM '/Stores.csv'
    WITH
        (   FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n'
        );

BULK INSERT IkeaStoreInventory.[dbo].Products
    FROM '/Products.csv'
    WITH
        (   FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n'
        );

BULK INSERT IkeaStoreInventory.[dbo].StoresProducts
    FROM '/StoresProducts.csv'
    WITH
        (   FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n'
        );
GO

-- PROJECT REQUIREMENTS

-- Write a SELECT query that uses a WHERE clause 

SELECT SKU, ProductDescription, SeriesID
FROM Products
WHERE [AssemblyRequired] = 1

-- Write a SELECT query that uses an OR and an AND operator

SELECT SKU, ProductDescription, ProductColor
FROM Products 
WHERE Price > 500 OR ProductColor ='%blue%' AND SeriesID = '3'

-- Write a SELECT query that filters NULL rows using IS NOT NULL 

SELECT ProductID, SKU, ProductColor
FROM Products
WHERE Price IS NOT NULL;

-- Write a DML statement that UPDATEs a set of rows with a WHERE clause. 
-- The values used in the WHERE clause should be a variable 

DECLARE @PI1 int = '41', 
        @PI2 int = '43';
        
UPDATE Products
SET ProductColor = 'Beige-brown'
WHERE ProductID IN (@PI1, @PI2)

-- Write a DML statement that DELETEs a set of rows with a WHERE clause. 
-- The values used in the WHERE clause should be a variable 

DECLARE @Code1 varchar(5) = 'c105',
        @Code2 varchar(5) = 'c445'   

DELETE FROM Inventory
WHERE CodeID IN (@Code1, @Code2)

DELETE FROM StoresProducts
WHERE CodeID IN (@Code1, @Code2)  

-- Write a DML statement that DELETEs rows from a table that another table references. 
-- This script will have to also DELETE any records that reference these rows. 
-- Both of the DELETE statements need to be wrapped in a single TRANSACTION. 

BEGIN TRANSACTION

DECLARE @DeleteNull TABLE (SKU varchar(10));
    INSERT INTO @DeleteNull
    SELECT SKU
    FROM Products P
    WHERE Price IS NULL

DELETE FROM Inventory 
WHERE CodeID IN (
    SELECT CodeID FROM StoresProducts
    WHERE SKU IN (
        SELECT SKU FROM @DeleteNull)
)
DELETE FROM StoresProducts 
WHERE SKU IN (SELECT SKU FROM @DeleteNull)

DELETE FROM Products 
WHERE SKU IN (SELECT SKU FROM @DeleteNull)

COMMIT

-- Write a SELECT query that utilizes a JOIN 

SELECT P.SKU, SS.SeriesName, SS.Category, P. Price
FROM Series SS
    JOIN Products P
    ON SS.SeriesID = P.SeriesID

-- Write a SELECT query that utilizes a JOIN with 3 or more tables 

SELECT P.SKU, SS.SeriesName, SS.Category, P.ProductDescription, P.ProductColor, SP.StoreID, P.Price
FROM Series SS
    JOIN Products P 
    ON SS.SeriesID = P.SeriesID
        JOIN StoresProducts SP
        ON P.SKU = SP.SKU

-- Write a SELECT query that utilizes a LEFT JOIN 

SELECT S.StoreID, S.City, S.[State], I.CodeID, I.Quantity
FROM Stores S
    JOIN StoresProducts SP
    ON S.StoreID = SP.StoreID
        LEFT JOIN Inventory I
        ON SP.CodeID = I.CodeID

-- Write a SELECT query that utilizes a variable in the WHERE clause 

DECLARE @city varchar(25) = 'Baltimore';
SELECT StoreID, City, [State]
FROM Stores
    WHERE City = @city

-- Write a SELECT query that utilizes an ORDER BY clause 

SELECT SKU, ProductDescription, Price, AssemblyRequired
FROM Products 
ORDER BY Price

-- Write a SELECT query that utilizes a GROUP BY clause along with an aggregate function 

SELECT SS.Category, SUM(I.Quantity) AS TotalQuantity
FROM Series SS
    JOIN Products P
    ON SS.SeriesID = P.SeriesID
        JOIN StoresProducts SP 
        ON P.SKU = SP.SKU
            JOIN Inventory I
            ON SP.CodeID = I.CodeID
GROUP BY SS.Category

-- Write a SELECT query that utilizes a CALCULATED FIELD 

SELECT CONCAT('$', MAX(Price)- MIN(Price)) AS PriceDifference
FROM Products

SELECT SP.StoreID, CONCAT('$ ', SUM(P.Price * I.Quantity)) AS TotalCostOfProductsInStore
FROM Inventory I
    JOIN StoresProducts SP 
    ON I.CodeID = SP.CodeID
        JOIN Products P
        ON P.SKU = SP.SKU
GROUP BY SP.StoreID    

-- Write a SELECT query that utilizes a SUBQUERY

SELECT AVG(Price) as AvgPrice
FROM Products

SELECT SKU, ProductDescription, Price
FROM Products 
WHERE Price < (
    SELECT AVG(Price) as AvgPrice
    FROM Products     
)
ORDER BY Price DESC

-- Write a SELECT query that utilizes a JOIN, at least 2 OPERATORS (AND, OR, =, IN, BETWEEN, ETC)
-- AND A GROUP BY clause with an aggregate function 

SELECT  S.[State], MAX(I.Quantity) AS MaxQuantity
FROM Stores S
    JOIN StoresProducts SP
    ON S.StoreID = SP.StoreID
        JOIN Inventory I 
        ON I.CodeID = SP.CodeID
WHERE I.CodeID BETWEEN 'c200' AND 'c500'
GROUP BY S.[State]

-- Write a SELECT query that utilizes a JOIN with 3 or more tables, at 2 OPERATORS (AND, OR, =, IN, BETWEEN, ETC),
-- a GROUP BY clause with an aggregate function, and a HAVING clause 

SELECT SS.SeriesName, COUNT(P.SKU) AS TotalInventory_in_US_stores
FROM Products P
    JOIN Series SS
    ON SS.SeriesID = P.SeriesID
        JOIN StoresProducts SP
        ON SS.SeriesID = SP.SeriesID
            JOIN Inventory I
            ON SP.CodeID = I.CodeID
WHERE P.AssemblyRequired = 1 AND Delivery = 1
GROUP BY SS.SeriesName
HAVING COUNT(P.SKU) > 400

-- Design a NONCLUSTERED INDEX with ONE KEY COLUMN that improves the performance of one of the above queries
-- in lines 220-224

CREATE NONCLUSTERED INDEX IX_Price
ON Products (Price);

SELECT SKU, ProductDescription, Price, AssemblyRequired
FROM Products 
ORDER BY Price

-- Design a NONCLUSTERED INDEX with TWO KEY COLUMNS that improves the performance of one of the above queries 
-- in lines 215-218
CREATE NONCLUSTERED INDEX IX_Location
ON Stores (City, [State]);

DECLARE @city1 varchar(25) = 'San Diego';
SELECT StoreID, City, [State]
FROM Stores
    WHERE City = @city1

-- Design a NONCLUSTERED INDEX with AT LEAST ONE KEY COLUMN and AT LEAST ONE INCLUDED COLUMN that
-- improves the performance of one of the above queries in lines 279-289

CREATE NONCLUSTERED INDEX IX_SKUAssembly 
ON Products (SKU, AssemblyRequired)
INCLUDE (SeriesID);

SELECT SS.SeriesName, COUNT(P.SKU) AS TotalInventory_in_US_stores
FROM Products P
    JOIN Series SS
    ON SS.SeriesID = P.SeriesID
        JOIN StoresProducts SP
        ON SS.SeriesID = SP.SeriesID
            JOIN Inventory I
            ON SP.CodeID = I.CodeID
WHERE P.AssemblyRequired = 1 AND Delivery = 1
GROUP BY SS.SeriesName
HAVING COUNT(P.SKU) > 400
