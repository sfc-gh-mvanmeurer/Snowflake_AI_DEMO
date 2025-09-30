# Springfield City Government Snowflake AI Demo - Implementation Guide

## Overview

This guide provides step-by-step instructions for implementing the Springfield City Government Snowflake Intelligence demo in Snowflake Snowsight. The demo showcases Cortex Analyst, Cortex Search, and Snowflake Intelligence Agent capabilities for city/county government operations.

## Prerequisites

### Snowflake Account Requirements
- **Snowflake Account**: Active Snowflake account with appropriate permissions
- **Cortex Features**: Access to Cortex Analyst, Cortex Search, and Intelligence Agent
- **Warehouse**: Compute warehouse for running queries and processing
- **Database**: Database for storing demo data and objects
- **Git Integration**: Access to Git integration features (optional but recommended)
- **GitHub Repository**: Access to https://github.com/sfc-gh-mvanmeurer/Snowflake_AI_DEMO.git

### Required Permissions
- **ACCOUNTADMIN**: For creating roles and initial setup
- **SYSADMIN**: For creating databases, schemas, and objects
- **SECURITYADMIN**: For role management and security
- **Cortex Usage**: Permissions to use Cortex features

## Git Configuration

### Configure Git with Your Snowflake Email
Before setting up the demo, configure Git with your Snowflake email address:

```bash
# Configure Git with your Snowflake email
git config user.email "michael.vanmeurer@snowflake.com"
git config user.name "Michael Van Meurer"

# Verify configuration
git config user.email
git config user.name
```

This ensures proper attribution and authentication with your GitHub account.

## Implementation Steps

### Step 1: Initial Setup and Roles

#### 1.1 Create Demo Roles
```sql
-- Create demo-specific roles
USE ROLE ACCOUNTADMIN;

-- Create demo admin role
CREATE ROLE IF NOT EXISTS DEMO_ADMIN;
GRANT ROLE DEMO_ADMIN TO ROLE SYSADMIN;

-- Create demo user role
CREATE ROLE IF NOT EXISTS DEMO_USER;
GRANT ROLE DEMO_USER TO ROLE DEMO_ADMIN;

-- Create demo viewer role
CREATE ROLE IF NOT EXISTS DEMO_VIEWER;
GRANT ROLE DEMO_VIEWER TO ROLE DEMO_USER;
```

#### 1.2 Create Demo Warehouse
```sql
-- Create demo warehouse
USE ROLE SYSADMIN;

CREATE WAREHOUSE IF NOT EXISTS DEMO_WH
  WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
  COMMENT = 'Demo warehouse for Springfield City Government demo';

-- Grant warehouse usage
GRANT USAGE ON WAREHOUSE DEMO_WH TO ROLE DEMO_ADMIN;
GRANT USAGE ON WAREHOUSE DEMO_WH TO ROLE DEMO_USER;
GRANT USAGE ON WAREHOUSE DEMO_WH TO ROLE DEMO_VIEWER;
```

### Step 2: Database and Schema Setup

#### 2.1 Create Demo Database
```sql
-- Create demo database
USE ROLE SYSADMIN;

CREATE DATABASE IF NOT EXISTS SPRINGFIELD_GOV;
USE DATABASE SPRINGFIELD_GOV;

-- Create demo schema
CREATE SCHEMA IF NOT EXISTS DEMO;
USE SCHEMA DEMO;

-- Grant schema permissions
GRANT USAGE ON DATABASE SPRINGFIELD_GOV TO ROLE DEMO_ADMIN;
GRANT USAGE ON DATABASE SPRINGFIELD_GOV TO ROLE DEMO_USER;
GRANT USAGE ON DATABASE SPRINGFIELD_GOV TO ROLE DEMO_VIEWER;

GRANT USAGE ON SCHEMA DEMO TO ROLE DEMO_ADMIN;
GRANT USAGE ON SCHEMA DEMO TO ROLE DEMO_USER;
GRANT USAGE ON SCHEMA DEMO TO ROLE DEMO_VIEWER;
```

#### 2.2 Create File Formats
```sql
-- Create file formats for data loading
USE ROLE SYSADMIN;
USE DATABASE SPRINGFIELD_GOV;
USE SCHEMA DEMO;

-- CSV file format
CREATE FILE FORMAT IF NOT EXISTS CSV_FORMAT
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  RECORD_DELIMITER = '\n'
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  NULL_IF = ('NULL', 'null', '')
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;

-- JSON file format
CREATE FILE FORMAT IF NOT EXISTS JSON_FORMAT
  TYPE = 'JSON'
  STRIP_OUTER_ARRAY = TRUE;
```

