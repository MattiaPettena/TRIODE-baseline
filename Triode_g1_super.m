%% CLEARING AND PATHS

clc
clear
%close all

%%%%%%%%  Change the current folder and add subfolders to path  %%%%%%%%
% Determine where your m-file's folder is. 
folder = [pwd,'/',mfilename];
% Change the current folder to the one containing our m-file
cd(folder)
% Add that folder plus all subfolders to the path.
addpath(genpath(folder));
clear folder
% Erase all the warning messages from the command window
clc


%% DEFINING THE DIFFERENT SIMULATIONS /1

% ENERGY TRANSITION SCENARIO RULE
    % "NT"                   --> No Transition: the target green share and the divisions' weights remain at their 2022 level.
    % "STEPS partial" 
    % "STEPS"
    % "APS partial"
    % "APS"
    % "NZE partial"
    % "NZE"
Variations.energy_transition_rule = ["NT" "STEPS" "APS" "NZE"]; % "NT" "STEPS" "APS" "NZE"


% MPC
% Variation of the Marginal Propensity to Consume out of income, compared to the baseline value
Variations.delta_MPC_income = [-0.2]; 


% EXPECTATIONS ON HOUSEHOLDS' DEMAND RULE
    % "known"             --> Sectors know the level of hhs' demand at the beginning of each period before engaging in production. The  hhs' demand is growing at an exogenously fixed growth rate.
    % "unknown & naive"   --> Sectors don't know the level of hhs' demand at the beginning of each period before engaging in production, and form naive expectations.
    % "unknown & complex" --> Sectors don't know the level of hhs' demand at the beginning of each period before engaging in production, and form complex expectations..
                                % that is, they multiply previous period hh demand by the average growth rate of hh demand over the past X years.
Variations.hhs_demand_exp_rule = ["unknown & naive"];


% GOV'T DEMAND RULE
    % "no"                           --> gov't demand = 0
    % "yes - constant"               --> gov't demand > 0; its physical level is always equal to the value given by Exiobase
    % "yes - growing constantly"     --> gov't demand > 0; its physical level is growing at a constant (exogenously and arbitrarily set) growth rate
    % "yes - changing adaptively"    --> gov't demand > 0; its physical level is growing at a rate that depends on economic conditions, 
                                         % i.e. on the average growth rate (over the past X years) of some variable: e.g. real GDP or hhs physical demand.
    % "yes - constant share of GDP"  --> gov't demand > 0; its nominal amount is an exogenously set share of nominal GDP
Variations.govt_demand_rule = ["yes - growing constantly"]; 


% GOV'T DEMAND EXOGENOUS GROWTH RATE
% This applies only if the "Variations.govt_demand_rule" = "yes - growing constantly"
% Since this drives the real GDP growth rate of the model, you could set this value to be consistent with IMF projections for global real GDP growth:
% https://www.imf.org/external/datamapper/NGDP_RPCH@WEO/WEOWORLD
Variations.govt_demand_exogenous_growth_rate = [0.03];


% MINIMUM INVESTMENT RULE
    % "yes" --> there is a backstop investment
    % "no"  --> there is no backstop investment: an industry may invest 0.
Variations.min_investment_rule = ["yes"];


% INVESTMENT REFERENCE IN "CASE 2.B"
    % "min"
    % "max"
Variations.investment_reference_case_2B_rule = ["max"];


% INTEREST RATE
Variations.interest_rate = [0];


% END OF STABILIZATION OF THE MODEL
% Time step by which we assume that the model has stabilized, and different simulations may start
Variations.simulations_kickoff_after_stabilization = [200]; % either 2 or 42 (DON'T put 1, because then the electrification&decarbonization don't occur fully)


%% DEFINING THE DIFFERENT SIMULATIONS /2


% DESIRED PRODUCTION DRIVING INVESTMENT RULE
    % "old" --> depends on expected final demand | this increases fluctuations
    % "new" --> depends on current final demand
Variations.desired_production_driving_investment_rule = ["new"];


% DESIRED INVESTMENT FUNCTION RULE
    % "old" --> "Case 1" is treated in a simple and a bit inconsistent way
    % "new" --> "Case 1" is treated in a complex but consistent way
Variations.desired_investment_function_rule = ["new"];


% TARGET GREEN SHARE ENFORCEMENT RULE
    % "yes"  --> if green share overshoots its target value, we force it to be equal to the target.
    % "no"   --> we let the green share take whatever value.
Variations.target_green_share_enforcement_rule = ["yes"];


% UNIT COSTS RULE
    % "including capital depreciation"     --> unit costs include capital depreciation per unit of products
    % "not including capital depreciation" --> unit costs don't include capital depreciation per unit of products
Variations.unit_costs_rule = ["not including capital depreciation"];


% HOUSEHOLD'S DEMAND ELASTICITY
    % "fixed physical proportions"  --> household's physical demand for different goods isn't impacted by relative prices, and therefore physical demand relations are constant over time (except for the changes implied by electrification)
    % "AIDS elasticity"             --> when relative prices change, the household changes its physical consumption behavior. I.e., in physical proportions terms, it consumes less of the good that has become relatively more expensive and more of the good that has become relatively cheaper.
    % "fixed nominal proportions"   --> this is exactly the opposite compared to "fixed physical proportions". Household's nominal (as opposed to physical) demand for different goods isn't impacted by relative prices.
Variations.hhs_demand_elasticity_rule = ["fixed physical proportions"];


% ELECTRICITY SECTORS SHADOW PRICE RULE
% This rule establishes how the "shadow" price is being set at the sectoral level, i.e. for the green and the brown electricity sectors.
% (Then, given the shadow prices of the green and brown sectors, ..
% ..the rule "Variations.electricity_price_rule" will decide how the final (unique) price for electricy is set.)
% Shadow pricing rules:
    % "max among all divisions within that sector"              --> the sector's shadow price is the max among the respective divisions' shadow prices
    % "weighted average among all divisions within that sector" --> the sector's shadow price is the weighted average of the respective divisions' shadow prices
Variations.electricity_sectors_shadow_price_rule = ["weighted average among all divisions within that sector"];


