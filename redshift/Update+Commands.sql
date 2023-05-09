--Update the CATGROUP column based on a range of values in the CATID column.
update category
set catgroup='Theatre'
where catid between 6 and 8;

select * from category
where catid between 6 and 8;

--Update the CATNAME and CATDESC columns based on their current CATGROUP value:
update category
set catdesc=default, catname='Shows'
where catgroup='Theatre';
select * from category
where catname='Shows';

--Update the original 11 rows in the CATEGORY table based on matching CATID rows in the EVENT table:
update category set catid=100
from event
where event.catid=category.catid;

--Update the original 11 rows in the CATEGORY table by extending the previous example and adding
--another condition to the WHERE clause. Because of the restriction on the CATGROUP column, only one
--row qualifies for the update (although four rows qualify for the join).
update category set catid=100
from event
where event.catid=category.catid
and catgroup='Concerts';
select * from category where catid=100;

--An alternative way to write this example is as follows:
--The advantage to this approach is that the join criteria are clearly separated from any other criteria that
--qualify rows for the update. Note the use of the alias CAT for the CATEGORY table in the FROM clause.
update category set catid=100
from event join category cat on event.catid=cat.catid
where cat.catgroup='Concerts';

--The previous example showed an inner join specified in the FROM clause of an UPDATE statement. The
--following example returns an error because the FROM clause does not support outer joins to the target table:
update category set catid=100
from event left join category cat on event.catid=cat.catid
where cat.catgroup='Concerts';

--If the outer join is required for the UPDATE statement, you can move the outer join syntax into a
--subquery:
update category set catid=100
from
(select event.catid from event left join category cat on event.catid=cat.catid) eventcat
where category.catid=eventcat.catid
and catgroup='Concerts';