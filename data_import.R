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


## 패키지 로딩
library(data.table)
library(devtools)
library(tidyverse) # metapackage with lots of helpful functions
library(jsonlite)
library(rlist)

#for fast EDA
library(DataExplorer) 
library(ggthemes)

## 데이터 로딩
train <- read_csv('~/R/data/train.csv')
test <- read_csv('~/R/data/test.csv')

## 데이터 구조 살펴보기
str(train)
str(test)

#Courtesy: https://www.kaggle.com/mrlong/r-flatten-json-columns
#Courtesy: https://www.kaggle.com/mrlong/r-flatten-json-columns#387132

jsontodf <- function(col){
  list.stack(lapply(col, function(j){
    as.list(unlist(fromJSON(j)))}) , fill=TRUE)   
}



#Convert each JSON column in the train and test sets
tr_device <- jsontodf(train$device)
tr_geoNetwork <- jsontodf(train$geoNetwork)
tr_totals <- jsontodf(train$totals)
tr_trafficSource <- jsontodf(train$trafficSource)

te_device <- jsontodf(test$device)
te_geoNetwork <- jsontodf(test$geoNetwork)
te_totals <- jsontodf(test$totals)
te_trafficSource <- jsontodf(test$trafficSource)


#Check to see if the training and test sets have the same column names
setequal(names(tr_device), names(te_device))
setequal(names(tr_geoNetwork), names(te_geoNetwork))
setequal(names(tr_totals), names(te_totals))
setequal(names(tr_trafficSource), names(te_trafficSource))

#As expected, all are equal except for the totals - which includes the target, transactionRevenue
#Clearly this should only appear in the training set
names(tr_totals)
names(te_totals)
#transactionRevenue is the only different column here


#Combine to make the full training and test sets
train <- train %>%
  cbind(tr_device, tr_geoNetwork, tr_totals, tr_trafficSource) %>%
  select(-device, -geoNetwork, -totals, -trafficSource)

test <- test %>%
  cbind(te_device, te_geoNetwork, te_totals, te_trafficSource) %>%
  select(-device, -geoNetwork, -totals, -trafficSource)








