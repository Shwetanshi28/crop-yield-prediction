# Step 5: Simple Fixed Data Generation Script
# Crop Yield Prediction Project

library(DBI)
library(RMySQL)
library(tidyverse)
library(ggplot2)
library(caret)
library(randomForest)

print("Libraries loaded successfully!")

# Connect to database
con <- dbConnect(RMySQL::MySQL(), 
                 host = "localhost",
                 user = "root",
                 password = "Shubhi@28",
                 dbname = "crop_yield_db")

print("Connected to database!")

# Instead of deleting everything, let's just add more data to what we have
# First, check what locations we currently have
existing_locations <- dbGetQuery(con, "SELECT * FROM locations")
print("Current locations:")
print(existing_locations)

# Get the highest location_id to avoid conflicts
if(nrow(existing_locations) > 0) {
  max_loc_id <- max(existing_locations$location_id)
  print(paste("Highest existing location_id:", max_loc_id))
} else {
  max_loc_id <- 0
  print("No existing locations found")
}

# Add more locations starting from the next available ID
new_locations <- data.frame(
  state = c("Iowa", "Illinois", "Nebraska", "Indiana", "Minnesota"),
  county = c("Story County", "McLean County", "Hamilton County", "Tippecanoe County", "Blue Earth County"),
  fips_code = c("19169", "17113", "31081", "18157", "27013"),
  latitude = c(42.0308, 40.4842, 40.9158, 40.4167, 44.1636),
  longitude = c(-93.6319, -88.9399, -98.1192, -87.0056, -94.0719)
)

# Insert new locations
for(i in 1:nrow(new_locations)) {
  query <- sprintf("INSERT INTO locations (state, county, fips_code, latitude, longitude) VALUES ('%s', '%s', '%s', %.4f, %.4f)",
                   new_locations$state[i], new_locations$county[i], new_locations$fips_code[i],
                   new_locations$latitude[i], new_locations$longitude[i])
  dbExecute(con, query)
}

print(paste("Inserted", nrow(new_locations), "new location records"))

# Get all locations now (including new ones)
all_locations <- dbGetQuery(con, "SELECT * FROM locations")
print("All locations now:")
print(all_locations)

# Generate data for these locations
set.seed(123)
years <- 2020:2023  # 4 years of data
location_ids <- all_locations$location_id

# Create comprehensive dataset
all_data <- list()
counter <- 1

for(year in years) {
  for(loc_id in location_ids) {
    
    # Get location info for this ID
    loc_info <- all_locations[all_locations$location_id == loc_id, ]
    
    # Generate realistic yield based on state
    base_yield <- case_when(
      loc_info$state == "Iowa" ~ 190,
      loc_info$state == "Illinois" ~ 185,
      loc_info$state == "Nebraska" ~ 180,
      loc_info$state == "Indiana" ~ 175,
      loc_info$state == "Minnesota" ~ 170,
      TRUE ~ 175
    )
    
    # Add year trend and random variation
    year_effect <- (year - 2020) * 2  # 2 bushel improvement per year
    random_effect <- rnorm(1, 0, 8)
    final_yield <- base_yield + year_effect + random_effect
    final_yield <- pmax(final_yield, 150)  # Minimum
    final_yield <- pmin(final_yield, 220)  # Maximum
    
    # Generate weather data
    base_temp <- case_when(
      loc_info$state == "Iowa" ~ 72,
      loc_info$state == "Illinois" ~ 73,
      loc_info$state == "Nebraska" ~ 74,
      loc_info$state == "Indiana" ~ 71,
      loc_info$state == "Minnesota" ~ 68,
      TRUE ~ 72
    )
    
    actual_temp <- base_temp + rnorm(1, 0, 3)
    
    base_precip <- case_when(
      loc_info$state == "Iowa" ~ 24,
      loc_info$state == "Illinois" ~ 22,
      loc_info$state == "Nebraska" ~ 18,
      loc_info$state == "Indiana" ~ 21,
      loc_info$state == "Minnesota" ~ 20,
      TRUE ~ 21
    )
    
    actual_precip <- base_precip + rnorm(1, 0, 3)
    actual_precip <- pmax(actual_precip, 12)
    actual_precip <- pmin(actual_precip, 32)
    
    # Store all data for this location-year
    all_data[[counter]] <- data.frame(
      location_id = loc_id,
      state = loc_info$state,
      year = year,
      yield = round(final_yield, 1),
      temperature = round(actual_temp, 1),
      precipitation = round(actual_precip, 1),
      fertilizer_n = round(runif(1, 140, 180)),
      organic_matter = case_when(
        loc_info$state == "Iowa" ~ runif(1, 3.5, 4.5),
        loc_info$state == "Illinois" ~ runif(1, 3.2, 4.2),
        loc_info$state == "Nebraska" ~ runif(1, 2.8, 3.8),
        TRUE ~ runif(1, 2.5, 3.5)
      ),
      ph_level = runif(1, 6.2, 7.0)
    )
    
    counter <- counter + 1
  }
}

