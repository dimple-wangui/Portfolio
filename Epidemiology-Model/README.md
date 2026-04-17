# Socio-Economic Predictors of Malaria

## Project Overview
This repository presents a biostatistical analysis framework for investigating how socio-economic characteristics influence malaria risk. The workflow is designed for reproducible epidemiological research using logistic regression, with emphasis on interpretable effect estimates for policy and public health decision-making.

## Abstract
Malaria remains a major public health burden in many low- and middle-income settings, where transmission is shaped by biological, environmental, and socio-economic determinants. This project examines whether household- and individual-level socio-economic factors are associated with malaria infection status. Using a binary outcome framework, the analysis applies logistic regression to estimate adjusted associations between predictors such as income level, education, housing quality, household size, and access to preventive resources. The repository provides a complete analysis pipeline, including exploratory data analysis, model fitting, and odds ratio interpretation with confidence intervals, enabling transparent and replicable inference.

## Methodology (Logistic Regression)
The primary outcome is a binary indicator of malaria status (`malaria_status`, coded as 1 = positive, 0 = negative).

1. **Data preparation**
   - Import epidemiological dataset (`data/malaria_data.csv`).
   - Recode categorical predictors as factors.
   - Handle missing values and check variable distributions.
2. **Exploratory analysis**
   - Summarize the outcome and covariate distributions.
   - Visualize class balance, variable distributions, and correlation structure.
3. **Model specification**
   - Fit a multivariable logistic regression model:
     \[
     \log\left(\frac{P(Y=1)}{1-P(Y=1)}\right)=\beta_0+\beta_1X_1+\cdots+\beta_kX_k
     \]
   - Include socio-economic covariates and control variables where relevant.
4. **Inference**
   - Convert coefficients to odds ratios (`exp(beta)`).
   - Compute 95% confidence intervals for each odds ratio.
   - Produce a publication-ready summary table.

## Results
Results are generated programmatically in `scripts/02_logistic_regression_analysis.Rmd` and exported to:

- `outputs/model_summary.txt`
- `outputs/odds_ratios_95ci.csv`

The odds ratio table reports point estimates and 95% confidence intervals, facilitating interpretation of effect size and statistical uncertainty for each socio-economic predictor.

## Public Health Implications
Quantifying socio-economic predictors of malaria can support targeted intervention strategies. If specific indicators (e.g., low household income, poor housing materials, limited education, or low bed-net access) are associated with higher odds of malaria, resources can be prioritized toward structurally vulnerable populations. This evidence can inform equitable prevention programs, strengthen surveillance planning, and guide resource allocation for maximal population-level impact.

## Repository Structure
```
Epidemiology-Model/
├── data/
│   └── malaria_data.csv              # Placeholder dataset name
├── outputs/                          # Analysis outputs (tables and figures)
├── scripts/
│   ├── 01_exploratory_data_analysis.Rmd
│   └── 02_logistic_regression_analysis.Rmd
├── .gitignore
├── requirements.txt
└── README.md
```

## Reproducibility
Install required R packages listed in `requirements.txt`, then run:

1. `scripts/01_exploratory_data_analysis.Rmd`
2. `scripts/02_logistic_regression_analysis.Rmd`

All scripts assume the working directory is the project root.
