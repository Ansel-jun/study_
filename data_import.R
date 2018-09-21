## 패키지 설치
install.packages('data.table')
install.packages('xgboost')
install.packages('tidyverse')
install.packages('DataExplorer')
install.packages('ggthemes')
install.packages('httr')
install.packages('rvest')
install.packages('xml2')
install.packages('devtools')
install.packages('jsonlite')
install.packages('rlist')
install.packages('doSNOW')
install.packages('foreach')


## 패키지 로딩
library(data.table)
library(devtools)
library(tidyverse) # metapackage with lots of helpful functions
library(jsonlite)
library(rlist)
library(doSNOW)
library(foreach) 

## 데이터 로딩
train <- read_csv('~/R/data/train.csv')
test <- read_csv('~/R/data/test.csv')

## 데이터 구조 살펴보기
str(train)
str(test)

## https://www.kaggle.com/mrlong/r-flatten-json-columns-to-make-single-data-frame

jsontodf <- function(col) {
  cores <- 4
  cl<-makeCluster(cores)
  registerDoSNOW(cl)
  nr <- length(col)
  chunk <- floor(nr/cores)
  s <- rep(1:cores, each = chunk)
  s <- c(s, rep(cores,nr-length(s)))
  for(i in 1:cores) {
    col.core <- col[s==i]
    clusterExport(cl[i], 'col.core', envir = environment())
  }
  col.df <- foreach(i=1:cores, .combine = 'bind_rows', .noexport = 'col.core', .packages = c('jsonlite', 'rlist', 'magrittr')) %dopar% {
    paste("[", paste(col.core, collapse = ","), "]") %>% fromJSON(flatten = TRUE)
  }
  stopCluster(cl)
  return(as.data.frame(col.df))
}

## 데이터 변환
# train data
train$date <- as.character(train$date)
train$visitId <- as.character(train$visitId)

tr_device <- jsontodf(train$device)
tr_geoNetwork <- jsontodf(train$geoNetwork)
tr_totals <- jsontodf(train$totals)
tr_trafficSource <- jsontodf(train$trafficSource)

train <- select(train, -c('device', 'geoNetwork', 'totals', 'trafficSource'))
train <- bind_cols(train, tr_device, tr_geoNetwork, tr_totals, tr_trafficSource)

# test data
test$date <- as.character(test$date)
test$visitId <- as.character(test$visitId)

te_device <- jsontodf(test$device)
te_geoNetwork <- jsontodf(test$geoNetwork)
te_totals <- jsontodf(test$totals)
te_trafficSource <- jsontodf(test$trafficSource)

test <- select(test, -c('device', 'geoNetwork', 'totals', 'trafficSource'))
test <- bind_cols(test, te_device, te_geoNetwork, te_totals, te_trafficSource)

## rm(te_device, te_geoNetwork, te_totals, te_trafficSource)

colnames(train)[!colnames(train) %in% colnames(test)]

## 분석용 데이터 저장
write_csv(train, '~/R/data/train_mart.csv')
write_csv(test, '~/R/data/test_mart.csv')
