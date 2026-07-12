mysql> USE flipkart_db;
Database changed

mysql> SET GLOBAL local_infile = 1;
Query OK, 0 rows affected (0.00 sec)

mysql> LOAD DATA LOCAL INFILE 'your_path/flipkart-cleaned.csv'
    -> INTO TABLE flipkart_cleaned
    -> FIELDS TERMINATED BY ','
    -> OPTIONALLY ENCLOSED BY '"'
    -> LINES TERMINATED BY '\n'
    -> IGNORE 1 LINES
    -> (product_id, category, brand, price, discount_percent, final_price, rating, rating_count, units_sold, listing_date);
Query OK, 66516 rows affected (2.59 sec)
Records: 66516  Deleted: 0  Skipped: 0  Warnings: 0

mysql> 
mysql> -- Question 1: What is the total revenue, total units sold, and average selling price across each product category?
mysql> SELECT
    ->     category,
    ->     COUNT(product_id) AS total_products,
    ->     SUM(units_sold) AS total_units_sold,
    ->     ROUND(AVG(final_price), 2) AS avg_selling_price,
    ->     ROUND(SUM(final_price * units_sold), 2) AS total_revenue
    -> FROM flipkart_cleaned
    -> GROUP BY category
    -> ORDER BY total_revenue DESC;
+----------------+----------------+------------------+-------------------+-----------------+
| category       | total_products | total_units_sold | avg_selling_price | total_revenue   |
+----------------+----------------+------------------+-------------------+-----------------+
| Toys           |           8468 |         21354874 |          23684.31 | 506793923279.58 |
| Beauty         |           8406 |         20881022 |          23904.71 | 503154054422.17 |
| Fashion        |           8397 |         20977557 |          23796.74 | 501181591474.26 |
| Electronics    |           8372 |         21157864 |          23591.11 | 498290461657.01 |
| Appliances     |           8236 |         20816790 |          23482.73 | 492186385285.31 |
| Sports         |           8301 |         20576052 |          23800.78 | 488606316556.82 |
| Mobiles        |           8224 |         20576415 |          23582.05 | 485431070721.14 |
| Home & Kitchen |           8112 |         20485900 |          23702.14 | 483515975846.54 |
+----------------+----------------+------------------+-------------------+-----------------+
8 rows in set (0.22 sec)

mysql> 
mysql> -- Question 2: Who are the top 10 generating brands by overall total revenue, and what is their average discount percentage?
mysql> SELECT
    ->     brand,
    ->     COUNT(product_id) AS total_catalog_items,
    ->     SUM(units_sold) AS total_units_sold,
    ->     ROUND(AVG(discount_percent), 2) AS avg_discount_percent,
    ->     ROUND(SUM(final_price * units_sold), 2) AS total_revenue
    -> FROM flipkart_cleaned
    -> GROUP BY brand
    -> ORDER BY total_revenue DESC
    -> LIMIT 10;
+----------+---------------------+------------------+----------------------+-----------------+
| brand    | total_catalog_items | total_units_sold | avg_discount_percent | total_revenue   |
+----------+---------------------+------------------+----------------------+-----------------+
| Adidas   |                4421 |         11236799 |                21.14 | 271665170393.26 |
| Nike     |                4448 |         11315719 |                21.59 | 270263142067.95 |
| Apple    |                4514 |         11202037 |                21.65 | 268388224752.61 |
| Puma     |                4527 |         11235032 |                21.40 | 266249578714.63 |
| Dell     |                4483 |         11274142 |                20.99 | 266075353322.60 |
| LG       |                4458 |         11219457 |                21.63 | 264973776851.75 |
| HP       |                4411 |         11092258 |                21.30 | 264942314646.86 |
| Prestige |                4466 |         11185603 |                21.41 | 264160758454.21 |
| Reebok   |                4475 |         11254305 |                21.24 | 263551570355.60 |
| Samsung  |                4468 |         11088840 |                21.30 | 263135039511.99 |
+----------+---------------------+------------------+----------------------+-----------------+
10 rows in set (0.24 sec)

