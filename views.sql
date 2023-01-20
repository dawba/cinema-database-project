----------------------------------------------------------------------------
-- view displaying viewers who agreed to receive the newsletter
GO
CREATE View [ClientsWithNewsletter] AS
    SELECT * FROM Clients C
    WHERE C.newsletter = 1
GO

DROP VIEW [ClientsWithNewsletter]
----------------------------------------------------------------------------
-- view displaying most watched movies in our cinema
GO
CREATE View [MostViewedFilms] AS
    SELECT TOP 3 WITH TIES M.movieTitle, COUNT(R.reservationID) as [total viewers] FROM Reservations R
    JOIN Showings S ON (R.showingID = S.showingID)
    JOIN Movies M ON(M.movieID = S.movieID)
    GROUP BY M.movieTitle ORDER BY COUNT(R.reservationID) DESC
GO

DROP View [MostViewedFilms]
----------------------------------------------------------------------------
-- view displaying contacts to studios for which we have films with expired licenses
GO
CREATE View [ContactToStudiosForNewLicenses] AS
    SELECT M.movieTitle, S.studioName, S.contactInfo, L.price FROM Licenses L
    JOIN Movies M ON(L.movieID = M.movieID)
    JOIN Studios S ON(S.studioID = L.movieID)
    WHERE GETDATE() >= (SELECT finish FROM Licenses WHERE Licenses.movieID = L.movieID)
GO

DROP View [ContactToStudiosForNewLicenses]
----------------------------------------------------------------------------
-- view displaying viewers who have watched more than half of our showings
GO
CREATE View [MostLoyalClients] AS
    SELECT C.name, C.surname, C.email, C.phoneNumber, C.newsletter, COUNT(DISTINCT R.showingID) AS [films watched]
    FROM Clients C
    JOIN Reservations R ON(C.clientID = R.clientID)
    GROUP BY C.name, C.surname, C.email, C.phoneNumber, C.newsletter
    HAVING COUNT(DISTINCT R.showingID) >= ROUND((SELECT COUNT(*) FROM Showings)/2, 0)
GO

DROP View [MostLoyalClients]