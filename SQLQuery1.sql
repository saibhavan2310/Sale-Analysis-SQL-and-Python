select top 10 productid,sum(salesprice) as sales from df_orders
group by productid
order by sales desc

--top 5 selling in region
with cte as (
    select region, productid, sum(salesprice) as sales 
    from df_orders
    group by region, productid
),
cte2 as (
    select *, ROW_NUMBER() over (partition by region order by sales desc) as rn 
    from cte
)
select * 
from cte2
where rn <= 5;

--month over month 2022 vs 2023
with cte44 as (
    select 
        Month(orderdate) as order_month,
        Year(orderdate) as order_year,
        round(sum(salesprice), 2) as total_sales
    from df_orders
    group by month(orderdate), year(orderdate)
)

select order_month,
sum(case when order_year=2022 then total_sales else 0 end) as salesyear2022,
sum(case when order_year=2023 then total_sales else 0 end) as salesyear2023
from cte44
group by order_month
order by order_month

--each cat whcih month had highest sales
with cte as (
select category,month(orderdate) as monthly,
round(sum(salesprice),2) as sales 
from df_orders
group by category,month(orderdate)
--order by category,month(orderdate), sales desc
),
cte2 as(
select *,
ROW_NUMBER() over (partition by category order by sales desc) as rn 
from cte
)

select * from cte2
where rn = 1

--subcategory with highest sales

with cte44 as (
    select
		subcategory,
        Year(orderdate) as order_year,
        round(sum(salesprice), 2) as total_sales
    from df_orders
    group by subcategory, year(orderdate)
),
cte2 as(
select subcategory,
sum(case when order_year=2022 then total_sales else 0 end) as salesyear2022,
sum(case when order_year=2023 then total_sales else 0 end) as salesyear2023
from cte44
group by subcategory
)

select top 1 *,salesyear2023-salesyear2022 as 'profit/loss' from cte2