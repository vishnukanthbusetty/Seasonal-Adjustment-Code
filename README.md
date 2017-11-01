# Seasonal-Adjustment-Code
Implementing Seasonality Forecasting Algorithm in SQL

What is seasonal adjustment?

Mathematically adjusted by moderating a macroeconomic indicator (e.g., oil prices/imports) so that relative comparisons can be drawn from month to month all year.

Data that was collected over time form a time series. Many of the most well-known statistics published by the Office for National Statistics are regular time series, including: the claimant count, the Retail Prices Index (RPI), Balance of Payments, and Gross Domestic Product (GDP). Those analyzing time Series typically seek to establish the general pattern of the data, the long-term movements, and whether any unusual occurrences have had major effects on the series. This type of analysis is not straightforward when one is reliant on raw time series data, because there will normally be short-term effects, associated with the time of the year, which obscure or confound other movements.

For example, retail sales rise each December due to Christmas. The purpose of seasonal adjustment is to remove systematic calendar related variation associated with the time of the year, i.e. seasonal effects. This facilitates comparisons between consecutive time periods.

Configuration:

Configured seasonality forecasting algorithm in the Business Intelligence Product by calling a stored procedure as a mode of execution for the algorithm logic in the product.

Design:

I have designed the best possible high performance stored procedure to have faster retrieval of values into the product.

Description:

My challenge is to develop a seasonality forecasting algorithm that can be applied on a plan table. As part of the Planning and Budgeting module of BI product, users have a province to enter historical data and planned data in a single plan sheet which will be formed into a single plan table in database. Planned data can be either manually entered or algorithms like moving averages, seasonality forecasting can be applied on historical data to obtain values which will be fetched into the product.

Table format

Planned Data:

ROW_NUM, P_2013_Q1_M4_M67584368, P_2013_Q1_M5_M67584368, P_2013_Q1_M6_M67584368, P_2013_Q2_M7_M67584368, P_2013_Q2_M8_M67584368, P_2013_Q2_M9_M67584368, P_2013_Q3_M10_M67584368, P_2013_Q3_M11_M67584368, P_2013_Q3_M12_M67584368, P_2014_Q4_M1_M67584368, P_2014_Q4_M2_M67584368, P_2014_Q4_M3_M67584368
Historic data:

H_2012_2013_Q1_M4_M67584368, H_2012_2013_Q1_M5_M67584368, H_2012_2013_Q1_M6_M67584368, H_2012_2013_Q2_M7_M67584368, H_2012_2013_Q2_M8_M67584368, H_2012_2013_Q2_M9_M67584368, H_2012_2013_Q3_M10_M67584368, H_2012_2013_Q3_M11_M67584368, H_2012_2013_Q3_M12_M67584368, H_2012_2013_Q4_M1_M67584368, H_2012_2013_Q4_M2_M67584368, H_2012_2013_Q4_M3_M67584368
© 2017 GitHub, Inc.
