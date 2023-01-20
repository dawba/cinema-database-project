----------------------------------------------------------------------------
-- trigger for checking if movie we attempt to add to current showing list has valid license
IF OBJECT_ID ('LicenseCheck', 'TR') IS NOT NULL  
   DROP TRIGGER LicenseCheck;  
GO
CREATE TRIGGER LicenseCheck
ON Showings
INSTEAD OF INSERT
AS
BEGIN
    IF
    ( (SELECT finish FROM Licenses L JOIN INSERTED I  ON L.movieID = I.movieID ) > (SELECT [date] from inserted))
      INSERT INTO Showings  
      (hallID,movieID,[date],standardPrice,reducedPrice,ticketsBought) 
      SELECT hallID,movieID,[date],standardPrice,reducedPrice,ticketsBought FROM INSERTED
     ELSE 
     PRINT('License for this movie has expired! Studio contact info:')
     SELECT S.contactInfo FROM Studios S JOIN Licenses L ON L.studioID = S.studioID 
     WHERE L.movieID = (SELECT I.movieID FROM inserted I)
END
GO
----------------------------------------------------------------------------
-- trigger reducing current product stock availability after transaction
 IF OBJECT_ID ('ProductSold', 'TR') IS NOT NULL  
   DROP TRIGGER ProductSold;  
GO
CREATE TRIGGER ProductSold
ON TransactionList
AFTER INSERT 
AS 
BEGIN
    UPDATE Products 
    SET pcsInStock = (pcsInStock - (SELECT amount FROM inserted)) 
    WHERE Products.productID = (SELECT productID from inserted)
END 
GO
----------------------------------------------------------------------------
-- trigger increasing current product stock availability after ordering restockment
 IF OBJECT_ID ('ProductOrdered', 'TR') IS NOT NULL  
   DROP TRIGGER ProductOrdered;  
GO
CREATE TRIGGER ProductOrdered
ON Orders
AFTER INSERT 
AS 
BEGIN
    UPDATE Products 
    SET pcsInStock = (pcsInStock + (SELECT quantity FROM inserted)) 
    WHERE Products.productID = (SELECT productID from inserted)
END 
GO 
----------------------------------------------------------------------------
-- trigger increasing tickets sold count and checking for seat availability
IF OBJECT_ID ('TicketSold', 'TR') IS NOT NULL  
   DROP TRIGGER TicketSold;  
GO
CREATE TRIGGER TicketSold
ON Reservations
INSTEAD OF INSERT 
AS 
BEGIN
    IF NOT EXISTS(SELECT * FROM Reservations R 
                           JOIN inserted ON R.showingID = inserted.showingID 
                           WHERE R.seatID = inserted.seatID )
BEGIN
UPDATE Showings 
    SET ticketsBought = (ticketsBought + 1) 
    WHERE Showings.showingID = (SELECT showingID FROM inserted) 
INSERT INTO Reservations(showingID, ticketType, seatID, employeeID, sold, clientID) 
    SELECT showingID, ticketType, seatID, employeeID, sold, clientID FROM inserted 
END
ELSE print('This seat has already been reserved!')
END 
GO 
----------------------------------------------------------------------------
-- trigger for returning tickets as long as request was made at least 30 minutes before show
IF OBJECT_ID ('TicketReturn', 'TR') IS NOT NULL  
   DROP TRIGGER TicketReturn;  
GO
CREATE TRIGGER TicketReturn
ON Reservations
INSTEAD OF DELETE 
AS 
BEGIN
    IF DATEDIFF(minute, GETDATE(), (SELECT [date] FROM Showings S 
                                                  JOIN deleted ON deleted.showingID = S.showingID)) >= 30 
BEGIN
    DELETE FROM Reservations WHERE reservationID IN (SELECT reservationID FROM deleted)  
UPDATE Showings 
    SET ticketsBought = (ticketsBought-1) 
    WHERE Showings.showingID = (SELECT showingID FROM deleted) 
END 
ELSE PRINT('You cannot return a ticket less than 30 minutes before the show, sorry')
END 
GO
