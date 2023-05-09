--You can't make forward references to tables defined by WITH clause subqueries. 
--For example, the following query returns an error because of the forward reference 
--to table W2 in the definition of table W1:
with w1 as (select * from w2), w2 as (select * from w1)
select * from sales;

--The following example shows the simplest possible case of a query that contains a 
--WITH clause. The WITH query named VENUECOPY selects all of the rows from the VENUE 
--table. The main query in turn selects all of the rows from VENUECOPY. 
--The VENUECOPY table exists only for the duration of this query.
with venuecopy as (select * from venue)
select * from venuecopy order by 1 limit 10;


--The following example shows a WITH clause that produces two tables, 
--named VENUE_SALES and TOP_VENUES. The second WITH query table selects from the 
--first. In turn, the WHERE clause of the main query block contains a subquery 
--that constrains the TOP_VENUES table.
with 

venue_sales as
(select venuename, venuecity, sum(pricepaid) as venuename_sales
from sales, venue, event
where venue.venueid=event.venueid and event.eventid=sales.eventid
group by venuename, venuecity),

top_venues as
(select venuename
from venue_sales
where venuename_sales > 800000)

select venuename, venuecity, venuestate,
sum(qtysold) as venue_qty,
sum(pricepaid) as venue_sales
from sales, venue, event
where venue.venueid=event.venueid and event.eventid=sales.eventid
and venuename in(select venuename from top_venues)
group by venuename, venuecity, venuestate
order by venuename;

--The following two examples demonstrate the rules for the scope of table references 
--based on WITH clause subqueries. The first query runs, but the second fails with an
--expected error. The first query has WITH clause subquery inside the SELECT list of 
--the main query. The table defined by the WITH clause (HOLIDAYS) is referenced in
--the FROM clause of the subquery in the SELECT list:

select caldate, sum(pricepaid) as daysales,
(with holidays as (select * from date where holiday ='t')
select sum(pricepaid)
from sales join holidays on sales.dateid=holidays.dateid
where caldate='2008-12-25') as dec25sales
from sales join date on sales.dateid=date.dateid
where caldate in('2008-12-25','2008-12-31')
group by caldate
order by caldate;

--The second query fails because it attempts to reference the HOLIDAYS table in the 
--main query as well as in the SELECT list subquery. The main query references are 
--out of scope.

select caldate, sum(pricepaid) as daysales,
(with holidays as (select * from date where holiday ='t')
select sum(pricepaid)
from sales join holidays on sales.dateid=holidays.dateid
where caldate='2008-12-25') as dec25sales
from sales join holidays on sales.dateid=holidays.dateid
where caldate in('2008-12-25','2008-12-31')
group by caldate
order by caldate;

--Return any 10 rows from the SALES table. Because no ORDER BY clause is specified, 
--the set of rows that this query returns is unpredictable.

select top 10 *
from sales;

--The following query is functionally equivalent, but uses a LIMIT clause instead of 
--a TOP clause:

select *
from sales
limit 10;

--Return the first 10 rows from the SALES table, ordered by the QTYSOLD column in 
--descending order.

select top 10 qtysold, sellerid
from sales
order by qtysold desc, sellerid;

--Return the first two QTYSOLD and SELLERID values from the SALES table, ordered by 
--the QTYSOLD column:

select top 2 qtysold, sellerid
from sales
order by qtysold desc, sellerid;

--Return a list of different category groups from the CATEGORY table:
select distinct catgroup from category
order by 1;

--Return the distinct set of week numbers for December 2008:
select distinct week, month, year
from date
where month='DEC' and year=2008
order by 1, 2, 3;

--The following query uses a combination of different WHERE clause restrictions, 
--including a join condition for the SALES and EVENT tables, a predicate on the 
--EVENTNAME column, and two predicates on the STARTTIME column.
select eventname, starttime, pricepaid/qtysold as costperticket, qtysold
from sales, event
where sales.eventid = event.eventid
and eventname='Hannah Montana'
and date_part(quarter, starttime) in(1,2)
and date_part(year, starttime) = 2008
order by 3 desc, 4, 2, 1 limit 10;

