
--CREATE A NEW VIEW TO “We need to be able to provide access to orders made in the last 12 months, where
--there were more than one-line items in that order. They only need to see the Line
--items, Customer, SalesPerson, Date of Order, and when it was likely to be delivered
--by”

CREATE VIEW Sales.Orders10YearsMultipleItems
AS
SELECT OrderId, CustomerId, SalespersonPersonId, OrderDate,ExpectedDeliveryDate
FROM Sales.Orders
WHERE OrderDate >= DATEADD (Year,-10, SYSDATETIME())
	AND (SELECT COUNT(*)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderID = Orders.OrderID) > 1;


SELECT TOP 5 *
FROM Sales.Orders10YearsMultipleItems
ORDER BY ExpectedDeliveryDate DESC;


--CREATE A VIEW TO REFORMATTING “I would like to see the data in the People table in a more user friendly manner. If
--the user can logon to the system, have a textual value that says ‘Can Logon’, or
--‘Can’t Logon’ otherwise. I would like to see employees typed as ‘SalesPerson’ if they
--are, then as ‘Regular’ if they are an employee, or ‘Not Employee’ if they are not an
--employee.”

--BOOLEAN VIEW 

SELECT PersonId, IsPermittedToLogOn, IsEmployee, IsSalesPerson
FROM Application.People;

--CREATING FRIENDLY VIEW 

CREATE VIEW Application.PeopleEmployeeStatus
AS
SELECT PersonId, Fullname, IsPermittedToLogon, IsEmployee, IsSalesPerson,
	CASE WHEN IsPermittedToLogon = 1 THEN 'Can Logon'
		ELSE 'Can''t Logon' END AS LogonRights,
	CASE WHEN IsEmployee =1 AND IsSalesPerson = 1 THEN 'Sales Person'
		WHEN IsEmployee = 1 THEN 'Regular'
		ELSE 'Not Employee' END AS EmployeeType
FROM Application.People;

SELECT *
FROM Application.PeopleEmployeeStatus

--CREATE VIEW FOR REPORTING  “Build a simple reporting interface that allows
--us to see sales profit or net income broken down by city, state, or territory
--customer category for the current week, up to the most current data”

CREATE SCHEMA Reports 
GO

CREATE VIEW Reports.InvoiceSummaryBasis
AS
SELECT Invoices.InvoiceId, CustomerCategories.CustomerCategoryName, Cities.CityName, 
		StateProvinces.StateProvinceName, StateProvinces.SalesTerritory, Invoices.InvoiceDate,
		--- the grain of the report is at the invoice, so total the amounts for invoice
		SUM(InvoiceLines.LineProfit) as InvoiceProfit,
		SUM(InvoiceLines.ExtendedPrice) as InvoiceExtendedPrice
FROM Sales.Invoices	
	JOIN Sales.InvoiceLines
		ON Invoices.InvoiceID = InvoiceLines.InvoiceID
	JOIN Sales.Customers
		ON Customers.CustomerID = Invoices.CustomerID
	JOIN Sales.CustomerCategories
		ON Customers.CustomerCategoryID = CustomerCategories.CustomerCategoryID
	JOIN Application.Cities
		ON Customers.DeliveryCityID = Cities.CityID
	JOIN Application.StateProvinces
		ON StateProvinces.StateProvinceID = Cities.StateProvinceID
GROUP BY Invoices.InvoiceID, CustomerCategories.CustomerCategoryName, Cities.CityName, StateProvinces.StateProvinceName, 
		StateProvinces.SalesTerritory, Invoices.InvoiceDate;

SELECT TOP 5 SalesTerritory, SUM(InvoiceProfit) AS InvoiceProfitTotal
FROM Reports.InvoiceSummaryBasis
WHERE InvoiceDate > '2016-05-01'
GROUP BY SalesTerritory
ORDER BY InvoiceProfitTotal DESC;