IF EXISTS(select * from sys.databases where name='Cinema')
	DROP DATABASE Cinema
CREATE DATABASE Cinema

IF OBJECT_ID(N'dbo.Movies', N'U') IS NOT NULL  
   DROP TABLE [dbo].[Movies];  
GO
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
('Godfather','crime',1972,'Francis Ford Coppola',170,'USA','YES'),
(' The Shawshank Redemption','drama',1994,'Frank Darabont',142,'USA','YES'),
('Schindlers List','history',1993,'Steven Spielberg',195,'USA','YES'),
('Forrest Gump','comedy',1994,'Robert Zemeckis',142,'USA','YES'),
('12 Angry Men','crime',1957,'Sidney Lumet',96,'USA','NO'),
('Star Wars: Episode IV - A New Hope','Fantasy',1977,'George Lucas',121,'USA','YES'),
('The Silence of the Lambs','thriller',1991,'Jonathan Demme',118,'USA','YES'),
('Intouchables','comedy',2011,'Oliver Nakache',112,'France','NO'),
('La vita è bella','war',1997,'Roberto Benigni',116,'Italy','YES'),
('Fight Club','thriller',1999,'David Fincher',139,'USA','NO'),
('Joker','action',2019,'Todd Phillips',122,'USA','YES'),
('Django Unchained','western',2012,'Quentin Tarantino',165,'USA','YES'),
('Gran Torino','drama',2008,'Clint Eastwood',116,'USA','YES'),
('Good Will Hunting','drama',1997,'Gus Van Sant',124,'USA','YES'),
('Léon','thriller',1994,'Luc Besson',110,'France','NO'),
('The Good The Bad and The Ugly','western',1966,'Todd Phillips',179,'Italy','NO'),
('Inglourious Basterds','war',2009,'Quentin Tarantino',170,'USA','YES'),
('Avatar: The Way of Water','sci-fi',2022,'James Cameron',192,'USA','YES') 
