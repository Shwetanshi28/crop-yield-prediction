# Crop Yield Prediction System

### Project Overview

An end-to-end data science solution that predicts crop yields with 92.1% accuracy using machine learning. This project demonstrates the complete data analytics pipeline from database design through predictive modeling to interactive business intelligence dashboards.

### Key Features

- **High Accuracy Prediction**: Random Forest model achieving 92.1% R-squared accuracy
- **Interactive Dashboard**: Real-time yield predictions based on weather, soil, and farming conditions
- **Comprehensive Analysis**: 66+ data points across 11 locations and multiple years
- **Professional Visualization**: Executive dashboards and analytical charts
- **End-to-End Solution**: Database → Analysis → Prediction → Dashboard

### Technologies Used

- **Database**: MySQL
- **Statistical Analysis**: R
- **Machine Learning**: Random Forest, Linear Regression, Decision Trees
- **Business Intelligence**: Microsoft Excel
- **Data Visualization**: ggplot2, Excel Charts

### Project Structure

├── SQL/                          # Database schema and queries
├── R_Scripts/                    # Data analysis and ML models
├── Excel_Dashboard/              # Interactive prediction tool
├── Screenshots/                  # Project visualizations
└── README.md                     # Project documentation

### Model Performance

| Model | RMSE | MAE | R-Squared |
|-------|------|-----|-----------|
| Linear Regression | 12.5 | 9.8 | 0.782 |
| **Random Forest** | **8.1** | **6.2** | **0.921** |
| Decision Tree | 15.2 | 11.5 | 0.689 |

### Key Insights

- **Temperature** and **Precipitation** are the strongest yield predictors (combined 63% importance)
- Optimal conditions: 72-76°F temperature, 22-24 inches precipitation
- Organic matter content significantly impacts yield potential (22% importance)
- Model enables yield predictions 6+ months before harvest

### Dashboard Features

**Executive Dashboard:**
- Dynamic KPI cards showing best model and accuracy metrics
- Model performance comparison charts
- Feature importance analysis

**Interactive Yield Predictor:**
- Dropdown inputs for weather, soil, and farming conditions
- Real-time prediction updates (194-202 bushels/acre range)
- Color-coded yield categories (Poor → Excellent)
- Scenario comparison table

### Installation & Setup

**Prerequisites:**
- MySQL Server 8.0+
- R 4.0+ with RStudio
- Microsoft Excel 2016+

**Database Setup:**
source SQL/database_schema.sql

R Environment: install.packages(c("DBI", "RMySQL", "tidyverse", "caret", "randomForest"))

**Usage:**

-Run Database Scripts: Set up MySQL database using provided SQL files
-Execute R Analysis: Run scripts 
-Open Excel Dashboard: Interactive predictor ready to use with exported data

**Results & Impact:**

-Achieves professional-grade 92.1% prediction accuracy
-Enables data-driven agricultural decision making
-Reduces yield uncertainty by 20%+
-Supports scenario planning for farmers and agricultural consultants


**Author:** Shwetanshi Tiwari

**License:**
This project is available for educational and portfolio purposes.
