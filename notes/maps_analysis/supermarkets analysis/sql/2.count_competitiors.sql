-- CREATE SNAPSHOT OF DISTANCE BETWEEN SUPERMARKETS
create table gis.supermarkets_distance_between_snapshot as (
	with crossed_data as (
		select 
			s1.id,
			s1.brand,
			s1.location,
			s2.id as id2,
			s2.brand as brand2,
			s2.location as location2,
--			ST_Distance(s1.location, s2."location") AS distance,
			ST_Distance(ST_Transform(s1.location, 2180), ST_Transform(s2.location, 2180)) / 1000 AS distance_km
		from gis.supermarkets s1
		cross join gis.supermarkets s2
		where s1.brand <> s2.brand
	)
	select *
	from crossed_data 
	where distance_km <= 10
);


select * from gis.supermarkets_distance_between_snapshot
where id = '9431902214'
and distance_km <= 1;

-- PLACES WITH HIGHEST NUMBER OF COMPETITORS in RANGE 0-1km
with competitors_count as (
select 
    id as "ID", 
    brand as "Brand", 
    ST_Y(location) || ', ' || ST_X(location) as "Location",
    count(distinct id2) as "Total competitors",
    count(case when brand2 = 'Biedronka' then id2 else null end) as "Biedronka",
    count(case when brand2 = 'Lidl' then id2 else null end) as "Lidl",
    count(case when brand2 = 'Dino' then id2 else null end) as "Dino",
    row_number() over (partition by brand order by count(distinct id2) desc) as rn
from gis.supermarkets_distance_between_snapshot 
where 1=1
and distance_km <= 1
group by id, brand, location
having count(distinct id2) > 1
order by count(distinct id2) desc
)
select * from competitors_count
where rn <= 1;




-- AVERAGE COMPETITORS COUNT IN RANGE 0-1km, 1-5km, 5-10km, 10km FOR EACH BRAND
with competitors_count as (
SELECT 
    id, 
    brand,
    location,
    count(case when distance_km <= 1 then id2 else null end) as count_competitors_0_1km,
    count(case when distance_km > 1 and distance_km <= 5 then id2 else null end) as count_competitors_1_5km,
    count(case when distance_km > 5 and distance_km <= 10 then id2 else null end) as count_competitors_5_10km,
    count(distinct id2) as total_count_competitors_10km
FROM gis.supermarkets_distance_between_snapshot
group by id, brand, location
)
select 
    brand as "Brand", 
    round(avg(count_competitors_0_1km), 2) as "Average competitors in range 0-1km",
    round(avg(count_competitors_1_5km), 2) as "Average competitors in range 1-5km",
    round(avg(count_competitors_5_10km), 2) as "Average competitors in range 5-10km",
    round(avg(total_count_competitors_10km), 2) as "Average competitors in range 10km"
from competitors_count      
group by brand
order by "Average competitors in range 0-1km" desc;











