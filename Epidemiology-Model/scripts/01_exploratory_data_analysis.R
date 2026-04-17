required_packages <- c(
  "tidyverse",
  "janitor",
  "GGally",
  "scales"
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
# malaria_status (0/1), age, household_income, education_years,
# household_size, bed_net_use (0/1), distance_to_clinic_km

numeric_vars <- malaria_data |>
  dplyr::select(where(is.numeric))

# 1) Distribution plot: household income by malaria status
income_plot <- malaria_data |>
  dplyr::mutate(
    malaria_status = factor(
      malaria_status,
      levels = c(0, 1),
      labels = c("Negative", "Positive")
    )
  ) |>
  ggplot2::ggplot(ggplot2::aes(x = household_income, fill = malaria_status)) +
  ggplot2::geom_histogram(
    bins = 35,
    alpha = 0.7,
    position = "identity",
    color = "white"
  ) +
  ggplot2::scale_fill_brewer(palette = "Set1", name = "Malaria Status") +
  ggplot2::scale_x_continuous(labels = scales::label_comma()) +
  ggplot2::labs(
    title = "Distribution of Household Income by Malaria Status",
    x = "Household Income",
    y = "Count"
  ) +
  ggplot2::theme_minimal(base_size = 13) +
  ggplot2::theme(plot.title = ggplot2::element_text(face = "bold"))

ggplot2::ggsave(
  filename = file.path(output_dir, "eda_income_distribution.png"),
  plot = income_plot,
  width = 9,
  height = 6,
  dpi = 300
)

# 2) Correlation heatmap for numeric predictors
cor_matrix <- stats::cor(numeric_vars, use = "pairwise.complete.obs")
cor_df <- as.data.frame(as.table(cor_matrix))
colnames(cor_df) <- c("Var1", "Var2", "Correlation")

correlation_plot <- ggplot2::ggplot(cor_df, ggplot2::aes(Var1, Var2, fill = Correlation)) +
  ggplot2::geom_tile(color = "white") +
  ggplot2::scale_fill_gradient2(
    low = "#2166AC",
    mid = "white",
    high = "#B2182B",
    midpoint = 0,
    limits = c(-1, 1)
  ) +
  ggplot2::labs(
    title = "Correlation Heatmap of Epidemiological Variables",
    x = NULL,
    y = NULL
  ) +
  ggplot2::theme_minimal(base_size = 12) +
  ggplot2::theme(
    axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
    plot.title = ggplot2::element_text(face = "bold")
  )

ggplot2::ggsave(
  filename = file.path(output_dir, "eda_correlation_heatmap.png"),
  plot = correlation_plot,
  width = 9,
  height = 7,
  dpi = 300
)

# 3) Malaria prevalence by education years (smoothed trend)
education_plot <- malaria_data |>
  dplyr::mutate(malaria_status = as.numeric(malaria_status)) |>
  ggplot2::ggplot(ggplot2::aes(x = education_years, y = malaria_status)) +
  ggplot2::geom_jitter(
    alpha = 0.15,
    width = 0.2,
    height = 0.04,
    color = "#666666"
  ) +
  ggplot2::geom_smooth(
    method = "glm",
    method.args = list(family = "binomial"),
    se = TRUE,
    color = "#1B7837",
    fill = "#A6DBA0",
    linewidth = 1.1
  ) +
  ggplot2::scale_y_continuous(
    breaks = c(0, 0.25, 0.5, 0.75, 1),
    labels = scales::label_percent(accuracy = 1)
  ) +
  ggplot2::labs(
    title = "Estimated Malaria Probability Across Education Years",
    x = "Years of Education",
    y = "Predicted Malaria Probability"
  ) +
  ggplot2::theme_minimal(base_size = 13) +
  ggplot2::theme(plot.title = ggplot2::element_text(face = "bold"))

ggplot2::ggsave(
  filename = file.path(output_dir, "eda_malaria_vs_education.png"),
  plot = education_plot,
  width = 9,
  height = 6,
  dpi = 300
)

readr::write_csv(
  malaria_data |>
    dplyr::summarise(
      n = dplyr::n(),
      malaria_prevalence = mean(malaria_status, na.rm = TRUE)
    ),
  file.path(output_dir, "eda_quick_summary.csv")
)

message("EDA complete. Figures and summary files were saved in the outputs/ directory.")
