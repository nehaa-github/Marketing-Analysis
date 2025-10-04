select * from dbo.products;

select * from dbo.geography;

-- sql stmt to join dim_customer with dim_gegraphy to enrich customer data with geographic information

select
	c.CustomerID,
	c.CustomerName,
	c.Email,
	c.Gender,
	g.GeographyID,
	g.Country,
	g.City
from
	dbo.customers as c -- Specifies the alias 'c' for the dim_customers table
LEFT JOIN
--RIGHT JOIN
--INNER JOIN
--FULL OUTER JOIN
	dbo.geography as g -- Specifies the alias 'g' for the dim_geography table
ON 
	c.GeographyID=g.GeographyID;