-- ========================================================================
-- Snowflake AI Demo - Government Setup Script
-- This script creates the database, schema, tables, and loads all data
-- Repository: https://github.com/sfc-gh-mvanmeurer/Snowflake_AI_DEMO.git
-- ========================================================================

-- Switch to accountadmin role to create warehouse
USE ROLE accountadmin;

-- Enable Snowflake Intelligence by creating the Config DB & Schema
-- CREATE DATABASE IF NOT EXISTS snowflake_intelligence;
-- CREATE SCHEMA IF NOT EXISTS snowflake_intelligence.agents;

-- Allow anyone to see the agents in this schema
GRANT USAGE ON DATABASE snowflake_intelligence TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA snowflake_intelligence.agents TO ROLE PUBLIC;

create or replace role SF_Intelligence_Demo;

SET current_user_name = CURRENT_USER();

-- Step 2: Use the variable to grant the role
GRANT ROLE SF_Intelligence_Demo TO USER IDENTIFIER($current_user_name);
GRANT CREATE DATABASE ON ACCOUNT TO ROLE SF_Intelligence_Demo;

-- Create a dedicated warehouse for the demo with auto-suspend/resume
CREATE OR REPLACE WAREHOUSE Snow_Intelligence_demo_wh 
    WITH WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE;

-- Grant usage on warehouse to admin role
GRANT USAGE ON WAREHOUSE SNOW_INTELLIGENCE_DEMO_WH TO ROLE SF_Intelligence_Demo;

-- Alter current user's default role and warehouse to the ones used here
ALTER USER IDENTIFIER($current_user_name) SET DEFAULT_ROLE = SF_Intelligence_Demo;
ALTER USER IDENTIFIER($current_user_name) SET DEFAULT_WAREHOUSE = Snow_Intelligence_demo_wh;

-- Switch to SF_Intelligence_Demo role to create demo objects
use role SF_Intelligence_Demo;

-- Create database and schema
CREATE OR REPLACE DATABASE SF_AI_DEMO;
USE DATABASE SF_AI_DEMO;

CREATE SCHEMA IF NOT EXISTS DEMO_SCHEMA;
USE SCHEMA DEMO_SCHEMA;

-- Create file format for CSV files
CREATE OR REPLACE FILE FORMAT CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    ESCAPE = 'NONE'
    ESCAPE_UNENCLOSED_FIELD = '\134'
    DATE_FORMAT = 'YYYY-MM-DD'
    TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS'
    NULL_IF = ('NULL', 'null', '', 'N/A', 'n/a');

use role accountadmin;
-- Create API Integration for GitHub (public repository access)
CREATE OR REPLACE API INTEGRATION git_api_integration
    API_PROVIDER = git_https_api
    API_ALLOWED_PREFIXES = ('https://github.com/sfc-gh-mvanmeurer/')
    ENABLED = TRUE;

GRANT USAGE ON INTEGRATION GIT_API_INTEGRATION TO ROLE SF_Intelligence_Demo;

use role SF_Intelligence_Demo;
-- Create Git repository integration for the public demo repository
CREATE OR REPLACE GIT REPOSITORY SF_AI_DEMO_REPO
    API_INTEGRATION = git_api_integration
    ORIGIN = 'https://github.com/sfc-gh-mvanmeurer/Snowflake_AI_DEMO.git';

-- Create internal stage for copied data files
CREATE OR REPLACE STAGE INTERNAL_DATA_STAGE
    FILE_FORMAT = CSV_FORMAT
    COMMENT = 'Internal stage for copied demo data files'
    DIRECTORY = ( ENABLE = TRUE)
    ENCRYPTION = (   TYPE = 'SNOWFLAKE_SSE');

ALTER GIT REPOSITORY SF_AI_DEMO_REPO FETCH;

-- ========================================================================
-- COPY DATA FROM GIT TO INTERNAL STAGE
-- ========================================================================

-- Copy all CSV files from Git repository demo_data folder to internal stage
COPY FILES
INTO @INTERNAL_DATA_STAGE/demo_data/
FROM @SF_AI_DEMO_REPO/branches/main/demo_data/;

