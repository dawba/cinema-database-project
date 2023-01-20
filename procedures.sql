----------------------------------------------------------------------------
-- stored procedure generating income/expense balance
-- arguments of the procedure are not mandatory value-vise (NULL is accepted)
-- passed format is [YY, MM] e.g. [2022, 1] or [2022, NULL]
DROP PROCEDURE IF EXISTS generateMonthlyIncomeBalance;
GO
CREATE PROCEDURE generateMonthlyIncomeBalance (@year INT, @month INT)
AS
DECLARE @tickets INT, @productIncome INT, @productExpense INT, @salaries INT
BEGIN
    SET @tickets = (SELECT SUM(ticketSales) AS Tickets FROM incomeFromMovies(@year, @month))
    SET @productIncome = (SELECT SUM(income) FROM productsIncome(@year, @month))
    SET @productExpense = (SELECT SUM(expense) FROM productsExpense(@year, @month))
    SET @salaries = (SELECT SUM(salary) AS Salaries FROM employeeSalary(@year, @month))

    SELECT @tickets AS [ticketIncome], @productIncome AS [productIncome], @salaries AS [salaries], @productExpense AS [productExpense], @tickets + @productIncome - @salaries - @productExpense AS [totalBalance] 
END
GO

EXECUTE generateMonthlyIncomeBalance 2022, NULL
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