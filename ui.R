### UI script ----

# secure_app( #If password protection is needed.
fluidPage(
  
  ### 2 - Force desktop version ----
  
  # The following command forces R to display the desktop version of the page,...
  # no matter what device the user has (mobile phone, tablet, desktop, etc).
  # This is a temporary solution until we develop a Shiny app that's...
  # optimised for mobile devices.
  
  HTML('<meta name="viewport" content="width=1200">'),
  
  style = "width: 100%; height: 100%; max-width: 1200px;", 
  tags$head( 
    tags$style(
      type = "text/css",
      
      ### 3 - Prevent error messages ----
      
      # Prevent error messages from popping up on the interface.
      
      ".shiny-output-error { visibility: hidden; }", 
      ".shiny-output-error:before { visibility: hidden; }"
      
    )
  ),
  
  ### 4 - Page break style ----
  
  # Style the horizontal line that you will be using below as a page break.
  # These are global attributes, i.e., they will apply to all the page breaks...
  # in the User Interface.
  
  tags$head(tags$style(HTML("hr { border: 1px solid #000000; }"))),
  
  ### 5 - Title panel ----
  
  # Open a title panel. Here, you can insert the publication title and specify...
  # the name of the window.
  
  ## Commented out as web page already has a title
  # titlePanel(title = div(h1("Mental health inpatient activity"),
  #                        h4("A National Statistics publication for Scotland"), 
  #                        style = "height:96px;"),
  #            windowTitle = "Mental health inpatient activity"),
  # 
  # # First page break.
  # 
  # hr(),
  # 
  ### 6 - Main tab ----
  
  # Open a tabPanel(), which will essentially contain all of our output, and...
  # give it a title with h1.
  
  tabPanel(title = "",
           
           style = "float: top; height: 95%; width: 95%;
           background-color: #FFFFFF; border: 0px solid #FFFFFF;",
           
           # h1(tags$b("Trend data"), id = 'Top'),
           
           ### 7 - Page content explanation and Contents hyperlinks ----
           
           # Explain the content of the page, and hyperlink the charts.
           
           p("The graphs below provide an overview of inpatient admissions and 
             discharges in Scotland over time. The data can be viewed at a 
             Scotland, health board, or hospital level. The page also includes 
             a length of stay analysis broken down by health board."),
           
           p("Contents:",
             tags$ul(
               tags$li(tags$a(href = '#admissions_link', tags$b("Admissions"))),
               tags$li(tags$a(href = '#discharges_link', tags$b("Discharges"))),
               tags$li(tags$a(href = '#discharges_types_link_scot', tags$b("Discharge types: National Level"))),
               tags$li(tags$a(href = '#discharges_groups_link_hb', tags$b("Discharge groups: Health Board of Treatment Level"))),
               tags$li(tags$a(href = '#los_link', tags$b("Length of stay")))
               
               
             )
           ),
           
           ### 8 - Page explanation text ----
           
           # Explain how to use the various functions on this page.
           
           p("Use the filters to visualise the data you are interested in. To 
             view your data selection in a table, use the 'Show/hide table' 
             button under each graph. At the top-right corner of each graph, 
             you will see a toolbar with four buttons:"),
           
           tags$ul(
             tags$li(tags$b("Download plot as a png"), 
                     icon("camera"), 
                     " - click this button to save the graph as an image 
                     (please note that Internet Explorer does not support this 
                     function)."),
             tags$li(tags$b("Zoom"), 
                     icon("search"), 
                     " - zoom into the graph by clicking this button and then 
                     clicking and dragging your mouse over the area of the 
                     graph you are interested in."),  
             tags$li(tags$b("Pan"), 
                     icon("move", lib = "glyphicon"), 
                     " - adjust the axes of the graph by clicking this button 
                     and then clicking and moving your mouse in any direction
                     you want."),  
             tags$li(tags$b("Reset axes"), 
                     icon("home"), 
                     " - click this button to return the axes to their 
                     default range.")
           ),
           
           ### 9 ---
           
           # Inform users that we have created a glossary for them, and insert...
           # a download button for it.
           # Also, inform them of the existence of a data explorer. 
           # Then, provide the contact details of the team.
           # Finally, insert the standard note regarding statistical disclosure...
           # control.
           
           p("To help you understand the information visualised here, we have 
             created a glossary of commonly used terms in mental health care. 
             Click the button below to download the glossary:"),
           
           downloadButton(outputId = "download_glossary_one", 
                          label = "Download glossary", 
                          class = "glossaryone"),
           
           tags$head(
             tags$style(".glossaryone { background-color: #0072B2; } 
                        .glossaryone { color: #FFFFFF; }")
           ),
           
           p(br(), 
             HTML(paste0(
               'The data used to create the below graphs can be downloaded in CSV 
                format from the  
                <b> <a href = "https://www.opendata.nhs.scot/dataset/mental-health-inpatient-activity">Scottish Health and Social Care Open Data Portal</a></b>.'
             ))),
           
           p("If you experience any problems using this dashboard, or have 
             any questions relating to the data, please contact us at: ",
             HTML(paste0('<b> <a href = "mailto:phs.mentalhealthanalytics@phs.scot">phs.mentalhealthanalytics@phs.scot</a></b>.'))),
           
           p(tags$b(
             "Note: Statistical disclosure control has been applied to protect
             patient confidentiality, with data being rounded to the nearest 5. 
             Percentages referenced in text under graphs have been rounded to 
             1 decimal place. As a result, the figures presented here may not be 
             additive and may differ to previous sources of information. For 
             more information, please refer to the ",
             tags$a(
               href = "https://publichealthscotland.scot/publications/public-health-scotland-statistical-disclosure-protocol/", 
               "PHS Statistical Disclosure Control Protocol."
             ), 
             ""
           )),
           
           p(""),
           
           #Second page break.
           
           hr(),
           
           
           #### [[ Graph Visualisaitons ]] ####
           
           
           #### [ Admissions ] ####
           
           
           ### 1.1 - Admissions graph header ----
           
           # Provide a header for the admissions graph.
           
           h3("Admissions", id = 'admissions_link'),
           
           br(),
           
           ### 1.2 - Admissions reactive filters ----
           
           # Insert the reactive filters for the admissions graph.
           
           column(3,
                  
                  uiOutput("adm_location_types")
                  
           ),
           
           column(3, 
                  
                  uiOutput("adm_locations")
                  
           ),
           
           column(3,
                  
                  shinyWidgets::pickerInput(
                    inputId = "adm_measure_type",
                    label = "Select measure", 
                    choices = act_adm_measures, 
                    selected = "Admissions in any specialty"
                  )
                  
           ),
           
           ### 1.3 - Insert Admissions graph ----
           
           # In the main panel of the admissions graph, insert the graph, the...
           # 'Show/hide table' button, and the admissions table.
           
           mainPanel(
             width = 12,
             plotlyOutput("adm_plot",
                          width = "1090px",
                          height = "650px"),
             br(),
             br(),
             HTML("<button data-toggle = 'collapse' href = '#adm_table_l'
                  class = 'btn btn-primary' id = 'adm_table_link'> 
                  <strong> Show/hide table </strong></button>"),
             HTML("<div id = 'adm_table_l' class = 'collapse'>"),
             br(),
             dataTableOutput("adm_table"),
             HTML("</div>"),
             br(),
             br(),
             
             ### 1.4 - Admissions main point ----
             
             # Write a main point for Scotland, i.e., summarise the "story"...
             # behind the admissions graph.
             
             br(),
             br(),
             p(tags$b("Main trend (Scotland):"),
               tags$ul(
                 tags$li(
                   "Over the past 26 years, admissions for mental health conditions 
                   in non-psychiatric specialties have tripled, from 9,450 to 29,205. 
                   At the same time, admissions in psychiatric specialties have decreased 
                   from 32,010 to 18,475. Over the same period total admissions 
                   in any speciality have increased from 41,460 to 47,680 with a 
                   peak of 51,720 in 2019/20."),
                 tags$li(
                   "Total admissions in any specialty for mental health conditions 
                   reached its lowest point in 2009/10, at 34,645. That number is 
                   roughly 37.6% higher (47,680) in 2022/23.")
               )
             ),
             
             br(),
             
             ### 1.5 - Back to top button ----
             
             # Add a button that allows the user to go back to the top of the...
             # page.
             
             tags$a(href = '#Top', 
                    icon("circle-arrow-up", 
                         lib = "glyphicon"), 
                    "Back to top"),
             
             # Third page break.
             
             hr(),
             
             
             
             #### [ Discharges ] ####
             
             ### 2.1 - Header for the discharges graph ----
             
             h3("Discharges", id = 'discharges_link'),
             
             br(),
             
             ### 2.2 - Reactive filters for the discharges graph ----
             
             column(3,
                    
                    uiOutput("dis_loc_type_output")
                    
             ),
             
             column(3, 
                    
                    uiOutput("dis_locations_output")
                    
             ),
             
             column(3,
                    
                    shinyWidgets::pickerInput(
                      inputId = "dis_measure_type",
                      label = "Select measure", 
                      choices = act_disch_measures, 
                      selected = "Discharges from any specialty"
                    )
                    
             ),
             
             br(),
             br(),
             br(),
             br(),
             
             ### 2.3 - Insert Discharges graph ----
             
             # In the main panel of the discharges graph, insert the graph, the...
             # 'Show/hide table' button, and the discharges table.
             
             plotlyOutput("dis_plot",
                          width = "1090px",
                          height = "650px"),
             br(),
             br(),
             HTML("<button data-toggle = 'collapse' href = '#dis_table_l'
                  class = 'btn btn-primary' id = 'dis_table_link'> 
                  <strong> Show/hide table </strong></button>"),
             HTML("<div id = 'dis_table_l' class = 'collapse'>"),
             br(),
             dataTableOutput("dis_table"),
             HTML("</div>"),
             br(),
             br(),
             
             ### 2.4 - Discharges main point ----
             
             # Write a main point for Scotland, i.e., summarise the "story"...
             # behind the discharges graph.
             
             br(),
             br(),
             p(tags$b("Main trend (Scotland):"),
               tags$ul(
                 tags$li(
                   "Over the past 26 years, discharges for mental health conditions 
                   from non-psychiatric specialties have more than tripled, from 
                   9,485 to 29,660. At the same time, discharges from psychiatric 
                   specialties have decreased from 32,300 to 18,490. Over the same 
                   period total discharges in any speciality have increased from 
                   41,785 to 48,150 with a peak of 52,550 in 2019/20."),
                 tags$li(
                   "Total discharges in any specialty for mental health conditions 
                   reached its lowest point in 2009/10, at 34,760. That number is 
                   roughly 38.5% higher (48,150) in 2022/23.")
               )
             ),
             
             br(),
             
             # Another 'Back to top' button.
             
             tags$a(href = '#Top',  
                    icon("circle-arrow-up", 
                         lib = "glyphicon"), 
                    "Back to top"),
             
             # Fourth page break.
             
             hr(),
             
             
             ####  [ Discharge Types Scot]  ####
             
             ### 3.1 - Discharge Types Scot header ----
             
             h3("Discharge Types: National Level", id = 'discharges_types_link_scot'),
             
             br(),
             
             ### 3.2 - Reactive filters ----
             
             # Insert the reactive filters for the discharge types graph.
             
             column(12, 
                    shinyWidgets::pickerInput(
                      inputId = "dis_type_scot_input",
                      label = "Select discharge type(s) (Maximum 4)",
                      choices = dis.type.scot,
                      multiple = TRUE,
                      options = list("max-options" = 4,
                                     `selected-text-format` = "count > 1"),
                      selected = "10 - Regular discharge (No additional detail added)")
             ),
             
             
             br(),
             br(),
             br(),
             br(),
             
             
             ### 3.3 - Insert discharge type graph ----
             
             # In the main panel of the discharges graph, insert the graph, the...
             # 'Show/hide table' button, and the discharges table.
             
             plotlyOutput("dis_type_scot_plot",
                          width = "1090px",
                          height = "650px"),
             br(),
             br(),
             HTML("<button data-toggle = 'collapse' href = '#dis_type_table_l'
                  class = 'btn btn-primary' id = 'dis_type_table_link'> 
                  <strong> Show/hide table </strong></button>"),
             HTML("<div id = 'dis_type_table_l' class = 'collapse'>"),
             br(),
             dataTableOutput("dis_type_scot_table"),
             HTML("</div>"),
             br(),
             br(),
             
             ### 3.4 - Discharge type main points ----
             
             # Write a main point for Scotland, i.e., summarise the "story"...
             # behind the discharges graph.
             
             br(),
             br(),
             p(tags$b("Main trend (Scotland):"),
               tags$ul(
                 tags$li("Since 2012/13, transfers within the same Health Board/Health 
                          Care Provider have grown steadily to become the largest 
                          discharge type overall, more than doubling from 8,020 to 21,895 per year.
                          Over the same period transfers to another health board/healthcare 
                          provider decreased from 570 to 385."),
                 tags$li("Between 2019/20 and 2020/21, patients discharging themselves 
                         against medical advice saw roughly a 23.4% increase from 1,005 to 1,240. 
                         This number has fallen to 945 in 2022/23")
               )
             ),
             
             br(),
             
             # Another 'Back to top' button.
             
             tags$a(href = '#Top',  
                    icon("circle-arrow-up", 
                         lib = "glyphicon"), 
                    "Back to top"),
             
             # fourth page break.
             
             hr(),
             
             ####  [ Discharge Groups HB]  ####
             
             ### 3.1 - Discharge Groups HB header ----
             
             h3("Discharge Types: Health Board of Treatment Level", 
                id = 'discharges_groups_link_hb'),
             
             br(),
             
             ### 3.2 - Reactive filters ----
             
             # Insert the reactive filters for the discharge types graph.
             
             column(4, 
                    shinyWidgets::pickerInput(
                      inputId = "dis_group_location_input",
                      label = "Select health board of treatment",
                      choices = dis.type.location.hb,
                      selected = "NHS Ayrshire & Arran")
             ),
             
             column(4, 
                    shinyWidgets::pickerInput(
                      inputId = "dis_group_hb_input",
                      label = "Select discharge type group(s)",
                      choices = dis.groups.hb,
                      multiple = TRUE,
                      options = list("max-options" = 3,
                                     `selected-text-format` = "count > 1"),
                      selected = "Regular Discharge")
             ),
             
             
             br(),
             br(),
             br(),
             br(),
             
             
             ### 3.3 - Insert discharge group graph ----
             
             # In the main panel of the discharges graph, insert the graph, the...
             # 'Show/hide table' button, and the discharges table.
             
             plotlyOutput("dis_group_hb_plot",
                          width = "1090px",
                          height = "650px"),
             br(),
             br(),
             HTML("<button data-toggle = 'collapse' href = '#dis_group_table_l'
                  class = 'btn btn-primary' id = 'dis_group_table_link'> 
                  <strong> Show/hide table </strong></button>"),
             HTML("<div id = 'dis_group_table_l' class = 'collapse'>"),
             br(),
             dataTableOutput("dis_group_hb_table"),
             HTML("</div>"),
             br(),
             br(),
             
             ### 3.4 - Discharge group main points ----
             
             # Write a main point for Scotland, i.e., summarise the "story"...
             # behind the discharges graph.
             
             br(),
             br(),
             p(tags$b("Main trend (Scotland):"),
               tags$summary("Since 2012/13 the biggest changes in discharges can be found 
                          within 2 Health Boards, in the regular discharge type:"),
               tags$ul(
                 tags$li("NHS Greater Glasgow and Clyde shows the the largest 
                         increase in regular discharges, almost doubling from 
                         8,885 to 14,435 between 2012/13 and 2022/23."),
                 tags$li("NHS Forth Valley shows the next largest increase in 
                         regular discharges, increasing from 1,385 to 3,490 
                         between 2012/13 and 2022/23, with a sharp rise in 2019/20.")
               )
             ),
             
             br(),
             
             # Another 'Back to top' button.
             
             tags$a(href = '#Top',  
                    icon("circle-arrow-up", 
                         lib = "glyphicon"), 
                    "Back to top"),
             
             # fourth page break.
             
             hr(),
             
             
             #### [ Length of Stay ] ####
             
             ### 4.1 - LoS Graph header ----
             
             # Header for the length of stay graph.
             
             p(h3("Length of stay", id = 'los_link')),
             
             br(),
             
             ### 4.2 - LoS Reactive filters ----
             
             # Insert the reactive filters for the length of stay graph.
             
             column(4,
                    
                    shinyWidgets::pickerInput(
                      inputId = "los_location_type",
                      label = "Select health board of treatment", 
                      choices = los_loc_names, 
                      selected = "Scotland"
                    )
                    
             ),
             
             column(4,
                    
                    shinyWidgets::pickerInput(
                      inputId = "los_measure_type",
                      label = "Select stay specialty", 
                      choices = los_measures, 
                      selected = "Stays in any specialty"
                    )
                    
             ),
             
             br(),
             br(),
             br(),
             br(),
             
             ### 4.3 - Insert LoS Graph ----
             
             # In the main panel of the length of stay graph, insert the graph,...
             # the 'Show/hide table' button, and the length of stay table.
             
             plotlyOutput("los_plot",
                          width = "1090px",
                          height = "650px"),
             br(),
             br(),
             HTML("<button data-toggle = 'collapse' href = '#los_table_l'
                  class = 'btn btn-primary' id = 'los_table_link'> 
                  <strong> Show/hide table </strong></button>"),
             HTML("<div id = 'los_table_l' class = 'collapse'>"),
             br(),
             dataTableOutput("los_table"),
             HTML("</div>"),
             br(),
             br(),
             
             ### 4.4 - LoS Main Point ----
             
             # Write a main point for Scotland, i.e., summarise the "story"...
             # behind the length of stay graph.
             
             br(),
             br(),
             p(tags$b("Main trend (Scotland):"),
               tags$ul(
                 tags$li("Between the years 1997/98 and 2022/23, there has generally been 
                         a reduction in the time spent as a psychiatric inpatient. This 
                         is due in part to the increase in community-based care. The 
                         number of mental health stays in non-psychiatric facilities has 
                         increased since 1997/98 but most of these stays are quite short 
                         (between 1 and 7 days).")
               ),
               
               br(),
               
               # Final 'back to top' button.
               
               tags$a(href = '#Top',  
                      icon("circle-arrow-up", 
                           lib= "glyphicon"), 
                      "Back to top")),
             hr()
             
           ) # Main panel ends.
           
    ) # Tab panel ends.
  
  ) # Fluid page ends.  ----

# )  # End of password protection. ----