COPY FILES
INTO @INTERNAL_DATA_STAGE/unstructured_docs/
FROM @SF_AI_DEMO_REPO/branches/main/unstructured_docs/;

-- Verify files were copied
LS @INTERNAL_DATA_STAGE;

ALTER STAGE INTERNAL_DATA_STAGE refresh;

-- ========================================================================
-- DIMENSION TABLES
-- ========================================================================

-- Service Category Dimension
CREATE OR REPLACE TABLE service_category_dim (
    category_key INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    vertical VARCHAR(50) NOT NULL
);

-- Service Dimension
CREATE OR REPLACE TABLE service_dim (
    service_key INT PRIMARY KEY,
    service_name VARCHAR(200) NOT NULL,
    category_key INT NOT NULL,
    category_name VARCHAR(100),
    vertical VARCHAR(50)
);

-- Contractor Dimension
CREATE OR REPLACE TABLE contractor_dim (
    contractor_key INT PRIMARY KEY,
    contractor_name VARCHAR(200) NOT NULL,
    vertical VARCHAR(50) NOT NULL,
    address VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(10),
    zip VARCHAR(20)
);

-- Citizen Dimension
CREATE OR REPLACE TABLE citizen_dim (
    citizen_key INT PRIMARY KEY,
    citizen_name VARCHAR(200) NOT NULL,
    entity_type VARCHAR(100),
    vertical VARCHAR(50),
    address VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(10),
    zip VARCHAR(20)
);

-- Account Dimension (Finance)
CREATE OR REPLACE TABLE account_dim (
    account_key INT PRIMARY KEY,
    account_name VARCHAR(100) NOT NULL,
    account_type VARCHAR(50)
);

