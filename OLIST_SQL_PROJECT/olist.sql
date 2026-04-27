USE COMMERCE
GO

-- 1. Primary Keys („‘ „ÊÃÊœ… ›Ì CSV)
ALTER TABLE olist_customers_dataset 
ADD CONSTRAINT PK_Customers PRIMARY KEY (customer_id);

ALTER TABLE olist_orders_dataset 
ADD CONSTRAINT PK_Orders PRIMARY KEY (order_id);

ALTER TABLE olist_order_items_dataset 
ADD CONSTRAINT PK_OrderItems PRIMARY KEY (order_id, order_item_id);

ALTER TABLE olist_products_dataset 
ADD CONSTRAINT PK_Products PRIMARY KEY (product_id);

ALTER TABLE olist_sellers_dataset 
ADD CONSTRAINT PK_Sellers PRIMARY KEY (seller_id);
------------------------------
ALTER TABLE olist_orders_dataset
ADD CONSTRAINT FK_ORDER_CUSTOMERS
FOREIGN KEY (customer_id) REFERENCES olist_customers_dataset(customer_id);

ALTER TABLE olist_order_items_dataset
ADD CONSTRAINT FK_OrderItems_Orders
FOREIGN KEY (order_id) REFERENCES olist_orders_dataset(order_id);


ALTER TABLE olist_order_items_dataset 
ADD CONSTRAINT FK_OrderItems_Products 
FOREIGN KEY (product_id) REFERENCES olist_products_dataset(product_id);


ALTER TABLE olist_order_items_dataset 
ADD CONSTRAINT FK_OrderItems_Sellers 
FOREIGN KEY (seller_id) REFERENCES olist_sellers_dataset(seller_id);

ALTER TABLE olist_order_payments_dataset 
ADD CONSTRAINT FK_Payments_Orders 
FOREIGN KEY (order_id) REFERENCES olist_orders_dataset(order_id);

ALTER TABLE olist_order_reviews_dataset 
ADD CONSTRAINT FK_Reviews_Orders 
FOREIGN KEY (order_id) REFERENCES olist_orders_dataset(order_id);

select*
from olist_customers_dataset oc
join olist_orders_dataset oo on oo.customer_id=oc.customer_id;

create nonclustered index ix_Orders_Customer on olist_orders_dataset(customer_id);
create nonclustered index IX_OrderItems_Order on olist_order_items_dataset(order_id);
CREATE NONCLUSTERED INDEX IX_OrderItems_Product ON olist_order_items_dataset(product_id);
CREATE NONCLUSTERED INDEX IX_OrderItems_Seller ON olist_order_items_dataset(seller_id);
CREATE NONCLUSTERED INDEX IX_Payments_Order ON olist_order_payments_dataset(order_id);
CREATE NONCLUSTERED INDEX IX_Reviews_Order ON olist_order_reviews_dataset(order_id);
CREATE NONCLUSTERED INDEX IX_Orders_Delivered ON olist_orders_dataset(order_delivered_customer_date);
CREATE INDEX IX_orders_customer_timestamp 
ON olist_orders_dataset (customer_id, order_purchase_timestamp DESC);

select*
from olist_customers_dataset
select*
from olist_geolocation_dataset
select*
from olist_order_items_dataset
select*
from olist_order_payments_dataset
select*
from olist_order_reviews_dataset
select*
from olist_orders_dataset
select*
from olist_products_dataset
select*
from olist_sellers_dataset

SELECT*
FROM product_category_name_translation
 