mysql> 
mysql> -- Question 3: How do sales volume and overall revenue perform across different discount percentage tiers?
mysql> SELECT
    ->     CASE
    ->         WHEN discount_percent = 0 THEN '1. No Discount (0%)'
    ->         WHEN discount_percent BETWEEN 1 AND 15 THEN '2. Low Discount (1-15%)'
    ->         WHEN discount_percent BETWEEN 16 AND 30 THEN '3. Moderate Discount (16-30%)'
    ->         WHEN discount_percent BETWEEN 31 AND 50 THEN '4. High Discount (31-50%)'
    ->         ELSE '5. Deep Discount (>50%)'
    ->     END AS discount_tier,
    ->     COUNT(product_id) AS product_count,
    ->     SUM(units_sold) AS total_units_sold,
    ->     ROUND(AVG(units_sold), 2) AS avg_units_sold_per_product,
    ->     ROUND(SUM(final_price * units_sold), 2) AS total_revenue
    -> FROM flipkart_cleaned
    -> GROUP BY discount_tier
    -> ORDER BY discount_tier ASC;
+-------------------------------+---------------+------------------+----------------------------+------------------+
| discount_tier                 | product_count | total_units_sold | avg_units_sold_per_product | total_revenue    |
+-------------------------------+---------------+------------------+----------------------------+------------------+
| 1. No Discount (0%)           |          8116 |         20578624 |                    2535.56 |  622654793613.94 |
| 2. Low Discount (1-15%)       |         24921 |         62424066 |                    2504.88 | 1694267132191.70 |
| 3. Moderate Discount (16-30%) |         16547 |         41200834 |                    2489.93 |  935429182448.65 |
| 4. High Discount (31-50%)     |         16932 |         42622950 |                    2517.30 |  706808670988.54 |
+-------------------------------+---------------+------------------+----------------------------+------------------+
4 rows in set (0.29 sec)

mysql> 
mysql> -- Question 4: What is the distribution of product listings, customer reviews, and revenue across customer rating tiers?
mysql> SELECT
    ->     CASE
    ->         WHEN rating >= 4.5 THEN 'Tier 1: Excellent (4.5 - 5.0)'
    ->         WHEN rating >= 3.5 THEN 'Tier 2: Good (3.5 - 4.4)'
    ->         WHEN rating >= 2.5 THEN 'Tier 3: Average (2.5 - 3.4)'
    ->         ELSE 'Tier 4: Poor (< 2.5)'
    ->     END AS rating_tier,
    ->     COUNT(product_id) AS total_products,
    ->     SUM(rating_count) AS aggregate_reviews,
    ->     SUM(units_sold) AS total_units_sold,
    ->     ROUND(SUM(final_price * units_sold), 2) AS total_revenue
    -> FROM flipkart_cleaned
    -> GROUP BY rating_tier
    -> ORDER BY rating_tier ASC;
+-------------------------------+----------------+-------------------+------------------+------------------+
| rating_tier                   | total_products | aggregate_reviews | total_units_sold | total_revenue    |
+-------------------------------+----------------+-------------------+------------------+------------------+
| Tier 1: Excellent (4.5 - 5.0) |           9073 |         228091086 |         22879644 |  538101464087.96 |
| Tier 2: Good (3.5 - 4.4)      |          16637 |         416251630 |         41552015 |  981103006228.04 |
| Tier 3: Average (2.5 - 3.4)   |          16739 |         417348655 |         42046997 | 1000491130376.29 |
| Tier 4: Poor (< 2.5)          |          24067 |         605425957 |         60347818 | 1439464178550.54 |
+-------------------------------+----------------+-------------------+------------------+------------------+
4 rows in set (0.32 sec)

mysql> 
mysql> -- Question 5: What are the top 5 highest-ranked products within each product category based on rating and units sold?
mysql> WITH RankedProducts AS (
    ->     SELECT
    ->         category,
    ->         product_id,
    ->         brand,
    ->         final_price,
    ->         rating,
    ->         units_sold,
    ->         ROUND(final_price * units_sold, 2) AS total_revenue,
    ->         DENSE_RANK() OVER (
    ->             PARTITION BY category
    ->             ORDER BY rating DESC, units_sold DESC
    ->         ) AS category_rank
    ->     FROM flipkart_cleaned
    -> )
    -> SELECT
    ->     category,
    ->     category_rank,
    ->     product_id,
    ->     brand,
    ->     final_price,
    ->     rating,
    ->     units_sold,
    ->     total_revenue
    -> FROM RankedProducts
    -> WHERE category_rank <= 5
    -> ORDER BY category, category_rank;
