# [ Discharges Types ] ----

# We continue with the discharge type graph.

## Dynamic filters ----

# The reactive() command below creates a subset of the discharge type dataset...
# based on the user's selection.
# This subset will then "feed" the discharges line chart.

dis_type_scot_new <- reactive({
  activity.dis.type.scot %>%
    filter(discharge_type %in% input$dis_type_scot_input 
           & measure %in% input$dis_type_scot_measure_input)
  
})


## Discharge types line chart ----
output$dis_type_scot_plot <- renderPlotly({
  
  if(sum(dis_type_scot_new()$value) == 0 & 
     !is.na(sum(dis_type_scot_new()$value))) 
    
  { 
    
    ### Account for charts with no admissions ----
    
    # Account for the possibility that a hospital had no discharges.
    # Create a message for this.
    
    na_disType_scot_text <- list(
      x = 5, 
      y = 2, 
      font = list(color = "#0072B2", size = 20),
      text = paste0("No types of discharges found for these selections."),
      xref = "x", 
      yref = "y",  
      showarrow = FALSE
    )
    
    # Visualise an empty graph with the above message in the middle.
    
    plot_ly() %>% 
      layout(annotations = na_disType_scot_text, 
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
    
    ### Tooltip creation ----
    
    # Create the tooltip, i.e., insert the information that appears when you...
    # hover your mouse over a dot in the discharges graph.
    
    tooltip_dis_type_scot <- paste0("Financial year: ", 
                                    dis_type_scot_new()$fyear, "<br>",
                                    "Discharge type: ",
                                    input$dis_type_scot_input, "<br>",
                                    input$dis_type_scot_measure_input,": ",
                                    dis_type_scot_new()$value)
    
    ### Create the main body of the chart ----
    
    plot_ly(data = dis_type_scot_new(), 
            
            # Select your variables.
            
            x = ~fyear, y = ~value, color = ~discharge_type,
            
            colors = c("#4CBEED", "#004785"),
            type = 'scatter', mode = 'lines+markers',
            line = list(width = 3),
            linetype = ~discharge_type,
            linetypes = c("solid", "solid", "dot", "dot"),
            # Select symbols for the health boards, and set their size.
            symbol = ~discharge_type, 
            symbols = c("square-open", "x", "circle", "diamond"),
            marker = list(size = 12),
            # Chart Size
            width = 1000, height = 650,
            # Legend adjustments
            text = tooltip_dis_type_scot, hoverinfo = "text",
            name = ~str_wrap(discharge_type, 26)) %>%
      
      
      ### Reactive Graph title ----
    
    layout(title =
             paste0(
               "<b>",
               "Discharge type '",
               input$dis_type_scot_input, "'", 
               "<br>",
               " in Scotland, by financial year, ",
               first(as.vector(dis_type_scot_new()$fyear)),
               " - ",
               last(as.vector(dis_type_scot_new()$fyear)),
               
               "<br>",
               "</b>"
             ),
           
           separators = ".",
           
           ###  Set y axis min range to Zero ----
           
           # We need to fix the range of the y axis, as R refuses to set...
           # the lower end of this axis to zero.
           # The following "range" command fixes the lower end to...
           # zero, and calculates the upper end as the maximum...
           # number visualised in the graph + 10% of this number.
           
           yaxis = list(
             
             exponentformat = "none",
             
             separatethousands = TRUE,
             
             range = c(0, max(dis_type_scot_new()$value, na.rm = TRUE) +
                         (max(dis_type_scot_new()$value, na.rm = TRUE)
                          * 10 / 100)),
             
             ### Axes titles ----
             
             # Wrap the y axis title in blank spaces so it doesn't...
             # overlap with the y axis tick labels.
             # Also, make the y axis title reactive.
             
             title = paste0(c(
               rep("&nbsp;", 20),
               # Take name from the measure selector
               input$dis_type_scot_measure_input,
               rep("&nbsp;", 20),
               rep("\n&nbsp;", 3)),
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
           
           ### Marigns ----
           
           # Fix the margins so that the graph and axis titles have enough...
           # room to display nicely.
           
           margin = list(l = 90, r = 60, b = 180, t = 120),
           
           ### Font sizes ----
           
           font = list(size = 13),
           title = list(size = 15),
           
           ### Legend ----
           
           # Insert a legend so that the user knows which discharge type 
           # they are looking at.
           # Make the legend background and legend border white.
           
           showlegend = TRUE,
           legend = list(x = 1,
                         y = 1,
                         bgcolor = 'rgba(255, 255, 255, 0)',
                         bordercolor = 'rgba(255, 255, 255, 0)')) %>%
      
      ### Remove unnecessary buttons from the modebar ----
    
    config(displayModeBar = TRUE,
           modeBarButtonsToRemove = list('select2d', 'lasso2d', 'zoomIn2d',
                                         'zoomOut2d', 'autoScale2d',
                                         'toggleSpikelines',
                                         'hoverCompareCartesian',
                                         'hoverClosestCartesian'),
           displaylogo = F, editable = F)
    
  }
  
})

## Reactive to subset data for table below graph ----

# This reactive() creates the subset that will be used to create the table...
# appearing under the discharges chart.
# Remove the variable that explains the measure type, as we can just rename...
# the Value column to reflect the measure type selected (see below).

# not necessary, use the same table used to produce the plot


## Table below graph creation ----

# We now create the table that will go under the discharges line chart.
# We give the columns clearer names.
# The name of the last column, which is the value column, changes...
# according to the user's input in the filter SELECT MEASURE.

output$dis_type_scot_table <- renderDataTable({
  datatable(dis_type_scot_new(), 
            style = 'bootstrap', 
            class = 'table-bordered table-condensed', 
            rownames = FALSE, 
            options = list(pageLength = 16, autoWidth = TRUE, dom = 'tip'),
            colnames = c("Financial year", 
                         "Health board of treatment", 
                         "Discharge type",
                         "Discharge type group",
                         "Measure",
                         "Value"))
})
