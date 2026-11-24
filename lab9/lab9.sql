--2.1
create or replace function rental_days(p_rental_id int)
returns int as $$
declare
    v_days int;
begin
    select end_date - start_date
    into v_days
    from rentals
    where rental_id = p_rental_id;

    return v_days;
end;
$$ language plpgsql;

select rental_days(2);
select rental_days(11);
select rental_days(19);
select rental_days(999);

--2.2
create or replace function member_rental_count(p_member_id int)
returns int as $$
declare
    v_count int;
begin
    select count(*)::int
    into v_count
    from rentals
    where member_id = p_member_id;

    return v_count;
end;
$$ language plpgsql;

select member_rental_count(1);
select member_rental_count(5);
select member_rental_count(6);
select member_rental_count(99);

--2.3
create or replace function station_city(p_station_id int)
returns varchar as $$
declare
    v_city varchar;
begin
    select city
    into v_city
    from stations
    where station_id = p_station_id;

    return v_city;
end;
$$ language plpgsql;

select station_city(30);
select station_city(77);

--2.4
select rental_id, member_id, rental_days(rental_id) as duration
from rentals
where rental_days(rental_id) > 4
order by duration desc;

--3.1
create or replace function fee_with_discount(p_fee numeric, p_percent numeric)
returns numeric as $$
begin
    return round(p_fee * (1 - p_percent / 100.0), 2);
end;
$$ language plpgsql;

select fee_with_discount(74.00, 15);

--3.2
create or replace function member_stats(
    p_member_id int,
    out rental_cnt int,
    out total_fee numeric,
    out last_start date)
as $$
begin
    select count(*)::int, coalesce(sum(fee), 0), max(start_date)
    into rental_cnt, total_fee, last_start
    from rentals
    where member_id = p_member_id;
end;
$$ language plpgsql;

select member_stats(3);
select * from member_stats(3);
select * from member_stats(6);

--3.3
create or replace function apply_late_fee(inout p_fee numeric)
as $$
begin
    p_fee := p_fee + 5.00;
end;
$$ language plpgsql;

select apply_late_fee(fee) from rentals where rental_id = 1;

--3.4
create or replace function fee_summary(
    variadic p_fees numeric[],
    out total numeric,
    out average numeric,
    out largest numeric)
as $$
begin
    select sum(p_fees[i]), round(avg(p_fees[i]), 2), max(p_fees[i])
    into total, average, largest
    from generate_subscripts(p_fees, 1) g(i);
end;
$$ language plpgsql;

select * from fee_summary(13.50, 35.00, 18.50, 31.50);

--4.1
create or replace function total_fees(p_member_id int)
returns numeric as $$
declare
    v_total numeric;
begin
    select coalesce(sum(fee), 0) into v_total
    from rentals where member_id = p_member_id;
    return v_total;
end;
$$ language plpgsql;

select total_fees(1);
select total_fees(6);

--4.2
create or replace function total_fees(p_member_id int, p_from_date date)
returns numeric as $$
declare
    v_total numeric;
begin
    select coalesce(sum(fee), 0) into v_total
    from rentals
    where member_id = p_member_id and start_date >= p_from_date;
    return v_total;
end;
$$ language plpgsql;

select total_fees(1, date '2024-01-01');
select total_fees(1, date '2025-01-01');

--4.3
create or replace function total_fees(
    p_member_id int,
    p_from_date date default date '2025-01-01')
returns numeric as $$
declare
    v_total numeric;
begin
    select coalesce(sum(fee), 0) into v_total
    from rentals
    where member_id = p_member_id and start_date >= p_from_date;
    return v_total;
end;
$$ language plpgsql;

-- select total_fees(1);

--4.4
drop function total_fees(integer);
select total_fees(1);

--4.5
create or replace function total_fees(p_full_name varchar)
returns numeric as $$
declare
    v_total numeric;
begin
    select coalesce(sum(r.fee), 0) into v_total
    from members m
    left join rentals r on m.member_id = r.member_id
    where m.full_name = p_full_name;
    return v_total;
end;
$$ language plpgsql;

select total_fees('Aisha Nurlanova');
select total_fees(1);

--5.1
create or replace function find_bikes(p_pattern varchar)
returns table(found_id int, found_model varchar, found_rate numeric) as $$
begin
    return query
    select bike_id, model, daily_rate
    from bikes
    where model ilike p_pattern
    order by bike_id;
end;
$$ language plpgsql;

select * from find_bikes('%road%');
select * from find_bikes('%Mini');
select find_bikes('%road%');

--5.2
create or replace function member_history(p_member_id int)
returns table(
    rental_id int,
    model varchar,
    station_name varchar,
    duration int,
    fee numeric) as $$
begin
    return query
    select r.rental_id, b.model, s.station_name, (r.end_date - r.start_date)::int, r.fee
    from rentals r
    join bikes b on r.bike_id = b.bike_id
    join stations s on b.station_id = s.station_id
    where r.member_id = p_member_id
    order by r.start_date;
end;
$$ language plpgsql;

select * from member_history(3);

--5.3
create or replace function bike_list(p_station_id int)
returns table(out_bike_id int, out_model varchar) as $$
begin
    return query
    select bike_id, model from bikes where station_id = p_station_id;
end;
$$ language plpgsql;