+----------------+---------------+------------+-----------+-------------+--------+------------+---------------+
| category       | category_rank | product_id | brand     | final_price | rating | units_sold | total_revenue |
+----------------+---------------+------------+-----------+-------------+--------+------------+---------------+
| Appliances     |             1 | FKP0079392 | Nike      |    11141.65 |   5.00 |       4980 |   55485417.00 |
| Appliances     |             2 | FKP0042173 | Puma      |    54742.88 |   5.00 |       4951 |  271031998.88 |
| Appliances     |             3 | FKP0047335 | Dell      |    27964.90 |   5.00 |       4873 |  136272957.70 |
| Appliances     |             4 | FKP0019778 | Dell      |    12535.19 |   5.00 |       4757 |   59629898.83 |
| Appliances     |             5 | FKP0056380 | Whirlpool |    15637.89 |   5.00 |       4684 |   73247876.76 |
| Beauty         |             1 | FKP0035100 | Samsung   |    18646.30 |   5.00 |       4970 |   92672111.00 |
| Beauty         |             2 | FKP0012562 | Boat      |    41458.04 |   5.00 |       4968 |  205963542.72 |
| Beauty         |             3 | FKP0061552 | Dell      |    28120.88 |   5.00 |       4800 |  134980224.00 |
| Beauty         |             4 | FKP0034312 | Prestige  |    52604.10 |   5.00 |       4797 |  252341867.70 |
| Beauty         |             5 | FKP0076659 | HP        |    21263.57 |   5.00 |       4586 |   97514732.02 |
| Electronics    |             1 | FKP0058423 | Nike      |    38776.39 |   5.00 |       4804 |  186281777.56 |
| Electronics    |             2 | FKP0041668 | Adidas    |    26648.12 |   5.00 |       4721 |  125805774.52 |
| Electronics    |             3 | FKP0045022 | Prestige  |    36914.50 |   5.00 |       4625 |  170729562.50 |
| Electronics    |             4 | FKP0061644 | Redmi     |    13994.96 |   5.00 |       4602 |   64404805.92 |
| Electronics    |             5 | FKP0078222 | Philips   |    15351.10 |   5.00 |       4579 |   70292686.90 |
| Fashion        |             1 | FKP0017628 | Adidas    |     8659.32 |   5.00 |       4981 |   43132072.92 |
| Fashion        |             2 | FKP0078013 | Philips   |    25268.18 |   5.00 |       4980 |  125835536.40 |
| Fashion        |             3 | FKP0027514 | Philips   |     6082.40 |   5.00 |       4841 |   29444898.40 |
| Fashion        |             4 | FKP0035924 | Reebok    |    12830.62 |   5.00 |       4819 |   61830757.78 |
| Fashion        |             5 | FKP0069950 | LG        |     8772.46 |   5.00 |       4731 |   41502508.26 |
| Home & Kitchen |             1 | FKP0067962 | Redmi     |    22524.08 |   5.00 |       4818 |  108521017.44 |
| Home & Kitchen |             2 | FKP0060497 | Nike      |    23583.92 |   5.00 |       4783 |  112801889.36 |
| Home & Kitchen |             3 | FKP0058364 | Prestige  |    37466.31 |   5.00 |       4773 |  178826697.63 |
| Home & Kitchen |             4 | FKP0007823 | Nike      |    10577.92 |   5.00 |       4733 |   50065295.36 |
| Home & Kitchen |             5 | FKP0044813 | Nike      |    11545.10 |   5.00 |       4719 |   54481326.90 |
| Mobiles        |             1 | FKP0020187 | Reebok    |    25695.81 |   5.00 |       4976 |  127862350.56 |
| Mobiles        |             2 | FKP0023862 | Whirlpool |    25460.46 |   5.00 |       4941 |  125800132.86 |
| Mobiles        |             3 | FKP0003963 | Reebok    |    11125.41 |   5.00 |       4930 |   54848271.30 |
| Mobiles        |             4 | FKP0004064 | Whirlpool |    16556.06 |   5.00 |       4878 |   80760460.68 |
| Mobiles        |             5 | FKP0058862 | Boat      |     7125.46 |   5.00 |       4666 |   33247396.36 |
| Sports         |             1 | FKP0047430 | Nike      |     9682.37 |   5.00 |       4976 |   48179473.12 |
| Sports         |             2 | FKP0079923 | Puma      |    37650.80 |   5.00 |       4971 |  187162126.80 |
| Sports         |             3 | FKP0035153 | Philips   |    16634.43 |   5.00 |       4955 |   82423600.65 |
| Sports         |             4 | FKP0064962 | LG        |    17898.65 |   5.00 |       4862 |   87023236.30 |
| Sports         |             5 | FKP0037776 | Puma      |    39760.15 |   5.00 |       4802 |  190928240.30 |
| Toys           |             1 | FKP0068247 | HP        |    44306.37 |   5.00 |       4979 |  220601416.23 |
| Toys           |             2 | FKP0006466 | HP        |    20333.46 |   5.00 |       4945 |  100548959.70 |
| Toys           |             3 | FKP0052596 | LG        |     6352.46 |   5.00 |       4906 |   31165168.76 |
| Toys           |             4 | FKP0056466 | Reebok    |    25043.66 |   5.00 |       4880 |  122213060.80 |
| Toys           |             5 | FKP0055700 | Reebok    |    35048.58 |   5.00 |       4873 |  170791730.34 |
+----------------+---------------+------------+-----------+-------------+--------+------------+---------------+
40 rows in set (0.78 sec)

