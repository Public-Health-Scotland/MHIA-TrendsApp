####
# DATA MANIPULATION ----
###

# [ File Imports & transformations ] ----

## Trend Data - Discharges & Admissions ----

# Import the file that will be used to create the admission and discharge graphs.
activity.by.hospital <- read_rds(
  paste0("data/MHIA_DataTrends_TrendsApp_",pub_date,".rds"))


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


## Trend Data - Discharge Type ----

# Read in the discharge_type data
activity.dis.type <- read_rds(
  paste0("data/MHIA_DischargeType_TrendsApp_",pub_date,".rds"))

# Store certain variables in each dataset as objects, to be used as selections...
# in the app's filters.

dis.type.measure <- activity.dis.type %>% 
  distinct(measure) %>% pull(measure)

### Scotland data ----
activity.dis.type.scot <- activity.dis.type %>% 
  filter(dis_type_group == "Scotland")

dis.type.scot <- activity.dis.type.scot %>% 
  distinct(discharge_type) %>%  pull(discharge_type)

dis.groups.scot <- activity.dis.type.scot %>% 
  distinct(dis_type_group) %>%  pull(dis_type_group)

dis.type.location.scot <- activity.dis.type.scot %>% 
  distinct(hbtreat_name) %>% pull(hbtreat_name)


### HB data ----
activity.dis.type.hb <- activity.dis.type %>% 
  filter(dis_type_group != "Scotland")

dis.type.hb <- activity.dis.type.hb %>% 
  distinct(discharge_type) %>%  pull(discharge_type)

dis.groups.hb <- activity.dis.type.hb %>% 
  distinct(dis_type_group) %>%  pull(dis_type_group)

dis.type.location.hb <- activity.dis.type.hb %>% 
  distinct(hbtreat_name) %>% pull(hbtreat_name)


## Trend Data - Length of Stay ----

# Now import the file that will be used to create the length of stay graph.
length.of.stay <- read_rds(
  paste0("data/MHIA_LengthOfStay_TrendsApp_",pub_date,".rds"))


# Finally, store the following two variables as objects to be used as...
# selections in the LoS filters.

los_loc_names <- length.of.stay %>% 
  distinct(geography2) %>% 
  mutate(geography2 = as.character(geography2)) %>% pull(geography2)


los_measures <- length.of.stay %>% 
  distinct(Stay_Specialty) %>% 
  mutate(Stay_Specialty = as.character(Stay_Specialty)) %>% pull(Stay_Specialty)


# [ Summary text extraction ] ----

## Load Text File
trends_text <- read.csv("data/trends_app_text.csv")

## Admissions summary text ----
adm_sum_text_1 <- trends_text %>% 
  filter(object == "adm_sum_text_1") %>% 
  pull(value)

adm_sum_text_2 <- trends_text %>% 
  filter(object == "adm_sum_text_2") %>% 
  pull(value)

adm_sum_text_3 <- trends_text %>% 
  filter(object == "adm_sum_text_3") %>% 
  pull(value)

adm_sum_text_4 <- trends_text %>% 
  filter(object == "adm_sum_text_4") %>% 
  pull(value)

## Discharges summary text ----
dis_sum_text_1 <- trends_text %>% 
  filter(object == "dis_sum_text_1") %>% 
  pull(value)

dis_sum_text_2 <- trends_text %>% 
  filter(object == "dis_sum_text_2") %>% 
  pull(value)

dis_sum_text_3 <- trends_text %>% 
  filter(object == "dis_sum_text_3") %>% 
  pull(value)

dis_sum_text_4 <- trends_text %>% 
  filter(object == "dis_sum_text_4") %>% 
  pull(value)

## Discharge Type summary text ----
dis_type_sum_text_1 <- trends_text %>% 
  filter(object == "dis_type_sum_text_1") %>% 
  pull(value)

dis_type_sum_text_2 <- trends_text %>% 
  filter(object == "dis_type_sum_text_2") %>% 
  pull(value)

dis_type_sum_text_3 <- trends_text %>% 
  filter(object == "dis_type_sum_text_3") %>% 
  pull(value)

## Discharge Group summary text ----
dis_group_sum_text_1 <- trends_text %>% 
  filter(object == "dis_group_sum_text_1") %>% 
  pull(value)

dis_group_sum_text_2 <- trends_text %>% 
  filter(object == "dis_group_sum_text_2") %>% 
  pull(value)

dis_group_sum_text_3 <- trends_text %>% 
  filter(object == "dis_group_sum_text_3") %>% 
  pull(value)

## Length of Stay summary text ----
los_sum_text_1 <- trends_text %>% 
  filter(object == "los_sum_text_1") %>% 
  pull(value)

los_sum_text_2 <- trends_text %>% 
  filter(object == "los_sum_text_2") %>% 
  pull(value)


