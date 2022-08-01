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
    {{source(var('source_schema', 'DEMO_XERO'),'ITEM')}}
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
    MD5( TRIM(COALESCE(S.ITEM_ID,'00000000000000000000000000000000')) ) AS K_ITEM_DLHK
    ,a_inventory.K_ACCOUNT_DLHK AS K_INVENTORY_ACCOUNT_DLHK
    ,a_purchase_details_account.K_ACCOUNT_DLHK AS K_PURCHASE_DETAILS_ACCOUNT_DLHK
    ,a_purchase_details_cogs.K_ACCOUNT_DLHK AS K_PURCHASE_DETAILS_COGS_ACCOUNT_DLHK
    ,a_sales_details_account.K_ACCOUNT_DLHK AS K_SALES_DETAILS_ACCOUNT_DLHK
    ,a_sales_details_cogs.K_ACCOUNT_DLHK AS K_SALES_DETAILS_COGS_DLHK
    --Business Keys
    ,ITEM_ID AS K_ITEM_BK
    --ATTRIBUTES
    ,CODE AS A_CODE
    ,DESCRIPTION AS A_DESCRIPTION
    ,INVENTORY_ASSET_ACCOUNT_CODE AS A_INVENTORY_ASSET_ACCOUNT_CODE
    ,NAME AS A_NAME
    ,PURCHASE_DESCRIPTION AS A_PURCHASE_DESCRIPTION
    ,PURCHASE_DETAILS_ACCOUNT_CODE AS A_PURCHASE_DETAILS_ACCOUNT_CODE
    ,PURCHASE_DETAILS_COGSACCOUNT_CODE AS A_PURCHASE_DETAILS_COGSACCOUNT_CODE
    ,PURCHASE_DETAILS_TAX_TYPE AS A_PURCHASE_DETAILS_TAX_TYPE
    ,SALES_DETAILS_ACCOUNT_CODE AS A_SALES_DETAILS_ACCOUNT_CODE
    ,SALES_DETAILS_COGSACCOUNT_CODE AS A_SALES_DETAILS_COGSACCOUNT_CODE
    ,SALES_DETAILS_TAX_TYPE AS A_SALES_DETAILS_TAX_TYPE
    ,UPDATED_DATE_UTC AS A_UPDATED_DATE_UTC
    --BOOLEAN
    ,IS_PURCHASED AS B_IS_PURCHASED
    ,IS_SOLD AS B_IS_SOLD
    ,IS_TRACKED_AS_INVENTORY AS B_IS_TRACKED_AS_INVENTORY
    --METRICS
    ,PURCHASE_DETAILS_UNIT_PRICE::decimal(15,2) AS M_PURCHASE_DETAILS_UNIT_PRICE
    ,QUANTITY_ON_HAND::decimal(15,2) AS M_QUANTITY_ON_HAND
    ,SALES_DETAILS_UNIT_PRICE::decimal(15,2) AS M_SALES_DETAILS_UNIT_PRICE
    ,TOTAL_COST_POOL::decimal(15,2) AS M_TOTAL_COST_POOL
    --METADATA (MD)
    ,CURRENT_TIMESTAMP as MD_LOAD_DTS
    ,'{{invocation_id}}' AS MD_INTGR_ID
FROM
    source S
    LEFT JOIN account a_inventory ON a_inventory.A_CODE = S.INVENTORY_ASSET_ACCOUNT_CODE
    LEFT JOIN account a_purchase_details_account ON  a_purchase_details_account.A_CODE = S.PURCHASE_DETAILS_ACCOUNT_CODE
    LEFT JOIN account a_purchase_details_cogs ON a_purchase_details_cogs.A_CODE = S.PURCHASE_DETAILS_COGSACCOUNT_CODE
    LEFT JOIN account a_sales_details_account ON a_sales_details_account.A_CODE = S.SALES_DETAILS_ACCOUNT_CODE
    LEFT JOIN account a_sales_details_cogs ON a_sales_details_cogs.A_CODE = S.SALES_DETAILS_COGSACCOUNT_CODE
)

SELECT * FROM rename