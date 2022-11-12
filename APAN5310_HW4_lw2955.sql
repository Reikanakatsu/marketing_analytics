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


-- HOMEWORK ASSIGNMENT 4

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
 *      database system (MySQL, MS SQL Server, SQLite, Oracle, etc).
 *
 *    - The source database 'bank' is provided to you. If you have any issues 
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
 *    - For this assignment, do not create or use any VIWEs! Use CTEs to
 *      represent intermediate tables.
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
 * Provide the SQL statement that returns the 100 customers who have the most
 *   transactions with amounts less than $2,000.
 *
 * The transactions can be any transaction type.
 * The transactions can come from any account type.
 *
 * Use a CTE called tran2k which is a subset of trans but with only 
 *  tran_amt < 2000.
 *
 * Include all ties for the 100th spot. That is, set the limit value to 
 *   not exclude any customers who are tied for the 100th spot.
 *
 * Label the columns: cust_id, num_trans_less_than_2000
 * Order by num_trans_less_than_2000 (hi to lo).
 *
 */

-- START ANSWER --

with tran2k as
(select cust_id
	, tran_amt 
from trans join accts using (acct_id)
where tran_amt < 2000)
select  cust_id, count(tran_amt) num_trans_less_than_2000
from tran2k
group by 1
order by 2 desc
limit 100;


-- END ANSWER --

-------------------------------------------------------------------------------

/*
 * QUESTION 2 (10 points)
 * --------------------
 *
 * Provide the SQL statement that returns the bank atm locations in the
 *   state of Florida (FL) that had conducted more transactions in the AM
 *   than they had in the PM.
 *
 * The transactions can be any transaction type.
 * The transactions can come from any account type.
 *
 * AM = the hours from 0 to 11. PM = all the other hours of the day.
 *
 * Create CTEs such that there is no joining of tables in the main query.
 *
 * Label the columns: locn_name, city, trans_am, trans_pm
 *   where trans_am = # of transactions in the AM
 *         trans_pm = # of transactions in the PM
 * Order by locn_name (A to Z) and then city (A to Z).
 *
 */

-- START ANSWER --

with a as (
select locn_name
	, city 
	, case when date_part('hour', tran_dt) between 0 and 11 then 'AM'
		else 'PM' end ampm
from locns join trans using (locn_id)
where st = 'FL'
	 and locn_type = 'a')
select locn_name
	, city
	, sum(case ampm when 'AM' then 1 else 0 end) trans_am
	, sum(case ampm when 'PM' then 1 else 0 end) trans_pm
from a 
group by 1,2
having sum(case ampm when 'AM' then 1 else 0 end)  > sum(case ampm when 'PM' then 1 else 0 end)
order by 1,2;

-- END ANSWER --

-------------------------------------------------------------------------------

/*
 * QUESTION 3 (15 points)
 * --------------------
 *
 * Provide the SQL statement that returns the states in which the customers
 *   live and the account type (c or s) in greatest use by those customers.
 *
 * Greatest use is defined by the number of transactions incurred for the 
 *   given account type.
 *
 * If there are ties for the top account type, choose Checking Account (c).
 *
 * For example, if state ZZ had 
 *   - Checking accounts with 200 total transactions
 *   - Savings accounts with 200 total transactions
 *   Then, the output for this state should be: 'ZZ', 'c'. 
 *
 * Label the columns: st, greatest_acct_type
 * Order by state (A to Z).
 *
 */

-- START ANSWER --



with t as 
(select * from (select st
	, count(tran_id) c_count
from custs join accts using (cust_id)
	join trans using (acct_id)
where acct_type = 'c'
group by 1
order by 1) a
join 
(select st
	, count(tran_id) s_count
from custs join accts using (cust_id)
	join trans using (acct_id)
where acct_type = 's'
group by 1
order by 1) b using (st))
select st
	, case when s_count > c_count then 's'  else 'c' end greatest_acct_type
from t ;


--check hint
with x as (
with t as 
(select * from (select st
	, count(tran_id) c_count
from custs join accts using (cust_id)
	join trans using (acct_id)
where acct_type = 'c'
group by 1
order by 1) a
join 
(select st
	, count(tran_id) s_count
from custs join accts using (cust_id)
	join trans using (acct_id)
where acct_type = 's'
group by 1
order by 1) b using (st))
select st
	, case when s_count > c_count then 's'  else 'c' end greatest_acct_type
from t )
select count(*) n
from x
where greatest_acct_type = 's';

-- END ANSWER --

-------------------------------------------------------------------------------

/*
 * QUESTION 4 (15 points)
 * --------------------
 *
 * Use two CTEs to produce a report showing the bank's customers
 *   grouped by the first three digits of their zip code (zip3)
 *   and the number of customers by gender.
 * 
 * Include all customers even if they have no active account.
 *
 * Each CTE (named cf and cm) should show the zip3 code along with the
 *   number of customers living in that zip3 code and of the corresponding
 *   gender.
 * 
 * There should be no NULL values in the final output. Replace with zeroes.
 *
 * Label the columns: zip3, female_customers, male_customers
 * Order by total of all customers (hi to lo), then by zip3 (A to Z).
 *
 */

-- START ANSWER --
with cf as (
select CAST(LEFT(zip, 3) AS INT) zip3,
	sum(case gender when 'f' then 1 else 0 end) female_customers
from custs
group by 1
),
cm 
as (
select CAST(LEFT(zip, 3) AS INT) zip3,
	sum(case gender when 'm' then 1 else 0 end) male_customers,
	count(*) total 
from custs
group by 1
)
select zip3
	, female_customers
	, male_customers
