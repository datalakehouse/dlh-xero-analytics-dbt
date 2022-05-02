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
    {{source(var('source_schema'),'PURCHASE_ORDER_LINE_ITEM')}}
),
account AS (
  SELECT 
  * 
  FROM  	
    {{ref('W_XER_ACCOUNTS_D')}}
),
item AS (
  SELECT 
  * 
  FROM  	
     {{ref('W_XER_ITEMS_D')}}
),
rename AS 
(  
SELECT
    --DLHK
    MD5( TRIM(COALESCE(S.LINE_ITEM_ID,'00000000000000000000000000000000')) ) AS K_PURCHASE_LINE_ITEM_DLHK
    ,MD5( TRIM(COALESCE(S.PURCHASE_ORDER_ID,'00000000000000000000000000000000')) ) AS K_PURCHASE_ORDER_DLHK
    ,A.K_ACCOUNT_DLHK
    ,I.K_ITEM_DLHK
    --attributes
    --BK
    ,A.K_ACCOUNT_BK
    ,I.K_ITEM_BK
    ,S.LINE_ITEM_ID AS K_PURCHASE_LINE_ITEM_BK
    ,S.PURCHASE_ORDER_ID AS K_PURCHASE_ORDER_BK
    ,S.ACCOUNT_CODE AS A_ACCOUNT_CODE
    ,S.DESCRIPTION AS A_DESCRIPTION
    ,S.ITEM_CODE AS A_ITEM_CODE
    ,S.TAX_TYPE AS A_TAX_TYPE
    --metrics
    ,DIV0(S.DISCOUNT_RATE,100)::DECIMAL(15,2) AS M_DISCOUNT_RATE
    ,(S.UNIT_AMOUNT * S.QUANTITY)::DECIMAL(15,2) AS M_GROSS_AMOUNT
    ,(M_GROSS_AMOUNT * M_DISCOUNT_RATE)::DECIMAL(15,2) AS M_DISCOUNT_AMOUNT
    ,S.LINE_AMOUNT::DECIMAL(15,2) AS M_LINE_AMOUNT
    ,S.QUANTITY::DECIMAL(15,2) AS M_QUANTITY
    ,S.TAX_AMOUNT::DECIMAL(15,2) AS M_TAX_AMOUNT
    ,S.UNIT_AMOUNT::DECIMAL(15,2) AS M_UNIT_AMOUNT
FROM
    source S
    LEFT JOIN account A on A.A_CODE = S.ACCOUNT_CODE
    LEFT JOIN item I ON I.A_CODE = S.ITEM_CODE
)

SELECT * FROM rename