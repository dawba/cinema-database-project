# Baza danych kina - Dawid Bania i Miłosz Wielgus

## Wstęp - o projekcie

Podstawowym założeniem projektu było umożliwienie gromadzenia danych o salach kinowych,
seansach filmowych oraz umożliwienie generowania raportów dotyczących sprzedaży biletów jak i przychodów dla każdego filmu.

Tak zaprojektowana baza danych może zostać wykorzystana jako narzędzie do wyprowadzania statystyk związanych z funkcjonowaniem kina
jak i jako wewnętrzna warstwa aplikacji np. webowej danego kina - wyświetlanie aktualnych seansów, dostępności miejsc czy wyszukiwania filmów
z konkretnymi parametrami (aktorzy, gatunki, rok wydania).

Głównym fundamentem podczas projektowania bazy danych było założenie prostoty i przejrzystości przechowywanych danych i maksymalnym zmniejszeniem ich redundantności w poszczególnych tabelach.

## Pielęgnacja bazy danych

Standardowy dzień w kinie wiąże się z potrzebą przetwarzania dużej ilości danych. Każdego dnia dochodzi do kilkuset transakcji, uwzględniając w tym nieuniknione zwroty czy reklamacje, rezerwacje miejsc i obsługę listy pokazów filmowych. 

Utrata danych oznaczałaby konieczność ponownego wprowadzenia tysięcy rekordów co może okazać się problematyczne ze względu na liczne powiązania pomiędzy tabelami. 

W takich warunkach koniecznym jest tworzenie kopii zapasowych bazy, zwłaszcza w okresach "zwiększonego natężenia" takich jak święta, premier blockbusterowych filmów. Dodatkowym pragmatycznym rozwiązaniem jest przygotowywanie pełnej kopii bazy - na przykład na koniec tygodnia.

## Tabele

1. Movies - tabela przechowująca informacje o filmie, na przykład takie jak: *tytuł*, *gatunek*, *reżyser* czy *aktualny stan wyświetlania filmu*.
2. Showings - tabela przechowująca informacje o seansach, zawierająca informacje o *cenie biletów*, *dacie pokazu* czy *sali*.
3. Reservations - tabela przechowująca informacje o rezerwacjach, zawierająca kluczowe: *numer rezerwowanego miejsca*, *dane klienta*, *rodzaj biletu* czy *datę transakcji*.
4. Seats - tabela z siedzeniami dla sal kinowych.
5. Halls - tabela z salami kinowymi, posiadająca informacje o *pojemności sali* jak i jej *nazwie*.
6. Clients - tabela z danymi dotyczących klienta, zawierająca informacje takie jak *imię*, *nazwisko* i *dane kontaktowe*.
7. Employees - tabela z danymi związanymi z pracownikami kina, zawierająca między innymi: *imię*, *nazwisko*, *numerem stanowiska*
8. Posts - tabela ze szczegółowymi danymi dla konkretnego stanowiska, czyli posiadająca *nazwę stanowiska*, *stawkę godzinową*
9. Shifts - tabela z informacjami dotyczącymi odbywanych przez pracowników zmian w kinie czyli *początkiem* i *końcem* zmiany, jak i *numerem pracownika*.
10. Products - tabela z danymi o produktach sprzedawanych przez kino, zawierająca *cenę sprzedaży*, *cenę kupna* czy *aktualną ilość towaru w magazynie*.
11. Orders - tabela posiadająca informacje dotyczące zamówień towarów do kina, a zatem z *datą zamówienia*, *ilością*, *numerem produktu*, czy *statusie zamówienia*.
12. TransactionList - tabela danych obejmująca informacje związane z transakcjami, czyli produktami sprzedawanymi przez kino, a więc zawiera *numer pracownika*, *date transakcji*, *numer sprzedawanego produktu* i *jego cenę* czy *ilość*.
13. Studios - tabela przechowująca informacje o wytwórniach, dystrybutorach filmów, które wyświetlamy w kinie, czyli *nazwę studia* i *kontakt do niego*.
14. Licenses - tabela przechowująca dane o zakupionych licencjach na wyświetlanie filmów, obejmująca *cenę*, *początek* i *koniec* licencji, *numer filmu* czy *numer studia*.
15. Actors - tabela z danymi dotyczącymi aktorów, którzy pojawiają się w filmach wyświetlanych przez kino, zawierająca *imię* i *nazwisko* aktora, *datę urodzin* czy *kraj pochodzenia*.
16. Cast - tabela wiążąca *aktorów* z *filmami* w postaci obsady filmu, zawierająca *numer filmu*, *numer aktora* oraz *rolę* przez niego graną. 

