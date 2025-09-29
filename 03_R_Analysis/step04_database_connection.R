# Step 4: R Database Connection Script
# Crop Yield Prediction Project
# Date: December 2024

# Load required libraries
library(DBI)      # Database interface
library(RMySQL)   # MySQL specific tools
library(tidyverse) # Data manipulation tools
library(ggplot2)  # Plotting tools

print("Libraries loaded successfully!")

# Connect to database
con <- dbConnect(RMySQL::MySQL(), 
                 host = "localhost",
                 user = "root",           # Change this to your MySQL username if different
                 password = "Shubhi@28",           # Change this to your MySQL password if you have one
                 dbname = "crop_yield_db")

print("Connected to database!")

# Test the connection - list all tables
tables <- dbListTables(con)
print("Tables in database:")
print(tables)

# Get all locations
locations_data <- dbGetQuery(con, "SELECT * FROM locations")
print("Locations data:")
print(locations_data)

# Get crop yields with location names
yield_query <- "
SELECT 
    l.state,
    l.county,
    cy.year,
    cy.yields_bushels_per_acre
FROM crop_yields cy
JOIN locations l ON cy.location_id = l.location_id
ORDER BY cy.yields_bushels_per_acre DESC
"

yield_data <- dbGetQuery(con, yield_query)
print("Yield data:")
print(yield_data)

# Look at the structure of our data
str(yield_data)

# Get basic statistics
summary(yield_data)

# Count how many records per state
state_counts <- table(yield_data$state)
print("Records per state:")
print(state_counts)

# Calculate average yield by state
yield_by_state <- yield_data %>%
  group_by(state) %>%
  summarise(avg_yield = mean(yields_bushels_per_acre))

print("Average yield by state:")
print(yield_by_state)

# Create a bar chart of yields by state
chart <- ggplot(yield_by_state, aes(x = state, y = avg_yield)) +
  geom_col(fill = "lightgreen", color = "darkgreen") +
  labs(title = "Average Corn Yield by State",
       x = "State", 
       y = "Yield (bushels per acre)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))

print(chart)

# Get more complex data for analysis
full_query <- "
SELECT 
    l.state,
    l.county,
    cy.year,
    cy.yields_bushels_per_acre,
    wd.avg_temp_f,
    wd.precipitation_inches,
    wd.growing_degree_days,
    sd.organic_matter_pct,
    sd.ph_level,
    sd.nitrogen_ppm,
    md.fertilizer_n_lbs_acre,
    md.irrigation
FROM crop_yields cy
JOIN locations l ON cy.location_id = l.location_id
JOIN weather_data wd ON cy.location_id = wd.location_id AND cy.year = wd.year
JOIN soil_data sd ON cy.location_id = sd.location_id  
JOIN management_data md ON cy.location_id = md.location_id AND cy.year = md.year
"

# Get the combined data
full_data <- dbGetQuery(con, full_query)
print("Combined data:")
print(full_data)

# Look at correlations between numeric variables
numeric_data <- full_data %>% 
  select_if(is.numeric)

print("Correlation matrix:")
correlation_matrix <- cor(numeric_data, use = "complete.obs")
print(round(correlation_matrix, 3))

# Create a simple scatter plot to show relationship between temperature and yield
temp_yield_plot <- ggplot(full_data, aes(x = avg_temp_f, y = yields_bushels_per_acre)) +
  geom_point(color = "blue", size = 3) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(title = "Relationship Between Temperature and Corn Yield",
       x = "Average Temperature (°F)",
       y = "Yield (bushels per acre)") +
  theme_minimal()

print(temp_yield_plot)

print("Step 4 completed successfully!")

# Always close the database connection at the end
dbDisconnect(con)
print("Database connection closed.")
