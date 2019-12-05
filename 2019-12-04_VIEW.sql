/*Modifying views that reference one table
Generally speaking, any view that references a single table is going to be
editable
For example, let’s create a VIEW based on the following requirements:
“The user needs a view to allow the interface to only be able to modify rows where
the type of gadget is ‘Electronic’, but not any other value.”*/

CREATE TABLE Examples.Gadget

(	
	GadgetId int NOT NULL CONSTRAINT PKGadget PRIMARY KEY,
	GadgetNumber char(8) NOT NULL CONSTRAINT AKGadget UNIQUE,
	GadgetType varchar(10) NOT NULL
);
GO

INSERT INTO Examples.Gadget(GadgetId, GadgetNumber, GadgetType)
VALUES (1,'00000001','Electronic'),
	   (2,'00000002','Manual'),
	   (3,'00000003','Manual');
GO	

CREATE VIEW Examples.ElectronicGadget
AS
	SELECT GadgetId, GadgetNumber, GadgetType, 
			UPPER(GadgetType) AS UpperGadgetType
	FROM Examples.Gadget
	WHERE GadgetType = 'Electronic';
GO

-- YOU CAN RESTRINCT WHAT INFO THE USER COULD SEE

SELECT ElectronicGadget.GadgetNumber AS FromView, Gadget.GadgetNumber AS FromTable, Gadget.GadgetType,
	   ElectronicGadget.UpperGadgetType
FROM Examples.ElectronicGadget
	FULL OUTER JOIN Examples.Gadget
	ON ElectronicGadget.GadgetId = Gadget.GadgetId;

	INSERT INTO Examples.ElectronicGadget(GadgetId, GadgetNumber, GadgetType)
	VALUES (4,'00000004','Electronic'),
		   (5,'00000005','Manual');

--Use the UPDATE statement as follows to modify values in the table using the VIEW 

 --Update the row we could see to values that could not be seen

 UPDATE Examples.ElectronicGadget
 SET GadgetType='Manual'
 WHERE GadgetNumber='00000004';
 GO

 --Update the row we could NOT see to values that could actually see

 UPDATE Examples.ElectronicGadget
 SET GadgetType = 'Electronic'
 WHERE GadgetNumber = '00000005';
 GO

 /*When using a view as an interface, one of the things that you generally don’t
want to occur is to have a DML statement affect the view of the data that is
not visible to the user of the view
In order to stop this from occurring, there is a clause on the creation of the
view called WITH CHECK OPTION that checks to make sure that the result of
the INSERT or UPDATE statement is still visible to the user of the view 
*/
 -- Limiting what data can be added to a table through a view through DDL

 ALTER VIEW Examples.ElectronicGadget
 AS
	SELECT GadgetId, GadgetNumber, GadgetType,
		   UPPER(GadgetType) AS UpperGadgetType
	FROM Examples.Gadget
	WHERE GadgetType = 'Electronic'
	WITH CHECK OPTION;
GO

INSERT INTO Examples.ElectronicGadget(GadgetId,GadgetNumber, GadgetType)
VALUES(6,'00000006', 'Manual');
--It failed because with the check option its not possible to insert 'Manual" values because it doesnt conform with the condition of the view.
GO

--So only it is possible to insert electronic values
INSERT INTO Examples.ElectronicGadget(GadgetId,GadgetNumber, GadgetType)
VALUES(6,'00000006', 'Electronic');
GO
