# Grouping Sets with Window Functions

We have below data 

|category   |subcategory|sales|year |
|-----------|-----------|-----|-----|
|Food       |Vegetables |10   |2,007|
|Food       |Vegetables |20   |2,008|
|Food       |Fruits     |30   |2,009|
|Food       |Fruits     |40   |2,010|
|Food       |Meat       |50   |2,011|
|Food       |Meat       |60   |2,012|
|Electronics|Phones     |100  |2,007|
|Electronics|Phones     |200  |2,008|
|Electronics|Phones     |300  |2,009|
|Electronics|Laptops    |100  |2,010|
|Electronics|Laptops    |200  |2,011|
|Electronics|Laptops    |300  |2,012|

And we want to grouped by category and subcategory and calculate participation of each subcategory in context of total sales.

1. First step
We use grouping sets to get all grouped data. We get group on 3 levels and we can see it clear with 'grouping(category, subcategory) as grouping_id'.

```sql
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
select *
from grouped 
order by grouping_id;
```
|grouping_id|category   |subcategory|sales_sum|
|-----------|-----------|-----------|---------|
|0          |Electronics|Laptops    |600      |
|0          |Food       |Meat       |110      |
|0          |Food       |Fruits     |70       |
|0          |Food       |Vegetables |30       |
|0          |Electronics|Phones     |600      |
|1          |Food       |           |210      |
|1          |Electronics|           |1,200    |
|2          |           |Vegetables |30       |
|2          |           |Meat       |110      |
|2          |           |Laptops    |600      |
|2          |           |Phones     |600      |
|2          |           |Fruits     |70       |
|3          |           |           |1,410    |



2. Second step
We calculate participation using window functions so we need to get total sales from all data.
So in first thought we use 'sales_sum/ SUM(sales_sum) OVER ()' but it is not correct because we already grouped data.
Now in column sales_sum we have total sales of all data (1410) four times on each group. 


```sql
select 
	grouping_id
	,category
	,subcategory
	,sales_sum
	,ROUND(sales_sum/ SUM(sales_sum) OVER () * 100, 2) AS WRONG__participation
	,SUM(sales_sum) OVER () AS WRONG_participation_divdor
from GROUPED
order BY grouping_id;
```
|grouping_id|category   |subcategory|sales_sum|wrong__participation|wrong_participation_divdor|
|-----------|-----------|-----------|---------|--------------------|--------------------------|
|0          |Electronics|Laptops    |600      |10.64               |5,640                     |
|0          |Food       |Meat       |110      |1.95                |5,640                     |
|0          |Food       |Fruits     |70       |1.24                |5,640                     |
|0          |Food       |Vegetables |30       |0.53                |5,640                     |
|0          |Electronics|Phones     |600      |10.64               |5,640                     |
|1          |Food       |           |210      |3.72                |5,640                     |
|1          |Electronics|           |1,200    |21.28               |5,640                     |
|2          |           |Vegetables |30       |0.53                |5,640                     |
|2          |           |Meat       |110      |1.95                |5,640                     |
|2          |           |Laptops    |600      |10.64               |5,640                     |
|2          |           |Phones     |600      |10.64               |5,640                     |
|2          |           |Fruits     |70       |1.24                |5,640                     |
|3          |           |           |1,410    |25                  |5,640                     |



3. Third step
Insted we have to use grouping levels to get correct participation.
Now grouping_id = 0 participation is 100%.
Now grouping_id = 1 participation is 100%.
Now grouping_id = 2 participation is 100%.
Now grouping_id = 3 participation is 100%.


```sql
select 
	grouping_id
	,category
	,subcategory
	,sales_sum
	,ROUND(sales_sum/ SUM(sales_sum) OVER (PARTITION BY grouping_id) * 100, 2) AS participation
	,SUM(sales_sum) OVER (PARTITION BY grouping_id) AS participation_divdor
from GROUPED
order BY grouping_id;

```
|grouping_id|category   |subcategory|sales_sum|participation|participation_divdor|
|-----------|-----------|-----------|---------|-------------|--------------------|
|0          |Electronics|Laptops    |600      |42.55        |1,410               |
|0          |Food       |Meat       |110      |7.8          |1,410               |
|0          |Food       |Fruits     |70       |4.96         |1,410               |
|0          |Food       |Vegetables |30       |2.13         |1,410               |
|0          |Electronics|Phones     |600      |42.55        |1,410               |
|1          |Food       |           |210      |14.89        |1,410               |
|1          |Electronics|           |1,200    |85.11        |1,410               |
|2          |           |Vegetables |30       |2.13         |1,410               |
|2          |           |Meat       |110      |7.8          |1,410               |
|2          |           |Laptops    |600      |42.55        |1,410               |
|2          |           |Phones     |600      |42.55        |1,410               |
|2          |           |Fruits     |70       |4.96         |1,410               |
|3          |           |           |1,410    |100          |1,410               |



4. Deep dive
We can also calculate participation in context of category or in context of subcategory. 
So on level 0 we see participation of laptops and phones in context of electronics.

```sql
select 
	grouping_id
	,category
	,subcategory
	,sales_sum
	,ROUND(sales_sum/ SUM(sales_sum) OVER (PARTITION BY grouping_id, category) * 100, 2) AS category_participation
	,SUM(sales_sum) OVER (PARTITION BY grouping_id, category) AS category_divdor
	,ROUND(sales_sum/ SUM(sales_sum) OVER (PARTITION BY grouping_id, subcategory) * 100, 2) AS subcategory_participation
	,SUM(sales_sum) OVER (PARTITION BY grouping_id, subcategory) AS subcategory_divdor
from GROUPED
order BY grouping_id;
```
|grouping_id|category   |subcategory|sales_sum|category_participation|category_divdor|subcategory_participation|subcategory_divdor|
|-----------|-----------|-----------|---------|----------------------|---------------|-------------------------|------------------|
|0          |Electronics|Laptops    |600      |50                    |1,200          |100                      |600               |
|0          |Electronics|Phones     |600      |50                    |1,200          |100                      |600               |
|0          |Food       |Fruits     |70       |33.33                 |210            |100                      |70                |
|0          |Food       |Meat       |110      |52.38                 |210            |100                      |110               |
|0          |Food       |Vegetables |30       |14.29                 |210            |100                      |30                |
|1          |Electronics|           |1,200    |100                   |1,200          |85.11                    |1,410             |
|1          |Food       |           |210      |100                   |210            |14.89                    |1,410             |
|2          |           |Fruits     |70       |4.96                  |1,410          |100                      |70                |
|2          |           |Laptops    |600      |42.55                 |1,410          |100                      |600               |
|2          |           |Meat       |110      |7.8                   |1,410          |100                      |110               |
|2          |           |Phones     |600      |42.55                 |1,410          |100                      |600               |
|2          |           |Vegetables |30       |2.13                  |1,410          |100                      |30                |
|3          |           |           |1,410    |100                   |1,410          |100                      |1,410             |