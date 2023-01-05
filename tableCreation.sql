IF EXISTS(select *
          from sys.databases
          where name = 'Cinema')
    DROP DATABASE Cinema
CREATE DATABASE Cinema 

IF OBJECT_ID(N'dbo.Movies', N'U') IS NOT NULL
    DROP TABLE [dbo].[Movies];
GO
CREATE TABLE [dbo].[Movies]
(
    [movieID]     INT          NOT NULL IDENTITY (1,1) PRIMARY KEY,
    [movieTitle]  VARCHAR(100) NOT NULL,
    [genre]       VARCHAR(100) NOT NULL,
    [releaseYear] INT          NOT NULL,
    [director]    VARCHAR(100) NOT NULL,
    [length]      INT          NOT NULL,
    [country]     VARCHAR(100) NOT NULL,
    [onDisplay]   VARCHAR(3)   NOT NULL
)

IF OBJECT_ID(N'dbo.Actors', N'U') IS NOT NULL
    DROP TABLE [dbo].[Actors];
GO
CREATE TABLE [dbo].[Actors]
(
    [actorID]      INT          NOT NULL IDENTITY (1,1) PRIMARY KEY,
    [actorName]    VARCHAR(100) NOT NULL,
    [actorSurname] VARCHAR(100) NOT NULL,
    [yearOfBirth]  INT          NOT NULL,
    [gender]       VARCHAR(1)   NOT NULL,
    [country]      VARCHAR(100) NOT NULL,
)

IF OBJECT_ID(N'dbo.Cast', N'U') IS NOT NULL
    DROP TABLE [dbo].[Cast];
GO
CREATE TABLE [dbo].[Cast]
(
    [movieID] INT          NOT NULL,
    [actorID] INT          NOT NULL,
    [role]    VARCHAR(100) NOT NULL
)

IF OBJECT_ID(N'dbo.Clients', N'U') IS NOT NULL
    DROP TABLE [dbo].[Clients];
GO
CREATE TABLE [dbo].[Clients]
(
    [clientID]    INT           NOT NULL IDENTITY (1,1) PRIMARY KEY,
    [name]        NVARCHAR(100) NOT NULL,
    [surname]     NVARCHAR(100) NOT NULL,
    [email]       VARCHAR(100),
    [phoneNumber] VARCHAR(9),
    [newsletter]  BIT,
)

IF OBJECT_ID(N'dbo.Reservations', N'U') IS NOT NULL
    DROP TABLE [dbo].[Reservations];
GO
CREATE TABLE [dbo].[Reservations]
(
    [reservationID] INT          NOT NULL IDENTITY (1,1) PRIMARY KEY,
    [showingID]     INT          NOT NULL,
    [ticketType]    VARCHAR(100) NOT NULL,
    [seatID]        INT          NOT NULL,
    [employeeID]    INT,
    [sold]          DATE         NOT NULL,
    [clientID]      INT          NOT NULL,
)

IF OBJECT_ID(N'dbo.Seats', N'U') IS NOT NULL
    DROP TABLE [dbo].[Seats];
GO
CREATE TABLE [dbo].[Seats]
(
    [seatID]     INT NOT NULL IDENTITY (1,1) PRIMARY KEY,
    [hallID]     INT NOT NULL,
    [row]        INT NOT NULL,
    [seatNumber] INT NOT NULL,
)

IF OBJECT_ID(N'dbo.Employees', N'U') IS NOT NULL
    DROP TABLE [dbo].[Employees];
GO
CREATE TABLE [dbo].[Employees]
(
    [employeeID]  INT           NOT NULL IDENTITY (1,1) PRIMARY KEY,
    [name]        NVARCHAR(100) NOT NULL,
    [surname]     NVARCHAR(100) NOT NULL,
    [sex]         VARCHAR(1)    NOT NULL,
    [dateOfBirth] DATE          NOT NULL,
    [postID]      INT           NOT NULL,
)

IF OBJECT_ID(N'dbo.Shifts', N'U') IS NOT NULL
    DROP TABLE [dbo].[Shifts];
