-- ========================================================================
-- Snowflake AI Demo - Government Agent Setup (Step 4 of 4)
--
-- DESCRIPTION:
-- Creates the Government_City_County_Agent - a comprehensive AI agent that
-- orchestrates between Cortex Analyst (Text-to-SQL), Cortex Search (document search),
-- and external tools for complete government analytics.
--
-- AGENT CAPABILITIES:
-- - Natural language queries across all government domains
-- - Document search and policy research
-- - Web scraping for external data analysis
-- - Email notifications and reporting
-- - File access with presigned URLs
-- - Progressive drill-down analysis from high-level to actionable insights
--
-- PREREQUISITES:
-- - government_cortex_search_setup.sql must be completed successfully
-- - All semantic views and search services must be operational
-- - Snowflake Intelligence must be enabled
--
-- EXECUTION TIME: ~2-3 minutes
--
-- COMPLETION: After this script, your demo is ready! 
-- Access the agent in Snowflake Intelligence UI and start asking questions.
-- ========================================================================

-- Use SF_Intelligence_Demo role to create procedures and functions first
USE ROLE SF_Intelligence_Demo;
USE DATABASE SPRINGFIELD_GOV;
USE SCHEMA DEMO;
USE WAREHOUSE SNOW_INTELLIGENCE_DEMO_WH;

-- Create stored procedure to generate presigned URLs for files in internal stages
CREATE OR REPLACE PROCEDURE Get_File_Presigned_URL_SP(
    RELATIVE_FILE_PATH STRING, 
    EXPIRATION_MINS INTEGER DEFAULT 60
)
RETURNS STRING
LANGUAGE SQL
COMMENT = 'Generates a presigned URL for a file in the static @INTERNAL_DATA_STAGE. Input is the relative file path.'
EXECUTE AS CALLER
AS
$$
DECLARE
    presigned_url STRING;
    sql_stmt STRING;
    expiration_seconds INTEGER;
    stage_name STRING DEFAULT '@SPRINGFIELD_GOV.DEMO.INTERNAL_DATA_STAGE';
BEGIN
    expiration_seconds := EXPIRATION_MINS * 60;

    sql_stmt := 'SELECT GET_PRESIGNED_URL(' || stage_name || ', ' || '''' || RELATIVE_FILE_PATH || '''' || ', ' || expiration_seconds || ') AS url';
    
    EXECUTE IMMEDIATE :sql_stmt;
    
    SELECT "URL"
    INTO :presigned_url
    FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));
    
    RETURN :presigned_url;
END;
$$;

-- Create stored procedure to send emails to verified recipients in Snowflake
CREATE OR REPLACE PROCEDURE send_mail(recipient TEXT, subject TEXT, text TEXT)
RETURNS TEXT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'send_mail'
AS
$$
def send_mail(session, recipient, subject, text):
    session.call(
        'SYSTEM$SEND_EMAIL',
        'ai_email_int',
        recipient,
        subject,
        text,
        'text/html'
    )
    return f'Email was sent to {recipient} with subject: "{subject}".'
$$;

