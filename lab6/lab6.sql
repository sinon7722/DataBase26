create table departments (
    dept_id int primary key,
    dept_name varchar(50),
    location varchar(50)
);

create table employees (
    emp_id int primary key,
    emp_name varchar(50),
    dept_id int,
    salary decimal(10, 2)
);

create table projects (
    project_id int primary key,
    project_name varchar(50),
    dept_id int,
    budget decimal(10, 2)
);

insert into departments (dept_id, dept_name, location) values
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');

insert into employees (emp_id, emp_name, dept_id, salary) values
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', null, 45000);

insert into projects (project_id, project_name, dept_id, budget) values
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', null, 200000);

select e.emp_name, d.dept_name
from employees e cross join departments d;

select e.emp_name, d.dept_name
from employees e, departments d;

select e.emp_name, d.dept_name
from employees e inner join departments d on true;

select e.emp_name, p.project_name
from employees e cross join projects p;

select e.emp_name, d.dept_name, d.location
from employees e
inner join departments d on e.dept_id = d.dept_id;

select emp_name, dept_name, location
from employees
inner join departments using (dept_id);

select emp_name, dept_name, location
from employees
natural inner join departments;

select e.emp_name, d.dept_name, p.project_name
from employees e
inner join departments d on e.dept_id = d.dept_id
inner join projects p on d.dept_id = p.dept_id;

select e.emp_name, e.dept_id as emp_dept, d.dept_id as dept_dept, d.dept_name
from employees e
left join departments d on e.dept_id = d.dept_id;

select emp_name, dept_id, dept_name
from employees
left join departments using (dept_id);

select e.emp_name, e.dept_id
from employees e
left join departments d on e.dept_id = d.dept_id
where d.dept_id is null;

select d.dept_name, count(e.emp_id) as employee_count
from departments d
left join employees e on d.dept_id = e.dept_id
group by d.dept_id, d.dept_name
order by employee_count desc;

select e.emp_name, d.dept_name
from employees e
right join departments d on e.dept_id = d.dept_id;

select e.emp_name, d.dept_name
from departments d
left join employees e on e.dept_id = d.dept_id;

select d.dept_name, d.location
from employees e
right join departments d on e.dept_id = d.dept_id
where e.emp_id is null;

select e.emp_name, e.dept_id as emp_dept, d.dept_id as dept_dept, d.dept_name
from employees e
full join departments d on e.dept_id = d.dept_id;

select d.dept_name, p.project_name, p.budget
from departments d
full join projects p on d.dept_id = p.dept_id;

select
    case
        when e.emp_id is null then 'Department without employees'
        when d.dept_id is null then 'Employee without department'
        else 'Matched'
    end as record_status,
    e.emp_name,
    d.dept_name
from employees e
full join departments d on e.dept_id = d.dept_id
where e.emp_id is null or d.dept_id is null;

select e.emp_name, d.dept_name, e.salary
from employees e
left join departments d on e.dept_id = d.dept_id and d.location = 'Building A';

select e.emp_name, d.dept_name, e.salary
from employees e
left join departments d on e.dept_id = d.dept_id
where d.location = 'Building A';

select e.emp_name, d.dept_name, e.salary
from employees e inner join departments d on e.dept_id = d.dept_id and d.location = 'Building A';

select e.emp_name, d.dept_name, e.salary
from employees e inner join departments d on e.dept_id = d.dept_id
where d.location = 'Building A';

select
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
from departments d
left join employees e on d.dept_id = e.dept_id
left join projects p on d.dept_id = p.dept_id
order by d.dept_name, e.emp_name;

alter table employees add column manager_id int;

update employees set manager_id = 3 where emp_id = 1;
update employees set manager_id = 3 where emp_id = 2;
update employees set manager_id = null where emp_id = 3;
update employees set manager_id = 3 where emp_id = 4;
update employees set manager_id = 3 where emp_id = 5;

select
    e.emp_name as employee,
    m.emp_name as manager
from employees e
left join employees m on e.manager_id = m.emp_id;

select d.dept_name, avg(e.salary) as avg_salary
from departments d
inner join employees e on d.dept_id = e.dept_id
group by d.dept_id, d.dept_name
having avg(e.salary) > 50000;