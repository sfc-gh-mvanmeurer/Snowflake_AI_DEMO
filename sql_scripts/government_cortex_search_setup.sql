-- ========================================================================
-- Snowflake AI Demo - Government Cortex Search Setup
-- Creates Cortex Search services for unstructured government documents
-- ========================================================================

USE ROLE SF_Intelligence_Demo;
USE DATABASE SPRINGFIELD_GOV;
USE SCHEMA DEMO;
USE WAREHOUSE SNOW_INTELLIGENCE_DEMO_WH;

-- ========================================================================
-- CREATE DOCUMENT TABLES FOR CORTEX SEARCH
-- ========================================================================

-- Create table for document metadata
CREATE OR REPLACE TABLE DOCUMENT_METADATA (
    DOCUMENT_ID STRING,
    DOCUMENT_NAME STRING,
    DOCUMENT_TYPE STRING,
    DEPARTMENT STRING,
    FILE_PATH STRING,
    UPLOAD_DATE TIMESTAMP,
    FILE_SIZE NUMBER,
    TITLE STRING,
    DESCRIPTION STRING
);

-- Create table for document content
CREATE OR REPLACE TABLE DOCUMENT_CONTENT (
    DOCUMENT_ID STRING,
    CONTENT STRING,
    METADATA VARIANT
);

-- ========================================================================
-- LOAD DOCUMENTS FROM GIT REPOSITORY
-- ========================================================================

-- Load document metadata
INSERT INTO DOCUMENT_METADATA VALUES
('DOC001', 'Annual_Budget_2025.md', 'Budget Document', 'Budget & Finance', 'unstructured_docs/budget_finance/Annual_Budget_2025.md', CURRENT_TIMESTAMP(), 15000, 'Springfield City Government Annual Budget 2025', 'Comprehensive annual budget document with revenue projections and department allocations'),
('DOC002', 'Q4_2024_Financial_Report.md', 'Financial Report', 'Budget & Finance', 'unstructured_docs/budget_finance/Q4_2024_Financial_Report.md', CURRENT_TIMESTAMP(), 12000, 'Q4 2024 Financial Report', 'Quarterly financial performance report with detailed analysis'),
('DOC003', 'Procurement_Policy_2025.md', 'Policy Document', 'Budget & Finance', 'unstructured_docs/budget_finance/Procurement_Policy_2025.md', CURRENT_TIMESTAMP(), 18000, 'Procurement Policy 2025', 'Government procurement guidelines and vendor management procedures'),
('DOC004', 'Service_Delivery_Procedures.md', 'Procedure Document', 'Citizen Services', 'unstructured_docs/citizen_services/Service_Delivery_Procedures.md', CURRENT_TIMESTAMP(), 20000, 'Service Delivery Procedures', 'Standardized procedures for municipal service delivery'),
('DOC005', 'Citizen_Success_Stories.md', 'Success Stories', 'Citizen Services', 'unstructured_docs/citizen_services/Citizen_Success_Stories.md', CURRENT_TIMESTAMP(), 25000, 'Citizen Success Stories', 'Detailed success stories across all service areas'),
('DOC006', 'Public_Communication_Strategy_2025.md', 'Strategy Document', 'Public Communications', 'unstructured_docs/public_communications/Public_Communication_Strategy_2025.md', CURRENT_TIMESTAMP(), 22000, 'Public Communication Strategy 2025', 'Comprehensive communication strategy and engagement plan'),
('DOC007', 'Employee_Handbook_2025.md', 'Handbook', 'Human Resources', 'unstructured_docs/human_resources/Employee_Handbook_2025.md', CURRENT_TIMESTAMP(), 30000, 'Employee Handbook 2025', 'Comprehensive employee policies and procedures'),
('DOC008', 'Strategic_Plan_2025-2030.md', 'Strategic Plan', 'Government Operations', 'unstructured_docs/government_operations/Strategic_Plan_2025-2030.md', CURRENT_TIMESTAMP(), 35000, 'Strategic Plan 2025-2030', 'Five-year strategic plan for city development');

