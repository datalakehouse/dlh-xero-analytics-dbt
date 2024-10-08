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
    {{source(var('source_schema', 'DEMO_XERO'),'ASSET')}}
),
asset_type AS (
  SELECT
  *
  FROM
    {{source(var('source_schema', 'DEMO_XERO'),'ASSET_TYPE')}}
),
rename AS 
(   
SELECT 
    --MD5
    MD5( TRIM(COALESCE(A.ASSET_ID,'00000000000000000000000000000000')) ) AS K_ASSET_DLHK
    ,MD5( TRIM(COALESCE(A.ASSET_TYPE_ID,'00000000000000000000000000000000')) ) AS K_ASSET_TYPE_DLHK
    --BUSINESS KEYS
    ,A.ASSET_ID AS K_ASSET_BK
    ,A.ASSET_TYPE_ID AS K_ASSET_TYPE_BK
    ,A.DEPRECIATION_BOOK_EFFECTIVE_DATE_OF_CHANGE_ID AS K_DEPRECIATION_BOOK_EFFECTIVE_DATE_OF_CHANGE_BK
    ,A.DEPRECIATION_OBJECT_ID AS K_DEPRECIATION_OBJECT_BK
    --ATTRIBUTES
    ,A.ASSET_NAME AS A_ASSET_NAME
    ,A.ASSET_NUMBER AS A_ASSET_NUMBER
    ,A.ASSET_STATUS AS A_ASSET_STATUS
    ,A.CURRENT_ACCUM_DEPRECIATION_AMOUNT AS A_CURRENT_ACCUM_DEPRECIATION_AMOUNT
    ,A.DEPRECIATION_AVERAGING_METHOD AS A_DEPRECIATION_AVERAGING_METHOD
    ,A.DEPRECIATION_CALCULATION_METHOD AS A_DEPRECIATION_CALCULATION_METHOD    
    ,A.DEPRECIATION_EFFECTIVE_FROM_DATE AS A_DEPRECIATION_EFFECTIVE_FROM_DATE
    ,A.DEPRECIATION_METHOD AS A_DEPRECIATION_METHOD
    ,A.DEPRECIATION_OBJECT_TYPE AS A_DEPRECIATION_OBJECT_TYPE
    ,A.DEPRECIATION_RATE AS A_DEPRECIATION_RATE
    ,A.DEPRECIATION_START_DATE AS A_DEPRECIATION_START_DATE
    ,A.DESCRIPTION AS A_DESCRIPTION
    ,A.DISPOSAL_DATE AS A_DISPOSAL_DATE
    ,A.DISPOSAL_PRICE AS A_DISPOSAL_PRICE    
    ,A.PURCHASE_DATE AS A_PURCHASE_DATE    
    ,A.SERIAL_NUMBER AS A_SERIAL_NUMBER
    ,A.WARRANTY_EXPIRY_DATE AS A_WARRANTY_EXPIRY_DATE
    ,T.ASSET_TYPE_NAME AS A_ASSET_TYPE_NAME
    ,T.DEPRECIATION_METHOD AS A_ASSET_TYPE_DEPRECIATION_METHOD    
    --BOOLEAN
    ,A.CAN_ROLLBACK AS B_CAN_ROLLBACK
    ,A.IS_DELETE_ENABLED_FOR_DATE AS B_IS_DELETE_ENABLED_FOR_DATE
    --METRICS
    ,A.DEPRECIATION_CURRENT_CAPITAL_GAIN::DECIMAL(15,2) AS M_DEPRECIATION_CURRENT_CAPITAL_GAIN
    ,A.DEPRECIATION_CURRENT_GAIN_LOSS::DECIMAL(15,2) AS M_DEPRECIATION_CURRENT_GAIN_LOSS
    ,A.ACCOUNTING_BOOK_VALUE::DECIMAL(15,2) AS M_ACCOUNTING_BOOK_VALUE
    ,A.DEPRECIATION_EFFECTIVE_LIFE_YEARS::DECIMAL(15,2) AS M_DEPRECIATION_EFFECTIVE_LIFE_YEARS
    ,A.PRIOR_ACCUM_DEPRECIATION_AMOUNT::DECIMAL(15,2) AS M_PRIOR_ACCUM_DEPRECIATION_AMOUNT
    ,A.PURCHASE_PRICE::DECIMAL(15,2) AS M_PURCHASE_PRICE
    ,T.DEPRECIATION_RATE AS M_ASSET_TYPE_DEPRECIATION_RATE
    --METADATA
    ,CURRENT_TIMESTAMP as MD_LOAD_DTS
    ,'{{invocation_id}}' AS MD_INTGR_ID
  FROM
    source  A
    LEFT JOIN asset_type T ON T.ASSET_TYPE_ID = A.ASSET_TYPE_ID
)


SELECT * FROM rename