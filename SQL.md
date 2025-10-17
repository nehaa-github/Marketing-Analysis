**1)dim\_customer.sql**



-- sql stmt to join dim\_customer with dim\_gegraphy to enrich customer data with geographic information



select

&nbsp;	c.CustomerID,c.CustomerName,c.Email,c.Gender,g.GeographyID,g.Country,g.City

from

&nbsp;	dbo.customers as c -- Specifies the alias 'c' for the dim\_customers table

LEFT JOIN

--RIGHT JOIN

--INNER JOIN

--FULL OUTER JOIN

&nbsp;	dbo.geography as g -- Specifies the alias 'g' for the dim\_geography table

ON 

&nbsp;	c.GeographyID=g.GeographyID;





**2)dim\_products.sql**



--query to categorize products based on their price

select ProductID,ProductName,Price, 

&nbsp;	CASE

&nbsp;		when price < 50 then 'low'

&nbsp;		when price between 50 and 200 then 'medium'

&nbsp;		else 'high'

&nbsp;	end as ProductCategory

from dbo.products;



-- find duplicates

select ProductName,COUNT(Price)

from dbo.products

group by ProductName,Price

having COUNT(Price) > 1





**3)fact\_cutomers.sql**



--query to clean whitespace issues in the ReviewText Column



select

&nbsp;	ReviewID,CustomerID,ProductID,ReviewDate,Rating,

&nbsp;	REPLACE(ReviewText, '  ', ' ') as Review\_Text -- Cleans up the ReviewText by replacing double spaces with single spaces to ensure the text is more readable and standardized

from

&nbsp;	dbo.customer\_reviews;





**4)fact\_cutomer\_reviews.sql**



--query to clean whitespace issues in the ReviewText Column



select

&nbsp;	ReviewID,CustomerID,ProductID,ReviewDate,Rating,

&nbsp;	REPLACE(ReviewText, '  ', ' ') as Review\_Text -- Cleans up the ReviewText by replacing double spaces with single spaces to ensure the text is more readable and standardized

from

&nbsp;	dbo.customer\_reviews;





**5)fact\_engagement\_data.sql**



--query to clean and normalize the engagement\_data table

select 

&nbsp;	EngagementID,

&nbsp;	ContentID,

&nbsp;	CampaignID,

&nbsp;	ProductID,

&nbsp;	UPPER(REPLACE(ContentType, 'Socialmedia', 'Social Media')) As ContentType,

&nbsp;	LEFT(ViewsClicksCombined, CHARINDEX('-',ViewsClicksCombined) - 1) As Views, -- Extracts the Views part from the ViewsClicksCombined column by taking the substring before the '-' character

&nbsp;	RIGHT(ViewsClicksCombined, LEN(ViewsClicksCombined) - CHARINDEX('-', ViewsClicksCombined)) As Clicks,Likes, -- Extracts the Clicks part from the ViewsClicksCombined column by taking the substring after the '-' character



&nbsp;	FORMAT(CONVERT(DATE, EngagementDate), 'dd.MM.yyyy') As EngagementDate



from dbo.engagement\_data



where 

&nbsp;	ContentType != 'Newsletter'; -- Filters out rows where ContentType is 'Newsletter' as these are not relevant for our analysis





**6)fact\_customer\_journey.sql**



-- Common Table Expression (CTE) to identify and tag duplicate records

with DuplicateRecords as(

&nbsp;	select

&nbsp;		JourneyID,CustomerID, ProductID, VisitDate, Stage, Action, Duration,

&nbsp;		ROW\_NUMBER() OVER (PARTITION BY CustomerID, ProductID, VisitDate, Stage, Action

&nbsp;						-- ROW\_NUMBER() to assign a unique row number to each record within the partition defined above

&nbsp;						-- PARTITION BY groups the rows based on the specified columns that should be unique

&nbsp;		ORDER BY JourneyID -- ORDER BY defines how to order the rows within each partition (usually by a unique identifier like JourneyID)

&nbsp;		)AS row\_num -- This creates a new column 'row\_num' that numbers each row within its partition

&nbsp;	from dbo.customer\_journey

)

-- the above query becomes a temporary table where below 'select' query can be run on

-- Select all records from the CTE where row\_num > 1, which indicates duplicate entries. both above and below are to only verify there are some duplicate enteries or records

select \* from DuplicateRecords

--WHERE row\_num > 1  -- Filters out the first occurrence (row\_num = 1) and only shows the duplicates (row\_num > 1)

ORDER BY JourneyID





-- Outer query selects the final cleaned and standardized data

--below query will fix the issue-1. duplicates 2. null values in duration(through subquery)



select JourneyID,CustomerID, ProductID, VisitDate, Stage, Action, 

&nbsp;		COALESCE(Duration, avg\_duration) As Duration -- Replaces missing durations with the average duration for the corresponding date

from(

&nbsp;	-- Subquery to process and clean the data



&nbsp;	select JourneyID,CustomerID, ProductID, VisitDate, UPPER(Stage) AS Stage,Action,Duration,

&nbsp;	AVG(Duration) OVER (PARTITION BY VisitDate) As avg\_duration, -- Calculates the average duration for each date, using only numeric values

&nbsp;	ROW\_NUMBER() OVER (PARTITION BY CustomerID, ProductID, VisitDate, UPPER(Stage), Action -- Groups by these columns to identify duplicate records

&nbsp;	ORDER BY JourneyID -- Orders by JourneyID to keep the first occurrence of each duplicate

&nbsp;	) as row\_num -- Assigns a row number to each row within the partition to identify duplicates

&nbsp;	from dbo.customer\_journey

)as subquery -- Names the subquery for reference in the outer query

where row\_num = 1 -- and JourneyID=23 ; -- Keeps only the first occurrence of each duplicate group identified in the subquery

