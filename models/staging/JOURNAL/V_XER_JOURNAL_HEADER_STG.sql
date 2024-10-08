{{ config (
  materialized= 'view',
  schema= var('target_schema', 'XERO'),
  tags= ["staging","daily"]
)
}}

WITH source AS (
  SELECT 
  * 
  FROM  	
    {{source(var('source_schema', 'DEMO_XERO'),'JOURNAL')}}
),
rename AS 
(  
SELECT
    --DLHK
    MD5( TRIM(COALESCE(S.JOURNAL_ID,'00000000000000000000000000000000')) ) AS K_JOURNAL_DLHK
    --BUSINESS KEYS
    ,JOURNAL_ID AS K_JOURNAL_BK
    ,SOURCE_ID AS K_SOURCE_BK    
    --ATTRIBUTES
    ,CREATED_DATE_UTC AS A_CREATED_DATE_DTS
    ,JOURNAL_DATE AS A_JOURNAL_DATE
    ,REFERENCE AS A_REFERENCE
    ,SOURCE_TYPE AS A_SOURCE_TYPE

    ,JOURNAL_NUMBER AS A_JOURNAL_NUMBER
    --METADATA
    ,CURRENT_TIMESTAMP as MD_LOAD_DTS
    ,'{{invocation_id}}' AS MD_INTGR_ID
FROM
    source S
)

SELECT * FROM rename