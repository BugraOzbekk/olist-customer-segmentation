WITH TopSpenders AS (

    SELECT  oc.customer_id,
            SUM(op.payment_value) AS TotalPayment
    FROM olist_customers oc
    JOIN olist_orders oo ON oc.customer_id=oo.customer_id
    JOIN olist_order_payments op ON op.order_id=oo.order_id
    GROUP BY oc.customer_id
),
RankedSpenders AS (
    SELECT
    customer_id,
    TotalPayment,
    ROW_NUMBER() OVER( ORDER BY TotalPayment DESC) AS spend_rank
    FROM TopSpenders
),
TopBuyers AS (
   
    SELECT  oc.customer_id,
            COUNT(oo.order_id) AS TotalOrders
    FROM olist_customers oc
    JOIN olist_orders oo ON oc.customer_id=oo.customer_id
    JOIN olist_order_payments op ON op.order_id=oo.order_id
    GROUP BY oc.customer_id
),
RankedBuyers AS (
    SELECT
    customer_id,
    TotalOrders,
    ROW_NUMBER() OVER( ORDER BY TotalOrders DESC) AS order_rank
    FROM TopBuyers
),
Top10Spenders AS (
    SELECT customer_id, TotalPayment FROM RankedSpenders WHERE spend_rank <= 10
),
Top10Buyers AS (
    SELECT customer_id, TotalOrders FROM RankedBuyers WHERE order_rank <= 10
)
SELECT 
    COALESCE(ts.customer_id, tb.customer_id) AS customer_id,
    ts.TotalPayment,
    tb.TotalOrders
FROM Top10Spenders ts
FULL OUTER JOIN Top10Buyers tb ON ts.customer_id = tb.customer_id;
