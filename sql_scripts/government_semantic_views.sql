-- ========================================================================
-- Snowflake AI Demo - Government Semantic Views (Step 2 of 4)
--
-- DESCRIPTION:
-- Creates semantic views that enable natural language queries via Cortex Analyst.
-- These views define the business logic and relationships for government domains:
-- - Budget & Finance: Financial transactions and budget analysis
-- - Citizen Services: Service delivery and citizen engagement
-- - Public Communications: Campaign performance and outreach
-- - Human Resources: Employee data and workforce analytics
--
-- PREREQUISITES:
-- - government_demo_setup.sql must be completed successfully
-- - All tables must be populated with data
--
-- EXECUTION TIME: ~2-3 minutes
--
-- NEXT STEPS: After completion, run government_cortex_search_setup.sql
-- ========================================================================
USE ROLE SF_Intelligence_Demo;
USE DATABASE SPRINGFIELD_GOV;
USE SCHEMA DEMO;
USE WAREHOUSE SNOW_INTELLIGENCE_DEMO_WH;

-- ========================================================================
-- BUDGET & FINANCE SEMANTIC VIEW
-- ========================================================================

CREATE OR REPLACE SEMANTIC VIEW SPRINGFIELD_GOV.DEMO.BUDGET_FINANCE_SEMANTIC_VIEW
    TABLES (
        TRANSACTIONS AS BUDGET_TRANSACTIONS PRIMARY KEY (TRANSACTION_ID) WITH SYNONYMS=('budget transactions','financial data','expenditures') COMMENT='All budget transactions across departments',
        ACCOUNTS AS ACCOUNT_DIM PRIMARY KEY (ACCOUNT_KEY) WITH SYNONYMS=('chart of accounts','account types','budget accounts') COMMENT='Account dimension for financial categorization',
        DEPARTMENTS AS DEPARTMENT_DIM PRIMARY KEY (DEPARTMENT_KEY) WITH SYNONYMS=('departments','business units','city departments') COMMENT='Department dimension for cost center analysis',
        CONTRACTORS AS CONTRACTOR_DIM PRIMARY KEY (CONTRACTOR_KEY) WITH SYNONYMS=('contractors','vendors','suppliers') COMMENT='Contractor information for spend analysis',
        SERVICES AS SERVICE_DIM PRIMARY KEY (SERVICE_KEY) WITH SYNONYMS=('services','municipal services','city services') COMMENT='Service dimension for transaction analysis',
        CITIZENS AS CITIZEN_DIM PRIMARY KEY (CITIZEN_KEY) WITH SYNONYMS=('citizens','residents','constituents') COMMENT='Citizen dimension for service analysis'
    )
    RELATIONSHIPS (
        TRANSACTIONS_TO_ACCOUNTS AS TRANSACTIONS(ACCOUNT_KEY) REFERENCES ACCOUNTS(ACCOUNT_KEY),
        TRANSACTIONS_TO_DEPARTMENTS AS TRANSACTIONS(DEPARTMENT_KEY) REFERENCES DEPARTMENTS(DEPARTMENT_KEY),
        TRANSACTIONS_TO_CONTRACTORS AS TRANSACTIONS(CONTRACTOR_KEY) REFERENCES CONTRACTORS(CONTRACTOR_KEY),
        TRANSACTIONS_TO_SERVICES AS TRANSACTIONS(SERVICE_KEY) REFERENCES SERVICES(SERVICE_KEY),
        TRANSACTIONS_TO_CITIZENS AS TRANSACTIONS(CITIZEN_KEY) REFERENCES CITIZENS(CITIZEN_KEY)
    )
    FACTS (
        TRANSACTIONS.AMOUNT AS amount COMMENT='Transaction amount in dollars',
        TRANSACTIONS.TRANSACTION_RECORD AS 1 COMMENT='Count of transactions'
    )
    DIMENSIONS (
        TRANSACTIONS.DATE AS date WITH SYNONYMS=('date','transaction date','budget date') COMMENT='Date of the budget transaction',
        TRANSACTIONS.TRANSACTION_MONTH AS MONTH(TRANSACTIONS.DATE) COMMENT='Month of the transaction',
        TRANSACTIONS.TRANSACTION_YEAR AS YEAR(TRANSACTIONS.DATE) COMMENT='Year of the transaction',
        ACCOUNTS.ACCOUNT_NAME AS account_name WITH SYNONYMS=('account','account type','budget account') COMMENT='Name of the account',
        ACCOUNTS.ACCOUNT_TYPE AS account_type WITH SYNONYMS=('type','category','account category') COMMENT='Type of account (Income/Expense)',
        DEPARTMENTS.DEPARTMENT_NAME AS department_name WITH SYNONYMS=('department','business unit','city department') COMMENT='Name of the department',
        CONTRACTORS.CONTRACTOR_NAME AS contractor_name WITH SYNONYMS=('contractor','vendor','supplier') COMMENT='Name of the contractor',
        SERVICES.SERVICE_NAME AS service_name WITH SYNONYMS=('service','municipal service','city service') COMMENT='Name of the service',
        CITIZENS.CITIZEN_NAME AS citizen_name WITH SYNONYMS=('citizen','resident','constituent') COMMENT='Name of the citizen'
    )
    METRICS (
        TRANSACTIONS.AVERAGE_AMOUNT AS AVG(TRANSACTIONS.AMOUNT) COMMENT='Average transaction amount',
        TRANSACTIONS.TOTAL_AMOUNT AS SUM(TRANSACTIONS.AMOUNT) COMMENT='Total transaction amount',
        TRANSACTIONS.TOTAL_TRANSACTIONS AS COUNT(TRANSACTIONS.TRANSACTION_RECORD) COMMENT='Total number of transactions'
    )
    COMMENT='Semantic view for budget and financial analysis and reporting';

