{{ config (
  materialized= 'table',
  schema= var('target_schema', 'XERO'),
  tags= ["staging", "daily"],
  transient=false
)
}}


SELECT
  *
FROM
  {{ref('V_XER_PURCHASE_ORDERS_STG')}} AS C