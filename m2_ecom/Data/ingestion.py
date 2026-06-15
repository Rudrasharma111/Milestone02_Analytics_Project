import csv
import psycopg2
from pydantic import BaseModel, Field, ValidationError
from typing import Optional

# --- Data Models (Validation Rules) ---
# Ye models ensure karte hain ki sirf valid data hi database mein jaye.

class Customer(BaseModel):
    customer_id: int = Field(gt=0)
    customer_name: str = Field(min_length=2)
    age_group: str
    gender: str
    city: Optional[str] = "Unknown"
    state: str
    membership_type: str
    customer_segment: str
    annual_income_group: str
    signup_date: str

class Product(BaseModel):
    product_id: int = Field(gt=0)
    category: str = "Unknown"
    subcategory: str
    brand: str
    season_tag: str
    mrp: float = Field(gt=0)
    profit_margin_pct: float
    supplier_name: str
    stock_level: int = Field(ge=0)

class Campaign(BaseModel):
    campaign_id: int = Field(gt=0)
    campaign_name: str
    expected_performance: str

class Order(BaseModel):
    order_id: str
    customer_id: int = Field(gt=0)
    product_id: int = Field(gt=0)
    region_id: int = Field(gt=0)
    campaign_id: int = Field(gt=0)
    order_date: str
    quantity: int = Field(ge=1)
    unit_price: float = Field(ge=0)
    discount: float
    shipping_cost: float
    payment_method: str
    delivery_days: int
    returned_flag: int
    order_status: Optional[str] = "PENDING"
    warehouse_region: str
    customer_rating: Optional[str] = "0"
    customer_city: str
    customer_state: str

def run_pipeline():
    # Database connection setup
    conn = psycopg2.connect(
        host="127.0.0.1", port="5434", 
        user="postgres", password="mypassword", 
        database="m2_analytics_db"
    )
    cursor = conn.cursor()
    
    # Tables ko fresh start ke liye recreate karna
    print("Setting up database tables...")
    cursor.execute("DROP TABLE IF EXISTS raw_customers, raw_products, raw_campaigns, raw_orders;")
    
    cursor.execute("""
        CREATE TABLE raw_customers (customer_id INT PRIMARY KEY, customer_name TEXT, age_group TEXT, gender TEXT, city TEXT, state TEXT, membership_type TEXT, customer_segment TEXT, annual_income_group TEXT, signup_date TEXT);
        CREATE TABLE raw_products (product_id INT PRIMARY KEY, category TEXT, subcategory TEXT, brand TEXT, season_tag TEXT, mrp FLOAT, profit_margin_pct FLOAT, supplier_name TEXT, stock_level INT);
        CREATE TABLE raw_campaigns (campaign_id INT PRIMARY KEY, campaign_name TEXT, expected_performance TEXT);
        CREATE TABLE raw_orders (order_id TEXT PRIMARY KEY, customer_id INT, product_id INT, region_id INT, campaign_id INT, order_date TEXT, quantity INT, unit_price FLOAT, discount FLOAT, shipping_cost FLOAT, payment_method TEXT, delivery_days INT, returned_flag INT, order_status TEXT, warehouse_region TEXT, customer_rating TEXT, customer_city TEXT, customer_state TEXT);
    """)
    
    # File aur unke liye logic ka configuration
    configs = [
        ("raw_customers.csv", Customer, "INSERT INTO raw_customers VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"),
        ("raw_products.csv", Product, "INSERT INTO raw_products VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)"),
        ("raw_campaigns.csv", Campaign, "INSERT INTO raw_campaigns VALUES (%s, %s, %s)"),
        ("raw_orders.csv", Order, "INSERT INTO raw_orders VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) ON CONFLICT (order_id) DO NOTHING")
    ]
    
    for file_name, model, query in configs:
        print(f"Ingesting data from {file_name}...")
        try:
            with open(file_name, 'r', encoding='utf-8-sig') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    try:
                        # Validation step
                        data = model(**row)
                        cursor.execute(query, tuple(data.model_dump().values()))
                    except ValidationError:
                        # Gande data ko ignore kar rahe hain, jo ki normal hai
                        continue
            print(f"Finished processing {file_name}.")
        except FileNotFoundError:
            print(f"Error: {file_name} nahi mili, check karo file sahi folder mein hai?")
                
    conn.commit()
    cursor.close()
    conn.close()
    print("--- Pipeline successfully complete! ---")

if __name__ == "__main__":
    run_pipeline()