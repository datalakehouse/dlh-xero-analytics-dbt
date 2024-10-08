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
    {{source(var('source_schema', 'DEMO_XERO'),'EMPLOYEE')}}
),
rename AS 
(  
SELECT
    --DLHK    
    MD5( TRIM(COALESCE(EMPLOYEE_ID,'00000000000000000000000000000000')) ) AS K_EMPLOYEE_DLHK
    --Business Keys
    ,EMPLOYEE_ID AS K_EMPLOYEE_BK
    --ATTRIBUTES
    ,STATUS AS A_STATUS
    ,FIRST_NAME AS A_FIRST_NAME
    ,LAST_NAME AS A_LAST_NAME
    ,{{full_name('FIRST_NAME', 'LAST_NAME')}} AS A_FULL_NAME
    ,UPDATED_DATE_UTC AS A_UPDATED_AT_DTS
    --METADATA
    ,CURRENT_TIMESTAMP as MD_LOAD_DTS
    ,'{{invocation_id}}' AS MD_INTGR_ID
FROM
    source S
)

SELECT * FROM rename