### Step 3: Data Loading Setup

#### 3.1 Create Internal Stage
```sql
-- Create internal stage for data files
USE ROLE SYSADMIN;
USE DATABASE SPRINGFIELD_GOV;
USE SCHEMA DEMO;

-- Create internal stage
CREATE STAGE IF NOT EXISTS DEMO_STAGE
  DIRECTORY = (ENABLE = TRUE)
  COMMENT = 'Internal stage for demo data files';

-- Grant stage permissions
GRANT READ ON STAGE DEMO_STAGE TO ROLE DEMO_ADMIN;
GRANT READ ON STAGE DEMO_STAGE TO ROLE DEMO_USER;
GRANT READ ON STAGE DEMO_STAGE TO ROLE DEMO_VIEWER;
```

#### 3.2 Upload Data Files
```sql
-- Option 1: Use Git Integration (Recommended)
-- The setup script automatically copies files from the GitHub repository
-- Repository: https://github.com/sfc-gh-mvanmeurer/Snowflake_AI_DEMO.git

-- Option 2: Manual Upload (Alternative)
-- Upload CSV files to stage (run these commands in Snowsight)
-- Note: You'll need to upload the CSV files from the demo_data directory

-- Example upload commands (adjust file paths as needed)
PUT file:///path/to/demo_data/service_category_dim.csv @DEMO_STAGE;
PUT file:///path/to/demo_data/service_dim.csv @DEMO_STAGE;
PUT file:///path/to/demo_data/citizen_dim.csv @DEMO_STAGE;
-- ... continue for all CSV files
```

### Step 4: Execute Setup Scripts

#### 4.1 Run Main Setup Script
```sql
-- Execute the main setup script
USE ROLE SYSADMIN;
USE DATABASE SPRINGFIELD_GOV;
USE SCHEMA DEMO;
USE WAREHOUSE DEMO_WH;

-- Run the government demo setup script
-- Copy and paste the contents of government_demo_setup.sql here
-- Or use @government_demo_setup.sql if the file is accessible
```

#### 4.2 Create Semantic Views
```sql
-- Create semantic views for natural language queries
USE ROLE SYSADMIN;
USE DATABASE SPRINGFIELD_GOV;
USE SCHEMA DEMO;
USE WAREHOUSE DEMO_WH;

-- Run the semantic views script
-- Copy and paste the contents of government_semantic_views.sql here
```

#### 4.3 Configure AI Agent
```sql
-- Configure the Snowflake Intelligence Agent
USE ROLE SYSADMIN;
USE DATABASE SPRINGFIELD_GOV;
USE SCHEMA DEMO;
USE WAREHOUSE DEMO_WH;

-- Run the agent setup script
-- Copy and paste the contents of government_agent_setup.sql here
```

### Step 5: Document Setup (Cortex Search)

#### 5.1 Upload Documents
```sql
-- Option 1: Use Git Integration (Recommended)
-- The setup script automatically copies files from the GitHub repository
-- Repository: https://github.com/sfc-gh-mvanmeurer/Snowflake_AI_DEMO.git
-- Documents are located in: unstructured_docs/ directory

-- Option 2: Manual Upload (Alternative)
-- Upload government documents to stage
USE ROLE SYSADMIN;
USE DATABASE SPRINGFIELD_GOV;
USE SCHEMA DEMO;

-- Upload document files
PUT file:///path/to/unstructured_docs/budget_finance/Annual_Budget_2025.md @DEMO_STAGE;
PUT file:///path/to/unstructured_docs/budget_finance/Q4_2024_Financial_Report.md @DEMO_STAGE;
PUT file:///path/to/unstructured_docs/budget_finance/Procurement_Policy_2025.md @DEMO_STAGE;
-- ... continue for all document files
```

#### 5.2 Create Document Tables
```sql
-- Create tables for document storage
USE ROLE SYSADMIN;
USE DATABASE SPRINGFIELD_GOV;
USE SCHEMA DEMO;

-- Create document metadata table
CREATE TABLE IF NOT EXISTS DOCUMENT_METADATA (
    DOCUMENT_ID STRING,
    DOCUMENT_NAME STRING,
    DOCUMENT_TYPE STRING,
    DEPARTMENT STRING,
    UPLOAD_DATE TIMESTAMP,
    FILE_SIZE NUMBER,
    CONTENT CLOB
);

-- Create document content table
CREATE TABLE IF NOT EXISTS DOCUMENT_CONTENT (
    DOCUMENT_ID STRING,
    CONTENT CLOB,
    METADATA VARIANT
);
```

