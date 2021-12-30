# COVID19 R Shiny App - 11.13.2020
#----------------------------------#
#library(httr)
#library(pkgconfig)
#set_config(use_proxy(url="127.0.0.1",port=0000))


#Read in datasets
who_data <- read.csv("https://covid19.who.int/WHO-COVID-19-global-data.csv")
pops <- read.csv("https://gist.githubusercontent.com/curran/0ac4077c7fc6390f5dd33bf5c06cb5ff/raw/605c54080c7a93a417a3cea93fd52e7550e76500/UN_Population_2019.csv")


download.file("http://thematicmapping.org/downloads/TM_WORLD_BORDERS_SIMPL-0.3.zip", destfile="world_shape_file.zip")
unzip("world_shape_file.zip")
world_spdf=sf::st_read(dsn = getwd(),layer = "TM_WORLD_BORDERS_SIMPL-0.3")



#-----Preprocessing Data-----#
MetricChoices=c("New_cases","Cumulative_cases","New_deaths","Cumulative_deaths","Death_Rate")
MetricChoices2=c("Cumulative_cases","Cumulative_deaths")
who_data$Date <- as.Date(who_data$Date_reported)


cols=colnames(pops)
pop_data=pops[,c(cols[1],cols[length(cols)])]
colnames(pop_data)=c("Country","Population")
pop_data$Population=pop_data$Population*1000

pop_data[order(pop_data$Country),]


covid19_data=merge(x=who_data,y=pop_data,by="Country",all.x=TRUE)


covid19_data$Date_reported=NULL
covid19_data$Country_code=NULL
covid19_data=covid19_data[order(covid19_data$Country,covid19_data$Date),]
covid19_data=covid19_data[c(1,7,8,3,4,5,6)]

covid19_data=subset(covid19_data,covid19_data$Country!="Other")




#Change names of countries --> need to match the pops data

#1.) United States
covid19_data$Country=ifelse(covid19_data$Country =="United States of America","United States",covid19_data$Country)
#2.) Bolivia
covid19_data$Country=ifelse(covid19_data$Country =="Bolivia (Plurinational State of)","Bolivia",covid19_data$Country)

#3.) Russia
covid19_data$Country=ifelse(covid19_data$Country =="Russian Federation","Russia",covid19_data$Country)

#4.) Venezuela
covid19_data$Country=ifelse(covid19_data$Country =="Venezuela (Bolivarian Republic of)","Venezuela",covid19_data$Country)

#5.) United Kingdom
covid19_data$Country=ifelse(covid19_data$Country =="The United Kingdom","United Kingdom",covid19_data$Country)

#6.) Czech Republic
covid19_data$Country=ifelse(covid19_data$Country =="Czechia","Czech Republic",covid19_data$Country)

#7.) Cote D'Ivoire
world_spdf$NAME=ifelse(world_spdf$NAME=="Cote d'Ivoire","Côte d’Ivoire",world_spdf$NAME)

#8.) Libyan Arab Jamahiriya
world_spdf$NAME=ifelse(world_spdf$NAME=="Libyan Arab Jamahiriya","Libya",world_spdf$NAME)

#9.) Burma
world_spdf$NAME=ifelse(world_spdf$NAME=="Burma","Myanmar",world_spdf$NAME)

#10.) Korea, Democratic People's Republic Of
covid19_data$Country=ifelse(covid19_data$Country =="Democratic People's Republic of Korea","North Korea",covid19_data$Country)
world_spdf$NAME=ifelse(world_spdf$NAME=="Korea, Democratic People's Republic of","North Korea",world_spdf$NAME)


#11.) Korea, Republic of
#covid19_data$Country=ifelse(covid19_data$Country =="Korea, Republic of","South Korea",covid19_data$Country)
covid19_data$Country=ifelse(covid19_data$Country =="Republic of Korea","South Korea",covid19_data$Country)
world_spdf$NAME=ifelse(world_spdf$NAME=="Korea, Republic of","South Korea",world_spdf$NAME)


#12.) The Formula Yugoslav Republic of Macedonia
world_spdf$NAME=ifelse(world_spdf$NAME=="The former Yugoslav Republic of Macedonia","North Macedonia",world_spdf$NAME)

