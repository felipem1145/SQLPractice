DROP TABLE IF EXISTS Examples.Gadget
CREATE TABLE Examples.Gadget
(

	GadgetId int IDENTITY (1,1) NOT NULL CONSTRAINT PKGadget PRIMARY KEY,
	GadgetCode varchar(10) NOT NULL
);

INSERT INTO Examples.Gadget (GadgetCode)
VALUES ('LENOVO-100');

SELECT * FROM Examples.Gadget;

DELETE FROM Examples.Gadget WHERE GadgetId >= 2;

ALTER TABLE Examples.Gadget ADD CONSTRAINT AKGadget UNIQUE (GadgetCode);



/* CHECK CONSTRAINT 

Limiting data more than a data type For example, the int data type is
arguably the most common data type, but usually the desired range of a
columns’ value is not between approximately -2 billion to 2 billion. A CHECK
constraint can limit the data in a column to a desired range
Now, let’s look at another example:
You have a table that captures the cost of a product in a grocery store
You can use the smallmoney data type, but the smallmoney data type has a
range of - 214,748.3648 to 214,748.3647
There are concerns at the top and the bottom of the range
First, a product would not cost a negative amount, so the bottom limit should
be at least 0 and not -214,748.3648
At the top you don’t want to accidentally charge 200 thousand for a can of
corn
For this example, we will limit the cost to a range of greater than 0 to 999.99
Translated to SQL Server: ItemCost > 0 AND ItemCost < 1000
*/

CREATE TABLE Examples.GroceryItem 

(
	ItemId int IDENTITY(1,1) PRIMARY KEY,
	ItemDescr varchar(200) NULL, 
	ItemCost smallmoney NULL CONSTRAINT CHKGroceryItem_ItemCosttRange 
	CHECK (ItemCost > 0 AND ItemCost <1000)
);

--Success Example
INSERT INTO Examples.GroceryItem (ItemDescr, ItemCost)
VALUES ('PC Ice Cream', NULL);

--Fail Example because the ItemCost havo to be lesser that 1000
INSERT INTO Examples.GroceryItem (ItemDescr, ItemCost)
VALUES (NULL, 1000);


/*As a final note, since this column allows NULL values, it is possible to insert a
NULL value in the ItemCost column
If for some reason you want to reject NULL values in this column, modify the
CHECK predicate by adding:ItemCost > 0 AND ItemCost < 1000 AND ItemCost IS NOT NULLDatatypes can be used to limit data to a maximum length, but they cannot
limit data to a minimum length or a certain format
For example, it is a common desire to disallow a user from inputting only
space characters for a value in a column, or to make sure that a
corporate-standard-formatted value is input for a value*/CREATE TABLE Examples.Message( 	MessageTag char(5) NOT NULL,	Comment nvarchar(MAX) NULL)/*For these tables, we want to check the format of the two values
? For the MessageTag, we want to make sure the format of the data is
Alpha-NumberNumberNumber
? We can do this check by using a Regular Expression
? For the Comment column, the requirement is to make sure that the value
is either NULL, or a character string of 1 or more characters*/ALTER TABLE Examples.MessageADD CONSTRAINT CHKMessage_MessageTagFormat CHECK (MessageTag LIKE '[A-Z]-[0-9][0-9][0-9]');ALTER TABLE Examples.MessageADD CONSTRAINT CHKMessage_CommentNotEmptyCHECK (LEN(Comment)>0);INSERT INTO Examples.Message (MessageTag, Comment)VALUES('nope','');INSERT INTO Examples.Message (MessageTag, Comment)VALUES('A-001','');--Success exampleINSERT INTO Examples.Message (MessageTag, Comment)VALUES('A-001','This is a comment');SELECT * FROM Examples.Message











INSERT INTO Examples.GroceryItem(ItemDescr,ItemCost)
VALUES (NULL,100.5);

INSERT INTO Examples.GroceryItem(ItemDescr,ItemCost)
VALUES (NULL,3000.95);
 