from cf join cm using (zip3)
order by total desc, zip3 ;
	
	

-- END ANSWER --

-------------------------------------------------------------------------------

/*
 * QUESTION 5 (25 points)
 * --------------------
 *
 * Although none of the accounts earn interest in this bank, the bank 
 * decides to reward certain customers with a one-time year-end interest
 * payment who meet all the following qualifications:
 * 
 *   1) own more than one account
 *   2) live in the same zip code with at least ten other customers
 *        (including those with no active accounts)
 *   3) conduct the majority of his/her transactions on a mobile device
 *
 * The interest payment is equal to:
 * 
 *   int_pmt = int_pmt = (bal @ end of day 9/30/2021) * 0.00525 (rounded to 2 dp)
 * 
 * Label the columns: cust_name, acct_type, bal930, int_pmt
 *   (cust_name is cust_last and cust_first separated by a comma and space;
 *    e.g. John Doe should be Doe, John)
 * Order by int_pmt (hi to lo), then by cust_name (A to Z).
 * 
 */

-- START ANSWER --


 with a as ( -- more than one account
	 select cust_id
	 	, count(acct_id) acct_count
	 from accts
	 group by 1
	 having count(acct_id)  > 1
 ),
 b as ( -- zip more than 10
 	select zip
	 	, count(cust_id) zip_count
	from custs 
	group by 1
	having count(cust_id) >10),
b2 as (
	select cust_id
	from custs join b using (zip)),
 c AS ( 
  	 SELECT cust_id
          , count(tran_id) mobile_count
      FROM accts
      JOIN trans USING (acct_id)
      JOIN locns USING (locn_id)
      WHERE locn_type = 'm'
      GROUP BY 1),
  c2 AS (
    SELECT cust_id
          , count(tran_id) total
      FROM accts
      JOIN trans USING (acct_id)
      JOIN locns USING (locn_id)
      GROUP BY 1),
   c3 AS ( 
     SELECT cust_id
       FROM c
       JOIN c2 USING (cust_id)
       WHERE 1.0 * mobile_count / total > 0.5),
  d as ( -- net amt
	 select acct_id
		, acct_type
		, bal_boy
	 	, sum(CASE tran_type
	                     WHEN 'w' THEN -1 * tran_amt
	                     ELSE tran_amt
	                   END) net_amt
	 from accts JOIN trans USING (acct_id)
	 WHERE tran_dt < '2021-10-01 00:00:00'
	 group by 1,2, 3),
 e as ( -- balance 
 SELECT acct_id
 	 , acct_type
     , bal_boy + net_amt bal930
  FROM d )-- interest 
 select cust_first || ' ' || cust_last cust_name
 	, e.acct_type
 	, bal930
 	, round(bal930 * 0.00525, 2) int_pmt
from a join b2 using (cust_id)	
	join c3 using (cust_id)
	join accts using (cust_id)
	join e using (acct_id)
	join custs using (cust_id)
order by 4 desc, 1;


-- END ANSWER --
 
/*
 * QUESTION 6 (25 points)
 * --------------------
 *
 * Because the bank is needing additional sources of revenue, it decides to
 *   impose two separate penalty fees to customers for certain withdrawal 
 *   activity as noted below:
 *
 *   Fee1: $25 for each withdrawal from a savings account where the withdrawal 
 *         amount exceeds the average savings withdrawal amount for the 
 *         customer's state of residence
 * 
 *   Fee2: 0.012% of total quarterly withdrawal amounts for all accounts 
 *       if that total exceeds $5,000 (round fee to 2 dp)
 *
 * Replace any null values with zeroes.
 *
 * Total Fee = Fee1 + Fee2 if sum >= $500, else Total Fee = $0
 * 
 * Label the columns: cust_id, full_name, fee1, fee2, total_fee 
 *   (full_name = cust_first and cust_last separated by a space; e.g John Doe)
 * Order by total fee (hi to lo).
 *
 */

-- START ANSWER --


with 
a as(
	select st,
		round(avg(tran_amt),2)st_avg
	from trans join accts using (acct_id)
		join custs using (cust_id)
	where tran_type = 'w'
		and acct_type  = 's'
	group by 1
),
f1 as (
	select cust_id
		, sum(case  when tran_amt > st_avg then 25 else 0 end) fee1
	from a join custs using (st)
		join accts using (cust_id)
		join trans using (acct_id)
	where tran_type = 'w'
		and acct_type  = 's'
	group by 1
),
b as (
	select cust_id
		, date_part('qtr', tran_dt) qtr
		, round(0.00012 * sum(tran_amt), 2) qtr_total
	FROM accts
       JOIN  trans USING (acct_id)
       WHERE tran_type = 'w'
       GROUP BY 1, 2
       HAVING sum(tran_amt) > 5000
), 
f2 as (
	select cust_id
		, SUM(qtr_total) fee2
	from b
	group by 1)
select cust_id
	, cust_first || ' ' || cust_last cust_name
	, fee1
	, fee2 
	, case when fee1 + fee2 >= 500 then fee1 + fee2 else 0 end total_fee
FROM custs
 JOIN f1 USING (cust_id)
 JOIN f2 USING (cust_id)
group by 1,2,3,4
order by 5 desc;


 
-- END ANSWER --

-------------------------------------------------------------------------------

-- END HOMEWORK ASSIGNMENT 4 --

-------------------------------------------------------------------------------