### Step 6: Configure Cortex Search

#### 6.1 Create Search Service
```sql
-- Create Cortex Search service for documents
USE ROLE SYSADMIN;
USE DATABASE SPRINGFIELD_GOV;
USE SCHEMA DEMO;

-- Create search service
CREATE SEARCH SERVICE IF NOT EXISTS GOVERNMENT_DOCS_SEARCH
  ON TABLE DOCUMENT_CONTENT
  TARGET_COLUMNS (CONTENT)
  COMMENT = 'Search service for government documents';
```

#### 6.2 Populate Document Data
```sql
-- Load document content into tables
USE ROLE SYSADMIN;
USE DATABASE SPRINGFIELD_GOV;
USE SCHEMA DEMO;

-- Load documents from stage
COPY INTO DOCUMENT_CONTENT
FROM @DEMO_STAGE
FILE_FORMAT = (TYPE = 'CSV' FIELD_DELIMITER = '|')
PATTERN = '.*\.md$'
ON_ERROR = 'CONTINUE';
```

### Step 7: Test and Verify Setup

#### 7.1 Verify Data Loading
```sql
-- Check data loading results
USE ROLE DEMO_USER;
USE DATABASE SPRINGFIELD_GOV;
USE SCHEMA DEMO;
USE WAREHOUSE DEMO_WH;

-- Check dimension tables
SELECT COUNT(*) FROM SERVICE_CATEGORY_DIM;
SELECT COUNT(*) FROM SERVICE_DIM;
SELECT COUNT(*) FROM CITIZEN_DIM;
SELECT COUNT(*) FROM DEPARTMENT_DIM;

-- Check fact tables
SELECT COUNT(*) FROM SERVICE_DELIVERY_FACT;
SELECT COUNT(*) FROM BUDGET_TRANSACTIONS;
SELECT COUNT(*) FROM PUBLIC_COMMUNICATION_FACT;
SELECT COUNT(*) FROM CITY_EMPLOYEE_FACT;
```

#### 7.2 Test Semantic Views
```sql
-- Test semantic views
USE ROLE DEMO_USER;
USE DATABASE SPRINGFIELD_GOV;
USE SCHEMA DEMO;
USE WAREHOUSE DEMO_WH;

-- Test budget finance view
SELECT * FROM BUDGET_FINANCE_SEMANTIC_VIEW LIMIT 10;

-- Test citizen services view
SELECT * FROM CITIZEN_SERVICES_SEMANTIC_VIEW LIMIT 10;

-- Test public communications view
SELECT * FROM PUBLIC_COMMUNICATIONS_SEMANTIC_VIEW LIMIT 10;

-- Test human resources view
SELECT * FROM HUMAN_RESOURCES_SEMANTIC_VIEW LIMIT 10;
```

#### 7.3 Test Cortex Search
```sql
-- Test document search
USE ROLE DEMO_USER;
USE DATABASE SPRINGFIELD_GOV;
USE SCHEMA DEMO;
USE WAREHOUSE DEMO_WH;

-- Search for budget information
SELECT * FROM GOVERNMENT_DOCS_SEARCH
WHERE CONTAINS(CONTENT, 'budget');

-- Search for service delivery information
SELECT * FROM GOVERNMENT_DOCS_SEARCH
WHERE CONTAINS(CONTENT, 'service delivery');
```

### Step 8: Demo User Setup

#### 8.1 Create Demo Users
```sql
-- Create demo users
USE ROLE USERADMIN;

-- Create demo admin user
CREATE USER IF NOT EXISTS DEMO_ADMIN_USER
  PASSWORD = 'DemoAdmin123!'
  DEFAULT_ROLE = DEMO_ADMIN
  DEFAULT_WAREHOUSE = DEMO_WH
  DEFAULT_DATABASE = SPRINGFIELD_GOV
  DEFAULT_SCHEMA = DEMO;

-- Create demo user
CREATE USER IF NOT EXISTS DEMO_USER_USER
  PASSWORD = 'DemoUser123!'
  DEFAULT_ROLE = DEMO_USER
  DEFAULT_WAREHOUSE = DEMO_WH
  DEFAULT_DATABASE = SPRINGFIELD_GOV
  DEFAULT_SCHEMA = DEMO;

-- Create demo viewer
CREATE USER IF NOT EXISTS DEMO_VIEWER_USER
  PASSWORD = 'DemoViewer123!'
  DEFAULT_ROLE = DEMO_VIEWER
  DEFAULT_WAREHOUSE = DEMO_WH
  DEFAULT_DATABASE = SPRINGFIELD_GOV
  DEFAULT_SCHEMA = DEMO;
```