-- ========================================================================
-- CITIZEN SERVICES SEMANTIC VIEW
-- ========================================================================

CREATE OR REPLACE SEMANTIC VIEW SPRINGFIELD_GOV.DEMO.CITIZEN_SERVICES_SEMANTIC_VIEW
    TABLES (
        CITIZENS AS CITIZEN_DIM PRIMARY KEY (CITIZEN_KEY) WITH SYNONYMS=('citizens','residents','constituents','accounts') COMMENT='Citizen information for service analysis',
        SERVICES AS SERVICE_DIM PRIMARY KEY (SERVICE_KEY) WITH SYNONYMS=('services','municipal services','city services','programs') COMMENT='Service catalog for service analysis',
        SERVICE_CATEGORY_DIM PRIMARY KEY (CATEGORY_KEY),
        DISTRICTS AS DISTRICT_DIM PRIMARY KEY (DISTRICT_KEY) WITH SYNONYMS=('districts','wards','areas','neighborhoods') COMMENT='District information for service analysis',
        SERVICE_DELIVERY AS SERVICE_DELIVERY_FACT PRIMARY KEY (SERVICE_ID) WITH SYNONYMS=('service transactions','service delivery','service data') COMMENT='All service delivery transactions',
        EMPLOYEES AS CITY_EMPLOYEE_DIM PRIMARY KEY (EMPLOYEE_KEY) WITH SYNONYMS=('employees','city employees','staff','workers') COMMENT='City employee information',
        CONTRACTORS AS CONTRACTOR_DIM PRIMARY KEY (CONTRACTOR_KEY) WITH SYNONYMS=('contractors','vendors','suppliers') COMMENT='Contractor information for service delivery'
    )
    RELATIONSHIPS (
        SERVICE_TO_CATEGORY AS SERVICES(CATEGORY_KEY) REFERENCES SERVICE_CATEGORY_DIM(CATEGORY_KEY),
        SERVICE_DELIVERY_TO_CITIZENS AS SERVICE_DELIVERY(CITIZEN_KEY) REFERENCES CITIZENS(CITIZEN_KEY),
        SERVICE_DELIVERY_TO_SERVICES AS SERVICE_DELIVERY(SERVICE_KEY) REFERENCES SERVICES(SERVICE_KEY),
        SERVICE_DELIVERY_TO_DISTRICTS AS SERVICE_DELIVERY(DISTRICT_KEY) REFERENCES DISTRICTS(DISTRICT_KEY),
        SERVICE_DELIVERY_TO_EMPLOYEES AS SERVICE_DELIVERY(EMPLOYEE_KEY) REFERENCES EMPLOYEES(EMPLOYEE_KEY),
        SERVICE_DELIVERY_TO_CONTRACTORS AS SERVICE_DELIVERY(CONTRACTOR_KEY) REFERENCES CONTRACTORS(CONTRACTOR_KEY)
    )
    FACTS (
        SERVICE_DELIVERY.AMOUNT AS amount COMMENT='Service amount in dollars',
        SERVICE_DELIVERY.SERVICE_RECORD AS 1 COMMENT='Count of service transactions',
        SERVICE_DELIVERY.UNITS AS units COMMENT='Number of service units delivered'
    )
    DIMENSIONS (
        CITIZENS.ENTITY_TYPE AS ENTITY_TYPE WITH SYNONYMS=('entity type','citizen type','resident type') COMMENT='Type of citizen entity',
        CITIZENS.CITIZEN_NAME AS citizen_name WITH SYNONYMS=('citizen','resident','constituent','account') COMMENT='Name of the citizen',
        SERVICES.SERVICE_NAME AS service_name WITH SYNONYMS=('service','municipal service','city service') COMMENT='Name of the service',
        SERVICES.VERTICAL AS SERVICE_VERTICAL WITH SYNONYMS=('service vertical','service area') COMMENT='Service area from service dimension',
        SERVICE_CATEGORY_DIM.CATEGORY_NAME AS CATEGORY_NAME WITH SYNONYMS=('category_title','service_group','classification_name','category_label','service_category_description') COMMENT='The category to which a service belongs, such as public safety, infrastructure, or community services.',
        DISTRICTS.DISTRICT_NAME AS district_name WITH SYNONYMS=('district','ward','area','neighborhood') COMMENT='Name of the district',
        SERVICE_DELIVERY.DATE AS date WITH SYNONYMS=('date','service date','transaction date') COMMENT='Date of the service delivery',
        SERVICE_DELIVERY.SERVICE_MONTH AS MONTH(SERVICE_DELIVERY.DATE) COMMENT='Month of the service',
        SERVICE_DELIVERY.SERVICE_YEAR AS YEAR(SERVICE_DELIVERY.DATE) COMMENT='Year of the service',
        EMPLOYEES.EMPLOYEE_NAME AS EMPLOYEE_NAME WITH SYNONYMS=('employee','city employee','staff member','worker') COMMENT='Name of the city employee',
        CONTRACTORS.CONTRACTOR_NAME AS contractor_name WITH SYNONYMS=('contractor','vendor','supplier','provider') COMMENT='Name of the contractor'
    )
    METRICS (
        SERVICE_DELIVERY.AVERAGE_SERVICE_AMOUNT AS AVG(SERVICE_DELIVERY.AMOUNT) COMMENT='Average service amount',
        SERVICE_DELIVERY.AVERAGE_UNITS_PER_SERVICE AS AVG(SERVICE_DELIVERY.UNITS) COMMENT='Average units per service',
        SERVICE_DELIVERY.TOTAL_SERVICES AS COUNT(SERVICE_DELIVERY.SERVICE_RECORD) COMMENT='Total number of services delivered',
        SERVICE_DELIVERY.TOTAL_SERVICE_AMOUNT AS SUM(SERVICE_DELIVERY.AMOUNT) COMMENT='Total service amount',
        SERVICE_DELIVERY.TOTAL_UNITS AS SUM(SERVICE_DELIVERY.UNITS) COMMENT='Total service units delivered',
        SERVICE_DELIVERY.COMPLETED_SERVICES AS COUNT(SERVICE_DELIVERY.SERVICE_RECORD) COMMENT='All services are considered completed when recorded'
    )
    COMMENT='Semantic view for citizen services analysis and performance tracking';

