haspkg <- require(dplyr)
if( haspkg == FALSE ){
  install.packages('dplyr')
  require(dplyr)
}

DomoR::init('DOMO CUSTOMER URL', 'DEV TOKEN')

#download data from domo datasource
x <- DomoR::fetch('8737a632-9842-4366-803e-52d50964e1dd')

#add predictor variables
x$date <- as.Date(x$date)
x$year <- as.numeric(format(x$date,'%Y'))
x$month <- format(x$date,'M%m')
x$dom <- format(x$date,"DW%u")


#run model and print results to console
x.lm <- lm(sales ~ date,data=x,contrasts=NULL)
#summary(x.lm)

predict(x.lm,x)

#create string of dates for forecasts
last_day <- as.Date(format(seq(from=max(x$date),by='month',length.out=2),'%Y-%m-01'))[2] - 1
new_values <- data.frame(date=seq(from=min(x$date),to=last_day,by='day'))
new_values$year <- as.numeric(format(new_values$date,'%Y'))
new_values$month <- format(new_values$date,'M%m')
new_values$dom <- format(new_values$date,"DW%u")

#add forecast to new_values
new_values$forecasts <- predict(x.lm,new_values)

#merge new_values with x and only keep date, sales and forecast data
final <- select(merge(new_values,x,by=c('date'),all.x=TRUE),date,sales,forecasts)


DomoR::create(final,name='Sales with prediction',description='From RStudio')

