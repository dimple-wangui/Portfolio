required_packages <- c(
  "tidyverse",
  "janitor",
  "broom"
)

missing_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]
if (length(missing_packages) > 0) {
  install.packages(missing_packages, dependencies = TRUE)
}

invisible(lapply(required_packages, library, character.only = TRUE))

data_path <- file.path("data", "malaria_data.csv")
output_dir <- "outputs"
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

malaria_data <- readr::read_csv(data_path, show_col_types = FALSE) |>
  janitor::clean_names()

# Expected example columns:
# malaria_status (0/1), age, sex, household_income, education_years,
# household_size, bed_net_use, distance_to_clinic_km, housing_quality

analysis_data <- malaria_data |>
  dplyr::mutate(
    malaria_status = as.integer(malaria_status),
    sex = as.factor(sex),
    bed_net_use = as.factor(bed_net_use),
    housing_quality = as.factor(housing_quality)
  ) |>
  dplyr::select(
    malaria_status,
    household_income,
    education_years,
    household_size,
    bed_net_use,
    distance_to_clinic_km,
    age,
    sex,
    housing_quality
  ) |>
  tidyr::drop_na()

logit_model <- stats::glm(
  malaria_status ~ household_income + education_years + household_size +
    bed_net_use + distance_to_clinic_km + age + sex + housing_quality,
  data = analysis_data,
  family = stats::binomial(link = "logit")
)

model_summary_capture <- utils::capture.output(summary(logit_model))
writeLines(model_summary_capture, con = file.path(output_dir, "model_summary.txt"))

odds_ratio_table <- broom::tidy(
  logit_model,
  conf.int = TRUE,
  conf.level = 0.95,
  exponentiate = TRUE
) |>
  dplyr::rename(
    odds_ratio = estimate,
    ci_lower_95 = conf.low,
    ci_upper_95 = conf.high,
    p_value = p.value
  ) |>
  dplyr::mutate(
    dplyr::across(
      c(odds_ratio, ci_lower_95, ci_upper_95, p_value),
      ~ round(.x, 4)
    )
  )

readr::write_csv(odds_ratio_table, file.path(output_dir, "odds_ratios_95ci.csv"))

message("Logistic regression analysis complete.")
message("Outputs saved to outputs/model_summary.txt and outputs/odds_ratios_95ci.csv.")
