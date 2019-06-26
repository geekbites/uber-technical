data <- read.csv("./appdata.csv", stringsAsFactors = FALSE)

server <- function(input, output) { 
  
  # creating the valueBoxOutput content
  output$value1 <- renderValueBox({
    num_trips <- n_distinct(data[data$WeekDate == input$filter, 'Trip.ID'])
    
    valueBox(
      formatC(num_trips, format='d', big.mark=',')
      # formatC(value1, format='f')
      ,'Total Trips'
      ,icon = icon('bicycle')
      ,color = 'purple')
  })
  
  output$value2 <- renderValueBox({
    data <- data[data$WeekDate == input$filter,] %>% group_by(Start.Day, Bike.Number) %>% summarize(num_of_trips=n_distinct(Trip.ID))
    trips_per_day <-  mean(data$num_of_trips)
    
    valueBox(
      formatC(trips_per_day, format='f', digits=1)
      ,'Avg Trips Per Bike Per Day'
      ,icon = icon('walking')
      ,color = 'green')
    
  })
  
  output$value3 <- renderValueBox({
    data <- n_distinct(data[data$WeekDate == input$filter, 'Bike.Number']) / n_distinct(data$Bike.Number)
    
    valueBox(
      paste0(formatC(data * 100, format='f', digits=1), '%')
      ,'Utilization Rate'
      ,icon = icon('stats',lib='glyphicon')
      ,color = 'yellow')
    
  })
  # 
  #creating the plotOutput content
  
  output$urbyWd <- renderPlot({
    unique_bikes <- n_distinct(data$Bike.Number)
    
    ur_weekday <- data[data$WeekDate == input$filter,] %>% 
      group_by(Week, Start.Weekday) %>% 
      summarize(total.duration=sum(duration_time),
                avg.duration=mean(duration_time),
                n.bikes=n_distinct(Bike.Number),
                num_of_weeks=n_distinct(Start.Day),
                num_of_trips=n_distinct(Trip.ID))
    
    ur_weekday$utilization_rate = ur_weekday$n.bikes / unique_bikes
    
    ggplot(data=ur_weekday, aes(x=Start.Weekday, y=utilization_rate)) +
      geom_bar(position = 'dodge', stat = 'identity') +
      ylab('Utilization Rate (%)') +
      xlab('Weekday') +
      geom_text(aes(label = percent(utilization_rate)),
                vjust = -0.5,
                position=position_dodge(0.9)) +
      scale_x_continuous(breaks=1:7,
                         labels=c('Mon','Tue','Wed','Thu','Fri','Sat','Sun'))
    
  })
  
  output$tripsbyWd <- renderPlot({
    rides_per_bike <- data[data$WeekDate == input$filter,] %>% 
      group_by(Start.Weekday, Bike.Number) %>% 
      summarize(num_of_trips=n_distinct(Trip.ID))
    
    rides_per_bike_2 <- rides_per_bike %>%
      group_by(Start.Weekday) %>%
      summarize(avg_trips=mean(num_of_trips))
    
    ggplot(data=rides_per_bike_2, aes(x=Start.Weekday, y=avg_trips)) +
      geom_bar(stat='identity',
               position=position_dodge(),
               width = 0.8) +
      ylab('Avg Trips') +
      xlab('Weekday') +
      scale_x_continuous(breaks=1:7,
                         labels=c('Mon','Tue','Wed','Thu','Fri','Sat','Sun')) +
      geom_text(aes(label = sprintf(avg_trips, fmt='%.1f')),
                vjust = -0.5,
                position=position_dodge(0.9))
  })
  
  output$totaltripsbyWd <- renderPlot({
    total_trips_by_day <- data[data$WeekDate == input$filter,] %>% 
      group_by(Start.Weekday) %>% 
      summarize(num_of_trips=n_distinct(Trip.ID))
    
    ggplot(data=total_trips_by_day, aes(x=Start.Weekday, y=num_of_trips)) +
      geom_bar(stat='identity',
               position=position_dodge(),
               width = 0.8) +
      ylab('Total Trips') +
      xlab('Weekday') +
      scale_x_continuous(breaks=1:7,
                         labels=c('Mon','Tue','Wed','Thu','Fri','Sat','Sun')) +
      geom_text(aes(label = formatC(num_of_trips, format='d', big.mark=',')),
                vjust = -0.5,
                position=position_dodge(0.9))
  })
  
  output$urbyHour <- renderPlot({
    unique_bikes <- n_distinct(data$Bike.Number)
    
    ur_hour <- data[data$WeekDate == input$filter,] %>% 
      group_by(Start.Hour) %>% 
      summarize(n.bikes=n_distinct(Bike.Number))
    
    ur_hour$utilization_rate = ur_hour$n.bikes / unique_bikes
    
    ggplot(data=ur_hour, aes(x=Start.Hour, y=utilization_rate)) +
      geom_bar(stat='identity',
               position=position_dodge(),
               width = 0.8) +
      ylab('Utilization Rate (%)') +
      xlab('Hour') +
      scale_x_continuous(breaks=0:24,
                         labels=c('0','1','2','3','4','5','6','7','8','9','10','11','12',
                                  '13','14','15','16','17','18','19','20','21','22','23','24')) +
      geom_text(aes(label = percent(utilization_rate)),
                vjust = -0.5,
                position=position_dodge(0.9))
  })
  
}