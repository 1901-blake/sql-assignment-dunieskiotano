---------------------------------------------------------------------------
2.1 SELECT Task 
------------------------------------------------------------------------
--Select all records from the Employee table.
SELECT * FROM Employee;
------------------------------------------------
--Task 
--Select all records from the Employee table where last name is King.
SELECT * FROM Employee WHERE lastName='King';
-----------------------------------------------------------------
--Task 
--Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
SELECT * from employee where firstname = 'Andrew' and reportsto isnull;
----------------------------------------------------------------------------------



-------------------------------------------------------------------------------
2.2 ORDER BY
------------------------------------------------------------------------------
--Select all albums in Album table and sort result set in descending order by title.
SELECT * FROM Album ORDER BY title DESC;
--------------------------------------------------------------------------------
--Task 
--Select first name from Customer and sort result set in ascending order by city
SELECT * FROM Customer ORDER BY city ASC;
------------------------------------------------------------------------------------


--------------------------------------------------------------------------------
2.3 INSERT INTO
----------------------------------------------------------------------------------
--Task Insert two new records into Genre table
INSERT INTO GENRE VALUES(29, 'Salsa'),(30, 'Merengue');
-----------------------------------------------------------------------------------
--Task
--Insert two new records into Employee table
insert into employee values
(9,'Dunieski', 'Otano', 'CEO', 7, '1976-04-01 00:00:00', '2018-04-01 00:00:00', '13876 SW 56th Street',
'Miami', 'FL', 'USA', '33175', '+1(787) 973-2044', '+1(787) 973-2044', 'dunieskior@gmail.com'),
(10,'Yanet', 'Perez', 'Vice President', 8, '1984-03-27 00:00:00', '2018-04-01 00:00:00', '13876 SW 56th Street',
'Miami', 'FL', 'USA', '33175', '+1(787) 779-6271', '+1(787) 973-2044', 'yanetperez@gmail.com');
-------------------------------------------------------------------------------------
--Task 
--Insert two new records into Customer table
insert into customer values
(60, 'Julia', 'Medina', 'Delta', 'San Lazaro 26', 'Luyano', 'FL', 'USA', '33126', '+1(305) 234-2012', '+1(305) 234-2013'
, 'juliamedina@gmail.com', 5),
(61, 'Roberto', 'Martinez', 'American Airlines', 'San Julia 2612', 'La Vibora', 'FL', 'USA', '33143', '+1(786) 234-2012', 
'+1(786) 234-2013', 'rmartinez@gmail.com', 4);
--------------------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------
2.4 UPDATE
------------------------------------------------------------------------
--Task Update Aaron Mitchell in Customer table to Robert Walter
update customer set firstname='Robert', lastname='Walter' where customerid=32;
--OR
update customer set firstname='Robert', lastname='Walter' where firstname='Aaron' and lastname='Mitchell';
------------------------------------------------------------------------------
--Task Update name of artist in the Artist table Creedence Clearwater Revival to CCR
update artist set name='CCR' where name='Creedence Clearwater Revival';
----------------------------------------------------------------------------




---------------------------------------------------------------------------
2.5 LIKE
-----------------------------------------------------------------------------
--Task Select all invoices with a billing address like T%
select * from invoice where billingaddress like 'T%';
-------------------------------------------------------------------------------------


----------------------------------------------------------------------
2.6 BETWEEN
----------------------------------------------------------------------
--Task Select all invoices that have a total between 15 and 50
select * from invoice where total between 15 and 50;
----------------------------------------------------------------------------
--Task Select all employees hired between 1st of June 2003 and 1st of March 2004
select * from employee where hiredate between '2003-06-01' and '2004-03-01';
--------------------------------------------------------------------------


-----------------------------------------------------------------------
2.7 DELETE
----------------------------------------------------------------------
--Task Delete a record in Customer table where the name is Robert Walter 
--(There may be constraints that rely on this, find out how to resolve them).
--The trasactions below drop the current constraint from the table and recreates a new one with on delete/update cascade*/
begin;
alter table invoice
drop constraint fk_invoicelineinvoiceid,
add CONSTRAINT fk_invoicelineinvoiceid 
FOREIGN KEY (invoiceid) REFERENCES invoice(invoiceid)
on delete cascade on update cascade;
commit;

