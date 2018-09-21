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

## 패키지 로딩
library(data.table)
library(devtools)
library(tidyverse) # metapackage with lots of helpful functions
#for fast EDA
library(DataExplorer) 
library(ggthemes)

## 데이터 로딩
train <- read_csv('~/R/data/train.csv')
test <- read_csv('~/R/data/test.csv')

## 데이터 구조 살펴보기
str(train)
str(test)







