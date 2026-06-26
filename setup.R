#!/usr/bin/env Rscript
packages <- c("broom", "datarium", "Metrics", "tidymodels", "tidyverse", "vip")
install.packages(packages[!packages %in% installed.packages()[,"Package"]])
