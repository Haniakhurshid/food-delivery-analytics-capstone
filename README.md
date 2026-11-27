# Food Delivery Analytics

## Project Overview

Food Delivery Analytics is a data engineering project that processes food delivery order data and transforms it into reliable, business-ready information for analysis.

The project uses the Medallion Architecture (Bronze, Silver and Gold) in Databricks, with dbt for data transformation, incremental loading, testing and documentation.

## Objectives

- Build an end-to-end data pipeline.
- Validate and clean incoming order data.
- Handle incremental data using MERGE operations.
- Maintain historical changes using SCD Type 2 and dbt Snapshots.
- Create analytical tables to support business insights.

## Technology Stack

- **Databricks:** Data processing and Medallion Architecture
- **PySpark & SQL:** Data ingestion, transformation and analysis
- **Delta Lake:** Reliable table storage and MERGE operations
- **dbt Cloud:** Data modelling, incremental processing, testing and documentation

## Project Architecture

The project follows the Medallion Architecture:

- **Bronze:** Ingests raw order data, maintains audit metadata and separates valid and rejected records.
- **Silver:** Cleans and standardizes data, applies validation rules and calculates order amounts.
- **Gold:** Creates fact and dimension tables for business reporting and analysis.

## Key Implementations

- Initial and incremental data ingestion.
- Data quality checks and reconciliation.
- Incremental MERGE using `order_id` as the unique key.
- SCD Type 2 implementation for restaurant history.
- dbt Snapshot to track changes in restaurant attributes.
- dbt models, data tests, documentation and lineage.
- Databricks Job orchestration for Bronze, Silver and Gold processing.

## Business Analysis

The Gold layer supports analysis such as:

- Restaurant performance and revenue.
- Order volume by city.
- Food category performance.
- Delivered and cancelled order analysis.
- Customer and revenue trends.

## Validation Results

The incremental processing demonstration produced:

- 50 incoming Batch 2 records.
- 46 valid records and 4 rejected records.
- 15 existing records updated and 31 new records inserted.
- 114 unique orders after incremental processing.
- Total revenue of ₹214,801.00.

