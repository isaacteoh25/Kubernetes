--Create a temporary table with design copied from the target table
create temp table stage (like users);

--Copy data into the newly created staging table from any supported data sources like S3 / DynamoDB
--In this example, we are copying a subset of data from target table into the temporary table
insert into stage
select * from users where userid = 1;
--Update original firstname Rafael to Rafael - Updated
update stage set firstname = firstname + ' - Updated' where userid = 1;

--Start the transaction before deleting / inserting data
begin transaction;

--Delete the data in the target table i.e. users table, as we will be replacing it with the updated
--version of the same records from the staging table
delete from users
using stage
where users.userid = stage.userid;

--Insert the records from the staging table to the users table 
insert into users
select * from stage;

-- Close the transaction
end transaction;

--Explicity drop the staging table. If not, this table will get deleted once the session ends.
drop table stage;

--Rollback the update with the below query if required
--update users set firstname = 'Rafael' where userid = 1