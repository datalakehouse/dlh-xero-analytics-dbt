{{ config (
  materialized= 'view',
  schema= var('target_schema', 'XERO'),
  tags= ["staging","daily"]
)
}}

WITH JOURNAL_HEADER AS (
  SELECT 
  * 
  FROM  	
    {{ref('V_XER_JOURNAL_HEADER_STG')}}
),
JOURNAL_LINE AS (
  SELECT
  *
  FROM
    {{ref('V_XER_JOURNAL_LINE_STG')}}
),
rename AS 
(  
SELECT
    --DLHK
    JL.K_JOURNAL_LINE_DLHK
    ,S.K_JOURNAL_DLHK
    ,JL.K_ACCOUNT_DLHK
    --BK
    ,JL.K_JOURNAL_LINE_BK
    ,S.K_JOURNAL_BK
    ,S.K_SOURCE_BK 
    ,JL.K_ACCOUNT_BK    
    --ATTRIBUTES
    ,S.A_CREATED_DATE_DTS
    ,S.A_JOURNAL_DATE
    ,S.A_REFERENCE
    ,S.A_SOURCE_TYPE
    ,S.A_JOURNAL_NUMBER
    ,JL.A_ACCOUNT_CODE
    ,JL.A_ACCOUNT_NAME
    ,JL.A_ACCOUNT_TYPE
    ,JL.A_DESCRIPTION
    ,JL.A_TAX_NAME
    ,JL.A_TAX_TYPE
    --METRICS
    ,JL.M_GROSS_AMOUNT
    ,JL.M_NET_AMOUNT
    ,JL.M_TAX_AMOUNT
    --METADATA
    ,CURRENT_TIMESTAMP as MD_LOAD_DTS
    ,'{{invocation_id}}' AS MD_INTGR_ID
FROM
    JOURNAL_HEADER S
    LEFT JOIN JOURNAL_LINE JL on JL.K_JOURNAL_BK = S.K_JOURNAL_BK
)

SELECT * FROM rename