## Schemat bazy danych
![database_schema.png](database_schema.png)

## Diagram ER
//WIP

## Widoki
Utworzone widoki pozwalają na wyświetlanie uogólnionych danych, które
nie wymagają parametryzacji do wyliczenia.


```sql
----------------------------------------------------------------------------
--1 view displaying viewers who agreed to receive the newsletter
GO
CREATE View [ClientsWithNewsletter] AS
    SELECT * FROM Clients C
    WHERE C.newsletter = 1
GO
----------------------------------------------------------------------------
```

```sql
----------------------------------------------------------------------------
--2 view displaying most watched movies in our cinema
GO
CREATE View [MostViewedFilms] AS
    SELECT TOP 3 WITH TIES M.movieTitle, COUNT(R.reservationID) as [total viewers] FROM Reservations R
    JOIN Showings S ON (R.showingID = S.showingID)
    JOIN Movies M ON(M.movieID = S.movieID)
    GROUP BY M.movieTitle ORDER BY COUNT(R.reservationID) DESC
GO
----------------------------------------------------------------------------
```

```sql
--3 view displaying contacts to studios for which we have films with expired licenses
GO
CREATE View [ContactToStudiosForNewLicenses] AS
    SELECT M.movieTitle, S.studioName, S.contactInfo, L.price FROM Licenses L
    JOIN Movies M ON(L.movieID = M.movieID)
    JOIN Studios S ON(S.studioID = L.movieID)
    WHERE GETDATE() >= (SELECT finish FROM Licenses WHERE Licenses.movieID = L.movieID)
GO
----------------------------------------------------------------------------
```

```sql
----------------------------------------------------------------------------
--4 view displaying viewers who have watched more than half of our showings
GO
CREATE View [MostLoyalClients] AS
    SELECT C.name, C.surname, C.email, C.phoneNumber, C.newsletter, COUNT(DISTINCT R.showingID) AS [films watched]
    FROM Clients C
    JOIN Reservations R ON(C.clientID = R.clientID)
    GROUP BY C.name, C.surname, C.email, C.phoneNumber, C.newsletter
    HAVING COUNT(DISTINCT R.showingID) >= ROUND((SELECT COUNT(*) FROM Showings)/2, 0)
GO
----------------------------------------------------------------------------
```

## Funkcje
Zaprojektowane funkcje wykorzystywane są do wyświetlania konkretnych danych, z reguły związanych
z obrotami kina czy aktualnym repertuarem. 


```sql
----------------------------------------------------------------------------
--1 function displaying revenue from showings
--  arguments of the function are not mandatory value-vise (NULL is accepted)
--  passed format is [YY, MM, DD] e.g. [2022, 1, 1] or [2022, NULL, NULL]
DROP FUNCTION IF EXISTS dbo.incomeFromMovies;
GO
CREATE FUNCTION incomeFromMovies (@year INT, @month INT, @day INT)
RETURNS @IncomeFromMovies TABLE
(
    [movieTitle] NVARCHAR(50),
    [ticketSales] INT,
    [date] DATE
)
AS
BEGIN
    INSERT INTO @IncomeFromMovies
    SELECT M.movieTitle,
    (SELECT COUNT(*) 
        FROM Reservations 
        WHERE showingID = R.showingID AND ticketType = 'R' AND ((@year IS NOT NULL AND YEAR(S.[date]) = @year) OR @year IS NULL) 
                                                           AND ((@month IS NOT NULL AND MONTH(S.[date]) = @month) OR @month IS NULL)
                                                           AND ((@day IS NOT NULL AND DAY(S.[date]) = @day) OR @day IS NULL)) * S.reducedPrice 
    +
    (SELECT COUNT(*) 
        FROM Reservations 
        WHERE showingID = R.showingID AND ticketType = 'S' AND ((@year IS NOT NULL AND YEAR(S.[date]) = @year) OR @year IS NULL) 
                                                           AND ((@month IS NOT NULL AND MONTH(S.[date]) = @month) OR @month IS NULL)
                                                            AND ((@day IS NOT NULL AND DAY(S.[date]) = @day) OR @day IS NULL)) * S.standardPrice 
        AS [ticket sales],
        S.[date]
    FROM Reservations R
    JOIN Showings S ON(R.showingID = S.showingID)
    JOIN Movies M ON(S.movieID = M.movieID)
    WHERE ((@year IS NOT NULL AND YEAR(S.[date]) = @year) OR @year IS NULL) 
                                AND ((@month IS NOT NULL AND MONTH(S.[date]) = @month) OR @month IS NULL)
                                AND ((@day IS NOT NULL AND DAY(S.[date]) = @day) OR @day IS NULL)
    GROUP BY M.movieTitle, R.showingID, S.reducedPrice, S.standardPrice, S.[date]
    RETURN
END
GO

SELECT * FROM incomeFromMovies(NULL, 1, 30)
----------------------------------------------------------------------------
```

