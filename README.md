# Electricity-Demand-Forecasting-with-Deep-Learning
This repository consolidates household electric power consumption data into a **SQL Server data warehouse and trains a deep learning model (e.g.,) to forecast electricity demand for the next 1 hour**. The pipeline includes data preprocessing, model training, evaluation (using MSE, RMSE), and orchestration via Apache Airflow. Focused on Individual Household electricity consumption data from 2006–2010, resampled at 15-minute intervals, this project supports grid optimization through accurate demand forecasting using deep learning. Clear documentation is provided for stakeholders.

---
## 🏗️ Data Architecture
The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:
![Data Architecture](docs/data_architecture.png)

1. **Bronze Layer**: Stores original raw data from the source text file. Data is ingested from txt Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare deep learning.
3. **Gold Layer**: Houses model ready data modeled into a 2D tensor (Table).

---
## 📖 Project Overview

This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source txt file into the Microsoft SQL warehouse.
3. **Data Modeling**: Developing 2d Tensor(table) optimized for Deep learning.

---
## 🚀 Project Requirements

## Building a Data Warehouse (Data Engineering)

### Objective

Develop a Modern Data Warehouse using Microsoft SQL Server to consolidate individual Household Electric Power Consumption data. This centralized repository will support a data engineering pipeline, enabling deep learning-based demand forecasting and anomaly detection to optimize grid operations.  

### Specification

- **Data Source** : Import data from a text file or CSV file, or install the `ucimlrepo` library and fetch the dataset from their API source.
- **Data Quality** : Preprocess the data to handle missing values, normalize/scale features, and create appropriate input-output sequences for the model.
- **Scope** : Focus only on the following time range : 2006 and November 2010 (47 months) and resample the dataset using a sampling rate of 15 minutes.
- **Documentation** :  Provide clear documentation of the data model to support business stakeholders.

## Building a Deep Learning Model ( Deep Learning with TensorFlow)

### Objective

A trained **deep learning model** capable of **forecasting electricity demand for the next 15 minutes.**

### Specification

- **Model Training** : Train a deep learning model (e.g., LSTM, GRU, or Transformer) to forecast electricity demand for the next 15 minutes using historical time series data.
- **Evaluate Model Performance** : Evaluate the model's performance using key metrics such as: Mean Squared Error (MSE) or Root Mean Squared Error (RMSE) to measure prediction accuracy.
- **Orchestration And Production** : Use Apache Airflow to orchestrate the data pipeline, including: Extracting data from the Data Warehouse, Preprocessing and feeding data into the model and Storing predictions back into the Data Warehouse.
- **Documentation** :  Provide clear documentation of the deep Learning Model to support business stakeholders.
