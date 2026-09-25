# load packages
library(tidyverse)
library(tidymodels) # trying out tidymodels for multiple linear regression
library(vip) # visualise feature importance

# load the data
data("marketing", package = "datarium")

glimpse(marketing)

# Rows: 200
# Columns: 4
# $ youtube   <dbl> 276.12, 53.40, 20.64, 181.80, 216.96, 10.44, 69.00, 144.24, 10.32, 239.76, 79.32, 257.64, 28.56, 117.00, 244.92, 234.48, 81.36, 337.68, 83.04, 176.76, 262.…
# $ facebook  <dbl> 45.36, 47.16, 55.08, 49.56, 12.96, 58.68, 39.36, 23.52, 2.52, 3.12, 6.96, 28.80, 42.12, 9.12, 39.48, 57.24, 43.92, 47.52, 24.60, 28.68, 33.24, 6.12, 19.08,…
# $ newspaper <dbl> 83.04, 54.12, 83.16, 70.20, 70.08, 90.00, 28.20, 13.92, 1.20, 25.44, 29.04, 4.80, 79.08, 8.64, 55.20, 63.48, 136.80, 66.96, 21.96, 22.92, 64.08, 28.20, 59.…
# $ sales     <dbl> 26.52, 12.48, 11.16, 22.20, 15.48, 8.64, 14.16, 15.84, 5.76, 12.72, 10.32, 20.88, 11.04, 11.64, 22.80, 26.88, 15.00, 29.28, 13.56, 17.52, 21.60, 15.00, 6.7…

# split the data for training and testing
# create a split & stratified by sales
set.seed(222)
marketing_split <- initial_split(marketing, prop = 0.8, strata = sales)

# <Analysis/Assess/Total>
# <159/41/200>

# create a training set
marketing_training <- marketing_split %>% 
  training(); nrow(marketing_training) # 159

# create a testing set
marketing_test <- marketing_split %>% 
  testing(); nrow(marketing_test) # 41

# model spec
lm_model <- linear_reg() %>% 
  set_engine('lm') %>%
  set_mode('regression')

# train a mode with the training set
lm_fit <- lm_model %>% 
  fit(sales ~ ., data = marketing_training)

summary(lm_fit$fit)

# Call:
# stats::lm(formula = sales ~ ., data = data)
# 
# Residuals:
#      Min       1Q   Median       3Q      Max 
# -10.5235  -1.0264   0.2994   1.3405   3.5218 
# 
# Coefficients:
#             Estimate Std. Error t value Pr(>|t|)    
# (Intercept) 3.307499   0.414648   7.977  3.1e-13 ***
# youtube     0.045537   0.001552  29.337  < 2e-16 ***
# facebook    0.190298   0.009553  19.919  < 2e-16 ***
# newspaper   0.005245   0.006465   0.811    0.418    
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 1.983 on 155 degrees of freedom
# Multiple R-squared:  0.9007,	Adjusted R-squared:  0.8988 
# F-statistic: 468.8 on 3 and 155 DF,  p-value: < 2.2e-16

# diagnostic plots
par(mfrow=c(2,2)) # plot all 4 plots in one

plot(lm_fit$fit, 
     pch = 16,    # optional parameters to make points blue
     col = '#006EA1')

# another way to get estimated coefficients etc. 
tidy(lm_fit)

  # term        estimate std.error statistic  p.value
  # <chr>          <dbl>     <dbl>     <dbl>    <dbl>
# 1 (Intercept)  3.31      0.415       7.98  3.10e-13
# 2 youtube      0.0455    0.00155    29.3   3.71e-65
# 3 facebook     0.190     0.00955    19.9   1.38e-44
# 4 newspaper    0.00524   0.00646     0.811 4.18e- 1

# Performance metrics on training data
glance(lm_fit)

# r.squared adj.r.squared sigma statistic  p.value    df logLik   AIC   BIC deviance df.residual  nobs
# <dbl>         <dbl> <dbl>     <dbl>    <dbl> <dbl>  <dbl> <dbl> <dbl>    <dbl>       <int> <int>
# 1     0.901         0.899  1.98      469. 1.71e-77     3  -332.  675.  690.     610.         155   159

# visualise feature importance
vip(lm_fit)

marketing_test_preds <- predict(lm_fit, new_data = advertising_test) %>% 
  bind_cols(advertising_test)

# View results
head(marketing_test_preds)

# .pred youtube facebook newspaper sales
# <dbl>   <dbl>    <dbl>     <dbl> <dbl>
# 1 15.2     20.6     55.1      83.2 11.2 
# 2 16.0    217.      13.0      70.1 15.5 
# 3 22.3    245.      39.5      55.2 22.8 
# 4  7.97    15.8     19.1      59.5  6.72
# 5  9.70    74.8     15.1      22.0 11.6 
# 6 17.9    171.      35.2      15.1 18   

# calculate RMSE
rmse(marketing_test_preds, 
     truth = sales,
     estimate = .pred)

# .metric .estimator .estimate
# <chr>   <chr>          <dbl>
# 1 rmse    standard        1.74

# # calculate r2
rsq(marketing_test_preds,
    truth = sales,
    estimate = .pred)

# .metric .estimator .estimate
# <chr>   <chr>          <dbl>
# 1 rsq     standard       0.925

# plot the predictions vs. sales
ggplot(marketing_test_preds, aes(x = .pred, y = sales)) +
  geom_point(color = 'red') +
  geom_smooth(method = "lm", se = FALSE) +
  theme_bw()