GO
CREATE TABLE [dbo].[Shifts]
(
    [employeeID] INT      NOT NULL,
    [start]      DATETIME NOT NULL,
    [end]        DATETIME NOT NULL,
)

IF OBJECT_ID(N'dbo.Posts', N'U') IS NOT NULL
    DROP TABLE [dbo].[Posts];
GO
CREATE TABLE [dbo].[Posts]
(
    [postID] INT          NOT NULL IDENTITY (1,1) PRIMARY KEY,
    [post]   VARCHAR(100) NOT NULL,
    [wage]   INT          NOT NULL,
)

IF OBJECT_ID(N'dbo.Showings', N'U') IS NOT NULL
    DROP TABLE [dbo].[Showings];
GO
CREATE TABLE [dbo].[Showings]
(
    [showingID]     INT  NOT NULL IDENTITY (1,1) PRIMARY KEY,
    [hallID]        INT  NOT NULL,
    [moveID]        INT  NOT NULL,
    [date]          DATE NOT NULL,
    [standardPrice] INT  NOT NULL,
    [reducedPrice]  INT  NOT NULL,
    [ticketsBought] INT  NOT NULL
)

IF OBJECT_ID(N'dbo.TransactionList', N'U') IS NOT NULL
    DROP TABLE [dbo].[TransactionList];
GO
CREATE TABLE [dbo].[TransactionList]
(
    [employeeID] INT  NOT NULL,
    [date]       DATE NOT NULL,
    [amount]     INT  NOT NULL,
    [productID]  INT NOT NULL,
)
IF OBJECT_ID(N'dbo.Products', N'U') IS NOT NULL
    DROP TABLE [dbo].[Products];
GO
CREATE TABLE [dbo].[Products]
(
    [productID]  INT  NOT NULL IDENTITY (1,1) PRIMARY KEY,
    [name]       VARCHAR(100) NOT NULL,
    [retailPrice]     INT  NOT NULL,
    [wholesalePrice]  INT NOT NULL,
    [pcsInStock]  INT NOT NULL
) 
IF OBJECT_ID(N'dbo.Studios', N'U') IS NOT NULL
    DROP TABLE [dbo].[Studios];
GO
CREATE TABLE [dbo].[Studios]
(
    [studioID] INT  NOT NULL IDENTITY (1,1) PRIMARY KEY,
    [studioName]       VARCHAR(100) NOT NULL,
    [contactInfo]     VARCHAR(100)  NOT NULL
) 
IF OBJECT_ID(N'dbo.Licenses', N'U') IS NOT NULL
    DROP TABLE [dbo].[Licenses];
GO
CREATE TABLE [dbo].[Licenses]
(
    [studioID] INT  NOT NULL ,
    [movieID]       INT NOT NULL,
    [start]     DATE  NOT NULL,
    [finish] DATE NOT NULL, 
    [price] INT NOT NULL
)


INSERT INTO Movies (movieTitle, genre, releaseYear, director, length, country, onDisplay)
VALUES ('Godfather', 'crime', 1972, 'Francis Ford Coppola', 170, 'USA', 'YES'),
       ('The Shawshank Redemption', 'drama', 1994, 'Frank Darabont', 142, 'USA', 'YES'),
       ('Schindlers List', 'history', 1993, 'Steven Spielberg', 195, 'USA', 'YES'),
       ('Forrest Gump', 'comedy', 1994, 'Robert Zemeckis', 142, 'USA', 'YES'),
       ('12 Angry Men', 'crime', 1957, 'Sidney Lumet', 96, 'USA', 'NO'),
       ('Star Wars: Episode IV - A New Hope', 'Fantasy', 1977, 'George Lucas', 121, 'USA', 'YES'),
       ('The Silence of the Lambs', 'thriller', 1991, 'Jonathan Demme', 118, 'USA', 'YES'),
       ('Intouchables', 'comedy', 2011, 'Oliver Nakache', 112, 'France', 'NO'),
       (N'La vita è bella', 'war', 1997, 'Roberto Benigni', 116, 'Italy', 'YES'),
       ('Fight Club', 'thriller', 1999, 'David Fincher', 139, 'USA', 'NO'),
       ('Joker', 'action', 2019, 'Todd Phillips', 122, 'USA', 'YES'),
       ('Django Unchained', 'western', 2012, 'Quentin Tarantino', 165, 'USA', 'YES'),
       ('Gran Torino', 'drama', 2008, 'Clint Eastwood', 116, 'USA', 'YES'),
       ('Good Will Hunting', 'drama', 1997, 'Gus Van Sant', 124, 'USA', 'YES'),
       (N'Léon', 'thriller', 1994, 'Luc Besson', 110, 'France', 'NO'),
       ('The Good The Bad and The Ugly', 'western', 1966, 'Todd Phillips', 179, 'Italy', 'NO'),
       ('Inglourious Basterds', 'war', 2009, 'Quentin Tarantino', 170, 'USA', 'YES'),
       ('Avatar: The Way of Water', 'sci-fi', 2022, 'James Cameron', 192, 'USA', 'YES')


