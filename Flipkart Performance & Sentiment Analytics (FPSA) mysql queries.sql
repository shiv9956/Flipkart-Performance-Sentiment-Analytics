-- ============================================================================
-- FLIPKART E-COMMERCE ANALYTICS
-- Database Setup & Business Analysis Script
-- Source File: flipkart-cleaned.csv
-- ============================================================================

-- Step 1: Database Setup
DROP DATABASE IF EXISTS flipkart_db;
CREATE DATABASE flipkart_db;
USE flipkart_db;

-- Step 2: Create Single Table Schema matching flipkart-cleaned.csv
DROP TABLE IF EXISTS flipkart_cleaned;
CREATE TABLE flipkart_cleaned (
    product_id VARCHAR(50) PRIMARY KEY,
    category VARCHAR(100) NOT NULL,
    brand VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    discount_percent INT NOT NULL,
    final_price DECIMAL(10, 2) NOT NULL,
    rating DECIMAL(3, 2) NOT NULL,
    rating_count INT NOT NULL,
    units_sold INT NOT NULL,
    listing_date DATE NOT NULL
);

-- Step 3: Import data from flipkart-cleaned.csv
-- Note: Replace '/path/to/flipkart-cleaned.csv' with your actual local file path.
LOAD DATA INFILE '/path/to/flipkart-cleaned.csv'
INTO TABLE flipkart_cleaned
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(product_id, category, brand, price, discount_percent, final_price, rating, rating_count, units_sold, listing_date);

-- Enable indexes to improve query performance
CREATE INDEX idx_category ON flipkart_cleaned(category);
CREATE INDEX idx_brand ON flipkart_cleaned(brand);
CREATE INDEX idx_rating ON flipkart_cleaned(rating);


-- ============================================================================
-- 10 BUSINESS QUESTIONS & MYSQL QUERIES
-- ============================================================================

-- Question 1: Which product categories generate the highest total revenue, and what are their overall sales volumes?
-- Purpose: Helps management identify core revenue-generating product categories for resource allocation.
SELECT 
    category,
    COUNT(product_id) AS total_products,
    SUM(units_sold) AS total_units_sold,
    ROUND(AVG(final_price), 2) AS avg_selling_price,
    ROUND(SUM(final_price * units_sold), 2) AS total_revenue
FROM flipkart_cleaned
GROUP BY category
ORDER BY total_revenue DESC;


-- Question 2: Who are the top 10 brands by total gross revenue, and what is their average discount percentage?
-- Purpose: Evaluates top brand performance and checks if high revenue is driven by aggressive discounting.
SELECT 
    brand,
    COUNT(product_id) AS total_catalog_items,
    SUM(units_sold) AS total_units_sold,
    ROUND(AVG(discount_percent), 2) AS avg_discount_percent,
    ROUND(SUM(final_price * units_sold), 2) AS total_revenue
FROM flipkart_cleaned
GROUP BY brand
ORDER BY total_revenue DESC
LIMIT 10;


-- Question 3: How does sales volume (units sold) and overall revenue vary across different discount tiers?
-- Purpose: Analyzes pricing elasticity to determine which discount ranges generate the best trade-off between volume and revenue.
SELECT 
    CASE 
        WHEN discount_percent = 0 THEN '1. No Discount (0%)'
        WHEN discount_percent BETWEEN 1 AND 15 THEN '2. Low Discount (1-15%)'
        WHEN discount_percent BETWEEN 16 AND 30 THEN '3. Moderate Discount (16-30%)'
        WHEN discount_percent BETWEEN 31 AND 50 THEN '4. High Discount (31-50%)'
        ELSE '5. Deep Discount (>50%)'
    END AS discount_tier,
    COUNT(product_id) AS product_count,
    SUM(units_sold) AS total_units_sold,
    ROUND(AVG(units_sold), 2) AS avg_units_sold_per_product,
    ROUND(SUM(final_price * units_sold), 2) AS total_revenue
FROM flipkart_cleaned
GROUP BY discount_tier
ORDER BY discount_tier ASC;


-- Question 4: What is the distribution of product performance across customer rating tiers (4.0+, 3.0-3.9, etc.)?
-- Purpose: Understands how customer satisfaction levels directly correlate with total sales and product catalog size.
SELECT 
    CASE 
        WHEN rating >= 4.5 THEN 'Tier 1: Excellent (4.5 - 5.0)'
        WHEN rating >= 3.5 THEN 'Tier 2: Good (3.5 - 4.4)'
        WHEN rating >= 2.5 THEN 'Tier 3: Average (2.5 - 3.4)'
        ELSE 'Tier 4: Poor (< 2.5)'
    END AS rating_tier,
    COUNT(product_id) AS total_products,
    SUM(rating_count) AS aggregate_reviews,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(final_price * units_sold), 2) AS total_revenue
