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
		grouping(category, subcategory) as grouping_id
		,category
		,subcategory
		,sum(sales) AS sales_sum
	from data
	group by grouping sets(
		(),
		(category),
		(subcategory),
		(category, subcategory)
	)
)
select 
	grouping_id
	,category
	,subcategory
	,sales_sum
	,ROUND(sales_sum/ SUM(sales_sum) OVER () * 100, 2) AS WRONG__participation
	,SUM(sales_sum) OVER () AS WRONG_participation_divdor
	,ROUND(sales_sum/ SUM(sales_sum) OVER (PARTITION BY grouping_id) * 100, 2) AS participation
	,SUM(sales_sum) OVER (PARTITION BY grouping_id) AS participation_divdor
	,ROUND(sales_sum/ SUM(sales_sum) OVER (PARTITION BY grouping_id, category) * 100, 2) AS category_participation
	,SUM(sales_sum) OVER (PARTITION BY grouping_id, category) AS category_divdor
	,ROUND(sales_sum/ SUM(sales_sum) OVER (PARTITION BY grouping_id, subcategory) * 100, 2) AS subcategory_participation
	,SUM(sales_sum) OVER (PARTITION BY grouping_id, subcategory) AS subcategory_divdor
from GROUPED
order BY grouping_id;

