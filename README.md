# Description

## Main scripts
* "Triode_g1_super.m" is a superscript, from which different parallel simulations can be run.
* "Triode_g1_initial.m" runs the model's initial period.
* "Triode_g1_sim.m" simulates the model over all subsequent periods.
* "Triode_g1_fig_exp.m" and "Triode_g1_fig_1.m" are used to create figures out of the simulations' results.

## Functions
The folder "functions" contains several functions used within the "Triode_g1_initial.m" and "Triode_g1_sim.m" scripts. In particular:
* "Triode_Production.m" and "Triode_Production_Nested.m" deal with the computation of industries' production (given expected final demand), accounting for (i) production constraints (either with a proportional rationing rule, or with the Mixed model formulation) and (ii) substitutability between green and brown electricity, with grid priority for the first.
* "Desired_Investments_function.m" deals with the computation of each industry's desired investment in each of the 6 different capital asset classes.
* "Triode_InvestmentsRationing.m" deals with the rationing of investment goods and the consequent adjustment of industries' desired investment in other capital assets.
* "Brown_sector_max_production_adj.m" deals with the total production capacity of brown electricity producers.
* "From_Sectional_Demand_to_Sectoral_Sales.m" receives the final demand for products as an input, and computes the implied industries' sales as an output, accounting for potential constraints in the availability of goods and services. It should be noted that the number of products (18) differs from the number of industries (27) since there are 10 industries that produce the same commodity, namely electricity.
* "From_Sectors_To_Sections_Function.m" transforms arrays related to industries into arrays related to products.

## Inputs
### Excel files
* "EuKlems_calibrated_data_for_model_2015.xlsx" contains the following data: capital productivities and depreciation rates for Triode's industries, as calibrated from EUKLEMS and other sources.
* "pxp_Exiobase_2015_aggregated_data_for_model_many_electricity_sectors.xlsx" contains the following data:
  * industries' technical coefficients, greenhouse gas emissions, pricing markups
  * the composition of the households' and government's final demand basket, as well as their greenhouse gas emissions
### Electricity weights IEA
* contains data calibrated from the International Energy Agency's (IEA) reports, related to the projections of the different green (solar PV, wind, etc) and brown (coal, gas, oil) utilities' weights in electricity production up to 2050, in three different energy transition scenarios defined by the IEA, namely STEPS, APS and NZE.
### Electrification IEA
* contains data calibrated from the IEA's reports, related to the different electrification efforts of distinct industry groups (energy intensive, non energy intensive, transportation, and services buildings) up to 2050, in three different energy transition scenarios defined by the IEA, namely STEPS, APS and NZE.