select * from bike_list(10);

drop function bike_list(int);

create or replace function bike_list(p_station_id int)
returns table(bike_id int, model varchar) as $$
begin
    return query
    select b.bike_id, b.model from bikes b where b.station_id = p_station_id;
end;
$$ language plpgsql;

select * from bike_list(10);

--5.4
create or replace function station_board(p_city varchar)
returns table(s_name varchar, s_bikes int, s_free int) as $$
begin
    return query
    select
        s.station_name,
        count(b.bike_id)::int,
        (s.capacity - count(b.bike_id))::int
    from stations s
    left join bikes b on s.station_id = b.station_id
    where s.city = p_city
    group by s.station_id, s.station_name, s.capacity
    order by s.station_id;
end;
$$ language plpgsql;

select * from station_board('Almaty');

--6.1
do $$
<<rental_report>>
declare
    total_rentals integer := 0;
begin
    select count(*) into total_rentals from rentals;
    raise notice 'the rentals table holds % rows.', total_rentals;
end rental_report $$;

--6.2
do $$
<<outer_block>>
declare
    fee_total numeric;
begin
    select coalesce(sum(fee), 0) into fee_total from rentals;
    raise notice '1. outer before subblock: %', fee_total;

    declare
        fee_total numeric;
    begin
        select coalesce(sum(fee), 0) into fee_total
        from rentals where start_date >= date '2025-01-01';

        raise notice '2. subblock own value: %', fee_total;
        raise notice '3. outer value via label: %', outer_block.fee_total;
    end;

    raise notice '4. outer after subblock: %', fee_total;
end outer_block $$;

--6.3
do $$
declare
    sub_var int := 10;
begin
    begin
        raise notice 'first subblock: %', sub_var;
    end;
    begin
        sub_var := sub_var + 5;
        raise notice 'second subblock: %', sub_var;
    end;
end $$;

--6.4
create or replace function fee_split(
    p_from_date date,
    out before_total numeric,
    out after_total numeric)
as $$
begin
    select
        coalesce(sum(case when start_date < p_from_date then fee else 0 end), 0),
        coalesce(sum(case when start_date >= p_from_date then fee else 0 end), 0)
    into before_total, after_total
    from rentals;
end;
$$ language plpgsql;

select before_total, after_total, (before_total + after_total) as grand_total
from fee_split(date '2025-01-01');

--7.1
create or replace function station_load(
    p_station_id int,
    out bikes_parked int,
    out capacity_pct numeric)
as $$
declare
    v_capacity int;
begin
    select s.capacity, count(b.bike_id)::int
    into v_capacity, bikes_parked
    from stations s
    left join bikes b on s.station_id = b.station_id
    where s.station_id = p_station_id
    group by s.station_id, s.capacity;

    if v_capacity is null or v_capacity = 0 then
        capacity_pct := null;
    else
        capacity_pct := round((bikes_parked::numeric / v_capacity) * 100, 1);
    end if;
end;
$$ language plpgsql;

select s.station_id, s.station_name, l.*
from stations s, lateral station_load(s.station_id) l;

--7.2
create or replace function top_members(p_limit int default 3)
returns table(member_name varchar, rental_count int, total_spent numeric) as $$
begin
    return query
    select
        m.full_name,
        count(r.rental_id)::int,
        coalesce(sum(r.fee), 0)
    from members m
    left join rentals r on m.member_id = r.member_id
    group by m.member_id, m.full_name
    order by total_spent desc, m.member_id asc
    limit p_limit;
end;
$$ language plpgsql;

select * from top_members();
select * from top_members(6);

--7.3
create or replace function rental_invoice(p_rental_id int)
returns table(
    member_name varchar,
    bike_model varchar,
    days int,
    amount_owed numeric,
    status varchar) as $$
begin
    return query
    select
        m.full_name,
        b.model,
        (coalesce(r.end_date, current_date) - r.start_date)::int as calc_days,
        round((coalesce(r.end_date, current_date) - r.start_date) * b.daily_rate, 2),
        (case when r.end_date is null then 'OPEN' else 'CLOSED' end)::varchar
    from rentals r
    join members m on r.member_id = m.member_id
    join bikes b on r.bike_id = b.bike_id
    where r.rental_id = p_rental_id;
end;
$$ language plpgsql;

select * from rental_invoice(11);
select * from rental_invoice(19);

--7.4
create or replace function city_report(p_city varchar)
returns table(member_cnt int, rental_cnt int, total_revenue numeric) as $$
begin
    return query
    select
        count(distinct m.member_id)::int,
        count(r.rental_id)::int,
        coalesce(sum(r.fee), 0)
    from members m
    left join rentals r on m.member_id = r.member_id
    where m.city = p_city;
end;
$$ language plpgsql;

create or replace function city_report(p_city varchar, p_from_date date)
returns table(member_cnt int, rental_cnt int, total_revenue numeric) as $$
begin
    return query
    select
        count(distinct m.member_id)::int,
        count(r.rental_id)::int,
        coalesce(sum(r.fee), 0)
    from members m
    left join rentals r
        on m.member_id = r.member_id
        and r.start_date >= p_from_date
    where m.city = p_city;
end;
$$ language plpgsql;

select * from city_report('Almaty');
select * from city_report('Almaty', date '2025-01-01');
