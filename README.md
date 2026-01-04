# 🏠 Airbnb Data Pipeline with dbt & Snowflake

A modern data engineering project that demonstrates building a scalable **Medallion Architecture** (Bronze → Silver → Gold) data pipeline using **dbt (Data Build Tool)** and **Snowflake** data warehouse.

![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Data Flow](#-data-flow)
- [Project Structure](#-project-structure)
- [Models](#-models)
- [Macros](#-macros)
- [Snapshots](#-snapshots)
- [Setup & Installation](#-setup--installation)
- [Usage](#-usage)
- [Technologies Used](#-technologies-used)

---

## 🎯 Overview

This project simulates an **Airbnb-like** data platform that processes and transforms booking, listings, and hosts data through multiple layers of transformation. The pipeline follows the **Medallion Architecture** pattern, which organizes data into three distinct layers:

| Layer | Purpose | Data Quality |
|-------|---------|--------------|
| 🥉 **Bronze** | Raw data ingestion | As-is from source |
| 🥈 **Silver** | Cleaned & transformed | Business logic applied |
| 🥇 **Gold** | Analytics-ready | Aggregated & optimized |

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DATA ARCHITECTURE                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐                  │
│   │   SOURCE    │     │   BRONZE    │     │   SILVER    │                  │
│   │   STAGING   │────▶│    LAYER    │────▶│    LAYER    │                  │
│   │             │     │             │     │             │                  │
│   │ • BOOKINGS  │     │ • bronze_   │     │ • silver_   │                  │
│   │ • HOSTS     │     │   booking   │     │   booking   │                  │
│   │ • LISTINGS  │     │ • bronze_   │     │ • silver_   │                  │
│   │             │     │   hosts     │     │   hosts     │                  │
│   │             │     │ • bronze_   │     │ • silver_   │                  │
│   │             │     │   listings  │     │   listings  │                  │
│   └─────────────┘     └─────────────┘     └─────────────┘                  │
│                                                   │                         │
│                                                   ▼                         │
│                              ┌─────────────────────────────────────┐       │
│                              │            GOLD LAYER               │       │
│                              │                                     │       │
│                              │  ┌─────────┐    ┌─────────────┐    │       │
│                              │  │   OBT   │───▶│    FACT     │    │       │
│                              │  │ (One Big│    │   (Analytics│    │       │
│                              │  │  Table) │    │    Ready)   │    │       │
│                              │  └─────────┘    └─────────────┘    │       │
│                              │       │                             │       │
│                              │       ▼                             │       │
│                              │  ┌─────────────────────────┐       │       │
│                              │  │   EPHEMERAL MODELS      │       │       │
│                              │  │ • booking (dim)         │       │       │
│                              │  │ • hosts (dim)           │       │       │
│                              │  │ • listings (dim)        │       │       │
│                              │  └─────────────────────────┘       │       │
│                              └─────────────────────────────────────┘       │
│                                                                             │
│                              ┌─────────────────────────────────────┐       │
│                              │          SNAPSHOTS (SCD)            │       │
│                              │  • dim_bookings                     │       │
│                              │  • dim_hosts                        │       │
│                              │  • dim_listings                     │       │
│                              └─────────────────────────────────────┘       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow

### Step 1: Source Data Ingestion
Raw data is extracted from the **STAGING** schema in Snowflake containing:
- `BOOKINGS` - Reservation/booking transactions
- `HOSTS` - Host information and profiles
- `LISTINGS` - Property listings details

### Step 2: Bronze Layer (Raw)
- **Purpose**: Store raw data exactly as received from source
- **Materialization**: Incremental tables
- **Key Feature**: Uses `CREATED_AT` column for incremental loading

### Step 3: Silver Layer (Transformed)
- **Purpose**: Apply business logic and data cleansing
- **Transformations**:
  - Data type conversions
  - Column renaming
  - Calculated fields (e.g., `TOTAL_AMOUNT`, `RESPONSE_RATE_QUALITY`)
  - Custom macros for tagging and calculations

### Step 4: Gold Layer (Analytics-Ready)
- **OBT (One Big Table)**: Denormalized table joining all silver tables
- **Fact Table**: Final analytics-ready table
- **Ephemeral Models**: Dimension extracts for specific use cases
- **Snapshots**: Track historical changes (SCD Type 2)

---

## 📁 Project Structure

```
aws_dbt_snowflake_project/
│
├── 📂 models/
│   ├── 📂 bronze/                    # Raw data layer
│   │   ├── bronze_booking.sql        # Incremental booking data
│   │   ├── bronze_hosts.sql          # Incremental hosts data
│   │   ├── bronze_listings.sql       # Incremental listings data
│   │   ├── sources.yml               # Source definitions
│   │   └── schema.yml                # Model documentation
│   │
│   ├── 📂 silver/                    # Transformed data layer
│   │   ├── silver_booking.sql        # Booking transformations
│   │   ├── silver_hosts.sql          # Host transformations
│   │   └── silver_listings.sql       # Listing transformations
│   │
│   └── 📂 gold/                      # Analytics layer
│       ├── obt.sql                   # One Big Table
│       ├── fact.sql                  # Fact table
│       └── 📂 ephemeral/             # Ephemeral dimensions
│           ├── booking.sql
│           ├── hosts.sql
│           └── listings.sql
│
├── 📂 macros/                        # Reusable SQL functions
│   ├── generate_schema_name.sql      # Custom schema naming
│   ├── multiply.sql                  # Multiplication helper
│   ├── tag.sql                       # Price categorization
│   └── trimmer.sql                   # String trimming
│
├── 📂 snapshots/                     # SCD Type 2 tracking
│   ├── dim_bookings.yml
│   ├── dim_hosts.yml
│   └── dim_listings.yml
│
├── 📂 seeds/                         # Static data files
│   ├── raw_bookings.csv
│   ├── raw_hosts.csv
│   └── raw_listings.csv
│
├── 📂 tests/                         # Data quality tests
├── 📂 analyses/                      # Ad-hoc analyses
├── dbt_project.yml                   # Project configuration
└── profiles.yml                      # Connection profiles
```

---

## 📊 Models

### Bronze Layer Models

| Model | Description | Materialization | Incremental Key |
|-------|-------------|-----------------|-----------------|
| `bronze_booking` | Raw booking data from staging | Incremental | `BOOKING_ID` |
| `bronze_hosts` | Raw host data from staging | Incremental | `HOST_ID` |
| `bronze_listings` | Raw listing data from staging | Incremental | `LISTING_ID` |

### Silver Layer Models

| Model | Description | Key Transformations |
|-------|-------------|---------------------|
| `silver_booking` | Transformed booking data | `TOTAL_AMOUNT` calculation, status cleanup |
| `silver_hosts` | Transformed host data | `RESPONSE_RATE_QUALITY` categorization |
| `silver_listings` | Transformed listing data | `PRICE_PER_NIGHT_TAG` using macro |

### Gold Layer Models

| Model | Description | Type |
|-------|-------------|------|
| `obt` | One Big Table - denormalized join of all data | Table |
| `fact` | Final analytics fact table | Table |
| `booking` | Booking dimension extract | Ephemeral |
| `hosts` | Hosts dimension extract | Ephemeral |
| `listings` | Listings dimension extract | Ephemeral |

---

## ⚙️ Macros

### `tag(column_name)`
Categorizes numeric values into price tiers:
```sql
{{ tag('PRICE_PER_NIGHT') }}
-- Returns: 'low' (<100), 'medium' (100-199), 'high' (200+)
```

### `multiply(a, b, precision)`
Multiplies two columns with specified precision:
```sql
{{ multiply('NIGHTS_BOOKED', 'BOOKING_AMOUNT', 2) }}
```

### `generate_schema_name(custom_schema_name, node)`
Custom schema naming to organize tables into bronze/silver/gold schemas.

---

## 📸 Snapshots

Snapshots implement **Slowly Changing Dimension Type 2 (SCD2)** to track historical changes:

| Snapshot | Tracks | Strategy | Updated At Column |
|----------|--------|----------|-------------------|
| `dim_bookings` | Booking status changes | Timestamp | `CREATED_AT` |
| `dim_hosts` | Host profile changes | Timestamp | `CREATED_AT` |
| `dim_listings` | Listing updates | Timestamp | `CREATED_AT` |

---

## 🚀 Setup & Installation

### Prerequisites
- Python 3.12+
- Snowflake account
- [uv](https://github.com/astral-sh/uv) package manager (recommended)

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/aws-dbt-snowflake.git
cd aws-dbt-snowflake
```

### 2. Install Dependencies
```bash
# Using uv (recommended)
uv sync

# Or using pip
pip install dbt-snowflake
```

### 3. Configure Snowflake Connection
Edit `~/.dbt/profiles.yml`:
```yaml
aws_dbt_snowflake_project:
  outputs:
    dev:
      type: snowflake
      account: your_account
      user: your_user
      password: your_password
      role: your_role
      database: AIRBNB
      warehouse: COMPUTE_WH
      schema: dbt_schema
      threads: 1
  target: dev
```

### 4. Verify Connection
```bash
uv run dbt debug
```

---

## 💻 Usage

### Run All Models
```bash
uv run dbt run
```

### Run Specific Layer
```bash
# Bronze layer only
uv run dbt run --select bronze

# Silver layer only
uv run dbt run --select silver

# Gold layer only
uv run dbt run --select gold
```

### Run with Full Refresh
```bash
uv run dbt run --full-refresh
```

### Load Seed Data
```bash
uv run dbt seed
```

### Run Snapshots
```bash
uv run dbt snapshot
```

### Run Tests
```bash
uv run dbt test
```

### Generate Documentation
```bash
uv run dbt docs generate
uv run dbt docs serve
```

---

## 🛠 Technologies Used

| Technology | Purpose |
|------------|---------|
| **dbt** | Data transformation & modeling |
| **Snowflake** | Cloud data warehouse |
| **Python** | Runtime environment |
| **uv** | Package management |
| **Git** | Version control |
| **YAML** | Configuration files |
| **Jinja** | SQL templating |

---

## 📈 Snowflake Schema Layout

After running the pipeline, your Snowflake database will have:

```
AIRBNB (Database)
├── STAGING (Schema)          # Source data
│   ├── BOOKINGS
│   ├── HOSTS
│   └── LISTINGS
│
├── BRONZE (Schema)           # Raw layer
│   ├── BRONZE_BOOKING
│   ├── BRONZE_HOSTS
│   └── BRONZE_LISTINGS
│
├── SILVER (Schema)           # Transformed layer
│   ├── SILVER_BOOKING
│   ├── SILVER_HOSTS
│   └── SILVER_LISTINGS
│
└── GOLD (Schema)             # Analytics layer
    ├── OBT
    ├── FACT
    ├── DIM_BOOKINGS         # Snapshot
    ├── DIM_HOSTS            # Snapshot
    └── DIM_LISTINGS         # Snapshot
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Kirtish Wankhedkar**

---

## ⭐ Star this repo if you found it helpful!

```
    ⭐ Star ⭐
        │
        ▼
   ┌─────────┐
   │  Thank  │
   │   You!  │
   └─────────┘
```
