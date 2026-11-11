-- part 2.1
create view employee_details as
select
    e.emp_id,
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location
from employees e
inner join departments d on e.dept_id = d.dept_id;

-- part 2.2
create view dept_statistics as
select
    d.dept_name,
    count(e.emp_id) as employee_count,
    avg(e.salary) as avg_salary,
    max(e.salary) as max_salary,
    min(e.salary) as min_salary
from departments d
left join employees e on d.dept_id = e.dept_id
group by d.dept_id, d.dept_name;

-- part 2.3
create view project_overview as
select
    p.project_name,
    p.budget,
    d.dept_name,
    d.location,
    count(e.emp_id) as team_size
from projects p
join departments d on p.dept_id = d.dept_id
left join employees e on d.dept_id = e.dept_id
group by p.project_id, p.project_name, p.budget, d.dept_name, d.location;

-- part 2.4
create view high_earners as
select
    e.emp_name,
    e.salary,
    d.dept_name
from employees e
left join departments d on e.dept_id = d.dept_id
where e.salary > 55000;

-- part 3.1
create or replace view employee_details as
select
    e.emp_id,
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location,
    case
        when e.salary > 60000 then 'high'
        when e.salary > 50000 then 'medium'
        else 'standard'
    end as salary_grade
from employees e
inner join departments d on e.dept_id = d.dept_id;

-- part 3.2
alter view high_earners rename to top_performers;

-- part 3.3
create view temp_view as
select *
from employees
where salary < 50000;

drop view temp_view;

-- part 4.1
create view employee_salaries as
select emp_id, emp_name, dept_id, salary
from employees;

-- part 4.2
update employee_salaries
set salary = 52000
where emp_name = 'john smith';

-- part 4.3
insert into employee_salaries (emp_id, emp_name, dept_id, salary)
values (6, 'alice johnson', 102, 58000);

-- part 4.4
create view it_employees as
select emp_id, emp_name, dept_id, salary
from employees
where dept_id = 101
with local check option;

-- part 5.1
create materialized view dept_summary_mv as
select
    d.dept_id,
    d.dept_name,
    count(distinct e.emp_id) as total_employees,
    coalesce(sum(e.salary), 0) as total_salaries,
    count(distinct p.project_id) as total_projects,
    coalesce(sum(p.budget), 0) as total_project_budget
from departments d
left join employees e on d.dept_id = e.dept_id
left join projects p on d.dept_id = p.dept_id
group by d.dept_id, d.dept_name
with data;

-- part 5.2
insert into employees (emp_id, emp_name, dept_id, salary)
values (8, 'charlie brown', 101, 54000);

refresh materialized view dept_summary_mv;

-- part 5.3
create unique index idx_dept_summary_mv_dept_id on dept_summary_mv (dept_id);

refresh materialized view concurrently dept_summary_mv;

-- part 5.4
create materialized view project_stats_mv as
select
    p.project_name,
    p.budget,
    d.dept_name,
    count(e.emp_id) as assigned_employees
from projects p
join departments d on p.dept_id = d.dept_id
left join employees e on d.dept_id = e.dept_id
group by p.project_id, p.project_name, p.budget, d.dept_name
with no data;

refresh materialized view project_stats_mv;

-- part 6.1
create role analyst nologin;
create role data_viewer with login password 'viewer123';
create role report_user with login password 'report456';

-- part 6.2
create role db_creator with createdb login password 'creator789';
create role user_manager with createrole login password 'manager101';
create role admin_user with superuser login password 'admin999';

-- part 6.3
grant select on employees, departments, projects to analyst;
grant all privileges on employee_details to data_viewer;
grant select, insert on employees to report_user;

-- part 6.4
create role hr_team nologin;
create role finance_team nologin;
create role it_team nologin;

create role hr_user1 with login password 'hr001';
create role hr_user2 with login password 'hr002';
create role finance_user1 with login password 'fin001';

grant hr_team to hr_user1, hr_user2;
grant finance_team to finance_user1;

grant select, update on employees to hr_team;
grant select on dept_statistics to finance_team;

-- part 6.5
revoke update on employees from hr_team;
revoke hr_team from hr_user2;
revoke all privileges on employee_details from data_viewer;

-- part 6.6
alter role analyst with login password 'analyst123';
alter role user_manager with superuser;
alter role analyst password null;
alter role data_viewer with connection limit 5;

-- part 7.1
create role read_only nologin;
grant select on all tables in schema public to read_only;

create role junior_analyst with login password 'junior123';
create role senior_analyst with login password 'senior123';

grant read_only to junior_analyst, senior_analyst;

grant insert, update on employees to senior_analyst;

-- part 7.2
create role project_manager with login password 'pm123';

alter view dept_statistics owner to project_manager;
alter table projects owner to project_manager;

-- part 7.3
create role temp_owner with login;
create table temp_table (id int);
alter table temp_table owner to temp_owner;

reassign owned by temp_owner to postgres;
drop owned by temp_owner;
drop role temp_owner;

-- part 7.4
create view hr_employee as
select * from employees
where dept_id = 102;

grant select on hr_employee to hr_team;

create view finance_employee_view as
select emp_id, emp_name, salary
from employees;

grant select on finance_employee_view to finance_team;

-- part 8.1
create view dept_dashboard as
select
    d.dept_name,
    d.location,
    count(distinct e.emp_id) as employee_count,
    round(coalesce(avg(e.salary), 0), 2) as avg_salary,
    count(distinct p.project_id) as active_projects_count,
    coalesce(sum(p.budget), 0) as total_project_budget,
    round(
        case
            when count(distinct e.emp_id) = 0 then 0
            else coalesce(sum(p.budget), 0) / count(distinct e.emp_id)
        end, 2
    ) as budget_per_employee
from departments d
left join employees e on d.dept_id = e.dept_id
left join projects p on d.dept_id = p.dept_id
group by d.dept_id, d.dept_name, d.location;

-- part 8.2
alter table projects
add column created_date timestamp default current_timestamp;

create view high_budget_projects as
select
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
    case
        when p.budget > 150000 then 'critical review required'
        when p.budget > 100000 then 'management approval needed'
        else 'standard process'
    end as approval_status
from projects p
left join departments d on p.dept_id = d.dept_id
where p.budget > 75000;

-- part 8.3
create role viewer_role nologin;
grant select on all tables in schema public to viewer_role;

create role entry_role nologin;
grant viewer_role to entry_role;
grant insert on employees, projects to entry_role;

create role analyst_role nologin;
grant entry_role to analyst_role;
grant update on employees, projects to analyst_role;

create role manager_role nologin;
grant analyst_role to manager_role;
grant delete on employees, projects to manager_role;

create role alice with login password 'alice123';
create role bob with login password 'bob123';
create role charlie with login password 'charlie123';

grant viewer_role to alice;
grant analyst_role to bob;
grant manager_role to charlie;