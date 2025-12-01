######## [ Admissions Server ] ###############   
          
# We start with the admission data.

### 1 - Dynamic filters ----

# The user's selection in the filter SELECT HEALTH BOARD OF TREATMENT...
# determines which choices appear in the filter SELECT HOSPITAL.
# The renderUI() command makes the process of creating these two dynamic... 
# filters very easy.

output$adm_location_types <- renderUI({
  shinyWidgets::pickerInput("adm_location_type", 
                            label = "Select health board of treatment",
                            choices = act_adm_loc_types, 
                            selected = "Scotland")
})

output$adm_locations <- renderUI({
  shinyWidgets::pickerInput( 
    "adm_location",
    label = "Select hospital",  
    choices = sort(
      unique(
        as.character(
          activity.admissions$hospital_name
          [activity.admissions$hbtreat_name %in% input$adm_location_type]
        )
      )
    ),
    selected = input$adm_location_type
  )
})


# There are three filters in total: SELECT HEALTH BOARD OF TREATMENT, SELECT...
# HOSPITAL, and SELECT MEASURE.
# The reactive() command below creates a subset of the admissions dataset...
# based on the user's selections in these three filters.
# This subset will then "feed" the admissions line chart.

adm_new <- reactive({
  activity.admissions %>%
    filter(hbtreat_name %in% input$adm_location_type
           & hospital_name %in% input$adm_location 
           & Trend_Type %in% input$adm_measure_type)
})


### 2 - Account for charts with no admissions ----

