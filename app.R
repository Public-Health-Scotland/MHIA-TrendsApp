####
# Name: Trends App
# Type: Data visualisation
# Output: Shiny application
# Confirmed working on: R 4.5.1 
#
# Original Author: Nikos Alexandrou (2019)
# Latest Author: Alex Bruce
# Latest Edit: Nov 2026
# Changes:
#
# 2024 (AB) - added to github, changed 'segments' to 'modules'
# - Moved summary text to csv file
# - Moved data prep to separate file
#
# 2023 (AB) - complete remodel to source ui from a separate ui.R file and server
# files from individual section files saved in folder called 'modules'
# to make editing easier
# - changed file types to parquet files for smaller footprint and faster loading
#
# 2022 (AB) - remodel to include discharge type and discharge groups
#
# Updated pub date, max year and file to import
#
# Approximate run time: < 1 minute
# Description: This syntax creates a Shiny page that provides an overview of...
# inpatient admissions, discharges, discharge types, discharge groups 
# and length of stay.
###


####
# [ SECTION 1: SETUP ] ----
###

## Load necessary libraries ----
library("shiny") # interactivity
library("readr") # read in rds files
library("dplyr") # easier variable manipulation
library("tidyr") # pivot function
library('purrr') # for map function to load multiple files
library("plotly") # graphs 
library("DT") # insert tables under the graphs
library("readr") # read CSV files into R
library("shinyWidgets") # filters
library("magrittr") # pipe operators
library("stringr") # easier string manipulation
library("shinyjs")
library('shinycssloaders')
library("shinymanager") # apply password protection to the app


## Define variables ----

### Publication Date variable ----
# MUST BE UPDATED EACH TIME WE PUBLISH
pub_date <- "2026_December"

### min and max fyears ---- 
# updates max fyear based on pub_date above
min_fyear <- 1997
max_fyear <- as.numeric(substr(pub_date,1,4)) - 1

## Source functions ----
list.files("functions") %>%
  map(~ source(paste0("functions/", .)))

## Source data ----
source("data_preparation.R")


##* Read in credentials for password-protecting the app ----
# Uncomment the below line for PRA
# credentials <- readRDS("admin/credentials.rds")


####
# [ SECTION 2: USER INTERFACE ] ----
###

## [Source the ui file] ----
ui <- source('ui.R', local = TRUE)$value
# Needs $value after source expression for ui to prevent 'TRUE' being printed 
# at the bottom of the app following R Shiny evaluation sequence



####
# [ SECTION 3: SERVER ] ----
###

server <- function(input, output, session) {
  
  ##* Password Protection - Shinymanager authorisation ----
  # Uncomment the two sections below for PRA 
  # res_auth <- secure_server(
  # check_credentials = check_credentials(credentials)
  # )
  # 
  # output$auth_output <- renderPrint({
  # reactiveValuesToList(res_auth)
  # })

  
  ## [Source Server files] ----
  ### Admissions server ----
  source('modules/server_01_admissions.R', local = TRUE)
  
  ### Discharges server ----
  source('modules/server_02_discharges.R', local = TRUE)
  
  ### Discharge Types server ----
  source('modules/server_03_discharge_types.R', local = TRUE)
  
  ### Discharge Groups server ----
  source('modules/server_04_discharge_groups.R', local = TRUE)
  
  ### Length of Stay server ----
  source('modules/server_05_los.R', local = TRUE)  
  
             
  ## Glossary Server ----

  # We have prepared a glossary to help the user understand the graphs and
  # tables more easily.
  
  ### Create a download button for the glossary ----
  
  output$download_glossary_one <- downloadHandler(
    filename = 'glossary.pdf',
    content = function(file) {
      file.copy("downloads/MHIA Glossary.pdf", file)
    }
  )
  
  ## Keep dashboard active ----
  # Keep dashboard active indefinitely to meet accessibility requirements (Keep at the end of server)
  auto_invalidate <- reactiveTimer(10000)
  observe({
    auto_invalidate()
    cat(".")
  })
  
} ## End of server ----

# Set app language ----
# Sets language right at the top of source (required this way for screen readers)
attr(ui, "lang") = "en"


# Launch app ----

shinyApp(ui = ui, server = server)