-- ========================================================================
-- PUBLIC COMMUNICATIONS SEMANTIC VIEW
-- ========================================================================

CREATE OR REPLACE SEMANTIC VIEW SPRINGFIELD_GOV.DEMO.PUBLIC_COMMUNICATIONS_SEMANTIC_VIEW
    TABLES (
        ACCOUNTS AS GOVERNMENT_ACCOUNTS PRIMARY KEY (ACCOUNT_ID) WITH SYNONYMS=('citizens','accounts','constituents') COMMENT='Citizen account information for communication analysis',
        COMMUNICATIONS AS PUBLIC_COMMUNICATION_FACT PRIMARY KEY (COMMUNICATION_FACT_ID) WITH SYNONYMS=('public communications','communication campaigns','outreach') COMMENT='Public communication campaign data',
        COMMUNICATION_DETAILS AS PUBLIC_COMMUNICATION_DIM PRIMARY KEY (COMMUNICATION_KEY) WITH SYNONYMS=('communication info','communication details') COMMENT='Communication dimension with objectives and names',
        CHANNELS AS COMMUNICATION_CHANNEL_DIM PRIMARY KEY (CHANNEL_KEY) WITH SYNONYMS=('communication channels','channels','media') COMMENT='Communication channel information',
        CONTACTS AS GOVERNMENT_CONTACTS PRIMARY KEY (CONTACT_ID) WITH SYNONYMS=('contacts','participants','attendees') COMMENT='Contact records generated from communications',
        SERVICE_REQUESTS AS GOVERNMENT_SERVICE_REQUESTS PRIMARY KEY (SERVICE_REQUEST_ID) WITH SYNONYMS=('service requests','requests','cases') COMMENT='Service request records',
        SERVICES AS SERVICE_DIM PRIMARY KEY (SERVICE_KEY) WITH SYNONYMS=('services','municipal services','programs') COMMENT='Service dimension for communication analysis',
        DISTRICTS AS DISTRICT_DIM PRIMARY KEY (DISTRICT_KEY) WITH SYNONYMS=('districts','wards','areas','neighborhoods') COMMENT='District information for communication analysis'
    )
    RELATIONSHIPS (
        COMMUNICATIONS_TO_CHANNELS AS COMMUNICATIONS(CHANNEL_KEY) REFERENCES CHANNELS(CHANNEL_KEY),
        COMMUNICATIONS_TO_DETAILS AS COMMUNICATIONS(COMMUNICATION_KEY) REFERENCES COMMUNICATION_DETAILS(COMMUNICATION_KEY),
        COMMUNICATIONS_TO_SERVICES AS COMMUNICATIONS(SERVICE_KEY) REFERENCES SERVICES(SERVICE_KEY),
        COMMUNICATIONS_TO_DISTRICTS AS COMMUNICATIONS(DISTRICT_KEY) REFERENCES DISTRICTS(DISTRICT_KEY),
        CONTACTS_TO_ACCOUNTS AS CONTACTS(ACCOUNT_ID) REFERENCES ACCOUNTS(ACCOUNT_ID),
        CONTACTS_TO_COMMUNICATIONS AS CONTACTS(COMMUNICATION_NO) REFERENCES COMMUNICATIONS(COMMUNICATION_FACT_ID),
        SERVICE_REQUESTS_TO_ACCOUNTS AS SERVICE_REQUESTS(ACCOUNT_ID) REFERENCES ACCOUNTS(ACCOUNT_ID),
        SERVICE_REQUESTS_TO_COMMUNICATIONS AS SERVICE_REQUESTS(COMMUNICATION_ID) REFERENCES COMMUNICATIONS(COMMUNICATION_FACT_ID)
    )
    FACTS (
        COMMUNICATIONS.COMMUNICATION_RECORD AS 1 COMMENT='Count of communication activities',
        COMMUNICATIONS.SPEND AS spend COMMENT='Communication spend in dollars',
        COMMUNICATIONS.IMPRESSIONS AS impressions COMMENT='Number of impressions',
        COMMUNICATIONS.PARTICIPANTS_GENERATED AS participants_generated COMMENT='Number of participants generated',
        CONTACTS.CONTACT_RECORD AS 1 COMMENT='Count of contacts generated',
        SERVICE_REQUESTS.SERVICE_REQUEST_RECORD AS 1 COMMENT='Count of service requests created',
        SERVICE_REQUESTS.SERVICE_REQUEST_AMOUNT AS amount COMMENT='Service request amount in dollars'
    )
    DIMENSIONS (
        ACCOUNTS.ACCOUNT_NAME AS ACCOUNT_NAME WITH SYNONYMS=('citizen name','resident name','constituent name','company') COMMENT='Name of the citizen account',
        ACCOUNTS.ACCOUNT_TYPE AS ACCOUNT_TYPE WITH SYNONYMS=('citizen type','account category','entity type') COMMENT='Type of citizen account',
        ACCOUNTS.ENTITY_TYPE AS ENTITY_TYPE WITH SYNONYMS=('entity type','citizen type') COMMENT='Type of citizen entity',
        COMMUNICATIONS.DATE AS date WITH SYNONYMS=('date','communication date') COMMENT='Date of the communication activity',
        COMMUNICATIONS.COMMUNICATION_MONTH AS MONTH(COMMUNICATIONS.DATE) COMMENT='Month of the communication',
        COMMUNICATIONS.COMMUNICATION_YEAR AS YEAR(COMMUNICATIONS.DATE) COMMENT='Year of the communication',
        COMMUNICATION_DETAILS.COMMUNICATION_NAME AS COMMUNICATION_NAME WITH SYNONYMS=('communication','communication title') COMMENT='Name of the public communication',
        COMMUNICATION_DETAILS.COMMUNICATION_OBJECTIVE AS OBJECTIVE WITH SYNONYMS=('objective','goal','purpose') COMMENT='Communication objective',
        CHANNELS.CHANNEL_NAME AS CHANNEL_NAME WITH SYNONYMS=('channel','communication channel','media') COMMENT='Name of the communication channel',
        CONTACTS.DEPARTMENT AS DEPARTMENT WITH SYNONYMS=('department','business unit') COMMENT='Contact department',
        CONTACTS.EMAIL AS EMAIL WITH SYNONYMS=('email','email address') COMMENT='Contact email address',
        CONTACTS.FIRST_NAME AS FIRST_NAME WITH SYNONYMS=('first name','contact name') COMMENT='Contact first name',
        CONTACTS.LAST_NAME AS LAST_NAME WITH SYNONYMS=('last name','surname') COMMENT='Contact last name',
        CONTACTS.REQUEST_SOURCE AS REQUEST_SOURCE WITH SYNONYMS=('request source','source') COMMENT='How the contact was generated',
        CONTACTS.TITLE AS TITLE WITH SYNONYMS=('job title','position') COMMENT='Contact job title',
        SERVICE_REQUESTS.CLOSE_DATE AS CLOSE_DATE WITH SYNONYMS=('close date','completion date') COMMENT='Expected or actual close date',
        SERVICE_REQUESTS.SERVICE_REQUEST_SOURCE AS request_source WITH SYNONYMS=('service request source','request source') COMMENT='Source of the service request',
        SERVICE_REQUESTS.SERVICE_REQUEST_NAME AS SERVICE_REQUEST_NAME WITH SYNONYMS=('request name','service request title') COMMENT='Name of the service request',
        SERVICE_REQUESTS.SERVICE_REQUEST_STATUS AS status WITH SYNONYMS=('status','request status','completion status') COMMENT='Status of the service request',
        SERVICE_REQUESTS.SERVICE_REQUEST_TYPE AS type WITH SYNONYMS=('request type','service request type') COMMENT='Type of service request',
        SERVICES.SERVICE_NAME AS SERVICE_NAME WITH SYNONYMS=('service','municipal service','service title') COMMENT='Name of the service being promoted',
        DISTRICTS.DISTRICT_NAME AS DISTRICT_NAME WITH SYNONYMS=('district','ward','area','neighborhood') COMMENT='Name of the district'
    )
    METRICS (
        COMMUNICATIONS.AVERAGE_SPEND AS AVG(COMMUNICATIONS.SPEND) COMMENT='Average communication spend',
        COMMUNICATIONS.TOTAL_COMMUNICATIONS AS COUNT(COMMUNICATIONS.COMMUNICATION_RECORD) COMMENT='Total number of communication activities',
        COMMUNICATIONS.TOTAL_IMPRESSIONS AS SUM(COMMUNICATIONS.IMPRESSIONS) COMMENT='Total impressions across communications',
        COMMUNICATIONS.TOTAL_PARTICIPANTS AS SUM(COMMUNICATIONS.PARTICIPANTS_GENERATED) COMMENT='Total participants generated from communications',
        COMMUNICATIONS.TOTAL_SPEND AS SUM(COMMUNICATIONS.SPEND) COMMENT='Total communication spend',
        CONTACTS.TOTAL_CONTACTS AS COUNT(CONTACTS.CONTACT_RECORD) COMMENT='Total contacts generated from communications',
        SERVICE_REQUESTS.AVERAGE_REQUEST_AMOUNT AS AVG(SERVICE_REQUESTS.SERVICE_REQUEST_AMOUNT) COMMENT='Average service request amount',
        SERVICE_REQUESTS.COMPLETED_REQUESTS AS SUM(CASE WHEN SERVICE_REQUESTS.SERVICE_REQUEST_STATUS = 'Completed' THEN SERVICE_REQUESTS.SERVICE_REQUEST_RECORD ELSE 0 END) COMMENT='Completed service requests',
        SERVICE_REQUESTS.TOTAL_REQUESTS AS COUNT(SERVICE_REQUESTS.SERVICE_REQUEST_RECORD) COMMENT='Total service requests from communications',
        SERVICE_REQUESTS.TOTAL_REQUEST_AMOUNT AS SUM(SERVICE_REQUESTS.SERVICE_REQUEST_AMOUNT) COMMENT='Total amount from service requests'
    )
    COMMENT='Enhanced semantic view for public communications analysis with complete service request attribution and ROI tracking';

