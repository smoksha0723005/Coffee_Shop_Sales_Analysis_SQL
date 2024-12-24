create database coffee_shop_sales_db;

-- VIEWING THE DATA --
select *
from coffee_shop_sales;

-- CHECKING THE DATA TYPE--
describe coffee_shop_sales;

-- CHANGING DATA TYPE FROM TEXT TO DATE FOR transaction_date--
update coffee_shop_sales
set transaction_date = str_to_date(transaction_date, '%d-%m-%Y');

alter table coffee_shop_sales
modify column transaction_date date;

describe coffee_shop_sales;

-- CHANGING DATA TYPE FROM TEXT TO TIME FOR transaction_time --
update coffee_shop_sales
set transaction_time = str_to_date(transaction_time, '%H:%i:%s');

alter table coffee_shop_sales
modify column transaction_time time;

describe coffee_shop_sales;

-- CHANGING COLUMN NAME OF transaction_id --
alter table coffee_shop_sales
change ï»¿transaction_id transaction_id int;

-- ---------------------------------------KPI REQUIREMENTS---------------------------------
-- TOTAL SALES ANALYSIS
-- 1. CALCULATING SALES FOR EACH MONTH
select monthname(transaction_date) as sales_month, 
round(sum(unit_price * transaction_qty),2) as total_sales
from coffee_shop_sales
group by monthname(transaction_date)
order by total_sales desc;

-- 2. CALCULATE THE DIFFERENCE IN SALES BETWEEN CURRENT MONTH AND THE PREVIOUS MONTH
-- ALSO SHOWS THE MONTH-OVER-MONTH GROWTH PERCENTAGE
select month(transaction_date) as sales_month,
	   round(sum(unit_price * transaction_qty), 2) as total_sales,
       round(
       ((sum(unit_price * transaction_qty) - lag(sum(unit_price * transaction_qty),1) 
       over(order by month(transaction_date))) / 
       lag(sum(unit_price * transaction_qty),1) over(order by month(transaction_date))) * 100, 
       2) as mom_increase_percentage -- ((current months sale - previous months sales) / previous months sales)
from coffee_shop_sales
-- where month(transaction_date) in (4,5)
group by month(transaction_date)
order by month(transaction_date);
       
-- TOTAL ORDER ANALYSIS
-- Q1.CALCULATE TOTAL ORDERS BY MONTHS
select monthname(transaction_date), count(*) as total_orders
from coffee_shop_sales
group by monthname(transaction_date)
order by total_orders desc;

-- Q2. CALCULATE THE DIFFERENCE IN ORDER BETWEEN CURRENT MONTH AND THE PREVIOUS MONTH
-- ALSO SHOWS THE MONTH-OVER-MONTH GROWTH PERCENTAGE
select month(transaction_date) as sales_month,
	   round(count(transaction_id), 2) as total_orders,
       round(
       ((count(transaction_id) - lag(count(transaction_id),1) 
       over(order by month(transaction_date))) / 
       lag(count(transaction_id),1) over(order by month(transaction_date))) * 100, 
       2) as mom_increase_percentage -- ((current months sale - previous months sales) / previous months sales)
from coffee_shop_sales
-- where month(transaction_date) in (4,5)
group by month(transaction_date)
order by month(transaction_date);

-- QUANTITY ANALYSIS
-- Q1. TOTAL QUANTITY SOLD
select monthname(transaction_date), sum(transaction_qty) as total_quanity_sold
from coffee_shop_sales
group by monthname(transaction_date)
order by total_quanity_sold desc;

-- Q2. CALCULATE THE DIFFERENCE IN QUANTITY SOLD BETWEEN CURRENT MONTH AND THE PREVIOUS MONTH
-- ALSO SHOWS THE MONTH-OVER-MONTH GROWTH PERCENTAGE
select month(transaction_date) as sales_month,
	   round(sum(transaction_qty), 2) as total_orders,
       round(
       ((sum(transaction_qty) - lag(sum(transaction_qty),1) 
       over(order by month(transaction_date))) / 
       lag(sum(transaction_qty),1) over(order by month(transaction_date))) * 100, 
       2) as mom_increase_percentage -- ((current months sale - previous months sales) / previous months sales)
