library(tidyverse)
library(ggplot2)

load_dataset <- function(csv) {
  data <- read_csv(csv) %>% mutate_all(function(x) ifelse(x<0,NA,x))
  return(data)
}

# create one row for every benchmark (time = mean of measurements)
summarise_dataset <- function(tibble, string) {
  tibble <- group_by(tibble, benchmark)
  data <- summarise(tibble, time=mean(`solution-time`), robots=first(`number-of-robots`))
  names(data)[2] <- string
  return(data)
}

average_datasets <- function(df_list, name_list) {
  for (i in (1:length(df_list))) {
    df_list[[i]] <- summarise_dataset(df_list[[i]], name_list[[i]])
  }
  data <- Reduce(function(x,y) merge(x,y,all=TRUE), df_list)
  return(data)
}

merge_datasets <- function(df_list, name_list) {
  for (i in (1:length(df_list))) {
    df_list[[i]] <- select(df_list[[i]], benchmark, `solution-time`)
    df_list[[i]] <- mutate(df_list[[i]], approach=name_list[[i]])
  }
  data <- Reduce(function(x,y) rbind(x,y), df_list)
  return(data)
}

df_st1 = load_dataset("GitHub/mapf-project/encodings/m/own-solutions/random-moves/data.csv")
df_st2 = load_dataset("GitHub/mapf-project/encodings/m/own-solutions/random-moves-heuristics-1/data.csv")
df_st3 = load_dataset("GitHub/mapf-project/encodings/m/own-solutions/random-moves-heuristics-2/data.csv")
df_st4 = load_dataset("GitHub/mapf-project/encodings/m/own-solutions/random-moves-heuristics-3/data.csv")
df_st5 = load_dataset("GitHub/mapf-project/encodings/m/own-solutions/random-moves-heuristics-4/data.csv")
df_st6 = load_dataset("GitHub/mapf-project/encodings/m/own-solutions/random-moves-heuristics-5/data.csv")
df_st7 = load_dataset("GitHub/mapf-project/encodings/m/own-solutions/iterative-conflict-resolution/data.csv")
df_st8 = load_dataset("GitHub/mapf-project/encodings/m/own-solutions/constraint-learning/data.csv")
df_st9 = load_dataset("GitHub/mapf-project/encodings/m/own-solutions/constraint-learning-change-time/data.csv")
df_st10 = load_dataset("GitHub/mapf-project/encodings/m/own-solutions/constraint-learning-global-conflict/data.csv")
df_st11 = load_dataset("GitHub/mapf-project/encodings/m/own-solutions/constraint-learning-heuristics/data.csv")
df_st12 = load_dataset("GitHub/mapf-project/encodings/m/own-solutions/random-moves-global-conflict/data.csv")
df_st13 = load_dataset("GitHub/mapf-project/encodings/m/own-solutions/random-moves-specific-conflict/data.csv")
df_st14 = load_dataset("GitHub/mapf-project/encodings/m/own-solutions/random-moves-change-time/data.csv")

df_list <- list(df_st1, df_st2, df_st3, df_st4, df_st5, df_st6, df_st7, df_st8, df_st9, df_st10, 
                df_st11, df_st12, df_st13, df_st14)

name_list <- list('random_moves', 'random_moves_heur1', 'random_moves_heur2', 'random_moves_heur3', 
                  'random_moves_heur4', 'random_moves_heur5', 'iterative_res', 'constraint', 
                  'constraint_change_time', 'constraint_glob_conf', 'constraint_heur', 
                  'random_moves_glob_conf','random_moves_spec_conf','random_moves_change_time')

df_average <- average_datasets(df_list, name_list)
data <- mutate(df_average, winner=colnames(select(df_average, -c(benchmark, robots)))[apply(select(df_average, -c(benchmark, robots)), 1, which.min)])

df_merged <- merge_datasets(df_list, name_list)
test <- filter(df_merged, benchmark=='benchmark-27')


# distribution of solution times per benchmark
ggplot(test, aes(x=approach, y=`solution-time`)) +
  geom_boxplot() +
  coord_flip() +
  facet_wrap(~benchmark, nrow=5)

# winning percentage per roboter count
data %>%
  group_by(robots) %>%
  mutate(count=n()) %>%
  ungroup() %>%
  mutate(robots_new=paste0(robots,' (n=', count, ')')) %>%
  ggplot() + 
    geom_bar(mapping=aes(x=winner, y=..prop.., group=2, fill=factor(..x..))) +
    coord_flip() +
    facet_wrap(~robots_new, nrow=3) +
    theme(legend.position="none") + 
    labs(y='percentage of wins')

# winning percentage overall
ggplot(data) +
  geom_bar(mapping=aes(x=winner, y=..prop.., group=2, fill=factor(..x..))) +
  coord_flip() +
  theme(legend.position="none") 