mysql> 
mysql> -- Question 6: How have new product listings, sales volumes, and generated revenue trended by listing year over time?
mysql> SELECT
    ->     YEAR(listing_date) AS listing_year,
    ->     COUNT(product_id) AS new_products_listed,
    ->     SUM(units_sold) AS total_units_sold,
    ->     ROUND(AVG(rating), 2) AS avg_listing_rating,
    ->     ROUND(SUM(final_price * units_sold), 2) AS total_generated_revenue
    -> FROM flipkart_cleaned
    -> GROUP BY listing_year
    -> ORDER BY listing_year ASC;
+--------------+---------------------+------------------+--------------------+-------------------------+
| listing_year | new_products_listed | total_units_sold | avg_listing_rating | total_generated_revenue |
+--------------+---------------------+------------------+--------------------+-------------------------+
|         2018 |               12183 |         30445581 |               2.99 |         725538660716.92 |
|         2019 |               11920 |         29943785 |               3.00 |         714398138494.78 |
|         2020 |               12202 |         30832713 |               2.98 |         728267017461.94 |
|         2021 |               12287 |         30878466 |               3.02 |         729644425704.55 |
|         2022 |               12121 |         30344152 |               3.00 |         716109051315.92 |
|         2023 |                5803 |         14381777 |               2.99 |         345202485548.72 |
+--------------+---------------------+------------------+--------------------+-------------------------+
6 rows in set (0.15 sec)

mysql> 
mysql> -- Question 7: What is the market revenue share of each brand specifically within Electronics and Mobiles?
mysql> SELECT
    ->     category,
    ->     brand,
    ->     COUNT(product_id) AS catalog_count,
    ->     SUM(units_sold) AS total_units_sold,
    ->     ROUND(SUM(final_price * units_sold), 2) AS category_brand_revenue
    -> FROM flipkart_cleaned
    -> WHERE category IN ('Electronics', 'Mobiles')
    -> GROUP BY category, brand
    -> ORDER BY category, category_brand_revenue DESC;
