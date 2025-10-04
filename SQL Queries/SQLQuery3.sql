--query to clean whitespace issues in the ReviewText Column

select
	ReviewID,
	CustomerID,
	ProductID,
	ReviewDate,
	Rating,
	REPLACE(ReviewText, '  ', ' ') as Review_Text
from
	dbo.customer_reviews;

