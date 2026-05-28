import pandas as pd
import numpy as np
from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker()
np.random.seed(42)
random.seed(42)

# --- CONFIG ---
NUM_CUSTOMERS = 500
NUM_PRODUCTS = 50
NUM_TRANSACTIONS = 10000
START_DATE = datetime(2023, 1, 1)
END_DATE = datetime(2024, 12, 31)

# --- CUSTOMERS ---
regions = ['Cairo', 'Alexandria', 'Giza', 'Luxor', 'Aswan']
segments = ['Retail', 'Wholesale', 'Online']

customers = []
for i in range(1, NUM_CUSTOMERS + 1):
    customers.append({
        'customer_id': i,
        'customer_name': fake.name(),
        'region': random.choice(regions),
        'segment': random.choice(segments),
        'join_date': fake.date_between(
            start_date=START_DATE, 
            end_date=END_DATE
        )
    })

customers_df = pd.DataFrame(customers)

# --- PRODUCTS ---
categories = {
    'Beverages': ['Water', 'Juice', 'Soda', 'Tea', 'Coffee',
                  'Energy Drink', 'Milk', 'Yogurt Drink'],
    'Snacks': ['Chips', 'Crackers', 'Cookies', 'Nuts',
               'Popcorn', 'Chocolate Bar', 'Candy', 'Gum'],
    'Dairy': ['Milk', 'Cheese', 'Butter', 'Cream',
              'Yogurt', 'Ice Cream', 'Sour Cream'],
    'Personal Care': ['Shampoo', 'Soap', 'Toothpaste',
                      'Deodorant', 'Lotion', 'Face Wash'],
    'Household': ['Detergent', 'Dish Soap', 'Bleach',
                  'Fabric Softener', 'Air Freshener',
                  'Trash Bags', 'Paper Towels']
}

products = []
product_id = 1
for category, items in categories.items():
    for item in items:
        cost = round(random.uniform(5, 80), 2)
        price = round(cost * random.uniform(1.2, 1.8), 2)
        target_monthly = random.randint(50, 300)
        products.append({
            'product_id': product_id,
            'product_name': item,
            'category': category,
            'cost_price': cost,
            'selling_price': price,
            'monthly_target_units': target_monthly
        })
        product_id += 1

products_df = pd.DataFrame(products)

# --- TRANSACTIONS ---
def random_date(start, end):
    delta = end - start
    return start + timedelta(days=random.randint(0, delta.days))

transactions = []
for i in range(1, NUM_TRANSACTIONS + 1):
    product = products_df.sample(1).iloc[0]
    customer = customers_df.sample(1).iloc[0]
    quantity = random.randint(1, 20)
    discount = random.choice([0, 0, 0, 0.05, 0.10, 0.15])
    unit_price = product['selling_price']
    total = round(quantity * unit_price * (1 - discount), 2)
    profit = round(total - (quantity * product['cost_price']), 2)

    transactions.append({
        'transaction_id': i,
        'customer_id': int(customer['customer_id']),
        'product_id': int(product['product_id']),
        'date': random_date(START_DATE, END_DATE),
        'quantity': quantity,
        'unit_price': unit_price,
        'discount': discount,
        'total_amount': total,
        'profit': profit
    })

transactions_df = pd.DataFrame(transactions)
transactions_df = transactions_df.sort_values('date').reset_index(drop=True)

# --- EXPORT TO CSV ---
customers_df.to_csv('customers.csv', index=False)
products_df.to_csv('products.csv', index=False)
transactions_df.to_csv('transactions.csv', index=False)

print("✅ Done! 3 files generated:")
print(f"   customers.csv  → {len(customers_df)} rows")
print(f"   products.csv   → {len(products_df)} rows")
print(f"   transactions.csv → {len(transactions_df)} rows")