begin;
alter table invoice
drop constraint fk_invoicecustomerid,
add CONSTRAINT fk_invoicecustomerid FOREIGN KEY (customerid) REFERENCES customer(customerid)
on delete cascade on update cascade;
commit;

delete from customer where firstname='Roberto' and lastname='Walter';
--The customer is finally deleted here after creating a new constraint
----------------------------------------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------
3.1 SYSTEM DEFINED FUNCTIONS      
-----------------------------------------------------------------------
--Task Create a function that returns the current time.
create or replace function currentTime() returns time with time zone as $$
  select * from current_time;
$$ language sql;

select currentTime();
-------------------------------------------------------------------------------------------------
--Task âcreate a function that returns the length of a mediatype from the mediatype table
create or replace function lengthMediaType() 
returns integer as $$
declare
    len integer;
begin
    select length(mediatype.name) into len from mediatype where mediatypeid=1;
    return len ;
end;
$$ language plpgsql;

select lengthMediaType();
----------------------------------------------------------------------------------------



-------------------------------------------------------------------------------------
3.2  SYSTEM DEFINED AGGREGATE FUNCTIONS                                         
-----------------------------------------------------------------------------------
--Task Create a function that returns the average total of all invoices
create or replace function averageTotal() returns money as $$
declare 
total money;
begin
select cast(round(avg(invoice.total), 2) as money) into total from invoice;
return total;
end;
$$ language plpgsql;

select averageTotal();
-----------------------------------------------------------------------------------
--Task Create a function that returns the most expensive track

create or replace function mostExpensiveTrack()
returns money as $$
declare 
price money;
begin
select cast(max(unitprice) as money) into price as "Price -- Most Expensive" from track;
return price;
end;
$$ language plpgsql;

select mostExpensiveTrack();
---------------------------------------------------------------------------------------------


-----------------------------------------------------------------------
3.3 USER DEFINED SCALAR FUNCTIONS
---------------------------------------------------------------------------
--Task Create a function that returns the average price of invoiceline items in the invoiceline table

create or replace function averageInvoicePrice()
returns money as $$
declare
    average money;
begin
    select cast(round(avg(unitprice), 2) as money) into average from invoiceline;
    return average;
end;
$$ language plpgsql;

select averageInvoicePrice();
-----------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------
3.4 User Defined Table Valued functions
--------------------------------------------------------------------------
--Task Create a function that returns all employees who are born after 1968.

CREATE or replace FUNCTION allEmployeesAfter1968() RETURNS setof employee AS $$
 select * from employee where birthdate > '1968-12-31';
$$ LANGUAGE SQL;
select * from allEmployeesAfter1968();

--select statement to test function
select * from employee

-------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------
4.0 STORED PROCEDURES
------------------------------------------------------------------------
--In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.
--4.1 Basic Stored Procedure
--Task – Create a stored procedure that selects the first and last names of all the employees.

--table emp created for testing purposes
create table emp(
employeeid serial primary key,
firstname text,
lastname text, 
title text);

--function created here

create or replace function managers_of_employees()
returns refcursor as $$
declare 
refe refcursor;
begin
open refe for select firstname, lastname, title from employee;
return refe;
end;
$$ language plpgsql;

--anonymous block created here for testing purposes
do $$
declare
curs refcursor;
emp_firstname text;
emp_lastname text;
emp_title text;

begin
	select managers_of_employees() into curs;
	loop
	fetch curs into emp_firstname, emp_lastname, emp_title;
	exit when not found;
insert into emp (firstname, lastname, title) values(emp_firstname, emp_lastname, emp_title);
	end loop;
end
$$ language plpgsql;

--select statement to test the insertion of the new employee record
select * from emp; 
----------------------------------------------------------------------------------------------------------------------------------



-------------------------------------------------------------------------------
4.2 Stored Procedure Input Parameters
-------------------------------------------------------------------------
--Task – Create a stored procedure that updates the personal information of an employee.