```sql
----------------------------------------------------------------------------
--2 function displaying ticket sale statistics for online and on-site sales
--  arguments of the function are not mandatory value-vise (NULL is accepted)
--  passed format is [YY, MM, DD, movie title] e.g. [2022, 1, 1, 'Django Unchained'] or [2022, NULL, NULL, NULL]
DROP FUNCTION IF EXISTS dbo.ticketSaleStatisticComparison;
GO
CREATE FUNCTION ticketSaleStatisticComparison (@year INT, @month INT, @day INT, @movieTitle NVARCHAR(50))
RETURNS @TicketSaleStatistics TABLE
(
    [movieTitle] NVARCHAR(50),
    [date] DATE,
    [sold by employees] INT,
    [sold online] INT
)
AS
BEGIN
    INSERT INTO @TicketSaleStatistics
    SELECT M.movieTitle, S.[date],
        COUNT(R.employeeID) AS [sold by employees], 
        S.ticketsBought - COUNT(R.employeeID) AS [sold online] 
    FROM Reservations R
    JOIN Showings S ON(R.showingID = S.showingID)
    JOIN Movies M ON(S.movieID = M.movieID)
    WHERE ((@year IS NOT NULL AND YEAR(S.[date]) = @year) OR (@year IS NULL))
            AND((@month IS NOT NULL AND MONTH(S.[date]) = @month) OR (@month IS NULL))
            AND((@day IS NOT NULL AND DAY(S.[date]) = @day) OR (@day IS NULL))
            AND((@movieTitle IS NOT NULL AND M.movieTitle = @movieTitle) OR (@movieTitle IS NULL))
    GROUP BY R.showingID, S.ticketsBought, M.movieTitle, S.[date]
    ORDER BY S.[date] ASC   
    RETURN
END
GO

SELECT * FROM ticketSaleStatisticComparison(2022, 01, 24, NULL)
----------------------------------------------------------------------------
```

```sql
----------------------------------------------------------------------------
--3 function calculating salaries for all employees
--  arguments of the function are not mandatory value-vise (NULL is accepted)
--  passed format is [YY, MM, DD] e.g. [2022, 1, 1] or [2022, NULL, NULL]
DROP FUNCTION IF EXISTS dbo.employeeSalary;
GO
CREATE FUNCTION employeeSalary (@year INT, @month INT, @day INT)
RETURNS @Salaries TABLE
(
    [name] NVARCHAR(50),
    [surname] NVARCHAR(50),
    [post] NVARCHAR(50),
    [wage] INT,
    [salary] INT
)
AS
BEGIN
    INSERT INTO @Salaries
    SELECT E.name, E.surname, P.post, P.wage, (
            SELECT SUM(DATEDIFF(HOUR, Shifts.[start], Shifts.[end])) 
            FROM Shifts 
            WHERE employeeID = E.employeeID 
                    AND ((@year IS NOT NULL AND YEAR(Shifts.[start]) = @year) OR (@year IS NULL))
                    AND ((@month IS NOT NULL AND MONTH(Shifts.[start]) = @month) OR (@month IS NULL))
                    AND ((@day IS NOT NULL AND DAY(Shifts.[start]) = @day) OR (@day IS NULL))
                    ) * P.wage AS [salary]
    FROM Employees E
    JOIN Shifts S ON(S.employeeID = E.employeeID)
    JOIN Posts P ON(E.postID = P.postID)
    WHERE  ((@year IS NOT NULL AND YEAR(S.[start]) = @year) OR (@year IS NULL))
                    AND ((@month IS NOT NULL AND MONTH(S.[start]) = @month) OR (@month IS NULL))
                    AND ((@day IS NOT NULL AND DAY(S.[start]) = @day) OR (@day IS NULL))
    GROUP BY E.name, E.surname, E.employeeID, P.post, P.wage
    RETURN
END
GO

SELECT * FROM employeeSalary(2022, NULL, NULL)
----------------------------------------------------------------------------
```

