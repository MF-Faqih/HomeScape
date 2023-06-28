fluidPage(
  
  useShinyjs(),
  
  navbarPage(
    title = "HomeScape",
    id = "inTabset",
    header = tagList(useShinydashboard()),
    
    #CSS style
    tags$style(HTML("
                    .space_box {
                    height: 20px;
                    }
                    .box-height {
                    height: 550px;
                    }
                    .box-margin-bot {
                    margin-bottom: 100px;
                    }
                    .box-margin-top {
                    margin-top: 10px;
                    }
                    .box-heights-arch {
                    height: 600px;
                    }
                    .box-heights-arch-head {
                    height: 100px;
                    }
                    "
    )),
    
    #---------------HOME TAB---------------
    
    tabPanel(title = "Home",
             
             # Autoplay slide show output
             fluidRow(
               slickROutput("slide_show",
                            width = "1100px",
                            height = "300px"
               )
             ),
             column(
               width = 12,
               class = "space_box"
             ),
             
             # Output image beneath slide show
             imageOutput("home_image", height = "100%", width = "100%"),
             
             # Action button to "Find by Place"
             column(
               width = 4,
               actionButton(
                 inputId = 'JumpIntoLocation',
                 label = strong("Let's Get Started >>"),
                 style = "color: white;
                            background-color: #337AB7;
                            border-color: #337AB7"
               ),
               align = "center",
               style = "margin-bottom: 10px;",
               style = "margin-top: -10px;" 
             ),
             
             # Action button to "Predict Price"
             column(
               width = 4,
               actionButton(
                 inputId = 'JumpIntoPrice',
                 label = strong("Let's Get Started >>"),
                 style = "color: white;
                            background-color: #337AB7;
                            border-color: #337AB7"
               ),
               align = "center",
               style = "margin-bottom: 10px;",
               style = "margin-top: -10px;" 
             ),
             
             # Action button to "Predict Price"
             column(
               width = 4,
               actionButton(
                 inputId = 'JumpIntoPrice2',
                 label = strong("Let's Get Started >>"),
                 style = "color: white;
                            background-color: #337AB7;
                            border-color: #337AB7"
               ),
               align = "center",
               style = "margin-bottom: 10px;",
               style = "margin-top: -10px;" 
             ),
             
             tags$hr()
    ),
    
    
    #---------------FIND BY LOCATION TAB---------------
    
    tabPanel(title = "Find by Location",
             value = "location_tab",
             div(
               tags$head(
                 
                   # Include custom CSS
                   includeCSS("styless.css")
                   
                 ),
                 fluidPage(
                   scrollable = T,
                   column(
                     width = 12,
                     
                     #Map Output
                     box( 
                       width = 9,
                       collapsible = F,
                       withSpinner(leafletOutput("map", width = "100%", height = 700), type = 8, size = 0.5, color = "gray")
                       ),
                     
                     #Select Panel
                     box(
                       width = 3,
                       absolutePanel(
                         fixed = F, draggable = F, top = 60, left = "auto", right = 0, bottom = "auto", width = "100%", height = "auto", id = "controls", class = "panel panel-default",
                         h1("HomeScape"),
                         column(width = 12),
                         selectInput(inputId = "select_district", label = "Select District: ", choices = sort(unique(apartment_for_map$District))),
                         withSpinner(uiOutput(outputId = "second_selection"), type = 8, size = 0.5, color = "gray"),
                         withSpinner(infoBoxOutput("total_apartment", width = 12), type = 8, size = 0.5, color = "gray"),
                         withSpinner(valueBoxOutput("cheapest", width = 12), type = 8, size = 0.5, color = "gray"),
                         withSpinner(valueBoxOutput("expensive", width = 12), type = 8, size = 0.5, color = "gray"),
                         withSpinner(valueBoxOutput("average", width = 12), type = 8, size = 0.5, color = "gray"),
                         h4("Note: See list of apartment available by scrolling down this page")
                       )
                     )
                   ),
                   column(
                     width = 5
                   ),
                   column(
                     width = 4,
                     imageOutput("list_image", height = "100%", width = "100%")
                   ),
                   
                   #List of available apartment
                   column(
                     width = 12,
                     dataTableOutput("apartment_table")
                   )
                 )
             )
    ),
    
    #---------------PREDICT PRICE TAB---------------
    
    tabPanel("Predict Price",
             value = "price_tab",
             
             #Custom hover button
             tags$style(HTML("
                             .btn-1:hover{
                             box-shadow:inset -10em 0 0 0 #2ECBE9;
                             }
                             ")),
             fluidPage(
               scrollable = T,
               
               #Select Panel
               column(
                 width = 3,
                 absolutePanel(
                   fixed = F, draggable = F, top = 10, left = 0, right = "auto", bottom = "auto", width = "80%", height = "auto", id = "controls", class = "panel panel-default",
                   h3("Select Characteristics"),
                   selectInput(inputId = "select_district2", label = "Select District: ", choices = sort(unique(apartment_for_map$District))),
                   uiOutput(outputId = "second_selection2"),
                   selectInput(inputId = "select_bedroom", label = "Number of Bedroom: ", choices = sort(unique(apartment_for_map$Bedroom))),
                   selectInput(inputId = "select_bathroom", label = "Number of Bathroom: ", choices = sort(unique(apartment_for_map$Bathroom))),
                   sliderInput(inputId = "areas", label = "Select Apartment Total Area:", value = 12, min = 12, max = 150), 
                   h4("Note: Number of Bathroom must be lower or equal to Number of Bedroom"),
                   actionButton(inputId = "action", label = "Process!", class = "btn-1")
                   
                 )
                 
               ),
               
               column(
                 width = 9,
                 
                 # Prediction Result
                 valueBox(value = valueBoxOutput("prediction_result", width = 22),
                          width = "100%",
                          subtitle = h3("Prediction Result", align = "Center"),
                          color = "light-blue"
                 ),
                 
                 #Sub Tab Recommendation_________________________________
                 tabsetPanel(type = "tabs",
                   tabPanel("Recommendation",
                            
                            column(
                              width = 12,
                              class = "space_box"
                            ),
                            
                            #Image 1
                            column(
                              width = 12,
                              class = "box-margin-top",
                              
                              imageOutput("pred_image1", height = "100%", width = "100%")
                            ),
                            
                            #List of recommendation apartment in same district
                            column(
                              width = 12,
                              class = "box-height",
                              
                              dataTableOutput("apartment_predict")
                            ),
                            
                            #Image 2
                            column(
                              width = 12,
                              class = "box-margin-top",
                                        
                              imageOutput("pred_image2", height = "100%", width = "100%")           
                            ),
                            
                            #List of recommendation apartment in different district
                            column(
                              width = 12,
                              class = "box-height box-margin-bot",
                              ("apartment_recom")
                            )
                   ),
                   
                   #Sub Tab Price Distribution_________________________________
                   tabPanel("Price Distribution",
                            
                            #Intro text
                            column(
                              width = 12,
                              div(
                                HTML(paste(
                                  "<h4 style='text-align: center;line-height: 1.5;'>You can compare the predicted price with the average price of other apartments in different sub-districts with the same characteristics (same district, number of bedrooms and number of bathrooms)</h5>"
                                ))
                              )
                            ),
                            
                            #Average price bar plot output
                            column(
                              width = 12,
                              withSpinner(plotlyOutput(outputId = "distribution_table"), type = 8, size = 0.5, color = "gray")
                            )
                            
                   ),
                   
                   #Sub Tab Frequencies_________________________________
                   tabPanel("Frequencies",
                            
                            #Intro Text
                            column(
                              width = 12,
                              div(
                                HTML(paste(
                                  "<h4 style='text-align: center;line-height: 1.5;'>See the characteristics of the best selling apartments on the market in your choosen district</h5>"
                                ))
                              )
                            ),
                            
                            #Donuts plot of apartment bedroom type
                            column(
                              width = 6,
                              withSpinner(plotOutput(outputId = "bedroom_freq"), type = 8, size = 0.5, color = "gray")
                            ),
                            
                            #Donuts plot of apartment bathroom type
                            column(
                              width = 6,
                              withSpinner(plotOutput(outputId = "bathroom_freq"), type = 8, size = 0.5, color = "gray")
                            ),
                            
                            column(
                              width = 1
                            ),
                            
                            #Plot description
                            column(
                              width = 4,
                              div(
                                HTML(paste(
                                  "<h4 style='text-align: center;line-height: 1.5;'>This plot shows total number of apartment bedroom</h5>"
                                ))
                              )
                            ),
                            
                            column(
                              width = 2
                            ),
                            
                            #Plot description
                            column(
                              width = 4,
                              div(
                                HTML(paste(
                                  "<h4 style='text-align: center;line-height: 1.5;'>This plot shows total number of apartment bathrooms</h5>"
                                ))
                              )
                            ),
                            column(
                              width = 1
                            ),
                            
                            #Donuts plot of apartment type
                            column(
                              width = 12,
                              withSpinner(plotOutput(outputId = "tpye_freq"), type = 8, size = 0.5, color = "gray")
                              
                            ),
                            
                            column(
                              width = 4
                            ),
                            
                            #Plot description
                            column(
                              width = 4,
                              div(
                                HTML(paste(
                                  "<h4 style='text-align: center;line-height: 1.5;'>This plot shows total number of apartment type</h5>"
                                ))
                              )
                            ),
                            column(
                              width = 4
                            ),
                            
                            #Note description
                            column(
                              width = 12,
                              div(
                                HTML(paste(
                                  "<h4 style='text-align: center;line-height: 1.5;'><center>Note: Micro is an apartment with total area between 12-24m², Studio is around 25-44m²,
                                   1-Bed is around 45-75m² with only 1 bedroom and 1 bathroom, 2-Bed is around 55-95m² with 2 bedroom and 2 bathroom or less,
                                   3-Bed is around 76-130m² with 3 bedroom and 3 bathroom or less and 4-Bed is around 90-150m² with 4 bedroom and bathroom or less</center></h5>"
                                ))
                              )
                            )
                   )
                 )
               )
             )
    ),
    
    #---------------ABOUT TAB---------------
    navbarMenu("About",
               
               #Sub Tab Architecture_________________________________
               tabPanel(
                 title = "Architecture",
                 fluidRow(
                   column(
                     width = 3,
                     class = "box-heights-arch-head"
                   ),
                   
                   #Head image output
                   column(
                     width = 6,
                     class = "box-heights-arch-head",
                     imageOutput("architectureHead", height = "100%", width = "100%")
                   ),
                   column(
                     width = 3,
                     class = "box-heights-arch-head"
                   ),
                   
                   #Architecture image output
                   column(
                     width = 12,
                     class = "box-heights-arch",
                     imageOutput("architecture")
                   ),
                   column(
                     width =1
                   ),
                   
                   column(
                     
                     #Architecture text decription
                     style = "text-align:justify;
                              font-size: 15px;
                              color:black;
                              background-color: whitesmoke ;
                              border-color:black;
                              padding:15px;
                              border-radius:10px;
                              border-size:15px",
                     collapsible = F,
                     width = 10,
                     div(
                       HTML(paste(
                         "
                         <b><center><u>Architecture</b></center></u><br>
                         HomeScape is an apartment search application that can help people find apartments according to the criteria they want in Jakarta. 
                         Unlike other applications, HomeScape is equipped with a price prediction feature so that the system can provide price recommendations based on the selected criteria. 
                         Also this application is equipped with an analysis in the form of price distribution and the type of apartment that is being sold most in the market, so that users can make further considerations.
                         <br><br>
                         The data used in this application is updated data obtained through a web scraping process (I'm using python to do scrapping with beautifulsoup package) on the lamudi.co.id website. 
                         To get a deeper understanding of how architecture, you can visit this Github link.
                         <br>
                         <a href= https://github.com/MF-Faqih/capstone_da_BikeSharingAPI><center>Github - HomeScape Architecture Link</a></center>
                         "
                       ))
                     )
                   )
                 )
               ),
               
               #Sub Tab My Profile_________________________________
               tabPanel(
                 title = "My Profile",
                 fluidRow(
                   
                   #Personal Photo
                   column(
                     br(),
                     imageOutput("myImage", height = "100%", width = "100%"),
                     align = "center",
                     style = "margin-bottom: 10px;",
                     style = "margin-top: -10px;",
                     width = 2
                   ),
                   
                   #Greetings and short personal description text
                   column(
                     width = 10,
                     div(
                       style="text-align:justify;
                              font-size: 15px;
                              color:black;
                              background-color: whitesmoke ;
                              border-color:black;
                              padding:15px;
                              border-radius:10px;
                              border-size:15px;
                              height: 310px",
                       
                       HTML(
                         paste(
                         "<b><center><h2>Hi There, nice to meet you!</center></u></b></h2>
                          <br>
                          <center>
                          Before you go, I'd like to say thankyou verymuch for visiting my project. My name is Muhammad Fadhlurrohman Faqih. I'm from Cilegon, Banten, but you can simply call me Faqih.
                          As someone who loves to learn, I have a strong sense of curiosity, desire to keep learning, adaptable and able to work in a team. Long Live Learner!.
                          I'm graduate from Universitas Diponegoro for Associate's Degree of Mechanical Engineering, also, I continued my undergraduate education in Jember University with the same major.
                          I have 1-year experience as Mechanic at PT. Indah Kiat Pulp & Paper, Tbk. I also have 4 months of experience working as an engineer at PT. KPDP, with additional Data Science certified skill from Algpritma Data Science School and Certified Statistic for Data Science and Business Analysis from Udemy. 
                          My passion lies in the field of data analysis and data science, as well as statistics. I possess a strong understanding of programming languages such as Python, R and some knowledge of SQL. 
                          With a strong passion for data science, I aspire to further develop and build my career in this field. Here, you can see my CV to know more about me.
                          </center>
                          <br>"
                         )
                       ),
                       
                       #Download button for CV
                       column(
                         width = 12,
                         downloadButton("downloadData", "Curriculum Vitae (CV)"), 
                         align = "center"
                       )
                     )
                   ),
                   column(
                     width = 12,
                     div(
                       style="height:30px"
                     )
                   ),
                   
                   fluidRow(
                     
                     #Recent project text
                     column(
                       width = 12,
                       div(
                         style="text-align:justify;
                          font-size: 15px;
                          color:black;
                          border-color:black;
                          border-radius:10px;
                          border-size:15px
                         ",
                         HTML(
                           paste("<b><center><h4><u>My Recent Project</center></u></b></h4><br>")
                         )
                       )
                     ),
                     
                     #First project description text
                     box(
                       style = "color: black; background-color: whitesmoke; border-color: whitesmoke",
                       collapsible = F,
                       width = 4,
                       div(
                         HTML(paste("<b><center><u>Restaurant Visitor Forcasting</b></center></u><br>
                              <h5 style='text-align: justify;line-height: 1.5;'>This is my third capstone project at Algoritma, I made a model to forecast the visitor of a restaurant. 
                              The data I used contain multisasonal data, so I choose to use STLM model with ARIMA as it's method to handle this.</h5>
                              <br><h5>- Application link: </h5><a href= https://rpubs.com/MF-Faqih/reastaurant-visitor-forcasting><b><i><h5>Click Here!</b></i></a></h5>")))
                     ),
                     
                     #RPubs description text
                     box(
                       style = "color: black; background-color: whitesmoke; border-color: whitesmoke;",
                       collapsible = F,
                       width = 4,
                       div(
                         HTML(paste("<b><center><u>RPubs Documentation</b></center></u><br>
                              <h5 style='text-align: justify; line-height: 1.5;'>To improve my skill in data science field, I wrote some simple researcs and analysis combined with machine learning in seceral field, such as finance, health, F&B etc.
                              I will also keep updating my project here</h5>
                              <br><h5>- Application link: </h5><a href= https://rpubs.com/MF-Faqih><b><i><h5>Click Here!</b></i></a></h5>")))
                     ),
                     
                     #Second project description text
                     box(
                       style = "color: black; background-color: whitesmoke; border-color: whitesmoke",
                       collapsible = F,
                       width = 4,
                       div(
                         HTML(paste("<b><center><u>Mexico Covid Case</b></center></u><br>
                              <h5 style='text-align: justify; line-height: 1.5;'>This is my second capstone project at Algoritma, I build simple dashboard about covid case in mexico during 2020-2021. 
                              In this analysis I can some useful insgiht such as type of factor that contribute the most to covid death rate.</h5>
                              <br><h5>- Application link: </h5><a href= https://mffaqih.shinyapps.io/CP-Davis/><b><i><h5>Click Here!</b></i></a></h5>")))
                     )
                   ),
                   
                   fluidRow(
                     
                     #First project gif
                     column(
                       imageOutput("firstGif", width = "100%", height = "100%"),
                       width = 4
                     ),
                     
                     #RPubs image
                     column(
                       imageOutput("rpubs", width = "100%", height = "100%"),
                       width = 4
                     ),
                     
                     #Second project gif
                     column(
                       imageOutput("thirdGif", width = "100%", height = "100%"),
                       width = 4
                     )
                   )
                   
                 )
               )
      
      
    ),
    
    div(class = "footer",
        includeHTML("html/footer2.Rhtml")
    )
    
  )
  
)