-- ========================================================================
-- HUMAN RESOURCES SEMANTIC VIEW
-- ========================================================================

CREATE OR REPLACE SEMANTIC VIEW SPRINGFIELD_GOV.DEMO.HUMAN_RESOURCES_SEMANTIC_VIEW
    TABLES (
        DEPARTMENTS AS DEPARTMENT_DIM PRIMARY KEY (DEPARTMENT_KEY) WITH SYNONYMS=('departments','business units','city departments') COMMENT='Department dimension for organizational analysis',
        EMPLOYEES AS CITY_EMPLOYEE_DIM PRIMARY KEY (EMPLOYEE_KEY) WITH SYNONYMS=('employees','city employees','staff','workforce') COMMENT='Employee dimension with personal information',
        HR_RECORDS AS CITY_EMPLOYEE_FACT PRIMARY KEY (HR_FACT_ID) WITH SYNONYMS=('hr data','employee records','personnel data') COMMENT='HR employee fact data for workforce analysis',
        JOBS AS GOVERNMENT_JOB_DIM PRIMARY KEY (JOB_KEY) WITH SYNONYMS=('job titles','positions','roles','civil service') COMMENT='Job dimension with titles and levels',
        LOCATIONS AS GOVERNMENT_LOCATION_DIM PRIMARY KEY (LOCATION_KEY) WITH SYNONYMS=('locations','offices','sites','facilities') COMMENT='Location dimension for geographic analysis'
    )
    RELATIONSHIPS (
        HR_TO_DEPARTMENTS AS HR_RECORDS(DEPARTMENT_KEY) REFERENCES DEPARTMENTS(DEPARTMENT_KEY),
        HR_TO_EMPLOYEES AS HR_RECORDS(EMPLOYEE_KEY) REFERENCES EMPLOYEES(EMPLOYEE_KEY),
        HR_TO_JOBS AS HR_RECORDS(JOB_KEY) REFERENCES JOBS(JOB_KEY),
        HR_TO_LOCATIONS AS HR_RECORDS(LOCATION_KEY) REFERENCES LOCATIONS(LOCATION_KEY)
    )
    FACTS (
        HR_RECORDS.ATTRITION_FLAG AS attrition_flag WITH SYNONYMS=('turnover_indicator','employee_departure_flag','separation_flag','employee_retention_status','churn_status','employee_exit_indicator') COMMENT='Attrition flag. value is 0 if employee is currently active. 1 if employee quit & left the company. Always filter by 0 to show active employees unless specified otherwise',
        HR_RECORDS.EMPLOYEE_RECORD AS 1 COMMENT='Count of employee records',
        HR_RECORDS.SALARY AS salary COMMENT='Employee salary in dollars'
    )
    DIMENSIONS (
        DEPARTMENTS.DEPARTMENT_KEY AS DEPARTMENT_KEY,
        DEPARTMENTS.DEPARTMENT_NAME AS department_name WITH SYNONYMS=('department','business unit','division','city department') COMMENT='Name of the department',
        EMPLOYEES.EMPLOYEE_KEY AS EMPLOYEE_KEY,
        EMPLOYEES.EMPLOYEE_NAME AS employee_name WITH SYNONYMS=('employee','city employee','staff member','person','worker','civil servant') COMMENT='Name of the employee',
        EMPLOYEES.GENDER AS gender WITH SYNONYMS=('gender','sex') COMMENT='Employee gender',
        EMPLOYEES.HIRE_DATE AS hire_date WITH SYNONYMS=('hire date','start date','employment date') COMMENT='Date when employee was hired',
        HR_RECORDS.DEPARTMENT_KEY AS DEPARTMENT_KEY,
        HR_RECORDS.EMPLOYEE_KEY AS EMPLOYEE_KEY,
        HR_RECORDS.HR_FACT_ID AS HR_FACT_ID,
        HR_RECORDS.JOB_KEY AS JOB_KEY,
        HR_RECORDS.LOCATION_KEY AS LOCATION_KEY,
        HR_RECORDS.DATE AS date WITH SYNONYMS=('date','record date','employment date') COMMENT='Date of the HR record',
        HR_RECORDS.RECORD_MONTH AS MONTH(HR_RECORDS.DATE) COMMENT='Month of the HR record',
        HR_RECORDS.RECORD_YEAR AS YEAR(HR_RECORDS.DATE) COMMENT='Year of the HR record',
        JOBS.JOB_KEY AS JOB_KEY,
        JOBS.JOB_LEVEL AS job_level WITH SYNONYMS=('level','grade','seniority','civil service level') COMMENT='Job level or grade',
        JOBS.JOB_TITLE AS job_title WITH SYNONYMS=('job title','position','role','civil service title') COMMENT='Employee job title',
        LOCATIONS.LOCATION_KEY AS LOCATION_KEY,
        LOCATIONS.LOCATION_NAME AS location_name WITH SYNONYMS=('location','office','site','facility') COMMENT='Work location'
    )
    METRICS (
        HR_RECORDS.ATTRITION_COUNT AS SUM(HR_RECORDS.ATTRITION_FLAG) COMMENT='Number of employees who left',
        HR_RECORDS.AVG_SALARY AS AVG(HR_RECORDS.SALARY) COMMENT='average employee salary',
        HR_RECORDS.TOTAL_EMPLOYEES AS COUNT(HR_RECORDS.EMPLOYEE_RECORD) COMMENT='Total number of employees',
        HR_RECORDS.TOTAL_SALARY_COST AS SUM(HR_RECORDS.SALARY) COMMENT='Total salary cost'
    )
    COMMENT='Semantic view for HR analytics and workforce management';

-- ========================================================================
-- VERIFICATION
-- ========================================================================

-- Show all semantic views
SHOW SEMANTIC VIEWS;

-- Show dimensions for each semantic view
SHOW SEMANTIC DIMENSIONS;

-- Show metrics for each semantic view
SHOW SEMANTIC METRICS;