```sql
----------------------------------------------------------------------------
--4 function calculating revenue from product sales
--  arguments of the function are not mandatory value-vise (NULL is accepted)
--  passed format is [YY, MM, DD] e.g. [2022, 1, 1] or [2022, NULL, NULL]
DROP FUNCTION IF EXISTS dbo.productsIncome;
GO 
CREATE FUNCTION productsIncome (@year INT, @month INT, @day INT)
RETURNS @producttable TABLE
(
	[ProductName] VARCHAR(50),
	Income INT
)
AS
BEGIN
	INSERT INTO @producttable 
         SELECT P.name,SUM(P.retailPrice*T.amount)
         FROM Products P JOIN TransactionList T ON P.productID = T.productID 
         WHERE ((@year IS NOT NULL AND YEAR(T.[date]) = @year  ) OR @year IS NULL)
         AND ((@month IS NOT NULL AND MONTH(T.[date]) = @month ) OR @month IS NULL)
         AND ((@day IS NOT NULL AND MONTH(T.[date]) = @day ) OR @day IS NULL)
         GROUP BY P.name
    RETURN
END 
GO  

SELECT * FROM productsIncome(2022, 1, 6)
----------------------------------------------------------------------------
```

```sql
----------------------------------------------------------------------------
--5 function calculating expenses for ordered products
--  arguments of the function are not mandatory value-vise (NULL is accepted)
--  passed format is [YY, MM, DD] e.g. [2022, 1, 1] or [2022, NULL, NULL]
DROP FUNCTION IF EXISTS dbo.productsExpense;
GO 
CREATE FUNCTION productsExpense (@year INT, @month INT, @day INT)
RETURNS @producttable TABLE
(
	[ProductName] VARCHAR(50),
	Expense INT
)
AS
BEGIN
	INSERT INTO @producttable 
         SELECT P.name,SUM(O.orderPrice)
         FROM Products P JOIN Orders O ON P.productID = O.productID 
         WHERE ((@year IS NOT NULL AND YEAR(O.orderDate) = @year  ) OR @year IS NULL)
         AND ((@month IS NOT NULL AND MONTH(O.orderDate) = @month) OR @month IS NULL)
         AND ((@day IS NOT NULL AND DAY(O.orderDate) = @day) OR @day IS NULL)
         GROUP BY P.name
    RETURN
END 
GO  

SELECT * FROM productsExpense(NULL, NULL, NULL)  
----------------------------------------------------------------------------
```

```sql
----------------------------------------------------------------------------
--6 function displaying cinemas repertoire for selected time span
--  arguments of the function are mandatory value-vise
--  passed format is [YY-MM-DD, YY-MM-DD] e.g. [2022-01-01, 2022-03-04]
DROP FUNCTION IF EXISTS dbo.cinemaRepertoire;
GO 
CREATE FUNCTION cinemaRepertoire (@start DATE, @finish DATE)
RETURNS @repertoire TABLE
(
	[Date] DATETIME,
	Movie NVARCHAR(50),
	Hall NVARCHAR(10),
	noOfFreeSeats INT
)
AS
BEGIN
	INSERT INTO @repertoire 
        SELECT S.[date],M.movieTitle,H.colour,H.capacity - S.ticketsBought 
        FROM Showings S JOIN Movies M ON S.movieID = M.movieID
        JOIN Halls H ON H.hallID = S.hallID 
        WHERE S.[date] BETWEEN @start AND @finish 
	RETURN
END 
GO 

SELECT * FROM cinemaRepertoire(2022-01-01, 2022-01-10)
----------------------------------------------------------------------------
```

## Procedury składowane
Zaprojektowane procedury składowane służą m.in do generowania całościowego bilansu przychodów i wydatków czy przychodów z konkretnego filmu,
wyświetlaniu dostępnych miejsc na konkretny seans.