-- Load actual document content from unstructured_docs folder
INSERT INTO DOCUMENT_CONTENT 
SELECT 'DOC001', '# Annual Budget 2025 - Springfield City Government

**Document Version**: 2.1  
**Effective Date**: January 1, 2025  
**Approved By**: Springfield City Council  
**Budget Director**: Sarah Johnson  
**Last Updated**: December 15, 2024

## Executive Summary

The Springfield City Government presents its comprehensive budget for fiscal year 2025, totaling **$127.8 million** in operating expenditures and **$45.2 million** in capital investments. This represents a 4.2% increase over the 2024 budget, driven primarily by infrastructure improvements, public safety enhancements, and employee compensation adjustments.

### Key Budget Highlights
- **Total Operating Budget**: $127.8M (+4.2% YoY)
- **Capital Improvement Program**: $45.2M (+8.1% YoY)
- **Property Tax Revenue**: $89.4M (+3.8% YoY)
- **Sales Tax Revenue**: $23.7M (+2.1% YoY)
- **Federal/State Grants**: $14.7M (+12.3% YoY)

## Revenue Projections

### Primary Revenue Sources
| Revenue Source | 2024 Actual | 2025 Budget | Change | % of Total |
|----------------|-------------|-------------|---------|------------|
| Property Taxes | $86.2M | $89.4M | +$3.2M | 69.8% |
| Sales Taxes | $23.2M | $23.7M | +$0.5M | 18.5% |
| Federal Grants | $8.9M | $10.1M | +$1.2M | 7.9% |
| State Grants | $3.8M | $4.6M | +$0.8M | 3.6% |
| Fees & Permits | $5.2M | $5.4M | +$0.2M | 4.2% |
| Other Revenue | $2.1M | $2.2M | +$0.1M | 1.7% |
| **TOTAL** | **$129.4M** | **$135.4M** | **+$6.0M** | **100%** |

### Revenue Assumptions
- **Property Tax Growth**: 3.8% increase based on assessed value growth
- **Sales Tax Stability**: 2.1% growth reflecting economic recovery
- **Grant Funding**: 12.3% increase due to infrastructure and public safety grants
- **Fee Revenue**: 3.8% increase from permit and service fee adjustments

## Department Budget Allocations

### Major Department Expenditures
| Department | 2024 Budget | 2025 Budget | Change | % of Total |
|------------|-------------|-------------|---------|------------|
| Public Safety | $42.8M | $45.2M | +$2.4M | 35.4% |
| Public Works | $28.6M | $30.1M | +$1.5M | 23.6% |
| Community Services | $18.9M | $19.8M | +$0.9M | 15.5% |
| Finance & Administration | $12.4M | $13.1M | +$0.7M | 10.3% |
| Planning & Development | $8.7M | $9.2M | +$0.5M | 7.2% |
| Human Resources | $6.2M | $6.8M | +$0.6M | 5.3% |
| Information Technology | $4.8M | $5.2M | +$0.4M | 4.1% |

[Additional budget details continue with department breakdowns, capital projects, and financial policies...]', PARSE_JSON('{"department": "Budget & Finance", "type": "budget", "year": 2025}');
INSERT INTO DOCUMENT_CONTENT 
SELECT 'DOC002', '# Q4 2024 Financial Report - Springfield City Government

**Report Period**: October 1 - December 31, 2024  
**Prepared By**: Michael Davis, Finance Director  
**Report Date**: January 15, 2025  
**Status**: Final

## Executive Summary

Springfield City Government concluded 2024 with strong financial performance, exceeding revenue projections by 2.3% while maintaining expenditure controls within budget parameters. The fourth quarter demonstrated continued economic stability and effective fiscal management across all departments.

