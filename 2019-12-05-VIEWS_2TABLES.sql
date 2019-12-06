--Modifying data in views with more tha one table
/* So far, the view we have worked with only contained one table. In this section
we look at how things are affected when you have greater than one table in
the view
Let’s modify the Examples.Gadget table we have been using in this section,
including data, and a foreign key constraint.
Let’s also add a catalog table called GadgetType*/



CREATE TABLE Examples.GadgetType
(	
	GadgetType varchar(10) NOT NULL CONSTRAINT PKGadgetType PRIMARY KEY,
	Description varchar(200) NOT NULL
)
GO

INSERT INTO Examples.GadgetType(GadgetType,Description)
VALUES ('Manual', 'No batteries'),
	   ('Electronic','Lots of bats');
GO

ALTER TABLE Examples.Gadget
	ADD CONSTRAINT FKGadget$ref$Examples_GadgetType
	FOREIGN KEY (GadgetType) REFERENCES Examples.GadgetType (GadgetType);
GO

CREATE VIEW Examples.GadgetExtension
AS 
	SELECT Gadget.GadgetId, Gadget.GadgetNumber, Gadget.GadgetType, GadgetType.GadgetType AS DomainGadgetType,
		   GadgetType.Description AS GadgettypeDescription
	FROM Examples.Gadget
		   JOIN Examples.GadgetType
			ON Gadget.GadgetType = GadgetType.GadgetType;

			--If we tried to use the following INSERT statement, as we have previously done,
we would see an error message:
INSERT INTO Examples.GadgetExtension(GadgetId,GadgetNumber, GadgetType, DomainGadgetType, GadgettypeDescription)
VALUES(7,'00000007','Acoustic','Acoustic','Sound');
GO
/*Here, it is important to know the internals of the view so we can break this
INSERT statement into two separate ones that add information to each part of
the VIEW:*/

INSERT INTO Examples.GadgetExtension(DomainGadgetType, GadgettypeDescription)
VALUES ('Acoustic','Sound');

INSERT INTO Examples.GadgetExtension(GadgetId,GadgetNumber,GadgetType)
VALUES (7,'00000007','Acoustic');

--The UPDATE statement is simpler, just target specific columns:
UPDATE Examples.GadgetExtension
SET GadgettypeDescription = 'Uses Batteries'
WHERE GadgetId=1;
GO

SELECT * FROM Examples.Gadget;
SELECT * FROM Examples.GadgetType;
SELECT * FROM Examples.GadgetExtension;

/* A partitioned view is based on a query that uses a UNION ALL set operator to
treat multiple tables as one
The feature still exists, both for backward compatibility, and to enable a VIEW
object to work across multiple independent SQL Servers
Generally, this feature is still the best practice when having two or more
servers located in different corporate locations
Each location might have a copy of their data, and then a view is created that
lets you treat the table as one on the local server
Implement partitioned views
Our example will be located on a single server, but we will create two tables
with different data that we will merge using a partitioned VIEW
Using the WideWorldImporters example database:
? First, create two tables: Invoices_Region1 and Invoices_Region2
? Next, add data to them using INSERT statements*/

CREATE TABLE Examples.Invoices_Region1

(	
	InvoiceId int NOT NULL
	constraint PKInvoices_Region1 PRIMARY KEY,
	CONSTRAINT CHKInvoices_Region1_PartKey
			CHECK(InvoiceId BETWEEN 1 and 10000),
	CustomerId int NOT NULL,
	InvoiceDate date NOT NULL
);
GO

CREATE TABLE Examples.Invoices_Region2
(
	InvoiceId int NOT NULL
	CONSTRAINT PKInvoices_Regio2 PRIMARY KEY,
	CONSTRAINT CHKInvoices_Region2_PartKey
			CHECK (InvoiceId BETWEEN 10001 and 20000),
	CustomerId int NOT NULL,
	InvoiceDate date NOT NULL
	);
GO

INSERT INTO Examples.Invoices_Region1
(InvoiceId, CustomerId, InvoiceDate)
	SELECT InvoiceId, CustomerId, InvoiceDate	
	FROM WideWorldImporters_Andres.Sales.Invoices
	WHERE InvoiceID BETWEEN 1 and 10000;

INSERT INTO Examples.Invoices_Region2
(InvoiceId,CustomerId, InvoiceDate)
SELECT InvoiceId, CustomerId, InvoiceDate
FROM WideWorldImporters_Andres.Sales.Invoices
WHERE InvoiceId BETWEEN 10001 and 20000;

/* The PRIMARY KEY constraint of this table must be involved in the partitioning
for this to work
In our examples, we use a range of InvoiceId values, which is the primary key
of both tables
You could use a SEQUENCE object with a pre-defined range to create your
data, but the partitioning column cannot be a column with the IDENTITY
property, and it cannot be loaded from a DEFAULT constraint
 The partitioning range must be enforced with a CHECK constraint, and must
be for a mutually-exclusive range of values*/


CREATE VIEW Examples.InvoicesPartitioned
AS
	SELECT InvoiceId, CustomerId, InvoiceDate
	FROM Examples.Invoices_Region1
	UNION ALL --ONLY FOR TABLES WHICH HAVING SAME DATA
	SELECT InvoiceId, CustomerId, InvoiceDate
	FROM Examples.Invoices_Region2;
GO

/* Using this VIEW object, and requesting data from only one of the TABLE
objects by partitioning key only needs to fetch data from one of the partitions
As an example, fetch the row where InvoiceId = 1:*/

SELECT *
FROM Examples.InvoicesPartitioned
--WHERE InvoiceId = 1 ;
GO

SELECT InvoiceId
FROM Examples.InvoicesPartitioned
WHERE InvoiceDate = '2013-01-01';
GO

--IMPLEMENT INDEXED VIEWS

CREATE VIEW Sales.InvoiceCustomerInvoiceAggregates
WITH SCHEMABINDING
AS
SELECT Invoices.CustomerId,
		SUM(ExtendedPrice * Quantity) AS SumCost,
		SUM(LineProfit) AS SumProfit,
		COUNT_BIG(*) AS TotalItemCount
FROM Sales.Invoices
	JOIN Sales.InvoiceLines
		ON Invoices.InvoiceID = InvoiceLines.InvoiceID
GROUP BY Invoices.CustomerID;
GO

CREATE UNIQUE CLUSTERED INDEX XPKInvoiceCustomerInvoiceAggregates 
on Sales.InvoiceCustomerInvoiceAggregates(CustomerID);
GO

SELECT * 
FROM Sales.InvoiceCustomerInvoiceAggregates;
GO