from coffee_shop_sales
-- where month(transaction_date) in (4,5)
group by month(transaction_date)
order by month(transaction_date);

-- ------------------------------------------CHART REQUIREMENTS----------------------------
--  Q1. DISPLAYING TOTAL SALES, ORDERS, AND QUANTITY SOLD 
select concat(round(sum(unit_price * transaction_qty)/1000,1), 'K') as total_sales,
		concat(round(sum(transaction_qty)/1000,1), "K") as total_quantity_sold,
        concat(round(count(transaction_id)/1000,1), "K") as total_orders
from coffee_shop_sales;

-- Q2. SALES MADE BY THE SHOP ON WEEKENDS AND WEEKDAYS
-- SUN = 1 ....... SAT = 7

select 
	case when dayofweek(transaction_date) in (1,7) then 'weekends'
    else 'weekdays'
    end as day_type,
    concat(round(sum(unit_price * transaction_qty)/1000, 2), "K") as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by day_type
order by total_sales desc;

-- Q3. SALES ANALYSIS BASED ON STORE LOCATION
select store_location,
		concat(round(sum(unit_price * transaction_qty)/1000,2), "K") as total_sales
from coffee_shop_sales
-- where month(transaction_date) = 5
group by store_location
order by total_sales desc;

-- Q4. AVERAGE SALES MADE PER DAY IN MAY
select avg(total_sales) as avg_sales
from (
	select sum(unit_price * transaction_qty) as total_sales
	from coffee_shop_sales
	where month(transaction_date) = 5
	group by transaction_date
    ) as internal_query;

-- Q5. DAILY SALES MADE IN MAY
select day(transaction_date) as day_of_month,
		concat(round(sum(unit_price * transaction_qty)/1000,2), 'K') as total_sales 
from coffee_shop_sales
where month(transaction_date) = 5
group by transaction_date;

-- Q6. COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”
select day_of_month,
		case 
			when total_sales > avg_sales then 'Above Average'
			when total_sales < avg_sales then 'Below Average'
            else 'Average'
            end as sales_status,
					total_sales
from(
	select day(transaction_date) as day_of_month,
		concat(round(sum(unit_price * transaction_qty)/1000,2), 'K') as total_sales,
        concat(round(avg(sum(unit_price * transaction_qty)/1000) over(), 2), 'K') as avg_sales -- calculates avrage sales for the entire month and you get one average number
	from coffee_shop_sales
	where month(transaction_date) = 5 -- filter for May
	group by day(transaction_date)
) as sales_data
order by day_of_month;

-- Q7. SALES WRT PRODUCT CATEGORY
select product_category,
	   round(sum(unit_price * transaction_qty),2) as total_sales
from coffee_shop_sales
group by product_category
order by total_sales desc;

-- Q8. TOP 10 PRODUCTS
select product_type,
       round(sum(unit_price * transaction_qty),2) as total_sales
from coffee_shop_sales
group by product_type
order by total_sales desc
limit 10;

-- Q9. SALES BY DAY/HOUR
select 
	  round(sum(unit_price * transaction_qty),2) as total_sales,
      sum(transaction_qty) as total_quantity,
      count(*) 
from coffee_shop_sales
where month(transaction_date) = 5 
	  and dayofweek(transaction_date) = 2 -- monday
      and hour(transaction_time) = 8; -- hour number 8

-- Q10. SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
select 
	 case
		WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM coffee_shop_sales
WHERE  MONTH(transaction_date) = 5
GROUP BY Day_of_Week;

-- Q11. TO GET SALES FOR ALL HOURS FOR MONTH OF MAY
SELECT 
    HOUR(transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY Hour_of_Day
ORDER BY Hour_of_Day;

    



