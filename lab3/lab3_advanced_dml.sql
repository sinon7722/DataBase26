create table employees (
    emp_id serial primary key,
    first_name varchar(50),
    last_name varchar(50),
    department varchar(50) default 'unassigned',
    salary int default 30000,
    hire_date date,
    status varchar(20) default 'active'
);

create table departments (
    dept_id serial primary key,
    dept_name varchar(50),
    budget int,
    manager_id int
);

create table projects (
    project_id serial primary key,
    project_name varchar(100),
    dept_id int,
    start_date date,
    end_date date,
    budget int
);

insert into employees (emp_id, first_name, last_name, department)
values (default, 'john', 'doe', 'it');

insert into employees (first_name, last_name, department, salary, status)
values ('alice', 'smith', 'hr', default, default);

insert into departments (dept_name, budget, manager_id)
values
    ('it', 150000, 1),
    ('hr', 50000, 2),
    ('sales', 120000, 3);

insert into employees (first_name, last_name, department, salary, hire_date)
values ('bob', 'johnson', 'it', 50000 * 1.1, current_date);

create temp table temp_employees as
select * from employees where 1=0;

insert into temp_employees
select * from employees where department = 'it';

update employees
set salary = salary * 1.1;

update employees
set status = 'senior'
where salary > 60000 and hire_date < '2020-01-01';

update employees
set department = case
    when salary > 80000 then 'management'
    when salary between 50000 and 80000 then 'senior'
    else 'junior'
end;

update employees
set department = default
where status = 'inactive';

update departments d
set budget = (
    select coalesce(avg(e.salary), 0) * 1.2
    from employees e
    where e.department = d.dept_name
);

update employees
set salary = salary * 1.15,
    status = 'promoted'
where department = 'sales';

delete from employees
where status = 'terminated';

delete from employees
where salary < 40000
  and hire_date > '2023-01-01'
  and department is null;

delete from departments
where dept_id not in (
    select distinct dept_id
    from departments
    where dept_name in (
        select distinct department
        from employees
        where department is not null
    )
);

delete from projects
where end_date < '2023-01-01'
returning *;

insert into employees (first_name, last_name, salary, department)
values ('charlie', 'brown', null, null);

update employees
set department = 'unassigned'
where department is null;

delete from employees
where salary is null or department is null;

insert into employees (first_name, last_name, department, salary)
values ('david', 'miller', 'finance', 65000)
returning emp_id, (first_name || ' ' || last_name) as full_name;

with old_data as (
    select emp_id, salary as old_salary
    from employees
    where department = 'it'
)
update employees e
set salary = e.salary + 5000
from old_data o
where e.emp_id = o.emp_id
returning e.emp_id, o.old_salary, e.salary as new_salary;

delete from employees
where hire_date < '2020-01-01'
returning *;

insert into employees (first_name, last_name, department, salary)
select 'eva', 'green', 'marketing', 55000
where not exists (
    select 1 from employees
    where first_name = 'eva' and last_name = 'green'
);

update employees e
set salary = case
    when (
        select budget
        from departments d
        where d.dept_name = e.department
    ) > 100000 then salary * 1.10
    else salary * 1.05
end;

with new_emps as (
    insert into employees (first_name, last_name, department, salary, hire_date)
    values
        ('user1', 'test', 'it', 40000, current_date),
        ('user2', 'test', 'it', 41000, current_date),
        ('user3', 'test', 'hr', 42000, current_date),
        ('user4', 'test', 'sales', 43000, current_date),
        ('user5', 'test', 'sales', 44000, current_date)
    returning emp_id
)
update employees
set salary = salary * 1.10
where emp_id in (select emp_id from new_emps);

create table employee_archive (like employees including all);

with moved_employees as (
    delete from employees
    where status = 'inactive'
    returning *
)
insert into employee_archive
select * from moved_employees;

update projects p
set end_date = end_date + interval '30 days'
where p.budget > 50000
  and p.dept_id in (
      select d.dept_id
      from departments d
      join employees e on d.dept_name = e.department
      group by d.dept_id
      having count(e.emp_id) > 3
  );