+-------------+-----------+---------------+------------------+------------------------+
| category    | brand     | catalog_count | total_units_sold | category_brand_revenue |
+-------------+-----------+---------------+------------------+------------------------+
| Electronics | Nike      |           598 |          1602145 |         38046884429.36 |
| Electronics | Whirlpool |           571 |          1497127 |         35563155496.73 |
| Electronics | Apple     |           586 |          1490966 |         35434002685.43 |
| Electronics | Prestige  |           581 |          1414229 |         34457641492.21 |
| Electronics | Adidas    |           585 |          1443693 |         34280360987.65 |
| Electronics | Redmi     |           558 |          1433718 |         33507073839.23 |
| Electronics | Puma      |           551 |          1396940 |         32992885888.24 |
| Electronics | LG        |           554 |          1425865 |         32899269621.05 |
| Electronics | Samsung   |           534 |          1355810 |         32895829985.99 |
| Electronics | Dell      |           577 |          1440427 |         32789436021.70 |
| Electronics | Reebok    |           553 |          1397205 |         31992170923.95 |
| Electronics | Boat      |           531 |          1296244 |         31444031060.47 |
| Electronics | HP        |           535 |          1346029 |         31440202709.30 |
| Electronics | Sony      |           550 |          1354050 |         31187185100.15 |
| Electronics | Philips   |           508 |          1263416 |         29360331415.55 |
| Mobiles     | Nike      |           575 |          1462832 |         34927244361.53 |
| Mobiles     | Prestige  |           596 |          1484842 |         34648031379.35 |
| Mobiles     | Apple     |           587 |          1423218 |         34556981588.03 |
| Mobiles     | Whirlpool |           543 |          1397426 |         33769487342.68 |
| Mobiles     | Philips   |           595 |          1434113 |         33739993068.23 |
| Mobiles     | Reebok    |           548 |          1441669 |         33712528858.25 |
| Mobiles     | Dell      |           565 |          1398157 |         33099703545.15 |
| Mobiles     | Adidas    |           534 |          1311618 |         32645316043.27 |
| Mobiles     | Puma      |           543 |          1354312 |         32448165517.93 |
| Mobiles     | Boat      |           513 |          1343179 |         31450894158.11 |
| Mobiles     | HP        |           529 |          1353699 |         31154041559.05 |
| Mobiles     | Samsung   |           531 |          1288617 |         30198937035.42 |
| Mobiles     | Redmi     |           537 |          1306955 |         30117946065.83 |
| Mobiles     | LG        |           536 |          1336084 |         30116082647.52 |
| Mobiles     | Sony      |           492 |          1239694 |         28845717550.79 |
+-------------+-----------+---------------+------------------+------------------------+
30 rows in set (0.14 sec)

mysql> 
mysql> -- Question 8: Which high-volume products pose a quality risk (low customer rating < 3.0 but high sales volume > 2000)?
mysql> SELECT
    ->     product_id,
    ->     category,
    ->     brand,
    ->     rating,
    ->     rating_count,
    ->     units_sold,
    ->     final_price,
    ->     ROUND(final_price * units_sold, 2) AS total_revenue
    -> FROM flipkart_cleaned
    -> WHERE rating < 3.0
    ->   AND units_sold > 2000
    -> ORDER BY units_sold DESC
    -> LIMIT 10;
+------------+----------------+-----------+--------+--------------+------------+-------------+---------------+
| product_id | category       | brand     | rating | rating_count | units_sold | final_price | total_revenue |
+------------+----------------+-----------+--------+--------------+------------+-------------+---------------+
| FKP0030096 | Toys           | Dell      |   1.20 |        29806 |       4999 |    43688.62 |  218399411.38 |
| FKP0050615 | Beauty         | Reebok    |   1.40 |         5609 |       4999 |    47304.52 |  236475295.48 |
| FKP0040699 | Home & Kitchen | Whirlpool |   1.90 |        33915 |       4999 |    10106.67 |   50523243.33 |
| FKP0059101 | Toys           | HP        |   2.90 |        40796 |       4999 |    44395.54 |  221933304.46 |
| FKP0011882 | Toys           | Samsung   |   2.60 |        11095 |       4999 |     5201.65 |   26003048.35 |
| FKP0009438 | Beauty         | Sony      |   1.20 |        16082 |       4999 |    23239.86 |  116176060.14 |
| FKP0043522 | Home & Kitchen | LG        |   2.00 |        18448 |       4998 |     3960.04 |   19792279.92 |
| FKP0042395 | Fashion        | Samsung   |   2.20 |        23285 |       4998 |     7175.02 |   35860749.96 |
| FKP0001341 | Toys           | Adidas    |   2.50 |        43976 |       4998 |    12578.49 |   62867293.02 |
| FKP0015684 | Beauty         | Whirlpool |   2.10 |        41050 |       4998 |    23283.78 |  116372332.44 |
+------------+----------------+-----------+--------+--------------+------------+-------------+---------------+
10 rows in set (0.06 sec)