```sql
----------------------------------------------------------------------------
-- stored procedure generating income/expense balance
-- arguments of the procedure are not mandatory value-vise (NULL is accepted)
-- passed format is [YY, MM] e.g. [2022, 1] or [2022, NULL]
DROP PROCEDURE IF EXISTS generateIncomeBalance;
GO
CREATE PROCEDURE generateIncomeBalance (@year INT, @month INT, @day INT)
AS
DECLARE @tickets INT, @productIncome INT, @productExpense INT, @salaries INT
BEGIN
    SET @tickets = (SELECT SUM(ticketSales) AS Tickets FROM incomeFromMovies(@year, @month, @day))
    SET @tickets = ISNULL(@tickets, 0)
    SET @productIncome = (SELECT SUM(income) FROM productsIncome(@year, @month, @day))
    SET @productIncome = ISNULL(@productIncome, 0)
    SET @productExpense = (SELECT SUM(expense) FROM productsExpense(@year, @month, @day))
    SET @productExpense = ISNULL(@productExpense, 0)
    SET @salaries = (SELECT SUM(salary) AS Salaries FROM employeeSalary(@year, @month, @day))
    SET @salaries = ISNULL(@salaries, 0)

    SELECT @tickets AS [ticketIncome], @productIncome AS [productIncome], @salaries AS [salaries], @productExpense AS [productExpense], @tickets + @productIncome - @salaries - @productExpense AS [totalBalance] 
END
GO

EXECUTE generateIncomeBalance 2022, 1, 23
----------------------------------------------------------------------------
```

```sql
----------------------------------------------------------------------------
-- stored procedure displaying available seats for selected showing
-- arguments of the procedure are mandatory value-vise (NULL is not accepted)
-- passed format is [number] e.g. [23]
DROP PROCEDURE IF EXISTS freeSeats;  
GO  
CREATE PROCEDURE freeSeats (@showID INT) 
AS 
DECLARE @hall INT
SET @hall = (SELECT DISTINCT S.hallID FROM Reservations R JOIN Seats S ON S.seatID = R.seatID WHERE R.showingID = @showID)

    IF  @hall = 1 
    BEGIN    

            SELECT[row],
            S1 = ISNULL((SELECT -1 FROM Reservations  R JOin Seats Ss ON R.seatID = Ss.seatID  WHERE R.showingID = @showID AND Ss.seatNumber = 1 AND Ss.[row] = S.[row]),(SELECT Ss.seatID FROM Seats Ss WHERE Ss.hallID = 1 AND Ss.[row] = S.[row] AND Ss.seatNumber = 1)),
            S2 = ISNULL((SELECT -1 FROM Reservations  R JOin Seats Ss ON R.seatID = Ss.seatID  WHERE R.showingID = @showID AND Ss.seatNumber = 2 AND Ss.[row] = S.[row]),(SELECT Ss.seatID FROM Seats Ss WHERE Ss.hallID = 1 AND Ss.[row] = S.[row] AND Ss.seatNumber = 2)),
            S3 = ISNULL((SELECT -1 FROM Reservations  R JOin Seats Ss ON R.seatID = Ss.seatID  WHERE R.showingID = @showID AND Ss.seatNumber = 3 AND Ss.[row] = S.[row]),(SELECT Ss.seatID FROM Seats Ss WHERE Ss.hallID = 1 AND Ss.[row] = S.[row] AND Ss.seatNumber = 3)),
            S4 = ISNULL((SELECT -1 FROM Reservations  R JOin Seats Ss ON R.seatID = Ss.seatID  WHERE R.showingID = @showID AND Ss.seatNumber = 4 AND Ss.[row] = S.[row]),(SELECT Ss.seatID FROM Seats Ss WHERE Ss.hallID = 1 AND Ss.[row] = S.[row] AND Ss.seatNumber = 4))
            FROM Seats S 
            WHERE hallID = 1
            GROUP BY S.[row]
    END
    ELSE IF @hall = 2 
    BEGIN   
            SELECT[row],
            S1 = ISNULL((SELECT -1 FROM Reservations  R JOin Seats Ss ON R.seatID = Ss.seatID  WHERE R.showingID = @showID AND Ss.seatNumber = 1 AND Ss.[row] = S.[row]),(SELECT Ss.seatID FROM Seats Ss WHERE Ss.hallID = 2 AND Ss.[row] = S.[row] AND Ss.seatNumber = 1)),
            S2 = ISNULL((SELECT -1 FROM Reservations  R JOin Seats Ss ON R.seatID = Ss.seatID  WHERE R.showingID = @showID AND Ss.seatNumber = 2 AND Ss.[row] = S.[row]),(SELECT Ss.seatID FROM Seats Ss WHERE Ss.hallID = 2 AND Ss.[row] = S.[row] AND Ss.seatNumber = 2)),
            S3 = ISNULL((SELECT -1 FROM Reservations  R JOin Seats Ss ON R.seatID = Ss.seatID  WHERE R.showingID = @showID AND Ss.seatNumber = 3 AND Ss.[row] = S.[row]),(SELECT Ss.seatID FROM Seats Ss WHERE Ss.hallID = 2 AND Ss.[row] = S.[row] AND Ss.seatNumber = 3)),
            S4 = ISNULL((SELECT -1 FROM Reservations  R JOin Seats Ss ON R.seatID = Ss.seatID  WHERE R.showingID = @showID AND Ss.seatNumber = 4 AND Ss.[row] = S.[row]),(SELECT Ss.seatID FROM Seats Ss WHERE Ss.hallID = 2 AND Ss.[row] = S.[row] AND Ss.seatNumber = 4)),
            S5 = ISNULL((SELECT -1 FROM Reservations  R JOin Seats Ss ON R.seatID = Ss.seatID  WHERE R.showingID = @showID AND Ss.seatNumber = 5 AND Ss.[row] = S.[row]),(SELECT Ss.seatID FROM Seats Ss WHERE Ss.hallID = 2 AND Ss.[row] = S.[row] AND Ss.seatNumber = 5))
            FROM Seats S 
            WHERE hallID = 2
            GROUP BY S.[row]
    END
    ELSE IF @hall = 3 
    BEGIN    
            SELECT[row],
            S1 = ISNULL((SELECT -1 FROM Reservations  R JOin Seats Ss ON R.seatID = Ss.seatID  WHERE R.showingID = @showID AND Ss.seatNumber = 1 AND Ss.[row] = S.[row]),(SELECT Ss.seatID FROM Seats Ss WHERE Ss.hallID = 3 AND Ss.[row] = S.[row] AND Ss.seatNumber = 1)),
            S2 = ISNULL((SELECT -1 FROM Reservations  R JOin Seats Ss ON R.seatID = Ss.seatID  WHERE R.showingID = @showID AND Ss.seatNumber = 2 AND Ss.[row] = S.[row]),(SELECT Ss.seatID FROM Seats Ss WHERE Ss.hallID = 3 AND Ss.[row] = S.[row] AND Ss.seatNumber = 2)),
            S3 = ISNULL((SELECT -1 FROM Reservations  R JOin Seats Ss ON R.seatID = Ss.seatID  WHERE R.showingID = @showID AND Ss.seatNumber = 3 AND Ss.[row] = S.[row]),(SELECT Ss.seatID FROM Seats Ss WHERE Ss.hallID = 3 AND Ss.[row] = S.[row] AND Ss.seatNumber = 3)),
            S4 = ISNULL((SELECT -1 FROM Reservations  R JOin Seats Ss ON R.seatID = Ss.seatID  WHERE R.showingID = @showID AND Ss.seatNumber = 4 AND Ss.[row] = S.[row]),(SELECT Ss.seatID FROM Seats Ss WHERE Ss.hallID = 3 AND Ss.[row] = S.[row] AND Ss.seatNumber = 4)),
            S5 = ISNULL((SELECT -1 FROM Reservations  R JOin Seats Ss ON R.seatID = Ss.seatID  WHERE R.showingID = @showID AND Ss.seatNumber = 5 AND Ss.[row] = S.[row]),(SELECT Ss.seatID FROM Seats Ss WHERE Ss.hallID = 3 AND Ss.[row] = S.[row] AND Ss.seatNumber = 5))
            FROM Seats S 
            WHERE hallID = 3
            GROUP BY S.[row]
    END 
GO 

EXECUTE freeSeats 1
----------------------------------------------------------------------------
```