INSERT INTO Actors(actorName, actorSurname, yearOfBirth, gender, country)
VALUES ('Marlon', 'Brando', 1924, 'M', 'USA'),
       ('Al', 'Pacino', 1940, 'M', 'USA'),
       ('Morgan', 'Freeman', 1937, 'M', 'USA'),
       ('Tim', 'Robbins', 1958, 'M', 'USA'),
       ('Liam', 'Neeson', 1952, 'M', 'USA'),
       ('Embeth', 'Davidtz', 1965, 'F', 'USA'),
       ('Tom', 'Hanks', 1956, 'M', 'USA'),
       ('Robin', 'Right', 1966, 'F', 'USA'),
       ('Mark', 'Hamill', 1951, 'M', 'USA'),
       ('Harrison', 'Ford', 1942, 'M', 'USA'),
       ('Carrie', 'Fisher', 1956, 'F', 'USA'),
       ('Anthony', 'Hopkins', 1937, 'M', 'USA'),
       ('Jodie', 'Foster', 1962, 'F', 'USA')

INSERT INTO Cast(movieID, actorID, role)
VALUES (1, 1, 'Michael Corleone'),
       (1, 2, 'Don Vito Corleone'),
       (2, 3, 'Ellis Boyd "Red" Redding '),
       (2, 4, 'Andy Dufresne'),
       (3, 5, 'Oskar Schindler'),
       (3, 6, 'Helen Hirsch'),
       (4, 7, 'Forrest Gump'),
       (4, 8, 'Jenny Curran'),
       (5, 9, 'Luke Skywalker'),
       (5, 10, 'Han Solo'),
       (5, 11, 'Princess Leia'),
       (6, 12, 'Dr Hannibal Lecter'),
       (6, 13, 'Clarice Starling') 

INSERT INTO Products(name,retailPrice,wholesalePrice,pcsInStock) VALUES
('fries',15,3,784),
('popcorn',12,2,1542),
('nachos',23,6,422),
('salsa dip',5,1,123),
('cheese dip',6,2,45),
('coke',7,1,4561),
('water',5,1,7842)

INSERT INTO Studios(studioName,contactInfo) VALUES
('Paramount Pictures','Carl Warback - 987883737'),
('Columbia Pictures','John Dew - 564206988'),
('Universal Pictures','Grubolini Gruby - 42069999292'),
('United Artists','Jan Kowalski - 12342534534'),
('Lucasfilms','Darth Vader - 666666666'),
('Orion Pictures','Hannie Lecture 452165154')


INSERT INTO Licenses(studioID,movieID,start,finish,price) VALUES
(1,1,N'2020-10-10',N'2022-12-15',12000),
(1,4,N'2017-01-10',N'2023-12-09',154200),
(2,2,N'2015-01-10',N'2022-11-12',17500),
(3,3,N'2021-01-17',N'2023-05-17',17125),
(4,5,N'1999-01-10',N'2017-02-19',10000),
(5,6,N'1978-01-10',N'2018-02-19',13000),
(6,7,N'2013-01-10',N'2019-03-29',100400)