% ELECTRICITY PRICE RULE
    % "max price among green and brown, unless green share is 100%" --> when the green share is 100%, the electricity price equals the green electricity price
    % "max price among green and brown, always"                     --> even if the green share is 100%, the electricity price is given by the highest price among green and brown
Variations.electricity_price_rule = ["max price among green and brown, always"];


% NET PRESENT VALUE (NPV) RULE
    % "no"  --> Divisions do not take the NPV into account when deciding on their investments
    % "yes" --> Divisions do take the NPV into account when deciding on their investments and may receive gov't subsidies
Variations.NPV_rule = ["no"];


% DEPRECIATION RULE
    % "entire capital"                           --> the entire capital stock gets depreciated
    % "only used capital"                        --> only used capital stock gets depreciated
    % "only used capital - but assuming entire"  --> only used capital stock gets depreciated, but when calculating their desired investments, Divisions assume that the entire capital stock will get depreciated (or that their capacity utilization will be 100%)
Variations.depreciation_rule = ["entire capital"];


%% DEFINING THE DIFFERENT SIMULATIONS /3

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   DEFINE THE VARIATIONS OF RULES   %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% GOV'T TAXATION RULE
    % "targeting deficit-to-GDP"  --> the gov't increases/decreases the tax rate depending on the deficit-to-GDP ratio
    % "targeting debt-to-GDP"     --> the gov't increases/decreases the tax rate depending on the debt-to-GDP ratio
Variations.govt_taxation_rule = ["targeting debt-to-GDP"];


% INITIAL INVESTMENT RULE
    % "no"                               --> at t=1, investment = 0
    % "yes - hypothetical growth rate"   --> at t=1, investment > 0; the amount is implied by a desired production level implied by an assumed growth rate.
    % "yes - capital depreciation"       --> at t=1, investment > 0; the amount is given by the depreciated capital, assuming that all capital is affected by depreciated.
Variations.initial_investment_rule = ["yes - capital depreciation"];


% ELECTRICITY DIVISIONS' TECHNICAL COEFFICIENTS ADJUSTMENT RULE
    % "no"  --> technical coefficients don't get adjusted: they are exactly as given by Exiobase
    % "yes" --> technical coefficients get adjusted
Variations.electricity_divisions_tech_coeff_adjustment_rule = ["yes"];


% RATIONING RULE
% When one or more sectors are constrained in their production (e.g. due to insufficient capital), there are alternative methods to deal with these constraints:
    % (A) "proportional rationing" --> Strict proportional rationing: the rationing is applied equally to all customers (intermediate custormers and final demand customers).
    % (B) "mixed model" --> Mixed model methodology: intermediate sales are prioritezed over final demand sales. See Chapter 13.2.1 in Miller and Blair (2009).
% While the constraints are dealt with by the function "Triode_Production", the latter needs as input the information on which method it has to apply.
Variations.rationing_rule = ["proportional rationing"];


% ELECTRICITY SECTOR AGGREGATION RULE
    % "one_electricity_sector"     --> the Electricity sector does not distinguish between green and brown
    % "two_electricity_sectors"    --> the Electricity sector distinguishes between green and brown
    % "many_electricity_sectors"   --> the Electricity sector features (almost) all Exiobase electricity sectors
Variations.electricity_sector_aggregation_rule = ["many_electricity_sectors"];


% PRODUCTION DRIVING INVESTMENT RULE
    % "desired" --> the desired level of production is the value that sectors look at to determine their desired investment
    % "actual"  --> the actual level of production is the value that sectors look at to determine their desired investment
Variations.production_driving_investment_rule = ["desired"];


% INVESTMENT RATIONING RULE
% When available investment goods are less than investment demand, sectors may follow 2 different rules:
    % "simple"   --> sectors simply acquire the available investment goods without rescaling their demand for the other complementary investment goods.
    % "rescaled" --> sectors react to the rationing by rescaling their demands of all investment goods so as to ensure that the resulting new capital stocks levels are all equal in terms of maximum production potential.
Variations.investment_rationing_rule = ["rescaled"];


% INVENTORIES RULE
    % "no"  --> sectors do not accumulate inventories, i.e. all unsold products get immediately destroyed.
    % "yes" --> sectors accumulate inventories, i.e. their unsold products.
Variations.inventories_rule = ["yes"];


% BANK'S DIVIDEND RULE
    % "no"           --> the bank never distributes dividends
    % "yes - rough"  --> the bank checks its previous year's Capital Adequacy Ratio (CAR): if it is less than the target, the bank will not distribute dividends. Otherwise, it will distribute all profits (or a fixed share of them).
    % "yes - smooth" --> the bank distributes an amount of dividends that will imply the resulting CAR to be equal to the target. 
Variations.bank_dividends_rule = ["yes - smooth"];


% HOUSEHOLDS' CONSUMPTION BUDGET RULE REGARDING INCOME
    % "rough"   --> consumption budget depends on last period's income (and on wealth)
    % "smooth"  --> consumption budget depends on the average income over the past X years (and on wealth)
Variations.hhs_consumption_budget_income_rule = ["smooth"];


% HOUSEHOLDS' CONSUMPTION BUDGET RULE REGARDING WEALTH
    % "rough"   --> consumption budget depends on last period's wealth (and on income)
    % "smooth"  --> consumption budget depends on the average wealth over the past X years (and on income)
Variations.hhs_consumption_budget_wealth_rule = ["rough"];


% MARKUP RULE
    % "constant: arbitrary" --> the markup is constant and uniform across sectors (exogenously and arbitrarily set)
    % "constant: Exiobase"  --> the markup is constant, but sector-specific, and derived from Exiobase
    % "variable: demand vs supply"    --> the markup is variable and can move within a range, depending on the discrepancy of supply vs demand. The more the supply is abundant compared to expected demand, the lower the markup.
Variations.markup_rule = ["constant: Exiobase"];


%% DEFINING THE DIFFERENT SIMULATIONS /4


% YEAR USED IN CALIBRATION
% Year for which we take values from Exiobase and EuKlems to calibrate the model
Variations.calibration_year = [2015];


