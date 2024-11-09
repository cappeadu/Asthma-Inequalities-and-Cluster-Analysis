# Asthma-Inequalities-and-Cluster-Analysis
This repository explores asthma-related health disparities through SQL-based data extraction and Python-driven cluster analysis. By examining demographic and socio-economic factors, we identify patterns in asthma clinical outcomes and emergency admissions using *synthetically generated data*.
### Project Overview
#### SQL Queries
The SQL component structures clinical data to extract relevant metrics, enabling clustering and regression analysis on:

- **GP Visits for Asthma**: Frequency and patterns of GP visits specific to asthma patients.
- **Hospital Admissions**: Including readmissions and outpatient appointments.
- **Medication Prescriptions**: Total asthma prescriptions.

#### Python Cluster Analysis and Poisson Regression
- **Clustering Analysis**: Groups patients based on healthcare utilization metrics, such as outpatient appointments, prescriptions, and exacerbation counts.
- **Poisson Regression**: Evaluates the relationship between each cluster and the likelihood of emergency admissions, highlighting how certain clusters show significantly higher or lower admission probabilities.

### Repository Contents
- **SQL Queries**: Code for preparing clinical outcome data.
- **Python Analysis (Jupyter Notebook)**: Includes clustering models, Poisson regression analysis, and visualizations summarizing cluster attributes.
- **Documentation**: Insights and visualizations that explore asthma outcome disparities and emergency admission risks.

### Key Findings
- **Cluster 1**: Patients with frequent prescriptions and appointments, showing a higher probability of emergency admissions.
- **Cluster 0**: Lower healthcare utilization with fewer emergency admissions, suggesting better-managed asthma.

The Poisson regression confirms that Cluster 1 patients have a statistically significant association with increased emergency admissions, underscoring potential areas for intervention.

### Dependencies
- **Python libraries**: Faker, pandas, numpy, scikit-learn, statsmodels (for Poisson regression).
- SQL environment to support the extraction script.
