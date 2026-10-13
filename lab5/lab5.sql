create table employees (
    employee_id integer,
    first_name text,
    last_name text,
    age integer check (age between 18 and 65),
    salary numeric check (salary > 0)
);

create table products_catalog (
    product_id integer,
    product_name text,
    regular_price numeric,
    discount_price numeric,
    constraint valid_discount check (
        regular_price > 0 and
        discount_price > 0 and
        discount_price < regular_price
    )
);

create table bookings (
    booking_id integer,
    check_in_date date,
    check_out_date date,
    num_guests integer check (num_guests between 1 and 10),
    constraint check_dates check (check_out_date > check_in_date)
);

insert into employees values (1, 'иван', 'иванов', 30, 500.00);
insert into employees values (2, 'анна', 'петрова', 25, 700.00);

insert into products_catalog values (1, 'ноутбук', 1000.00, 800.00);
insert into products_catalog values (2, 'телефон', 500.00, 450.00);

insert into bookings values (1, '2026-06-01', '2026-06-05', 2);
insert into bookings values (2, '2026-07-10', '2026-07-15', 4);

create table customers (
    customer_id integer not null,
    email text not null,
    phone text,
    registration_date date not null
);

create table inventory (
    item_id integer not null,
    item_name text not null,
    quantity integer not null check (quantity >= 0),
    unit_price numeric not null check (unit_price > 0),
    last_updated timestamp not null
);

insert into customers values (1, 'test@mail.com', '12345', '2026-01-01');
insert into customers values (2, 'test2@mail.com', null, '2026-01-02');

insert into inventory values (1, 'ручка', 50, 1.50, '2026-01-01 10:00:00');

create table users (
    user_id integer,
    username text,
    email text,
    created_at timestamp,
    constraint unique_username unique (username),
    constraint unique_email unique (email)
);

create table course_enrollments (
    enrollment_id integer,
    student_id integer,
    course_code text,
    semester text,
    constraint unique_student_course unique (student_id, course_code, semester)
);

create table departments (
    dept_id integer primary key,
    dept_name text not null,
    location text
);

insert into departments values (1, 'hr', 'офис а');
insert into departments values (2, 'it', 'офис б');
insert into departments values (3, 'sales', 'офис в');

create table student_courses (
    student_id integer,
    course_id integer,
    enrollment_date date,
    grade text,
    primary key (student_id, course_id)
);

create table employees_dept (
    emp_id integer primary key,
    emp_name text not null,
    dept_id integer references departments(dept_id),
    hire_date date
);

insert into employees_dept values (1, 'олег', 1, '2026-01-10');

create table authors (
    author_id integer primary key,
    author_name text not null,
    country text
);

create table publishers (
    publisher_id integer primary key,
    publisher_name text not null,
    city text
);

create table books (
    book_id integer primary key,
    title text not null,
    author_id integer references authors(author_id),
    publisher_id integer references publishers(publisher_id),
    publication_year integer,
    isbn text unique
);

insert into authors values (1, 'толстой', 'россия');
insert into publishers values (1, 'эксмо', 'москва');
insert into books values (1, 'война и мир', 1, 1, 1869, '123-456');

create table categories (
    category_id integer primary key,
    category_name text not null
);

create table products_fk (
    product_id integer primary key,
    product_name text not null,
    category_id integer references categories(category_id) on delete restrict
);

create table orders (
    order_id integer primary key,
    order_date date not null
);

create table order_items (
    item_id integer primary key,
    order_id integer references orders(order_id) on delete cascade,
    product_id integer references products_fk(product_id),
    quantity integer check (quantity > 0)
);

insert into categories values (1, 'электроника');
insert into products_fk values (1, 'мышь', 1);
insert into orders values (1, '2026-03-01');
insert into order_items values (1, 1, 1, 2);

create table ecommerce_customers (
    customer_id integer primary key,
    name text not null,
    email text not null unique,
    phone text,
    registration_date date not null
);

create table ecommerce_products (
    product_id integer primary key,
    name text not null,
    description text,
    price numeric not null check (price >= 0),
    stock_quantity integer not null check (stock_quantity >= 0)
);

create table ecommerce_orders (
    order_id integer primary key,
    customer_id integer not null references ecommerce_customers(customer_id) on delete restrict,
    order_date date not null,
    total_amount numeric not null check (total_amount >= 0),
    status text not null check (status in ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

create table ecommerce_order_details (
    order_detail_id integer primary key,
    order_id integer not null references ecommerce_orders(order_id) on delete cascade,
    product_id integer not null references ecommerce_products(product_id) on delete restrict,
    quantity integer not null check (quantity > 0),
    unit_price numeric not null check (unit_price >= 0)
);

insert into ecommerce_customers values (1, 'иван', 'ivan@mail.com', '111', '2026-01-01');
insert into ecommerce_customers values (2, 'анна', 'anna@mail.com', '222', '2026-01-02');
insert into ecommerce_customers values (3, 'петр', 'petr@mail.com', '333', '2026-01-03');
insert into ecommerce_customers values (4, 'ольга', 'olga@mail.com', '444', '2026-01-04');
insert into ecommerce_customers values (5, 'сергей', 'sergey@mail.com', '555', '2026-01-05');

insert into ecommerce_products values (1, 'товар а', 'описание а', 10.00, 100);
insert into ecommerce_products values (2, 'товар б', 'описание б', 20.00, 50);
insert into ecommerce_products values (3, 'товар в', 'описание в', 30.00, 20);
insert into ecommerce_products values (4, 'товар г', 'описание г', 40.00, 10);
insert into ecommerce_products values (5, 'товар д', 'описание д', 50.00, 5);

insert into ecommerce_orders values (1, 1, '2026-02-01', 50.00, 'pending');
insert into ecommerce_orders values (2, 2, '2026-02-02', 40.00, 'processing');
insert into ecommerce_orders values (3, 3, '2026-02-03', 30.00, 'shipped');
insert into ecommerce_orders values (4, 4, '2026-02-04', 20.00, 'delivered');
insert into ecommerce_orders values (5, 5, '2026-02-05', 10.00, 'cancelled');

insert into ecommerce_order_details values (1, 1, 1, 5, 10.00);
insert into ecommerce_order_details values (2, 2, 2, 2, 20.00);
insert into ecommerce_order_details values (3, 3, 3, 1, 30.00);
insert into ecommerce_order_details values (4, 4, 4, 1, 20.00);
insert into ecommerce_order_details values (5, 5, 5, 1, 10.00);