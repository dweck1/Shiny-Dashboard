library(tidyverse)
library(teamcolors)
library(plotly)
library(png)

#Static code to load data
all_data <- read_csv('NFL_Data.csv')
colors <- read_csv('nfl_colors.csv')

added_colors <- left_join(all_data, colors, by = 'name')
NFL_2019 <- filter(added_colors, year == 2019)
NFL <- filter(added_colors, year != 2019)

x_vars <- NFL[, 5:42]
y_var <- (NFL[, 4])
x_preds <- NFL_2019[, c(1, 5:42)]

NFL_df <- cbind(x_vars, y_var)
NFL_pred_df <- cbind(NFL_2019[, 5:42], NFL_2019[, 4])

offensive_vars <- select(x_vars, -starts_with('opp'))
off_df <- cbind(offensive_vars, y_var)

defensive_Vars <- select(x_vars, starts_with('opp'))
def_df <- cbind(defensive_Vars, y_var)

