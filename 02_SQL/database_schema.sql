CREATE DATABASE crop_yield_db;

USE crop_yield_db;
-- Table 1: Where the farms are located
CREATE TABLE locations (
location_id INT PRIMARY KEY AUTO_INCREMENT,
state VARCHAR(50),
county VARCHAR(100),
fips_code VARCHAR(10),
latitude DECIMAL(10,8),
longitude DECIMAL(11,8)
);

-- Table 2: The harvest results we want to predict
CREATE TABLE crop_yields(
yield_id INT PRIMARY KEY AUTO_INCREMENT,
location_id INT,
year INT,
crop_type VARCHAR(50),
yields_bushels_per_acre DECIMAL(8,2),
planted_acres INT,
harvested_acres INT,
FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

DROP TABLE weather_data;

-- Table 3: Weather conditions that affect crop group
CREATE TABLE weather_data(
weather_id INT PRIMARY KEY AUTO_INCREMENT,
location_id INT,
year INT,
month INT,
avg_temp_f DECIMAL(5,2),
min_temp_f DECIMAL(5,2),
max_temp_f DECIMAL(5,2),
precipitation_inches DECIMAL(6,2),
growing_degree_days INT,
FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

-- Table 4: Soil characterstics that affect crop growth
CREATE TABLE soil_data(
	soil_id INT PRIMARY KEY AUTO_INCREMENT,      
    location_id INT,                             
    organic_matter_pct DECIMAL(5,2),            
    ph_level DECIMAL(3,1),                      
    nitrogen_ppm DECIMAL(8,2),                  
    phosphorus_ppm DECIMAL(8,2),                
    potassium_ppm DECIMAL(8,2),                 
    soil_type VARCHAR(100),                      
    drainage_class VARCHAR(50),                  
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

-- Table 5: What the farmer did (farming practices)
CREATE TABLE management_data (
    management_id INT PRIMARY KEY AUTO_INCREMENT, -- Unique ID
    location_id INT,                              -- Links to locations
    year INT,                                     -- Which year
    planting_date DATE,                           -- When corn was planted
    harvest_date DATE,                            -- When corn was harvested
    irrigation BOOLEAN,                           -- TRUE if irrigated, FALSE if not
    tillage_type VARCHAR(50),                     -- How soil was prepared
    fertilizer_n_lbs_acre DECIMAL(8,2),         -- Nitrogen fertilizer pounds per acre
    fertilizer_p_lbs_acre DECIMAL(8,2),         -- Phosphorus fertilizer
    fertilizer_k_lbs_acre DECIMAL(8,2),         -- Potassium fertilizer
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

SHOW TABLES;

DESCRIBE locations;

-- Add some sample locations
INSERT INTO locations (state, county, fips_code, latitude, longitude) VALUES
('Iowa', 'Story County', '19169', 42.0308, -93.6319),
('Illinois', 'McLean County', '17113', 40.4842, -88.9399),
('Nebraska', 'Hamilton County', '31081', 40.9158, -98.1192);

-- Add some sample crop yields
INSERT INTO crop_yields (location_id, year, crop_type, yields_bushels_per_acre, planted_acres, harvested_acres) VALUES
(1, 2022, 'CORN', 195.5, 1000, 995),
(1, 2023, 'CORN', 203.2, 1000, 1000),
(2, 2022, 'CORN', 188.7, 800, 790),
(2, 2023, 'CORN', 192.1, 800, 800),
(3, 2022, 'CORN', 201.3, 1200, 1180),
(3, 2023, 'CORN', 198.9, 1200, 1200);

-- Add some sample weather data
INSERT INTO weather_data (location_id, year, month, avg_temp_f, min_temp_f, max_temp_f, precipitation_inches, growing_degree_days) VALUES
(1, 2022, 7, 75.2, 65.1, 85.3, 3.2, 310),
(1, 2022, 8, 78.1, 68.9, 87.3, 2.8, 330),
(2, 2022, 7, 76.8, 66.2, 87.4, 2.9, 320),
(2, 2022, 8, 79.2, 69.1, 89.3, 2.1, 340);

-- Add some sample soil data  
INSERT INTO soil_data (location_id, organic_matter_pct, ph_level, nitrogen_ppm, phosphorus_ppm, potassium_ppm, soil_type, drainage_class) VALUES
(1, 3.2, 6.8, 180, 35, 220, 'Silty Clay Loam', 'Well drained'),
(2, 2.9, 6.5, 165, 32, 205, 'Silt Loam', 'Moderately well drained'),  
(3, 3.5, 7.1, 195, 38, 235, 'Clay Loam', 'Well drained');

-- Add some sample management data
INSERT INTO management_data (location_id, year, planting_date, harvest_date, irrigation, tillage_type, fertilizer_n_lbs_acre, fertilizer_p_lbs_acre, fertilizer_k_lbs_acre) VALUES
(1, 2022, '2022-05-15', '2022-10-20', FALSE, 'No-till', 150, 60, 80),
(1, 2023, '2023-05-12', '2023-10-18', FALSE, 'No-till', 160, 65, 85),
(2, 2022, '2022-05-18', '2022-10-25', TRUE, 'Conventional till', 140, 55, 75),
(2, 2023, '2023-05-20', '2023-10-22', TRUE, 'Conventional till', 145, 58, 78);

-- Let's see what data we have
SELECT 
    l.state,
    l.county, 
    cy.year,
    cy.yields_bushels_per_acre,
    sd.organic_matter_pct,
    md.fertilizer_n_lbs_acre
FROM crop_yields cy
JOIN locations l ON cy.location_id = l.location_id  
JOIN soil_data sd ON cy.location_id = sd.location_id
JOIN management_data md ON cy.location_id = md.location_id AND cy.year = md.year
ORDER BY cy.yields_bushels_per_acre DESC;

USE crop_yield_db;

-- Reset the auto-increment counter for locations table
ALTER TABLE locations AUTO_INCREMENT = 1;

-- Check current locations
SELECT * FROM locations;

USE crop_yield_db;
ALTER TABLE locations AUTO_INCREMENT = 1;