output$adm_plot <- renderPlotly({
  
  if(sum(adm_new()$Number) == 0 & 
     !is.na(sum(adm_new()$Number))) 
    
  { 
    
    # Account for the possibility that a hospital had no admissions.
    # Create a message for this.
    
    text_no_admissions_found <- list(
      x = 5, 
      y = 2, 
      font = list(color = "#0072B2", size = 20),
      text = paste0("No admissions found for these selections."),
      xref = "x", 
      yref = "y",  
      showarrow = FALSE
    )
    
    # Visualise an empty graph with the above message in the middle.
    
    plot_ly() %>% 
      layout(annotations = text_no_admissions_found, 
             yaxis = list(showline = FALSE, 
                          showticklabels = FALSE, 
                          showgrid = FALSE), 
             xaxis = list(showline = FALSE, 
                          showticklabels = FALSE, 
                          showgrid = FALSE)) %>%  
      config(displayModeBar = FALSE,
             displaylogo = F, editable = F) 
    
  }
  
  else {
    
    ### 3 - Tooltip creation ----
    
    # Create the tooltip, i.e., insert the information that appears when you...
    # hover your mouse over a dot in the admissions graph.
    
    tooltip_adm <- paste0("Financial year: ", 
                          adm_new()$year, "<br>",
                          "Health board of treatment: ",
                          adm_new()$hbtreat_name, "<br>",
                          "Hospital: ",
                          adm_new()$hospital_name, "<br>",
                          input$adm_measure_type, ": ",
                          adm_new()$Number)
    
    ### 4 - Create the main body of the chart ----
    
    plot_ly(data = adm_new(), 
            
            
            # Select your variables.
            
            x = ~year, y = ~Number, color = ~hospital_name,
            
            ### 5 - Line colour ----
            
            colors = c("#0080FF"), # dark blue colour for all lines
            
            text = tooltip_adm, hoverinfo = "text", 
            
            ### 6 - Chart type selection ----
            
            # Select the type of chart you want, in this case a scatter plot,
            # but set the mode to 'lines+markers' to transform into a line chart.
            # Set the width and height of the plot, and style the line and...
            # dots (markers).
            # The "name" attribute tells plotly which variable to base the...
            # legend labels on. We use a string wrapper, so that only 10...
            # characters are visualised per line. This is meant to deal with...
            # boards with long names, like NHS Greater Glasgow & Clyde.
            
            type = 'scatter', mode = 'lines+markers',
            width = 1000, height = 650,
            line = list(width = 3),
            marker = list(size = 12),
            name = ~str_wrap(hospital_name, 26)) %>%
      
      ### 7 - Graph title ----
    
    # Make the graph title reactive.
    
    layout(title = 
             paste0(
               "<b>", "Number of ", input$adm_measure_type, 
               " in ", input$adm_location, ",",
               "<br>",
               " by financial year, ",
               first(as.vector(adm_new()$year)), 
               " - ", 
               last(as.vector(adm_new()$year)),
               
               "<br>",
               "</b>"
             ),
           
           separators = ".",
           
           ### 8 - Set y axis min range to Zero ----
           
           # We need to fix the range of the y axis, as R refuses to set...
           # the lower end of this axis to zero.
           # The following "range" command fixes the lower end to...
           # zero, and calculates the upper end as the maximum...
           # number visualised in the graph + 10% of this number.
           
           yaxis = list(
             
             exponentformat = "none",
             
             separatethousands = TRUE,
             
             range = c(0, max(adm_new()$Number, na.rm = TRUE) + 
                         (max(adm_new()$Number, na.rm = TRUE) 
                          * 10 / 100)), 
             
             ### 9 - Axes titles ----
             
             # Wrap the y axis title in blank spaces so it doesn't...
             # overlap with the y axis tick labels.
             # Also, make the y axis title reactive.
             
             title = paste0(c(
               rep("&nbsp;", 20),
               input$adm_measure_type, 
               rep("&nbsp;", 20),
               rep("\n&nbsp;", 3)
             ), 
             collapse = ""),
             showline = TRUE, 
             ticks = "outside"
             
           ),
           
           # Set the x axis tick angle to minus 45. It's the only way for...
           # the x axis tick labels (fin. years) to display without...
           # overlapping with each other.
           # Also, wrap the x axis title in blank spaces so it doesn't...
           # overlap with the x axis tick labels.
           
           xaxis = list(tickangle = -45, 
                        title = paste0(c(rep("&nbsp;", 20),
                                         "<br>",
                                         "<br>",
                                         "Financial year",
                                         rep("&nbsp;", 20),
                                         rep("\n&nbsp;", 3)),
                                       collapse = ""),
                        showline = TRUE, 
                        ticks = "outside"),
           
           ### 10 - Margins ----
           # Fix the margins so that the graph and axis titles have enough...
           # room to display nicely.
           
           margin = list(l = 90, r = 60, b = 180, t = 120),
           
           ### 11 - Font Sizes ----
           
           font = list(size = 13),
           title = list(size = 15),
           
           ### 12 - Legend ----
           
           # Insert a legend so that the user knows which hospital they are...
           # looking at.
           # Make the legend background and legend border white.              
           
           showlegend = TRUE,
           legend = list(x = 1, 
                         y = 1, 
                         bgcolor = 'rgba(255, 255, 255, 0)', 
                         bordercolor = 'rgba(255, 255, 255, 0)')) %>%
      
      ### 13 - Remove unecessary buttons from modebar ----
    
    config(displayModeBar = TRUE,
           modeBarButtonsToRemove = list('select2d', 'lasso2d', 'zoomIn2d', 
                                         'zoomOut2d', 'autoScale2d', 
                                         'toggleSpikelines', 
                                         'hoverCompareCartesian', 
                                         'hoverClosestCartesian'), 
           displaylogo = F, editable = F)
    
  }
  
})

### 14 - Reactive to subset data for table below graph ----

# This reactive() creates the subset that will be used to create the table...
# appearing under the admissions chart.
# Remove the variable that explains the measure type, as we can just rename...
# the Value column to reflect the measure type selected (see below).

table_adm <- reactive({
  activity.admissions %>% 
    filter(hbtreat_name %in% input$adm_location_type
           & hospital_name %in% input$adm_location 
           & Trend_Type %in% input$adm_measure_type) %>% 
    select(-c(Trend_Type))
})

### 15 - Table below graph creation ----

# We now create the table that will go under the admissions line chart.
# We give the columns clearer names.
# The name of the last column, which is the value column, changes...
# according to the user's input in the filter SELECT MEASURE.

output$adm_table <- renderDataTable({
  datatable(table_adm(), 
            style = 'bootstrap', 
            class = 'table-bordered table-condensed', 
            rownames = FALSE, 
            options = list(pageLength = 16, autoWidth = TRUE, dom = 'tip'),
            colnames = c("Financial year", 
                         "Health board of treatment", 
                         "Hospital", 
                         input$adm_measure_type))
})
