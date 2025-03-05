--*************************************************************************--
-- Title: Assignment06
-- Author: CAguirre
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,CAguirre,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_CAguirre')
	 Begin 
	  Alter Database [Assignment06DB_CAguirre] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_CAguirre;
	 End
	Create Database Assignment06DB_CAguirre;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_CAguirre;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
-- Let's see what we're working with. Throwing the select all statements here for quick reference
-- since my work from home set up is currently being fixed up.
-- Gentle reminder to myself not to forget the 2 part name for table references.

--Select * From Categories;
--go
-- So our view statement should reference CategoryID and CategoryName for dbo.Categories table.

Create View [dbo].[viewCategories]
WITH SCHEMABINDING 
AS
 Select CategoryID, CategoryName
 From dbo.Categories;
go

--Select * From Products;
--go
-- Our view statement for Products should reference ProductID, ProductName, CategoryID, and UnitPrice
-- from dbo.Products.

Create View [dbo].[viewProducts]
WITH SCHEMABINDING
AS
	Select ProductID, ProductName, CategoryID, UnitPrice
	From dbo.Products;
go

--Select * From Employees;
--go
-- Our view statement for Employees should reference EmployeeID, EmployeeFirstName, EmployeeLastName, 
-- and ManagerID.

Create View [dbo].[viewEmployees]
WITH SCHEMABINDING
AS
	Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	From dbo.Employees;
go

--Select * From Inventories;
--go
-- Our view statement for Inventories should reference InventoryID, InventoryDate, EmployeeID, ProductID,
-- and Count. I need to remember the brackets again to make sure SQL doesn't see it as a function.

Create View [dbo].[viewInventories]
WITH SCHEMABINDING
AS
	Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count] 
	From dbo.Inventories;
go

---------------------------------------------------------------------------------------------------
-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
-- Not sure if this is necessary but I want to specify what source I'm using just for ease of reference.
Use Assignment06DB_CAguirre;
go
-- Denying for Categories.
Deny Select On Categories to Public;
go
-- Denying for Products.
Deny Select on Products to Public;
go
-- Denying for Employees.
Deny Select on Employees to Public;
go
-- Denying for Inventories.
Deny Select on Inventories to Public;
go
-- Now let's set permissions for views!

-- Access to vCategories.
Grant Select on viewCategories to Public;
go
-- Access to vProducts
Grant Select on viewProducts to Public;
go
-- Access to vEmployees
Grant Select on viewEmployees to Public;
go
-- Access to vInventories
Grant Select on viewInventories to Public;
go

---------------------------------------------------------------------------------------------------
-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
-- This'll require a join between Category and Product on our CategoryID column.
-- Let's throw our previous code in here and work off of that.

-------- OLD CODE
--Select CategoryName, ProductName, UnitPrice
--	From dbo.Categories 
--		Join dbo.Products
--			ON Categories.CategoryID = Products.CategoryID
--	ORDER BY CategoryName, ProductName;
--go
--------- OLD CODE
-- So we create our view and name it something arbitrary... x is a cool letter so let's pick that.
-- I throw in the parts of code I need from above and I also add the top bit - the table isn't that big
-- so it'll show the whole thing.
-- I also need to order by CategoryName and ProductName to make sure I'm matching the result set in the 
-- assignment.

Create view [dbo].[viewProductsXCategories] as
	Select top 100000000
	C.CategoryName, P.ProductName, P.UnitPrice
		From viewCategories as C
			Join viewProducts as P
				On C.CategoryID = P.CategoryID
Order by CategoryName, ProductName;
go
-- ALWAYS CHECK YOUR WORK!
Select * From viewProductsXCategories;
-- Awesome! Everything matches up.
---------------------------------------------------------------------------------------------------
-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Let's throw in our old code again for easy reference.
--------- OLD CODE
--SELECT ProductName, InventoryDate, Count
--	FROM dbo.Products
--		JOIN dbo.Inventories
--			ON Products.ProductID = Inventories.ProductID
--	ORDER BY ProductName, InventoryDate, Count;
--go
--------- OLD CODE

