----------------------------------------------------------------------------
-- function displaying revenue from showings
-- arguments of the function are not mandatory value-vise (NULL is accepted)
-- passed format is [YY, MM] e.g. [2022, 01] or [2022, NULL]
DROP FUNCTION IF EXISTS dbo.incomeFromMovies;
GO
CREATE FUNCTION incomeFromMovies (@year INT, @month INT)
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
        WHERE showingID = R.showingID AND ticketType = 'R' AND YEAR(S.[date]) = @year AND MONTH(S.[date]) = @month) * S.reducedPrice 
    +
    (SELECT COUNT(*) 
        FROM Reservations 
        WHERE showingID = R.showingID AND ticketType = 'S' AND YEAR(S.[date]) = @year AND MONTH(S.[date]) = @month) * S.standardPrice 
        AS [ticket sales],
        S.[date]
    FROM Reservations R
    JOIN Showings S ON(R.showingID = S.showingID)
    JOIN Movies M ON(S.movieID = M.movieID)
    GROUP BY M.movieTitle, R.showingID, S.reducedPrice, S.standardPrice, S.[date]
    RETURN
END
GO

SELECT * FROM incomeFromMovies(2022, 1)
----------------------------------------------------------------------------
-- function displaying ticket sale statistics for online and on-site sales
-- arguments of the function are not mandatory value-vise (NULL is accepted)
-- passed format is [YY, MM, movie title] e.g. [2022, 1, 'Django Unchained'] or [2022, NULL, NULL]
DROP FUNCTION IF EXISTS dbo.ticketSaleStatisticComparison;
GO
CREATE FUNCTION ticketSaleStatisticComparison (@year INT, @month INT, @movieTitle NVARCHAR(50))
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
            AND((@movieTitle IS NOT NULL AND M.movieTitle = @movieTitle) OR (@movieTitle IS NULL))
    GROUP BY R.showingID, S.ticketsBought, M.movieTitle, S.[date]
    ORDER BY S.[date] ASC   
    RETURN
END
GO

SELECT * FROM ticketSaleStatisticComparison(NULL, NULL, NULL)
----------------------------------------------------------------------------
-- function calculating salaries for all employees
-- arguments of the function are not mandatory value-vise (NULL is accepted)
-- passed format is [YY, MM] e.g. [2022, 1] or [2022, NULL]
DROP FUNCTION IF EXISTS dbo.employeeSalary;
GO
CREATE FUNCTION employeeSalary (@year INT, @month INT)
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
                    AND MONTH(Shifts.[start]) = @month
                    AND YEAR(Shifts.[start]) = @year
                    ) * P.wage AS [salary]
    FROM Employees E
    JOIN Shifts S ON(S.employeeID = E.employeeID)
    JOIN Posts P ON(E.postID = P.postID)
    GROUP BY E.name, E.surname, E.employeeID, P.post, P.wage ORDER BY [salary] DESC
    RETURN
END
GO

SELECT * FROM employeeSalary(2022, 1)
----------------------------------------------------------------------------
-- function calculating revenue from product sales
-- arguments of the function are not mandatory value-vise (NULL is accepted)
-- passed format is [YY, MM] e.g. [2022, 1] or [2022, NULL]
DROP FUNCTION IF EXISTS dbo.productsIncome;
GO 
CREATE FUNCTION productsIncome ( @year INT,@month INT)
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
         WHERE ((@month is not null AND MONTH(T.[date]) = @month ) OR @month is null)
         AND ((@year IS NOT NULL AND YEAR(T.[date]) = @year  ) OR @year is null)
         GROUP BY P.name
    RETURN
END 
GO  

SELECT * FROM productsIncome(NULL,NULL)
----------------------------------------------------------------------------
-- function calculating expenses for ordered products
-- arguments of the function are not mandatory value-vise (NULL is accepted)
-- passed format is [YY, MM] e.g. [2022, 1] or [2022, NULL]
DROP FUNCTION IF EXISTS dbo.productsExpense;
GO 
CREATE FUNCTION productsExpense (@year INT, @month INT)
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
         WHERE ((@month is not null AND MONTH(O.orderDate) = @month ) OR @month is null)
         AND ((@year IS NOT NULL AND YEAR(O.orderDate) = @year  ) OR @year is null)
         GROUP BY P.name
    RETURN
END 
GO  

SELECT * FROM productsExpense(NULL,NULL)  
----------------------------------------------------------------------------
-- function displaying cinemas repertoire for selected time span
-- arguments of the function are mandatory value-vise
-- passed format is [YY-MM-DD, YY-MM-DD] e.g. [2022-01-01, 2022-03-04]
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
----------------------------------------------------------------------------