--If two tables are joined over multiple join conditions, you must use the (+) operator in all or none of
--these conditions. A join with mixed syntax styles executes as an inner join, without warning.
--The (+) operator does not produce an outer join if you join a table in the outer query with a table that
--results from an inner query.
--To use the (+) operator to outer-join a table to itself, you must define table aliases in the FROM clause
--and reference them in the join condition:
select count(*)
from event a, event b
where a.eventid(+)=b.catid;

--You can't combine a join condition that contains the (+) operator with an OR condition or an IN
--condition. For example:
select count(*) from sales, listing
where sales.listid(+)=listing.listid or sales.salesid=0;

--In a WHERE clause that outer-joins more than two tables, the (+) operator can be applied only once to
--a given table. In the following example, the SALES table can't be referenced with the (+) operator in
--two successive joins.
select count(*) from sales, listing, event
where sales.listid(+)=listing.listid and sales.dateid(+)=date.dateid;

--The following join query specifies a left outer join of the SALES and LISTING tables over their LISTID
--columns:
select count(*)
from sales, listing
where sales.listid = listing.listid(+);

--The following equivalent query produces the same result but uses FROM clause join syntax:
select count(*)
from sales left outer join listing on sales.listid = listing.listid;

--The SALES table does not contain records for all listings in the LISTING table because not all listings
--result in sales. The following query outer-joins SALES and LISTING and returns rows from LISTING even
--when the SALES table reports no sales for a given list ID. The PRICE and COMM columns, derived from
--the SALES table, contain nulls in the result set for those non-matching rows.
select listing.listid, sum(pricepaid) as price,
sum(commission) as comm
from listing, sales
where sales.listid(+) = listing.listid and listing.listid between 1 and 5
group by 1 order by 1;

--If you remove the (+) operator from the EVENTID restriction, the query treats this restriction as a filter, not as part of the outer-join
--condition. In turn, the outer-joined rows that contain nulls for EVENTID are eliminated from the result
--set. The following example illustrates this behavior:
select catname, catgroup, eventid
from category, event
where category.catid=event.catid(+) and eventid(+)=796;

--The equivalent query using FROM clause syntax is as follows:
select catname, catgroup, eventid
from category left join event
on category.catid=event.catid and eventid=796;

--If you remove the second (+) operator from the WHERE clause version of this query, it returns only 1 row
--(the row where eventid=796).
select catname, catgroup, eventid
from category, event
where category.catid=event.catid(+) and eventid=796;

--The list of columns or expressions must match the list of non-aggregate expressions in the select list of
--the query. For example, consider the following simple query:
select listid, eventid, sum(pricepaid) as revenue,
count(qtysold) as numtix
from sales
group by listid, eventid
order by
limit 5;

--The following query calculates total ticket sales for all events by name, then eliminates events where
--the total sales were less than $800,000. The HAVING condition is applied to the results of the aggregate
--function in the select list: sum(pricepaid).
select eventname, sum(pricepaid)
from sales join event on sales.eventid = event.eventid
group by 1
having sum(pricepaid) > 800000
order by 2 desc, 1;

--The following query calculates a similar result set. In this case, however, the HAVING condition is applied
--to an aggregate that is not specified in the select list: sum(qtysold). Events that did not sell more than
--2,000 tickets are eliminated from the final result.
select eventname, sum(pricepaid)
from sales join event on sales.eventid = event.eventid
group by 1
having sum(qtysold) >2000
order by 2 desc, 1;

--The UNION and EXCEPT set operators are left-associative. If parentheses are not specified to influence
--the order of precedence, a combination of these set operators is evaluated from left to right. For
--example, in the following query, the UNION of T1 and T2 is evaluated first, then the EXCEPT operation is
--performed on the UNION result:
select * from t1
union
select * from t2
except
select * from t3
order by c1;

--The INTERSECT operator takes precedence over the UNION and EXCEPT operators when a combination
--of operators is used in the same query. For example, the following query will evaluate the intersection of
--T2 and T3, then union the result with T1:
select * from t1
union
select * from t2
intersect
select * from t3
order by c1;

