USE master;

/*
We'll be creating two different tables intended for use in PowerBI:

Product will be used to examine product specifications at a high granularity level
Time will consolidate stock items into categories, and be used for a YoY/Quarterly comparison
First, we'll begin by querying data for tables
*/

/*
Query to create our Product table
We'd like to see a breakdown of sales success per category > subcategory > product > size/color
*/

SELECT
	YEAR(o.OrderDate) AS [Year],
	si.StockItemName,
	si.Size,
	c.ColorName AS Color,
	SUM(il.Quantity) AS Quantity,
	il.UnitPrice,
	sih.LastCostPrice,
	il.UnitPrice - sih.LastCostPrice AS UnitMargin,
	(il.UnitPrice - sih.LastCostPrice) / il.UnitPrice AS PctMargin,
	SUM(il.Quantity * il.UnitPrice) AS TotalUnitPrice,
	SUM(il.LineProfit) AS LineProfit
INTO Product
FROM
	WideWorldImporters.Sales.InvoiceLines il
	JOIN WideWorldImporters.Warehouse.StockItems si
	ON il.StockItemID = si.StockItemID
	JOIN WideWorldImporters.Sales.Invoices i
	ON i.InvoiceID = il.InvoiceID
	JOIN WideWorldImporters.Sales.Orders o
	ON o.OrderID = i.OrderID
	LEFT JOIN WideWorldImporters.Warehouse.Colors c
	ON c.ColorID = si.ColorID
	JOIN WideWorldImporters.Warehouse.StockItemHoldings sih
	ON sih.StockItemID = il.StockItemID
GROUP BY
	YEAR(o.OrderDate),
	si.StockItemName,
	si.Size,
	c.ColorName,
	il.UnitPrice,
	sih.LastCostPrice;

/*
Query to create our Time table
We're interested in comparing transformations of revenue and profit over time
*/

SELECT
	YEAR(o.OrderDate) AS [Year],
	MONTH(o.OrderDate) AS [Month],
	si.StockItemName,
	SUM(il.Quantity) AS Quantity,
	SUM(il.Quantity * il.UnitPrice) AS TotalUnitPrice,
	SUM(il.Quantity * il.UnitPrice) - SUM(il.LineProfit) AS Revenue,
	SUM(il.LineProfit) AS LineProfit
INTO [Time]
FROM
	WideWorldImporters.Sales.InvoiceLines il
	JOIN WideWorldImporters.Warehouse.StockItems si
	ON il.StockItemID = si.StockItemID
	JOIN WideWorldImporters.Sales.Invoices i
	ON i.InvoiceID = il.InvoiceID
	JOIN WideWorldImporters.Sales.Orders o
	ON o.OrderID = i.OrderID
GROUP BY
	YEAR(o.OrderDate),
	MONTH(o.OrderDate),
	si.StockItemName;

/*
Check NULL count
NULL in Size and Color are acceptable, not every item has a specific attribute of these types
*/

-- Product

SELECT
	SUM(CASE WHEN [Year] IS NULL THEN 1 ELSE 0 END) AS NullCount_Year,
	SUM(CASE WHEN StockItemName IS NULL THEN 1 ELSE 0 END) AS NullCount_StockItemName,
	SUM(CASE WHEN Size IS NULL THEN 1 ELSE 0 END) AS NullCount_Size,
	SUM(CASE WHEN Color IS NULL THEN 1 ELSE 0 END) AS NullCount_Color,
	SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS NullCount_Quantity,
	SUM(CASE WHEN UnitPrice IS NULL THEN 1 ELSE 0 END) AS NullCount_UnitPrice,
	SUM(CASE WHEN LastCostPrice IS NULL THEN 1 ELSE 0 END) AS NullCount_LastCostPrice,
	SUM(CASE WHEN UnitMargin IS NULL THEN 1 ELSE 0 END) AS NullCount_UnitMargin,
	SUM(CASE WHEN PctMargin IS NULL THEN 1 ELSE 0 END) AS NullCount_PctMargin,
	SUM(CASE WHEN TotalUnitPrice IS NULL THEN 1 ELSE 0 END) AS NullCount_TotalUnitPrice,
	SUM(CASE WHEN LineProfit IS NULL THEN 1 ELSE 0 END) AS NullCount_LineProfit
FROM Product;

-- Time

SELECT
	SUM(CASE WHEN [Year] IS NULL THEN 1 ELSE 0 END) AS NullCount_Year,
	SUM(CASE WHEN [Month] IS NULL THEN 1 ELSE 0 END) AS NullCount_Month,
	SUM(CASE WHEN StockItemName IS NULL THEN 1 ELSE 0 END) AS NullCount_StockItemName,
	SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS NullCount_Quantity,
	SUM(CASE WHEN TotalUnitPrice IS NULL THEN 1 ELSE 0 END) AS NullCount_TotalUnitPrice,
	SUM(CASE WHEN Revenue IS NULL THEN 1 ELSE 0 END) AS NullCount_Revenue,
	SUM(CASE WHEN LineProfit IS NULL THEN 1 ELSE 0 END) AS NullCount_LineProfit
