WITH DATA AS  (
	select 'Food'        as category,
	       'Vegetables'  as subcategory,
	        10          as sales,
	       2007         as year
	union all select 'Food',        'Vegetables',   20,  2008
	union all select 'Food',        'Fruits',       30,  2009
	union all select 'Food',        'Fruits',       40,  2010
	union all select 'Food',        'Meat',         50,  2011
	union all select 'Food',        'Meat',         60,  2012
	union all select 'Electronics', 'Phones',      100,  2007
	union all select 'Electronics', 'Phones',      200,  2008
	union all select 'Electronics', 'Phones',      300,  2009
	union all select 'Electronics', 'Laptops',     100,  2010
	union all select 'Electronics', 'Laptops',     200,  2011
	union all select 'Electronics', 'Laptops',     300,  2012
)
,GROUPED AS (
	select 
		grouping(category, subcategory) grouping_id
		,category
		,subcategory
		,sum(sales) AS sales_sum
        ,SUM(sum(sales)) OVER () AS total_sales
        ,SUM(sum(sales)) OVER (PARTITION BY category) AS category_sales
        ,SUM(sum(sales)) OVER (PARTITION BY subcategory) AS subcategory_sales
        ,SUM(sum(sales)) OVER (PARTITION BY grouping(category, subcategory)) AS total_sales_grouped
        ,SUM(sum(sales)) OVER (PARTITION BY grouping(category, subcategory), category) AS category_sales_grouped
        ,SUM(sum(sales)) OVER (PARTITION BY grouping(category, subcategory), subcategory) AS subcategory_sales_grouped
        -- ,ROUND(sum(sales) / SUM(sum(sales)) OVER () * 100, 2) AS TO_TOTAL_SALES
        -- ,ROUND(sum(sales) / SUM(sum(sales)) OVER (PARTITION BY category) * 100, 2) AS TO_CATEGORY_SALES
        -- ,ROUND(sum(sales) / SUM(sum(sales)) OVER (PARTITION BY subcategory) * 100, 2) AS TO_SUBCATEGORY_SALES
        -- ,round(sum(sales) / SUM(sum(sales)) OVER (PARTITION BY GROUPING(category, subcategory)) * 100, 2) AS TO_TOTAL_SALES
        -- ,round(sum(sales) / SUM(sum(sales)) OVER (PARTITION BY GROUPING(category, subcategory), category) * 100, 2) AS TO_CATEGORY_SALES
        -- ,round(sum(sales) / SUM(sum(sales)) OVER (PARTITION BY GROUPING(category, subcategory), subcategory) * 100, 2) AS TO_SUBCATEGORY_SALES
	from data
	group by grouping sets(
		(category),
		(category, subcategory)
	)
)
SELECT * 
FROM GROUPED
order by grouping_id;

select 
	grouping_id
	,category
	,subcategory
	,sales_sum

	,ROUND(sales_sum/ SUM(sales_sum) OVER (PARTITION BY category) * 100, 2) AS WRONG_category_participation
	,SUM(sales_sum) OVER (PARTITION BY category) AS WRONG_category_divdor

	,ROUND(sales_sum/ SUM(sales_sum) OVER (PARTITION BY grouping_id) * 100, 2) AS category_participation
	,SUM(sales_sum) OVER (PARTITION BY grouping_id) AS category_divdor

from GROUPED
order BY grouping_id