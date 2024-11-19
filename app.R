################################################################################
# Name: Trend data
# Type: Data visualisation
# Output: Shiny application
# Written on: RStudio
# Written for: R version 3.6.1 
#
# Original Author: Nikos Alexandrou
# Modified: 16/07/2019
# Latest Author: Alex Bruce
# Latest Edit: Sept 2024
# Changes:
#
# 2024 (AB) - added to github, changed 'segments' to 'modules'
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
# Grab a cup of tea if making changes, it's a long file.
#
# Approximate run time: < 1 minute
# Description: This syntax creates a Shiny page that provides an overview of...
# inpatient admissions, discharges, discharge types, discharge groups 
# and length of stay.
################################################################################


#Load the necessary libraries.

library("shiny") # interactivity
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
# library("shinymanager") # apply password protection to the app


### Load setup files ----

# sourcing functions created for app (see functions folder)
list.files("functions") %>%
  map(~ source(paste0("functions/", .)))

#############################################################

# SECTION 1: DATA MANIPULATION ----

#############################################################


### 1 -  Publication Date variable to define file3path ----
# MUST BE UPDATED EACH TIME WE PUBLISH
pub_date <- "20231212"

### 2 - Define min and max years ---- 
# must be updated each time we publish 
min_year <- 1997
max_year <- 2022

### 4 - File Imports & transformations ----

### Trend Data - Discharges & Admissions ----

# Import the file that will be used to create the admission and discharge graphs.
activity.by.hospital <- arrow::read_parquet(
  paste0("data/MHIA_DataTrends_TrendsApp_",pub_date,".parquet"))

# activity.by.hospital <- readRDS("data/SMR01SMR04_MH_trend_data_long.rds")


# Then, split this file in two -one file for discharges, one for admissions.
# In each file, delete the columns you don't need.

activity.admissions <- activity.by.hospital %>% 
  filter(Trend_Type == "Admissions in any specialty" | 
           Trend_Type == "Non-psychiatric admissions" | 
           Trend_Type == "Psychiatric admissions") %>% 
  select(-c(year_ending, hospital_code))


activity.discharges <- activity.by.hospital %>% 
  filter(Trend_Type == "Discharges from any specialty" | 
           Trend_Type == "Non-psychiatric discharges" | 
           Trend_Type == "Psychiatric discharges") %>% 
  select(-c(year_ending, hospital_code))


# Store certain variables in each dataset as objects, to be used as selections...
# in the app's filters.

act_adm_loc_types <- activity.admissions %>% distinct(hbtreat_name) %>% 
  pull(hbtreat_name)
act_adm_measures <- activity.admissions %>% distinct(Trend_Type) %>% 
  pull(Trend_Type)

act_disch_loc_types <- activity.discharges %>% distinct(hbtreat_name) %>% 
  pull(hbtreat_name)
act_disch_measures <- activity.discharges %>% distinct(Trend_Type) %>%  
  pull(Trend_Type)


### Trend Data - Discharge Type ----

# Read in the discharge_type data
activity.dis.type <- arrow::read_parquet(
  paste0("data/MHIA_DischargeType_TrendsApp_",pub_date,".parquet"))

# Store certain variables in each dataset as objects, to be used as selections...
# in the app's filters.

# Scotland data
activity.dis.type.scot <- activity.dis.type %>% 
  filter(dis_type_group == "Scotland")

dis.type.scot <- activity.dis.type.scot %>% 
  distinct(discharge_type) %>%  pull(discharge_type)

dis.groups.scot <- activity.dis.type.scot %>% 
  distinct(dis_type_group) %>%  pull(dis_type_group)

dis.type.location.scot <- activity.dis.type.scot %>% 
  distinct(hbtreat_name) %>% pull(hbtreat_name)


# HB data
activity.dis.type.hb <- activity.dis.type %>% 
  filter(dis_type_group != "Scotland")

dis.type.hb <- activity.dis.type.hb %>% 
  distinct(discharge_type) %>%  pull(discharge_type)

dis.groups.hb <- activity.dis.type.hb %>% 
  distinct(dis_type_group) %>%  pull(dis_type_group)

dis.type.location.hb <- activity.dis.type.hb %>% 
  distinct(hbtreat_name) %>% pull(hbtreat_name)


### Trend Data - Length of Stay ----

# Now import the file that will be used to create the length of stay graph.
length.of.stay <- arrow::read_parquet(
  paste0("data/MHIA_LengthOfStay_TrendsApp_",pub_date,".parquet"))


# Finally, store the following two variables as objects to be used as...
# selections in the LoS filters.

los_loc_names <- length.of.stay %>% 
  distinct(geography2) %>% 
  mutate(geography2 = as.character(geography2)) %>% pull(geography2)
  

los_measures <- length.of.stay %>% 
  distinct(Stay_Specialty) %>% 
  mutate(Stay_Specialty = as.character(Stay_Specialty)) %>% pull(Stay_Specialty)
  


#* Read in credentials for password-protecting the app ----
# credentials <- readRDS("admin/credentials.rds")



#############################################################

#### SECTION 2: USER INTERFACE ####

#############################################################

### [Source the ui file] ----
ui <- source('ui.R', local = TRUE)$value
# Needs $value after source expression for ui to prevent 'TRUE' being printed 
# at the bottom of the app following R Shiny evaluation sequence



#############################################################

#### SECTION 3: SERVER ####

#############################################################

server <- function(input, output, session) {
  
  # ##* Shinymanager authorisation - password protection ----
  # res_auth <- secure_server(
  # check_credentials = check_credentials(credentials)
  # )
  # 
  # output$auth_output <- renderPrint({
  # reactiveValuesToList(res_auth)
  # })

  #### [Source Server files] ----
  ###* Admissions server ----
  source('modules/server_01_admissions.R', local = TRUE)
  
  ##* Discharges server ----
  source('modules/server_02_discharges.R', local = TRUE)
  
  ##* Discharge Types server ----
  source('modules/server_03_discharge_types.R', local = TRUE)
  
  ##* Discharge Groups server ----
  source('modules/server_04_discharge_groups.R', local = TRUE)
  
  ##* Length of Stay server ----
  source('modules/server_05_los.R', local = TRUE)  
  
             
  ################ [ Glossary Server ] ################

  # We have prepared a glossary to help the user understand the graphs and...
  # tables more easily.
  
  ### 1 - Create a download button for the glossary ####
  
  output$download_glossary_one <- downloadHandler(
    filename = 'glossary.pdf',
    content = function(file) {
      file.copy(paste0(filepath, "downloads/MHIA Glossary.pdf"), file)
    }
  )
  
  # Keep dashboard active indefinitely to meet accessibility requirements
  # (Keep at the end of server)
  auto_invalidate <- reactiveTimer(10000)
  observe({
    auto_invalidate()
    cat(".")
  })
  
} # End of server

# Sets language right at the top of source (required this way for screen readers)
attr(ui, "lang") = "en"


# Launch the page ----

shinyApp(ui = ui, server = server)
