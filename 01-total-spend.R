# load packages
library(tidyverse)
library(Metrics)
data("marketing", package = "datarium")

glimpse(marketing)

# Rows: 200
# Columns: 4
# $ youtube   <dbl> 276.12, 53.40, 20.64, 181.80, 216.96, 10.44, 69.00, 144.24, 10.32, 239.76, 79.32, 257.64, 28.56, 117.00, 244.9…
# $ facebook  <dbl> 45.36, 47.16, 55.08, 49.56, 12.96, 58.68, 39.36, 23.52, 2.52, 3.12, 6.96, 28.80, 42.12, 9.12, 39.48, 57.24, 43…
# $ newspaper <dbl> 83.04, 54.12, 83.16, 70.20, 70.08, 90.00, 28.20, 13.92, 1.20, 25.44, 29.04, 4.80, 79.08, 8.64, 55.20, 63.48, 1…
# $ sales     <dbl> 26.52, 12.48, 11.16, 22.20, 15.48, 8.64, 14.16, 15.84, 5.76, 12.72, 10.32, 20.88, 11.04, 11.64, 22.80, 26.88, …

head(marketing)

# youtube facebook newspaper sales
# 1  276.12    45.36     83.04 26.52
# 2   53.40    47.16     54.12 12.48
# 3   20.64    55.08     83.16 11.16
# 4  181.80    49.56     70.20 22.20
# 5  216.96    12.96     70.08 15.48
# 6   10.44    58.68     90.00  8.64

summary(marketing)

# youtube          facebook       newspaper          sales      
# Min.   :  0.84   Min.   : 0.00   Min.   :  0.36   Min.   : 1.92  
# 1st Qu.: 89.25   1st Qu.:11.97   1st Qu.: 15.30   1st Qu.:12.45  
# Median :179.70   Median :27.48   Median : 30.90   Median :15.48  
# Mean   :176.45   Mean   :27.92   Mean   : 36.66   Mean   :16.83  
# 3rd Qu.:262.59   3rd Qu.:43.83   3rd Qu.: 54.12   3rd Qu.:20.88  
# Max.   :355.68   Max.   :59.52   Max.   :136.80   Max.   :32.40  

# feature engineering
# create a new feature for all channels by adding all marketing $
marketing$all_channels <- rowSums(marketing[,1:3])

# plot a scatter plot with lm
ggplot(marketing, aes(sales, all_channels)) +
  geom_point() +
  geom_smooth(method = "lm", se = F) 
  
# run a cor
cor(marketing$sales, marketing$all_channels) # 0.8677123

# create a lm model
lm.model <- lm(sales ~ all_channels, marketing)

lm.model

# Call:
# lm(formula = sales ~ all_channels, data = marketing)
# 
# Coefficients:
# (Intercept)  all_channels  
# 5.09163       0.04869  

# the formula
# predicted = intercept + coefficient * unseen value
intercept <- 5.09163
coefficient <- 0.04869
unseen_value <- 0

intercept + coefficient * unseen_value 
# with zero investment in marketing, the predicted sales = 5.09163

intercept <- 5.09163
coefficient <- 0.04869
unseen_value <- 300
intercept + coefficient * unseen_value 
# with $300 investment in marketing, the predicted sales = 19.69863

# evaluation metrics
# R Square/Adjusted R Square.
# Mean Square Error(MSE)/Root Mean Square Error(RMSE)
# Mean Absolute Error(MAE)

summary(lm.model)

# Call:
# lm(formula = sales ~ all_channels, data = marketing)
# 
# Residuals:
# Min      1Q  Median      3Q     Max
# -9.6655 -1.5685  0.1408  1.9153  8.6274
# 
# Coefficients:
# Estimate Std. Error t value Pr(>|t|)
# (Intercept)  5.091634   0.526230   9.676   <2e-16 ***
# all_channels 0.048688   0.001982  24.564   <2e-16 ***
# ---
# Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
# 
# Residual standard error: 3.12 on 198 degrees of freedom
# Multiple R-squared:  0.7529,	Adjusted R-squared:  0.7517
# F-statistic: 603.4 on 1 and 198 DF,  p-value: < 2.2e-16

library(broom) # this is cool to show all evaluation metrics in a dataframe
glance(lm.model)

# r.squared adj.r.squared sigma statistic  p.value    df logLik   AIC   BIC deviance df.residual  nobs
# 0.753         0.752     3.12      603. 5.06e-62     1  -510. 1027. 1037.    1927.         198   200

# around 75% of dependent variability can be explained by the model which is not bad

# confidence intervals
confint(lm.model)
#                   2.5 %     97.5 %
# (Intercept)  4.05389878 6.12936894
# all_channels 0.04477913 0.05259663

# Get the observation-level elements of the model
metrics <- augment(lm.model)

metrics

# sales all_channels .fitted  .resid    .hat .sigma     .cooksd .std.resid
# <dbl>        <dbl>   <dbl>   <dbl>   <dbl>  <dbl>       <dbl>      <dbl>
# 1 26.5         405.    24.8   1.73   0.0158    3.13 0.00251        0.560  
# 2 12.5         155.    12.6  -0.143  0.00801   3.13 0.00000851    -0.0459 
# 3 11.2         159.    12.8  -1.67   0.00772   3.13 0.00112       -0.536  
# 4 22.2         302.    19.8   2.43   0.00648   3.12 0.00198        0.780  
# 5 15.5         300     19.7  -4.22   0.00640   3.11 0.00593       -1.36   
# 6  8.64        159.    12.8  -4.20   0.00771   3.11 0.00709       -1.35   
# 7 14.2         137.    11.7   2.42   0.00941   3.12 0.00288        0.779  
# 8 15.8         182.    13.9   1.90   0.00642   3.12 0.00121        0.612  
# 9  5.76         14.0    5.78 -0.0152 0.0258    3.13 0.000000323   -0.00494
# 10 12.7         268.    18.2  -5.44   0.00530   3.10 0.00813       -1.75   
# # … with 190 more rows

# RMSE
# calculate by hand
sqrt(mean((metrics$sales - metrics$.fitted)^2))
# 3.104319

# calculate with a package
Metrics::rmse(metrics$sales, metrics$.fitted)
# 3.104319

# MSE
mean((metrics$sales - metrics$.fitted)^2)
# 9.636797

Metrics::mse(metrics$sales, metrics$.fitted)
# 9.636797

# MAE
Metrics::mae(metrics$sales, metrics$.fitted)
# 2.340457

# commonly used metrics for linear regression
# https://towardsdatascience.com/what-are-the-best-metrics-to-evaluate-your-regression-model-418ca481755b