#### 8.2 Grant Permissions
```sql
-- Grant permissions to demo users
USE ROLE SECURITYADMIN;

-- Grant roles to users
GRANT ROLE DEMO_ADMIN TO USER DEMO_ADMIN_USER;
GRANT ROLE DEMO_USER TO USER DEMO_USER_USER;
GRANT ROLE DEMO_VIEWER TO USER DEMO_VIEWER_USER;
```

## Demo Execution

### Step 9: Run Demo Scenarios

#### 9.1 Budget Analysis Demo
```sql
-- Login as DEMO_USER_USER
-- Use Cortex Analyst to ask natural language questions

-- Example questions:
-- "What is our total budget for 2025?"
-- "Show me department spending by quarter"
-- "Which contractors received the most funding?"
-- "What are our revenue projections?"
```

#### 9.2 Service Delivery Demo
```sql
-- Example questions:
-- "How many service requests did we process last month?"
-- "What are our average response times by department?"
-- "Which services are most requested by citizens?"
-- "Show me service delivery performance metrics"
```

#### 9.3 Document Search Demo
```sql
-- Use Cortex Search to find information in documents

-- Example searches:
-- "Find information about procurement policies"
-- "Show me budget performance reports"
-- "What are our service delivery procedures?"
-- "Find employee handbook information"
```

#### 9.4 AI Agent Demo
```sql
-- Use the Snowflake Intelligence Agent

-- Example agent queries:
-- "Analyze our budget performance and identify areas for improvement"
-- "Compare our service delivery metrics with industry benchmarks"
-- "Find documents related to emergency response procedures"
-- "Generate a report on employee satisfaction and retention"
```

## Troubleshooting

### Common Issues

#### Data Loading Issues
- **File Format Errors**: Check CSV file format and delimiters
- **Permission Errors**: Ensure proper role and warehouse permissions
- **Stage Issues**: Verify stage creation and file uploads

#### Semantic View Issues
- **View Creation Errors**: Check table names and column references
- **Permission Errors**: Ensure role has access to underlying tables
- **Query Errors**: Verify view syntax and table relationships

#### Cortex Search Issues
- **Search Service Creation**: Ensure proper table structure and permissions
- **Document Loading**: Verify document content and format
- **Search Performance**: Check warehouse size and query optimization

#### Agent Configuration Issues
- **Agent Creation**: Verify agent setup and permissions
- **Tool Configuration**: Check semantic view and search service references
- **Query Execution**: Ensure proper role permissions and warehouse access

### Performance Optimization

#### Warehouse Sizing
- **X-SMALL**: For development and testing
- **SMALL**: For small demos and presentations
- **MEDIUM**: For larger demos with multiple users
- **LARGE**: For production-like demonstrations

#### Query Optimization
- **Semantic Views**: Optimize view definitions for common queries
- **Indexing**: Use appropriate clustering keys for large tables
- **Caching**: Leverage result set caching for repeated queries
- **Warehouse Scaling**: Scale warehouse based on query complexity

## Security Considerations

### Access Control
- **Role-based Access**: Implement proper role hierarchy
- **Data Privacy**: Protect sensitive citizen and employee data
- **Audit Logging**: Enable audit logging for compliance
- **Network Security**: Use appropriate network policies

### Data Governance
- **Data Classification**: Classify data by sensitivity level
- **Retention Policies**: Implement appropriate data retention
- **Backup and Recovery**: Ensure proper backup procedures
- **Compliance**: Meet government data compliance requirements

## Maintenance and Updates

### Regular Maintenance
- **Data Refresh**: Update data regularly for accuracy
- **Performance Monitoring**: Monitor query performance and optimization
- **Security Updates**: Apply security patches and updates
- **Backup Verification**: Verify backup and recovery procedures

### Demo Updates
- **Content Updates**: Update documents and data as needed
- **Feature Updates**: Incorporate new Snowflake features
- **User Training**: Provide training for demo users
- **Documentation**: Keep implementation guide updated

## Conclusion

This implementation guide provides a comprehensive approach to deploying the Springfield City Government Snowflake AI demo. Follow the steps in order, test each component, and troubleshoot issues as they arise. The demo showcases the power of Snowflake Intelligence for government operations while maintaining security and performance standards.

For additional support or questions, refer to the Snowflake documentation or contact your Snowflake representative.

---

**Prepared for**: Springfield City Government Snowflake AI Demo  
**Implementation Guide Version**: 1.0  
**Last Updated**: January 2025
