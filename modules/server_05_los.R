############ [ Length of stay ] ##############  

### 1 - Dynamic filters ----

#There are two filters here: SELECT HEALTH BOARD OF TREATMENT and SELECT...
#TREATMENT SPECIALTY.
#The reactive() command below creates a subset of the length of stay...
#dataset based on the user's selections in these two filters.
#This subset will then "feed" the length of stay chart.

los_new <- reactive({
  length.of.stay %>%
    filter(geography2 %in% input$los_location_type
           & Stay_Specialty %in% input$los_measure_type)
})

# Create the length of stay chart.

output$los_plot <- renderPlotly({
  
  if(sum(los_new()$Number) == 0 & 
     !is.na(sum(los_new()$Number))) 
    
  { 
    
    # Account for the possibility that a health board had no stays.
    # Create a message for this.
    
    text_no_stays_found <- list(
      x = 5, 
      y = 2, 
      font = list(color = "#0072B2", size = 20),
      text = paste0("No stays found for these selections."),
      xref = "x", 
      yref = "y",  
      showarrow = FALSE
    )
    
    # Visualise an empty graph with the above message in the middle.
    
    plot_ly() %>% 
      layout(annotations = text_no_stays_found, 
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
    
    ### 2 - Tooltip creation ----
    
    # Create the tooltip, i.e., insert the information that appears when you...
    # hover your mouse over a dot in the length of stay graph.
    
    tooltip_los <- paste0("Financial year: ", 
                          los_new()$fyear, "<br>",
                          "Health board of treatment: ",
                          los_new()$geography2, "<br>",
                          "Specialty: ", 
                          input$los_measure_type, "<br>",
                          "Length of stay category: ",
                          los_new()$length_of_stay_cat, "<br>", 
                          "Number of stays: ",
                          los_new()$Number)
    
    ### 3 - Create the main body of the chart ----
    
    plot_ly(data = los_new(), 
            
            # Select your variables.
            
            x = ~fyear, y = ~Number, color = ~length_of_stay_cat,
            
            ### 4 - Assign colours for LoS categories ----
            
            colors = c(rep("#99CCFF", 2), 
                       rep("#0080FF", 2), 
                       "#004C99"),
            
            text = tooltip_los, hoverinfo = "text", 
            
            ### 5 - Chart type selection ----
            
            # Select the type of chart you want, in this case a scatter...
            # plot, but set the mode to 'lines+markers' in order to...
            # transform it into a line chart.
            # Set the width and height of the plot.
            # Set the line width and marker (i.e., dot) size.
            # Then, each length of stay category gets assigned its own type...
            # of line. We differentiate further by assigning each category...
            # its own symbol (i.e., type of "dot"). 
            # The "name" attribute tells plotly which variable to base the...
            # legend labels on. We use a string wrapper, so that only 10...
            # characters are visualised per line. This is meant to deal with...
            # LOS categories with long names.
            
            type = 'scatter', mode = 'lines+markers',
            width = 1000, height = 650,
            line = list(width = 3),
            marker = list(size = 12),
            linetype = ~length_of_stay_cat,
            linetypes = c(rep(c("solid", "dot"), 3)),
            symbol = ~length_of_stay_cat, 
            symbols = c("circle", "square", "circle-open", "square-open", "x"),
            name = ~str_wrap(length_of_stay_cat, 26)
    ) %>%
      
      ### 6 - Graph title ----
    
    # Make the graph title reactive.
    
    layout(title = 
             paste0(
               "<b>",
               if(input$los_measure_type == "Psychiatric stays") 
               {paste0("Number of psychiatric stays in ")}
               else if(input$los_measure_type == "Non-psychiatric stays") 
               {paste0("Number of non-psychiatric stays in ")}
               else {paste0("Number of stays in any specialty in ")},
               input$los_location_type, ",", 
               "<br>", 
               " by length of stay category, ",
               first(as.vector(los_new()$fyear)), 
               " - ", 
               last(as.vector(los_new()$fyear)),
               "<br>",
               "</b>"
             ),
           
           separators = ".",
           
           ### 7 - Set y axis min range to Zero -------
           
           # We need to fix the range of the y axis, as R refuses to set...
           # the lower end of this axis to zero.
           # The following "range" command fixes the lower end to...
           # zero, and calculates the upper end as the maximum...
           # number visualised in the graph + 10% of this number.
           
           yaxis = list(
             
             exponentformat = "none",
             
             separatethousands = TRUE,
             
             range = c(0, max(los_new()$Number, na.rm = TRUE) + 
                         (max(los_new()$Number, na.rm = TRUE) 
                          * 10 / 100)), 
             
             ### 8 - Axes titles ----
             
             #Insert the titles of the axes.
             
             #Wrap the y axis title in blank spaces so it doesn't...
             #overlap with the y axis tick labels.
             
             title = paste0(c(
               rep("&nbsp;", 20),
               "Number of stays", 
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
           
           ### 9 - Margins ----
           
           # Fix the margins so that the graph and axis titles have enough...
           # room to display nicely.
           
           margin = list(l = 90, r = 60, b = 180, t = 120),
           
           ### 10 - Font sizes ----
           
           font = list(size = 13),
           title = list(size = 15),
           
           ### 11 - Legend ----
           
           #Insert a legend so that the user knows which type of line...
           #corresponds to which length of stay category.
           #Make the legend background and legend border white.              
           
           showlegend = TRUE,
           legend = list(x = 1, 
                         y = 1,
                         bgcolor = 'rgba(255, 255, 255, 0)', 
                         bordercolor = 'rgba(255, 255, 255, 0)')) %>%
      
      ### 12 - Remove unnecessary buttons from the modebar ----
    
    config(displayModeBar = TRUE,
           modeBarButtonsToRemove = list('select2d', 'lasso2d', 'zoomIn2d', 
                                         'zoomOut2d', 'autoScale2d', 
                                         'toggleSpikelines', 
                                         'hoverCompareCartesian', 
                                         'hoverClosestCartesian'), 
           displaylogo = F, editable = F)
    
  }
  
})

### 13 - Reactive to susbet data for table below graph ----

# This reactive() creates the subset that will be used to create the table...
# appearing under the length of stay chart.

table_los <- reactive({
  length.of.stay %>% 
    filter(geography2 %in% input$los_location_type
           & Stay_Specialty %in% input$los_measure_type)
})

### 14 - Create table below graph ----

# We now create the table that will go under the length of stay chart.
# We give the columns clearer names.

output$los_table <- renderDataTable({
  datatable(table_los(), 
            style = 'bootstrap', 
            class = 'table-bordered table-condensed', 
            rownames = FALSE, 
            options = list(pageLength = 16, autoWidth = TRUE, dom = 'tip'),
            colnames = c("Financial year", 
                         "Health board of treatment", 
                         "Specialty",
                         "Length of stay category",
                         "Number of stays"))
})