FROM flipkart_cleaned
GROUP BY rating_tier
ORDER BY rating_tier ASC;


-- Question 5: What are the top 5 highest-rated and top-selling products in each category?
-- Purpose: Uses window functions to identify star products in each category for homepage promotion and banner highlighting.
WITH RankedProducts AS (
    SELECT 
        category,
        product_id,
        brand,
        final_price,
        rating,
        units_sold,
        ROUND(final_price * units_sold, 2) AS total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY category 
            ORDER BY rating DESC, units_sold DESC
        ) AS category_rank
    FROM flipkart_cleaned
)
SELECT 
    category,
    category_rank,
    product_id,
    brand,
    final_price,
    rating,
    units_sold,
    total_revenue
FROM RankedProducts
WHERE category_rank <= 5
ORDER BY category, category_rank;


-- Question 6: How has catalog size, total units sold, and generated revenue trended by product listing year?
-- Purpose: Evaluates year-over-year growth in marketplace listings and historical sales momentum.
SELECT 
    YEAR(listing_date) AS listing_year,
    COUNT(product_id) AS new_products_listed,
    SUM(units_sold) AS total_units_sold,
    ROUND(AVG(rating), 2) AS avg_listing_rating,
    ROUND(SUM(final_price * units_sold), 2) AS total_generated_revenue
FROM flipkart_cleaned
GROUP BY listing_year
ORDER BY listing_year ASC;


-- Question 7: Which brands dominate the Electronics and Mobiles categories in terms of revenue share?
-- Purpose: Provides category managers with targeted insights into high-value tech and electronic brands.
SELECT 
    category,
    brand,
    COUNT(product_id) AS catalog_count,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(final_price * units_sold), 2) AS category_brand_revenue
FROM flipkart_cleaned
WHERE category IN ('Electronics', 'Mobiles')
GROUP BY category, brand
ORDER BY category, category_brand_revenue DESC;


-- Question 8: What are the top 10 products that have low ratings (< 3.0) despite having high sales volume (> 2,000 units)?
-- Purpose: Identifies quality risk items that sell well but receive poor reviews, helping Flipkart prevent customer dissatisfaction and returns.
SELECT 
    product_id,
    category,
    brand,
    rating,
    rating_count,
    units_sold,
    final_price,
    ROUND(final_price * units_sold, 2) AS total_revenue
FROM flipkart_cleaned
WHERE rating < 3.0 
  AND units_sold > 2000
ORDER BY units_sold DESC
LIMIT 10;


-- Question 9: What is the average original price, average discount amount, and average final price for each category?
-- Purpose: Measures the average markdowns and pricing margins across different retail product lines.
SELECT 
    category,
    ROUND(AVG(price), 2) AS avg_original_price,
    ROUND(AVG(price - final_price), 2) AS avg_discount_amount,
    ROUND(AVG(discount_percent), 2) AS avg_discount_percent,
    ROUND(AVG(final_price), 2) AS avg_final_price
FROM flipkart_cleaned
GROUP BY category
ORDER BY avg_discount_amount DESC;


-- Question 10: Which pricing tier (Under 1k, 1k-5k, 5k-20k, 20k-50k, 50k+) generates the highest revenue and volume?
-- Purpose: Segments products into consumer price brackets to optimize catalog pricing strategies and search filters.
SELECT 
    CASE 
        WHEN final_price < 1000 THEN '1. Budget (< ₹1,000)'
        WHEN final_price BETWEEN 1000 AND 5000 THEN '2. Affordable (₹1,000 - ₹5,000)'
        WHEN final_price BETWEEN 5001 AND 20000 THEN '3. Mid-Range (₹5,001 - ₹20,000)'
        WHEN final_price BETWEEN 20001 AND 50000 THEN '4. Premium (₹20,001 - ₹50,000)'
        ELSE '5. Luxury (> ₹50,000)'
    END AS price_tier,
    COUNT(product_id) AS product_count,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(final_price * units_sold), 2) AS tier_revenue
FROM flipkart_cleaned
GROUP BY price_tier
ORDER BY price_tier ASC;