import csv
import psycopg2
from pydantic import BaseModel, Field, ValidationError, field_validator
from typing import Optional

class Customer(BaseModel):
    customer_id: int = Field(gt=0)
    customer_name: str = Field(min_length=2)
    age_group: str
    gender: str
    city: Optional[str] = "Unknown"
    state: str
    membership_type: str
    customer_segment: str 

class Product(BaseModel):
    product_id: int = Field(gt=0)
    category: str = "Unknown"
    subcategory: str
    brand: str
    season_tag: str
    mrp: float = Field(gt=0)
    profit_margin_pct: float
    stock_level: int = Field(ge=0)

class Campaign(BaseModel):
    campaign_id: int = Field(gt=0)
    campaign_name: str
    expected_performance: str

    @field_validator('campaign_id', mode='before')
    @classmethod
    def clean_campaign_id(cls, value):
        if value == '' or value is None:
            return None
        if isinstance(value, str) and '.' in value:
            return int(float(value))
        return value

class Order(BaseModel):
    order_id: str
    customer_id: int = Field(gt=0)
    product_id: int = Field(gt=0)
    campaign_id: Optional[int] = None
    order_date: str
    quantity: int = Field(ge=1)
    unit_price: float = Field(ge=0)
    discount: float
    shipping_cost: float
    payment_method: str
    delivery_days: int
    returned_flag: int
    order_status: Optional[str] = "PENDING"
    customer_city: str
    customer_state: str

    @field_validator('campaign_id', mode='before')
    @classmethod
    def clean_campaign_id(cls, value):
        if value == '' or value is None:
            return None
        if isinstance(value, str) and '.' in value:
            return int(float(value))
        return value

def run_pipeline():
    conn = psycopg2.connect(
        host="127.0.0.1", port="5434", 
        user="postgres", password="mypassword", 
        database="m2_analytics_db"
    )
    cursor = conn.cursor()
    
    print("Setting up database tables...")
    cursor.execute("DROP TABLE IF EXISTS raw_customers, raw_products, raw_campaigns, raw_orders CASCADE;")
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS raw_customers (customer_id INT PRIMARY KEY, customer_name TEXT, age_group TEXT, gender TEXT, city TEXT, state TEXT, membership_type TEXT, customer_segment TEXT);
        CREATE TABLE IF NOT EXISTS raw_products (product_id INT PRIMARY KEY, category TEXT, subcategory TEXT, brand TEXT, season_tag TEXT, mrp FLOAT, profit_margin_pct FLOAT, stock_level INT);
        CREATE TABLE IF NOT EXISTS raw_campaigns (campaign_id INT PRIMARY KEY, campaign_name TEXT, expected_performance TEXT);
        CREATE TABLE IF NOT EXISTS raw_orders (order_id TEXT, customer_id INT, product_id INT, campaign_id INT, order_date TEXT, quantity INT, unit_price FLOAT, discount FLOAT, shipping_cost FLOAT, payment_method TEXT, delivery_days INT, returned_flag INT, order_status TEXT, customer_city TEXT, customer_state TEXT);
    """)
    
    configs = [
        ("raw_customers.csv", Customer, "INSERT INTO raw_customers VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"),
        ("raw_products.csv", Product, "INSERT INTO raw_products VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"),
        ("raw_campaigns.csv", Campaign, "INSERT INTO raw_campaigns VALUES (%s, %s, %s)"),
        ("raw_orders.csv", Order, "INSERT INTO raw_orders VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)")
    ]
    
    for file_name, model, query in configs:
        print(f"ingesting data from {file_name} ...")
        try:
            with open(file_name, 'r', encoding='utf-8-sig') as f:
                reader = csv.DictReader(f)
                inserted_count = 0
                
                for row in reader:
                    try:
                        data = model(**row)
                        cursor.execute(query, tuple(data.model_dump().values()))
                        inserted_count += 1
                    except ValidationError:
                        continue
                        
            print(f"finished procesing {file_name}. Rows inserted: {inserted_count}")
        except FileNotFoundError:
            print(f"eror: {file_name} not found")
            
    conn.commit()
    cursor.close()
    conn.close()
    print("--- pipelin complet ---")

if __name__ == "__main__":
    run_pipeline()