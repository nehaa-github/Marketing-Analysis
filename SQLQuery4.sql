
select * from dbo.engagement_data;

--query to clean and normalize the engagement_data table

select 
	EngagementID,
	ContentID,
	CampaignID,
	ProductID,
	UPPER(REPLACE(ContentType, 'Socialmedia', 'Social Media')) As ContentType,
	LEFT(ViewsClicksCombined, CHARINDEX('-',ViewsClicksCombined) - 1) As Views, -- Extracts the Views part from the ViewsClicksCombined column by taking the substring before the '-' character
	RIGHT(ViewsClicksCombined, LEN(ViewsClicksCombined) - CHARINDEX('-', ViewsClicksCombined)) As Clicks,Likes, -- Extracts the Clicks part from the ViewsClicksCombined column by taking the substring after the '-' character

	FORMAT(CONVERT(DATE, EngagementDate), 'dd.MM.yyyy') As EngagementDate

from dbo.engagement_data

where 
	ContentType != 'Newsletter'; -- Filters out rows where ContentType is 'Newsletter' as these are not relevant for our analysis