CREATE OR REPLACE FUNCTION Web_scrape(weburl STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = 3.11
HANDLER = 'get_page'
EXTERNAL_ACCESS_INTEGRATIONS = ()
PACKAGES = ('requests', 'beautifulsoup4')
AS
$$
import _snowflake
import requests
from bs4 import BeautifulSoup

def get_page(weburl):
  url = f"{weburl}"
  response = requests.get(url)
  soup = BeautifulSoup(response.text)
  return soup.get_text()
$$;

-- Grant ACCOUNTADMIN access to the schema and objects before agent creation
USE ROLE SF_Intelligence_Demo;
GRANT USAGE ON DATABASE SPRINGFIELD_GOV TO ROLE ACCOUNTADMIN;
GRANT USAGE ON SCHEMA SPRINGFIELD_GOV.DEMO TO ROLE ACCOUNTADMIN;
GRANT USAGE ON WAREHOUSE SNOW_INTELLIGENCE_DEMO_WH TO ROLE ACCOUNTADMIN;
GRANT SELECT ON ALL TABLES IN SCHEMA SPRINGFIELD_GOV.DEMO TO ROLE ACCOUNTADMIN;
GRANT USAGE ON ALL FUNCTIONS IN SCHEMA SPRINGFIELD_GOV.DEMO TO ROLE ACCOUNTADMIN;
GRANT USAGE ON ALL PROCEDURES IN SCHEMA SPRINGFIELD_GOV.DEMO TO ROLE ACCOUNTADMIN;

-- Now switch to ACCOUNTADMIN to create the agent in the system schema
USE ROLE ACCOUNTADMIN;
USE DATABASE SPRINGFIELD_GOV;
USE SCHEMA DEMO;
USE WAREHOUSE SNOW_INTELLIGENCE_DEMO_WH;

-- Create government-focused Snowflake Intelligence Agent
CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.Government_City_County_Agent
WITH PROFILE='{ "display_name": "Government City & County Agent" }'
    COMMENT=$$ This is an agent that can answer questions about city and county government operations including Budget & Finance, Citizen Services, Public Communications, and Human Resources. $$
FROM SPECIFICATION $$
{
  "models": {
    "orchestration": ""
  },
  "instructions": {
    "response": "You are a government data analyst who has access to budget & finance, citizen services, public communications, and HR datamarts for a city/county government. If user does not specify a date range assume it for year 2025. Leverage data from all domains to analyse & answer user questions. Provide visualizations if possible. Trendlines should default to linecharts, Categories Barchart.",
    "orchestration": "Use cortex search for known entities and pass the results to cortex analyst for detailed analysis.\nIf answering citizen services related question from datamart, Always make sure to include the service_dim table & filter service VERTICAL by 'Public Services' for all questions but don't show this fact while explaining thinking steps.\n\nFor Public Communications Datamart:\nService Request Status=Completed indicates a completed service request. \nServiceID in public communications datamart links a service request to a Service record in Citizen Services Datamart ServiceID columns\n\n\n",
    "sample_questions": [
      {
        "question": "What are our monthly budget expenditures for the last 12 months?"
      },
      {
        "question": "How many citizen service requests were completed this quarter?"
      },
      {
        "question": "What are our most effective public communication campaigns?"
      },
      {
        "question": "What's our employee headcount by department?"
      },
      {
        "question": "Show me our service delivery performance trends across all districts over the past 2 years"
      },
      {
        "question": "Which contractors have the highest spending and what services do they provide?"
      },
      {
        "question": "What are the top 5 most requested citizen services and their completion rates?"
      },
      {
        "question": "Find information about our procurement policies and budget allocation procedures"
      },
      {
        "question": "Compare our employee salaries by department and identify any retention risks based on attrition data"
      },
      {
        "question": "Which district has the highest service delivery costs and why?"
      },
      {
        "question": "Show me the detailed breakdown of service costs in District 3 - Westside by service category"
      },
      {
        "question": "What specific services are driving up costs in District 3 and which contractors are involved?"
      },
      {
        "question": "Find policy documents related to infrastructure services and contractor management in our westside operations"
      },
      {
        "question": "Which employees in District 3 handle the most expensive service requests and what are their performance metrics?"
      },
      {
        "question": "Create an action plan to optimize service delivery costs in District 3 based on historical data and policy guidelines"
      }
    ]
  },
  "tools": [
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query Budget & Finance Datamart",
        "description": "Allows users to query budget and finance data for a city/county government in terms of revenue & expenditures."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query Citizen Services Datamart",
        "description": "Allows users to query citizen services data for a city/county government in terms of service delivery, permits, and citizen interactions."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query HR Datamart",
        "description": "Allows users to query HR data for a city/county government in terms of employee data, departments, and workforce management."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query Public Communications Datamart",
        "description": "Allows users to query public communications data in terms of campaigns, channels, outreach, and community engagement."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search Government Documents: Budget & Finance",
        "description": ""
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search Government Documents: HR",
        "description": ""
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search Government Documents: Citizen Services",
        "description": ""
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search Government Documents: Public Communications",
        "description": "This tools should be used to search unstructured docs related to public communications department.\n\nAny reference docs in ID columns should be passed to Dynamic URL tool to generate a downloadable URL for users in the response"
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "Web_scraper",
        "description": "This tool should be used if the user wants to analyse contents of a given web page. This tool will use a web url (https or https) as input and will return the text content of that web page for further analysis",
        "input_schema": {
          "type": "object",
          "properties": {
            "weburl": {
              "description": "Agent should ask web url ( that includes http:// or https:// ). It will scrape text from the given url and return as a result.",
              "type": "string"
            }
          },
          "required": [
            "weburl"
          ]
        }
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "Send_Emails",
        "description": "This tool is used to send emails to a email recipient. It can take an email, subject & content as input to send the email. Always use HTML formatted content for the emails.",
        "input_schema": {
          "type": "object",
          "properties": {
            "recipient": {
              "description": "recipient of email",
              "type": "string"
            },
            "subject": {
              "description": "subject of email",
              "type": "string"
            },
            "text": {
              "description": "content of email",
              "type": "string"
            }
          },
          "required": [
            "text",
            "recipient",
            "subject"
          ]
        }
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "Dynamic_Doc_URL_Tool",
        "description": "This tools uses the ID Column coming from Cortex Search tools for reference docs and returns a temp URL for users to view & download the docs.\n\nReturned URL should be presented as a HTML Hyperlink where doc title should be the text and out of this tool should be the url.\n\nURL format for PDF docs that are are like this which has no PDF in the url. Create the Hyperlink format so the PDF doc opens up in a browser instead of downloading the file.\nhttps://domain/path/unique_guid",
        "input_schema": {
          "type": "object",
          "properties": {
            "expiration_mins": {
              "description": "default should be 5",
              "type": "number"
            },
            "relative_file_path": {
              "description": "This is the ID Column value Coming from Cortex Search tool.",
              "type": "string"
            }
          },
          "required": [
            "expiration_mins",
            "relative_file_path"
          ]
        }
      }
    }
  ],
  "tool_resources": {
    "Dynamic_Doc_URL_Tool": {
      "execution_environment": {
        "query_timeout": 0,
        "type": "warehouse",
        "warehouse": "SNOW_INTELLIGENCE_DEMO_WH"
      },
      "identifier": "SPRINGFIELD_GOV.DEMO.GET_FILE_PRESIGNED_URL_SP",
      "name": "GET_FILE_PRESIGNED_URL_SP(VARCHAR, DEFAULT NUMBER)",
      "type": "procedure"
    },
    "Query Budget & Finance Datamart": {
      "semantic_view": "SPRINGFIELD_GOV.DEMO.BUDGET_FINANCE_SEMANTIC_VIEW"
    },
    "Query HR Datamart": {
      "semantic_view": "SPRINGFIELD_GOV.DEMO.HUMAN_RESOURCES_SEMANTIC_VIEW"
    },
    "Query Public Communications Datamart": {
      "semantic_view": "SPRINGFIELD_GOV.DEMO.PUBLIC_COMMUNICATIONS_SEMANTIC_VIEW"
    },
    "Query Citizen Services Datamart": {
      "semantic_view": "SPRINGFIELD_GOV.DEMO.CITIZEN_SERVICES_SEMANTIC_VIEW"
    },
    "Search Government Documents: Budget & Finance": {
      "id_column": "FILE_URL",
      "max_results": 5,
      "name": "SPRINGFIELD_GOV.DEMO.SEARCH_BUDGET_FINANCE_DOCS",
      "title_column": "TITLE"
    },
    "Search Government Documents: HR": {
      "id_column": "FILE_URL",
      "max_results": 5,
      "name": "SPRINGFIELD_GOV.DEMO.SEARCH_HR_DOCS",
      "title_column": "TITLE"
    },
    "Search Government Documents: Citizen Services": {
      "id_column": "FILE_URL",
      "max_results": 5,
      "name": "SPRINGFIELD_GOV.DEMO.SEARCH_CITIZEN_SERVICES_DOCS",
      "title_column": "TITLE"
    },
    "Search Government Documents: Public Communications": {
      "id_column": "RELATIVE_PATH",
      "max_results": 5,
      "name": "SPRINGFIELD_GOV.DEMO.SEARCH_PUBLIC_COMMUNICATIONS_DOCS",
      "title_column": "TITLE"
    },
    "Send_Emails": {
      "execution_environment": {
        "query_timeout": 0,
        "type": "warehouse",
        "warehouse": "SNOW_INTELLIGENCE_DEMO_WH"
      },
      "identifier": "SPRINGFIELD_GOV.DEMO.SEND_MAIL",
      "name": "SEND_MAIL(VARCHAR, VARCHAR, VARCHAR)",
      "type": "procedure"
    },
    "Web_scraper": {
      "execution_environment": {
        "query_timeout": 0,
        "type": "warehouse",
        "warehouse": "SNOW_INTELLIGENCE_DEMO_WH"
      },
      "identifier": "SPRINGFIELD_GOV.DEMO.WEB_SCRAPE",
      "name": "WEB_SCRAPE(VARCHAR)",
      "type": "function"
    }
  }
}
$$;