### Key Financial Highlights
- **Total Revenue**: $33.2M (Q4) vs $32.1M budget (+3.4%)
- **Total Expenditures**: $31.8M (Q4) vs $32.0M budget (-0.6%)
- **Net Position**: +$1.4M favorable variance
- **Year-to-Date Revenue**: $128.7M vs $126.4M budget (+1.8%)
- **Year-to-Date Expenditures**: $125.9M vs $127.2M budget (-1.0%)

## Revenue Analysis

### Q4 2024 Revenue Performance
| Revenue Source | Budget | Actual | Variance | % of Total |
|----------------|--------|--------|----------|------------|
| Property Taxes | $22.4M | $22.8M | +$0.4M | 68.7% |
| Sales Taxes | $5.8M | $6.1M | +$0.3M | 18.4% |
| Federal Grants | $2.2M | $2.4M | +$0.2M | 7.2% |
| State Grants | $1.0M | $1.1M | +$0.1M | 3.3% |
| Fees & Permits | $1.3M | $1.4M | +$0.1M | 4.2% |
| Other Revenue | $0.4M | $0.4M | $0.0M | 1.2% |
| **TOTAL** | **$33.1M** | **$33.8M** | **+$0.7M** | **100%** |

[Additional financial analysis continues with expenditure breakdowns, department performance, and year-end summaries...]', PARSE_JSON('{"department": "Budget & Finance", "type": "financial_report", "quarter": "Q4", "year": 2024}');
INSERT INTO DOCUMENT_CONTENT 
SELECT 'DOC003', '# Procurement Policy 2025 - Springfield City Government

**Document Version**: 3.2  
**Effective Date**: January 1, 2025  
**Approved By**: Springfield City Council  
**Procurement Director**: David Martinez  
**Last Updated**: December 10, 2024

## Purpose and Scope

This procurement policy establishes comprehensive guidelines for the acquisition of goods, services, and construction by Springfield City Government. The policy ensures fair, transparent, and cost-effective procurement processes while maintaining compliance with state and federal regulations.

### Applicability
This policy applies to all city departments, divisions, and employees involved in procurement activities. It covers all purchases regardless of funding source, including general fund, grants, and special revenue funds.

## Procurement Authority

### Delegated Authority
| Purchase Amount | Approval Authority | Documentation Required |
|-----------------|-------------------|----------------------|
| $0 - $2,500 | Department Head | Purchase Order |
| $2,501 - $10,000 | Department Head + Finance | 3 Quotes |
| $10,001 - $25,000 | Finance Director | 3 Written Quotes |
| $25,001 - $50,000 | City Manager | Formal Bid Process |
| $50,001 - $100,000 | City Council | Formal Bid + Council Approval |
| Over $100,000 | City Council | Formal Bid + Public Hearing |

### Emergency Procurement
- **Emergency Threshold**: Up to $25,000 for emergency situations
- **Approval Required**: City Manager or designee

[Additional procurement guidelines continue with bid processes, vendor management, and compliance requirements...]', PARSE_JSON('{"department": "Budget & Finance", "type": "policy", "year": 2025}');
INSERT INTO DOCUMENT_CONTENT 
SELECT 'DOC004', '# Service Delivery Procedures - Springfield City Government

**Document Version**: 2.4  
**Effective Date**: January 1, 2025  
**Approved By**: Springfield City Manager  
**Service Delivery Director**: Lisa Anderson  
**Last Updated**: December 20, 2024

## Purpose and Scope

This document establishes standardized procedures for the delivery of municipal services to Springfield citizens. These procedures ensure consistent, efficient, and high-quality service delivery across all city departments while maintaining accountability and transparency.

### Service Delivery Principles
- **Citizen-First Approach**: Services designed around citizen needs and preferences
- **Accessibility**: Services available through multiple channels and formats
- **Efficiency**: Streamlined processes and reduced wait times
- **Quality**: Consistent service standards and continuous improvement
- **Transparency**: Clear communication and regular feedback

