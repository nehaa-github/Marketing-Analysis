select * from dbo.customer_journey;


-- Common Table Expression (CTE) to identify and tag duplicate records
with DuplicateRecords as(
	select
		JourneyID,CustomerID, ProductID, VisitDate, Stage, Action, Duration,
		ROW_NUMBER() OVER (PARTITION BY CustomerID, ProductID, VisitDate, Stage, Action
						-- ROW_NUMBER() to assign a unique row number to each record within the partition defined above
						-- PARTITION BY groups the rows based on the specified columns that should be unique
		ORDER BY JourneyID -- ORDER BY defines how to order the rows within each partition (usually by a unique identifier like JourneyID)
		)AS row_num -- This creates a new column 'row_num' that numbers each row within its partition
	from dbo.customer_journey
)
-- the above query becomes a temporary table where below 'select' query can be run on
-- Select all records from the CTE where row_num > 1, which indicates duplicate entries. both above and below are to only verify there are some duplicate enteries or records
select * from DuplicateRecords
--WHERE row_num > 1  -- Filters out the first occurrence (row_num = 1) and only shows the duplicates (row_num > 1)
ORDER BY JourneyID


-- Outer query selects the final cleaned and standardized data
--below query will fix the issue-1. duplicates 2. null values in duration(through subquery)

select JourneyID,CustomerID, ProductID, VisitDate, Stage, Action, 
		COALESCE(Duration, avg_duration) As Duration -- Replaces missing durations with the average duration for the corresponding date
from(
	-- Subquery to process and clean the data

	select JourneyID,CustomerID, ProductID, VisitDate, UPPER(Stage) AS Stage,Action,Duration,
	AVG(Duration) OVER (PARTITION BY VisitDate) As avg_duration, -- Calculates the average duration for each date, using only numeric values
	ROW_NUMBER() OVER (PARTITION BY CustomerID, ProductID, VisitDate, UPPER(Stage), Action -- Groups by these columns to identify duplicate records
	ORDER BY JourneyID -- Orders by JourneyID to keep the first occurrence of each duplicate
	) as row_num -- Assigns a row number to each row within the partition to identify duplicates
	from dbo.customer_journey
)as subquery -- Names the subquery for reference in the outer query
where row_num = 1 -- and JourneyID=23 ; -- Keeps only the first occurrence of each duplicate group identified in the subquery

