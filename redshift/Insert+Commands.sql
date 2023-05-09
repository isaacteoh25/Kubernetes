--Delete all records in city_new table
truncate table city_new

--Insert a new record
insert into city_new values (1, 'USA', 'Florida', 'Miami', 100.50 )

select * from city_new

--Insert data in one table based on a query result from another table
insert into city
select * from city_new

select * from city

--Insert data based on specific column order
insert into city_new (id, amount, state, city, country)
values (2, 200.50, 'Nevada', 'Las Vegas', 'USA')

select * from city_new

--Insert mutiple records in a table with a single insert statement
insert into city_new 
values 
(3, 'USA', 'Florida', 'Miami', 100.50 ),
(4, 'USA', 'Nevada', 'Las Vegas', 200.50)

select * from city_new