--function update_employee_info created here to update employee information
create or replace function update_employee_info(e_id integer, fname varchar, lname varchar)
returns void as $$
begin 
    update employee set firstname = fname, lastname = lname
    where employeeid = e_id;
end;
$$ language plpgsql;

--- a select statement is used to select the previously created function and iupdate the employee's info
select update_employee_info(9, 'Lazaro', 'Perez');

-- select statement used to test update
select * from employee;
-----------------------------------------------------------------------------------------------------------------

--Task – Create a stored procedure that returns the managers of an employee.

--table created for testing purposes
create table employee_managers
(emp_id serial primary key,
emp_firstname text,
emp_lastname text,
emp_title text,
reportsto text null,
mgr_fistname text,
mgr_lastname text,
mgr_title text);

create or replace function manager_and_employee()
returns refcursor as $$
declare 
refe refcursor;
begin
	open refe for 
	select emp.firstname, emp.lastname, emp.title, mgr.firstname, mgr.lastname, mgr.title from employee as emp
    inner join employee as mgr on emp.reportsto=mgr.employeeid; 
    return refe;
end;
$$ language plpgsql;

-- anonymous block created to test stored producure
do $$
declare 
curs refcursor;
e_firstname text;
e_lastname text;
e_title text;
m_firstname text;
m_lastname text;
m_title text;
begin
	select manager_and_employee() into curs;
	loop
    fetch curs into e_firstname, e_lastname, e_title, m_firstname, m_lastname, m_title;
    exit when not found;
    insert into employee_managers (emp_firstname, emp_lastname, emp_title, reportsto, mgr_fistname, mgr_lastname, mgr_title) 
    values(e_firstname, e_lastname, e_title, 'Reports To', m_firstname, m_lastname, m_title);
    end loop;
end
$$ language plpgsql;

select * from employee_managers; -- select info from employee_managers table to test the stored procedure
------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------
4.3 Stored Procedure Output 
--------------------------------------------------------------------------------------------
--Task – Create a stored procedure that returns the name and company of a customer.

-- create table cust_info for testing purposes
create table cust_info
(customerid serial primary key,
firstname text,
lastname text,
company text);

-- create function that will pull the data from the table
create or replace function customer_and_company(custom_id integer)
returns refcursor as $$
declare 
refe refcursor;
begin
	open refe for select firstname, lastname, company from customer where customerid=custom_id;
    return refe;
end;
$$ language plpgsql;

-- use anonymous block to test function
do $$
declare 
curs refcursor;
cust_firstname text;
cust_lastname text;
cust_companyname text;
begin
	select customer_and_company(5) into curs;-- customer with customer id 5 is passed and inserted in table cust_info
    loop
	fetch curs into cust_firstname, cust_lastname, cust_companyname;
	exit when not found;
    insert into cust_info (firstname, lastname, company) values(cust_firstname, cust_lastname, cust_companyname);
	end loop;
end
$$ language plpgsql;

--- --data from cust_info is pulled to reflect the insertion
select * from cust_info;
--NOTE: In the output customer shows id 3 because it is a different table but this customer has id 5 in the customer table
--------------------------------------------------------------------------------------------------------------------

5.0 Transactions
--In this section you will be working with transactions. Transactions are usually nested within a stored procedure.

--Task – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, 
--find out how to resolve them).

begin;
	delete from invoice where invoiceId=3;
commit;
------------------------------------------------------------------------------------------------------------------------
--Task – Create a transaction nested within a stored procedure that inserts a new record in the Customer table
--PROCEDURES ARE ATOMIC AND ARE TRANSACTIONS IN THEMSELVES
create or replace function transaction_within_stored_proc()
returns setof customer as $$
	begin;
	insert into customer values((select nextval('customer_id_seq')), 'Carlos', 'Benitez', 'CubaMax', '2210 South R Dr',
                                 'Miami', 'FL', 'USA', '33175', '7864543637', '3054674748', 'support@gmail.com', 2);
     end;
$$ language plpgsql;

