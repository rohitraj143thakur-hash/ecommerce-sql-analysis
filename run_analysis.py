"""
E-commerce Database Analysis using SQL
Author: Rohit Thakur
Description: Runs SQL queries against a relational e-commerce SQLite database
(customers, products, orders, order_items) to extract business insights,
exports results to CSV, and generates visualizations.
"""

import sqlite3
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os

sns.set_style("whitegrid")
plt.rcParams['figure.figsize'] = (9, 5)

conn = sqlite3.connect('database/ecommerce.db')
os.makedirs('query_results', exist_ok=True)
os.makedirs('charts', exist_ok=True)

def run_query(name, query):
    df = pd.read_sql_query(query, conn)
    df.to_csv(f'query_results/{name}.csv', index=False)
    return df

# 1. Total Revenue
q1 = run_query('01_total_revenue', """
SELECT ROUND(SUM(p.price * oi.quantity * (1 - oi.discount_pct/100.0)), 2) AS total_revenue
FROM order_items oi JOIN products p ON oi.product_id = p.product_id
""")
total_revenue = q1['total_revenue'][0]

# 2. Orders + AOV
q2 = run_query('02_orders_summary', """
SELECT COUNT(DISTINCT o.order_id) AS total_orders,
ROUND(SUM(p.price * oi.quantity * (1 - oi.discount_pct/100.0)) * 1.0 / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id JOIN products p ON oi.product_id = p.product_id
""")

# 3. Top 10 Products
q3 = run_query('03_top_products', """
SELECT p.product_name, p.category, SUM(oi.quantity) AS units_sold,
ROUND(SUM(p.price * oi.quantity * (1 - oi.discount_pct/100.0)), 2) AS revenue
FROM order_items oi JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id ORDER BY revenue DESC LIMIT 10
""")

plt.figure()
sns.barplot(data=q3, x='revenue', y='product_name', hue='product_name', palette='mako', legend=False)
plt.title('Top 10 Best-Selling Products by Revenue')
plt.xlabel('Revenue (₹)')
plt.ylabel('Product')
plt.tight_layout()
plt.savefig('charts/01_top_products.png', dpi=150)
plt.close()

# 4. Revenue by Category
q4 = run_query('04_revenue_by_category', """
SELECT p.category, ROUND(SUM(p.price * oi.quantity * (1 - oi.discount_pct/100.0)), 2) AS category_revenue
FROM order_items oi JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category ORDER BY category_revenue DESC
""")

plt.figure()
sns.barplot(data=q4, x='category_revenue', y='category', hue='category', palette='viridis', legend=False)
plt.title('Revenue by Category')
plt.xlabel('Revenue (₹)')
plt.ylabel('Category')
plt.tight_layout()
plt.savefig('charts/02_revenue_by_category.png', dpi=150)
plt.close()

# 5. Revenue by Region
q5 = run_query('05_revenue_by_region', """
SELECT o.region, ROUND(SUM(p.price * oi.quantity * (1 - oi.discount_pct/100.0)), 2) AS region_revenue,
COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id JOIN products p ON oi.product_id = p.product_id
GROUP BY o.region ORDER BY region_revenue DESC
""")

plt.figure()
plt.pie(q5['region_revenue'], labels=q5['region'], autopct='%1.1f%%', colors=sns.color_palette('pastel'), startangle=90)
plt.title('Revenue Share by Region')
plt.tight_layout()
plt.savefig('charts/03_revenue_by_region.png', dpi=150)
plt.close()

# 6. Monthly Revenue Trend
q6 = run_query('06_monthly_revenue_trend', """
SELECT strftime('%Y-%m', o.order_date) AS month,
ROUND(SUM(p.price * oi.quantity * (1 - oi.discount_pct/100.0)), 2) AS monthly_revenue
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id JOIN products p ON oi.product_id = p.product_id
GROUP BY month ORDER BY month
""")

plt.figure()
plt.plot(q6['month'], q6['monthly_revenue'], marker='o', color='#3498db')
plt.title('Monthly Revenue Trend')
plt.xlabel('Month')
plt.ylabel('Revenue (₹)')
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.savefig('charts/04_monthly_revenue_trend.png', dpi=150)
plt.close()

