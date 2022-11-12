SELECT count(orderid), count(sku), customerid FROM `totemic-client-362800.123.pet_retail` 
group by CustomerID
having count(sku) >1
LIMIT 1000;


--- delete orderid null value ----
DELETE FROM `totemic-client-362800.123.pet_retail` WHERE OrderID IS NULL;


----avg lifespan---
-- the avg days for customers to purchase again --
select avg(span)
from (
  select CustomerID
        ,date_diff(max(OrderTime)
        , min(OrderTime)
        , day) as span
  from `123.pet_retail`
  group by CustomerID);
-- in average it took the customers 53 days to purchase again 


---repurchase rate----
select 1*(count(repur)/ (select count('Orderid') order_num 
                          from `123.pet_retail`)) repur_rate
from (select count('Orderid') repur
      from `123.pet_retail`
      group by CustomerID
      having repur >1);
-- RESULT: The repurchase rate is low, approximately 30%. onyl 416/1406 customers have purchased again. 

-- create views of repurchased customer----
--create view `123.rep_cus` as 
select *,
      date_trunc(min_date, month) month
from (select CustomerID
      ,max(OrderTime) max_date
      ,min(ordertime) min_date
      ,count('Orderid') repur_count
from `123.pet_retail`
group by 1
having repur_count >1);

--- repurchase inteval----
-- time span of customers who repurchased---
select avg(span)
from (select CustomerID
      ,date_diff(max_date, min_date, day) as span
      from `123.rep_cus`);
-- RESULT: for customer who repurchased, it took them at average 93 days to repurchase

-- retentnion rate: customer who came back in 30 days
-- (number of customers repurchased in 30 days from the earliest purchase day / total num of customer in that month)
--create view `123.retention_rate` as  
select date_trunc(OrderTime, month) month, 
      (select count(customerid) 
        from (select *
              ,date_diff(max_date, min_date, day) span
              from `123.rep_cus`
              group by 1,2,3,4,5
              having date_diff(max_date, min_date, day)<=30))
        / count(customerid) retention_rate
from `123.pet_retail`
group by 1
order by 1;
-- RESULT: No seasonal difference regarding retention rate. March has the lowest retention rate (29%) while April resulted the highest (38%). 
select CustomerID, date_trunc(min_date, month) month
from `123.rep_cus`;


