{{ config (
  materialized= 'view',
  schema= var('target_schema'),
  tags= ["staging","daily"]
)
}}

WITH source AS (
  SELECT 
  * 
  FROM  	
    {{source(var('source_schema'),'JOURNAL_LINE')}}
),
account AS (
  SELECT 
  * 
  FROM  	
    {{ref('W_XER_ACCOUNTS_D')}}
),
rename AS 
(  
SELECT
    --DLHK
    MD5( TRIM(COALESCE(S.JOURNAL_LINE_ID,'00000000000000000000000000000000')) ) AS K_JOURNAL_LINE_DLHK
    ,MD5( TRIM(COALESCE(S.JOURNAL_ID,'00000000000000000000000000000000')) ) AS K_JOURNAL_DLHK
    ,A.K_ACCOUNT_DLHK
    --BUSINESS KEYS
    ,S.ACCOUNT_ID AS K_ACCOUNT_BK
    ,S.JOURNAL_ID AS K_JOURNAL_BK
    ,S.JOURNAL_LINE_ID AS K_JOURNAL_LINE_BK
    --ATTRIBUTES
    ,S.ACCOUNT_CODE AS A_ACCOUNT_CODE
    ,S.ACCOUNT_NAME AS A_ACCOUNT_NAME
    ,S.ACCOUNT_TYPE AS A_ACCOUNT_TYPE
    ,S.DESCRIPTION AS A_DESCRIPTION
    ,S.TAX_NAME AS A_TAX_NAME
    ,S.TAX_TYPE AS A_TAX_TYPE
    --METRICS
    ,S.GROSS_AMOUNT::DECIMAL(15,2) AS M_GROSS_AMOUNT
    ,S.NET_AMOUNT::DECIMAL(15,2) AS M_NET_AMOUNT
    ,S.TAX_AMOUNT::DECIMAL(15,2) AS M_TAX_AMOUNT
      --METADATA
    ,CURRENT_TIMESTAMP as MD_LOAD_DTS
    ,'{{invocation_id}}' AS MD_INTGR_ID

FROM
    source S
    LEFT JOIN account A on A.K_ACCOUNT_BK = S.ACCOUNT_ID    
)

SELECT * FROM rename