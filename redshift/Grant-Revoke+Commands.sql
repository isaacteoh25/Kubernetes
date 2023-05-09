--Create a new database
create database privileges_test

--Change the database to privilege_test before executing the below commands
--Create a new schema
create schema myschema

--Create a sample table test in myschema
create table myschema.test (id int, name varchar(50))

--Insert a sample record in test table
insert into myschema.test values (1,'Siddharth')

--Create view based on test table in myschema
create view myschema.myview as select * from myschema.test

--Create user guest
create user guest password 'Redshift1'

--Grant permission on all tables in myschema to guest user account 
grant all on all tables in schema myschema to guest
grant all on schema myschema to guest

--Commands to be executed using guest user account to test access
select * from myschema.test
select * from myschema.myview

--Revoke permission on test table from guest user account
revoke all on table myschema.test from guest

--Commands to be executed using guest user account to test access
select * from myschema.test
select * from myschema.myview