# Combine all data
dataset <- do.call(rbind, all_data)
print(paste("Generated", nrow(dataset), "complete records"))
print("Sample of generated data:")
print(head(dataset))

# Insert the data into appropriate tables
print("Inserting crop yield data...")

for(i in 1:nrow(dataset)) {
  # Insert crop yield
  yield_query <- sprintf("INSERT IGNORE INTO crop_yields (location_id, year, crop_type, yields_bushels_per_acre, planted_acres, harvested_acres) VALUES (%d, %d, 'CORN', %.1f, %d, %d)",
                         dataset$location_id[i], dataset$year[i], dataset$yield[i], 1000, 995)
  dbExecute(con, yield_query)
  
  # Insert weather data
  weather_query <- sprintf("INSERT IGNORE INTO weather_data (location_id, year, month, avg_temp_f, min_temp_f, max_temp_f, precipitation_inches, growing_degree_days) VALUES (%d, %d, 7, %.1f, %.1f, %.1f, %.1f, %d)",
                           dataset$location_id[i], dataset$year[i], dataset$temperature[i], 
                           dataset$temperature[i] - 10, dataset$temperature[i] + 10, 
                           dataset$precipitation[i], round((dataset$temperature[i] - 50) * 31))
  dbExecute(con, weather_query)
  
  # Insert management data
  mgmt_query <- sprintf("INSERT IGNORE INTO management_data (location_id, year, planting_date, harvest_date, irrigation, tillage_type, fertilizer_n_lbs_acre, fertilizer_p_lbs_acre, fertilizer_k_lbs_acre) VALUES (%d, %d, '%s', '%s', 0, 'No-till', %.0f, 60, 80)",
                        dataset$location_id[i], dataset$year[i], 
                        paste(dataset$year[i], "05", "15", sep="-"),
                        paste(dataset$year[i], "10", "20", sep="-"),
                        dataset$fertilizer_n[i])
  dbExecute(con, mgmt_query)
}

# Insert soil data (once per location)
print("Inserting soil data...")
unique_locations <- unique(dataset[, c("location_id", "state", "organic_matter", "ph_level")])

for(i in 1:nrow(unique_locations)) {
  soil_query <- sprintf("INSERT IGNORE INTO soil_data (location_id, organic_matter_pct, ph_level, nitrogen_ppm, phosphorus_ppm, potassium_ppm, soil_type, drainage_class) VALUES (%d, %.2f, %.1f, 180, 35, 220, 'Silt Loam', 'Well drained')",
                        unique_locations$location_id[i], unique_locations$organic_matter[i], unique_locations$ph_level[i])
  dbExecute(con, soil_query)
}

print("=== DATA INSERTION COMPLETED! ===")

# Verify our data
verification_query <- "
SELECT 
    COUNT(*) as total_records,
    MIN(year) as first_year,
    MAX(year) as last_year,
    COUNT(DISTINCT location_id) as num_locations
FROM crop_yields
"

verification <- dbGetQuery(con, verification_query)
print("Data verification:")
print(verification)

print("Step 5.3 completed successfully! Ready for analysis.")

# Don't close connection yet - we'll use it for the next step