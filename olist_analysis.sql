select 
table_name,
column_name,
data_type,
is_nullable
from information_schema.columns
where 
table_schema = 'olist_db'
order by table_name;

alter table orders add primary key (order_id);
alter table customers add primary key (customer_id);
alter table products add primary key (product_id);
alter table sellers add primary key (seller_id);
alter table order_items add primary key (order_id, order_item_id);

alter table orders 
add constraint fk_orders_customers
foreign key (customer_id) references customers(customer_id);

alter table order_items 
add constraint fk_items_orders
foreign key (order_id) references orders(order_id);

alter table order_items 
add constraint fk_items_products
foreign key (product_id) references products(product_id);

alter table order_payments 
add constraint fk_payments_orders
foreign key (order_id) references orders(order_id);

alter table order_items 
add constraint fk_items_sellers
foreign key (seller_id) references sellers(seller_id);

alter table order_reviews
add constraint fk_reviews_orders
foreign key (order_id) references orders(order_id);

describe orders;

CREATE OR REPLACE VIEW v_orders_kpi AS
select
o.order_id,
o.order_purchase_timestamp,
o.order_status,

c.customer_unique_id,
c.customer_city,
c.customer_state,

oi.total_price,
oi.total_freight,

op.total_payment,
coalesce(r.review_score, 0) as review_score

from orders o 
left join customers c 
on o.customer_id = c.customer_id

left join (
select order_id,
sum(price) as total_price,
sum(freight_value) as total_freight
from order_items
group by order_id
)
oi on o.order_id = oi.order_id

left join (
select order_id, 
sum(payment_value) as total_payment
from order_payments
group by order_id
)
op on o.order_id = op.order_id

LEFT JOIN (
    SELECT 
        order_id,
        cast(avg(review_score) AS unsigned) as review_score
    FROM order_reviews
    GROUP BY order_id
) r 
ON o.order_id = r.order_id
where o.order_status = 'delivered';

SELECT order_id, COUNT(*)
FROM order_reviews
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT COUNT(*), COUNT(DISTINCT order_id)
FROM v_orders_kpi;