-- ========================================================================
-- Snowflake AI Demo - Government Agent Setup
-- Creates government-focused Snowflake Intelligence Agent
-- ========================================================================

USE ROLE SF_Intelligence_Demo;

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
    stage_name STRING DEFAULT '@SF_AI_DEMO.DEMO_SCHEMA.INTERNAL_DATA_STAGE';
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
EXTERNAL_ACCESS_INTEGRATIONS = (Snowflake_intelligence_ExternalAccess_Integration)
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
      "identifier": "SF_AI_DEMO.DEMO_SCHEMA.GET_FILE_PRESIGNED_URL_SP",
      "name": "GET_FILE_PRESIGNED_URL_SP(VARCHAR, DEFAULT NUMBER)",
      "type": "procedure"
    },
    "Query Budget & Finance Datamart": {
      "semantic_view": "SF_AI_DEMO.DEMO_SCHEMA.BUDGET_FINANCE_SEMANTIC_VIEW"
    },
    "Query HR Datamart": {
      "semantic_view": "SF_AI_DEMO.DEMO_SCHEMA.HUMAN_RESOURCES_SEMANTIC_VIEW"
    },
    "Query Public Communications Datamart": {
      "semantic_view": "SF_AI_DEMO.DEMO_SCHEMA.PUBLIC_COMMUNICATIONS_SEMANTIC_VIEW"
    },
    "Query Citizen Services Datamart": {
      "semantic_view": "SF_AI_DEMO.DEMO_SCHEMA.CITIZEN_SERVICES_SEMANTIC_VIEW"
    },
    "Search Government Documents: Budget & Finance": {
      "id_column": "FILE_URL",
      "max_results": 5,
      "name": "SF_AI_DEMO.DEMO_SCHEMA.SEARCH_BUDGET_FINANCE_DOCS",
      "title_column": "TITLE"
    },
    "Search Government Documents: HR": {
      "id_column": "FILE_URL",
      "max_results": 5,
      "name": "SF_AI_DEMO.DEMO_SCHEMA.SEARCH_HR_DOCS",
      "title_column": "TITLE"
    },
    "Search Government Documents: Citizen Services": {
      "id_column": "FILE_URL",
      "max_results": 5,
      "name": "SF_AI_DEMO.DEMO_SCHEMA.SEARCH_CITIZEN_SERVICES_DOCS",
      "title_column": "TITLE"
    },
    "Search Government Documents: Public Communications": {
      "id_column": "RELATIVE_PATH",
      "max_results": 5,
      "name": "SF_AI_DEMO.DEMO_SCHEMA.SEARCH_PUBLIC_COMMUNICATIONS_DOCS",
      "title_column": "TITLE"
    },
    "Send_Emails": {
      "execution_environment": {
        "query_timeout": 0,
        "type": "warehouse",
        "warehouse": "SNOW_INTELLIGENCE_DEMO_WH"
      },
      "identifier": "SF_AI_DEMO.DEMO_SCHEMA.SEND_MAIL",
      "name": "SEND_MAIL(VARCHAR, VARCHAR, VARCHAR)",
      "type": "procedure"
    },
    "Web_scraper": {
      "execution_environment": {
        "query_timeout": 0,
        "type": "warehouse",
        "warehouse": "SNOW_INTELLIGENCE_DEMO_WH"
      },
      "identifier": "SF_AI_DEMO.DEMO_SCHEMA.WEB_SCRAPE",
      "name": "WEB_SCRAPE(VARCHAR)",
      "type": "function"
    }
  }
}
$$;