```sql
----------------------------------------------------------------------------
-- stored procedure displaying total movie income and sold tickets for selected movie
-- arguments of the procedure are mandatory value-vise (NULL is not accepted)
-- passed format is [movie title] e.g. ['Django Unchained']
DROP PROCEDURE IF EXISTS movieIncome;  
GO  
CREATE PROCEDURE movieIncome (@title VARCHAR(50)) 
AS
DECLARE @movieID INT
SET @movieID = (SELECT M.movieID From Movies M WHERE M.movieTitle = @title) 
SELECT @title AS Title,S.movieID,COUNT(R.seatID) AS TicketsSold,
sum(case ticketType when 'S' then 1 else 0 end)*S.standardPrice +sum(case ticketType when 'R' then 1 else 0 end)*S.reducedPrice-(SELECT SUM(L.price) FROM Licenses L WHERE L.movieID = @movieID) as MovieIncome  FROM Reservations R JOIN Showings S ON S.showingID = R.showingID
WHERE S.movieID = @movieID
GROUP BY S.movieID,S.standardPrice,S.reducedPrice  
GO

EXECUTE movieIncome 'Django Unchained'
----------------------------------------------------------------------------
```

```sql
----------------------------------------------------------------------------
-- stored procedure displaying number of days-off each employee had
-- arguments of the procedure are mandatory value-vise (NULL is not accepted)
-- passed format is [YY, MM] e.g. [2022, 1]
DROP PROCEDURE IF EXISTS daysOff;  
GO  
CREATE PROCEDURE daysOff (@year INT, @month INT) 
AS 
DECLARE @monthlength INT 
SET @monthlength = (CASE  
                        WHEN (@month%2 = 1 AND @month<8) THEN 31 
                        WHEN (@month%2 = 0 AND @month<8) THEN 30
                        WHEN (@month%2 = 0 AND @month>7) THEN 31 
                        WHEN (@month%2 = 1 AND @month>7) THEN 30 
                        ELSE 30 END)
SELECT E.name, E.surname, @monthlength - COUNT(S.[start]) AS daysOff 
                                                        FROM Employees E 
                                                        JOIN Shifts S ON E.employeeID = S.employeeID 
WHERE MONTH(S.[start]) = @month AND YEAR(S.[start]) = @year
GROUP BY E.name,E.surname
GO 

EXECUTE daysOff 2022, 1
----------------------------------------------------------------------------
```

