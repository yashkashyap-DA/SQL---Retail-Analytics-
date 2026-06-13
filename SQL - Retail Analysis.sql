-- ALL THREE TABLES CLEANED.
use my_schema;
select * from customer_profiles;
select * from product_inventory;
select * from sales_transaction;

-- Product perfromance variability
-- Which product sells the most
select productid, sum(quantitypurchased) as totalunitssold,
sum(price * quantitypurchased) as totalsales
from sales_transaction
group by productid
order by totalsales desc
limit 5;

-- how oftern do customer buy
select CustomerID, count(*) as numberOfTransactions
from sales_transaction
group by CustomerID
order by numberOfTransactions desc;

-- which categories perform best
select pi.Category, sum(st.quantitypurchased) as totalunitssold,
sum(st.price * st.quantitypurchased) as totalsales
from sales_transaction st
join product_inventory pi on st.productID = pi.productID
group by pi.Category
order by totalsales desc;


-- high sales products
select productid,
sum(price * quantitypurchased) as total_sales
from sales_transaction
group by productid
order by total_sales desc;


-- low sales product
select productid,
sum(quantitypurchased) as totalunitssold
from sales_transaction
group by productid
having totalunitssold > 0
order by totalunitssold asc;

-- daily sales trend
SELECT 
cast(transactiondate as date) as datetransaction,
SUM(price * quantitypurchased) AS total_sales,
sum(quantitypurchased) as totalunitssold,
COUNT(*) AS total_transactions
FROM sales_transaction
GROUP BY datetransaction
ORDER BY datetransaction desc;


-- Month-on-month growth
with mom as(
select month(Transactiondate) as month, round(sum(price*quantitypurchased),2)as totalsale
from sales_transaction
group by month(Transactiondate))
SELECT month, totalsale,
lag(TotalSale) over (order by Month) as PreviousMonthSales,
ROUND(((totalsale - LAG(totalsale) OVER (ORDER BY month)) 
/LAG(totalsale) OVER (ORDER BY month)) * 100, 2) AS mom_growthperc
FROM mom
ORDER BY month;


-- customer level analysis
--  high frequency, high spend customer
select customerID, sum(quantitypurchased) as numberOftransaction,
sum(quantitypurchased*price) as totalSales
from sales_transaction
group by customerID
having numberOftransaction > 10 and totalSales > 1000
order by totalSales desc;

-- Occasional customer

select CustomerID, sum(quantityPurchased) as No_of_purchase,
sum(quantitypurchased*price) as totalSales
from Sales_transaction
group by customerID
having no_of_purchase<5;

-- Loyalty duration
select
customerID,
min(transactionDate) as FirstPurchaseDate,
max(transactionDate) as LastPurchaseDate,
datediff(max(transactionDate), min(transactionDate)) as LoyaltyDuration
from sales_transaction
group by customerID
having LoyaltyDuration > 0
order by LoyaltyDuration desc;

-- repeat purchase patterns
select CustomerId,
ProductID,
count(*) as numberOfTransactions
from sales_transaction
group by CustomerId, ProductID
having numberOfTransactions > 1
order by CustomerId;

-- customer segementation by quantity purchased
-- quantiy > 30 high
-- 11 30 medium 
-- 1to 10 low 

select category , 
case 
when sum(QuantityPurchased) <= 0 then 'No orders'
when sum(QuantityPurchased) between 1 and 10  then 'Low'
when sum(QuantityPurchased) between 10 and 30  then 'Mid'
else 'High'
end as Customer_segement 
from sales_transaction s 
join product_inventory p 
on s.productid = p.productid
group by category;


select customerid, sum(quantitypurchased) as totalquantity, 
case when sum(quantitypurchased) > 30 then 'high' 
when sum(quantitypurchased) between 11 and 30 then 'medium' 
else 'low' end as customersegmentation 
from sales_transaction group by customerid order by totalquantity desc;

with TotalPurchase as(
select customerID, count(*) as Nofpuchase
from Sales_transaction
group by customerID
having Nofpuchase>1
order by Nofpuchase desc)
select CustomerID, case
when nofPuchase >30 then 'High'
when nofPuchase between 11 and 30 then 'Medium'
else 'Low' end as Category
from TotalPurchase;

select CustomerID, sum(quantitypurchased) as total_qty_purchased, 
case when sum(quantitypurchased) > 30 then 'High'
	when sum(quantitypurchased) between 11 and 30 then 'medium'
    else 'low'
    end as category
from sales_transaction
group by CustomerID
order by total_qty_purchased desc;