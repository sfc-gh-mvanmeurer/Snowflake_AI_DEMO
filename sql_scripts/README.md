# Government SQL Scripts for Snowflake AI Demo

This directory contains SQL scripts for setting up the Springfield City Government Snowflake Intelligence demo environment. These scripts create the complete data infrastructure, semantic views, and AI agent configuration for a city/county government context.

## Script Overview

### Total Scripts: 3 files
- **government_demo_setup.sql** - Complete database and data setup
- **government_semantic_views.sql** - Business unit semantic views
- **government_agent_setup.sql** - AI agent configuration

## Script Descriptions

### 1. government_demo_setup.sql
**Purpose**: Complete database and data infrastructure setup for government demo

**Key Components**:
- **Roles & Permissions**: Government-specific roles and access controls
- **Database & Schema**: City government database structure
- **File Formats**: CSV and JSON file format configurations
- **Git Integration**: Automated data loading from GitHub repository
- **Internal Stage**: File staging for data loading
- **Dimension Tables**: 13 government dimension tables
- **Fact Tables**: 4 government fact tables
- **CRM Tables**: 3 government service request tables
- **Data Loading**: Automated CSV data loading
- **Verification**: Data quality and completeness checks

**Tables Created**:
- **Dimension Tables**: service_category_dim, service_dim, citizen_dim, contractor_dim, department_dim, district_dim, city_employee_dim, public_communication_dim, communication_channel_dim, government_job_dim, government_location_dim, account_dim, region_dim
- **Fact Tables**: service_delivery_fact, budget_transactions, public_communication_fact, city_employee_fact
- **CRM Tables**: government_accounts, government_service_requests, government_contacts

### 2. government_semantic_views.sql
**Purpose**: Create semantic views for natural language queries across government business units

**Semantic Views**:
- **BUDGET_FINANCE_SEMANTIC_VIEW**: Budget, finance, and procurement data
- **CITIZEN_SERVICES_SEMANTIC_VIEW**: Service delivery and citizen engagement
- **PUBLIC_COMMUNICATIONS_SEMANTIC_VIEW**: Communication campaigns and outreach
- **HUMAN_RESOURCES_SEMANTIC_VIEW**: Employee data and HR metrics

**Features**:
- **Synonyms**: Government-specific terminology and aliases
- **Facts**: Key metrics and performance indicators
- **Dimensions**: Descriptive attributes and classifications
- **Metrics**: Calculated measures and KPIs
- **Natural Language**: Optimized for conversational queries

### 3. government_agent_setup.sql
**Purpose**: Configure the Snowflake Intelligence Agent for government operations

**Agent Configuration**:
- **Agent Name**: Government_City_County_Agent
- **Profile**: City/County Government AI Assistant
- **Instructions**: Government-focused response and orchestration
- **Sample Questions**: Government-relevant query examples
- **Tools**: Text2SQL, Search, and Web Scraping capabilities

**Tool Resources**:
- **Semantic Views**: All four government semantic views
- **Search Services**: Document search across government content
- **Web Scraping**: External data integration capabilities

## Usage Instructions

### 1. Initial Setup
```sql
-- Run the complete setup script
@government_demo_setup.sql
```

### 2. Semantic Views
```sql
-- Create semantic views for natural language queries
@government_semantic_views.sql
```

### 3. AI Agent Configuration
```sql
-- Configure the government AI agent
@government_agent_setup.sql
```

## Data Model Overview

### Government Data Architecture
- **Star Schema**: Optimized for government analytics
- **13 Dimension Tables**: Government entities and classifications
- **4 Fact Tables**: Government transactions and metrics
- **3 CRM Tables**: Government service requests and accounts
- **4 Semantic Views**: Business unit-specific views

### Key Government Domains
- **Budget & Finance**: Financial transactions, budget data, procurement
- **Citizen Services**: Service delivery, citizen engagement, service requests
- **Public Communications**: Communication campaigns, outreach, engagement
- **Human Resources**: Employee data, HR metrics, workforce planning

## Demo Scenarios

### Scenario 1: Budget Analysis
- "What is our total budget for 2025?"
- "Show me department spending by quarter"
- "Which contractors received the most funding?"
- "What are our revenue projections?"

### Scenario 2: Service Delivery
- "How many service requests did we process last month?"
- "What are our average response times by department?"
- "Which services are most requested by citizens?"
- "Show me service delivery performance metrics"

### Scenario 3: Public Communications
- "What communication campaigns are running?"
- "How effective are our social media campaigns?"
- "What is our citizen engagement rate?"
- "Show me communication performance by channel"

### Scenario 4: Human Resources
- "How many employees do we have by department?"
- "What is our average salary by job title?"
- "Show me employee turnover rates"
- "What training programs are available?"

## Technical Features

### Snowflake Intelligence Capabilities
- **Cortex Analyst**: Text-to-SQL via semantic views
- **Cortex Search**: Vector search for unstructured documents
- **Snowflake Intelligence Agent**: Multi-tool AI agent with orchestration
- **Git Integration**: Automated data loading from GitHub repository

### Data Integration
- **Structured Data**: Relational database with star schema
- **Unstructured Data**: Government documents and policies
- **External Data**: Web scraping and API integration
- **Real-time Updates**: Automated data refresh and synchronization

### Security and Compliance
- **Role-based Access**: Government-specific security model
- **Data Governance**: Compliance with government data standards
- **Audit Logging**: Complete audit trail for all operations
- **Privacy Protection**: Citizen data protection and privacy

## Performance Optimization

### Query Performance
- **Semantic Views**: Optimized for natural language queries
- **Indexing**: Strategic indexing for government data patterns
- **Caching**: Intelligent caching for frequently accessed data
- **Partitioning**: Time-based partitioning for historical data

### Scalability
- **Auto-scaling**: Automatic resource scaling based on demand
- **Multi-warehouse**: Separate warehouses for different workloads
- **Data Sharing**: Secure data sharing across government departments
- **Cloud Integration**: Seamless cloud and on-premises integration

## Maintenance and Updates

### Regular Maintenance
- **Data Refresh**: Automated data loading and updates
- **Performance Monitoring**: Query performance and optimization
- **Security Updates**: Regular security patches and updates
- **Backup and Recovery**: Comprehensive backup and disaster recovery

### Monitoring and Alerts
- **Performance Metrics**: Query performance and resource utilization
- **Error Monitoring**: System errors and exception handling
- **Usage Analytics**: User behavior and query patterns
- **Capacity Planning**: Resource planning and optimization

## Conclusion

These SQL scripts provide a complete foundation for the Springfield City Government Snowflake Intelligence demo. The scripts create a comprehensive data infrastructure that supports natural language queries, document search, and AI-powered analysis for city and county government operations.

The implementation supports various demo scenarios and use cases while maintaining security, compliance, and performance standards required for government operations.

---

**Prepared for**: Springfield City Government Snowflake AI Demo  
**Script Version**: 1.0  
**Last Updated**: January 2025
