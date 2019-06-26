library(ggplot2)
library(tidyverse)
library(lubridate)
library(shiny)
library(shinydashboard)
library(rsconnect)
library(scales)

######## R SHINY APP ########
data <- read.csv("./appdata.csv", stringsAsFactors = FALSE)

#Dashboard header carrying the title of the dashboard
header <- dashboardHeader(title = 'SF Bikes')  

choices_names <- unique(data$WeekDate)
  
#Sidebar content of the dashboard
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem('Dashboard', tabName = 'dashboard', icon = icon('dashboard')),
    menuItem('Github Repo', icon = icon('send',lib='glyphicon'), 
             href = 'https://github.com/geekbites/sanfran-bike'),
    selectInput('filter', 'Select a week',
                choices = choices_names,
                selectize=TRUE,
                width = '98%')
  )
)

frow1 <- fluidRow(
  valueBoxOutput('value1')
  ,valueBoxOutput('value2')
  ,valueBoxOutput('value3')
)

frow2 <- fluidRow(
  box(
    title = 'Total trips by day'
    ,status = 'primary'
    ,width=12
    ,solidHeader = TRUE 
    ,collapsible = TRUE 
    ,plotOutput('totaltripsbyWd', height = '300px')
  )
)

frow3 <- fluidRow(
  box(
    title = 'Avg Trips per Bike per Day'
    ,status = 'primary'
    ,solidHeader = TRUE 
    ,collapsible = TRUE 
    ,plotOutput('tripsbyWd', height = '300px')
  )
  
  ,box(
    title = 'Utilization Rate (Weekday)'
    ,status = 'primary'
    ,solidHeader = TRUE 
    ,collapsible = TRUE 
    ,plotOutput('urbyWd', height = '300px')
  ) 
)

frow4 <- fluidRow(
  box(
    title = 'Utilization Rate (Hour)'
    ,status = 'primary'
    ,width = 12
    ,solidHeader = TRUE 
    ,collapsible = TRUE 
    ,plotOutput('urbyHour', height = '300px')
  )
) 

# combine the two fluid rows to make the body
body <- dashboardBody(frow1, frow2, frow3, frow4)

#completing the ui part with dashboardPage
ui <- dashboardPage(title = 'San Francisco Bike Sharing', header, sidebar, body, skin='red')