# 7. Top 10 Customers
q7 = run_query('07_top_customers', """
SELECT c.customer_name, c.city,
ROUND(SUM(p.price * oi.quantity * (1 - oi.discount_pct/100.0)), 2) AS total_spend,
COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_id ORDER BY total_spend DESC LIMIT 10
""")

# 8. Payment Method Distribution
q8 = run_query('08_payment_distribution', """
SELECT payment_method, COUNT(*) AS order_count,
ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS percentage
FROM orders GROUP BY payment_method ORDER BY order_count DESC
""")

plt.figure()
sns.barplot(data=q8, x='order_count', y='payment_method', hue='payment_method', palette='crest', legend=False)
plt.title('Orders by Payment Method')
plt.xlabel('Number of Orders')
plt.ylabel('Payment Method')
plt.tight_layout()
plt.savefig('charts/05_payment_method.png', dpi=150)
plt.close()

# 9. Customers by City
q9 = run_query('09_customers_by_city', """
SELECT city, COUNT(*) AS total_customers FROM customers GROUP BY city ORDER BY total_customers DESC LIMIT 5
""")

plt.figure()
sns.barplot(data=q9, x='total_customers', y='city', hue='city', palette='rocket', legend=False)
plt.title('Top 5 Cities by Customer Count')
plt.xlabel('Number of Customers')
plt.ylabel('City')
plt.tight_layout()
plt.savefig('charts/06_customers_by_city.png', dpi=150)
plt.close()

# 10. Repeat customers
q10 = run_query('10_repeat_customers', """
SELECT COUNT(*) AS repeat_customers FROM (
    SELECT customer_id FROM orders GROUP BY customer_id HAVING COUNT(*) > 1
)
""")

# 11. Avg discount by category
q11 = run_query('11_avg_discount_by_category', """
SELECT p.category, ROUND(AVG(oi.discount_pct), 2) AS avg_discount_pct
FROM order_items oi JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category ORDER BY avg_discount_pct DESC
""")

# 12. Highest revenue order
q12 = run_query('12_highest_revenue_order', """
SELECT o.order_id, c.customer_name,
ROUND(SUM(p.price * oi.quantity * (1 - oi.discount_pct/100.0)), 2) AS order_value
FROM orders o JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id JOIN products p ON oi.product_id = p.product_id
GROUP BY o.order_id ORDER BY order_value DESC LIMIT 1
""")

# ---------------- Insights Summary ----------------
insights = []
insights.append(f"Total Revenue: ₹{total_revenue:,.2f}")
insights.append(f"Total Orders: {q2['total_orders'][0]}")
insights.append(f"Average Order Value: ₹{q2['avg_order_value'][0]:,.2f}")
insights.append(f"\nTop-selling product: {q3.iloc[0]['product_name']} (₹{q3.iloc[0]['revenue']:,.2f})")
insights.append(f"Top category: {q4.iloc[0]['category']} (₹{q4.iloc[0]['category_revenue']:,.2f})")
insights.append(f"Top region: {q5.iloc[0]['region']} (₹{q5.iloc[0]['region_revenue']:,.2f})")
insights.append(f"Best month: {q6.loc[q6['monthly_revenue'].idxmax(), 'month']} (₹{q6['monthly_revenue'].max():,.2f})")
insights.append(f"Top customer: {q7.iloc[0]['customer_name']} from {q7.iloc[0]['city']} (₹{q7.iloc[0]['total_spend']:,.2f})")
insights.append(f"Most used payment method: {q8.iloc[0]['payment_method']} ({q8.iloc[0]['percentage']}%)")
insights.append(f"Repeat customers: {q10['repeat_customers'][0]}")
insights.append(f"Highest single order value: ₹{q12.iloc[0]['order_value']:,.2f} (Order #{q12.iloc[0]['order_id']}, {q12.iloc[0]['customer_name']})")

print("\n".join(insights))

with open('insights.txt', 'w', encoding='utf-8') as f:
    f.write("\n".join(insights))

conn.close()
print("\nAnalysis complete! Query results in 'query_results/', charts in 'charts/'.")
