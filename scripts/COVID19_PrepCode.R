#Name: Jon (me)
#Purpose: COVID19 Project
#Last Update: 10/15/20
#-------------------------------------#
covid19 <- read.csv("https://covid19.who.int/WHO-COVID-19-global-data.csv")
dim(covid19)
#69325    8
colnames(covid19)
head(covid19)
tail(covid19)
length(unique(covid19$Country_code))
length(unique(covid19$Country))
table(covid19$WHO_region)

class(covid19$Date_reported)

covid19$Date <- as.Date(covid19$Date_reported)
class(covid19$Date)
range(covid19$Date)


head(covid19)
range(covid19$New_cases)
range(covid19$Cumulative_cases)
range(covid19$New_deaths)
range(covid19$Cumulative_deaths)




us=covid19[covid19$Country=="United States of America",]
dim(us)
#295    9

nz=covid19[covid19$Country=="New Zealand",]

plot(us$Date,us$Cumulative_cases,type='l')
plot(us$Date,us$New_cases,type='l')
plot(us$Date,us$New_deaths,type='l')
plot(us$Date,us$Cumulative_deaths,type='l')

plot(nz$Date,nz$Cumulative_cases,type='l')
plot(nz$Date,nz$New_cases,type='l')
plot(nz$Date,nz$New_deaths,type='l')
plot(nz$Date,nz$Cumulative_deaths,type='l')



pops <- read.csv("https://gist.githubusercontent.com/curran/0ac4077c7fc6390f5dd33bf5c06cb5ff/raw/605c54080c7a93a417a3cea93fd52e7550e76500/UN_Population_2019.csv")
cols=colnames(pops)

pop_data=pops[,c(cols[1],cols[length(cols)])]


colnames(pop_data)=c("Country","Population")
pop_data$Population=pop_data$Population*1000
dim(pop_data)

min(covid19_data$Date)+1


download.file("http://thematicmapping.org/downloads/TM_WORLD_BORDERS_SIMPL-0.3.zip", destfile="world_shape_file.zip")
unzip("world_shape_file.zip")
world_spdf=readOGR(dsn = getwd(),layer = "TM_WORLD_BORDERS_SIMPL-0.3")
names(world_spdf)[names(world_spdf) == "NAME"] <- "Country"
world_spdf


missingpops=unique(covid19_data[is.na(covid19_data$Population)==TRUE,"Country"])
missingpops

testdata=subset(covid19,covid19$Date_reported==max(covid19$Date_reported))

map_data=merge(x=world_spdf,y=testdata,by="Country",all.x=TRUE)
dim(world_spdf)
#246    11
dim(testdata)
#235    9
dim(map_data)
#246    19

table(who_data$WHO_region)

#[1] "Côte d’Ivoire"   - there                                        
#[2] "Democratic People's Republic of Korea"       - there            
#[3] "Guernsey"                                                
#[4] "Jersey"                                                  
#[5] "Kosovo[1]"                                               
#[6] "Micronesia (Federated States of)"                        
#[7] "Northern Mariana Islands (Commonwealth of the)"          
#[8] "occupied Palestinian territory, including east Jerusalem" - there
#[9] "Other"                                                   
#[10] "Pitcairn Islands"                                        
#[11] "Saint Martin"                                            
#[12] "Sint Maarten"                                            
#[13] "The United Kingdom"                                      
#[14] "Wallis and Futuna"




#Top 10 Countries
top10who=covid19[c(3,1,6,8)]
top10who

OCT31=subset(top10who,top10who$Date_reported=="2020-10-31")
sorted <- OCT31[order(OCT31$Cumulative_cases,decreasing = TRUE),]
dim(sorted)
sorted=sorted[1:15,]
p<-ggplot(sorted,aes(x=reorder(Country,-Cumulative_cases),y=Cumulative_cases,fill=reorder(Country,-Cumulative_cases)))+
  geom_bar(stat="identity")
p

head(covid19)
test=subset(covid19,(covid19$Date_reported<=max(covid19$Date_reported)) & covid19$Date_reported>=max(as.Date(covid19$Date_reported))-13)
dim(test)

a=max(covid19$Date_reported)
a=as.Date(a)
b=a-14

head(test)
#Sum up by country
test$SumNewCases <- with(test,ave(New_cases,Country,FUN=sum))
test$SumNewDeaths <- with(test,ave(New_deaths,Country,FUN=sum))

head(test)
#Order by Metric
test_sorted <- test[order(test$SumNewCases,decreasing = TRUE),]
final=test_sorted[1:140,]


#----- Time Series -----#
us=covid19[covid19$Country=="United States of America",]
nz=covid19[covid19$Country=="New Zealand",]
fr=covid19[covid19$Country=="France",]



myts=ts(fr$New_cases,frequency = 7)
plot(myts)
#install.packages("forecast")
library(forecast)
fit=ets(myts)
fc <- forecast(fit,h=50)
plot(fc)


#----- Tooltips -----#


data <- data.frame(cbind(rnorm(10, 8), rnorm(10, 2)))
names(data) <- c("thing1", "thing2")

data$hovertext <- paste("here's a coordinate:",
                        round(data$thing1,1), sep = "<br>")


p <- plot_ly(data, type = 'scatter', x = ~thing1, y = ~thing2, 
             text = ~hovertext, hoverinfo = 'text', mode = "markers")
p
