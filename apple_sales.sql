
-- APAN 5310: SQL & RELATIONAL DATABASES

   -------------------------------------------------------------------------
   --                                                                     --
   --                            HONOR CODE                               --
   --                                                                     --
   --  I affirm that I will not plagiarize, use unauthorized materials,   --
   --  or give or receive illegitimate help on assignments, papers, or    --
   --  examinations. I will also uphold equity and honesty in the         --
   --  evaluation of my work and the work of others. I do so to sustain   --
   --  a community built around this Code of Honor.                       --
   --                                                                     --
   -------------------------------------------------------------------------

/*
 *    You are responsible for submitting your own, original work. We are
 *    obligated to report incidents of academic dishonesty as per the
 *    Student Conduct and Community Standards.
 */


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------


-- HOMEWORK ASSIGNMENT 3

/*
 *  NOTES:
 *
 *    - For all SQL statements, enter your answers between the START and END tags 
 *      for each question, as shown in the example. Do not alter this template 
 *      file in any other way other than adding your answers. Do not delete the
 *      START/END tags. The .sql file you submit will be validated before
 *      grading and will not be graded if it fails validation due to any
 *      alteration of the commented sections.
 *
 *    - Our course is using PostgreSQL. We will grade your assignments in PostgreSQL.
 *      You risk losing points if you prepare your SQL queries for a different
 *      database system (MySQL, MS SQL Server, SQLIte, Oracle, etc).
 *
 *    - The source database 'apple' is provided to you. If you have any issues 
 *      accessing this database, please contact Professor Yi 
 *      as soon as possible.
 *
 *    - Make sure you test each one of your answers. If a query returns an
 *      error it will earn no points.
 *
 *    - Each question specifies the exact columns requested in the output. Any more
 *      or any less columns will result in less than full score for the question.
 *
 *    - You are free to use JOINS and any other SQL logic to solve these problems.
 *
 *    - You will receive full credit for each problem only if the minimum number
 *      of tables are joined to solve the problem.
 *
 */

-------------------------------------------------------------------------------

/*
 * EXAMPLE
 * -------
 *
 * Provide the SQL statement that returns all columns and rows from
 * a table named "tbl1".
 *
 */

-- START EXAMPLE --

SELECT * FROM tbl1;

-- END EXAMPLE --

-------------------------------------------------------------------------------

/*
 * QUESTION 1 (10 points)
 * --------------------
 *
 * Provide the SQL statement that returns all the customers from the 
 *   custs table who have not purchased anything during the 
 *   4th quarter of 2021.
 * Label the columns: cust_name, cust_email, cust_city, cust_state
 * Order by cust_state (A to Z) and then cust_name (A to Z).
 *
 */

-- START ANSWER --
select  cust_name
		, email cust_email
		, city cust_city
		, st cust_state
from custs left join (select cust_id
						from orders o
						where date_part('qtr', ord_dt) = 4) o 
			using (cust_id)
where o.cust_id is null -- outer left join 
order by cust_state, cust_name;
-- END ANSWER --

-------------------------------------------------------------------------------

/*
 * QUESTION 2 (10 points)
 * --------------------
 *
 * Provide the SQL statement that returns all the brick and mortar Apple stores
 *   in the states of CA, TX, FL, and NY along with the number of items purchased
 *   by male customers under the age of 30 (during day of purchase).
 * Label the columns: store_name, store_city, store_state, items_purchased
 * Order by items_purchased (hi to lo) and then store_state (A to Z).
 *
 */

-- START ANSWER --
select * 
from (select store_name, s.city store_city, s.st store_state, sum(qty) items_purchased
from stores s join orders o using (store_id)
join custs c using (cust_id)
join order_items using (ord_id)
join prods using (prod_id)
where c.gender = 'm'
and round(date_part('year', age(o.ord_dt, c.dob))::numeric, 2)  < 30
group by 1,2,3)a
where store_state in ('CA', 'TX', 'FL','NY')
order by items_purchased desc, store_state;

-- END ANSWER --

-------------------------------------------------------------------------------

/*
 * QUESTION 3 (15 points)
 * --------------------
 *
 * Provide the SQL statement that returns the geniuses 
 *   who assisted on more orders than the average
 *   number of orders assisted by all geniuses.
 * Label the columns: genius_name, store_name, num_orders
 * Order by num_orders (hi to lo) and then genius_name (A to Z).
 *
 */

