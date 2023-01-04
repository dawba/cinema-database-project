DROP DATABASE Cinema
CREATE DATABASE Cinema
GO
USE Cinema 

DROP TABLE Movies
CREATE TABLE [dbo].[Movies]
(
  [movieID] INT  NOT NULL IDENTITY(1,1) PRIMARY KEY,
  [movieTitle] VARCHAR(100) NOT NULL, 
  [genre] VARCHAR(100) NOT NULL, 
  [releaseYear] INT NOT NULL, 
  [director] VARCHAR(100) NOT NULL, 
  [length] INT NOT NULL,
  [country] VARCHAR(100) NOT NULL,
  [onDisplay] VARCHAR(3) NOT NULL
)

INSERT INTO Movies (movieTitle,genre,releaseYear,director,length,country,onDisplay)VALUES
('Ojciec Chrzestny','crime',1972,'Francis Ford Coppola',170,'USA','YES'),
('Ojciec Chrzestny','crime',1972,'Francis Ford Coppola',170,'USA','YES'),
('Ojciec Chrzestny','crime',1972,'Francis Ford Coppola',170,'USA','YES'),
('Ojciec Chrzestny','crime',1972,'Francis Ford Coppola',170,'USA','YES'),
('Ojciec Chrzestny','crime',1972,'Francis Ford Coppola',170,'USA','YES'),
('Ojciec Chrzestny','crime',1972,'Francis Ford Coppola',170,'USA','YES'),
('Ojciec Chrzestny','crime',1972,'Francis Ford Coppola',170,'USA','YES')