## Service Delivery Framework

### Service Categories
| Category | Services | Department | Response Time |
|----------|----------|------------|--------------|
| **Public Safety** | Police, Fire, Emergency | Public Safety | <5 minutes |
| **Infrastructure** | Streets, Water, Sewer | Public Works | <24 hours |
| **Community** | Parks, Recreation, Library | Community Services | <48 hours |
| **Development** | Permits, Planning, Zoning | Planning & Development | <72 hours |
| **Administrative** | Records, Licenses, Payments | Finance | <24 hours |

[Additional service delivery procedures continue with detailed processes, quality standards, and performance metrics...]', PARSE_JSON('{"department": "Citizen Services", "type": "procedures", "year": 2025}');

INSERT INTO DOCUMENT_CONTENT 
SELECT 'DOC005', '# Citizen Success Stories - Springfield City Government

**Document Version**: 1.3  
**Publication Date**: January 15, 2025  
**Community Relations Director**: Amanda Thomas  
**Last Updated**: January 10, 2025

## Introduction

This document highlights successful service delivery stories from Springfield City Government, demonstrating our commitment to citizen satisfaction and community improvement. These stories showcase the positive impact of municipal services on citizens lives and the community as a whole.

### Success Story Categories
- **Emergency Response**: Life-saving interventions and crisis management
- **Infrastructure Improvements**: Community development and public works
- **Community Services**: Recreation, education, and social services
- **Economic Development**: Business support and job creation
- **Public Safety**: Crime prevention and community safety
- **Environmental**: Sustainability and environmental protection

## Emergency Response Success Stories

### Story 1: Fire Department Saves Historic Downtown Building
**Date**: March 15, 2024  
**Location**: 123 Main Street, Downtown Springfield  
**Response Team**: Fire Station 1, Engine 1, Ladder 1, Battalion Chief David Martinez

#### Situation
At 2:47 AM, Springfield Fire Department received a 911 call reporting smoke and flames visible from the historic Springfield Mercantile Building, a 120-year-old structure housing six businesses and 12 residential units.

#### Response
[Additional success stories continue with detailed accounts of emergency responses, infrastructure projects, and community service achievements...]', PARSE_JSON('{"department": "Citizen Services", "type": "success_stories", "year": 2025}');
INSERT INTO DOCUMENT_CONTENT 
SELECT 'DOC006', '# Public Communication Strategy 2025 - Springfield City Government

**Document Version**: 2.1  
**Effective Date**: January 1, 2025  
**Approved By**: Springfield City Council  
**Communication Director**: Sarah Wilson  
**Last Updated**: December 18, 2024

## Executive Summary

The Springfield City Government Public Communication Strategy 2025 establishes a comprehensive framework for engaging citizens, building community trust, and ensuring transparent government operations. This strategy emphasizes multi-channel communication, citizen engagement, and responsive public information services.

### Strategic Goals
- **Transparency**: Open and accessible government information
- **Engagement**: Active citizen participation in government processes
- **Trust**: Building and maintaining public trust in government
- **Accessibility**: Communication accessible to all community members
- **Effectiveness**: Clear, timely, and relevant information delivery

## Communication Framework

### Core Principles
1. **Citizen-First Communication**: Information designed for citizen needs and understanding
2. **Transparency**: Open access to government information and decision-making
3. **Accessibility**: Communication accessible to all community members
4. **Timeliness**: Rapid response to citizen inquiries and community issues
5. **Accuracy**: Factual, verified information in all communications
6. **Consistency**: Unified messaging across all communication channels

### Communication Objectives
[Additional communication strategy details continue with channel strategies, engagement tactics, and measurement frameworks...]', PARSE_JSON('{"department": "Public Communications", "type": "strategy", "year": 2025}');

INSERT INTO DOCUMENT_CONTENT 
SELECT 'DOC007', '# Employee Handbook 2025 - Springfield City Government