mysql> 
mysql> -- Question 9: What is the average original price, discount markdown amount, and final selling price across product categories?
mysql> SELECT
    ->     category,
    ->     ROUND(AVG(price), 2) AS avg_original_price,
    ->     ROUND(AVG(price - final_price), 2) AS avg_discount_amount,
    ->     ROUND(AVG(discount_percent), 2) AS avg_discount_percent,
    ->     ROUND(AVG(final_price), 2) AS avg_final_price
    -> FROM flipkart_cleaned
    -> GROUP BY category
    -> ORDER BY avg_discount_amount DESC;
+----------------+--------------------+---------------------+----------------------+-----------------+
| category       | avg_original_price | avg_discount_amount | avg_discount_percent | avg_final_price |
+----------------+--------------------+---------------------+----------------------+-----------------+
| Sports         |           30298.67 |             6497.89 |                21.22 |        23800.78 |
| Home & Kitchen |           30196.45 |             6494.31 |                21.42 |        23702.14 |
| Toys           |           30171.92 |             6487.60 |                21.58 |        23684.31 |
| Beauty         |           30373.89 |             6469.18 |                21.36 |        23904.71 |
| Mobiles        |           30050.72 |             6468.67 |                21.56 |        23582.05 |
| Electronics    |           30042.04 |             6450.92 |                21.40 |        23591.11 |
| Appliances     |           29920.28 |             6437.55 |                21.43 |        23482.73 |
| Fashion        |           30196.83 |             6400.09 |                21.23 |        23796.74 |
+----------------+--------------------+---------------------+----------------------+-----------------+
8 rows in set (0.26 sec)

mysql> 
mysql> -- Question 10: How are product counts, sales volume, and total revenue distributed across consumer price tiers?
mysql> SELECT
    ->     CASE
    ->         WHEN final_price < 1000 THEN '1. Budget (< ₹1,000)'
    ->         WHEN final_price BETWEEN 1000 AND 5000 THEN '2. Affordable (₹1,000 - ₹5,000)'
    ->         WHEN final_price BETWEEN 5001 AND 20000 THEN '3. Mid-Range (₹5,001 - ₹20,000)'
    ->         WHEN final_price BETWEEN 20001 AND 50000 THEN '4. Premium (₹20,001 - ₹50,000)'
    ->         ELSE '5. Luxury (> ₹50,000)'
    ->     END AS price_tier,
    ->     COUNT(product_id) AS product_count,
    ->     SUM(units_sold) AS total_units_sold,
    ->     ROUND(SUM(final_price * units_sold), 2) AS tier_revenue
    -> FROM flipkart_cleaned
    -> GROUP BY price_tier
    -> ORDER BY price_tier ASC;
+---------------------------------+---------------+------------------+------------------+
| price_tier                      | product_count | total_units_sold | tier_revenue     |
+---------------------------------+---------------+------------------+------------------+
| 1. Budget (< ₹1,000)            |          1272 |          3167513 |    1830741167.13 |
| 2. Affordable (₹1,000 - ₹5,000) |          5988 |         14839938 |   44962912960.58 |
| 3. Mid-Range (₹5,001 - ₹20,000) |         22253 |         55887289 |  700427722662.78 |
| 4. Premium (₹20,001 - ₹50,000)  |         33842 |         84837652 | 2776957467490.02 |
| 5. Luxury (> ₹50,000)           |          3161 |          8094082 |  434980934962.32 |
+---------------------------------+---------------+------------------+------------------+
5 rows in set (0.24 sec)