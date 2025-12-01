########### [ Discharge Groups ] ############# 

### 1 - Create data for chart ----
dis_group_hb_new <- reactive({
  activity.dis.type.hb %>%
    filter(hbtreat_name %in% input$dis_group_location_input
           & dis_type_group %in% input$dis_group_hb_input)
})


# Create the discharges line chart.
output$dis_group_hb_plot <- renderPlotly({
  
  ### 2 - Account for charts with no admissions ----
  if(sum(dis_group_hb_new()$DischargeTypeTotal) == 0 & 
     !is.na(sum(dis_group_hb_new()$DischargeTypeTotal))) 
    
  { 
    
    # Account for the possibility that a hospital had no discharges.
    # Create a message for this.
    
    na_disType_hb_text <- list(
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
      layout(annotations = na_disType_hb_text, 
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
    
    ### 4 - Tooltip creation ----
    tooltip_dis_group_hb <- paste0("Financial year: ", 
                                   dis_group_hb_new()$fyear, "<br>",
                                   "Discharge type: ",
                                   input$dis_group_hb_input, "<br>",
                                   "Value: ",
                                   dis_group_hb_new()$DischargeTypeTotal)
    
    ### 5 - Create the main body of the chart ----
    plot_ly(data = dis_group_hb_new(), 
            x = ~fyear, 
            y = ~DischargeTypeTotal, 
            color = ~dis_type_group,
            colors = c("#4CBEED", "#004785", "#4CBEED", "#004785"),
            type = 'scatter', mode = 'lines+markers',
            line = list(width = 3),
            linetype = ~discharge_type,
            linetypes = c("solid", "dotdash", "dot"),
            # Select symbols for the health boards, and set their size.
            symbol = ~discharge_type, 
            symbols = c("square-open", "circle", "x"),
            marker = list(size = 12),
            # Chart Size
            width = 1000, height = 650,
            # Legend adjustments
            text = tooltip_dis_group_hb, hoverinfo = "text",
            name = ~str_wrap(discharge_type, 26)) %>%
      
      
      ### 5 - Graph title ----
    layout(title =
             paste0(
               "<b>",
               "Discharge type: ",
               input$dis_group_hb_input, ", in ",
               input$dis_group_location_input, ",",
               "<br>",
               " by financial year, ",
               first(as.vector(dis_group_hb_new()$fyear)),
               " - ",
               last(as.vector(dis_group_hb_new()$fyear)),
               "<br>",
               "</b>"
             ),
           
           separators = ".",
           
           ### 6 - Set y axis min range to Zero ----
           
           # We need to fix the range of the y axis, as R refuses to set...
           # the lower end of this axis to zero.
           # The following "range" command fixes the lower end to...
           # zero, and calculates the upper end as the maximum...
           # number visualised in the graph + 10% of this number.
           
           yaxis = list(
             
             exponentformat = "none",
             
             separatethousands = TRUE,
             
             range = c(0, max(dis_group_hb_new()$DischargeTypeTotal, na.rm = TRUE) +
                         (max(dis_group_hb_new()$DischargeTypeTotal, na.rm = TRUE)
                          * 10 / 100)),
             
             ### 7 - Axes titles ----
             
             # Wrap the y axis title in blank spaces so it doesn't...
             # overlap with the y axis tick labels.
             # Also, make the y axis title reactive.
             
             title = paste0(c(
               rep("&nbsp;", 20),
               "Number of Discharges",
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
           
           ### 8 - Marigns ----
           margin = list(l = 90, r = 60, b = 180, t = 120),
           
           ### 9 - Font sizes ----
           font = list(size = 13),
           title = list(size = 15),
           
           ### 10 - Legend ----
           showlegend = TRUE,
           legend = list(x = 1,
                         y = 1,
                         bgcolor = 'rgba(255, 255, 255, 0)',
                         bordercolor = 'rgba(255, 255, 255, 0)')) %>%
      
      ### 11 - Remove unnecessary buttons from the modebar ----
    config(displayModeBar = TRUE,
           modeBarButtonsToRemove = list('select2d', 'lasso2d', 'zoomIn2d',
                                         'zoomOut2d', 'autoScale2d',
                                         'toggleSpikelines',
                                         'hoverCompareCartesian',
                                         'hoverClosestCartesian'),
           displaylogo = F, editable = F)
    
  }
  
})

### 12 - Table below graph creation ----

output$dis_group_hb_table <- renderDataTable({
  datatable(dis_group_hb_new(), 
            style = 'bootstrap', 
            class = 'table-bordered table-condensed', 
            rownames = FALSE, 
            options = list(pageLength = 16, autoWidth = TRUE, dom = 'tip'),
            colnames = c("Financial year", 
                         "Health board of treatment", 
                         "Discharge type",
                         "Discharge type group",
                         "Value"))
})
