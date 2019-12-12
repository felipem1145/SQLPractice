

/*PROCEDURES
A business requirement for which a STORED PROCEDURE might be useful, is
to be able to INSERT, UPDATE, and DELETE to a table*/

CREATE TABLE Examples.SimpleTable
(
	SimpleTableId int NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Value1 varchar(20) NOT NULL,
	Value2 varchar(20) NOT NULL
);

--INSERT PROCEDURE 

CREATE PROCEDURE Examples.SimpleTable_Insert

	@SimpleTableId int, --- not needed
	@Value1 varchar(20),
	@Value2 varchar(20)

AS

	INSERT INTO Examples.SimpleTable VALUES (@Value1,@Value2);
GO

EXEC Examples.SimpleTable_Insert 0, 'MY VALUE 1','MY VALUE 2'

SELECT * FROM Examples.SimpleTable

--UPDATE PROCEDURE

CREATE PROCEDURE Examples.SimpleTable_Update

	@SimpleTableId int, 
	@Value1 varchar(20),
	@Value2 varchar(20)

AS

	UPDATE Examples.SimpleTable 
	SET Value1 = @Value1,
		Value2 = @Value2
		WHERE SimpleTableId= @SImpleTableId
GO

EXEC Examples.SimpleTable_Update 1,'NEW VALUE 1', 'NEW VALUE 2';

--DELETE PROCEDURE

CREATE PROCEDURE Examples.SimpleTable_Delete

	@SimpleTableId int,
	@Value varchar(20)
AS

	DELETE Examples.SimpleTable 
		WHERE SimpleTableId= @SImpleTableId
GO

EXEC Examples.SimpleTable_Delete 1,'NEW VALUE1';

/*By creating these STORED PROCEDURES we are providing a strict user
interface that we have complete control over
1) The first and most common is by using one or more result sets
Consider the following SP which returns all data from the TABLE*/