----«⁄·Ì ⁄‘— ⁄„·«¡
go
create view vw_topcustomerss as
select  c.customer_unique_id,
COUNT(o.order_id) as TotalOrders,
SUM(p.payment_value) as TotalLifeTime,
DENSE_RANK() over(order by sum(p.payment_value ) desc) as CustomerRank
from olist_customers_dataset c
join olist_orders_dataset o on c.customer_id=o.customer_id
join olist_order_payments_dataset p on o.order_id=p.order_id
where o.order_status='delivered'
group by c.customer_unique_id;
go
select* from vw_topcustomers
----------------------------------------------------------
----«”—⁄ ⁄‘— „œ‰  ”·Ì„ ··«Ê—œ«—« 
go
CREATE VIEW VW_FASTCITESs AS
SELECT top 10
C.customer_city,
COUNT(  O.order_id    ) AS TotalOrders,
AVG(datediff( DAY,o.order_purchase_timestamp,o.order_delivered_customer_date      ) ) as AvgDeliveryDay,
AVG( r.review_score  )as avgscore
FROM olist_customers_dataset C
JOIN olist_orders_dataset O ON C.customer_id=O.customer_id
JOIN olist_order_reviews_dataset R ON O.order_id=R.order_id
where o.order_status='delivered'
group by c.customer_city
order by AvgDeliveryDay desc;
go
 select* from VW_FASTCITES;
 ----------------------------------------------
 -----  ÿÊ— «·«Ì—«œ« 
 with monthlyRevenue as
 (
 select
 MONTH( o.order_purchase_timestamp)as month,
 YEAR( o.order_purchase_timestamp    )as year,
 sum( p.payment_value )as revenue
 from olist_orders_dataset o
 join olist_order_payments_dataset p on o.order_id=p.order_id
 group by MONTH( o.order_purchase_timestamp), YEAR( o.order_purchase_timestamp    )
 ),
  revenuetrends as
 (
 select*,
 LAG(  revenue) over ( order by year,month) as previousGrowth,
 revenue- LAG(  revenue) over ( order by year,month) as growth
 from monthlyRevenue
 )
 select* from revenuetrends where growth>0;
 -------------------------------
 --- «ﬂÀ— ›∆«  «·„‰ Ã«  »Ì⁄«
 go
CREATE VIEW VW_ProductRanking AS
SELECT TOP 10
    COALESCE(cat.Column2, p.product_category_name) AS Category,
    COUNT(DISTINCT oi.order_id) AS TotalOrders,
    SUM(oi.price) AS TotalRevenue,
    AVG(oi.price) AS AvgPrice
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
JOIN olist_orders_dataset o ON oi.order_id = o.order_id
LEFT JOIN product_category_name_translation cat 
    ON p.product_category_name = cat.Column1
WHERE o.order_status = 'delivered'
GROUP BY COALESCE(cat.Column2, p.product_category_name)
ORDER BY TotalOrders DESC;
----------------------------------------------
----«›÷· «·»«∆⁄Ì‰
go
CREATE VIEW VW_BESTSELLEER AS
SELECT TOP 10 OI.seller_id,OS.seller_city,
count( oi.order_id)as TotalOrders,
sum(    oi.price ) as TotalSales,
avg( ore.review_score   ) as AvgCustomerRating,
DENSE_RANK() over( order by sum(   oi.price )desc ) as sellerRank

FROM olist_sellers_dataset OS
JOIN olist_order_items_dataset OI ON OS.seller_id=OI.seller_id
JOIN olist_orders_dataset O ON OI.order_id=O.order_id
LEFT JOIN olist_order_reviews_dataset ORE ON O.order_id=ORE.order_id
WHERE O.order_status='delivered'
group by OI.seller_id,OS.seller_city;
go
SELECT* FROM VW_BESTSELLEER;
----------------------------------------------
--- Õ·Ì· ÿ—ﬁ «·œ›⁄
GO
CREATE VIEW VW_PaymentAnalysis as
select pay.payment_type,
count( pay.order_id  )as totalPayment,
sum(    pay.payment_value   ) as Totalrevenue,
AVG( PAY.payment_installments      ) as AVGInstallment
from olist_order_payments_dataset pay
join olist_orders_dataset o on pay.order_id=o.order_id
where o.order_status='delivered'
group by pay.payment_type;
go
select* from VW_PaymentAnalysis;

---------------------------------------------
----«œ«¡ «·‘Õ‰ Õ”» «·Ê·«ÌÂ
GO
CREATE VIEW VW_SHIPPINGPerformancee as
select oc.customer_state,
avg( DATEDIFF(DAY,o.order_purchase_timestamp,o.order_delivered_customer_date     )) as AvgDeliveryDay,
COUNT( o.order_id  ) as orderCount,
PERCENT_RANK () OVER ( ORDER BY  avg( DATEDIFF(DAY,o.order_purchase_timestamp,o.order_delivered_customer_date     )) ) AS DELIVERYRank
from olist_customers_dataset oc
join olist_orders_dataset o on oc.customer_id=o.customer_id
where o.order_status='delivered'
group by oc.customer_state
GO
select* from VW_SHIPPINGPerformance;
----------------------------------------------------------------
----·Ê ⁄«Ì“  ﬁ—Ì— ⁄‰ ⁄„Ì·
GO
create procedure sp_customerReporttt