#13.) Svalbard --> Norway
#world_spdf$NAME=ifelse(world_spdf$NAME=="Svalbard","Norway",world_spdf$NAME)

#14.) Kosovo[1] --> Kosovo
covid19_data$Country=ifelse(covid19_data$Country =="Kosovo[1]","Kosovo",covid19_data$Country)

#15.) Micronesia (Federated States of)
world_spdf$NAME=ifelse(world_spdf$NAME=="Micronesia, Federated States of","Federated States of Micronesia",world_spdf$NAME)
covid19_data$Country=ifelse(covid19_data$Country =="Micronesia (Federated States of)","Federated States of Micronesia",covid19_data$Country)

#16.) The United Kingdom
world_spdf$NAME=ifelse(world_spdf$NAME=="The United Kingdom","United Kingdom",world_spdf$NAME)

#17.) Northern Mariana Island
covid19_data$Country=ifelse(covid19_data$Country =="Northern Mariana Islands (Commonwealth of the)","Northern Mariana Islands",covid19_data$Country)

#18.) Palestine
covid19_data$Country=ifelse(covid19_data$Country =="occupied Palestinian territory, including east Jerusalem","Palestine",covid19_data$Country)
#19.) Wallis and Futuna
covid19_data$Country=ifelse(covid19_data$Country =="Wallis and Futuna Islands","Wallis and Futuna",covid19_data$Country)

#20.) Iran
world_spdf$NAME=ifelse(world_spdf$NAME=="Iran (Islamic Republic of)","Iran",world_spdf$NAME)
covid19_data$Country=ifelse(covid19_data$Country =="Iran (Islamic Republic of)","Iran",covid19_data$Country)



#--------------------- Fix Populations --------------------- #
#[1] "Côte d’Ivoire"       
covid19_data$Population=ifelse(covid19_data$Country=="Côte d’Ivoire",26378000,covid19_data$Population)
#[2] "Democratic People's Republic of Korea"    
covid19_data$Population=ifelse(covid19_data$Country=="North Korea",25779000,covid19_data$Population)
#[3] "Guernsey"     
covid19_data$Population=ifelse(covid19_data$Country=="Guernsey",62792,covid19_data$Population)
#[4] "Jersey"       
covid19_data$Population=ifelse(covid19_data$Country=="Jersey",107800,covid19_data$Population)
#[5] "Kosovo[1]"      
covid19_data$Population=ifelse(covid19_data$Country=="Kosovo",1873160,covid19_data$Population)
#[6] "Micronesia (Federated States of)"          
covid19_data$Population=ifelse(covid19_data$Country=="Federated States of Micronesia",104468,covid19_data$Population)

#[7] "Northern Mariana Islands (Commonwealth of the)"      
covid19_data$Population=ifelse(covid19_data$Country=="Northern Mariana Islands",58000,covid19_data$Population)

#[8] "occupied Palestinian territory, including east Jerusalem"
covid19_data$Population=ifelse(covid19_data$Country=="Palestine",5101000,covid19_data$Population)

#[10] "Pitcairn Islands"     
covid19_data$Population=ifelse(covid19_data$Country=="Pitcairn Islands",50,covid19_data$Population)

#[11] "Saint Martin"   
covid19_data$Population=ifelse(covid19_data$Country=="Saint Martin",39000,covid19_data$Population)

#[12] "Sint Maarten"      
covid19_data$Population=ifelse(covid19_data$Country=="Sint Maarten",43000,covid19_data$Population)

#[13] "The United Kingdom"  
covid19_data$Population=ifelse(covid19_data$Country=="United Kingdom",67886000,covid19_data$Population)
#[14] "Wallis and Futuna"  
covid19_data$Population=ifelse(covid19_data$Country=="Wallis and Futuna",11000,covid19_data$Population)

