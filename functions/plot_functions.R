### Functions for code used in multiple plots

## PHS colour spinner ----

phs_spinner <- function(plot_name){
  withSpinner(
    plotlyOutput(plot_name, width = "1090px", height = "650px"),
    type = 8, size = 0.7,
    color = "#AF69A9", # color.background = "#E1C7DF",
    caption = "Loading...",
    hide.ui = FALSE
  )
}