@customer_uniqueId nvarchar(50)
as
begin
if exists ( select 1 from olist_customers_dataset where customer_unique_id=@customer_uniqueId)
begin
select   c.customer_city , count( o.order_id ) as TotalOrders,
avg(datediff(day,o.order_purchase_timestamp,o.order_delivered_customer_date     )     ) as avgDeliveryDay,
sum( pay.payment_value         ) as TotalSpent,
avg(  r.review_score              ) as AvgRating

from
olist_customers_dataset c 
join olist_orders_dataset o on c.customer_id=o.customer_id
join olist_order_payments_dataset pay on o.order_id =pay.order_id
left join olist_order_reviews_dataset r  on O.order_id =R.order_id
where c.customer_unique_id= @customer_uniqueId
group by c.customer_city ;
end
else 
select '  «·⁄„Ì· €Ì— „ÊÃÊœ' as message
End;

 EXEC sp_customerReportt'b0015e09bb4b6e47c52844fab5fb6638' ;     
  EXEC sp_customerReportt'b0015e09bb4b6e47c52844fab5fb669' ; 
  

  ---------------------------------------------------------------------------
  ---**«·”ƒ«·:** "«·⁄„·«¡ »Ì Ã“√Ê« ≈“«Ìø VIP / Loyal / New / One-Timeø"
  GO
create view vw_customerSegment as
 select c.customer_unique_id,
 count(o.order_id  ) as  totalOrders,
 sum(pay.payment_value         ) as totalSpent,
 case 
 when  count(o.order_id  )>=5 and  sum(pay.payment_value) >=1000 then 'vip'
 when  count(o.order_id  )>=3 then 'loyal'
 when count(o.order_id  )=1 then 'new'
 else 'onTime'
 end
 as segment

 from olist_customers_dataset c
 join olist_orders_dataset o on c.customer_id=o.customer_id
  join olist_order_payments_dataset pay on o.order_id=pay.order_id
 group by c.customer_unique_id;
 GO
 ----------------------------------------------------
---"√ﬂÀ— «·›∆«  —»ÕÌ… („‘ „Ã—œ „»Ì⁄« )ø"
select
coalesce (pc.column2,p.product_category_name) as category ,
count (*) as orders,
sum (oi.price  ) as revenue,
sum (oi.price*0.85) as estiProfit,
ROUND ((sum (oi.price*0.85)/ sum (oi.price ))*100,1) as profitMargin           
from olist_order_items_dataset oi
join olist_products_dataset p on oi.product_id=p.product_id
left join product_category_name_translation pc on p.product_category_name=pc.column1
group by coalesce (pc.column2,p.product_category_name)
order by profitMargin desc;
-----------------------------------------------
---"œ—Ã… √œ«¡ ﬂ· »«∆⁄ (Revenue + Rating + Speed)ø"
---«Õ‰« »‰”«· «·„œÌ— «ÌÂ «Ê·ÊÌ«  »«·‰”»«·ﬂ «·»Ì⁄ Ê·« «· ﬁÌ„ Ê·« «·”—⁄Â Ê»‰«¡ ⁄·ÌÂ »‰Õœœ «·‰”»
----⁄‰œ‰« Â‰« ﬁÊ·‰« «·»Ì⁄ «·«Â„ Ê»⁄œÌ‰ «· ﬁÌ„ Ê»⁄œÌ‰ «·”—⁄Â ›ﬁ”„‰«Â« 50›Ì «·„ÌÂ »Ì⁄ Ê30›Ì «·„ÌÂ  ﬁÌ„ Ê20›Ì «·„ÌÂ ”—⁄Â
go
create view vw_sellerScore as

select top 20
s.seller_id,s.seller_city,
sum (oi.price  )*0.5 + sum(r.review_score )*100*0.3+
AVG(DATEDIFF(DAY,o.order_approved_at,o.order_delivered_carrier_date    )/1.0)*100*0.2  as performance
from olist_sellers_dataset s join olist_order_items_dataset oi on s.seller_id=oi.seller_id
join olist_orders_dataset o on oi.order_id=o.order_id
left join olist_order_reviews_dataset r on o.order_id=r.order_id
where o.order_status = 'delivered'
group by s.seller_id,s.seller_city
order by performance desc;