--By adding parentheses, you can enforce a different order of evaluation. In the following case, the result
--of the union of T1 and T2 is intersected with T3, and the query is likely to produce a different result.
(select * from t1
union
select * from t2)
intersect
(select * from t3)
order by c1;

--The LIMIT and OFFSET clauses are not supported as a means of restricting the number of rows
--returned by an intermediate result of a set operation. 
--For example, the following query returns an error:
(select listid from listing
limit 10)
intersect
select listid from sales;

--In the following UNION query, rows in the SALES table are merged with rows in the LISTING table. Three
--compatible columns are selected from each table; in this case, the corresponding columns have the same
--names and data types.
--The final result set is ordered by the first column in the LISTING table and limited to the 5 rows with the
--highest LISTID value.
select listid, sellerid, eventid from listing
union select listid, sellerid, eventid from sales
order by listid, sellerid, eventid desc limit 5;

--The following example shows how you can add a literal value to the output of a UNION query so you can
--see which query expression produced each row in the result set. The query identifies rows from the first
--query expression as "B" (for buyers) and rows from the second query expression as "S" (for sellers).
--The query identifies buyers and sellers for ticket transactions that cost $10,000 or more. The only
--difference between the two query expressions on either side of the UNION operator is the joining column
--for the SALES table.

select listid, lastname, firstname, username,
pricepaid as price, 'S' as buyorsell
from sales, users
where sales.sellerid=users.userid
and pricepaid >=10000
union
select listid, lastname, firstname, username, pricepaid,
'B' as buyorsell
from sales, users
where sales.buyerid=users.userid
and pricepaid >=10000
order by 1, 2, 3, 4, 5;

--The following example uses a UNION ALL operator because duplicate rows, if found, need to be retained
--in the result. For a specific series of event IDs, the query returns 0 or more rows for each sale associated
--with each event, and 0 or 1 row for each listing of that event. Event IDs are unique to each row in the
--LISTING and EVENT tables, but there might be multiple sales for the same combination of event and
--listing IDs in the SALES table.
select eventid, listid, 'Yes' as salesrow
from sales
where listid in(500,501,502)
union all
select eventid, listid, 'No'
from listing
where listid in(500,501,502)
order by listid asc;

--If you run the same query without the ALL keyword, the result retains only one of the sales transactions.
select eventid, listid, 'Yes' as salesrow
from sales
where listid in(500,501,502)
union
select eventid, listid, 'No'
from listing
where listid in(500,501,502)
order by listid asc;

--The following query finds events (for which tickets were sold) that occurred at venues in both New York
--City and Los Angeles in March. The difference between the two query expressions is the constraint on the
--VENUECITY column.
select distinct eventname from event, sales, venue
where event.eventid=sales.eventid and event.venueid=venue.venueid
and date_part(month,starttime)=3 and venuecity='Los Angeles'
intersect
select distinct eventname from event, sales, venue
where event.eventid=sales.eventid and event.venueid=venue.venueid
and date_part(month,starttime)=3 and venuecity='New York City'
order by eventname asc;

--Return all 11 rows from the CATEGORY table, ordered by the second column, CATGROUP. For results that
--have the same CATGROUP value, order the CATDESC column values by the length of the character string.
--The other two columns, CATID and CATNAME, do not influence the order of results.
select * from category order by 2, length(catdesc), 1, 3;

--Return selected columns from the SALES table, ordered by the highest QTYSOLD values. Limit the result
--to the top 10 rows:
select salesid, qtysold, pricepaid, commission, saletime from sales
order by qtysold, pricepaid, commission, salesid, saletime desc
limit 10;

--Return a column list and no rows by using LIMIT 0 syntax:
select * from venue limit 0;

--This query matches LISTID column values in LISTING (the left table) and SALES (the right table). The
--results show that listings 2, 3, and 5 did not result in any sales.
select listing.listid, sum(pricepaid) as price, sum(commission) as comm
from listing left outer join sales on sales.listid = listing.listid
where listing.listid between 1 and 5
group by 1
order by 1;

