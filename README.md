# Xero package

This dbt package:

*   Contains a DBT dimensional model based on Xero data from [DataLakeHouse.io](https://www.datalakehouse.io/) connector.
*   The main use of this package is to provide a stable snowflake dimensional model that will provide useful insights.
    

### Models

The primary ouputs of this package are fact and dimension tables as listed below. There are several intermediate models used to create these models. Documentation can be found [here](https://datalakehouse.github.io/dlh-xero-analytics-dbt/#!/overview).

|        Type       |        Model       |        Raw tables involved       |
|:----------------:|:----------------:|----------------|
|Dimension| W_XER_ACCOUNTS_D       | ACCOUNT|
|Dimension| W_XER_ASSETS_D         | ASSET<br>ASSET_TYPE |
|Dimension| W_XER_CURRENCY_D       | Manually built |
|Dimension| W_XER_CONTACTS_D      | CONTACTS<br>CONTACT_GROUP_MEMBER<br>CONTACT_GROUP|
|Dimension| W_XER_DATE_D      | Manually built|
|Dimension| W_XER_EMPLOYEES_D      | EMPLOYEE|
|Dimension| W_XER_ITEMS_D      | ITEM|
|Fact| W_XER_JOURNAL_F | ORDER<br>ORDER_LINE_ITEM<br>ORDER_LINE_ITEM_MODIFIER|
|Fact| W_XER_PAYMENTS_F          | PAYMENT|
|Fact| W_XER_INVOICES_F          | INVOICE<br>INVOICE_LINE_ITEM|
|Fact| W_XER_PURCHASE_ORDERS_F          | PURCHASE_ORDER<br>PURCHASE_ORDER_LINE_ITEM|
|Fact| W_XER_RECEIPTS_F          | RECEIPT<br>RECEIPT_LINE_ITEM|

| ![0jSpD4G.png](https://i.imgur.com/0jSpD4G.png) | 
|:--:| 
| *ERD of Dimensional Model* | 

</br>

| ![EuwN0Nn.png](https://i.imgur.com/EuwN0Nn.png) | 
|:--:| 
| *Data Lineage Graph* |

Installation Instructions
-------------------------

Check [dbt Hub](https://hub.getdbt.com) for the latest installation instructions, or [read the docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

Include in your packages.yml

```yaml
packages:
  - package: datalakehouse/dlh_xero
    version: [">=0.1.0"]
```

Configuration
-------------

By default, this package uses `DEVELOPER_SANDBOX` as the source database name and `DEMO_XERO` as schema name. If this is not the where your salesforce data is, change ther below [variables](https://docs.getdbt.com/docs/using-variables) configuration on your `dbt_project.yml`:

```yaml
# dbt_project.yml

...

vars:    
    source_database: DEVELOPER_SANDBOX
    source_schema: DEMO_XERO
    target_schema: XERO
```

### Database support

Core:

*   Snowflake
    

### Contributions

Additional contributions to this package are very welcome! Please create issues or open PRs against `main`. Check out [this post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package.


*   Fork and :star: this repository :)
*   Check it out and :star: [the datalakehouse core repository](https://github.com/datalakehouse/datalakehouse-core);