select * from transaction_within_stored_proc();--invocation of function to insert value
select * from customer;--select customer table to bring a result set that reflects insertion
-----------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
6.0 TRIGGERS
-------------------------------------------------------------------------------------
--In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.
--6.1 AFTER/FOR
--Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.

create sequence employee_id_seq start 15;--a sequence is created 
select nextval('employee_id_seq');--this will be used every time the employee id needs to be inserted

/*function created here*/
create or replace function insert_employee_info()
returns trigger as $$
begin 
	if(TG_OP = 'INSERT') then
	new.employeeid=(select nextval('employee_id_seq'));
   	end if;
	return new;
end;
$$ language plpgsql; 

/*Trigger to be fired avter insert on employee*/
create trigger emp_insert
after insert on employee
for each row
execute procedure insert_employee_info();

/*Insert statement after which trigger will be fired*/
insert into employee values ((select nextval('employee_id_seq')), 'Casanova', 'Salvador'); 
-----------------------------------------------------------------------------------------------------------------------

--Task – Create an after update trigger on the album table that fires after a row is inserted in the table

create sequence album_id_seq start 348;--sequence is created here for album table
create sequence artist_id_seq start 276;--sequence for artist table
select nextval('album_id_seq');--used every time an album id needs to be inserted
select nextval('artist_id_seq');--used every time an artist id needs to be inserted

--function is created here to update info
create or replace function update_album() 
returns trigger as $$
begin
	if(new.title <> old.title) then
	insert into album values((select nextval('album_id_seq')), new.title, (select nextval('artist_id_seq')));
     end if;
     return new;
end;
$$ language plpgsql;

--created trigger here to fire after update
create trigger album_trigger
after update on album
for each row
execute procedure update_album();

--information to be updated in the table
update album set title='Ay, Por que te fuiste?' where albumid=1;
----------------------------------------------------------------------------------------------------------------

--Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.

--function will insert a row after a row has been deleted from the  customer table
create or replace function delete_customer_info()
returns trigger as $$
begin
	insert into customer values((select nextval('customer_id_seq')), 'Armando', 'Paredes', 'CDC', '123 NW 23 St',
                             'Cuba', 'FL', 'Cuba', '33175', '6754843838', '4543632728','aswe@gmail.com', 12);
return null;
end;
$$ language plpgsql;

--this trigger will fire after a row has been deleted using the statement below
create trigger delete_customer
after delete on customer
for each row
execute procedure delete_customer_info();

--This delete statement that fires the trigger
delete from customer where customerid=63;
-----------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------
7.0 JOINS
-------------------------------------------------------------------------------------------------
--In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.
--7.1 INNER
--Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.

select concat(c.firstname, ' ', c.lastname) as "Customer's Name", i.invoiceId as "Invoice ID" 
from customer as c 
inner join invoice as i on c.customerid=i.customerid;
-------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------
7.2 OUTER
----------------------------------------------------------------------------
--Task – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, 
--invoiceId, and total.

select c.customerId, c.firstname, c.lastname, i.invoiceId, cast(i.total as money)
from customer as c
full outer join invoice as i on c.customerid=i.customerid order by c.customerid; 
-------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------
7.3 RIGHT
----------------------------------------------------------------------------------------------
--Task – Create a right join that joins album and artist specifying artist name and title.

select ar.name as "Artist's Name ", a.title as "Song's Title" 
from album a 
right join artist ar on a.artistid=ar.artistid;
------------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------
7.4 CROSS
--------------------------------------------------------------------------------------------------
--Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.

select * from album cross join artist order by artist.name;
----------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------
7.5 SELF
--------------------------------------------------------------------------------------------
--Task – Perform a self-join on the employee table, joining on the reportsto column.

select emp.employeeid as "Employee ID", concat(emp.firstname, ' ', emp.lastname) as "Full Name", emp.title as "Title", 
concat(mgr.firstname, ' ', mgr.lastname) as "Report To", mgr.title as "Title" from employee as emp 
full outer join employee mgr on emp.reportsto=mgr.employeeid;
---------------------------------------------------------------------------------------------


