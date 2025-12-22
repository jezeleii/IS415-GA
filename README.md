Geospatial Portfolio: https://is415-ga-jezelei.netlify.app/

# Geospatial Analysis of Armed Conflict in Myanmar (Take Home Exercise 1)

This project provides a detailed geospatial analysis of armed conflict events in Myanmar, focusing on the period from January 2021 to June 2024. The analysis explores the spatial and spatio-temporal patterns of these conflicts to identify hotspots and understand their distribution over time.

The primary analysis can be found in the Quarto document: `Take-Home_Exercise/TakeHomeEx01/TakeHomeEx01.qmd`.

## Data Sources

The analysis is built upon three key datasets:

*   **Armed Conflict Data**: Sourced from the Armed Conflict Location & Event Data Project (ACLED), covering events from January 2021 to June 2024.
*   **Administrative Boundaries**: Geospatial data for Myanmar's state and region boundaries were obtained from the Myanmar Information Management Unit (MIMU).
*   **Points of Interest (POI)**: Data from **OpenStreetMap**, specifically focusing on healthcare infrastructure like hospitals and clinics, was used for contextual analysis.

## Analytical Methods

The project employs several stages of geospatial analysis to uncover patterns in the conflict data.

### 1. Geospatial Data Wrangling

Before analysis, the raw data was extensively prepared:
*   **Importing and Transformation**: Conflict data (CSV) and boundary data (Shapefiles) were imported into R. The conflict data was converted into a simple features (`sf`) object for spatial operations.
*   **Coordinate Reference System (CRS)**: All spatial data was transformed to a consistent projected CRS (UTM zone 47N) to ensure accurate distance and area calculations.
*   **Subsetting**: The analysis focuses on the **Sagaing, Magway, and Mandalay** regions, which were identified as having the highest concentration of conflict events. The event type was filtered to **"Battles"** and the sub-event type to **"Armed clash"** for a more focused analysis.
*   **Data Conversion**: The prepared `sf` objects were converted into `sp` and `spatstat`'s `ppp` (planar point pattern) and `owin` (observation window) formats, which are required for advanced spatial statistics.
*   **Handling Duplicates**: Duplicate points, which arise from multiple events at the same location over time, were addressed by **jittering** (adding minor random noise) to avoid issues in density and distance calculations.

### 2. First-Order Spatial Point Pattern Analysis (Hotspot Analysis)

This analysis examines the intensity and distribution of conflict events across the study area.

*   **Kernel Density Estimation (KDE)**: KDE was used to visualize the intensity of armed clashes and identify hotspots. The analysis explored various bandwidth selection methods (`bw.diggle`, `bw.ppl`, etc.) to find the most appropriate level of smoothing.
*   **Quarterly KDE Comparison**: To analyze temporal changes, quarterly KDEs were computed using a fixed bandwidth. This ensures that the density surfaces are comparable across different time periods, revealing how hotspots evolve.
*   **Clark and Evans' Test**: This statistical test was performed to confirm that the observed point patterns were not random. The results consistently showed a statistically significant **clustered pattern** for armed clashes across all analyzed quarters.

### 3. Second-Order Spatial Point Pattern Analysis (Spatial Dependence)

This analysis was performed on the Sagaing region to understand the spatial dependence between conflict events at various distance scales.

*   **G-Function**: Used to analyze the distribution of distances from each event to its nearest neighbor. The results indicated strong clustering at small distances.
*   **F-Function**: Analyzed the distribution of distances from random points in the study area to the nearest event, providing insight into the empty space in the pattern.
*   **K-Function and L-Function**: These functions were used to explore spatial clustering over a range of distances. The L-function, a variance-stabilized transformation of the K-function, confirmed that armed clashes are significantly more clustered than would be expected under complete spatial randomness (CSR).

### 4. Spatio-Temporal Analysis

This section combines both space and time to visualize the evolution of conflict hotspots.

*   **Spatio-Temporal Data Preparation**: The dataset was structured to include a temporal component (quarterly intervals) for each event.
*   **Spatio-Temporal KDE (STKDE)**: STKDE was computed to generate density surfaces that show how the intensity of armed clashes changes over both space and time.
*   **Animated Visualization**: The results of the STKDE were used to create an animated GIF, providing a dynamic visualization of how conflict hotspots emerged and shifted on a quarterly basis.

## Key Insights

The analyses reveal that armed clashes in the selected regions of Myanmar are not randomly distributed but are highly clustered in specific hotspots. These hotspots show dynamic changes over time, with conflict intensity fluctuating across different quarters, particularly between **Q4 2021 and Q3 2022**.

Furthermore, the analysis highlights a concerning trend where conflict events are often located near critical civilian infrastructure. By overlaying healthcare facilities (hospitals, clinics) on the conflict maps, the study supports external reports suggesting that **healthcare has become a battleground**, especially in the heavily affected Sagaing region.