-- START ANSWER --

select genius_name
	,store_name
	, count(ord_id) num_orders -- count(ord_id)
from geniuses g join stores  using (store_id) 
				join orders  using (genius_id)
group by 1, 2
having count(ord_id) > (select avg(n) 
					from (select genius_id, count(ord_id) n -- n is the count of orders by genius
							from geniuses g -- can we use sum all orders/num genius
							join orders o using (genius_id) 
							group by 1)a)
order by 3 desc, 1;

-- END ANSWER --

-------------------------------------------------------------------------------

/*
 * QUESTION 4 (15 points)
 * --------------------
 *
 * Provide the SQL statement that returns the 'price per GB' for
 *   certain MacBook products.
 * 
 *   price_per_gb = price / # of GB in hd_storage
 * 
 * Include only MacBooks with less than 1TB of storage space.
 * Include only MacBooks purchased more than 25 times
 *   on a weekday (Mon thru Fri).
 * Label the columns: prod_grp, chip, disp_size, hd_storage, 
 *                    memory, price_per_gb
 * Order by price_per_gb (hi to lo).
 * 
 */

-- START ANSWER --
select prod_grp
		, chip
		, disp_size
		,hd_storage
		,memory
		,price / gb price_per_gb
from (select prod_grp
			, chip
			, disp_size
			,hd_storage
			,memory
			, cast(split_part(memory, 'G', 1) as integer) gb
			, avg(p.price) price
			,  count(oi.ord_id) order_times  
		from prods p join order_items oi using (prod_id)
					join orders o using (ord_id)
		where prod_grp like ('MacBook%')
			and hd_storage like ('%GB')
			and date_part('dow', ord_dt) not in (0,6) 
		group by 1,2,3,4,5) a
where order_times >25
order by 5 desc;

-- END ANSWER --

-------------------------------------------------------------------------------

/*
 * QUESTION 5 (25 points)
 * --------------------
 *
 * Provide the SQL statement that returns the dollar amount of iPads purchased
 *   for each full week in October 2021. 
 * There were four full weeks during the month:
 *    Week1: 10/03 - 10/09 39
 *    Week2: 10/10 - 10/16 40
 *    Week3: 10/17 - 10/23 41
 *    Week4: 10/24 - 10/30 42
 * Exclude the iPad mini.
 * Label the columns: week, amt_ipads
 * The values in the week column must be 'Week1', 'Week2', 'Week3', and 'Week4'.
 * Order by week (lo to hi).
 *
 */

-- START ANSWER --

select  'Week' || ((date_part('week',ord_dt+1)::int) % 39) weeks, sum(qty*price) amt_ipads
from prods join order_items oi using (prod_id)
			join orders using (ord_id)
where prod_cat = 'iPad'
	and prod_grp != 'iPad mini'
	and  date_part('month', ord_dt) = 10 
	and date_part('week',ord_dt+1)::int % 39 between 1 and 4
group by 1;



-- END ANSWER --

-------------------------------------------------------------------------------

/*
 * QUESTION 6 (25 points)
 * --------------------
 *
 * As an employee of Apple, you are asked to find all customers who fit
 *   every following criteria:
 *   - purchased at least $1,000 of any product during November 2021
 *   - purchased at least one Apple Watch of any kind
 *   - total $ spent on Apple Watches / total $ spent on everything > 0.5
 * Label the columns: cust_name, email, watch_sales
 * Order by watch_sales (hi to lo) and then cust_name (A to Z).
 *
 */

-- START ANSWER --
			
select cust_name
	, email
	, watch_sales
from (select cust_name
			,email
			,prod_cat
			,sum(qty*price) watch_sales
		from custs c join orders using (cust_id)
					join order_items oi using (ord_id)
					join prods p using (prod_id)
		where prod_cat = ('Watch')
		group by 1,2,3)a
join (select cust_name
			,sum(qty*price) all_spent
		from custs c join orders using (cust_id)
					join order_items oi using (ord_id)
					join prods p using (prod_id)
		where date_part('month', ord_dt) = 11 
		group by 1
		having sum(qty*price)  > 1000)b using (cust_name)--cant use amt_purchas		
where watch_sales / all_spent > 0.5
order by 3 desc, 1;

-- END ANSWER --

-------------------------------------------------------------------------------

-- END HOMEWORK ASSIGNMENT 3 --

-------------------------------------------------------------------------------