-- ========================================================================
-- GRANT PERMISSIONS
-- ========================================================================

-- Grant usage on the agent to the demo role (agent is in system schema)
GRANT USAGE ON AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.Government_City_County_Agent TO ROLE SF_Intelligence_Demo;

-- Note: Semantic views are accessed through database/schema USAGE permissions
-- The role already has USAGE on SPRINGFIELD_GOV.DEMO schema

-- Grant permissions on Cortex Search services
GRANT USAGE ON CORTEX SEARCH SERVICE SPRINGFIELD_GOV.DEMO.SEARCH_BUDGET_FINANCE_DOCS TO ROLE SF_Intelligence_Demo;
GRANT USAGE ON CORTEX SEARCH SERVICE SPRINGFIELD_GOV.DEMO.SEARCH_HR_DOCS TO ROLE SF_Intelligence_Demo;
GRANT USAGE ON CORTEX SEARCH SERVICE SPRINGFIELD_GOV.DEMO.SEARCH_CITIZEN_SERVICES_DOCS TO ROLE SF_Intelligence_Demo;
GRANT USAGE ON CORTEX SEARCH SERVICE SPRINGFIELD_GOV.DEMO.SEARCH_PUBLIC_COMMUNICATIONS_DOCS TO ROLE SF_Intelligence_Demo;

-- Grant permissions on procedures and functions
GRANT USAGE ON PROCEDURE SPRINGFIELD_GOV.DEMO.GET_FILE_PRESIGNED_URL_SP(VARCHAR, NUMBER) TO ROLE SF_Intelligence_Demo;
GRANT USAGE ON PROCEDURE SPRINGFIELD_GOV.DEMO.SEND_MAIL(VARCHAR, VARCHAR, VARCHAR) TO ROLE SF_Intelligence_Demo;
GRANT USAGE ON FUNCTION SPRINGFIELD_GOV.DEMO.WEB_SCRAPE(VARCHAR) TO ROLE SF_Intelligence_Demo;

-- Grant permissions on tables
GRANT SELECT ON TABLE SPRINGFIELD_GOV.DEMO.DOCUMENT_METADATA TO ROLE SF_Intelligence_Demo;
GRANT SELECT ON TABLE SPRINGFIELD_GOV.DEMO.DOCUMENT_CONTENT TO ROLE SF_Intelligence_Demo;