select* from vw_sellerScore
GO
------------------------------------
--**«·”ƒ«·:** "„Ì‰ «·⁄„·«¡ «··Ì ÂÌ”Ì»Ê‰«ø"
GO
CREATE VIEW VW_ChurnRisk AS
SELECT 
    c.customer_unique_id,
    COUNT(o.order_id) AS Orders,
    DATEDIFF(MONTH, MAX(o.order_purchase_timestamp), 
             (SELECT MAX(order_purchase_timestamp) FROM olist_orders_dataset)) AS InactiveMonths,
    CASE 
        WHEN DATEDIFF(MONTH, MAX(o.order_purchase_timestamp), 
                      (SELECT MAX(order_purchase_timestamp) FROM olist_orders_dataset)) >= 6 THEN 'High Risk'
        WHEN DATEDIFF(MONTH, MAX(o.order_purchase_timestamp), 
                      (SELECT MAX(order_purchase_timestamp) FROM olist_orders_dataset)) >= 3 THEN 'Medium Risk'
        ELSE 'Active'
    END AS ChurnStatus
FROM olist_customers_dataset c
LEFT JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(o.order_id) > 0;
GO
-------------------------------------------
-- «ﬂ — „‰ Ã«  „‘ —ﬂÂ  „ ‘—«∆Â« „⁄ »⁄÷ basket market analysis
GO
CREATE VIEW VW_BasketAnalysis AS
SELECT TOP 10
    Product1,
    Product2,
    CoPurchaseCount
FROM (
    SELECT 
        p1.product_category_name AS Product1,
        p2.product_category_name AS Product2,
        COUNT(*) AS CoPurchaseCount
    FROM olist_order_items_dataset oi1
    JOIN olist_order_items_dataset oi2 
        ON oi1.order_id = oi2.order_id 
        AND oi1.product_id < oi2.product_id  --  — Ì»
        AND oi1.product_id != oi2.product_id -- „Œ ·›
    JOIN olist_products_dataset p1 ON oi1.product_id = p1.product_id  --  ÕÊÌ· «·«—ﬁ«„ ·Õ—Ê›
    JOIN olist_products_dataset p2 ON oi2.product_id = p2.product_id --  ÕÊÌ· «·«—ﬁ«„ ·Õ—Ê›
    GROUP BY p1.product_category_name, p2.product_category_name
) ranked_pairs
WHERE Product1 != Product2  --  ›· — ‰Â«∆Ì ··›∆«  «·„Œ ·›…
ORDER BY CoPurchaseCount DESC;
GO

--------------------------------------
-- «ÌÂ «·‘ÂÊ— «··Ì  «·›∆«  »  »«⁄ ›ÌÂ« «ﬂ —
CREATE VIEW VW_SEASOINALLITY AS

SELECT 
COALESCE ( CAT.column2 ,P.product_category_name) as category,
DATENAME(MONTH,o.order_purchase_timestamp ) as month,
count( OI.order_id  ) as TotalOrders,
SUM(OI.price ) AS REVENUE

FROM olist_order_items_dataset OI 
JOIN olist_products_dataset P ON OI.product_id=P.product_id
JOIN olist_orders_dataset O ON O.order_id=OI.order_id
LEFT JOIN product_category_name_translation CAT ON P.product_category_name=CAT.column1
GROUP BY COALESCE ( CAT.column2 ,P.product_category_name) ,
DATENAME(MONTH,o.order_purchase_timestamp ),
MONTH(O.order_purchase_timestamp   )
ORDER BY category,MONTH(o.order_purchase_timestamp ) ;

-----------------------------------------------
---EXCUTIVE SUMMARY
GO
CREATE VIEW VW_EXCUTIVE_SUMMARY AS
SELECT 
COUNT(O.order_id   ) AS TOTALORDERS,
SUM (OI.price ) AS REVENUE,
AVG(R.review_score ) as avgscore,
AVG(datediff( DAY,O.order_purchase_timestamp,O.order_delivered_customer_date  )) AS AVGDELIVERYDAYS,
count(distinct os.seller_id  ) as activeSeller,
count(distinct oc.customer_id) as activecustomer,
round(100.0 * count( case when datediff( DAY,O.order_purchase_timestamp,O.order_delivered_customer_date  )<=10
THEN 1 END) /COUNT(*),1) AS OnTimeRte
 
FROM olist_orders_dataset O 
JOIN olist_order_items_dataset OI ON O.order_id=OI.order_id
JOIN olist_customers_dataset OC ON OC.customer_id=O.customer_id
JOIN olist_sellers_dataset OS ON OS.seller_id=OI.seller_id
JOIN olist_order_payments_dataset P ON P.order_id=O.order_id
LEFT JOIN olist_order_reviews_dataset R ON R.order_id=O.order_id
WHERE O.order_status='DELIVERED';
GO

























