## Wyzwalacze
Przygotowane wyzwalacze są związane z aktualizowaniem i dodawaniem danych związanych z transakcjami/rezerwacją miejsc czy seansami.

```sql
----------------------------------------------------------------------------
--1 trigger for checking if movie we attempt to add to current showing list has valid license
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
```

```sql
----------------------------------------------------------------------------
--2 trigger reducing current product stock availability after transaction
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
```

```sql
----------------------------------------------------------------------------
--3 trigger increasing current product stock availability after ordering restockment
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
```

```sql
----------------------------------------------------------------------------
--4 trigger increasing tickets sold count and checking for seat availability
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
```

```sql
----------------------------------------------------------------------------
--5 trigger for returning tickets as long as request was made at least 30 minutes before show
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
----------------------------------------------------------------------------
```

## Skrypt tworzący bazę danych

```sql
IF OBJECT_ID('Cinema', 'U') IS NOT NULL
    DROP DATABASE Cinema
CREATE DATABASE Cinema
GO
USE Cinema

CREATE TABLE [dbo].[Movies]
(
    [movieID] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
    [movieTitle] VARCHAR(100) NOT NULL,
    [genre] VARCHAR(100) NOT NULL,
    [releaseYear] INT NOT NULL,
    [director] VARCHAR(100) NOT NULL,
    [length] INT NOT NULL,
    [country] VARCHAR(100) NOT NULL,
    [onDisplay] VARCHAR(3) NOT NULL
);

CREATE TABLE [dbo].[Actors]
(
    [actorID] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
    [actorName] VARCHAR(100) NOT NULL,
    [actorSurname] VARCHAR(100) NOT NULL,
    [yearOfBirth] INT NOT NULL,
    [gender] VARCHAR(1) NOT NULL,
    [country] VARCHAR(100) NOT NULL,
);

CREATE TABLE [dbo].[Cast]
(
    [movieID] INT,
    [actorID] INT,
    [role] VARCHAR(100) NOT NULL
);

CREATE TABLE [dbo].[Clients]
(
    [clientID] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
    [name] NVARCHAR(100) NOT NULL,
    [surname] NVARCHAR(100) NOT NULL,
    [email] VARCHAR(100),
    [phoneNumber] VARCHAR(9),
    [newsletter] BIT
);

CREATE TABLE [dbo].[Reservations]
(
    [reservationID] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
    [showingID] INT NOT NULL,
    [ticketType] VARCHAR(100) NOT NULL,
    [seatID] INT NOT NULL,
    [employeeID] INT,
    [sold] DATE NOT NULL,
    [clientID] INT NOT NULL
);

CREATE TABLE [dbo].[Seats]
(
    [seatID] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
    [hallID] INT NOT NULL,
    [row] INT NOT NULL,
    [seatNumber] INT NOT NULL
); 

CREATE TABLE [dbo].[Employees]
(
    [employeeID] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
    [name] NVARCHAR(100) NOT NULL,
    [surname] NVARCHAR(100) NOT NULL,
    [sex] VARCHAR(1) NOT NULL,
    [dateOfBirth] DATE NOT NULL,
    [postID] INT NOT NULL
);

CREATE TABLE [dbo].[Shifts]
(
    [employeeID] INT NOT NULL ,
    [start] DATETIME NOT NULL,
    [end] DATETIME NOT NULL,
);

CREATE TABLE [dbo].[Posts]
(
    [postID] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
    [post] VARCHAR(100) NOT NULL,
    [wage] INT NOT NULL,
);

CREATE TABLE [dbo].[Showings]
(
    [showingID] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
    [hallID] INT NOT NULL,
    [movieID] INT NOT NULL,
    [date] DATETIME NOT NULL,
    [standardPrice] INT NOT NULL,
    [reducedPrice] INT NOT NULL,
    [ticketsBought] INT NOT NULL
);

CREATE TABLE [dbo].[TransactionList]
(
    [transactionID] INT NOT NULL IDENTITY (1,1) PRIMARY KEY,
    [employeeID] INT NOT NULL,
    [date] DATE NOT NULL,
    [amount] INT NOT NULL,
    [productID] INT NOT NULL
); 

CREATE TABLE [dbo].[Products]
(
    [productID] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY ,
    [name] VARCHAR(100) NOT NULL,
    [retailPrice] INT NOT NULL,
    [wholesalePrice] INT NOT NULL,
    [pcsInStock] INT NOT NULL
);

CREATE TABLE [dbo].[Studios]
(
    [studioID] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
    [studioName] VARCHAR(100) NOT NULL,
    [contactInfo] VARCHAR(100) NOT NULL
);

CREATE TABLE [dbo].[Licenses]
(
    [studioID] INT NOT NULL ,
    [movieID] INT NOT NULL ,
    [start] DATE NOT NULL,
    [finish] DATE NOT NULL,
    [price] INT NOT NULL
);

CREATE TABLE [dbo].[Orders]
(
    [orderID] INT NOT NULL IDENTITY (1,1) PRIMARY KEY,
    [productID] INT NOT NULL,
    [quantity] INT NOT NULL,
    [orderPrice] INT NOT NULL,
    [orderDate] DATE NOT NULL,
    [status] VARCHAR(20) NOT NULL
); 

CREATE TABLE [dbo].[Halls]
(
    [hallID] INT NOT NULL IDENTITY (1, 1) PRIMARY KEY,
    [colour] VARCHAR(100) NOT NULL,
    [capacity] INT NOT NULL
); 

ALTER TABLE Cast 
ADD CONSTRAINT [moviePlayed] 
FOREIGN KEY (movieID) REFERENCES Movies(movieID);

ALTER TABLE Cast 
ADD CONSTRAINT [actorPlayed] 
FOREIGN KEY (actorID) REFERENCES Actors(actorID);

ALTER TABLE Reservations 
ADD CONSTRAINT [showing] 
FOREIGN KEY (showingID) REFERENCES Showings(showingID);

ALTER TABLE Reservations 
ADD CONSTRAINT [seat]  
FOREIGN KEY (seatID) REFERENCES Seats(seatID);

ALTER TABLE Reservations 
ADD CONSTRAINT [rEmployee] 
FOREIGN KEY (employeeID) REFERENCES Employees(employeeID);

ALTER TABLE Reservations 
ADD CONSTRAINT [client] 
FOREIGN KEY (clientID) REFERENCES Clients(clientID);

ALTER TABLE Seats
ADD CONSTRAINT [hall] 
FOREIGN KEY (hallID) REFERENCES Halls(hallID);

ALTER TABLE Employees
ADD CONSTRAINT [post] 
FOREIGN KEY (postID) REFERENCES Posts(postID);

ALTER TABLE Shifts
ADD CONSTRAINT [sEmployee] 
FOREIGN KEY (employeeID) REFERENCES Employees(employeeID);

ALTER TABLE Showings
ADD CONSTRAINT [showingHall] 
FOREIGN KEY (hallID) REFERENCES Halls(hallID);

ALTER TABLE Showings
ADD CONSTRAINT [showingMovie] 
FOREIGN KEY (movieID) REFERENCES Movies(movieID);

ALTER TABLE TransactionList
ADD CONSTRAINT [transactionEmployee] 
FOREIGN KEY (employeeID) REFERENCES Employees(employeeID);

ALTER TABLE TransactionList
ADD CONSTRAINT [transProduct] 
FOREIGN KEY (productID) REFERENCES Products(productID);

ALTER TABLE Licenses
ADD CONSTRAINT [lStudio] 
FOREIGN KEY (studioID) REFERENCES Studios(studioID);

ALTER TABLE Licenses
ADD CONSTRAINT [lMovie] 
FOREIGN KEY (movieID) REFERENCES Movies(movieID);

ALTER TABLE Orders
ADD CONSTRAINT [orderedProduct] 
FOREIGN KEY (productID) REFERENCES Products(productID);
```