% EXPECTED HOUSEHOLD DEMAND CORRECTION
% Used when the Sections form naive expectations over hhs demand
% i.e., instead of expecting simply Demand(t-1), they expect (1 + exp_hh_demand_correction) * Demand(t-1)
% When exp_hh_demand_correction > 0, this helps preventing hhs demand rationing.
Variations.exp_hh_demand_correction = [0.09]; % 0.09


% LEVERAGE CEILING
% Leverage ceiling values
Variations.leverage_target = [2];


% INVESTMENT THRESHOLD
% These values express the value assigned to the investment threshold
    % Decreasing this parameter has an important impact on simulations if that helps preventing rationing. 
    % But once you have no rationing, decreasing it further seems to have no impact on simulations.
Variations.investment_threshold = [0.6];


% BANK'S CAPITAL REQUIREMENT
% These values express the value assigned to the capital requirement
Variations.bank_capital_requirement = [0]; % 0.01


% BANK'S TARGET CAR
% These values express the increase (if positive) or decrease (if negative) compared to the capital requirement.
Variations.bank_CAR_target_delta = [0];


% TIME SPAN OVER WHICH TO COMPUTE THE AVERAGE INCOME OR WEALTH IN THE HH CONSUMPTION BUDGET
Variations.hhs_consumption_budget_time_span_avg = [5];


% PERTURBATION OF DEPRECIATION RATES
% = 1 --> no perturbation
% < 1 --> perturbation that decreases the original value
% > 1 --> perturbation that increases the original value
Variations.depreciation_rates_perturbation = [1];


% PERTURBATION OF CAPITAL PRODUCTIVITY
% = 1 --> no perturbation
% < 1 --> perturbation that decreases the original value
% > 1 --> perturbation that increases the original value
Variations.capital_productivity_perturbation = [1]; %2


% PERTURBATION OF INITIAL PHYSICAL CAPITAL STOCKS
% = 1 --> no perturbation
% < 1 --> perturbation that decreases the original value
% > 1 --> perturbation that increases the original value
Variations.capital_stocks_perturbation = [1]; %10


%% SIMULATIONS' NUMBER, NAMES, AND SUMMARY TABLE

% NUMBER
% Total number of simulations
nr_simulations = max(structfun(@numel, Variations)); % finds the max numel of the fields in the Variations structure


% NAMES
% Assigning names to the different simulations
% OPTION 1: sim1, sim2, sim3, etc.
simulations_names = [];
for j = 1 : nr_simulations
    simulations_names = [simulations_names, {sprintf("sim %d", j)}];    
end
% OPTION 2: names of the energy transition scenarios
simulations_names = cellstr(Variations.energy_transition_rule);



% EMPTY SUMMARY TABLES
% ..in which we want to display the values of some indicators across the different simulations

% Define the names of the variables (i.e. columns) of the tables
table_1_variable_names = ...
    {'simulation'; 
    'avg_real_GDP_growth'; 'avg_CPI_inflation'; 'avg_deflator_inflation';
    'avg_real_consumption_growth_rate'; 'avg_real_investment_growth_rate';
    'avg_loans_growth_rate'; 'avg_deposits_growth_rate'};
table_2_variable_names = ...
    {'simulation';
    'nr_years_with_loan_rationing'; 'avg_loan_rationing';
    'nr_years_with_fin_dem_rationing'; 'avg_fin_dem_rationing'}; 
table_3_variable_names = ...
    {'simulation';    
    'nr_years_with_cap_acc_rationing'; 'avg_nr_divisions_with_cap_acc_rationing'; 'avg_cap_acc_rationing';
    'nr_years_with_hhs_dem_rationing'; 'avg_hhs_dem_rationing';
    'nr_years_with_govt_dem_rationing'; 'avg_govt_dem_rationing'};


% Create the empty tables
summary_table_1 = ...
    array2table(strings(nr_simulations, numel(table_1_variable_names)), 'VariableNames', table_1_variable_names);
summary_table_2 = ...
    array2table(strings(nr_simulations, numel(table_2_variable_names)), 'VariableNames', table_2_variable_names);
summary_table_3 = ...
    array2table(strings(nr_simulations, numel(table_3_variable_names)), 'VariableNames', table_3_variable_names);

% In the column called "simulation", we store the "simulations_names"
summary_table_1.simulation = simulations_names';
summary_table_2.simulation = simulations_names';
summary_table_3.simulation = simulations_names';


