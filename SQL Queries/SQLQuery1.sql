select * from dbo.products;

--query to categorize products based on their price
select ProductID,ProductName,Price, 
	CASE
		when price < 50 then 'low'
		when price between 50 and 200 then 'medium'
		else 'high'
	end as ProductCategory
from dbo.products;

-- find duplicates
select ProductName,COUNT(Price)
from dbo.products
group by ProductName,Price
having COUNT(Price) > 1