#Adjust for population
# (metric/POP)*100000
covid19_data$Adjusted_NewCases=(covid19_data$New_cases/covid19_data$Population)*100000
covid19_data$Adjusted_NewDeaths=(covid19_data$New_deaths/covid19_data$Population)*100000
covid19_data$Adjusted_CumulCases=(covid19_data$Cumulative_cases/covid19_data$Population)*100000
covid19_data$Adjusted_CumulDeaths=(covid19_data$Cumulative_deaths/covid19_data$Population)*100000
covid19_data$Death_Rate=(covid19_data$Cumulative_deaths/covid19_data$Cumulative_cases)



countrychoices=unique(covid19_data$Country)


#----- Load libraries -----#
library(shiny)
library(shinydashboard)
library(DT)
library(ggplot2)
library(rsconnect)
library(packrat)
library(formattable)
library(leaflet)
library(leaflet.extras)
library(rgdal)
library(sp)
library(raster)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(reshape2)
library(plotly)
library(maps)
library(shinyWidgets)
library(plotly)
library(waldo)
#these might need to be moved up to the top
library(httr)
library(pkgconfig)


# Define UI for application 


ui <- fluidPage(
    dashboardPage(
        dashboardHeader(title="COVID19 Analysis"),
        dashboardSidebar(
            sidebarMenu(
                menuItem("Welcome",
                         tabName = "welcome",
                         icon=icon("door-open")
                ),
                menuItem("All Data",
                         tabName = "AllData",
                         icon=icon("table")
                ),
                menuItem("Country",
                         tabName="Country",
                         icon=icon("flag")
                         ),
                menuItem("Spread",
                         tabName="map_spread",
                         icon=icon("virus")
                ),
                
                menuItem("Top 10",
                         tabName="top10",
                         icon=icon("list")
                         ),
                menuItem("14-Day Trend",
                         tabName = "trend14",
                         icon=icon("poll")))
        ),
        dashboardBody(
            tabItems(
                tabItem(
                    tabName = "welcome",
                    fluidPage(h1("COVID19 Analysis"),
                              br(),
                              p(strong(tags$u("What is the purpose of this dashboard?"))),
                              p("This dashboard attempts to understand the global spread and impact of the COVID19 pandemic.  
                                The metrics used to quantify these impacts are 'new cases', 'cumulative cases', new 
                                deaths', and 'cumulative deaths'. "),
                              br(),
                              p(strong(tags$u("What data is being used for this analysis?"))),
                              p("Data on cases and deaths is pulled from a",a("dashboard",href="https://covid19.who.int/table")," created by 
                                the World Health Organization (WHO).  2020 Population data is pulled from a publicly available",
                                a("dataset",href="https://github.com/datasets/population")," created by The World Bank."),
                              br(),
                              p(strong(tags$u("What are the limitations of this data?"))),
                              p("The data collected from the WHO is self-reported, therefore, accuracy may differ by country.
                                Further, there are instances of negative case and death counts for several days.  These values
                                represent corrections from a previous day.")
                              
                    )),
                tabItem(
                    tabName = "AllData",
                    DTOutput("alldata")
                ),
                
                tabItem(
                    tabName="Country",
                        fluidRow(align="center",
                                 column(width=6,
                                            selectInput(inputId = "country_select",
                                                label="Select a country:",
                                                choices=as.list(countrychoices),selected = countrychoices[1])),
                                 column(width=6,
                                            selectInput(inputId = "metric_select",
                                                label="Select a metric:",
                                                choices=as.list(MetricChoices),selected = MetricChoices[1]))),
                                    
                        fluidRow(align="center",splitLayout(cellWidths = c("33.3%","33.3%","33.3%"),
                                    valueBoxOutput("vbox1",width=12),
                                    valueBoxOutput("vbox2",width=12),
                                    valueBoxOutput("vbox3",width=12))),
                    
                    plotlyOutput("country_plots"),
                    strong(p(align="center","Case and death counts with negative values represent corrections from a previous day."))
                ),
                tabItem(
                    tabName = "map_spread",
                    fluidRow(align="center",splitLayout(cellWidths = c("50%","25%","25%"),
                        sliderInput("date_filter", "Choose a date:",
                                min = min(covid19_data$Date), max = max(covid19_data$Date), value = min(covid19_data$Date)
                    ),
                        prettyRadioButtons(inputId = "rb", 
                                       label = "Choose a metric:",
                                       c("Cumulative Cases"="Cumulative Cases",
                                         "Cumulative Deaths"="Cumulative Deaths"),
                                       animation = "pulse"),
                        prettyRadioButtons(inputId = "rb1",
                                       label = "Adjust for Population:",
                                       c("No"="No",
                                         "Yes"="Yes"),
                                       animation="pulse")
                    )),
                    fluidRow(align="center",splitLayout(cellWidths = c("50%","50%"),
                        valueBoxOutput("vbox4",width=12),
                        valueBoxOutput("vbox5",width=12))),
                        leafletOutput("world_map")
                ),
                tabItem(
                    tabName = "top10",
                    strong(p(align="center","Use the date slider to select a date and update the two charts below.")),
                    fluidRow(align="center",splitLayout(cellWidths = c("50%","50%"),
                    sliderInput("date_filter2", "Choose a date:",
                                min = min(covid19_data$Date), 
                                max = max(covid19_data$Date), 
                                value = max(covid19_data$Date)
                   ),
                   prettyRadioButtons(inputId = "rb2",
                                      label = "Adjust for Population:",
                                      c("No"="No",
                                        "Yes"="Yes"),
                                      animation="pulse")
                   )),
                 
            
                    plotlyOutput("top10cases"),
                    plotlyOutput("top10deaths")),
                tabItem(
                    tabName = "trend14",
                    fluidRow(align="center",splitLayout(cellWidths = c("50%","50%"),
                                 sliderInput("date_filter3", "Choose a date:",
                                 min = min(covid19_data$Date)+14, 
                                 max = max(covid19_data$Date), 
                                 value = max(covid19_data$Date)),                              
                    prettyRadioButtons(inputId = "rb3",
                                       label = "Adjust for Population:",
                                       c("No"="No",
                                         "Yes"="Yes"),
                                       animation="pulse")
                   )),
                    plotlyOutput("trend14_cases"),
                    plotlyOutput("trend14_deaths")
                )
                
                ))))

# Define server logic 
server <- function(input, output) {
    
    
#----------ALL DATA TABLE----------#
    output$alldata=renderDT({
        datatable(covid19_data[,1:7],filter="top",
                               options=list(pageLength=10,
                               lengthMenu=c(10,15,20,25)
        ),
        rownames = FALSE,
        caption = htmltools::tags$caption(
            style = "caption-side: top; text-align: center; color:black; font-weight: bold",
            'All Data'
        ))
    })
    
#---------- Country Plots ----------#
    
    filtered_data=reactive({
        filter=subset(covid19_data,Country==input$country_select)
        return(filter)
    })
    

    
    
    output$country_plots=renderPlotly({
        p=ggplot(filtered_data(), aes_string(x=filtered_data()$Date, y=input$metric_select))+
            geom_point(size=0.75,aes(text=paste("Date: ", filtered_data()$Date)))+
            geom_line(color="red",size=0.5)+
            xlab("Date")+
            ggtitle(paste0("COVID19 ", input$metric_select," for ",filtered_data()$Country))+
            theme(plot.title = element_text(color="black", size=14, face="bold",hjust=0.5))+
            scale_y_continuous(labels = comma)
        ggplotly(p, tooltip = c("text",'y'))
        
    
        
    })
    

    output$vbox1 <- renderValueBox({
        valueBox(value = formatC(mean(filtered_data()$Population),format="d",big.mark = ","),
                 subtitle = paste0("Current Population of ",unique(filtered_data()$Country)),
                 color = "light-blue"
        )
    })
    
    output$vbox2 <- renderValueBox({
        valueBox(value = formatC(max(filtered_data()$Cumulative_cases),format="d",big.mark = ","),
                 subtitle = paste0("Cumulative Cases for ",unique(filtered_data()$Country)),
                 color = "light-blue"
        )
    })
    
    output$vbox3 <- renderValueBox({
        valueBox(value = formatC(max(filtered_data()$Cumulative_deaths),format="d",big.mark = ","),
                 subtitle = paste0("Cumulative Deaths for ",unique(filtered_data()$Country)),
                 color = "light-blue"
        )
    })
   



#---------- WORLD MAP ----------#
    

map_filter=reactive({
    filter=subset(covid19_data,Date==input$date_filter)
    return(filter)
})


merge_filter=reactive({
    names(world_spdf)[names(world_spdf) == "NAME"] <- "Country"
    map_data=merge(x=world_spdf,y=map_filter(),by="Country",all.x=TRUE)
})




output$vbox4 <- renderValueBox({
    valueBox(value = formatC(sum(map_filter()$Cumulative_cases),format="d",big.mark = ","),
             subtitle = paste0("Cumulative Cases for ",input$date_filter),
             color = "light-blue"
    )
})

output$vbox5 <- renderValueBox({
    valueBox(value = formatC(sum(map_filter()$Cumulative_deaths),format="d",big.mark = ","),
             subtitle = paste0("Cumulative Deaths for " ,input$date_filter),
             color = "light-blue"
    )
})




#----Map #1: Choropleth Map - World Cases----#
output$world_map=renderLeaflet({
    
    bins=c(0,500,1000,5000,10000,100000,500000,1000000,5000000,Inf)
    pal=colorBin(palette = "YlOrBr",domain = merge_filter()$Cumulative_cases,na.color = "transparent",bins=bins)
    customLabel = paste(strong("Country: "),merge_filter()$Country,"<br/>",
                        strong("Cumulative Cases: "),formatC(merge_filter()$Cumulative_cases,format="d",
                                                     big.mark=","), serp="") %>%
    lapply(htmltools::HTML)
    
    
    
    pal2=colorBin(palette = "YlOrBr",domain = merge_filter()$Cumulative_deaths,na.color = "transparent",bins=bins)
    customLabel2 = paste(strong("Country: "),merge_filter()$Country,"<br/>",
                         strong("Cumulative Deaths: "),formatC(merge_filter()$Cumulative_deaths,format="d",big.mark=","), serp="") %>%
    lapply(htmltools::HTML)
    
    
    bins2=c(0,25,50,100,250,500,1000,2500,5000,Inf)
    pal3=colorBin(palette = "YlOrBr",domain = merge_filter()$Adjusted_CumulCases,na.color = "transparent",bins=bins2)
    customLabel3 = paste(strong("Country: "),merge_filter()$Country,"<br/>",
                         strong("Cumulative Cases per 100,000 people: "),formatC(merge_filter()$Adjusted_CumulCases,format="d",big.mark=","), serp="") %>%
    lapply(htmltools::HTML)
    
    pal4=colorBin(palette = "YlOrBr",domain = merge_filter()$Adjusted_CumulDeaths,na.color = "transparent",bins=bins2)
    customLabel4 = paste(strong("Country: "),merge_filter()$Country,"<br/>",
                         strong("Cumulative Deaths per 100,000 people: "),formatC(merge_filter()$Adjusted_CumulDeaths,format="d",big.mark=","), serp="") %>%
    lapply(htmltools::HTML)
    
    
    
    switch(input$rb1,
           "No"=
    switch(input$rb,
            "Cumulative Cases"=
        leaflet(merge_filter()) %>%
        addProviderTiles(providers$OpenStreetMap,options=tileOptions(minZoom = 1.5,maxZoom = 8)) %>%
        addPolygons(fillColor = ~pal(Cumulative_cases),
                    fillOpacity = 0.9,
                    stroke = TRUE,
                    color = "white",
                    highlight=highlightOptions(weight=5,fillOpacity = 0.3),
                    label=customLabel,weight=0.3,smoothFactor = 0.2) %>%
        addLegend(pal=pal,values = ~Cumulative_cases,position = "bottomright",title = "Cumulative Cases"
        ),
            "Cumulative Deaths"=
        leaflet(merge_filter()) %>%
        addProviderTiles(providers$OpenStreetMap,options=tileOptions(minZoom = 1.5,maxZoom = 8)) %>%
        addPolygons(fillColor = ~pal(Cumulative_deaths),
                    fillOpacity = 0.9,
                    stroke = TRUE,
                    color = "white",
                    highlight=highlightOptions(weight=5,fillOpacity = 0.3),
                    label=customLabel2,weight=0.3,smoothFactor = 0.2) %>%
        addLegend(pal=pal2,values = ~Cumulative_deaths,position = "bottomright",title = "Cumulative Deaths"
        )),
            "Yes"=
        switch(input$rb,
               "Cumulative Cases"=
                   leaflet(merge_filter()) %>%
                   addProviderTiles(providers$OpenStreetMap,options=tileOptions(minZoom = 1.5,maxZoom = 8)) %>%
                   addPolygons(fillColor = ~pal3(Adjusted_CumulCases),
                               fillOpacity = 0.9,
                               stroke = TRUE,
                               color = "white",
                               highlight=highlightOptions(weight=5,fillOpacity = 0.3),
                               label=customLabel3,weight=0.3,smoothFactor = 0.2) %>%
                   addLegend(pal=pal3,values = ~Adjusted_CumulCases,position = "bottomright",title = "Cumulative Cases"
                   ),
               "Cumulative Deaths"=
                   leaflet(merge_filter()) %>%
                   addProviderTiles(providers$OpenStreetMap,options=tileOptions(minZoom = 1.5,maxZoom = 8)) %>%
                   addPolygons(fillColor = ~pal4(Adjusted_CumulDeaths),
                               fillOpacity = 0.9,
                               stroke = TRUE,
                               color = "white",
                               highlight=highlightOptions(weight=5,fillOpacity = 0.3),
                               label=customLabel4,weight=0.3,smoothFactor = 0.2) %>%
                   addLegend(pal=pal4,values = ~Adjusted_CumulDeaths,position = "bottomright",title = "Cumulative Deaths"
                   )))
})

#---------------Top 10 Cases/Deaths---------------#

date_filter_cases=reactive({
    filter=subset(covid19_data,Date==input$date_filter2)
    sorted_cases <- filter[order(filter$Cumulative_cases,decreasing = TRUE),]
    sorted_cases <- sorted_cases[1:10,]
    return(sorted_cases)
})


date_filter_deaths=reactive({
    filter=subset(covid19_data,Date==input$date_filter2)
    sorted_deaths <- filter[order(filter$Cumulative_deaths,decreasing = TRUE),]
    sorted_deaths <- sorted_deaths[1:10,]
    return(sorted_deaths)
})


output$top10cases=renderPlotly({
    switch(input$rb2,
           "No"=
               ggplotly(ggplot(date_filter_cases(), aes(x=reorder(date_filter_cases()$Country,-date_filter_cases()$Cumulative_cases), 
                             y=date_filter_cases()$Cumulative_cases))+
                             geom_bar(stat="identity",fill="darkorange3",aes(text=paste("Country: ", date_filter_cases()$Country, "<br>",
                                                                                        "Cumulative Cases: ", formatC(date_filter_cases()$Cumulative_cases,format="d",big.mark = ","))))+
                             xlab("Country")+ylab("Cumulative Cases")+
                             ggtitle(paste0("Top 10 Countries Ranked by Cumulative Cases on ",input$date_filter2))+
                             theme(plot.title = element_text(color="black", size=14, face="bold",hjust=0.5),legend.position = "none")+
                             scale_y_continuous(labels = comma),
                        tooltip = c("text") ),
           "Yes"=
               ggplotly(ggplot(date_filter_cases(), aes(x=reorder(date_filter_cases()$Country,-date_filter_cases()$Adjusted_CumulCases), 
                             y=date_filter_cases()$Adjusted_CumulCases))+
                             geom_bar(stat="identity",fill="darkorange3",aes(text=paste("Country: ", date_filter_cases()$Country,"<br>",
                                                                                        "Cumulative Cases: ", round(date_filter_cases()$Adjusted_CumulCases,2))))+
                             xlab("Country")+ylab("Cumulative Cases")+
                             ggtitle(paste0("Top 10 Countries Ranked by Cumulative Cases on ",input$date_filter2," per 100,000 People"))+
                             theme(plot.title = element_text(color="black", size=14, face="bold",hjust=0.5),legend.position = "none")+
                             scale_y_continuous(labels = comma),
                        tooltip=c("text"))
           )

})

output$top10deaths=renderPlotly({
    
    switch(input$rb2,
           "No"=
               ggplotly(ggplot(date_filter_deaths(), aes(x=reorder(date_filter_deaths()$Country,-date_filter_deaths()$Cumulative_deaths), 
                                    y=date_filter_deaths()$Cumulative_deaths))+
                                    geom_bar(stat="identity",fill="brown3",aes(text=paste("Country: ", date_filter_deaths()$Country, "<br>",
                                                                                          "Cumulative Cases: ", formatC(date_filter_deaths()$Cumulative_deaths,format="d",big.mark = ","))))+
                            
                                    xlab("Country")+ylab("Cumulative Deaths")+
                                    ggtitle(paste0("Top 10 Countries Ranked by Cumulative Deaths on ",input$date_filter2))+
                                    theme(plot.title = element_text(color="black", size=14, face="bold",hjust=0.5),legend.position = "none")+
                                    scale_y_continuous(labels = comma),
                        tooltip=c("text")),
           
           "Yes"= 
               ggplotly(ggplot(date_filter_deaths(), aes(x=reorder(date_filter_deaths()$Country,-date_filter_deaths()$Adjusted_CumulDeaths), 
                                    y=date_filter_deaths()$Adjusted_CumulDeaths))+
                                    geom_bar(stat="identity",fill="brown3",aes(text=paste("Country: ", date_filter_deaths()$Country, "<br>",
                                                                                          "Cumulative Deaths: ", round(date_filter_deaths()$Adjusted_CumulDeaths,2))))+
                                    xlab("Country")+ylab("Cumulative Deaths")+
                                    ggtitle(paste0("Top 10 Countries Ranked by Cumulative Deaths on ",input$date_filter2, " per 100,000 People"))+
                                    theme(plot.title = element_text(color="black", size=14, face="bold",hjust=0.5),legend.position = "none")+
                                    scale_y_continuous(labels = comma),
           tooltip=c("text")))
    
        
})

#---------------14-Day Trend---------------#

output$trend14_cases=renderPlotly({
    
    df_cases=reactive({
        trend14data=subset(covid19_data,(covid19_data$Date<=max(input$date_filter3)) & covid19_data$Date>=max(as.Date(input$date_filter3))-13)
        trend14data$SumNewCases <- with(trend14data,ave(New_cases,Country,FUN=sum))
        trend_cases <- trend14data[order(trend14data$SumNewCases,decreasing = TRUE),][1:140,]
        loc1=unique(trend_cases$Country)[1:10]
        trend_cases=trend_cases[trend_cases$Country %in% loc1,]
        return(trend_cases)
    })
    
    
    df_cases_adj=reactive({
        trend14data=subset(covid19_data,(covid19_data$Date<=max(input$date_filter3)) & covid19_data$Date>=max(as.Date(input$date_filter3))-13)
        trend14data$SumNewCases_Adj <- with(trend14data,ave(Adjusted_NewCases,Country,FUN=sum))
        trend_cases_adj <- trend14data[order(trend14data$SumNewCases_Adj,decreasing = TRUE),][1:140,]
        loc3=unique(trend_cases_adj$Country)[1:10]
        trend_cases_adj=trend_cases_adj[trend_cases_adj$Country %in% loc3,]
        return(trend_cases_adj)
    })
    
    
 
    
    switch(input$rb3,
            "No"=
                ggplotly(ggplot(df_cases(),aes(x=Date,y=New_cases))+
                    geom_area(fill="darkorange3")+
                    geom_line(color="black",size=0.5)+
                    geom_point(size=1.00,color="black",aes(text=paste("Date: ", Date, "<br>",
                                                                      "New Cases: ", formatC(New_cases,format="d",big.mark = ","))))+

                    facet_wrap(~reorder(Country,-New_cases),ncol=5)+
                    ggtitle(paste0("Top 10 Countries Ranked by Total New Cases over Last 14 Days from ",input$date_filter3))+
                    theme(plot.title = element_text(color="black", size=14, face="bold",hjust=0.5),legend.position = "none")+
                    xlab("Last 14 Days")+ylab("New Cases")+
                    scale_y_continuous(labels = comma),tooltip=c("text"))
           ,
           "Yes"=
               ggplotly(ggplot(df_cases_adj(),aes(x=Date,y=Adjusted_NewCases))+
                   geom_area(fill="darkorange3")+
                   geom_line(color="black",size=0.5)+
                   geom_point(size=1.00,color="black",aes(text=paste("Date: ", Date, "<br>",
                                                                     "New Cases: ", round(Adjusted_NewCases,2))))+
                   facet_wrap(~reorder(Country,-Adjusted_NewCases),ncol=5)+
                   ggtitle(paste0("Top 10 Countries Ranked by Total New Cases over Last 14 Days from ",input$date_filter3," per 100,000 people"))+
                   theme(plot.title = element_text(color="black", size=14, face="bold",hjust=0.5),legend.position = "none")+
                   xlab("Last 14 Days")+ylab("New Cases")+
                   scale_y_continuous(labels = comma),tooltip=c("text"))
           
    )

})

output$trend14_deaths=renderPlotly({
    
    
    df_deaths=reactive({
        trend14data=subset(covid19_data,(covid19_data$Date<=max(input$date_filter3)) & covid19_data$Date>=max(as.Date(input$date_filter3))-13)
        trend14data$SumNewDeaths <- with(trend14data,ave(New_deaths,Country,FUN=sum))
        trend_deaths <- trend14data[order(trend14data$SumNewDeaths,decreasing = TRUE),][1:140,]
        loc2=unique(trend_deaths$Country)[1:10]
        trend_deaths=trend_deaths[trend_deaths$Country %in% loc2,]
        return(trend_deaths)
    })
    
    df_deaths_adj=reactive({
        trend14data=subset(covid19_data,(covid19_data$Date<=max(input$date_filter3)) & covid19_data$Date>=max(as.Date(input$date_filter3))-13)
        trend14data$SumNewDeaths_Adj <- with(trend14data,ave(Adjusted_NewDeaths,Country,FUN=sum))
        trend_deaths_adj <- trend14data[order(trend14data$SumNewDeaths_Adj,decreasing = TRUE),][1:140,]
        loc4=unique(trend_deaths_adj$Country)[1:10]
        trend_deaths_adj=trend_deaths_adj[trend_deaths_adj$Country %in% loc4,]
        return(trend_deaths_adj)
    })
    
    
    
    
    
    
    
    
    
    
    switch(input$rb3,
           "No"=
                ggplotly(ggplot(df_deaths(),aes(x=Date,y=New_deaths))+
                    geom_area(fill="brown3")+
                    geom_line(color="black",size=0.5)+
                    geom_point(size=1.00,color="black",aes(text=paste("Date: ", Date, "<br>",
                                                                      "New Deaths: ", formatC(New_deaths,format="d",big.mark = ","))))+
                    facet_wrap(~reorder(Country,-New_deaths),ncol=5)+
                    ggtitle(paste0("Top 10 Countries Ranked by Total New Deaths over Last 14 Days from ", input$date_filter3))+
                    theme(plot.title = element_text(color="black", size=14, face="bold",hjust=0.5),legend.position = "none")+
                    xlab("Last 14 Days")+ylab("New Deaths")+
                    scale_y_continuous(labels = comma),tooltip=c("text")),
           "Yes"=
              ggplotly(ggplot(df_deaths_adj(),aes(x=Date,y=Adjusted_NewDeaths))+
                   geom_area(fill="brown3")+
                   geom_line(color="black",size=0.5)+
                   geom_point(size=1.00,color="black",aes(text=paste("Date: ", Date, "<br>",
                                                                     "New Deaths: ", round(Adjusted_NewDeaths,2))))+
                   facet_wrap(~reorder(Country,-Adjusted_NewDeaths),ncol=5)+
                   ggtitle(paste0("Top 10 Countries Ranked by Total New Deaths over Last 14 Days from ", input$date_filter3, " per 100,000 people"))+
                   theme(plot.title = element_text(color="black", size=14, face="bold",hjust=0.5),legend.position = "none")+
                   xlab("Last 14 Days")+ylab("New Deaths")+
                   scale_y_continuous(labels = comma),tooltip=c("text"))
           
           

    )

})


}

# Run the application 
shinyApp(ui = ui, server = server)
