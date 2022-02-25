/* Here I changed the data type on some of my columns to decimal instead of float. */
alter table dbo.GameSales
alter column NA_Sales decimal(18,2);

alter table dbo.GameSales
alter column EU_Sales decimal(18,2);

alter table dbo.GameSales
alter column JP_Sales decimal(18,2);

alter table dbo.GameSales
alter column Other_Sales decimal(18,2);

alter table dbo.GameSales
alter column Global_Sales decimal(18,2);

/* This lets you view the entire table of video game sales data. */
select *
from GameSales
order by ID ASC
;

/* This lets you view the entire table of video game critic scores data. */
select *
from CriticRatings 
order by ID ASC
;

/* This shows the units of video games sold in millions, globally, by year. You can consider this to be the size of the video game market each year, historically.*/ 
select SUM(Global_Sales) as Units_Sold, Year_of_Release
from GameSales
Group By Year_of_Release
Order By Year_of_Release DESC
;

/* This shows the total units of video games sold from 1980 to 2020, in millions, by region. */
select Sum(NA_Sales) AS North_America, Sum(EU_Sales) as European_Union, Sum(JP_Sales) as Japan, Sum(Other_Sales) as Other
from GameSales
;

/* This shows the historical total units of video games sold (in millions) in North America from 1996 to 2020, by publisher. */
select sum(NA_Sales) as North_American_Sales, Publisher
from GameSales
Where (Year_of_Release > 1995)
Group By Publisher
Order By sum(NA_Sales) DESC
;

/*This shows the historical global units sold in millions, by age level rating. In other words, it shows which age ratings sell the best. */
select sum(Global_Sales) as Global_Sales, isnull(Rating, 'Unrated') as Age_Rating
from GameSales
Group By Rating
Order By round(sum(Global_Sales), 2) DESC
;

/*This shows the historical amount of video game units sold (in millions rounded) in North America, by genre. In other words, it shows which genre sells the best. */
select round(sum(NA_Sales), 0) as North_American_Sales, isnull(Genre, 'N/A') as Genre
from GameSales
Group by Genre
order by round(sum(NA_Sales), 0) DESC
;

/*This shows the historical units of games sold (in millions rounded), by gaming platform. In other words, it shows us which platform is most popular.*/
select PLATFORM, cast(sum(NA_Sales) as int) as NA_Sales
from GameSales
Group By Platform 
Order by NA_Sales DESC
;

/* Here I perfrom an inner join to combine the data from our two tables into one table.*/
select *
from GameSales
INNER JOIN CriticRatings
ON  GameSales.ID = CriticRatings.ID 
Order by GameSales.ID ASC
;

/*Here I create a temporary table with some of the data. */
drop table if exists #temp_SalesAndScores
create table #temp_SalesAndScores (
ID int,
Name varchar (200),
NA_Sales decimal(6,2),
Global_Sales decimal(6,2),
Critic_Score decimal (6,2),
User_Score decimal (6,2),
Publisher varchar(200)
)
;

/* Here I use a join to put my desired data into my temporary table. */
insert into #temp_SalesAndScores
select sales.ID, Name, NA_Sales, Global_Sales, Critic_Score, User_Score, Publisher
from master.dbo.GameSales sales
join master.dbo.CriticRatings ratings
on sales.ID = ratings.ID
;

/* This query shows only the games that have a critic rating. They are ordered by game ID. */
select Distinct *
from #temp_SalesAndScores
where Critic_Score is not null
order by ID
;

/* Here I perform a sub-query to show the average critic score of the games from each Pulbishing company. Only publishers who have published more than 10 games are shown. */ 
select cast(avg(Critic_Score) as int) AS Avg_Critic_Score, count(Name) as Number_of_Games_Published, Publisher
from #temp_SalesAndScores
group by Publisher
having avg(Critic_Score) is not null
and
count(Name) > 10
order by avg(Critic_Score) DESC
;

