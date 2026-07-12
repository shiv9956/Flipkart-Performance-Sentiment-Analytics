# Flipkart Performance & Sentiment Analytics (FPSA)

End-to-end MySQL analytics on 66k+ Flipkart products analyzing revenue trends, pricing strategies, customer sentiment, and quality risks.

[![GitHub Repo](https://img.shields.io/badge/GitHub-shiv9956%2FFlipkart--Performance--Sentiment--Analytics-blue?style=for-the-badge&logo=github)](https://github.com/shiv9956/Flipkart-Performance-Sentiment-Analytics)
![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![SQL Data Analysis](https://img.shields.io/badge/Data_Analysis-SQL-blue?style=for-the-badge)
![E-Commerce Analytics](https://img.shields.io/badge/Domain-E--Commerce-orange?style=for-the-badge)

---

## 📌 Executive Summary

**Flipkart Performance & Sentiment Analytics (FPSA)** is an end-to-end data analytics project designed to evaluate product performance, customer sentiment, pricing strategies, and catalog health across Flipkart's e-commerce marketplace. 

By running structured SQL queries and data engineering workflows on over **66,000+ catalog listings**, this project provides actionable business intelligence to optimize category revenues, identify quality risks, and refine pricing discount models.

---

## 🎯 Core Business Objectives

1. **Category Performance Analysis:** Evaluate gross merchandise revenue, sales volume, and average selling prices across major categories (*Electronics, Mobiles, Fashion, Beauty, Appliances, Toys, Sports, Home & Kitchen*).
2. **Brand Market Share:** Identify top 10 revenue-generating brands (*Adidas, Nike, Apple, Puma, Dell, etc.*) and measure discount aggression.
3. **Discount Elasticity & Tiers:** Measure demand shifts across discount bands ranging from 0% (full price) to deep discounts (>50%).
4. **Customer Sentiment Segmentation:** Group customer ratings into sentiment tiers (Poor `< 2.5` to Excellent `4.5 - 5.0`) to measure revenue impact.
5. **Quality Risk Identification:** Flag high-volume products selling thousands of units despite poor customer satisfaction (`rating < 3.0`).
6. **Temporal Trends:** Analyze year-over-year listing volume, rating trends, and generated revenues (2018–2023).
7. **Consumer Price Tier Segmentation:** Categorize revenue distribution across *Budget*, *Affordable*, *Mid-Range*, *Premium*, and *Luxury* price points.

---

## 📊 Key Analytical Insights

* **Category Leaders:** **Toys**, **Beauty**, and **Fashion** lead overall platform revenues, with each category generating over **₹500 Billion** in total gross sales.
* **Top Revenue Brands:** **Adidas** (₹271.6B) and **Nike** (₹270.2B) lead brand revenues with an average discount margin of ~21%.
* **Revenue Driver:** The **Premium Tier (₹20,001 - ₹50,000)** drives the majority of platform revenue (~₹2.77 Trillion across 33,800+ listings).
* **Quality Risk Warning:** Discovered multiple high-volume items with critical user ratings (`1.2 - 2.5`) generating tens of millions in revenue, representing key targets for seller quality audits.

---

## 📁 Repository Structure

```text
Flipkart-Performance-Sentiment-Analytics/
│
├── data/
│   ├── flipkart.csv                     # Raw e-commerce dataset
│   └── flipkart-cleaned.csv             # Processed & feature-engineered dataset
│
├── notebooks/
│   └── flipkart_sales_analysis.ipynb      # Python data preprocessing & cleaning pipeline
│
├── sql/
│   ├── Flipkart Performance & Sentiment Analytics (FPSA) mysql queries.sql                       # Database setup & data load scripts
│   └── Flipkart Performance & Sentiment Analytics (FPSA) mysql-answers.sql             # answers to 10 core business questions
│
├── dashboards/
│   └── fpsa_dashboard.pbix # Interactive Power BI report
│
├── docs/
│   ├── Business_Problem_Statement.pdf   # Formal business problem documentation
│   └── Flipkart Data Analytics.pptx                        # ppt with complete report
│                           
└── README.md                            # Comprehensive project documentation