**Document Version**: 4.1  
**Effective Date**: January 1, 2025  
**Approved By**: Springfield City Council  
**HR Director**: Michael Davis  
**Last Updated**: December 12, 2024

## Welcome to Springfield City Government

Welcome to Springfield City Government! This Employee Handbook is designed to provide you with important information about our organization, policies, procedures, benefits, and expectations. Please read this handbook carefully and refer to it whenever you have questions about city policies.

### Our Mission Statement
"To serve the citizens of Springfield with excellence, integrity, and innovation while building a strong, safe, and prosperous community for all."

### City Values
- **Service Excellence**: We are committed to providing outstanding service to our citizens
- **Integrity**: We act with honesty, transparency, and ethical behavior in all our actions
- **Innovation**: We embrace new ideas and technologies to improve our community
- **Collaboration**: We work together as a team to achieve common goals
- **Respect**: We treat all people with dignity and respect
- **Accountability**: We take responsibility for our actions and decisions

## Employment Basics

### Equal Opportunity Employment
Springfield City Government is an equal opportunity employer committed to providing equal employment opportunities to all employees and applicants without regard to race, color, religion, sex, national origin, age, disability, veteran status, sexual orientation, gender identity, or any other protected characteristic.

### Civil Service System
Springfield operates under a civil service system that ensures fair and merit-based employment practices. All positions are filled based on qualifications, experience, and performance, with equal opportunity for advancement.

[Additional employee handbook content continues with compensation, benefits, workplace policies, and procedures...]', PARSE_JSON('{"department": "Human Resources", "type": "handbook", "year": 2025}');

INSERT INTO DOCUMENT_CONTENT 
SELECT 'DOC008', '# Strategic Plan 2025-2030 - Springfield City Government

**Document Version**: 1.0  
**Effective Date**: January 1, 2025  
**Approved By**: Springfield City Council  
**City Manager**: Jennifer Wilson  
**Last Updated**: December 30, 2024

## Executive Summary

The Springfield City Government Strategic Plan 2025-2030 establishes a comprehensive vision for the future of our community, focusing on sustainable growth, enhanced quality of life, and responsive government services. This five-year plan builds upon our current strengths while addressing emerging challenges and opportunities.

### Vision Statement
"Springfield will be a thriving, sustainable, and inclusive community where all residents have access to excellent services, economic opportunities, and a high quality of life."

### Mission Statement
"To serve the citizens of Springfield with excellence, integrity, and innovation while building a strong, safe, and prosperous community for all."

### Core Values
- **Service Excellence**: We are committed to providing outstanding service to our citizens
- **Integrity**: We act with honesty, transparency, and ethical behavior in all our actions
- **Innovation**: We embrace new ideas and technologies to improve our community
- **Collaboration**: We work together as a team to achieve common goals
- **Respect**: We treat all people with dignity and respect
- **Accountability**: We take responsibility for our actions and decisions

## Strategic Priorities

### Priority 1: Economic Development and Job Creation
#### Goals
[Additional strategic plan content continues with detailed priorities, action plans, and implementation strategies...]', PARSE_JSON('{"department": "Government Operations", "type": "strategic_plan", "years": "2025-2030"}');

-- ========================================================================
-- CREATE CORTEX SEARCH SERVICES
-- ========================================================================

-- Create search service for budget & finance documents
-- This enables semantic search over budget and finance-related content
CREATE OR REPLACE CORTEX SEARCH SERVICE SEARCH_BUDGET_FINANCE_DOCS
    ON content
    ATTRIBUTES relative_path, file_url, title
    WAREHOUSE = SNOW_INTELLIGENCE_DEMO_WH
    TARGET_LAG = '30 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            dm.FILE_PATH as relative_path,
            dm.FILE_PATH as file_url,
            dm.TITLE as title,
            dc.CONTENT as content
        FROM DOCUMENT_CONTENT dc
        JOIN DOCUMENT_METADATA dm ON dc.DOCUMENT_ID = dm.DOCUMENT_ID
        WHERE dm.DEPARTMENT = 'Budget & Finance'
    );

