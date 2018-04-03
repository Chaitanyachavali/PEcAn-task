library(ISLR)
library(Hmisc)

# Reading the file
data_raw = read.delim("/home/chaitanya/Documents/Github/PEcAn/data/GlobalLandTemperaturesByCountry.csv",sep=',')
data = subset(data_raw, data_raw$Country == "India")
dim(data)
des <- describe(data)

# Missing values are greatest problem while visualization of data. So eliminating before going any further.
# Finding the total number of missing values
sum(is.na(data))

# Removing all the missing values
data_train = na.omit(data)

# checking whether all missing values are been removed or been
sum(is.na(data_train))
dim(data_train)

# Getting all column names from the given data.
names(data_train)[1]="date"
colnames(data_train)

mod1=lm(AverageTemperature~.,data=data_train)
mod1
summary(mod1)