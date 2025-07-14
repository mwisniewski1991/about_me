CREATE TABLE gis.supermarkets_competition AS (
WITH competition_analysis AS (
    SELECT 
        s1.id,
        s1.brand,
        s1.location,
        CASE 
            WHEN EXISTS (
                SELECT 1 
                FROM gis.supermarkets s2 
                WHERE s1.id != s2.id 
                AND   s1.brand != s2.brand 
                AND   ST_Distance(ST_Transform(s1.location, 2180), ST_Transform(s2.location, 2180)) <= 1000  -- 1km promień
            ) THEN true 
            ELSE false 
        END as has_competition
    FROM gis.supermarkets s1
    GROUP BY s1.id, s1.brand, s1.location
)
SELECT
    id,    
    brand, 
    location,
    has_competition
FROM competition_analysis
);



SELECT 
    brand as "Brand", 
    count(distinct id) as "Number of supermarkets",
    count(distinct case when has_competition = true then id else Null end) as "Supermarkets with competition",
    count(distinct case when has_competition = false then id else Null end) as "Supermarkets without competition",
    round(count(distinct case when has_competition = true then id else Null end)::decimal / count(distinct id)::decimal, 2) * 100 as "Ratio of supermarkets with competition"
FROM gis.supermarkets_competition
group by brand;