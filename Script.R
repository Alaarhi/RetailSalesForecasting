#Alaa Riahi's Project : 
#upload datasets
features_data_set <- read.csv2(" <base path> /Retail Sales Forecasting/Features data set.csv", header = TRUE, sep = ",")
sales_data_set <- read.csv2(" <base path> /Retail Sales Forecasting/sales data-set.csv", header = TRUE, sep = ",")
stores_data_set <- read.csv2(" <base path> /Retail Sales Forecasting/stores data-set.csv", header = TRUE, sep = ",")

#Data Converting
library(lubridate)
features_data_set$Year <- substr(features_data_set$Date, 7, 10)
features_data_set$Month <- substr(features_data_set$Date, 4, 5)
features_data_set$Day <- substr(features_data_set$Date, 1, 2)

sales_data_set$Year <- substr(sales_data_set$Date, 7, 10)
sales_data_set$Month <- substr(sales_data_set$Date, 4, 5)
sales_data_set$Day <- substr(sales_data_set$Date, 1, 2)

sales_data_set$Weekly_Sales <- as.character(sales_data_set$Weekly_Sales)
sales_data_set$Weekly_Sales <- as.numeric(sales_data_set$Weekly_Sales,2)

#Pick the store 1 with dept 1 
features_1 <- features_data_set[features_data_set$Store==1,]
sales_1 <- sales_data_set[sales_data_set$Store==1 & sales_data_set$Dept==1,]
stores_1 <- stores_data_set[stores_data_set$Store==1,]

str(features_1)
str(sales_1)
str(stores_1)

#Sales of the deparments in 3 years
YearSales <- sales_1 %>% group_by(Year,Dept) %>% summarise(YearSales = sum(Weekly_Sales)) %>% arrange(desc(YearSales))

ggplot(head(YearSales, 60), aes(Year, YearSales)) +
  geom_col() + facet_wrap(~Dept)

#Merging the 3 Datasets 
base_1 <- merge(sales_1, features_1, by.sales_1="store", by.features_1="store", by.sales_1="Date", by.features_1="Date",                by.sales_1="isHoliday", by.features_1="isHoliday")
base <- merge(stores_1, base_1, by.stores_1="store", by.base_1="store")
View(base)

#Encoding of the feauture IsHoliday : 
base$IsHoliday<-as.integer(base$IsHoliday)

#Remplace missing values with 0
base[is.na(base)]<-0

#creating a new feauture called Week of the Year 
#( since we are working with weekly sales we need to know what week we are in)
library(lubridate)
my_week <- function(x){
  (yday(x)-1)%/%7+1
}
base$DateW<-week(as.POSIXct(base$Date))

#Building correlation matrix :
library(corrplot)
selectcol <- base %>% select(  CPI ,Unemployment ,Fuel_Price, Weekly_Sales, Temperature,DateW,
                               MarkDown1,MarkDown2,MarkDown3,MarkDown3,MarkDown4,MarkDown5,IsHoliday)
selectcol$CPI <- as.numeric(as.character(selectcol$CPI))
selectcol$Unemployment <- as.numeric(as.character(selectcol$Unemployment))
selectcol$Fuel_Price <- as.numeric(as.character(selectcol$Fuel_Price))
selectcol$Weekly_Sales <- as.numeric(as.character(selectcol$Weekly_Sales))
selectcol$Temperature <- as.numeric(as.character(selectcol$Temperature))
selectcol$DateW <- as.numeric(as.character(selectcol$DateW))
selectcol$MarkDown1 <- as.numeric(as.character(selectcol$MarkDown1))
selectcol$MarkDown2 <- as.numeric(as.character(selectcol$MarkDown2))
selectcol$MarkDown3 <- as.numeric(as.character(selectcol$MarkDown3))
selectcol$MarkDown4 <- as.numeric(as.character(selectcol$MarkDown4))
selectcol$MarkDown5 <- as.numeric(as.character(selectcol$MarkDown5))

matrixdata <- as.matrix(selectcol)

corrplot(cor(selectcol) ,method = "circle")

#Visualising Data
library(ggplot2)
ggplot(base, aes(x = DateW, y =Weekly_Sales , fill = IsHoliday)) +
  geom_point(size = 2, shape = 23, color = "#4ABEFF")

ggplot(base, aes(x =Fuel_Price , y =Weekly_Sales, fill = DateW )) +
  geom_point(size = 2, shape = 23, color = "#4ABEFF")

ggplot(base, aes(x =Temperature , y =Weekly_Sales, fill = DateW )) +
  geom_point(size = 2, shape = 23, color = "#4ABEFF")

ggplot(base, aes(x =CPI , y =Weekly_Sales, fill = DateW )) +
  geom_point(size = 2, shape = 23, color = "#4ABEFF")

ggplot(base, aes(x =Unemployment , y =Weekly_Sales, fill = DateW )) +
  geom_point(size = 2, shape = 23, color = "#4ABEFF")

plot(ts(base$Weekly_Sales))


# dividing data into train and test set 
train_set=base[base$Year<2012,]
summary(train_set)
test_set=base[base$Year>2011,]

library(lattice)
library(caret)

#Building Model
custom<-trainControl(method="repeatedcv",
                     number=10,
                     repeats=5,
                     verboseIter=T)
set.seed(50)

lm<-train(Weekly_Sales ~DateW+MarkDown1+MarkDown2+MarkDown3+MarkDown5+CPI+IsHoliday,
          data = train_set,
          method='lm',
          trControl=custom,
          tuneLength=5,
          na.action = na.exclude)

lm$results
summary(lm)
plot(lm$finalModel)


#Testing Phase 
predict(lm,newdata=test_set)
predicted1<-predict(lm,newdata=test_set)

library(Metrics)
mae(actual=test_set$Weekly_Sales,predicted = predicted1 )

rmse(actual=test_set$Weekly_Sales,predicted = predicted1)

compare <- cbind (actual=test_set$Weekly_Sales, predicted1)
View(compare)

#Extra Work : PCA : 
selectcolpca <- base %>% select( Size, CPI ,Unemployment ,Fuel_Price, Weekly_Sales, Temperature)

selectcolpca$CPI <- as.numeric(as.character(selectcolpca$CPI))
selectcolpca$Unemployment <- as.numeric(as.character(selectcolpca$Unemployment))
selectcolpca$Fuel_Price <- as.numeric(as.character(selectcolpca$Fuel_Price))
selectcolpca$Weekly_Sales <- as.numeric(as.character(selectcolpca$Weekly_Sales))
selectcolpca$Temperature <- as.numeric(as.character(selectcolpca$Temperature))

prout <- prcomp(selectcolpca)
prvar <- prout$sdev^2
pve <- prvar / sum(prvar)

plot(pve, xlab = "Principal Component",
     ylab = "Proportion of Variance Explained",
     ylim = c(0, 1), type = "b")

plot(cumsum(pve), xlab = "Principal Component",
     ylab = "Cumulative Proportion of Variance Explained",
     ylim = c(0, 1), type = "b")

