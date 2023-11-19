create database mobile_manufacturer;
use mobile_manufacturer;


--all the states in which we have customers who have bought cellphones from 2005 till today.

Select T3.State as States,count(T1.IDCustomer) AS No_of_Customers,T2.Year as Years
from DIM_CUSTOMER T1
Inner join FACT_TRANSACTIONS T4 on T1.IDCustomer = T4.IDCustomer
Inner join DIM_DATE T2 on T4.Date = T2.Date
inner join DIM_LOCATION T3 on T3.IdLocation = T4.IDLocation
where year >= 2005
group by T3.State,T2.Year

--state in the US is buyingthe most 'Samsung' cell phones
select * from [dbo].[DIM_LOCATION]
select * from [dbo].[FACT_TRANSACTIONS]
select * from [dbo].[DIM_MODEL]
select * from [dbo].[DIM_MANUFACTURER]

Select Top 1 T1.Country,T1.State as States,T4.Manufacturer_Name,Count(Model_Name) as countsofmobile
from DIM_LOCATION T1
inner join FACT_TRANSACTIONS T2 on T1.IDLocation = T2.IDLocation
inner join DIM_MODEL T3 on T2.IDModel = T3.IDModel
inner join DIM_MANUFACTURER T4 on T3.IDManufacturer = T4.IDManufacturer
where Country = 'US' And Manufacturer_Name = 'Samsung'
Group by T1.State,T4.Manufacturer_Name,T1.Country
order by Count(Model_Name) Desc


--the number of transactions for each model per zip code per state.


Select T1.ZipCode,T1.State as States, T3.Model_Name,count(*) as Total_trans
from DIM_LOCATION T1
inner join FACT_TRANSACTIONS T2 on T1.IdLocation = T2.IdLocation
inner join DIM_MODEL T3 on T2.IDModel = T3.IDModel
group by T1.ZipCode,T1.State, T3.Model_Name



--the cheapest cellphone

Select top 1 Model_Name,Unit_price
from DIM_MODEL
Order by Unit_price 

--the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.


Select T1.Model_Name,T3.Manufacturer_Name,Cast(Avg(totalprice) as int) as Avg_price,sum(Quantity) as TotalQuantity
from DIM_MODEL T1
Inner join FACT_TRANSACTIONS T2 on T1.IDModel = T2.IDModel
inner join DIM_MANUFACTURER T3 on T3.IDManufacturer = T1.IDManufacturer
where Manufacturer_Name in  
    (select top 5 T3.Manufacturer_Name
    from DIM_MODEL T1
    Inner join FACT_TRANSACTIONS T2 on T1.IDModel = T2.IDModel
    inner join DIM_MANUFACTURER T3 on T3.IDManufacturer = T1.IDManufacturer
    group by T3.Manufacturer_Name
    order by sum(TotalPrice) Desc)
group by T1.Model_Name,T3.Manufacturer_Name
Order by Avg_price desc



--the names of the customers and the average amount spent in 2009,where the average is higher than 500

Select T1.Customer_Name,T2.Year as Years,avg(Totalprice) as AvgPrice
from DIM_CUSTOMER T1
inner join FACT_TRANSACTIONS T3 on T1.IDCustomer = T3.IDCustomer
inner join DIM_DATE T2 on T2.DATE = T3.date
where Year = 2009
group by T1.Customer_Name,T2.Year
having avg(Totalprice) > 500



--if there is any model that was in the top 5 in terms of quantity,simultaneously in 2008, 2009 and 2010  

Select * from (
Select Top 5 IDModel from  FACT_TRANSACTIONS
where Year(Date)= 2008
group by IDModel,Year(Date)
order by sum(Quantity) desc ) as A
intersect
Select * from (
Select Top 5 IDModel from  FACT_TRANSACTIONS
where Year(Date)= 2009
group by IDModel,Year(Date)
order by sum(Quantity) desc ) As B
intersect
Select * from (
Select Top 5 IDModel from  FACT_TRANSACTIONS
where Year(Date)= 2010
group by IDModel,Year(Date)
order by sum(Quantity) desc) as C



--the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010

Select * from (
select top 1 * from (select top 2 T1.Manufacturer_Name,sum(T3.TotalPrice) as Totalsales,Year(T3.Date) as years
from FACT_TRANSACTIONS T3
inner join DIM_MODEL T2 on T2.IDModel = T3.IDModel
inner join DIM_MANUFACTURER T1 on T1. IDManufacturer = T2. IDManufacturer
where year(T3.Date) = 2009
group by T1.Manufacturer_Name,Year(T3.Date)
order by sum(T3.TotalPrice) desc) as A
order by Totalsales ) as B
union
Select * from (
select top 1 * from (select top 2 T1.Manufacturer_Name,sum(T3.TotalPrice) as Totalsales,Year(T3.Date) as years
from FACT_TRANSACTIONS T3
inner join DIM_MODEL T2 on T2.IDModel = T3.IDModel
inner join DIM_MANUFACTURER T1 on T1. IDManufacturer = T2. IDManufacturer
where year(T3.Date) = 2010
group by T1.Manufacturer_Name,Year(T3.Date)
order by sum(T3.TotalPrice) desc) as A
order by Totalsales ) as B


--Show the manufacturers that sold cellphones in 2010 but did not in 2009.

select * from (select T1.Manufacturer_Name
from FACT_TRANSACTIONS T3
inner join DIM_MODEL T2 on T2.IDModel = T3.IDModel
inner join DIM_MANUFACTURER T1 on T1. IDManufacturer = T2. IDManufacturer
where year(T3.Date) = 2010
group by T1.Manufacturer_Name) as A
Except
select * from(select T1.Manufacturer_Name
from FACT_TRANSACTIONS T3
inner join DIM_MODEL T2 on T2.IDModel = T3.IDModel
inner join DIM_MANUFACTURER T1 on T1. IDManufacturer = T2. IDManufacturer
where year(T3.Date) = 2009
group by T1.Manufacturer_Name) as B



--top 100 customers and their average spend, average quantity by each year.

select * from [dbo].[DIM_CUSTOMER]
select * from [dbo].[FACT_TRANSACTIONS]

select top 10 IDCustomer from FACT_TRANSACTIONS
group by IDCustomer
order by sum(TotalPrice) desc

select *, ((avgamt - lag_price)/lag_price) as percentage_changes from (
select *, lag(avgamt,1) over(partition by IDCustomer order by years) as lag_price from
(
select IDCustomer,avg(TotalPrice) as avgamt, sum(Quantity) as qty ,year(Date) as years
from FACT_TRANSACTIONS
where IDCustomer in(select top 10 IDCustomer from FACT_TRANSACTIONS
   group by IDCustomer
   order by sum(TotalPrice) desc)
Group by IDCustomer, year(date)
)As A
) As B