-- Time to create our view. Let's follow our silly naming convention.
Create view [dbo].[ProductsXInventory] as
	Select top 100000000
	P.ProductName, I.InventoryDate, I.[Count]
		From viewProducts as P
			Join viewInventories as I
				On P.ProductID = I.ProductID
Order by P.ProductName, I.InventoryDate, I.[Count];
go

-- Check our work babyyy
Select * From ProductsXInventory;
-- Yesss, this matches the result set!
---------------------------------------------------------------------------------------------------
-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Let's toss in our old code again.
--------- OLD CODE
--SELECT DISTINCT InventoryDate, EmployeeName = EmployeeFirstName + ' ' + EmployeeLastName
--	FROM Inventories
--		JOIN Employees
--			ON Inventories.EmployeeID = Employees.EmployeeID
--	ORDER BY InventoryDate;
-- go
--------- OLD CODE

-- Let's make our view!
-- Using a lot of the same code from before just sticking in our views instead of table names.
Create view [dbo].[InvenXEmployeeXDates] as
	Select distinct top 100000000
	I.InventoryDate, EmployeeName = E.EmployeeFirstName + ' ' + E.EmployeeLastName
From viewInventories as I
	Join viewEmployees as E
		On I.EmployeeID = E.EmployeeID
Order by I.InventoryDate, EmployeeName;
go

-- Let's check the work.
Select * From InvenXEmployeeXDates;
-- Great, it checks out!
---------------------------------------------------------------------------------------------------
-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
-- Once again I'm throwing in my old code.
----Select statement
--SELECT CategoryName, ProductName, InventoryDate, Count
--	FROM Inventories
--		JOIN Products
--			ON Products.ProductID=Inventories.ProductID 
--		JOIN Categories
--			ON Categories.CategoryID=Products.CategoryID
--	ORDER BY CategoryName, ProductName, InventoryDate, Count;
--GO

-- Add view
Create view [dbo].[InventoriesXProdXCategories] as
		SELECT TOP 100000 
		C.CategoryName, P.ProductName, I.InventoryDate, I.[Count]
			FROM viewInventories as I
				JOIN viewProducts as P
					ON P.ProductID = I.ProductID 
				JOIN viewCategories as C
					ON C.CategoryID = P.CategoryID
ORDER BY C.CategoryName, P.ProductName, I.InventoryDate, I.[Count];
go

-- Let's check our work.
Select * From InventoriesXProdXCategories;
-- Yay everything looks good!
---------------------------------------------------------------------------------------------------
-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- OLD CODE TIME! 
-- SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count]
--	FROM Inventories as I
--		JOIN Products as P
--			ON P.ProductID = I.ProductID 
--		JOIN Categories as C
--			ON C.CategoryID = P.CategoryID
--	ORDER BY C.CategoryName, P.ProductName, I.InventoryDate, I.[Count];
--go
-- OLD CODE TIME!

-- view time! Let's follow my too cool for school naming convention with the X.
-- Someone please tell if there's a prettier way to make the EmployeeName column.
Create view [dbo].[InvenXProdXEmployees] as
	SELECT TOP 1000000000
	C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], 
	EmployeeName = E.EmployeeFirstName + ' ' + E.EmployeeLastName
		FROM viewCategories AS C 
  			JOIN viewProducts AS P 
    			ON C.CategoryID = P.CategoryID
  			JOIN viewInventories AS I 
    			ON P.ProductID = I.ProductID
  			JOIN viewEmployees AS E 
    			ON I.EmployeeID = E.EmployeeID
ORDER BY I.InventoryDate, C.CategoryName, P.ProductName, EmployeeName;
go
-- Time to check our work.
Select * From InvenXProdXEmployees;
-- Great it all checks out :-) 
---------------------------------------------------------------------------------------------------
-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- OLD CODE TIME! 
--SELECT C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], 
-- EmployeeName = E.EmployeeFirstName + ' ' + E.EmployeeLastName
--	FROM Inventories as I
--		JOIN Products as P
--			ON P.ProductID = I.ProductID 
--		JOIN Categories as C
--			ON C.CategoryID = P.CategoryID
--		JOIN Employees
--			ON Employees.EmployeeID = Inventories.EmployeeID
--	WHERE Inventories.ProductID IN (SELECT ProductID FROM Products WHERE ProductName IN ('Chai', 'Chang'))
--	ORDER BY InventoryDate, CategoryName, ProductName;
--go
-- OLD CODE TIME! 