-- Department Dimension
CREATE OR REPLACE TABLE department_dim (
    department_key INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

-- District Dimension
CREATE OR REPLACE TABLE district_dim (
    district_key INT PRIMARY KEY,
    district_name VARCHAR(100) NOT NULL
);

-- City Employee Dimension
CREATE OR REPLACE TABLE city_employee_dim (
    employee_key INT PRIMARY KEY,
    employee_name VARCHAR(200) NOT NULL,
    hire_date DATE
);

-- Public Communication Dimension (Marketing)
CREATE OR REPLACE TABLE public_communication_dim (
    communication_key INT PRIMARY KEY,
    communication_name VARCHAR(300) NOT NULL,
    objective VARCHAR(100)
);

-- Communication Channel Dimension (Marketing)
CREATE OR REPLACE TABLE communication_channel_dim (
    channel_key INT PRIMARY KEY,
    channel_name VARCHAR(100) NOT NULL
);

-- City Employee Dimension (HR)
CREATE OR REPLACE TABLE city_employee_dim (
    employee_key INT PRIMARY KEY,
    employee_name VARCHAR(200) NOT NULL,
    gender VARCHAR(1),
    hire_date DATE
);

-- Government Job Dimension (HR)
CREATE OR REPLACE TABLE government_job_dim (
    job_key INT PRIMARY KEY,
    job_title VARCHAR(100) NOT NULL,
    job_level INT
);

-- Government Location Dimension (HR)
CREATE OR REPLACE TABLE government_location_dim (
    location_key INT PRIMARY KEY,
    location_name VARCHAR(200) NOT NULL
);

-- ========================================================================
-- FACT TABLES
-- ========================================================================

-- Service Delivery Fact Table
CREATE OR REPLACE TABLE service_delivery_fact (
    service_id INT PRIMARY KEY,
    date DATE NOT NULL,
    citizen_key INT NOT NULL,
    service_key INT NOT NULL,
    employee_key INT NOT NULL,
    district_key INT NOT NULL,
    contractor_key INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    units INT NOT NULL
);

-- Budget Transactions Fact Table
CREATE OR REPLACE TABLE budget_transactions (
    transaction_id INT PRIMARY KEY,
    date DATE NOT NULL,
    account_key INT NOT NULL,
    department_key INT NOT NULL,
    contractor_key INT NOT NULL,
    service_key INT NOT NULL,
    citizen_key INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL
);

-- Public Communication Fact Table
CREATE OR REPLACE TABLE public_communication_fact (
    communication_fact_id INT PRIMARY KEY,
    date DATE NOT NULL,
    communication_key INT NOT NULL,
    service_key INT NOT NULL,
    channel_key INT NOT NULL,
    district_key INT NOT NULL,
    spend DECIMAL(10,2) NOT NULL,
    participants_generated INT NOT NULL,
    impressions INT NOT NULL
);

-- City Employee Fact Table
CREATE OR REPLACE TABLE city_employee_fact (
    hr_fact_id INT PRIMARY KEY,
    date DATE NOT NULL,
    employee_key INT NOT NULL,
    department_key INT NOT NULL,
    job_key INT NOT NULL,
    location_key INT NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    attrition_flag INT NOT NULL
);

-- ========================================================================
-- GOVERNMENT CRM TABLES
-- ========================================================================

-- Government Accounts Table
CREATE OR REPLACE TABLE government_accounts (
    account_id VARCHAR(20) PRIMARY KEY,
    account_name VARCHAR(200) NOT NULL,
    citizen_key INT NOT NULL,
    entity_type VARCHAR(100),
    vertical VARCHAR(50),
    billing_street VARCHAR(200),
    billing_city VARCHAR(100),
    billing_state VARCHAR(10),
    billing_postal_code VARCHAR(20),
    account_type VARCHAR(50),
    annual_revenue DECIMAL(15,2),
    employees INT,
    created_date DATE
);

-- Government Service Requests Table
CREATE OR REPLACE TABLE government_service_requests (
    service_request_id VARCHAR(20) PRIMARY KEY,
    service_id INT,
    account_id VARCHAR(20) NOT NULL,
    service_request_name VARCHAR(200) NOT NULL,
    status VARCHAR(100) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    priority VARCHAR(100),
    close_date DATE,
    created_date DATE,
    request_source VARCHAR(100),
    type VARCHAR(100),
    communication_id INT
);

-- Government Contacts Table
CREATE OR REPLACE TABLE government_contacts (
    contact_id VARCHAR(20) PRIMARY KEY,
    service_request_id VARCHAR(20) NOT NULL,
    account_id VARCHAR(20) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(200),
    phone VARCHAR(50),
    title VARCHAR(100),
    department VARCHAR(100),
    request_source VARCHAR(100),
    communication_no INT,
    created_date DATE
);

-- ========================================================================
-- LOAD DIMENSION DATA FROM INTERNAL STAGE
-- ========================================================================

-- Load Service Category Dimension
COPY INTO service_category_dim
FROM @INTERNAL_DATA_STAGE/demo_data/service_category_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Service Dimension
COPY INTO service_dim
FROM @INTERNAL_DATA_STAGE/demo_data/service_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Contractor Dimension
COPY INTO contractor_dim
FROM @INTERNAL_DATA_STAGE/demo_data/contractor_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Citizen Dimension
COPY INTO citizen_dim
FROM @INTERNAL_DATA_STAGE/demo_data/citizen_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Account Dimension
COPY INTO account_dim
FROM @INTERNAL_DATA_STAGE/demo_data/account_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Department Dimension
COPY INTO department_dim
FROM @INTERNAL_DATA_STAGE/demo_data/department_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load District Dimension
COPY INTO district_dim
FROM @INTERNAL_DATA_STAGE/demo_data/district_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load City Employee Dimension
COPY INTO city_employee_dim
FROM @INTERNAL_DATA_STAGE/demo_data/city_employee_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Public Communication Dimension
COPY INTO public_communication_dim
FROM @INTERNAL_DATA_STAGE/demo_data/public_communication_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Communication Channel Dimension
COPY INTO communication_channel_dim
FROM @INTERNAL_DATA_STAGE/demo_data/communication_channel_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Government Job Dimension
COPY INTO government_job_dim
FROM @INTERNAL_DATA_STAGE/demo_data/government_job_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Government Location Dimension
COPY INTO government_location_dim
FROM @INTERNAL_DATA_STAGE/demo_data/government_location_dim.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- ========================================================================
-- LOAD FACT DATA FROM INTERNAL STAGE
-- ========================================================================

-- Load Service Delivery Fact
COPY INTO service_delivery_fact
FROM @INTERNAL_DATA_STAGE/demo_data/service_delivery_fact.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Budget Transactions
COPY INTO budget_transactions
FROM @INTERNAL_DATA_STAGE/demo_data/budget_transactions.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Public Communication Fact
COPY INTO public_communication_fact
FROM @INTERNAL_DATA_STAGE/demo_data/public_communication_fact.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load City Employee Fact
COPY INTO city_employee_fact
FROM @INTERNAL_DATA_STAGE/demo_data/city_employee_fact.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- ========================================================================
-- LOAD GOVERNMENT CRM DATA FROM INTERNAL STAGE
-- ========================================================================

-- Load Government Accounts
COPY INTO government_accounts
FROM @INTERNAL_DATA_STAGE/demo_data/government_accounts.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Government Service Requests
COPY INTO government_service_requests
FROM @INTERNAL_DATA_STAGE/demo_data/government_service_requests.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- Load Government Contacts
COPY INTO government_contacts
FROM @INTERNAL_DATA_STAGE/demo_data/government_contacts.csv
FILE_FORMAT = CSV_FORMAT
ON_ERROR = 'CONTINUE';

-- ========================================================================
-- VERIFICATION
-- ========================================================================

-- Verify Git integration and file copy
SHOW GIT REPOSITORIES;

-- Verify data loads
SELECT 'DIMENSION TABLES' as category, '' as table_name, NULL as row_count
UNION ALL
SELECT '', 'service_category_dim', COUNT(*) FROM service_category_dim
UNION ALL
SELECT '', 'service_dim', COUNT(*) FROM service_dim
UNION ALL
SELECT '', 'contractor_dim', COUNT(*) FROM contractor_dim
UNION ALL
SELECT '', 'citizen_dim', COUNT(*) FROM citizen_dim
UNION ALL
SELECT '', 'account_dim', COUNT(*) FROM account_dim
UNION ALL
SELECT '', 'department_dim', COUNT(*) FROM department_dim
UNION ALL
SELECT '', 'district_dim', COUNT(*) FROM district_dim
UNION ALL
SELECT '', 'city_employee_dim', COUNT(*) FROM city_employee_dim
UNION ALL
SELECT '', 'public_communication_dim', COUNT(*) FROM public_communication_dim
UNION ALL
SELECT '', 'communication_channel_dim', COUNT(*) FROM communication_channel_dim
UNION ALL
SELECT '', 'government_job_dim', COUNT(*) FROM government_job_dim
UNION ALL
SELECT '', 'government_location_dim', COUNT(*) FROM government_location_dim
UNION ALL
SELECT '', '', NULL
UNION ALL
SELECT 'FACT TABLES', '', NULL
UNION ALL
SELECT '', 'service_delivery_fact', COUNT(*) FROM service_delivery_fact
UNION ALL
SELECT '', 'budget_transactions', COUNT(*) FROM budget_transactions
UNION ALL
SELECT '', 'public_communication_fact', COUNT(*) FROM public_communication_fact
UNION ALL
SELECT '', 'city_employee_fact', COUNT(*) FROM city_employee_fact
UNION ALL
SELECT '', '', NULL
UNION ALL
SELECT 'GOVERNMENT CRM TABLES', '', NULL
UNION ALL
SELECT '', 'government_accounts', COUNT(*) FROM government_accounts
UNION ALL
SELECT '', 'government_service_requests', COUNT(*) FROM government_service_requests
UNION ALL
SELECT '', 'government_contacts', COUNT(*) FROM government_contacts;

-- Show all tables
SHOW TABLES IN SCHEMA DEMO_SCHEMA;
