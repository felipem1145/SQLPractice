SELECT Orders.ContactPersonID, People.PreferredName
FROM Sales.Orders	
	JOIN Application.People
	ON People.PersonID = Orders.ContactPersonID
WHERE People.PreferredName = 'Aakriti';

CREATE NONCLUSTERED INDEX ContactPersonId_Include_OrderDate_ExpectedDeliveryDate
ON Sales.Orders(ContactPersonId)
INCLUDE(OrderDate, ExpectedDeliveryDate)
ON USERDATA;
GO