FROM [Time];

/*
If we join our two tables in PowerBI as they are now, we'll accumulate duplicate measurements
Rather than dealing with them in PowerBI, we'll address them here by categorizing our stock items
Plus, we don't actually need Time table at the granularity level of stock items
Our first step in converting our item names to categories is standardizing strings as lowercase
*/

-- Product

-- Sort StockItemName into categories

ALTER TABLE [Product]
ADD Category NVARCHAR(100);

UPDATE [Product]
SET Category = CASE
	WHEN StockItemName LIKE '%packaging%'
	OR StockItemName LIKE '%bubble%'
	OR StockItemName LIKE '%tape%'
	OR StockItemName LIKE '%box%'
	OR StockItemName LIKE '%bag%'
	OR StockItemName LIKE '%shipping%'
	OR StockItemName LIKE '%marker%'
	OR StockItemName LIKE '%cushion%'
	OR StockItemName LIKE '%blade%'
	OR StockItemName LIKE '%knife%'
	THEN 'Packaging'
	WHEN StockItemName LIKE '%shirt%'
	OR StockItemName LIKE '%furry%'
	OR StockItemName LIKE '%slippers%'
	OR StockItemName LIKE '%mask%'
	OR StockItemName LIKE '%hoodie%'
	THEN 'Clothing'
	WHEN StockItemName LIKE '%usb%' THEN 'USB Devices'
	WHEN StockItemName LIKE '%superhero%'
	OR StockItemName LIKE '%ride%'
	OR StockItemName LIKE '%remote%'
	OR StockItemName LIKE '%action%'
	OR StockItemName LIKE '%cube%'
	THEN 'Toys'
	WHEN StockItemName LIKE '%chocolate%' THEN 'Candy'
	WHEN StockItemName LIKE '%mug%' THEN 'Mugs'
END;

-- Time

UPDATE [Time]
SET StockItemName = LOWER(StockItemName);

-- Sort StockItemName into categories

ALTER TABLE [Time]
ADD Category NVARCHAR(100);

UPDATE [Time]
SET Category = CASE
	WHEN StockItemName LIKE '%packaging%'
	OR StockItemName LIKE '%bubble%'
	OR StockItemName LIKE '%tape%'
	OR StockItemName LIKE '%box%'
	OR StockItemName LIKE '%bag%'
	OR StockItemName LIKE '%shipping%'
	OR StockItemName LIKE '%marker%'
	OR StockItemName LIKE '%cushion%'
	OR StockItemName LIKE '%blade%'
	OR StockItemName LIKE '%knife%'
	THEN 'Packaging'
	WHEN StockItemName LIKE '%shirt%'
	OR StockItemName LIKE '%furry%'
	OR StockItemName LIKE '%slippers%'
	OR StockItemName LIKE '%mask%'
	OR StockItemName LIKE '%hoodie%'
	THEN 'Clothing'
	WHEN StockItemName LIKE '%usb%' THEN 'USB Devices'
	WHEN StockItemName LIKE '%superhero%'
	OR StockItemName LIKE '%ride%'
	OR StockItemName LIKE '%remote%'
	OR StockItemName LIKE '%action%'
	OR StockItemName LIKE '%cube%'
	THEN 'Toys'
	WHEN StockItemName LIKE '%chocolate%' THEN 'Candy'
	WHEN StockItemName LIKE '%mug%' THEN 'Mugs'
END;

-- Drop StockItemName column

ALTER TABLE [Time]
DROP COLUMN StockItemName;

-- Find LineProfit for each category and reorder the columns

SELECT [Year], [Month], Category,
	SUM(Quantity) AS Quantity, 
	SUM(TotalUnitPrice) AS TotalUnitPrice,
	SUM(LineProfit) AS LineProfit
INTO temp
FROM [Time]
GROUP BY [Year], [Month], Category;

DROP TABLE [Time];

EXEC sp_rename 'temp', 'Time';

/*
Next, we'll remove end-of-string Size and Color details from StockItemName values in Product table
It's preferred to have these details isolated in their respective columns and avoid redundancy
*/

-- Remove Color in (Color) format from StockItemName

UPDATE Product
SET StockItemName = TRIM(SUBSTRING(StockItemName, 1, LEN(StockItemName) - CHARINDEX('(', REVERSE(StockItemName)))) + ' ' +
TRIM(SUBSTRING(StockItemName, LEN(StockItemName) - CHARINDEX(')', REVERSE(StockItemName)) + 2, LEN(StockItemName)))
WHERE StockItemName LIKE '%(%';

-- Remove most Size measurements from StockItemName

UPDATE Product
SET StockItemName = TRIM(REPLACE(' ' + StockItemName + ' ', ' ' + Size + ' ', ''))
WHERE CHARINDEX(' ' + Size + ' ', ' ' + StockItemName + ' ') > 0;

-- Check the tables again and export them to .csv files

SELECT *
FROM Product
ORDER BY [Year], StockItemName, Quantity DESC, LineProfit DESC;

SELECT *
FROM [Time]
ORDER BY [Year], [Month], Category;

-- Drop tables

DROP TABLE Product, [Time];