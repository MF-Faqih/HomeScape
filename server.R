function(input, output, session) {
  
  shinyjs::addClass(id = "inTabset")
  
  #---------------HOME TAB---------------
  
  ## Slide show settings
  output$slide_show <- renderSlickR({
    
    imgs <- list.files("image/home", 
                       pattern=".png", 
                       full.names = TRUE)
    slickR(imgs) + 
      settings(dots = TRUE, autoplay = TRUE)
  })
  
  ## Image beneath slide show
  output$home_image <- renderImage({
    
    list(src = "image/image4.png",
         height = "100%",
         width = "100%"
         )
    
  }, deleteFile = F)
  
  ## Action button to specific tab
  observeEvent(input$JumpIntoLocation, {
    updateTabsetPanel(session = session, 
                      inputId = "inTabset",
                      selected = "location_tab")
  })
  
  observeEvent(input$JumpIntoPrice, {
    updateTabsetPanel(session = session, 
                      inputId = "inTabset",
                      selected = "price_tab")
  })
  
  observeEvent(input$JumpIntoPrice2, {
    updateTabsetPanel(session = session, 
                      inputId = "inTabset",
                      selected = "price_tab")
  })

  #---------------FIND BY LOCATION TAB---------------
  
  ##Interactive Map
  
  output$second_selection <- renderUI({
    
    selectInput(inputId = "select_subdistrict",
                label = "Select Sub-District: ",
                choices = sort(unique(apartment_for_map[apartment_for_map$District == input$select_district, ]$Sub_district))
                )
    
  })
  
  output$map <- renderLeaflet({
    
    apartment_num <- apartment_for_map %>% 
      filter(District == input$select_district & Sub_district == input$select_subdistrict) %>%
      group_by(District, Sub_district) %>% 
      summarise(Max = max(Price),
                Min = min(Price),
                Mean = mean(Price),
                Total = n()) %>% 
      ungroup()
    
    apartment_map <- jakarta_json_mod %>% 
      left_join(apartment_num, by = c("NAME_3" = "Sub_district")) %>% 
      st_as_sf()
    
    pal <- colorNumeric(palette = "red", domain = apartment_map$Mean)
    
    map <- leaflet(apartment_map) %>% 
      addTiles() %>% 
      addPolygons(fillColor = ~pal(Mean),
                  label = paste0("Sub District: ", apartment_map$NAME_3), 
                  fillOpacity = .8,
                  weight = 2,
                  color = "white",
                  highlight = highlightOptions(
                    weight = 1,
                    color = "black", 
                    bringToFront = TRUE,
                    opacity = 0.8)
      ) %>% 
      setView(lng = 106.8106, lat = -6.2615, zoom = 11)
    
  })
  
  output$total_apartment <- renderInfoBox({
    
    for_display1 <- apartment_for_map %>% 
      filter(District == input$select_district & Sub_district == input$select_subdistrict) %>%
      group_by(District, Sub_district) %>% 
      summarise(Total = n()) %>% 
      ungroup() %>% 
      select(Total)
    
    infoBox("Apartment Found: ", for_display1, icon = icon("house"), color = "olive", fill = T)
  })
  
  output$expensive <- renderValueBox({
    
    for_display2 <- apartment_for_map %>% 
      filter(District == input$select_district & Sub_district == input$select_subdistrict) %>%
      group_by(District, Sub_district) %>% 
      summarise(Max = max(Price)) %>% 
      ungroup() %>% 
      select(Max)
    
    valueBox(paste("Rp ", prettyNum(for_display2, big.mark = ".", decimal.mark = ",")), "Most Expensive Apartment", icon = icon("fas fa-dollar-sign"), color = "red")
  })
  
  output$cheapest <- renderValueBox({
    
    for_display3 <- apartment_for_map %>% 
      filter(District == input$select_district & Sub_district == input$select_subdistrict) %>%
      group_by(District, Sub_district) %>% 
      summarise(Min = min(Price)) %>% 
      ungroup() %>% 
      select(Min)
    
    valueBox(paste("Rp ", prettyNum(for_display3, big.mark = ".", decimal.mark = ",")), "Cheapest Price Apartment", icon = icon("fas fa-dollar-sign"), color = "green")
  })
  
  output$average <- renderValueBox({
    
    for_display4 <- apartment_for_map %>% 
      filter(District == input$select_district & Sub_district == input$select_subdistrict) %>%
      group_by(District, Sub_district) %>% 
      summarise(Mean = mean(Price)) %>% 
      ungroup() %>% 
      select(Mean)
    
  
    valueBox(
      
      paste("Rp ", prettyNum(for_display4, big.mark = ".", decimal.mark = ",")), "Average Apartment Price", icon = icon("fas fa-dollar-sign"), 
      color = ifelse(for_display4 >= 0 & for_display4 <= 1000000000, "green", 
                     ifelse(for_display4 > 1000000000 & for_display4 <= 1500000000, "yellow", 
                            ifelse(for_display4 > 1500000000 & for_display4 <= 2500000000, "orange",
                                   ifelse(for_display4 > 2500000000 & for_display4 <= 4100000000, "red"))))
      )
  })
  
  output$list_image <- renderImage({
    
    list(src = "image/apartmentlist.png"
    )
    
  }, deleteFile = F)
  
  plotData <- reactive({
    apartment_for_map %>% 
      filter(Sub_district == input$select_subdistrict) %>% 
      select(c(Name, Bedroom, Bathroom, Price, Total_area, Phone))
  })
  
  output$apartment_table <- renderDataTable(
    
    plotData(), options = list(pageLength = 5)
 
  )
  
  
  #---------------PREDICT PRICE TAB---------------
  
  output$second_selection2 <- renderUI({
    
    selectInput(inputId = "select_subdistrict2",
                label = "Select Sub-District: ",
                choices = sort(unique(apartment_for_map[apartment_for_map$District == input$select_district2, ]$Sub_district))
    )
    
  })
  
  predictions <- eventReactive(input$action,{
    
    if(is.null(input$select_district2)){
      return()
    }
    
    apartment_predict <- data.frame(
      Bedroom = as.numeric(input$select_bedroom),
      Bathroom = as.numeric(input$select_bathroom),
      Total_area = input$areas,
      District = input$select_district2,
      Sub_district = input$select_subdistrict2
    )
    
    
    exp(predict(apartment_forest, apartment_predict))
    
  })
  
  output$prediction_result <- renderText({
    
    paste("Rp ", prettyNum(predictions(), big.mark = "."))
    
  })
  
  
  ##Sub Tab Recommendation_________________________________
  
  ### Apartment recommendation in same District
  plotData1 <- eventReactive(input$action,{
    
    apartment_for_map %>% 
      filter(Price <= predictions(),
             District == input$select_district2) %>% 
      select(c(Name, Sub_district, Bedroom, Bathroom, Total_area, Price, Phone))
    
  })
  
  output$apartment_predict <- renderDataTable(
    
    plotData1(), options = list(pageLength = 5)
    
  )
  
  ### Apartment recommendation in another district
  plotData2 <- eventReactive(input$action,{
    
    cluster_only <- apartment_for_map %>% 
      filter(Price < predictions(),
             District == input$select_district2) %>% 
      select(Cluster)
    
    freq <- table(cluster_only$Cluster)
    
    most_frequent <- as.numeric(names(freq)[freq == max(freq)])
    
    apartment_for_map %>% 
      filter(Cluster == most_frequent,
             District != input$select_district2,
             Price < predictions()) %>% 
      select(c(Name, District, Sub_district, Bedroom, Bathroom, Total_area, Price, Phone))
    
  })
  
  output$apartment_recom <- renderDataTable(
    
    plotData2(), options = list(pageLength = 5)
    
  )
  
  output$pred_image1 <- renderImage({
    
    list(src = "image/image5.png"
    )
    
  }, deleteFile = F)
  
  output$pred_image2 <- renderImage({
    
    list(src = "image/image6.png"
    )
    
  }, deleteFile = F)
  
  
  ##Sub Tab Price Distribution_________________________________
  
  ### Average price bar plot
  graph_data <- eventReactive(input$action,{
    
    apartment_filter <- apartment_for_map %>% 
      filter(Bedroom == input$select_bedroom,
             Bathroom == input$select_bathroom,
             District == input$select_district2) %>% 
      group_by(Sub_district) %>% 
      summarise(Price_mean = mean(Price)) %>% 
      ungroup() %>% 
      mutate(Sub_district = as.factor(Sub_district))
    
    apartment_filter %>% 
      mutate(
        label = glue(
          "District: {Sub_district}
       Mean Price: {comma(Price_mean)}"
        )
      )
  })
  
  output$distribution_table <- renderPlotly({
    
    graph_data <- graph_data()
    
    plot1 <- ggplot(graph_data, aes(x = reorder(Sub_district, Price_mean),
                                    y = Price_mean, 
                                    text = label)) +
      geom_col(aes(fill = Price_mean)) +
      scale_fill_gradient(low="#F8EEE3", high="red") +
      labs(#title = "Price Distribution with Same Apartment Characteristic (District, Bedroom, and Bathroom)",
           y = "Average Price",
           x = "Sub District")+
      coord_flip() +
      scale_y_continuous(labels = comma) +
      theme_minimal()
    
    ggplotly(plot1, tooltip = "text")
    
  })
  
  ##Sub Tab Frequencies_________________________________
  
  #Donuts plot of apartment bedroom type
  bedroom_freq_data <- eventReactive(input$action,{
    
    apartment_donut <- apartment_for_map %>% 
      filter(District == input$select_district2) %>% 
      select(c(District, Bedroom))
    
    tot_bedroom <- function(x){
      if (x == 1){
        y <- "1 Bed"
      }
      
      else if (x == 2){
        y <- "2 Bed"
      }
      
      else if (x == 3){
        y <- "3 Bed"
      }
      
      else if (x == 4){
        y <- "4 Bed"
      }
      
    }
    
    apartment_donut$Total_bedroom <- as.factor(sapply(apartment_donut$Bedroom, FUN = tot_bedroom))
    
    apartment_donut <- apartment_donut %>% 
      group_by(Bedroom, Total_bedroom) %>% 
      summarise(Jumlah = n()) %>% 
      ungroup()
    
    apartment_donut$fraction <- apartment_donut$Jumlah / sum(apartment_donut$Jumlah)
    apartment_donut$ymax <- cumsum(apartment_donut$fraction)
    apartment_donut$ymin <- c(0, head(apartment_donut$ymax, n=-1))
    apartment_donut$labelPosition <- (apartment_donut$ymax + apartment_donut$ymin) / 2
    apartment_donut$label <- paste0(apartment_donut$Total_bedroom, "\n Total: ", apartment_donut$Jumlah)
    
    apartment_donut <- as.data.frame(apartment_donut)
    
  })
  
  output$bedroom_freq <- renderPlot({
    
    apartment_donut <- bedroom_freq_data()
    
    ggplot(apartment_donut, aes(ymax=ymax, ymin=ymin, xmax=4, xmin=3, fill=Total_bedroom)) +
      geom_rect() +
      geom_text( x=2, aes(y=labelPosition, label=label, color=Total_bedroom), size=4) +
      scale_fill_manual(values=c("#D52027", "#FFB049", "#1E4558", "#F8EEE3")) +
      #scale_fill_brewer(palette=3) +
      #scale_color_brewer(palette=3) +
      coord_polar(theta="y") +
      xlim(c(-1, 4)) +
      theme_void() +
      theme(legend.position = "none") 
    
  })
  
  #Donuts plot of apartment bathroom type
  bathroom_freq_data <- eventReactive(input$action,{
    
    apartment_bathrom <- apartment_for_map %>% 
      filter(District == input$select_district2) %>% 
      select(c(District, Bathroom))
    
    tot_bathroom <- function(x){
      if (x == 1){
        y <- "1 Bath"
      }
      
      else if (x == 2){
        y <- "2 Bath"
      }
      
      else if (x == 3){
        y <- "3 Bath"
      }
      
      else if (x == 4){
        y <- "4 Bath"
      }
      
    }
    
    apartment_bathrom$Total_bathroom <- as.factor(sapply(apartment_bathrom$Bathroom, FUN = tot_bathroom))
    
    apartment_bathrom <- apartment_bathrom %>% 
      group_by(Bathroom, Total_bathroom) %>% 
      summarise(Jumlah = n()) %>% 
      ungroup()
    
    apartment_bathrom$fraction <- apartment_bathrom$Jumlah / sum(apartment_bathrom$Jumlah)
    apartment_bathrom$ymax <- cumsum(apartment_bathrom$fraction)
    apartment_bathrom$ymin <- c(0, head(apartment_bathrom$ymax, n=-1))
    apartment_bathrom$labelPosition <- (apartment_bathrom$ymax + apartment_bathrom$ymin) / 2
    apartment_bathrom$label <- paste0(apartment_bathrom$Total_bathroom, "\n Total: ", apartment_bathrom$Jumlah)
    
    apartment_bathrom <- as.data.frame(apartment_bathrom)
    
  })
  
  output$bathroom_freq <- renderPlot({
    
    apartment_bathroom <- bathroom_freq_data()
    
    ggplot(apartment_bathroom, aes(ymax=ymax, ymin=ymin, xmax=4, xmin=3, fill=Total_bathroom)) +
      geom_rect() +
      geom_text( x=2, aes(y=labelPosition, label=label, color=Total_bathroom), size=4) +
      scale_fill_manual(values=c("#D52027", "#FFB049", "#1E4558", "#F8EEE3")) +
      coord_polar(theta="y") +
      xlim(c(-1, 4)) +
      theme_void() +
      theme(legend.position = "none") 
    
  })
  
  #Donuts plot of apartment type
  apartment_type_data <- eventReactive(input$action,{
    
    apartment_type <- apartment_for_map %>% 
      filter(District == input$select_district2) %>% 
      select(c(District, Total_area, Bedroom))
    
    apartment_type$Type <- ifelse(apartment_type$Total_area >= 12 & apartment_type$Total_area <= 24, "Micro",
                                  ifelse(apartment_type$Total_area >= 25 & apartment_type$Total_area <= 44, "Studio",
                                         ifelse(apartment_type$Bedroom == 1, "1 Bed",
                                                ifelse(apartment_type$Bedroom == 2, "2 Bed",
                                                       ifelse(apartment_type$Bedroom == 3, "3 Bed",
                                                              ifelse(apartment_type$Bedroom == 4, "4 Bed", "None"))))))
    
    apartment_type$Type <- as.factor(apartment_type$Type)
    
    apartment_type <- apartment_type %>% 
      group_by(Type) %>% 
      summarise(Jumlah = n()) %>% 
      ungroup()
    
    apartment_type$fraction <- apartment_type$Jumlah / sum(apartment_type$Jumlah)
    apartment_type$ymax <- cumsum(apartment_type$fraction)
    apartment_type$ymin <- c(0, head(apartment_type$ymax, n=-1))
    apartment_type$labelPosition <- (apartment_type$ymax + apartment_type$ymin) / 2
    apartment_type$label <- paste0(apartment_type$Type, "\n Total: ", apartment_type$Jumlah)
    
    apartment_type <- as.data.frame(apartment_type)
    
  })
  
  output$tpye_freq <- renderPlot({
    
    apartment_type <- apartment_type_data()
    
    ggplot(apartment_type, aes(ymax=ymax, ymin=ymin, xmax=4, xmin=3, fill=Type)) +
      geom_rect() +
      geom_text( x=2, aes(y=labelPosition, label=label, color=Type), size=4) +
      scale_fill_manual(values=c("#D52027", "#FFB049", "#1E4558", "#F8EEE3", "#CE4420", "#102030")) +
      coord_polar(theta="y") +
      xlim(c(-1, 4)) +
      theme_void() +
      theme(legend.position = "none") 
    
  })
  
  #---------------ABOUT TAB---------------
  
  output$architectureHead <- renderImage({
    
    list(src = "image/archHead.png"
    )
    
  }, deleteFile = F)
  
  #Architecture image
  output$architecture <- renderImage({
    
    list(src = "image/architecture.png",
         width = "100%",
         height = "500px"
    )
    
  }, deleteFile = F)
  
  #Personal image
  output$myImage <- renderImage({
    
    list(src = "image/my_image.png",
         width = "100%",
         height = "100%x"
    )
    
  }, deleteFile = F)
  
  #Personal CV
  output$downloadData <- downloadHandler(
    filename = "M. Fadlurrohman Faqih CV.pdf",
    content = function(file) {
      file.copy("www/M. Fadlurrohman Faqih CV.pdf", file)
    }
  )
  
  #First project gif
  output$firstGif <- renderImage({
    
    list(src = "image/gif/gif1.gif",
         contentType = "image/gif",
         width = "375px",
         height = "200px"
    )
    
  }, deleteFile = F)
  
  #RPubs gif
  output$rpubs <- renderImage({
    
    list(src = "image/gif/RPubs.png",
         contentType = "image/gif",
         width = "300px",
         height = "150px"
    )
    
  }, deleteFile = F)
  
  #Second project gif
  output$thirdGif <- renderImage({
    
    list(src = "image/gif/gif3.gif",
         contentType = "image/gif",
         width = "375px",
         height = "200px"
    )
    
  }, deleteFile = F)
  

}






