library(dplyr)
library(factoextra)
library(FactoMineR)
library(MLmetrics)
library(partykit)
library(ROCR)
library(leaflet)
library(rgdal)
library(stringr)#str_to_title
library(rgeos)
library(sf)
library(formattable)
library(slickR)

library(shiny)
library(leaflet)
library(plotly)
library(shinyjs)
library(shinyBS)
library(shinydashboard)
library(shinydashboardPlus)
library(shinyWidgets)
library(rmarkdown)
library(shinycssloaders)

library(ggplot2)
library(GGally)
library(scales)
library(plotly)
library(glue)

options(scipen = 999)

# READ MAP DATA AND CONVERT IT TO JSON DATA TYPE
jakarta_json <- rgdal::readOGR("gadm41_IDN_3.json")

jakarta_json_mod <- sf::st_as_sf(jakarta_json)

# Removing `Kepulauan Seribu` and some columns we won't use 
jakarta_json_mod <- jakarta_json_mod %>% 
  mutate(NAME_3 = str_replace_all(NAME_3, fixed(" "), "") %>% str_to_title()) %>%       
  filter(NAME_2 != "Kepulauan Seribu")  %>%                        
  dplyr::select(-c(id, NL_NAME_1, NL_NAME_2, NL_NAME_3, VARNAME_3, HASC_3, TYPE_3, ENGTYPE_3)) 

# READ APARTMENT DATA
apartment <- read.csv("apartment_jakarta.csv")

apartment <- apartment %>%
  filter(!grepl("[A-Za-z]", Bathroom)) %>%
  mutate(Total_area = gsub(" m²", "", Total_area),
         Price = gsub(",", "", Price),
         Bedroom = as.numeric(Bedroom),
         Bathroom = as.numeric(Bathroom),
         Total_area = as.numeric(Total_area),
         Price = as.numeric(Price))

## FEATURE ENGINEERING
apartment <- apartment %>%
  # Extract district name from address column
  mutate(District = sapply(strsplit(Address, ",\\s*"), "[", 2)) %>%
  na.omit() %>%
  # Extract sub-district name from address column
  mutate(Sub_district = sapply(strsplit(Address, ",\\s*"), "[", 1)) %>% 
  mutate(Sub_district = as.factor(Sub_district),
         District = as.factor(District))

apartment <- apartment %>% 
  mutate(Sub_district = gsub(" ", "", Sub_district),
         Sub_district = stringr::str_to_title(Sub_district),
         Sub_district = as.factor(Sub_district))

## HANDLING ABNORMAL VALUES
apartment_raw <- apartment %>% 
  filter(Total_area >= 12,
         Total_area <= 150,
         Bedroom <= 4,
         Bathroom <= Bedroom)

apartment_clean <- apartment %>% 
  filter(Bedroom <= 4,
         Total_area >= 12,
         Total_area <= 150,
         Bathroom <= Bedroom,
         Price > 300000000,
         
         !(Total_area >= 12 & Total_area <= 54 & Bedroom > 1),
         !(Total_area >= 55 & Total_area <= 75 & Bedroom > 2),
         !(Total_area >= 76 & Total_area <= 90 & Bedroom < 2),
         !(Total_area >= 76 & Total_area <= 90 & Bedroom > 3),
         !(Total_area >= 91 & Total_area <= 95 & Bedroom < 2),
         !(Total_area >= 91 & Total_area <= 95 & Bedroom > 4),
         !(Total_area >= 96 & Total_area <= 150 & Bedroom < 3),
         !(Total_area >= 96 & Total_area <= 150 & Bedroom > 4),
         
         !(Total_area >= 25 & Total_area <= 44 & Sub_district == "Pasar Minggu" & Price == 2749000000),
         !(Total_area >= 25 & Total_area <= 44 & Sub_district == "Kuningan" & Price == 2500000000),
         !(Total_area >= 45 & Total_area <= 75 & Sub_district == "SetiaBudi" & Price == 3500000000),
         !(Total_area >= 45 & Total_area <= 75 & Sub_district == "Tebet" & Price == 3750000000),
         !(Total_area >= 45 & Total_area <= 75 & Sub_district == "Kuningan" & Price == 3700000000),
         !(Total_area >= 45 & Total_area <= 75 & Sub_district == "Sudirman" & Price == 4500000000),
         !(Total_area >= 55 & Total_area <= 95 & Sub_district == "Cilandak" & Price == 1750000000),
         !(Total_area >= 90 & Total_area <= 150 & Sub_district == "Kemang" & Price == 7900000000),
         !(Total_area >= 90 & Total_area <= 150 & Sub_district == "SetiaBudi" & Price > 7000000000),
         !(Total_area >= 90 & Total_area <= 150 & Sub_district == "Kebayoran Baru" & Price >= 9000000000),
         !(Total_area >= 45 & Total_area <= 75 & Sub_district == "Thamrin" & Price >= 37500000000),
         !(Total_area >= 90 & Total_area <= 150 & Sub_district == "Tanah Abang" & Price >= 7750000000),
         !(Total_area >= 45 & Total_area <= 75 & Sub_district == "Kelapa Gading" & Price >= 3000000000),
         !(Total_area >= 55 & Total_area <= 95 & Sub_district == "Kelapa Gading" & Price >= 3250000000)
  )


# K MEAN CLUSTERING
apartment_cluster <- apartment_raw
apartment_District <- apartment_cluster$District
apartment_Subdistrict <- apartment_cluster$Sub_district
District_encoded <- model.matrix(~ apartment_District - 1)
Subdistrict_encoded <- model.matrix(~ apartment_Subdistrict - 1)

apartment_scale <- apartment_cluster %>% 
  select(c(Bedroom, Bathroom, Total_area, Price)) %>% 
  scale()

apartment_z <- cbind(apartment_scale, District_encoded, Subdistrict_encoded)
apartment_z <- as.data.frame(apartment_z)

RNGkind(sample.kind = "Rounding")
set.seed(100)
apartment_km <- kmeans(x = apartment_z,
                       centers = 5)

apartment_raw$Cluster <- apartment_km$cluster

# BUILD MAP

apartment_for_map <- apartment_raw %>% 
  left_join(jakarta_json_mod, by = c("District" = "NAME_2", "Sub_district" = "NAME_3")) %>% 
  na.omit() %>% 
  select(c(1:10))

# Model Random Forest
apartment_forest <- readRDS("final_model.RDS")





