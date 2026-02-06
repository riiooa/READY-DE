#!/usr/bin/env python3
"""
Data Generation Script for Retail Sales Star Schema
Generates realistic dummy data for testing and development
"""

import pandas as pd
import numpy as np
from faker import Faker
import random
from datetime import datetime, timedelta, date
import csv
import os
from tqdm import tqdm

# Initialize Faker with Indonesian locale
fake = Faker(['id_ID', 'en_US'])

class DataGenerator:
    def __init__(self, start_date='2023-01-01', end_date='2024-12-31'):
        self.fake = fake
        self.start_date = datetime.strptime(start_date, '%Y-%m-%d')
        self.end_date = datetime.strptime(end_date, '%Y-%m-%d')
        self.date_range = pd.date_range(start_date, end_date)
        
        # Configuration
        self.num_products = 500
        self.num_stores = 25
        self.num_customers = 5000
        self.num_transactions = 50000
        
        # Indonesian cities and regions
        self.indonesian_cities = [
            'Jakarta', 'Surabaya', 'Bandung', 'Medan', 'Semarang',
            'Makassar', 'Denpasar', 'Palembang', 'Balikpapan', 'Manado'
        ]
        
        self.regions = {
            'Jakarta': 'Jabodetabek',
            'Surabaya': 'Jawa Timur',
            'Bandung': 'Jawa Barat',
            'Medan': 'Sumatera Utara',
            'Semarang': 'Jawa Tengah',
            'Makassar': 'Sulawesi Selatan',
            'Denpasar': 'Bali',
            'Palembang': 'Sumatera Selatan',
            'Balikpapan': 'Kalimantan Timur',
            'Manado': 'Sulawesi Utara'
        }
        
        # Product categories and subcategories
        self.categories = {
            'Electronics': ['Smartphones', 'Laptops', 'Tablets', 'Accessories', 'Audio'],
            'Fashion': ['Men Clothing', 'Women Clothing', 'Shoes', 'Bags', 'Accessories'],
            'Home & Living': ['Furniture', 'Kitchenware', 'Decor', 'Bedding', 'Lighting'],
            'Groceries': ['Fresh Food', 'Beverages', 'Snacks', 'Dairy', 'Frozen'],
            'Beauty': ['Skincare', 'Makeup', 'Fragrances', 'Hair Care', 'Body Care']
        }
        
        # Brands by category
        self.brands = {
            'Electronics': ['Samsung', 'Apple', 'Xiaomi', 'Oppo', 'Vivo', 'Sony', 'LG'],
            'Fashion': ['Zara', 'H&M', 'Uniqlo', 'Nike', 'Adidas', 'Levi\'s', 'Gucci'],
            'Home & Living': ['IKEA', 'Ace Hardware', 'Informa', 'Mr. DIY', 'Livaza'],
            'Groceries': ['Indofood', 'Wings', 'Unilever', 'Nestle', 'Mayora'],
            'Beauty': ['Wardah', 'Make Over', 'Implora', 'Sariayu', 'Biolane']
        }
        
        # Payment methods
        self.payment_methods = ['Cash', 'Credit Card', 'Debit Card', 'E-Wallet', 'Bank Transfer']
        
        # Store types
        self.store_types = ['Mall', 'Standalone', 'Kiosk', 'Online', 'Outlet']
        
    def generate_dim_time(self):
        """Generate time dimension data"""
        print("Generating dim_time data...")
        
        data = []
        holidays = [
            '2023-01-01', '2023-03-22', '2023-04-07', '2023-04-22', '2023-05-01',
            '2023-05-18', '2023-06-01', '2023-06-29', '2023-07-19', '2023-08-17',
            '2023-09-28', '2023-12-25',
            '2024-01-01', '2024-03-11', '2024-03-29', '2024-04-10', '2024-05-01',
            '2024-05-09', '2024-05-23', '2024-06-01', '2024-06-17', '2024-07-07',
            '2024-08-17', '2024-09-16', '2024-12-25'
        ]
        
        for single_date in tqdm(self.date_range):
            date_str = single_date.strftime('%Y-%m-%d')
            is_weekend = single_date.weekday() >= 5
            is_holiday = date_str in holidays
            
            data.append({
                'full_date': date_str,
                'year': single_date.year,
                'quarter': (single_date.month - 1) // 3 + 1,
                'month': single_date.month,
                'month_name': single_date.strftime('%B'),
                'day_of_month': single_date.day,
                'day_of_week': single_date.isoweekday(),
                'day_name': single_date.strftime('%A'),
                'week_of_year': single_date.isocalendar()[1],
                'is_weekend': is_weekend,
                'is_holiday': is_holiday,
                'holiday_name': 'Holiday' if is_holiday else None
            })
        
        df = pd.DataFrame(data)
        df.to_csv('data/dim_time.csv', index=False, quoting=csv.QUOTE_NONNUMERIC)
        print(f"Generated {len(df)} time dimension records")
        return df
    
    def generate_dim_product(self):
        """Generate product dimension data"""
        print("Generating dim_product data...")
        
        data = []
        product_id = 1
        
        for category, subcategories in self.categories.items():
            for subcategory in subcategories:
                num_products_in_subcat = self.num_products // (len(self.categories) * len(subcategories))
                
                for _ in range(num_products_in_subcat):
                    brand = random.choice(self.brands.get(category, ['Generic']))
                    product_name = f"{brand} {self.fake.word().capitalize()} {random.choice(['Pro', 'Lite', 'Max', 'Plus', ''])}".strip()
                    
                    # Generate realistic pricing
                    if category == 'Electronics':
                        unit_cost = round(random.uniform(50, 1000), 2)
                        unit_price = round(unit_cost * random.uniform(1.2, 2.0), 2)
                    elif category == 'Fashion':
                        unit_cost = round(random.uniform(10, 200), 2)
                        unit_price = round(unit_cost * random.uniform(1.5, 3.0), 2)
                    else:
                        unit_cost = round(random.uniform(5, 100), 2)
                        unit_price = round(unit_cost * random.uniform(1.3, 2.5), 2)
                    
                    created_date = self.fake.date_between(
                        start_date=date(2022, 1, 1),
                        end_date='today'
                    )
                    
                    # 10% chance of being discontinued
                    is_discontinued = random.random() < 0.1
                    discontinued_date = None
                    if is_discontinued:
                        discontinued_date = self.fake.date_between(
                            start_date=created_date,
                            end_date='today'
                        )
                    
                    data.append({
                        'product_id': product_id,
                        'product_sku': f'SKU-{category[:3].upper()}-{product_id:06d}',
                        'product_name': product_name,
                        'product_description': self.fake.sentence(),
                        'category_id': hash(category) % 1000,
                        'category_name': category,
                        'subcategory_id': hash(subcategory) % 1000,
                        'subcategory_name': subcategory,
                        'brand': brand,
                        'supplier_id': random.randint(1, 50),
                        'supplier_name': self.fake.company(),
                        'manufacturer': brand,
                        'unit_cost': unit_cost,
                        'unit_price': unit_price,
                        'reorder_level': random.randint(5, 20),
                        'target_stock_level': random.randint(30, 100),
                        'weight_kg': round(random.uniform(0.1, 10.0), 3),
                        'dimensions': f"{random.randint(5, 50)}x{random.randint(5, 30)}x{random.randint(2, 20)} cm",
                        'is_active': not is_discontinued,
                        'is_discontinued': is_discontinued,
                        'created_date': created_date.strftime('%Y-%m-%d'),
                        'discontinued_date': discontinued_date.strftime('%Y-%m-%d') if discontinued_date else None,
                        'last_restock_date': self.fake.date_between(
                            start_date=date(2023, 11, 1),
                            end_date='today'
                        ).strftime('%Y-%m-%d')
                    })
                    
                    product_id += 1
        
        df = pd.DataFrame(data)
        df.to_csv('data/dim_product.csv', index=False, quoting=csv.QUOTE_NONNUMERIC)
        print(f"Generated {len(df)} product dimension records")
        return df
    
    def generate_dim_store(self):
        """Generate store dimension data"""
        print("Generating dim_store data...")
        
        data = []
        
        for i in range(1, self.num_stores + 1):
            city = random.choice(self.indonesian_cities)
            region = self.regions[city]
            store_type = random.choice(self.store_types)
            
            # Adjust attributes based on store type
            if store_type == 'Online':
                address = 'Online Store'
                square_feet = 0
                has_parking = False
                has_cafe = False
            else:
                address = self.fake.address().replace('\n', ', ')
                square_feet = random.choice([800, 1200, 2000, 3000, 5000])
                has_parking = store_type == 'Mall'
                has_cafe = store_type in ['Mall', 'Standalone']
            
            opening_date = self.fake.date_between(
                start_date=date(2019, 1, 1),
                end_date=date(2023, 1, 1)
            )
            
            # 5% chance store is closed
            is_active = random.random() > 0.05
            closing_date = None
            if not is_active:
                closing_date = self.fake.date_between(
                    start_date=opening_date,
                    end_date='today'
                )
            
            data.append({
                'store_id': i,
                'store_code': f'STR-{i:04d}',
                'store_name': f'{city} {store_type} Store {i}',
                'store_type': store_type,
                'store_format': random.choice(['Supermarket', 'Convenience', 'Hypermarket', 'Specialty']),
                'region_id': hash(region) % 100,
                'region_name': region,
                'subregion_id': hash(f"{region}_sub") % 100,
                'subregion_name': f'{region} Subregion',
                'city': city,
                'state_province': region,
                'address': address,
                'postal_code': str(random.randint(10000, 99999)),
                'country': 'Indonesia',
                'latitude': round(random.uniform(-6.2, -6.1), 6) if city == 'Jakarta' else round(random.uniform(-7.0, -5.0), 6),
                'longitude': round(random.uniform(106.7, 106.9), 6) if city == 'Jakarta' else round(random.uniform(107.0, 110.0), 6),
                'manager_id': random.randint(1000, 2000),
                'manager_name': self.fake.name(),
                'employee_count': random.randint(5, 50),
                'square_feet': square_feet,
                'number_of_floors': random.randint(1, 3),
                'has_parking': has_parking,
                'has_cafe': has_cafe,
                'opening_date': opening_date.strftime('%Y-%m-%d'),
                'closing_date': closing_date.strftime('%Y-%m-%d') if closing_date else None,
                'renovation_date': self.fake.date_between(
                    start_date=opening_date,
                    end_date='today'
                ).strftime('%Y-%m-%d') if random.random() > 0.7 else None,
                'monthly_rent': round(random.uniform(1000, 10000), 2) if store_type != 'Online' else 0,
                'annual_sales_target': round(random.uniform(50000, 500000), 2),
                'is_active': is_active,
                'is_temporary_closed': random.random() < 0.02
            })
        
        df = pd.DataFrame(data)
        df.to_csv('data/dim_store.csv', index=False, quoting=csv.QUOTE_NONNUMERIC)
        print(f"Generated {len(df)} store dimension records")
        return df
    
    def generate_dim_customer(self):
        """Generate customer dimension data"""
        print("Generating dim_customer data...")
        
        data = []
        
        for i in range(1, self.num_customers + 1):
            first_name = self.fake.first_name()
            last_name = self.fake.last_name()
            city = random.choice(self.indonesian_cities)
            
            # Customer segmentation
            if random.random() < 0.05:
                segment = 'Premium'
                tier = 'Platinum'
            elif random.random() < 0.15:
                segment = 'Gold'
                tier = 'Gold'
            elif random.random() < 0.30:
                segment = 'Silver'
                tier = 'Silver'
            else:
                segment = 'Regular'
                tier = 'Bronze'
            
            registration_date = self.fake.date_between(
                start_date=date(2021, 1, 1),
                end_date='today'
            )
            
            # Generate purchase dates for active customers
            first_purchase_date = None
            last_purchase_date = None
            purchase_frequency = 0
            average_order_value = 0
            
            if random.random() > 0.3:  # 70% of customers have made purchases
                first_purchase_date = self.fake.date_between(
                    start_date=registration_date,
                    end_date='today'
                )
                last_purchase_date = self.fake.date_between(
                    start_date=first_purchase_date,
                    end_date='today'
                )
                purchase_frequency = random.randint(1, 50)
                average_order_value = round(random.uniform(50, 500), 2)
            
            data.append({
                'customer_id': i,
                'customer_code': f'CUST-{i:06d}',
                'first_name': first_name,
                'last_name': last_name,
                'email': f'{first_name.lower()}.{last_name.lower()}@{self.fake.free_email_domain()}',
                'phone': f'+62{random.randint(811, 899)}{random.randint(1000000, 9999999)}',
                'phone_secondary': f'+62{random.randint(811, 899)}{random.randint(1000000, 9999999)}' if random.random() > 0.5 else None,
                'birth_date': self.fake.date_of_birth(minimum_age=18, maximum_age=70).strftime('%Y-%m-%d'),
                'gender': random.choice(['Male', 'Female', 'Other']),
                'marital_status': random.choice(['Single', 'Married', 'Divorced', 'Widowed']),
                'address': self.fake.address().replace('\n', ', '),
                'city': city,
                'state_province': self.regions.get(city, 'Java'),
                'postal_code': str(random.randint(10000, 99999)),
                'country': 'Indonesia',
                'customer_segment': segment,
                'customer_tier': tier,
                'lifetime_value': round(random.uniform(0, 10000), 2),
                'registration_date': registration_date.strftime('%Y-%m-%d'),
                'first_purchase_date': first_purchase_date.strftime('%Y-%m-%d') if first_purchase_date else None,
                'last_purchase_date': last_purchase_date.strftime('%Y-%m-%d') if last_purchase_date else None,
                'purchase_frequency': purchase_frequency,
                'average_order_value': average_order_value,
                'loyalty_points': random.randint(0, 5000),
                'loyalty_tier': random.choice(['Bronze', 'Silver', 'Gold', 'Platinum']),
                'referral_code': f'REF{random.randint(10000, 99999)}',
                'referred_by_id': random.randint(1, self.num_customers) if random.random() > 0.8 and i > 1 else None,
                'email_opt_in': random.random() > 0.3,
                'sms_opt_in': random.random() > 0.7,
                'is_active': random.random() > 0.1,
                'is_vip': random.random() < 0.03,
                'is_employee': random.random() < 0.02
            })
        
        df = pd.DataFrame(data)
        df.to_csv('data/dim_customer.csv', index=False, quoting=csv.QUOTE_NONNUMERIC)
        print(f"Generated {len(df)} customer dimension records")
        return df
    
    def generate_fact_sales(self, dim_products, dim_stores, dim_customers):
        """Generate fact sales data"""
        print("Generating fact_sales data...")
        
        data = []
        
        # Create date range for transactions
        transaction_dates = pd.date_range(
            self.start_date,
            self.end_date,
            freq='h'
        )
        
        # Sample transactions
        transaction_dates = random.sample(
            list(transaction_dates),
            min(self.num_transactions, len(transaction_dates))
        )
        
        for i, transaction_time in enumerate(tqdm(transaction_dates)):
            # Select random dimension keys
            product = random.choice(dim_products)
            store = random.choice(dim_stores)
            customer = random.choice(dim_customers) if random.random() > 0.2 else None
            
            # Generate transaction details
            quantity = random.randint(1, 5)
            unit_price = product['unit_price']
            
            # Apply discount (30% chance)
            discount_amount = 0
            discount_percentage = None
            if random.random() < 0.3:
                discount_percentage = round(random.uniform(5, 25), 2)
                discount_amount = round((quantity * unit_price) * discount_percentage / 100, 2)
            
            # Payment method
            payment_method = random.choice(self.payment_methods)
            
            # Sales channel
            if store['store_type'] == 'Online':
                sales_channel = 'Online'
                online_order_id = f'ONL-{transaction_time.strftime("%Y%m%d")}-{i:06d}'
            else:
                sales_channel = random.choice(['In-Store', 'Mobile', 'Phone'])
                online_order_id = None
            
            data.append({
                'time_id': (transaction_time.date() - self.start_date.date()).days + 1,
                'product_id': product['product_id'],
                'store_id': store['store_id'],
                'customer_id': customer['customer_id'] if customer else None,
                'transaction_id': f'TXN-{transaction_time.strftime("%Y%m%d%H%M%S")}-{i:06d}',
                'sales_person_id': random.randint(1000, 2000),
                'sales_person_name': self.fake.name(),
                'quantity': quantity,
                'unit_price': unit_price,
                'unit_cost': product['unit_cost'],
                'discount_type': 'Percentage' if discount_percentage else None,
                'discount_percentage': discount_percentage,
                'discount_amount': discount_amount,
                'promotion_id': f'PROMO-{random.randint(100, 999)}' if random.random() > 0.7 else None,
                'promotion_name': random.choice(['Summer Sale', 'Flash Sale', 'Member Discount', 'Clearance']) if random.random() > 0.7 else None,
                'tax_rate': 10.0,  # Standard VAT in Indonesia
                'service_fee': round(random.uniform(0, 10), 2) if random.random() > 0.8 else 0,
                'shipping_fee': round(random.uniform(0, 20), 2) if sales_channel == 'Online' else 0,
                'payment_method': payment_method,
                'payment_status': random.choice(['Completed', 'Completed', 'Completed', 'Pending', 'Failed']),
                'card_type': random.choice(['Visa', 'MasterCard', 'JCB']) if payment_method in ['Credit Card', 'Debit Card'] else None,
                'card_last_four': str(random.randint(1000, 9999)) if payment_method in ['Credit Card', 'Debit Card'] else None,
                'is_returned': random.random() < 0.03,
                'return_reason': random.choice(['Defective', 'Wrong Size', 'Changed Mind', 'Late Delivery']) if random.random() < 0.03 else None,
                'return_date': (transaction_time + timedelta(days=random.randint(1, 14))).strftime('%Y-%m-%d') if random.random() < 0.03 else None,
                'refund_amount': round(random.uniform(0, unit_price * quantity), 2) if random.random() < 0.03 else None,
                'sales_channel': sales_channel,
                'online_order_id': online_order_id,
                'transaction_time': transaction_time.strftime('%Y-%m-%d %H:%M:%S'),
                'source_system': random.choice(['POS', 'E-Commerce', 'Mobile App', 'Call Center']),
                'batch_id': random.randint(1, 10)
            })
        
        df = pd.DataFrame(data)
        
        # Calculate derived columns
        df['total_amount'] = df['quantity'] * df['unit_price']
        df['net_amount'] = df['total_amount'] - df['discount_amount']
        df['tax_amount'] = df['net_amount'] * df['tax_rate'] / 100
        df['gross_amount'] = df['net_amount'] + df['tax_amount'] + df['service_fee'] + df['shipping_fee']
        
        df.to_csv('data/fact_sales.csv', index=False, quoting=csv.QUOTE_NONNUMERIC)
        print(f"Generated {len(df)} sales fact records")
        return df
    
    def generate_all_data(self):
        """Generate all dimension and fact data"""
        print("Starting data generation for Retail Sales Star Schema...")
        print(f"Date range: {self.start_date.date()} to {self.end_date.date()}")
        
        # Create data directory if it doesn't exist
        os.makedirs('data', exist_ok=True)
        
        # Generate dimension tables
        dim_time_df = self.generate_dim_time()
        dim_product_df = self.generate_dim_product()
        dim_store_df = self.generate_dim_store()
        dim_customer_df = self.generate_dim_customer()
        
        # Convert to list of dicts for easier access
        dim_products = dim_product_df.to_dict('records')
        dim_stores = dim_store_df.to_dict('records')
        dim_customers = dim_customer_df.to_dict('records')
        
        # Generate fact table
        fact_sales_df = self.generate_fact_sales(dim_products, dim_stores, dim_customers)
        
        print("\n" + "="*50)
        print("DATA GENERATION COMPLETE!")
        print("="*50)
        print(f"Generated files in 'data/' directory:")
        print(f"  • dim_time.csv: {len(dim_time_df):,} records")
        print(f"  • dim_product.csv: {len(dim_product_df):,} records")
        print(f"  • dim_store.csv: {len(dim_store_df):,} records")
        print(f"  • dim_customer.csv: {len(dim_customer_df):,} records")
        print(f"  • fact_sales.csv: {len(fact_sales_df):,} records")
        print("\nTotal records generated:", 
              sum([len(dim_time_df), len(dim_product_df), len(dim_store_df), 
                   len(dim_customer_df), len(fact_sales_df)]))
        
        # Generate summary statistics
        self.generate_summary_statistics(fact_sales_df, dim_product_df, dim_store_df)
    
    def generate_summary_statistics(self, fact_sales, dim_products, dim_stores):
        """Generate summary statistics of the generated data"""
        print("\n" + "="*50)
        print("DATA SUMMARY STATISTICS")
        print("="*50)
        
        # Sales statistics
        total_revenue = fact_sales['total_amount'].sum()
        avg_transaction = fact_sales['total_amount'].mean()
        total_transactions = len(fact_sales)
        
        print(f"\n📊 Sales Statistics:")
        print(f"  Total Revenue: Rp {total_revenue:,.2f}")
        print(f"  Total Transactions: {total_transactions:,}")
        print(f"  Average Transaction Value: Rp {avg_transaction:,.2f}")
        print(f"  Total Discount Given: Rp {fact_sales['discount_amount'].sum():,.2f}")
        
        # Product statistics
        print(f"\n📦 Product Statistics:")
        print(f"  Total Products: {len(dim_products):,}")
        print(f"  Active Products: {dim_products['is_active'].astype(int).sum():,}")
        categories = dim_products['category_name'].value_counts()
        print(f"  Products by Category:")
        for category, count in categories.items():
            print(f"    • {category}: {count:,}")
        
        # Store statistics
        print(f"\n🏪 Store Statistics:")
        print(f"  Total Stores: {len(dim_stores):,}")
        print(f"  Active Stores: {dim_stores['is_active'].astype(int).sum():,}")
        store_types = dim_stores['store_type'].value_counts()
        print(f"  Stores by Type:")
        for store_type, count in store_types.items():
            print(f"    • {store_type}: {count:,}")
        
        # Save statistics to file
        stats = {
            'total_revenue': total_revenue,
            'total_transactions': total_transactions,
            'avg_transaction_value': avg_transaction,
            'total_products': len(dim_products),
            'active_products': int(dim_products['is_active'].astype(int).sum()),
            'total_stores': len(dim_stores),
            'active_stores': int(dim_stores['is_active'].astype(int).sum())
        }
        
        stats_df = pd.DataFrame([stats])
        stats_df.to_csv('data/data_statistics.csv', index=False)
        print(f"\n📈 Statistics saved to: data/data_statistics.csv")


def main():
    """Main function to run data generation"""
    print("Retail Sales Data Mart - Data Generator")
    print("="*50)
    
    # Initialize generator
    generator = DataGenerator(
        start_date='2023-01-01',
        end_date='2024-02-28'
    )
    
    # Generate all data
    generator.generate_all_data()
    
    print("\n✅ Data generation completed successfully!")
    print("\n📁 Files generated in 'data/' directory:")
    print("  1. dim_time.csv        - Time dimension")
    print("  2. dim_product.csv     - Product dimension")
    print("  3. dim_store.csv       - Store dimension")
    print("  4. dim_customer.csv    - Customer dimension")
    print("  5. fact_sales.csv      - Sales fact table")
    print("  6. data_statistics.csv - Summary statistics")
    
    print("\n🚀 Next steps:")
    print("  1. Run create_tables.sql in PostgreSQL")
    print("  2. Load CSV files using COPY command")
    print("  3. Run analytical queries on the star schema")


if __name__ == "__main__":
    main()