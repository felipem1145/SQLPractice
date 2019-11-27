CREATE SCHEMA Examples;
GO --This is a comment

CREATE TABLE Examples.Widget(

WidgetCode varchar(10) NOT NULL CONSTRAINT PKWidget PRIMARY KEY,
WidgetName varchar(100) NULL,
WidgetPrice varchar(10) NULL 

) 

SELECT * FROM Examples.Widget

DROP TABLE Examples.Widget