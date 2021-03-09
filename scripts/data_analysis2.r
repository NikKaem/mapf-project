library(tidyverse)
library(ggplot2)


df_stats <- read_csv('GitHub/mapf-project/benchmarks/stats_benchmarks.csv', na='-1')
df_random <- df_stats %>% filter(approach=='random-moves')
df_solutions <- read_csv('GitHub/mapf-project/benchmarks/solutions_benchmarks.csv', na='-1')

load_dataset <- function(csv) {
  data <- read_csv(csv) %>% mutate_all(function(x) ifelse(x<0,NA,x))
  return(data)
}
df_st14 <- load_dataset("GitHub/mapf-project/encodings/m/own-solutions/random-moves-change-time/data.csv")
df_st14 <- df_st14 %>% 
  group_by(benchmark) %>%
  summarise(average_time=mean(solution_time))

df_st1 = load_dataset("GitHub/mapf-project/encodings/m/own-solutions/random-moves/data.csv")
df_st1 <- df_st1 %>% 
  group_by(benchmark) %>%
  summarise(average_time=mean(solution_time))

df_average <- df_stats %>% 
  group_by(benchmark, approach) %>% 
  summarise(average_time=mean(solving_time)) %>% 
  mutate(normalized_time=average_time/mean(average_time))

df_average %>% 
  group_by(approach) %>%
  summarise(average_time=mean(normalized_time)) %>%
  ggplot +
  geom_bar(mapping=aes(x=approach, y=average_time, fill=factor(..x..)), stat='identity') +
  coord_flip() +
  theme(legend.position="none") +
  labs(x='average time normalized by mean')


df_winner <- df_average %>%
  group_by(benchmark) %>%
  summarise(winner=approach[which.min(average_time)]) 

df_winner %>%
  ggplot() +
  geom_bar(mapping=aes(x=winner, y=..prop.., group=2, fill=factor(..x..))) +
  coord_flip() +
  theme(legend.position="none") +
  labs(y='percentage of wins')