-- Create search service for HR documents
-- This enables semantic search over HR-related content
CREATE OR REPLACE CORTEX SEARCH SERVICE SEARCH_HR_DOCS
    ON content
    ATTRIBUTES relative_path, file_url, title
    WAREHOUSE = SNOW_INTELLIGENCE_DEMO_WH
    TARGET_LAG = '30 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            dm.FILE_PATH as relative_path,
            dm.FILE_PATH as file_url,
            dm.TITLE as title,
            dc.CONTENT as content
        FROM DOCUMENT_CONTENT dc
        JOIN DOCUMENT_METADATA dm ON dc.DOCUMENT_ID = dm.DOCUMENT_ID
        WHERE dm.DEPARTMENT = 'Human Resources'
    );

-- Create search service for citizen services documents
-- This enables semantic search over citizen services-related content
CREATE OR REPLACE CORTEX SEARCH SERVICE SEARCH_CITIZEN_SERVICES_DOCS
    ON content
    ATTRIBUTES relative_path, file_url, title
    WAREHOUSE = SNOW_INTELLIGENCE_DEMO_WH
    TARGET_LAG = '30 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            dm.FILE_PATH as relative_path,
            dm.FILE_PATH as file_url,
            dm.TITLE as title,
            dc.CONTENT as content
        FROM DOCUMENT_CONTENT dc
        JOIN DOCUMENT_METADATA dm ON dc.DOCUMENT_ID = dm.DOCUMENT_ID
        WHERE dm.DEPARTMENT = 'Citizen Services'
    );

-- Create search service for public communications documents
-- This enables semantic search over public communications-related content
CREATE OR REPLACE CORTEX SEARCH SERVICE SEARCH_PUBLIC_COMMUNICATIONS_DOCS
    ON content
    ATTRIBUTES relative_path, file_url, title
    WAREHOUSE = SNOW_INTELLIGENCE_DEMO_WH
    TARGET_LAG = '30 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            dm.FILE_PATH as relative_path,
            dm.FILE_PATH as file_url,
            dm.TITLE as title,
            dc.CONTENT as content
        FROM DOCUMENT_CONTENT dc
        JOIN DOCUMENT_METADATA dm ON dc.DOCUMENT_ID = dm.DOCUMENT_ID
        WHERE dm.DEPARTMENT = 'Public Communications'
    );


-- ========================================================================
-- GRANT PERMISSIONS
-- ========================================================================

-- Grant permissions on search services
GRANT USAGE ON CORTEX SEARCH SERVICE SEARCH_BUDGET_FINANCE_DOCS TO ROLE SF_Intelligence_Demo;
GRANT USAGE ON CORTEX SEARCH SERVICE SEARCH_HR_DOCS TO ROLE SF_Intelligence_Demo;
GRANT USAGE ON CORTEX SEARCH SERVICE SEARCH_CITIZEN_SERVICES_DOCS TO ROLE SF_Intelligence_Demo;
GRANT USAGE ON CORTEX SEARCH SERVICE SEARCH_PUBLIC_COMMUNICATIONS_DOCS TO ROLE SF_Intelligence_Demo;

-- Grant permissions on tables
GRANT SELECT ON TABLE DOCUMENT_METADATA TO ROLE SF_Intelligence_Demo;
GRANT SELECT ON TABLE DOCUMENT_CONTENT TO ROLE SF_Intelligence_Demo;

-- Note: Cortex Search services are accessed directly, no function grants needed

-- ========================================================================
-- VERIFICATION
-- ========================================================================

SHOW CORTEX SEARCH SERVICES;

-- Show document metadata
SELECT * FROM DOCUMENT_METADATA ORDER BY DEPARTMENT, DOCUMENT_NAME;
