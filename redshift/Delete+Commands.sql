--Delete all of the rows from the CATEGORY table:
delete from category;

--Delete rows with CATID values between 0 and 9 from the CATEGORY table:
delete from category
where catid between 0 and 9;

--Delete rows from the LISTING table whose SELLERID values do not exist in the SALES table:
delete from listing
where listing.sellerid not in(select sales.sellerid from sales);

--The following two queries both delete one row from the CATEGORY table, based on a join to the EVENT
--table and an additional restriction on the CATID column:
delete from category
using event
where event.catid=category.catid and category.catid=9;

delete from category
where catid in
(select category.catid from category, event
where category.catid=event.catid and category.catid=9);