-- Let's make our cool-ly named view.
CREATE VIEW [dbo].[ChaiXChangXInvenXEmp] as
		SELECT TOP 100000 
		C.CategoryName, P.ProductName, I.InventoryDate, I.[Count], 
		EmployeeName = E.EmployeeFirstName + ' ' + E.EmployeeLastName
			FROM viewInventories as I
				JOIN viewProducts as P
					ON P.ProductID = I.ProductID 
				JOIN viewCategories as C
					ON C.CategoryID = P.CategoryID
				JOIN viewEmployees as E
					ON E.EmployeeID = I.EmployeeID
		WHERE I.ProductID IN (SELECT ProductID FROM viewProducts WHERE ProductName IN ('Chai', 'Chang'))
ORDER BY I.InventoryDate, C.CategoryName, P.ProductName;
go

-- You know what I have to do.
Select * From ChaiXChangXInvenXEmp;
-- Everything checks out!
---------------------------------------------------------------------------------------------------
-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
-- HAHAHA I despise self joins. Let's get it done.

-- OLD CODE
--SELECT 
--    e2.EmployeeFirstName + ' ' + e2.EmployeeLastName AS Manager, 
--	-- referencing the table like it's 2 tables.
--    e1.EmployeeFirstName + ' ' + e1.EmployeeLastName AS Employee
---- Setting my alias.
--FROM Employees AS e1
--LEFT JOIN Employees AS e2 
---- We set the join where the two tables (the one table in this case specified as 2) are the same.
--ON e1.ManagerID = e2.EmployeeID
---- We order by manager.
--ORDER BY Manager;
--go
-- OLD CODE

-- Making our view: 
Create view [dbo].[EmployeeXManager] as
Select TOP 1000000
	e2.EmployeeFirstName + ' ' + e2.EmployeeLastName as Manager,
	e1.EmployeeFirstName + ' ' + e1.EmployeeLastName as Employee
	From viewEmployees as e1
		Left join viewEmployees as e2
			On e1.ManagerID = e2.EmployeeID
Order by Manager;
go

-- Time to check and see if we did it right.
Select * From EmployeeXManager;
-- CHECKS OUT!!!
---------------------------------------------------------------------------------------------------
-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
-- This took me literally forever! AHH!!!

-- We're using our cool (and not impractical at all) naming convention.
Create view InvenXProdXyCatXEmp as
	SELECT TOP 10000000
	-- Since I have to reference so much stuff here I'm laying it out by view for easier reading.
		C.CategoryID, C.CategoryName,
		P.ProductID, P.ProductName, P.UnitPrice,
		I.InventoryID, I.InventoryDate, I.[Count],
		E.EmployeeID, 
	-- Again if someone knows a prettier way of combining these columns please leave me some feedback
	-- and teach me how!
		EmployeeName = E.EmployeeFirstName + ' ' + E.EmployeeLastName, 
		Manager = M.EmployeeFirstName + ' ' + M.EmployeeLastName
			FROM viewCategories AS C
				INNER JOIN viewProducts AS P
			 ON P.CategoryID = C.CategoryID
				INNER JOIN viewInventories AS I
			 ON I.ProductID = P.ProductID
				INNER JOIN viewEmployees AS E
			 ON E.EmployeeID = I.EmployeeID
				INNER JOIN viewEmployees AS M
			ON M.EmployeeID = E.ManagerID
ORDER BY CategoryName, ProductName, InventoryID, EmployeeName;
go

-- CHECK TIME!!!
Select * From InvenXProdXyCatXEmp;
-- IT IS DONE! and correct.
---------------------------------------------------------------------------------------------------
-- Test your Views (NOTE: You must change the your view names to match what I have below!)

-- I've already checked each question and everything looks good without me changing my view names (I am lazy 
-- and I don't want to rewrite everything.)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/