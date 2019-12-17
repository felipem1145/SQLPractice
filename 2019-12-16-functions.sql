/*USER-DEFINED FUNCTIONS
*/

CREATE FUNCTION Sales.Customers_ReturnOrderCount
(
	--Parameters
	@CustomerID int,
	@OrderDate date = NULL--if any value is entered will be NULL
)

RETURNS INT--RETURN TYPE
	WITH RETURNS NULL ON NULL INPUT, -- if all parameters NULL, return NULL immediately
	SCHEMABINDING --make certain that the tables/columns referenced canot change

AS
--FUNCTION CODE
	BEGIN 
		DECLARE @OutputValue int

		SELECT @OutputValue = COUNT(*)
		FROM Sales.Orders
		WHERE CustomerID = @CustomerID
			AND (OrderDate = @OrderDate
					OR @OrderDate IS NULL);

		RETURN @OutputValue
	END;

GO

/*Using parameters of a FUNCTION object differs from using a STORED
PROCEDURE, in that you can’t use named parameters (@VALUE), and you can’t
skip parameters that have defaults
For example, to use this function you might code the following:*/

SELECT Sales.Customers_ReturnOrderCount(905,'2013-01-01');--Number of orders that date
GO

/*Now, since you can’t skip parameters that have DEFAULT values… you must
use this DEFAULT keyword instead: (@OrderDate)*/

SELECT Sales.Customers_ReturnOrderCount(905, DEFAULT);--Number of total orders without specify the date
GO

SELECT CustomerID, Sales.Customers_ReturnOrderCount(CustomerID,DEFAULT)
FROM Sales.Customers;
GO

/*The most common use case for scalar UDFs is to format some data in a
common manner
For example, say you have a business need to format a value, such as the
CustomerPurchaseOrderNumber in the Sales.Orders table in
WideWorldImporters in a given way, and in multiple locations
In this case we just right pad the data to eight characters, and prepend ‘CPO’
to the number*/


SELECT N'CPO' + RIGHT(N'00000000' + CustomerPurchaseOrderNumber,8)
FROM WideWorldImporters_Andres.Sales.Orders;

/*But what if you need to use this in multiple places?
If you need to use this in multiple places, you can fold that expression into a
scalar USER DEFINED FUNCTION object, like so:*/

CREATE FUNCTION Sales.Orders_ReturnFormattedCPO

(
	@CustomerPurchaseOrderNumber nvarchar(20)
)

RETURNS nvarchar(20)
WITH RETURNS NULL ON NULL INPUT,
	SCHEMABINDING
AS

	BEGIN
		RETURN ('CPO' + RIGHT('00000000'+ @CustomerPurchaseOrderNumber,8));
	END;

--Now you can reuse this function anywhere by writing something like this:

SELECT Sales.Orders_ReturnFormattedCPO('12345') as CustomerPurchaseOrderNumber;


--TABLES

/*Table-Valued UDFs are used to present a set of data as a table, much like a
view
In fact, they are generally thought of as views with parameters (or
parameterized views.) 
There are two kinds of table-valued UDFs:
? Simple Consisting of a single Transact-SQL query, simple table-valued
UDFs work very much like a VIEW
? Multi-Statement Consists of as many statements as you need, allowing
you to build a set of data using the same logic as you had in scalar UDFs,
but returning a table instead of a scalar variable

For these examples, use the same requirements used in our scalar example,
returning the number of sales for a given customer, and optionally on a given
day
In addition, add a requirement to determine if they have any backorders on
that day.
Starting with the simple table-valued UDF, the basics of the object is, just like a
VIEW, a single SELECT query*/

CREATE FUNCTION Sales.Customers_ReturnOrderCountSetSimple
(
	@CustomerID int,
	@OrderDate date = NULL
)

RETURNS TABLE
AS
RETURN (SELECT COUNT(*) AS SalesCount,
		CASE WHEN MAX(BackorderOrderId) IS NOT NULL
				THEN 1 ELSE 0 END AS HasBackorderFlag
			FROM Sales.Orders
			WHERE CustomerId = @CustomerID
			AND (OrderDate= @OrderDate
				 OR @OrderDate IS NULL));
GO

