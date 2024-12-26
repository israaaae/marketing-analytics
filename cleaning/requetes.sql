--1 jointure left entre les 2 tables customers et geography 
select * from MarketingAnalytics.dbo.customers;
select * from MarketingAnalytics.dbo.geography;
select c.CustomerID, c.CustomerName, c.Email, c.Gender, c.Age, g.Country, g.City 
from MarketingAnalytics.dbo.customers as c left join MarketingAnalytics.dbo.geography as g
on c.GeographyID = g.GeographyID
-----------------------------------------------------
--2 catégoriser les produits en fonction de leur prix
select * FROM MarketingAnalytics.dbo.products;
select ProductID, ProductName, Price, --Category,
	case when Price <50 then 'low'
		 when Price BETWEEN 50 AND 200 then 'Medium'
		 else 'High'
	end as PriceCategory
from MarketingAnalytics.dbo.products;
-----------------------------------------------------
--3 nettoyer les problèmes d'espaces blancs dans la colonne ReviewText
select * from MarketingAnalytics.dbo.customer_reviews;
select ReviewID, CustomerID, ProductID, Rating, Replace(ReviewText, '  ',' ') as ReviewText from MarketingAnalytics.dbo.customer_reviews;
------------------------------------------------------
--4 nettoyer et normaliser la table engagement_data
select * from MarketingAnalytics.dbo.engagement_data;
select EngagementID, ContentID, CampaignID, ProductID, Likes, 
	   UPPER(REPLACE(ContentType,'Socialmedia', 'Social Media')) as ContentType,
	   LEFT(ViewsClicksCombined,CHARINDEX('-',ViewsClicksCombined)-1) as Views,
	   RIGHT(ViewsClicksCombined,LEN(ViewsClicksCombined)-CHARINDEX('-',ViewsClicksCombined)) as Clicks,
	   FORMAT(CONVERT(DATE, EngagementDate), 'dd.MM.yyyy') as EngagementDate 
from MarketingAnalytics.dbo.engagement_data
where ContentType != 'Newsletter';
-----------------------------------------------------
--5 identifier et étiqueter les enregistrements en double
select * from MarketingAnalytics.dbo.customer_journey;

with DuplicateRecords as (
	select JourneyID, CustomerID, ProductID, VisitDate, Stage, Action, Duration,
	ROW_NUMBER() over(
	partition by CustomerID, ProductID, VisitDate, Stage, Action
	order by JourneyID
	) as row_num
from MarketingAnalytics.dbo.customer_journey)

select * from DuplicateRecords where row_num > 1 order by JourneyID

select JourneyID,CustomerID,ProductID,VisitDate,Stage,Action, COALESCE(Duration, avg_duration) as Duration 
from (select JourneyID, CustomerID,ProductID,VisitDate,UPPER(Stage) AS Stage, Action,Duration,AVG(Duration) over (partition by VisitDate) as avg_duration, ROW_NUMBER() over (
                partition by CustomerID, ProductID, VisitDate, UPPER(Stage), Action order by JourneyID) as row_num 
        from MarketingAnalytics.dbo.customer_journey) as subquery where row_num = 1;
