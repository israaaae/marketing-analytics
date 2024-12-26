--1 jointure left entre les 2 tables customers et geography 
select * from MarketingAnalytics.dbo.customers;
--------------------------------------------------
select * from MarketingAnalytics.dbo.geography;
select c.CustomerID, c.CustomerName, c.Email, c.Gender, c.Age, g.Country, g.City 
from MarketingAnalytics.dbo.customers as c left join MarketingAnalytics.dbo.geography as g
on c.GeographyID = g.GeographyID

--2 
