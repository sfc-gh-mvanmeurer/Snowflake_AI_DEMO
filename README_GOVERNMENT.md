# Snowflake Intelligence Demo - Government Edition

This project demonstrates the comprehensive Snowflake Intelligence capabilities for **Cities and Counties** including:
- **Cortex Analyst** (Text-to-SQL via semantic views)
- **Cortex Search** (Vector search for unstructured documents)  
- **Snowflake Intelligence Agent** (Multi-tool AI agent with orchestration)
- **Git Integration** (Automated data loading from GitHub repository)

## Government Transformation Overview

This demo has been transformed from a business-focused platform to a **government-focused platform** specifically designed for cities and counties. The transformation maintains the same sophisticated architecture while adapting all data, terminology, and use cases to be relevant for government stakeholders.

## Setup Instructions

**Single Script Setup**: The entire government demo environment is created with one script:

1. **Run the complete setup script**:
   ```sql
   -- Execute in Snowflake worksheet
   /sql_scripts/government_demo_setup.sql
   ```

2. **What the script creates**:
   - `SF_Intelligence_Demo` role and permissions
   - `Snow_Intelligence_demo_wh` warehouse
   - `SF_AI_DEMO.DEMO_SCHEMA` database and schema
   - Git repository integration
   - All dimension and fact tables with government data
   - 4 semantic views for Cortex Analyst
   - 4 Cortex Search services for government documents
   - Web scraping function with external access integration
   - 1 Snowflake Intelligence Agent with multi-tool capabilities

3. **Post-Setup Verification(Optional)**:
   - Run `SHOW TABLES;` to verify 20 tables created (17 original + 3 Government CRM)
   - Run `SHOW SEMANTIC VIEWS;` to verify 4 semantic views
   - Run `SHOW CORTEX SEARCH SERVICES;` to verify 4 search services
   - Run `SHOW FUNCTIONS LIKE 'WEB_SCRAPE';` to verify web scraping function

4. **RUN DEMO**:
   - Use AI/ML option on the left navigation bar
   - Pick "Snowflake Intelligence"
   - Make sure to pick the right agent at the bottom-left 

## Key Components

### 1. Data Infrastructure
- **Star Schema Design**: 13 dimension tables and 4 fact tables covering Budget & Finance, Citizen Services, Public Communications, HR
- **Government CRM Integration**: 3 Government tables (Accounts, Service Requests, Contacts) with 62,000+ CRM records
- **Automated Data Loading**: Git integration pulls data from GitHub repository
- **Realistic Government Data**: 210,000+ records across all government domains with complete citizen journey
- **Database**: `SF_AI_DEMO` with schema `DEMO_SCHEMA`
- **Warehouse**: `Snow_Intelligence_demo_wh` (XSMALL with auto-suspend/resume)

### 2. Semantic Views (4 Government Domains)
- **Budget & Finance Semantic View**: Budget transactions, accounts, departments, contractors
- **Citizen Services Semantic View**: Service delivery data, citizens, services, districts, employees
- **Public Communications Semantic View**: Communication campaigns, channels, outreach, community engagement + **Service Request Attribution** (Government CRM integration)
- **Human Resources Semantic View**: Employee data, departments, jobs, locations, attrition

### 3. Cortex Search Services (4 Domain-Specific)
- **Budget & Finance Documents**: Budget documents, procurement policies, contractor contracts
- **HR Documents**: Employee handbook, civil service policies, department overviews
- **Public Communications Documents**: Communication strategies, community engagement reports, public meeting minutes
- **Citizen Services Documents**: Service delivery procedures, citizen success stories, permit processes

### 4. Snowflake Intelligence Agent
- **Multi-Tool Agent**: Combines Cortex Search, Cortex Analyst, and Web Scraping capabilities
- **Cross-Domain Analysis**: Can query all government domains and documents
- **Web Content Analysis**: Can scrape and analyze content from any web URL
- **Natural Language Interface**: Responds to government questions across all departments
- **Visualization Support**: Generates charts and visualizations for data insights

### 5. GitHub Integration
- **Repository**: `https://github.com/NickAkincilar/Snowflake_AI_DEMO.git`
- **Automated Sync**: Pulls demo data and unstructured documents
- **File Processing**: Parses PDF documents using Cortex Parse for search indexing

## Government Data Model

### Dimension Tables (13)
- `service_category_dim`, `service_dim`, `contractor_dim`, `citizen_dim`
- `account_dim`, `department_dim`, `district_dim`, `city_employee_dim`
- `public_communication_dim`, `communication_channel_dim`, `government_job_dim`, `government_location_dim`

### Fact Tables (4)
- `service_delivery_fact` - Service delivery transactions with amounts and units (12,000 records)
- `budget_transactions` - Budget transactions across departments
- `public_communication_fact` - Communication campaign metrics with service targeting
- `city_employee_fact` - Employee data with salary and attrition (5,640 records)

### Government CRM Tables (3)
- `government_accounts` - Citizen accounts linked to citizen_dim (1,000 records)
- `government_service_requests` - Service request pipeline and completion data (25,000 records)
- `government_contacts` - Contact records with communication attribution (37,563 records)

## Agent Capabilities

The Government City & County Agent can:
- **Analyze structured data** across Budget & Finance, Citizen Services, Public Communications, and HR domains
- **Perform service request attribution** from communication campaigns to completed services via Government CRM integration
- **Search unstructured documents** to provide context and policy information
- **Scrape and analyze web content** from any URL to incorporate external data and insights
- **Generate visualizations** including trend lines, bar charts, and analytics
- **Combine insights** from multiple data sources for comprehensive answers
- **Calculate communication ROI** and citizen engagement costs across the complete service journey
- **Understand government context** and provide domain-specific insights

