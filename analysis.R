# Marketing spend → sales
# Business question: where should the next marketing dollar go?
# Two models: total spend (baseline) vs per-channel (decision-ready).

library(tidyverse)
library(tidymodels)
library(Metrics)
library(broom)
library(vip)

data("marketing", package = "datarium")

# ---------------------------------------------------------------------------
# 1. Simple model — total spend vs sales
# ---------------------------------------------------------------------------

marketing <- marketing %>%
  mutate(all_channels = youtube + facebook + newspaper)

lm_total <- lm(sales ~ all_channels, data = marketing)

# Coefficients from the fitted model (not hardcoded)
coefs_total <- coef(lm_total)
intercept <- unname(coefs_total["(Intercept)"])
slope <- unname(coefs_total["all_channels"])

# Score two budget points from the fitted line
budget_scenarios <- tibble(
  total_spend = c(0, 300),
  predicted_sales = intercept + slope * c(0, 300)
)

# Fit quality
glance_total <- glance(lm_total)
fitted_total <- augment(lm_total)

rmse_total <- Metrics::rmse(fitted_total$sales, fitted_total$.fitted)
mae_total <- Metrics::mae(fitted_total$sales, fitted_total$.fitted)

ggplot(marketing, aes(all_channels, sales)) +
  geom_point(alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE) +
  theme_bw() +
  labs(
    title = "Total marketing spend vs sales",
    x = "Total spend (all channels)",
    y = "Sales"
  )

# ---------------------------------------------------------------------------
# 2. Per-channel model — which dollar works?
# ---------------------------------------------------------------------------

set.seed(222)
marketing_split <- initial_split(marketing, prop = 0.8, strata = sales)
marketing_training <- training(marketing_split)
marketing_test <- testing(marketing_split)

lm_spec <- linear_reg() %>%
  set_engine("lm") %>%
  set_mode("regression")

lm_fit <- lm_spec %>%
  fit(sales ~ youtube + facebook + newspaper, data = marketing_training)

coefs_channel <- tidy(lm_fit)
glance_channel <- glance(lm_fit)

vip(lm_fit)

# Holdout metrics (predict on marketing_test — not a placeholder name)
marketing_test_preds <- predict(lm_fit, new_data = marketing_test) %>%
  bind_cols(marketing_test)

rmse_test <- rmse(marketing_test_preds, truth = sales, estimate = .pred)
rsq_test <- rsq(marketing_test_preds, truth = sales, estimate = .pred)

ggplot(marketing_test_preds, aes(x = .pred, y = sales)) +
  geom_point(color = "#C23B22", alpha = 0.8) +
  geom_smooth(method = "lm", se = FALSE) +
  theme_bw() +
  labs(
    title = "Holdout: predicted vs actual sales",
    x = "Predicted sales",
    y = "Actual sales"
  )

# ---------------------------------------------------------------------------
# 3. Decision summary (printable)
# ---------------------------------------------------------------------------

channel_report <- coefs_channel %>%
  filter(term != "(Intercept)") %>%
  mutate(
    per_dollar_return = estimate,
    significant = p.value < 0.05,
    read_as = case_when(
      !significant ~ "Not significant — do not trust this point estimate",
      estimate >= 0.1 ~ "Highest per-dollar return in this data",
      TRUE ~ "Real effect; weaker per dollar"
    )
  ) %>%
  select(term, per_dollar_return, p.value, significant, read_as)

cat("\n=== Budget view ===\n")
print(budget_scenarios)
cat(sprintf("\nTotal-spend model: R2 = %.3f | RMSE = %.2f | MAE = %.2f\n",
            glance_total$r.squared, rmse_total, mae_total))
cat(sprintf("Per-channel model: train R2 = %.3f | test RMSE = %.2f | test R2 = %.3f\n",
            glance_channel$r.squared, rmse_test$.estimate, rsq_test$.estimate))
cat("\n=== Channel payback ===\n")
print(channel_report)
cat("\nNote: observational data — confirm with a test/holdout before hard reallocation.\n")