--The following query is an inner join of two subqueries in the FROM clause. The query finds the number
--of sold and unsold tickets for different categories of events (concerts and shows):
select catgroup1, sold, unsold
from
(select catgroup, sum(qtysold) as sold
from category c, event e, sales s
where c.catid = e.catid and e.eventid = s.eventid
group by catgroup) as a(catgroup1, sold)
join
(select catgroup, sum(numtickets)-sum(qtysold) as unsold
from category c, event e, sales s, listing l
where c.catid = e.catid and e.eventid = s.eventid
and s.listid = l.listid
group by catgroup) as b(catgroup2, unsold)
on a.catgroup1 = b.catgroup2
order by 1;

--The following example contains a subquery in the SELECT list. This subquery is scalar: it returns only one
--column and one value, which is repeated in the result for each row that is returned from the outer query.
--The query compares the Q1SALES value that the subquery computes with sales values for two other
--quarters (2 and 3) in 2008, as defined by the outer query.
select qtr, sum(pricepaid) as qtrsales,
(select sum(pricepaid)
from sales join date on sales.dateid=date.dateid
where qtr='1' and year=2008) as q1sales
from sales join date on sales.dateid=date.dateid
where qtr in('2','3') and year=2008
group by qtr
order by qtr;

--The query finds the top 10 sellers in terms of maximum tickets sold. The top 10 list is restricted by the
--subquery, which removes users who live in cities where there are ticket venues. This query can be written
--in different ways; for example, the subquery could be rewritten as a join within the main query.
select firstname, lastname, city, max(qtysold) as maxsold
from users join sales on users.userid=sales.sellerid
where users.city not in(select venuecity from venue)
group by firstname, lastname, city
order by maxsold desc, city desc
limit 10;

--The following example contains a correlated subquery in the WHERE clause; this kind of subquery
--contains one or more correlations between its columns and the columns produced by the outer query. In
--this case, the correlation is where s.listid=l.listid. For each row that the outer query produces,
--the subquery is executed to qualify or disqualify the row.
select salesid, listid, sum(pricepaid) from sales s
where qtysold=
(select max(numtickets) from listing l
where s.listid=l.listid)
group by 1,2
order by 1,2
limit 5;

--The following query, the block containing the correlation reference and the skipped block
--are connected by a NOT EXISTS predicate:
select event.eventname from event
where not exists
(select * from listing
where not exists
(select * from sales where event.eventid=sales.eventid));

--Correlation references from a subquery that is part of an ON clause in an outer join:
select * from category
left join event
on category.catid=event.catid and eventid =
(select max(eventid) from sales where sales.eventid=event.eventid);

--The ON clause contains a correlation reference from SALES in the subquery to EVENT in the outer
--query. Null-sensitive correlation references to an Amazon Redshift system table. For example:
select attrelid
from stv_locks sl, pg_attribute
where sl.table_id=pg_attribute.attrelid and 1 not in
(select 1 from pg_opclass where sl.lock_owner = opcowner);

--Correlation references from within a subquery that contains a window function.
select listid, qtysold
from sales s
where qtysold not in
(select sum(numtickets) over() from listing l where s.listid=l.listid);
 
--References in a GROUP BY column to the results of a correlated subquery. For example:
select listing.listid,
(select count (sales.listid) from sales where sales.listid=listing.listid) as list
from listing
group by list, listing.listid;

--Correlation references from a subquery with an aggregate function and a GROUP BY clause, connected
--to the outer query by an IN predicate. (This restriction does not apply to MIN and MAX aggregate
--functions.) 
select * from listing where listid in
(select sum(qtysold)
from sales
where numtickets>4
group by salesid);

--Select all of the rows from the EVENT table and create a NEWEVENT table:
select * into newevent from event;

--Select the result of an aggregate query into a temporary table called PROFITS:
select username, lastname, sum(pricepaid-commission) as profit
into temp table profits
from sales, users
where sales.sellerid=users.userid
group by 1, 2
order by 3 desc;