## Government Demo Script: Cross-Functional Analysis

The following questions demonstrate the agent's ability to perform cross-domain analysis, connecting insights across Citizen Services, HR, Public Communications, and Budget & Finance:

### 🏛️ Budget & Finance Analysis
1. **Budget Performance & Trends**  
   "Show me monthly budget expenditures for 2025 with visualizations. Which months had the highest spending?"

2. **Department Budget Analysis**  
   "What are our department budget allocations for 2025? Show me spending by department and contractor."

3. **Contractor Spend Analysis**  
   "Who are our top contractors by spend? Show me their contract values and service delivery performance."

### 👥 Citizen Services & Engagement
1. **Service Delivery Performance**  
   "How many citizen service requests were completed this quarter? What are our most requested services by district?"

2. **Service Request Trends**  
   "Show me service request completion rates by department. Which departments have the best response times?"

3. **Citizen Satisfaction Analysis**  
   "What are our citizen satisfaction scores by service type? How do completion rates correlate with satisfaction?"

### 📢 Public Communications & Outreach
1. **Communication Campaign Effectiveness**  
   "Which public communication campaigns were most successful in 2025? Show me communication ROI and engagement by channel."

2. **Community Engagement Analysis**  
   "Show me the complete communication funnel from impressions to service requests. Which campaigns have the best conversion rates?"

3. **Public Meeting & Outreach Performance**  
   "Compare communication spend to actual citizen engagement by channel. Which channels drive the most service requests?"

### 💰 Budget & Cross-Domain Integration
1. **Communication Attribution & Budget Analysis**  
   "Show me budget impact of each communication channel. What is our true communication ROI from campaigns to service completion?"

2. **Citizen Service Cost Analysis**  
   "Calculate our cost per service request by communication channel. Which channels deliver the most cost-effective citizen engagement?"

3. **Contractor Spend & Policy Compliance**  
   "What are our top contractor expenses? Check our procurement policy - are we following government contracting guidelines?"

### 🔍 Cross-Functional Insights & External Data
**Web Content Analysis Questions**  
1. **Government Benchmarking**  
   "Analyze the content from [neighboring city website URL] and compare their service offerings to our service catalog."

2. **Policy Research**  
   "Scrape content from [government best practices URL] and analyze how it relates to our service delivery performance and citizen satisfaction."

3. **External Data Integration**  
   "Get the latest information from [state government news URL] and analyze its potential impact on our budget forecast."

## Government Use Cases

### Budget & Finance
- "What are our department budget allocations for 2025?"
- "Which contractors received the most contracts last year?"
- "Show me our revenue sources and expenditure trends"
- "What's our budget variance by department?"

### Citizen Services
- "How many building permits were issued this quarter?"
- "What are our most requested services by district?"
- "Show me citizen satisfaction scores by service type"
- "What's our average service completion time?"

### Public Communications
- "What public engagement campaigns were most successful?"
- "How many community meetings were held last year?"
- "Show me public communication effectiveness by channel"
- "What's our social media engagement rate?"

### Human Resources
- "What's our employee headcount by department?"
- "Which departments have the highest turnover rates?"
- "Show me employee satisfaction scores by location"
- "What's our average salary by job level?"

## Data Transformation Summary

### What Changed
1. **Business → Government Terminology**:
   - Customers → Citizens
   - Products → Services
   - Sales → Service Delivery
   - Marketing → Public Communications
   - Vendors → Contractors
   - Regions → Districts

2. **Data Content**:
   - Business entities → Government entities
   - Commercial services → Municipal services
   - Sales transactions → Service delivery
   - Marketing campaigns → Public communications
   - Business documents → Government documents

3. **Use Cases**:
   - Business intelligence → Government intelligence
   - Customer analytics → Citizen analytics
   - Sales performance → Service delivery performance
   - Marketing ROI → Communication ROI

### What Stayed the Same
1. **Technical Architecture**: All Snowflake Intelligence capabilities
2. **Data Structure**: Star schema design maintained
3. **Agent Capabilities**: Multi-tool orchestration
4. **Integration**: Git, Cortex Search, Cortex Analyst
5. **Visualization**: Charts and analytics capabilities

## Implementation Benefits

### For Cities & Counties
- **Relevant Data**: All examples and use cases are government-focused
- **Familiar Terminology**: Uses government language and concepts
- **Practical Applications**: Real-world government scenarios
- **Stakeholder Engagement**: IT, Finance, HR, Public Works, Planning departments

### For Snowflake Sales
- **Immediate Relevance**: Demo resonates with government prospects
- **Use Case Clarity**: Clear value proposition for government operations
- **Technical Demonstration**: Shows full Snowflake Intelligence capabilities
- **Competitive Advantage**: Government-specific demo differentiates from generic business demos

## Next Steps

1. **Replace Documents**: Update unstructured documents with government equivalents
2. **Test Agent**: Verify agent responses with government terminology
3. **Customize Examples**: Add city/county-specific examples
4. **Train Team**: Ensure sales team understands government use cases
5. **Demo Script**: Practice government-focused demo scenarios

---

**Transformation Status**: ✅ Complete
**Government Ready**: ✅ All components adapted for cities and counties
**Demo Ready**: ✅ All features optimized for government stakeholders