%% SIMULATIONS AND FIGURES
for sim_counter = 1 : nr_simulations
    %% RUN THE CURRENT SIMULATION

    [Rules, Parameters, Sections, Sectors, Divisions, Bank, Households, CentralBank, Government, Economy, Tests] = ...
        Triode_g1_sim(sim_counter, Variations);


    %% FILL THE SUMMARY TABLES

    % Note: in the following, we will store the data as strings and not as numbers because this allows us..
    % ..to set the number of decimals to be equal across all entries, thereby leading to a more readable table.
    % (Otherwise, e.g. the number 0.0340 would be automatically displayed by Matlab as 0.034, implying that it is not in line with e.g. the number 0.0423)
    % Note that in order to actually save the strings into the table as strings, you need to create an empty string table at the beginning and not an empty table of numbers:
    % in the latter case Matlab would convert the string to a number when storing it into the table.
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%  TABLE 1  %%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Average GDP growth
    summary_table_1{sim_counter, strcmp(summary_table_1.Properties.VariableNames, 'avg_real_GDP_growth')} = ...
        sprintf(" %.4f ", Economy.average_GDP_real_growth_rate); 
    
    % Average CPI inflation
    summary_table_1{sim_counter, strcmp(summary_table_1.Properties.VariableNames, 'avg_CPI_inflation')} = ...
        sprintf(" %.4f ", Economy.average_CPI_inflation);
    
    % Average GDP deflator inflation
    summary_table_1{sim_counter, strcmp(summary_table_1.Properties.VariableNames, 'avg_deflator_inflation')} = ...
        sprintf(" %.4f ", Economy.average_GDP_deflator_inflation);

    % Average real consumption growth rate
    summary_table_1{sim_counter, strcmp(summary_table_1.Properties.VariableNames, 'avg_real_consumption_growth_rate')} = ...
        sprintf(" %.4f ", Economy.average_hhs_consumption_defl_growth_rate);

    % Average real investment growth rate
    summary_table_1{sim_counter, strcmp(summary_table_1.Properties.VariableNames, 'avg_real_investment_growth_rate')} = ...
        sprintf(" %.4f ", Economy.average_investment_defl_growth_rate);
    
    % Average growth rate of loans
    summary_table_1{sim_counter, strcmp(summary_table_1.Properties.VariableNames, 'avg_loans_growth_rate')} = ...
        sprintf(" %.4f ", Economy.average_loans_stock_growth_rate);
    
    % Average growth rate of deposits
    summary_table_1{sim_counter, strcmp(summary_table_1.Properties.VariableNames, 'avg_deposits_growth_rate')} = ...
        sprintf(" %.4f ", Economy.average_deposits_growth_rate);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%  TABLE 2  %%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % LOANS RATIONING    
    % Number of years in which loans rationing occurs
    summary_table_2{sim_counter, strcmp(summary_table_2.Properties.VariableNames, 'nr_years_with_loan_rationing')} = ...
        sprintf(" %d ", Economy.nr_years_with_loans_rationing);    
    % Average loans rationing across the years where rationing occurs
    summary_table_2{sim_counter, strcmp(summary_table_2.Properties.VariableNames, 'avg_loan_rationing')} = ...
        sprintf(" %.4f ", Economy.average_loans_rationing);

    % FINAL DEMAND RATIONING
    % Number of years in which final demand rationing occures
    summary_table_2{sim_counter, strcmp(summary_table_2.Properties.VariableNames, 'nr_years_with_fin_dem_rationing')} = ...
        sprintf(" %d ", Economy.nr_years_with_final_demand_rationing);
    % Average final demand rationing across the years where rationing occurs
    summary_table_2{sim_counter, strcmp(summary_table_2.Properties.VariableNames, 'avg_fin_dem_rationing')} = ...
        sprintf(" %.4f ", Economy.average_final_demand_rationing);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%  TABLE 3  %%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % CAPACITY ACCUMULATION RATIONING
    % Number of years in which at least one sector suffered from capacity accumulation rationing
    summary_table_3{sim_counter, strcmp(summary_table_3.Properties.VariableNames, 'nr_years_with_cap_acc_rationing')} = ...
        sprintf(" %d ", Economy.nr_years_with_capacity_accumulation_rationing);    
    % Average number of sectors suffering from rationing in the years where rationing occurs
    summary_table_3{sim_counter, strcmp(summary_table_3.Properties.VariableNames, 'avg_nr_divisions_with_cap_acc_rationing')} = ...
        sprintf(" %.2f ", Economy.average_nr_divisions_with_capacity_accumulation_rationing);
    % Average capacity accumulation rationing in the years where rationing occurs, across sectors where rationing occurs
    summary_table_3{sim_counter, strcmp(summary_table_3.Properties.VariableNames, 'avg_cap_acc_rationing')} = ...
        sprintf(" %.4f ", Economy.average_capacity_accumulation_rationing);

    % HHS DEMAND RATIONING
    % Number of years in which hhs demand rationing occures
    summary_table_3{sim_counter, strcmp(summary_table_3.Properties.VariableNames, 'nr_years_with_hhs_dem_rationing')} = ...
        sprintf(" %d ", Economy.nr_years_with_hhs_demand_rationing);
    % Average hhs demand rationing across the years where rationing occurs
    summary_table_3{sim_counter, strcmp(summary_table_3.Properties.VariableNames, 'avg_hhs_dem_rationing')} = ...
        sprintf(" %.4f ", Economy.average_hhs_demand_rationing);  

    % GOV'T DEMAND RATIONING
    % Number of years in which gov't demand rationing occures
    summary_table_3{sim_counter, strcmp(summary_table_3.Properties.VariableNames, 'nr_years_with_govt_dem_rationing')} = ...
        sprintf(" %d ", Economy.nr_years_with_govt_demand_rationing);
    % Average gov't demand rationing across the years where rationing occurs
    summary_table_3{sim_counter, strcmp(summary_table_3.Properties.VariableNames, 'avg_govt_dem_rationing')} = ...
        sprintf(" %.4f ", Economy.average_govt_demand_rationing);  
    

    % DISPLAY THE SUMMARY TABLES
    summary_table_1
    summary_table_2
    summary_table_3
    

    %% CREATE THE FIGURES THAT REFER TO THE CURRENT SIMULATION

    %Triode_g1_fig_1(Rules, Parameters, Sections, Sectors, Divisions, Bank, Households, CentralBank, Government, Economy, ...
        %sprintf('figures_sim_%d', sim_counter), sprintf('sim_%d_fig', sim_counter));

    %% CREATE THE FIGURES THAT COMPARE DIFFERENT SIMULATIONS
        %% Creation of empty arrays
        
        % Creating empty arrays that will contain data of all simulations.        

        if sim_counter == 1                        
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%  BAR PLOTS  %%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            % Measured in physical units
            Data.bar_plot_productions_phys = NaN * ones(Parameters.Sectors.nr, nr_simulations);
            Data.bar_plot_final_demand_sales_phys = NaN * ones(Parameters.Sectors.nr, nr_simulations);  
            Data.bar_plot_interindustry_sales_phys = NaN * ones(Parameters.Sectors.nr, nr_simulations);
            % Measured in deflated values
            Data.bar_plot_productions_defl = NaN * ones(Parameters.Sectors.nr, nr_simulations);
            Data.bar_plot_final_demand_sales_defl = NaN * ones(Parameters.Sectors.nr, nr_simulations);  
            Data.bar_plot_interindustry_sales_defl = NaN * ones(Parameters.Sectors.nr, nr_simulations);
            % Sectoral emissions
            Data.bar_plot_sectoral_emissions = NaN * ones(Parameters.Sectors.nr, nr_simulations);
            % Sectors' deflated investment
            Data.bar_plot_sectoral_deflated_investment = NaN * ones(Parameters.Sectors.nr, nr_simulations);
            % Divisions' investment costs in each asset
            Data.bar_plot_divisional_investment_cost_breakdown = NaN * ones(Parameters.Sections.nr, Parameters.Divisions.nr, nr_simulations);



            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%  LINE PLOTS  %%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


            %%%%%%%%%%%%%    MACROECONOMIC PLOTS    %%%%%%%%%%%%%%

            % REAL GDP LEVEL
            Data.GDP_level_real_comparison = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            
            % REAL GDP GROWTH RATE
            Data.GDP_growth_rate_real_comparison = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.avg_GDP_growth_rate_real_comparison = NaN * ones(1, nr_simulations);
            
            % INVESTMENT
            Data.investment_defl_comparison = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.investment_defl_growth_rate_comparison = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.avg_investment_defl_growth_rate_comparison = NaN * ones(1, nr_simulations);
            Data.aggr_investments_in_each_asset_nominal = NaN * ones(Parameters.Sections.nr, Parameters.valid_results_time_span_length, nr_simulations);
            
            % REAL (DEFLATED) HHS CONSUMPTION
            Data.hhs_consumption_defl_comparison = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.hhs_consumption_defl_growth_rate_comparison = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.avg_hhs_consumption_defl_growth_rate_comparison = NaN * ones(1, nr_simulations);

            % REAL (DEFLATED) GOV'T CONSUMPTION
            Data.govt_consumption_defl_comparison = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);

            % INFLATION
            % GDP deflator inflation
            Data.GDP_deflator_inflation = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.avg_GDP_deflator_inflation = NaN * ones(1, nr_simulations);
            % CPI inflation
            Data.CPI_inflation = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.avg_CPI_inflation = NaN * ones(1, nr_simulations);

            % SHARE OF .. IN TOTAL NOMINAL PRODUCTION
            % .. Household consumption ..
            Data.share_hh_cons_in_nominal_production = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            % .. Gov't consumption ..
            Data.share_govt_cons_in_nominal_production = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            % .. Investment ..
            Data.share_investment_in_nominal_production = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            % .. Intermediate sales ..
            Data.share_intermediate_in_nominal_production = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            % .. Change in inventories ..
            Data.share_delta_inventories_in_nominal_production = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);


            %%%%%%%%%%%%%    GREEN VARIABLES PLOTS    %%%%%%%%%%%%%%            
            
            Data.green_share_comparison = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations); 
            Data.green_share_target_comparison = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations); 
            Data.green_max_production_comparison = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);            
            % Units of electricity produced
            Data.electricity_production_phys = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            % Divisions' weights within their Sector
            Data.divisions_sectoral_weights = NaN * ones(Parameters.valid_results_time_span_length, Parameters.Divisions.nr, nr_simulations);
            Data.divisions_sectoral_target_weights = NaN * ones(Parameters.valid_results_time_span_length, Parameters.Divisions.nr, nr_simulations);
            % Divisions' weights within their Section
            Data.divisions_sectional_weights = NaN * ones(Parameters.valid_results_time_span_length, Parameters.Divisions.nr, nr_simulations);
            Data.divisions_sectional_target_weights = NaN * ones(Parameters.valid_results_time_span_length, Parameters.Divisions.nr, nr_simulations);
            
            % EMISSIONS
            Data.emissions_total_stock_comparison = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.emissions_total_flow_comparison = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.emissions_flow_from_electricity_percentage_comparison = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);   


            %%%%%%%%%%%%%    OTHER PLOTS    %%%%%%%%%%%%%%

            % HOUSEHOLD
            Data.hhs_consumption_basket_units_demanded = NaN * ones(Parameters.valid_results_time_span_length, Parameters.Households.nr, nr_simulations);
            Data.hhs_demand_relations_phys_percentage_change = NaN * ones(Parameters.Sections.nr, Parameters.valid_results_time_span_length, nr_simulations);

            % INDUSTRIES or PRODUCTS
            Data.sectors_production_nominal = NaN * ones(Parameters.Sectors.nr, Parameters.valid_results_time_span_length, nr_simulations); 
            Data.sections_production_phys = NaN * ones(Parameters.Sections.nr, Parameters.valid_results_time_span_length, nr_simulations);  
            Data.sections_intermediate_sales_aggr_phys = NaN * ones(Parameters.Sections.nr, Parameters.valid_results_time_span_length, nr_simulations);  
            Data.sections_investment_sales_aggr_phys = NaN * ones(Parameters.Sections.nr, Parameters.valid_results_time_span_length, nr_simulations);  

            % BANK
            Data.bank_loans_stock = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.bank_deposits = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.bank_reserves_holdings = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.bank_advances = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.bank_net_worth = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.bank_capital_requirement = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.bank_CAR = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.bank_CAR_target = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.proportion_supply_vs_demanded_loans = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);

            % GOVERNMENT
            Data.govt_deficit_to_GDP_ratio = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.govt_debt_to_GDP_ratio = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.tax_rate = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations);
            Data.govt_consumption_basket_units_demanded_in1year = NaN * ones(Parameters.valid_results_time_span_length, nr_simulations); 


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%  EXERCISE  %%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            Data.Exercise.hh_consumption_basket_sectional = NaN * ones(Parameters.Sections.nr, nr_simulations);
            Data.Exercise.C_rectangular = NaN * ones(Parameters.Sections.nr, Parameters.Divisions.nr, nr_simulations);
            Data.Exercise.capital_productivity = NaN * ones(Parameters.Sections.nr, Parameters.Divisions.nr, nr_simulations);
            Data.Exercise.depreciation_rates = NaN * ones(Parameters.Sections.nr, Parameters.Divisions.nr, nr_simulations);
            Data.Exercise.target_sectional_weights = NaN * ones(nr_simulations, Parameters.Divisions.nr);


            %%%%%%%%%%%%%    TESTS    %%%%%%%%%%%%%%

            % TESTS
            Data.test_negative_NPV = strings(1, nr_simulations);
            Data.green_vs_brown_shadow_price = NaN * ones(Parameters.T, nr_simulations);

        end


        %% Saving data after each simulation
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%  BAR PLOTS  %%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Defining the time span over which we want to consider data when computing average values for the bar plots
        time_span_bar_plots = Parameters.valid_results_time_span;
        % Use this if you want to compute the average only across certain years
        % (end-9):end
        time_span_bar_plots = Parameters.valid_results_time_span(58);

    
        % AVERAGE REAL PRODUCTION; AVERAGE REAL SALES TO FINAL DEMAND; AVERAGE REAL INTERINDUSTRY SALES
        % The average is performed on the specified time_span_bar_plots (we want to exclude initial adjustment period).
        
        % Expressed in units of products
        for k = 1 : Parameters.Sectors.nr
            Data.bar_plot_productions_phys(k, sim_counter) = mean(Sectors.production_phys(k, time_span_bar_plots));
            Data.bar_plot_final_demand_sales_phys(k, sim_counter) = mean(Sectors.sales_to_final_demand_phys(k, time_span_bar_plots));
            Data.bar_plot_interindustry_sales_phys(k, sim_counter) = mean(sum(Sectors.S_square(k, :, time_span_bar_plots), 2));
        end
        
        % Expressed in deflated values (i.e. units x price / GDPdeflator)
        for k = 1 : Parameters.Sectors.nr
            Data.bar_plot_productions_defl(k, sim_counter) = ...
                mean(Sectors.production_phys(k, time_span_bar_plots)' .* Sectors.prices(time_span_bar_plots, k) ./ Economy.GDP_deflator(time_span_bar_plots));
            Data.bar_plot_final_demand_sales_defl(k, sim_counter) = ...
                mean(Sectors.sales_to_final_demand_phys(k, time_span_bar_plots)' .* Sectors.prices(time_span_bar_plots, k) ./ Economy.GDP_deflator(time_span_bar_plots));
            Data.bar_plot_interindustry_sales_defl(k, sim_counter) = ...
                mean(reshape(sum(Sectors.S_square(k,:,time_span_bar_plots), 2), [], 1) .* Sectors.prices(time_span_bar_plots, k) ./ Economy.GDP_deflator(time_span_bar_plots));

            Data.bar_plot_sectoral_deflated_investment(k, sim_counter) = ...
                mean(Sectors.investments_costs_defl(time_span_bar_plots, k));

        end
    
        
        % TOTAL SECTORAL EMISSIONS
        for k = 1 : Parameters.Sectors.nr
            Data.bar_plot_sectoral_emissions(k, sim_counter) = sum(Sectors.emissions_flow(time_span_bar_plots, k));
        end


        % DIVISIONS' INVESTMENT COSTS IN EACH ASSET
        % We take the data in the very last period
        Data.bar_plot_divisional_investment_cost_breakdown(:, :, sim_counter) = ...
            Sections.sales_to_investing_divisions_nomin(:,:,end);        
        
    
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%  LINE PLOTS  %%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%%%%%    MACROECONOMIC PLOTS    %%%%%%%%%%%%%%
        
        % REAL GDP LEVEL
        Data.GDP_level_real_comparison(:, sim_counter) = Economy.GDP_real(Parameters.valid_results_time_span);
        
        % REAL GDP GROWTH RATE
        Data.GDP_growth_rate_real_comparison(:, sim_counter) = Economy.GDP_real_growth_rate(Parameters.valid_results_time_span);
        Data.avg_GDP_growth_rate_real_comparison(sim_counter) = Economy.average_GDP_real_growth_rate;
        
        % INVESTMENT
        Data.investment_defl_comparison(:, sim_counter) = Economy.investment_defl(Parameters.valid_results_time_span);
        Data.investment_defl_growth_rate_comparison(:, sim_counter) = Economy.investment_defl_growth_rate(Parameters.valid_results_time_span);
        Data.avg_investment_defl_growth_rate_comparison(sim_counter) = Economy.average_investment_defl_growth_rate;
        Data.aggr_investments_in_each_asset_nominal(:, :, sim_counter) = Economy.investments_in_each_asset_nominal(:, Parameters.valid_results_time_span);
        
        % REAL (DEFLATED) HHS CONSUMPTION
        Data.hhs_consumption_defl_comparison(:, sim_counter) = Economy.hhs_consumption_defl(Parameters.valid_results_time_span);
        Data.hhs_consumption_defl_growth_rate_comparison(:, sim_counter) = Economy.hhs_consumption_defl_growth_rate(Parameters.valid_results_time_span);
        Data.avg_hhs_consumption_defl_growth_rate_comparison(sim_counter) = Economy.average_hhs_consumption_defl_growth_rate;

        % REAL (DEFLATED) GOV'T CONSUMPTION
        Data.govt_consumption_defl_comparison(:, sim_counter) = Economy.govt_consumption_defl(Parameters.valid_results_time_span);

        % INFLATION
        % GDP deflator inflation
        Data.GDP_deflator_inflation(:, sim_counter) = Economy.GDP_deflator_inflation(Parameters.valid_results_time_span);
        Data.avg_GDP_deflator_inflation(sim_counter) = Economy.average_GDP_deflator_inflation;
        % CPI inflation
        Data.CPI_inflation(:, sim_counter) = Economy.CPI_inflation(Parameters.valid_results_time_span);
        Data.avg_CPI_inflation(sim_counter) = Economy.average_CPI_inflation;        


        % SHARE OF .. IN TOTAL NOMINAL PRODUCTION
        % .. Household consumption ..
        Data.share_hh_cons_in_nominal_production(:, sim_counter) = Economy.share_hh_cons_in_nominal_production(Parameters.valid_results_time_span);
        % .. Gov't consumption ..
        Data.share_govt_cons_in_nominal_production(:, sim_counter) = Economy.share_govt_cons_in_nominal_production(Parameters.valid_results_time_span);
        % .. Investment ..
        Data.share_investment_in_nominal_production(:, sim_counter) = Economy.share_investment_in_nominal_production(Parameters.valid_results_time_span);
        % .. Intermediate sales ..
        Data.share_intermediate_in_nominal_production(:, sim_counter) = Economy.share_intermediate_in_nominal_production(Parameters.valid_results_time_span);
        % .. Change in inventories ..
        Data.share_delta_inventories_in_nominal_production(:, sim_counter) = Economy.share_delta_inventories_in_nominal_production(Parameters.valid_results_time_span);            



        %%%%%%%%%%%    SECTIONAL, SECTORAL, and DIVISIONAL PLOTS   %%%%%%%%%%%  

        % PRODUCTION
        Data.sectors_production_nominal(:, :, sim_counter) = Sectors.production_nominal(:, Parameters.valid_results_time_span);
        Data.sections_production_phys(:, :, sim_counter) = Sections.production_phys(:, Parameters.valid_results_time_span);
        Data.sections_intermediate_sales_aggr_phys(:, :, sim_counter) = Sections.intermediate_sales_aggr_phys(:, Parameters.valid_results_time_span);
        Data.sections_investment_sales_aggr_phys(:, :, sim_counter) = ...
            reshape(sum(Sections.current_orders_from_investing_divisions_adj_for_rationing_phys(:, :, Parameters.valid_results_time_span), 2), Parameters.Sections.nr, Parameters.valid_results_time_span_length);

        % SECTIONAL PRICES
        my_field = sprintf('sectional_prices_sim_%d', sim_counter);
        Data.(my_field) = Sections.prices(Parameters.valid_results_time_span, :);   

        % SECTORAL PRODUCTION CAPACITY
        my_field = sprintf('sectors_production_capacity_sim_%d', sim_counter);
        Data.(my_field) = Sectors.prod_cap(:, Parameters.valid_results_time_span);

        % SECTORS' DEFLATED INVESTMENT COSTS
        my_field = sprintf('sectors_deflated_investment_sim_%d', sim_counter);
        Data.(my_field) = Sectors.investments_costs_defl(Parameters.valid_results_time_span, :);

        % SECTIONS' DEMAND FROM HHS
        my_field = sprintf('sections_demand_from_hhs_phys_sim_%d', sim_counter);
        Data.(my_field) = Sections.demand_from_hhs_phys(:, :, Parameters.valid_results_time_span);         
    
        % SECTIONAL CONSTRAINTS IN THE SUPPLY OF GOODS..
        % ..to expected final demand
        my_field = sprintf('sectional_supply_constraints_to_exp_final_demand_sim_%d', sim_counter);
        Data.(my_field) = Sections.exp_final_demand_fulfillment_constraints(:, Parameters.valid_results_time_span);
        % ..to final demand buyers
        my_field = sprintf('sectional_supply_constraints_to_final_demand_sim_%d', sim_counter);
        Data.(my_field) = Sections.final_demand_fulfillment_constraints(:, Parameters.valid_results_time_span);        
        % ..used for investment by purchasers
        my_field = sprintf('investment_goods_supply_sectional_constraints_sim_%d', sim_counter);
        Data.(my_field) = Sections.investm_demand_fulfillment_constraints(:, Parameters.valid_results_time_span);
        % ..to households
        my_field = sprintf('sectional_supply_constraints_to_hh_demand_sim_%d', sim_counter);
        Data.(my_field) = Sections.hhs_demand_fulfillment_constraints(:, Parameters.valid_results_time_span);
        % ..to gov't
        my_field = sprintf('sectional_supply_constraints_to_govt_demand_sim_%d', sim_counter);
        Data.(my_field) = Sections.govt_demand_fulfillment_constraints(:, Parameters.valid_results_time_span);

        % DIVISIONS' CAPACITY ACCUMULATION RATIONING
        my_field = sprintf('divisions_capacity_accumulation_rationing_sim_%d', sim_counter);
        Data.(my_field) = Divisions.capacity_accumulation_rationing(Parameters.valid_results_time_span, :); 

        % DIVISIONS' NPV
        my_field = sprintf('divisions_NPV_sim_%d', sim_counter);
        Data.(my_field) = Divisions.NPV(Parameters.valid_results_time_span, :); 

        % DIVISIONS' TECHNICAL COEFFICIENTS % CHANGE
        my_field = sprintf('tech_coeff_perc_change_sim_%d', sim_counter);
        Data.(my_field) = Divisions.C_rectangular_percentage_change(:, :, Parameters.valid_results_time_span); 
        

        %%%%%%%%%%%%%    GREEN VARIABLES PLOTS    %%%%%%%%%%%%%%

        % GREEN SECTOR VARIABLES
        if Rules.electricity_sector_aggregation ~= "one_electricity_sector"
            Data.green_share_comparison(:, sim_counter) = Economy.green_share_production(Parameters.valid_results_time_span);
            Data.green_share_target_comparison(:, sim_counter) = Parameters.Sectors.target_green_share(Parameters.valid_results_time_span);
            Data.green_max_production_comparison(:, sim_counter) = Sectors.prod_cap(Parameters.Sectors.idx_green, Parameters.valid_results_time_span);
        end                             

        % DIVISIONS' SECTORAL WEIGHTS
        Data.divisions_sectoral_weights(:, :, sim_counter) = Divisions.sectoral_weights(Parameters.valid_results_time_span, :);
        Data.divisions_sectoral_target_weights(:, :, sim_counter) = Parameters.Divisions.target_sectoral_weights(Parameters.valid_results_time_span, :);

        % DIVISIONS' SECTIONAL WEIGHTS
        Data.divisions_sectional_weights(:, :, sim_counter) = Divisions.sectional_weights(Parameters.valid_results_time_span, :);
        Data.divisions_sectional_target_weights(:, :, sim_counter) = Parameters.Divisions.target_sectional_weights(Parameters.valid_results_time_span, :);
    
        % EMISSIONS
        Data.emissions_total_stock_comparison(:, sim_counter) = Economy.emissions_stock(Parameters.valid_results_time_span);
        Data.emissions_total_flow_comparison(:, sim_counter) = Economy.emissions_flow(Parameters.valid_results_time_span);
        Data.emissions_flow_from_electricity_percentage_comparison(:, sim_counter) = Economy.emissions_flow_from_electricity_percentage(Parameters.valid_results_time_span);        

        % UNITS OF ELECTRICITY PRODUCED
        Data.electricity_production_phys(:, sim_counter) = ...
            sum(Sectors.production_phys([Parameters.Sectors.idx_green Parameters.Sectors.idx_brown], Parameters.valid_results_time_span));


        %%%%%%%%%%%%%    OTHER PLOTS    %%%%%%%%%%%%%%

        % HOUSEHOLD
        Data.hhs_consumption_basket_units_demanded(:, :, sim_counter) = Households.consumption_basket_units_demanded(Parameters.valid_results_time_span, :);
        Data.hhs_demand_relations_phys_percentage_change(:, :, sim_counter) = Households.demand_relations_phys_percentage_change(:, Parameters.valid_results_time_span);

        % BANK
        Data.bank_loans_stock(:, sim_counter) = Bank.loans_stock(Parameters.valid_results_time_span);
        Data.bank_deposits(:, sim_counter) = Bank.deposits(Parameters.valid_results_time_span);
        Data.bank_reserves_holdings(:, sim_counter) = Bank.reserves_holdings(Parameters.valid_results_time_span);
        Data.bank_advances(:, sim_counter) = Bank.advances(Parameters.valid_results_time_span);
        Data.bank_net_worth(:, sim_counter) = Bank.net_worth(Parameters.valid_results_time_span);
        Data.bank_capital_requirement(:, sim_counter) = Parameters.Bank.capital_requirement * ones(Parameters.valid_results_time_span_length, 1);
        Data.bank_CAR(:, sim_counter) = Bank.CAR(Parameters.valid_results_time_span);
        Data.bank_CAR_target(:, sim_counter) = Parameters.Bank.CAR_target * ones(Parameters.valid_results_time_span_length, 1);
        Data.proportion_supply_vs_demanded_loans(:, sim_counter) = Bank.proportion_supply_vs_demanded_loans(Parameters.valid_results_time_span);

        % GOVERNMENT
        Data.govt_deficit_to_GDP_ratio(:, sim_counter) = Government.deficit_to_GDP_ratio(Parameters.valid_results_time_span);
        Data.govt_debt_to_GDP_ratio(:, sim_counter) = Government.debt_to_GDP_ratio(Parameters.valid_results_time_span);
        Data.tax_rate(:, sim_counter) = Government.sectors_tax_rate(Parameters.valid_results_time_span);
        Data.govt_consumption_basket_units_demanded_in1year(:, sim_counter) = Government.consumption_basket_units_demanded_in1year(Parameters.valid_results_time_span);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%  EXERCISE  %%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        Data.Exercise.hh_consumption_basket_sectional(:, sim_counter) = Parameters.Households.demand_relations_phys_evolving(:, Parameters.T);
        Data.Exercise.C_rectangular(:, :, sim_counter) = Divisions.C_rectangular(:, :, Parameters.T);
        Data.Exercise.capital_productivity(:, :, sim_counter) = Divisions.capital_productivity(:, :, Parameters.T);
        Data.Exercise.depreciation_rates(:, :, sim_counter) = Parameters.Divisions.depreciation_rates;
        Data.Exercise.target_sectional_weights(sim_counter, :) = Parameters.Divisions.target_sectional_weights(Parameters.T, :);

       
        %%%%%%%%%%%%%    TESTS    %%%%%%%%%%%%%%

        Data.test_negative_NPV(sim_counter) = strjoin(Tests.non_electricity_divisions_with_negative_NPV, ' \n ');
        Data.green_vs_brown_shadow_price(:, sim_counter) = Sectors.green_vs_brown_shadow_price;


        %% Creating the figures

        if sim_counter == nr_simulations
            %Triode_g1_fig_exp(Rules, Parameters, Data, simulations_names)
        end

end
%% Warning messages

% TEST FOR NEGATIVE NPV IN NON-ELECTRICITY DIVISIONS
% We want to check if any non electricity-producing Division has experienced a negative NPV

% Index of simulations that have featured negative NPV for non-electricity Divisions
condition_for_warning_message_NPV = ~cellfun(@isempty, Data.test_negative_NPV);

% Write warning message
if any(condition_for_warning_message_NPV)
    for sim = 1 : nr_simulations
        if condition_for_warning_message_NPV(sim)
            warning('In simulation "%s", the following non electricity-producing Divisions have experienced a negative NPV in at least one time step: \n %s.', string(simulations_names(sim)), Data.test_negative_NPV(sim))
        end
    end
end


% TEST FOR GREEN VS BROWN SHADOW PRICE
% If the green electricity sector's shadow price is larger than the brown sector's one, we want to send a warning message

% Write warning message
for sim = 1 : nr_simulations
    condition_for_warning_message_markup = Data.green_vs_brown_shadow_price(:, sim) > 1;
    if any(condition_for_warning_message_markup)
        warning('In simulation "%s", in %d year(s) on a total of %d years, the green sector''s shadow price is larger than the brown sector''s one', string(simulations_names(sim)), sum(condition_for_warning_message_markup), Parameters.T)
    end
end




%% Check for multiple parallel simulations

% It may happen that, without wanting it, we are running multiple simulations in parallel.
% For example we may have defined:
    % Variations.energy_transition_rule = ["NT" "STEPS" "APS" "NZE"];
% .. which is the series of simulations we actually want to perform, but we may have forgotten that:
    % Variations.delta_MPC_income = [0 -0.4];
% .. while we would actually want:
    % Variations.delta_MPC_income = [0];
% If that is the case, we want to print an error message.

fields_with_multiple_items = [];

my_fieldnames = fieldnames(Variations);

for k = 1 : numel(my_fieldnames)
    if numel(Variations.(my_fieldnames{k})) > 1
        fields_with_multiple_items = [fields_with_multiple_items; string(my_fieldnames{k})];
    end
end

if numel(fields_with_multiple_items) > 1    
    error('You are running multiple simulations in parallel. Indeed, there is more than one field of the structure ''Variations'' that features multiple items. Specifically, the following fields: \n %s \n', strjoin(fields_with_multiple_items, ' \n '))
end

clear my_fieldnames


%% Check desired investment formula cases

% We want to check if in the long-run equilibrium, all Divisions invest in order to increase their productive capacity..
% ..or whether some invest according to a minimum backstop investment rule.

% Let's check whether in any of the last X periods, any Division has invested according to a different case from "case 1.A.2"
    % 0 --> no occurrence
    % 1 --> at least one occurrence
nr_periods = Parameters.T - 1; %50;
any(any(Divisions.desired_investment_formula_cases(end - nr_periods : end, :) == "case 2.B.1")); % ~= "case 1.A.2"

clear nr_periods