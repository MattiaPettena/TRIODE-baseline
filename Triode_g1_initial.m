function [Rules, Parameters, Sections, Sectors, Divisions, Bank, Households, CentralBank, Government, Economy] = ...
    Triode_g1_initial...
    (sim_counter, Variations)    
%% LEGENDA

% Variables labelled "_phys" are in physical units

% Variables labelled "_defl" are deflated


%% CLEARING AND PATHS

% CLEARING WORKSPACE, COMMAND WINDOW, AND CLOSING IMAGES
%clc
%clearvars -except Data  % "Data" is the structure that contains data for our figures that compare different policies
%close all


% PATHS

%%%%%%%%  Let's restore the search path to the factory-installed state  %%%%%%%%
% We do so because: imagine the following situation:
% you start Matlab and add a path to folder X containing certain txt files (e.g. containing a file called "A.txt"), and you perform some operations through a script.
% Then you want to perform some operations through another script on another file, also called "A.txt", contained in folder Y. So you add a path to the Y folder as well.
% But then, when you instruct Matlab to load the "A.txt" file, you're not sure whether you are taking the one from the X or from the Y folder!
% Therefore, at the beginning of each script it is good practice to restore the search path to the factory-installed state, to eliminate all (potentially unwanted) paths.
% Note by Mattia: I'm not sure this is the standard way of doing this though.
% Note: PROBLEM: with this method the problem is that if you do "restoredefaultpath" it seems that Matlab is not able to read the installed add-ons and toolboxes (such as the "Label" toolbox) anymore (at least on Mac).
% Indeed, Matlab add-ons (at least on Mac) are installed in a folder that is not within the Matlab root folder (see also here https://www.mathworks.com/help/matlab/matlab_env/macintosh-platform-conventions.html)
% So probably when you do "restoredefaultpath" Matlab is not able to access the add-ons folder.
% restoredefaultpath
% clear RESTOREDEFAULTPATH_EXECUTED

%%%%%%%%  Change the current folder and add subfolders to path  %%%%%%%%
% % Determine where your m-file's folder is. 
% folder = [pwd,'/',mfilename];
% % Change the current folder to the one containing our m-file
% % cd(folder)
% % Add that folder plus all subfolders to the path.
% addpath(genpath(folder));
% clear folder


%% TIME

% YEAR USED IN CALIBRATION
% Year for which we take values from Exiobase and EuKlems to calibrate the model
if numel(Variations.calibration_year) > 1
    Parameters.calibration_year = Variations.calibration_year(sim_counter); 
else
    Parameters.calibration_year = Variations.calibration_year;
end


% STARTING TIME STEP OF THE ENERGY TRANSITION SCENARIOS
% Time step by which we assume that the model has stabilized, and different simulations may start 
if numel(Variations.simulations_kickoff_after_stabilization) > 1
    Parameters.simulations_kickoff_after_stabilization = Variations.simulations_kickoff_after_stabilization(sim_counter); 
else
    Parameters.simulations_kickoff_after_stabilization = Variations.simulations_kickoff_after_stabilization;
end


% YEAR USED FOR SETTING THE GREEN SHARE AND ELECTRICITY WEIGHTS AND IMPLIED INITIAL PHYSICAL CAPITAL STOCKS
% This is the year corresponding to the "Parameters.simulations_kickoff_after_stabilization" time step
% You may choose among 2 different values to be assigned to this parameter:
    % = 2015  if you want the simulations to start in 2015 regarding the green share and electricity weights
        % Obviously, also the stabilization period before the start of the simulations will feature the green share and electricity weights of 2015
    % = 2022  if you want the simulations to start in 2022 regarding the green share and electricity weights
        % Obviously, also the stabilization period before the start of the simulations will feature the green share and electricity weights of 2022
% Depending on the value assigned to "Parameters.calibration_year", you may set "Parameters.year_of_simulations_kickoff" = "Parameters.calibration_year" or to a different year.
Parameters.year_of_simulations_kickoff = 2022;  % Parameters.calibration_year


% END OF THE ENERGY TRANSITION
% Time step by which we want the energy transition to be completed
end_year_energy_transition = 2050;
Parameters.end_of_energy_transition = ...
    (Parameters.simulations_kickoff_after_stabilization - 1) + numel(Parameters.year_of_simulations_kickoff : end_year_energy_transition);


% TIME STEP CORRESPONDING TO YEAR 2022
% Electrification and decarbonization parameters span from 2022 to 2050.
% We need a parameter that captures the time step corresponding to year 2022.
Parameters.time_step_corresponding_to_2022 = ...
    (Parameters.simulations_kickoff_after_stabilization - 1) + numel(Parameters.year_of_simulations_kickoff : 2022); 


% TOTAL NUMBER OF YEARS OF THE SIMULATION
additional_years_after_end_of_energy_transition = 50; % a value of 58 enables us to make the plots of a 60 years length, since the transition starts either in time t=2 or t=42
Parameters.T = Parameters.end_of_energy_transition + additional_years_after_end_of_energy_transition;


% TIME SPAN OF VALID RESULTS
% it starts with the end of the model's stabilization period, and ends at the end of the simulation.
% This time span is the one used to compute average values, and that is being showed in figures
Parameters.valid_results_time_span = (Parameters.simulations_kickoff_after_stabilization - 1) : Parameters.T; % we start from (Parameters.simulations_kickoff_after_stabilization - 1), because otherwise when the energy transition starts in period t=2 then the graphs would start at t=2 instead of t=1
% Defining the length of the time span
Parameters.valid_results_time_span_length = numel(Parameters.valid_results_time_span);
     

% SETTING THE INITIAL TIME STEP
t = 1;

    
%% RULES

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%   TIME-DEPENDENT RULES   %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ENERGY TRANSITION SCENARIO RULE
    % "NT"                   --> No Transition: the target green share and the divisions' weights remain at their 2022 level.
    % "STEPS partial" 
    % "STEPS"
    % "APS partial"
    % "APS"
    % "NZE partial"
    % "NZE"
Rules.energy_transition = [];
if t < Parameters.simulations_kickoff_after_stabilization
    Rules.energy_transition{t} = "NT";
else
    if numel(Variations.energy_transition_rule) > 1
        Rules.energy_transition{t} = Variations.energy_transition_rule(sim_counter);
    else
        Rules.energy_transition{t} = Variations.energy_transition_rule;
    end
end

% Define the energy transition scenario we are considering in the current simulation
if numel(Variations.energy_transition_rule) > 1
    energy_transition_rule = Variations.energy_transition_rule(sim_counter);
else
    energy_transition_rule = Variations.energy_transition_rule;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%   TIME-INDEPENDENT RULES   %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% DESIRED PRODUCTION DRIVING INVESTMENT RULE
    % "old" --> depends on expected final demand
    % "new" --> depends on current final demand
if numel(Variations.desired_production_driving_investment_rule) > 1
    Rules.desired_production_driving_investment = Variations.desired_production_driving_investment_rule(sim_counter);
else
    Rules.desired_production_driving_investment = Variations.desired_production_driving_investment_rule;
end


% DESIRED INVESTMENT FUNCTION RULE
    % "old" --> "Case 1" is treated in a simple and a bit inconsistent way
    % "new" --> "Case 1" is treated in a complex but consistent way
if numel(Variations.desired_investment_function_rule) > 1
    Rules.desired_investment_function = Variations.desired_investment_function_rule(sim_counter);
else
    Rules.desired_investment_function = Variations.desired_investment_function_rule;
end


% TARGET GREEN SHARE ENFORCEMENT RULE
    % "yes"  --> if green share overshoots its target value, we force it to be equal to the target.
    % "no"   --> we let the green share take whatever value.
if numel(Variations.target_green_share_enforcement_rule) > 1
    Rules.target_green_share_enforcement = Variations.target_green_share_enforcement_rule(sim_counter);
else
    Rules.target_green_share_enforcement = Variations.target_green_share_enforcement_rule;
end


% INITIAL INVESTMENT RULE
    % "no"                               --> at t=1, investment = 0
    % "yes - hypothetical growth rate"   --> at t=1, investment > 0; the amount is implied by a desired production level implied by an assumed growth rate.
    % "yes - capital depreciation"       --> at t=1, investment > 0; the amount is given by the depreciated capital, assuming that all capital is affected by depreciated.
if numel(Variations.initial_investment_rule) > 1
    Rules.initial_investment = Variations.initial_investment_rule(sim_counter);
else
    Rules.initial_investment = Variations.initial_investment_rule;
end


% NET PRESENT VALUE (NPV) RULE
    % "no"  --> Divisions do not take the NPV into account when deciding on their investments
    % "yes" --> Divisions do take the NPV into account when deciding on their investments and may receive gov't subsidies
if numel(Variations.NPV_rule) > 1
    Rules.NPV = Variations.NPV_rule(sim_counter);
else
    Rules.NPV = Variations.NPV_rule;
end


% ELECTRICITY DIVISIONS' TECHNICAL COEFFICIENTS ADJUSTMENT
    % "no"  --> technical coefficients don't get adjusted: they are exactly as given by Exiobase
    % "yes" --> technical coefficients get adjusted
if numel(Variations.electricity_divisions_tech_coeff_adjustment_rule) > 1
    Rules.electricity_divisions_tech_coeff_adjustment = Variations.electricity_divisions_tech_coeff_adjustment_rule(sim_counter);
else
    Rules.electricity_divisions_tech_coeff_adjustment = Variations.electricity_divisions_tech_coeff_adjustment_rule;
end


% RATIONING RULE
% When one or more sectors are constrained in their production (e.g. due to insufficient capital), there are alternative methods to deal with these constraints:
    % (A) "proportional rationing" --> Strict proportional rationing: the rationing is applied equally to all customers (intermediate custormers and final demand customers).
    % (B) "mixed model" --> Mixed model methodology: intermediate sales are prioritezed over final demand sales. See Chapter 13.2.1 in Miller and Blair (2009).
% While the constraints are dealt with by the function "Triode_Production", the latter needs as input the information on which method it has to apply.
if numel(Variations.rationing_rule) > 1
    Rules.rationing = Variations.rationing_rule(sim_counter);
else
    Rules.rationing = Variations.rationing_rule;
end


% ELECTRICITY SECTOR AGGREGATION RULE
    % "one_electricity_sector"     --> the Electricity sector does not distinguish between green and brown
    % "two_electricity_sectors"    --> the Electricity sector distinguishes between green and brown
    % "many_electricity_sectors"   --> the Electricity sector features (almost) all Exiobase electricity sectors
if numel(Variations.electricity_sector_aggregation_rule) > 1
    Rules.electricity_sector_aggregation = Variations.electricity_sector_aggregation_rule(sim_counter);
else
    Rules.electricity_sector_aggregation = Variations.electricity_sector_aggregation_rule;
end


% GOV'T DEMAND RULE
    % "no"                           --> gov't demand = 0
    % "yes - constant"               --> gov't demand > 0; its physical level is always equal to the value given by Exiobase
    % "yes - growing constantly"     --> gov't demand > 0; its physical level is growing at a constant (exogenously and arbitrarily set) growth rate
    % "yes - changing adaptively"    --> gov't demand > 0; its physical level is growing at a rate that depends on economic conditions, 
                                         % i.e. on the average growth rate (over the past X years) of some variable: e.g. real GDP or hhs physical demand.
    % "yes - constant share of GDP"  --> gov't demand > 0; its nominal amount is an exogenously set share of nominal GDP
if numel(Variations.govt_demand_rule) > 1
    Rules.govt_demand = Variations.govt_demand_rule(sim_counter);
else
    Rules.govt_demand = Variations.govt_demand_rule;
end


% GOV'T TAXATION RULE
    % "targeting deficit-to-GDP"  --> the gov't increases/decreases the tax rate depending on the deficit-to-GDP ratio
    % "targeting debt-to-GDP"     --> the gov't increases/decreases the tax rate depending on the debt-to-GDP ratio
if numel(Variations.govt_taxation_rule) > 1
    Rules.govt_taxation = Variations.govt_taxation_rule(sim_counter);
else
    Rules.govt_taxation = Variations.govt_taxation_rule;
end


% MINIMUM INVESTMENT RULE
    % "yes" --> there is a backstop investment
    % "no"  --> there is no backstop investment: an industry may invest 0.
if numel(Variations.min_investment_rule) > 1
    Rules.min_investment = Variations.min_investment_rule(sim_counter);
else
    Rules.min_investment = Variations.min_investment_rule;
end


% INVESTMENT REFERENCE IN "CASE 2.B"
    % "min"
    % "max"
if numel(Variations.investment_reference_case_2B_rule) > 1
    Rules.investment_reference_case_2B = Variations.investment_reference_case_2B_rule(sim_counter);
else
    Rules.investment_reference_case_2B = Variations.investment_reference_case_2B_rule;
end


% PRODUCTION DRIVING INVESTMENT RULE
    % "desired" --> the desired level of production is the value that sectors look at to determine their desired investment
    % "actual"  --> the actual level of production is the value that sectors look at to determine their desired investment
if numel(Variations.production_driving_investment_rule) > 1
    Rules.production_driving_investment = Variations.production_driving_investment_rule(sim_counter);
else
    Rules.production_driving_investment = Variations.production_driving_investment_rule;
end


% INVESTMENT RATIONING RULE
% When available investment goods are less than investment demand, sectors may follow 2 different rules:
    % "simple"   --> sectors simply acquire the available investment goods without rescaling their demand for the other complementary investment goods.
    % "rescaled" --> sectors react to the rationing by rescaling their demands of all investment goods so as to ensure that the resulting new capital stocks levels are all equal in terms of maximum production potential.
if numel(Variations.inventories_rule) > 1
    Rules.inventories = Variations.inventories_rule(sim_counter);
else
    Rules.inventories = Variations.inventories_rule;
end


% DEPRECIATION RULE
    % "entire capital"                           --> the entire capital stock gets depreciated
    % "only used capital"                        --> only used capital stock gets depreciated
    % "only used capital - but assuming entire"  --> only used capital stock gets depreciated, but when calculating their desired investments, Divisions assume that the entire capital stock will get depreciated (or that their capacity utilization will be 100%)
if numel(Variations.depreciation_rule) > 1
    Rules.depreciation = Variations.depreciation_rule(sim_counter);
else
    Rules.depreciation = Variations.depreciation_rule;
end


% HOUSEHOLD'S DEMAND ELASTICITY
    % "fixed physical proportions"  --> household's physical demand for different goods isn't impacted by relative prices, and therefore physical demand relations are constant over time (except for the changes implied by electrification)
    % "AIDS elasticity"             --> when relative prices change, the household changes its physical consumption behavior. I.e., in physical proportions terms, it consumes less of the good that has become relatively more expensive and more of the good that has become relatively cheaper.
    % "fixed nominal proportions"   --> this is exactly the opposite compared to "fixed physical proportions". Household's nominal (as opposed to physical) demand for different goods isn't impacted by relative prices.
if numel(Variations.hhs_demand_elasticity_rule) > 1
    Rules.hhs_demand_elasticity = Variations.hhs_demand_elasticity_rule(sim_counter);
else
    Rules.hhs_demand_elasticity = Variations.hhs_demand_elasticity_rule;
end


% INVENTORIES RULE
    % "no"  --> sectors do not accumulate inventories, i.e. all unsold products get immediately destroyed.
    % "yes" --> sectors accumulate inventories, i.e. their unsold products.
if numel(Variations.investment_rationing_rule) > 1
    Rules.investment_rationing = Variations.investment_rationing_rule(sim_counter);
else
    Rules.investment_rationing = Variations.investment_rationing_rule;
end


% BANK'S DIVIDEND RULE
    % "no"           --> the bank never distributes dividends
    % "yes - rough"  --> the bank checks its previous year's Capital Adequacy Ratio (CAR): if it is less than the target, the bank will not distribute dividends. Otherwise, it will distribute all profits (or a fixed share of them).
    % "yes - smooth" --> the bank distributes an amount of dividends that will imply the resulting CAR to be equal to the target. 
if numel(Variations.bank_dividends_rule) > 1
    Rules.bank_dividends = Variations.bank_dividends_rule(sim_counter);
else
    Rules.bank_dividends = Variations.bank_dividends_rule;
end


% HOUSEHOLDS' CONSUMPTION BUDGET RULE REGARDING INCOME
    % "rough"   --> consumption budget depends on last period's income (and on wealth)
    % "smooth"  --> consumption budget depends on the average income over the past X years (and on wealth)
if numel(Variations.hhs_consumption_budget_income_rule) > 1
    Rules.hhs_consumption_budget_income = Variations.hhs_consumption_budget_income_rule(sim_counter);
else
    Rules.hhs_consumption_budget_income = Variations.hhs_consumption_budget_income_rule;
end


% HOUSEHOLDS' CONSUMPTION BUDGET RULE REGARDING WEALTH
    % "rough"   --> consumption budget depends on last period's wealth (and on income)
    % "smooth"  --> consumption budget depends on the average wealth over the past X years (and on income)
if numel(Variations.hhs_consumption_budget_wealth_rule) > 1
    Rules.hhs_consumption_budget_wealth = Variations.hhs_consumption_budget_wealth_rule(sim_counter);
else
    Rules.hhs_consumption_budget_wealth = Variations.hhs_consumption_budget_wealth_rule;
end


% EXPECTATIONS ON HOUSEHOLDS' DEMAND RULE
    % "known"             --> Sectors know the level of hhs' demand at the beginning of each period before engaging in production. The  hhs' demand is growing at an exogenously fixed growth rate.
    % "unknown & naive"   --> Sectors don't know the level of hhs' demand at the beginning of each period before engaging in production, and form naive expectations.
    % "unknown & complex" --> Sectors don't know the level of hhs' demand at the beginning of each period before engaging in production, and form complex expectations.
if numel(Variations.hhs_demand_exp_rule) > 1
    Rules.hhs_demand_exp = Variations.hhs_demand_exp_rule(sim_counter);
else
    Rules.hhs_demand_exp = Variations.hhs_demand_exp_rule;
end


% MARKUP RULE
    % "constant: arbitrary" --> the markup is constant and uniform across sectors (exogenously and arbitrarily set)
    % "constant: Exiobase"  --> the markup is constant, but sector-specific, and derived from Exiobase
    % "variable: demand vs supply"    --> the markup is variable and can move within a range, depending on the discrepancy of supply vs demand. The more the supply is abundant compared to expected demand, the lower the markup.
if numel(Variations.markup_rule) > 1
    Rules.markup = Variations.markup_rule(sim_counter);
else
    Rules.markup = Variations.markup_rule;
end


% UNIT COSTS RULE
    % "including capital depreciation"     --> unit costs include capital depreciation per unit of products
    % "not including capital depreciation" --> unit costs don't include capital depreciation per unit of products
if numel(Variations.unit_costs_rule) > 1
    Rules.unit_costs = Variations.unit_costs_rule(sim_counter);
else
    Rules.unit_costs = Variations.unit_costs_rule;
end


% ELECTRICITY SECTORS SHADOW PRICE RULE
% This rule establishes how the "shadow" price is being set at the sectoral level, i.e. for the green and the brown electricity sectors.
% (Then, given the shadow prices of the green and brown sectors, ..
% ..the rule "Variations.electricity_price_rule" will decide how the final (unique) price for electricy is set.)
% Shadow pricing rules:
    % "max among all divisions within that sector"              --> the sector's shadow price is the max among the respective divisions' shadow prices
    % "weighted average among all divisions within that sector" --> the sector's shadow price is the weighted average of the respective divisions' shadow prices
if numel(Variations.electricity_sectors_shadow_price_rule) > 1
    Rules.electricity_sectors_shadow_price = Variations.electricity_sectors_shadow_price_rule(sim_counter);
else
    Rules.electricity_sectors_shadow_price = Variations.electricity_sectors_shadow_price_rule;
end


% ELECTRICITY PRICE RULE
    % "max price among green and brown, unless green share is 100%" --> when the green share is 100%, the electricity price equals the green electricity price
    % "max price among green and brown, always"                     --> even if the green share is 100%, the electricity price is given by the highest price among green and brown
if numel(Variations.electricity_price_rule) > 1
    Rules.electricity_price = Variations.electricity_price_rule(sim_counter);
else
    Rules.electricity_price = Variations.electricity_price_rule;
end


%% EXIOBASE AND EUKLEMS

% IMPORTING DATA FROM RELEVANT EXCEL FILE

% Name of the Excel file from which to import data
excel_file_Exiobase = sprintf("pxp_Exiobase_%d_aggregated_data_for_model_%s.xlsx", Parameters.calibration_year, Rules.electricity_sector_aggregation);
excel_file_EuKlems = sprintf('EuKlems_calibrated_data_for_model_%d.xlsx', Parameters.calibration_year);


%% PARAMETERS
    %% error tolerence in tests
    
    % Note that when we want to test whether two variables are equal (A = B), e.g. when checking stock-flow consistency,
    % checking e.g. whether abs(A - B) > 1e-6  may not make much sense because the right hand side (1e-6) is not taking into account the order of magnitude of A and B.
    % In other words, having a 1e-5 error between A=5 and B=5+1e-5 is qualitatively different from having the same error but with A=5000 and B=5000+1e-5.
    % Therefore, when running tests we will rather check: abs((A - B)/A) > 1e-6
    
    % Define the error tolerance:
    Parameters.error_tolerance_weak = 1e-3;
    Parameters.error_tolerance_medium = 1e-7;
    Parameters.error_tolerance_strong = 1e-12; 

    
    %% divisions / names, id, idx
    
    % Let's import the total output table from the Exiobase excel file
    % This is the table from which we will extract infos on Divisions' names and Divisions' total number.
    table_total_output_Exiobase = readtable(excel_file_Exiobase, 'Sheet', 'total_output', 'VariableNamingRule', 'preserve'); % setting 'VariableNamingRule' to 'preserve' prevents Matlab from renaming the variable names (it would erase blank spaces)        

    % DIVISIONS' NUMBER AND NAMES
    Parameters.Divisions.nr = height(table_total_output_Exiobase);
    Parameters.Divisions.names = table_total_output_Exiobase{:,'SectorsNames'};
    Parameters.Divisions.names = string(Parameters.Divisions.names); % convert cell array to string array
    if Rules.electricity_sector_aggregation == "many_electricity_sectors"
        Parameters.Divisions.names_green = readcell(excel_file_Exiobase, 'Sheet', 'green_sectors');
        Parameters.Divisions.names_brown = readcell(excel_file_Exiobase, 'Sheet', 'brown_sectors');
    end

    % DIVISIONS' SECTORAL BELONGING (NAMES)
    Parameters.Divisions.sector_id = strings(Parameters.Divisions.nr, 1);
    if Rules.electricity_sector_aggregation == "many_electricity_sectors"            
        for i = 1 : Parameters.Divisions.nr
            if ismember(Parameters.Divisions.names(i), Parameters.Divisions.names_green)
                Parameters.Divisions.sector_id(i) = "Green electricity";
            elseif ismember(Parameters.Divisions.names(i), Parameters.Divisions.names_brown)
                Parameters.Divisions.sector_id(i) = "Brown electricity";
            else
                Parameters.Divisions.sector_id(i) = Parameters.Divisions.names(i);
            end
        end
    else
        Parameters.Divisions.sector_id = Parameters.Divisions.names;
    end


    % DIVISIONS' GROUPINGS RELEVANT FOR THE ENERGY TRANSITION PROCESS
    % We classify the Divisions according to IEA's categories: 
    % (1) energy-intensive industries (accounting for 70% of global industry energy demand):        
        % iron and steel        
        % non-ferrous metals
        % non-metallic minerals (e.g. cement)
        % chemicals
        % paper, pulp and printing
    % (2) non-energy-intensive industries; 
        % construction; 
	    % food and tobacco; 
	    % machinery; 
	    % mining and quarrying (excluding mining and extraction of fuels, which aren’t covered); 
	    % transportation equipment; 
	    % wood and wood products; 
	    % and other industry not specified elsewhere.
    % (3) transport; 
    % (4) buildings (residential and services).

    % (1)
    Parameters.Divisions.IEAcategory.names.energy_intensive = [...
        "Metals processing"
        "Chemicals"
        ];    
    % (2)
    Parameters.Divisions.IEAcategory.names.non_energy_intensive = [...           
        "Metals mining"                
        %"Fossil fuels extraction"
        "ICT"
        "TraEq"
        "OMach"
        "Construction"
        "Manufacturing"        
        ];
    % (3)
    Parameters.Divisions.IEAcategory.names.transport = ...
        "Transportation";
    % (4)
    Parameters.Divisions.IEAcategory.names.services_buildings = [...        
        "PSTA"
        "SoftDB"        
        "Services"
        "Public"
        ];    
    Parameters.Divisions.IEAcategory.names.no_energy_transition = [...   
        "Agriculture" % Agriculture is likely not going to electrify significantly
        "Fossil fuels extraction"
        "Fossil fuels processing"                
        "Electricity transmission"
        %"Electricity"
        "Electricity hydro"
        "Electricity wind"
        "Electricity solarPV"
        "Electricity solarCSP"
        "Electricity geothermal"
        "Electricity nuclear"
        "Electricity biomass waste"
        "Electricity coal"
        "Electricity gas"
        "Electricity oil"              
        ];
    
    % TEST
    % Let's check whether we have forgotten any Division in the above classification, or whether we have duplicates (i.e. a Division being in more than one category)
    all_assigned_divisions = [Parameters.Divisions.IEAcategory.names.energy_intensive; Parameters.Divisions.IEAcategory.names.non_energy_intensive; 
        Parameters.Divisions.IEAcategory.names.services_buildings; Parameters.Divisions.IEAcategory.names.transport; 
        Parameters.Divisions.IEAcategory.names.no_energy_transition];
    if ~isequal(sort(all_assigned_divisions), sort(Parameters.Divisions.names))
        error('When classifying the Divisions according to IEA''s categories, one or more Divisions may have been forgotten or duplicated')
    end

    % SORTING ELEMENTS TO BE CONSISTENT WITH ORIGINAL ORDER
    % We want to make sure that the order of the Divisions in each "Parameters.Divisions.IEAcategory.names" ..
    % ..follows the original order in "Parameters.Divisions.names".
    my_fieldnames = fieldnames(Parameters.Divisions.IEAcategory.names);
    for i = 1 : numel(my_fieldnames)
        structure_field_i = Parameters.Divisions.IEAcategory.names.(my_fieldnames{i});
        [~, idx] = ismember(structure_field_i, Parameters.Divisions.names);        
        [~, sortIdx] = sort(idx);  
        % Sort the elements
        Parameters.Divisions.IEAcategory.names.(my_fieldnames{i}) = structure_field_i(sortIdx);        
        % Now that we have sorted the elements, we can also create an index
        [~, Parameters.Divisions.IEAcategory.idx.(my_fieldnames{i})] = ...
            ismember(Parameters.Divisions.IEAcategory.names.(my_fieldnames{i}), Parameters.Divisions.names); 
    end


    %% sectors & sections / names, id, idx
    

    % SECTORS' NUMBER AND NAMES
    % Let's import the table from the Exiobase excel file, that contains the names of the sectors
    table_sectors_names_Exiobase = readtable(excel_file_Exiobase, 'Sheet', 'sectors_names', 'VariableNamingRule', 'preserve'); % setting 'VariableNamingRule' to 'preserve' prevents Matlab from renaming the variable names (it would erase blank spaces)
    Parameters.Sectors.nr = height(table_sectors_names_Exiobase);
    Parameters.Sectors.names = table_sectors_names_Exiobase{:,'SectorsNames'};
    Parameters.Sectors.names = string(Parameters.Sectors.names); % convert cell array to string array    


    % DIVISIONS' SECTORAL BELONGING (ID NUMBERS)
    % identification number of the sector to which each Division belongs, e.g. first sector, second sector, etc
    Parameters.Divisions.sector_idx = NaN * ones(1, Parameters.Divisions.nr);
    for i = 1 : Parameters.Divisions.nr
        Parameters.Divisions.sector_idx(i) = find(Parameters.Sectors.names == Parameters.Divisions.sector_id(i));
    end

    Parameters.Divisions.idx_fossil_fuels = find(contains(Parameters.Divisions.names, "Fossil fuels"))';
    Parameters.Divisions.idx_green = find(Parameters.Divisions.sector_id == "Green electricity")';
    Parameters.Divisions.idx_brown = find(Parameters.Divisions.sector_id == "Brown electricity")';
    if Rules.electricity_sector_aggregation == "one_electricity_sector"
        Parameters.Divisions.idx_electricity_producing = find(Parameters.Divisions.sector_id == "Electricity")';
    else
        Parameters.Divisions.idx_electricity_producing = sort([Parameters.Divisions.idx_green Parameters.Divisions.idx_brown]);    
    end

    % Divisions that are allowed to shrink
    if energy_transition_rule == "NT"
        Parameters.Divisions.idx_shrinking = [];
    elseif contains(energy_transition_rule, "partial")
        Parameters.Divisions.idx_shrinking = Parameters.Divisions.idx_brown;
    else
        Parameters.Divisions.idx_shrinking = [Parameters.Divisions.idx_fossil_fuels  Parameters.Divisions.idx_brown];
    end


    % SECTORS' INDEXES
    % For all sectors
    Parameters.Sectors.idx = 1 : Parameters.Sectors.nr;
    % Green and brown sectors
    Parameters.Sectors.idx_green = find(Parameters.Sectors.names == "Green electricity");
    Parameters.Sectors.idx_brown = find(Parameters.Sectors.names == "Brown electricity"); 
    % Electricity sector(s)
    if Rules.electricity_sector_aggregation == "one_electricity_sector"
        Parameters.Sectors.idx_electricity_producing = find(Parameters.Sectors.names == "Electricity");        
    else
        Parameters.Sectors.idx_electricity_producing = [Parameters.Sectors.idx_green Parameters.Sectors.idx_brown];        
        Parameters.Sectors.idx_electricity_producing = sort(Parameters.Sectors.idx_electricity_producing); % Sort the elements in ascending order
    end
    Parameters.Sectors.idx_electricity_producing_and_transmitting = find(contains(Parameters.Sectors.names, "electricity", 'IgnoreCase', true))';
    % Non-electricity producing sectors
    Parameters.Sectors.idx_non_electricity_producing = setdiff(1:Parameters.Sectors.nr, Parameters.Sectors.idx_electricity_producing);
    % Fossil fuels
    Parameters.Sectors.idx_fossil_fuels = find(contains(Parameters.Sectors.names, "Fossil fuels"));
   

    % SECTORS' SECTIONAL BELONGING (NAMES)
    if Rules.electricity_sector_aggregation == "one_electricity_sector"
        Parameters.Sectors.section_id = Parameters.Sectors.names;
    else
        Parameters.Sectors.section_id = Parameters.Sectors.names;
        Parameters.Sectors.section_id([Parameters.Sectors.idx_green Parameters.Sectors.idx_brown]) = "Electricity";
    end    
    

    % SECTIONS' NAMES AND NUMBER
    Parameters.Sections.names = unique(Parameters.Sectors.section_id, 'stable'); % unique(A) returns the same data as in A, but with no repetitions. 'stable' specifies that the order of the values should not be changed.
    Parameters.Sections.nr = length(Parameters.Sections.names);
    % Create an adjusted version of the Sections' names vector, where the names are to be interpreted as products (and not as industries).
        % This is useful when exporting data to txt files that will then be imported in the Latex paper to create tables.
    Parameters.Sections.names_adj_as_products = Parameters.Sections.names;
    Parameters.Sections.names_adj_as_products(Parameters.Sections.names_adj_as_products == "Metals mining") = "Mined metals";
    Parameters.Sections.names_adj_as_products(Parameters.Sections.names_adj_as_products == "Metals processing") = "Processed metals";
    Parameters.Sections.names_adj_as_products(Parameters.Sections.names_adj_as_products == "Fossil fuels extraction") = "Extracted fossil fuels";
    Parameters.Sections.names_adj_as_products(Parameters.Sections.names_adj_as_products == "Fossil fuels processing") = "Processed fossil fuels";
    Parameters.Sections.names_adj_as_products(Parameters.Sections.names_adj_as_products == "ICT") = "ICT equipment";
    Parameters.Sections.names_adj_as_products(Parameters.Sections.names_adj_as_products == "TraEq") = "Transport equipment";
    Parameters.Sections.names_adj_as_products(Parameters.Sections.names_adj_as_products == "OMach") = "Other machinery";
    Parameters.Sections.names_adj_as_products(Parameters.Sections.names_adj_as_products == "Construction") = "Constructions";
    Parameters.Sections.names_adj_as_products(Parameters.Sections.names_adj_as_products == "Manufacturing") = "Other manufacturing";
    Parameters.Sections.names_adj_as_products(Parameters.Sections.names_adj_as_products == "SoftDB") = "Software \& databases";
    Parameters.Sections.names_adj_as_products(Parameters.Sections.names_adj_as_products == "Transportation") = "Transport services";
    Parameters.Sections.names_adj_as_products(Parameters.Sections.names_adj_as_products == "Services") = "Other services";
    Parameters.Sections.names_adj_as_products(Parameters.Sections.names_adj_as_products == "Public") = "Public services";
    


    % SECTORS' SECTIONAL BELONGING (ID NUMBERS)
    % identification number of the section to which each sector belongs, e.g. first section, second section, etc
    Parameters.Sectors.section_idx = NaN * ones(1, Parameters.Sectors.nr);
    for i = 1 : Parameters.Sectors.nr
        Parameters.Sectors.section_idx(i) = find(Parameters.Sections.names == Parameters.Sectors.section_id(i));
    end

    
    % DIVISIONS' SECTIONAL BELONGING (ID NUMBERS)
    % identification number of the section to which each Division belongs, e.g. first section, second section, etc
    Parameters.Divisions.section_idx = NaN * ones(1, Parameters.Divisions.nr);
    for i = 1 : Parameters.Divisions.nr               
        Parameters.Divisions.section_idx(i) = Parameters.Sectors.section_idx(Parameters.Divisions.sector_idx(i));
    end
    

    % SECTIONS' INDEXES /1
    % Index of Electricity section
    Parameters.Sections.idx_electricity_producing = find(Parameters.Sections.names == "Electricity");
    % Index of Sections dealing with electricity (production and transmission)
    Parameters.Sections.idx_electricity_producing_and_transmitting = find(contains(Parameters.Sections.names, "electricity", 'IgnoreCase', true))';
    % Index of Sections not dealing with electricity
    Parameters.Sections.idx_non_electricity_producing_and_transmitting = setdiff(1:Parameters.Sections.nr, Parameters.Sections.idx_electricity_producing_and_transmitting); 
    % Index of Sections dealing with fossil fuels (extraction and processing)
    Parameters.Sections.idx_fossil_fuels = find(contains(Parameters.Sections.names, "Fossil fuels"))';
    % Index of Sections neither dealing with electricity nor with fossil-fuels
    Parameters.Sections.idx_not_electricity_not_fossil_fuels = setdiff(1:Parameters.Sections.nr, [Parameters.Sections.idx_electricity_producing_and_transmitting Parameters.Sections.idx_fossil_fuels]);
    % Index of the Section whose final demand from hhs and gov't gets set to zero
    Parameters.Sections.idx_demand_set_to_zero = Parameters.Sections.names == "Fossil fuels extraction";


    %% sectors & sections / capital


    % INVESTMENT THRESHOLD
    % if the production value driving desired investments goes above this threshold percentage of max production given available capital, a sector invests.                               
    if numel(Variations.investment_threshold) > 1
        Parameters.Divisions.investment_threshold_coefficient = ...
            Variations.investment_threshold(sim_counter) * ones(1, Parameters.Divisions.nr);
    else
        Parameters.Divisions.investment_threshold_coefficient = ...
            Variations.investment_threshold * ones(1, Parameters.Divisions.nr);
    end
    % Change the value for all green electricity-producing Divisions
    Parameters.Divisions.investment_threshold_coefficient(Parameters.Divisions.idx_green) = 0.8;


    % NORMAL CAPACITY UTILIZATION
    % This value is also used below to infer:
        % productivity
        % initial capital stocks levels
    Parameters.Divisions.normal_capacity_utilization = Parameters.Divisions.investment_threshold_coefficient;    
        


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%  CAPITAL PRODUCTIVITY  %%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % For all Divisions except the Electricity ones, we have computed productivity from the EuKlems dataset.
    % For the electricity-producing Divisions, we have computed productivity in a special way (see relevant Excel file).
    % In both cases, we assumed capacity utilization to be 1. 
    % Therefore, here we have to adjust the values we import for the assumed capacity utilization.

    % PERTURBATION
    % Define the perturbation of original capital productivity values
    if numel(Variations.capital_productivity_perturbation) > 1
        capital_productivity_perturbation = Variations.capital_productivity_perturbation(sim_counter);
    else
        capital_productivity_perturbation = Variations.capital_productivity_perturbation;
    end
        

    % Import the capital productivity table from the EuKlems excel sheet
    table_capital_productivity = readtable(excel_file_EuKlems, 'Sheet', 'productivity', 'VariableNamingRule', 'preserve'); % setting 'VariableNamingRule' to 'preserve' prevents Matlab from renaming the variable names (it would erase blank spaces)
    % Create empty capital productivity matrix
    initial_capital_productivity = NaN * ones(Parameters.Sections.nr, Parameters.Divisions.nr);
    
    % Filling the capital productivity matrix
    
    for i = 1 : Parameters.Divisions.nr
        
        % Index of the table column that corresponds to Division i
        idx_table_column = strcmp(table_capital_productivity.Properties.VariableNames, Parameters.Divisions.names(i));

        for j = 1 : Parameters.Sections.nr
            
            % Index of the row in the EuKlems capital productivity table that refers to section j
            idx_table_row = strcmp(table_capital_productivity.capital_good, Parameters.Sections.names(j));

            % Fill the capital productivity matrix
            initial_capital_productivity(j,i) = ...
                capital_productivity_perturbation .* ...
                (table_capital_productivity{idx_table_row, idx_table_column} ./ Parameters.Divisions.normal_capacity_utilization(i));
        end
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%   CAPITAL PRODUCTIVITY OF THE ELECTRICITY TRANSMISSION SECTOR   %%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Unfortunately, we could not compute capital productivities from EuKlems for the Electricity Transmission sector, because it's not featured in EuKlems.
    % However, we use the following workaround:    
    
    % To compute its productivities, we just need 3 things: physical output, physical capital stock, and capacity utilization.
    % However, we have nominal values, not physical ones, but that's not a problem to compute the productivity..
    % ..as long as prices are assumed to be equal across all goods!
    % Indeed, let's define:
        % gamma = capital productivity
        % q = physical output
        % Q = nominal output
        % k = physical capital stock
        % K = nominal capital stock
        % u = capacity utilization
        % p = price
    % Then, the productivity of the i-th capital asset of sector j is defined as: 
        % gamma_ij = q_j / (u_ij * k_ij)
    % as long as p_j and p_i are equal, we can multiply numerator and denominator to obtain:
        % gamma_ij = (q_j * p_j) / ((u_ij * k_ij) * p_i)
        %          = Q_j / (u_ij * K_ij)
    % Since we don't have data on capacity utilization u_ij, we'll simply assume some arbitrary value.

    % To compute the total nominal capital stock, we do as follows:
    % WACC * (Debt + Equity) = (capital income)      where WACC = Weighted Average Cost of Capital
    % In addition, since Assets = Liabilities:
    % (Debt + Equity) ≃ (Nominal capital stock)
    % ..because we can approximate Assets to be equal to the nominal capital stock.
    % Therefore, finally:
    % (Nominal capital stock) ≃ (capital income) / WACC
    % Note that capital income data have been computed from Exiobase (see relevant script), while WACC can be found in the internet or in published papers.

    % Then we decompose the total nominal capital stock into the specific nominal capital stocks related to each capital asset class.

    % Exiobase also provides us with the nominal output of the Electricity Transmission sector. 

    % Therefore, we have everything to compute the productivities.

    division_name = "Electricity transmission";

    % NOMINAL OUTPUT
    electricity_transmission_output_nominal = ...
        table_total_output_Exiobase.TotalOutput(table_total_output_Exiobase.SectorsNames == division_name);    


    % TOTAL NOMINAL CAPITAL STOCK
    % (Nominal capital stock) ≃ (capital income) / WACC
    % Assumed WACC
        % We use a reasonable value, taken from the sources:
        % Table 2 in Gelo et al (2019) "Allowed Revenue of Network System Operators in the Croatian Energy Sector and Interest Rate Changes on the Croatian Capital Market"
        % Table 1 in Bedoya-Cadavid et al (2023) "WACC for Electric Power Transmission System Operators: The Case of Colombia"
        % and for the US National Grid: https://valueinvesting.io/NG.L/valuation/wacc
    assumed_WACC = 0.06;
    % Capital income
    capital_income_table = readtable(excel_file_Exiobase, 'Sheet', 'capital_income', 'VariableNamingRule', 'preserve'); % setting 'VariableNamingRule' to 'preserve' prevents Matlab from renaming the variable names (it would erase blank spaces)
    % Total nominal capital stock
    electricity_transmission_total_capital_stock_nominal = ...
        capital_income_table{:, capital_income_table.Properties.VariableNames == division_name}...
        ./ assumed_WACC;


    % SPECIFIC NOMINAL CAPITAL STOCKS
    % We need to split the total nominal capital stock into the specific nominal capital stocks related to each capital asset class.
    % Which weights should we use? Well, let's use the weights computed from EuKlems for the EuKlems' Electricity sector.
    % Import the capital composition percentages table from the EuKlems excel sheet
    table_capital_composition_percentages = readtable(excel_file_EuKlems, 'Sheet', 'capital_composition_%', 'VariableNamingRule', 'preserve'); % setting 'VariableNamingRule' to 'preserve' prevents Matlab from renaming the variable names (it would erase blank spaces)    
    % Electricity transmission capital composition percentages
    electricity_transmission_capital_composition_percentages = NaN * ones(Parameters.Sections.nr, 1);
    for j = 1 : Parameters.Sections.nr            
        % Index of the row in the EuKlems capital composition table that refers to section j
        idx_table_row = strcmp(table_capital_composition_percentages.capital_good, Parameters.Sections.names(j));
        % Fill the capital productivity matrix
        electricity_transmission_capital_composition_percentages(j) = ...
            table_capital_composition_percentages.Electricity(idx_table_row);
    end
    % Test whether the sum of weights is very different from 100%:
    % it may not be exactly 100% though for some reason I can't remember, but we also don't want it to be too far from 100%
    if abs(1 - sum(electricity_transmission_capital_composition_percentages)) > 0.03
        error('The sum of composition percentages in the capital stock of the Electricity Transmission sector is quite far from 100%')
    end
    % Specific nominal capital stocks
    electricity_transmission_capital_stock_nominal = ...
        electricity_transmission_total_capital_stock_nominal .* electricity_transmission_capital_composition_percentages;


    % CAPITAL PRODUCTIVITY
    % = Q_j / (u_ij * K_ij)
    electricity_transmission_capital_productivity = ...
        electricity_transmission_output_nominal ./ (Parameters.Divisions.normal_capacity_utilization(Parameters.Divisions.names == division_name) .* electricity_transmission_capital_stock_nominal);
    % Replace Inf values with zeros
    electricity_transmission_capital_productivity(isinf(electricity_transmission_capital_productivity)) = 0;    

    % FILL IT IN THE CAPITAL PRODUCTIVITY MATRIX
    initial_capital_productivity(:, Parameters.Divisions.names == division_name) = ...
        electricity_transmission_capital_productivity;

    clear  division_name  electricity_transmission_output_nominal   assumed_WACC   capital_income_table... 
        electricity_transmission_total_capital_stock_nominal   electricity_transmission_capital_stock_nominal   electricity_transmission_capital_productivity

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%   END OF THE CAPITAL PRODUCTIVITY OF THE ELECTRICITY TRANSMISSION SECTOR   %%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    % TEST
    if any(initial_capital_productivity < 0, 'all')
        error('There is at least one negative value in ''initial_capital_productivity''')
    end


    % SAVE PRODUCTIVITY TABLE INTO AN EXCEL FILE
    % Now that we have the productivity values also for the Electricity transmission industry, it is useful to store the values in an excel file.
    % Create the table
    capital_productivity_table = ...
        array2table(initial_capital_productivity, 'VariableNames', Parameters.Divisions.names);
    % Add a column with the names of the Sections (i.e. commodities)
    capital_productivity_table = ...
        addvars(capital_productivity_table, Parameters.Sections.names, 'NewVariableNames', 'Commodities', 'Before', Parameters.Divisions.names(1));
    % Save into an Excel file
    writetable(capital_productivity_table, sprintf('capital_productivities_%d.xlsx', Parameters.calibration_year), 'Sheet', 'capital_productivities');
    clear capital_productivity_table


    %% sectors & sections / other capital-related parameters


    % DIVISIONS' CAPITAL PRODUCTIVITY GROWTH
    Parameters.Divisions.capital_productivity_growth = 0;
    

    % DEPRECIATION RATES

    % Define the perturbation of original depreciation rates values
    if numel(Variations.depreciation_rates_perturbation) > 1
        depreciation_rates_perturbation = Variations.depreciation_rates_perturbation(sim_counter);
    else
        depreciation_rates_perturbation = Variations.depreciation_rates_perturbation;
    end   

    % Import the depreciation rates table from the EuKlems excel sheet
    table_depreciation_rates = readtable(excel_file_EuKlems, 'Sheet', 'depreciation_rates', 'VariableNamingRule', 'preserve'); % setting 'VariableNamingRule' to 'preserve' prevents Matlab from renaming the variable names (it would erase blank spaces)
    % Create empty depreciation rates matrix
    Parameters.Divisions.depreciation_rates = NaN * ones(Parameters.Sections.nr, Parameters.Divisions.nr);
    
    % Filling the depreciation rates matrix
    
    for i = 1 : Parameters.Divisions.nr
        
        % Index of the table column that corresponds to Division i
        idx_table_column = strcmp(table_depreciation_rates.Properties.VariableNames, Parameters.Divisions.names(i));

        for j = 1 : Parameters.Sections.nr
            
            % Index of the row in the EuKlems depreciation rates table that refers to section j
            idx_table_row = strcmp(table_depreciation_rates.capital_good, Parameters.Sections.names(j));

            % Fill the depreciation rates matrix
            Parameters.Divisions.depreciation_rates(j,i) = ...
                depreciation_rates_perturbation .* table_depreciation_rates{idx_table_row, idx_table_column};
        end
    end

    % IF YOU WANT TO SET DEPRECIATION RATES TO BE ALL EQUAL TO EACH OTHER..
    %Parameters.Divisions.depreciation_rates(Parameters.Divisions.depreciation_rates ~= 0) = 0.1;

    % Test
    % Values should not be <0 nor >1
    if any(Parameters.Divisions.depreciation_rates < 0, 'all') || any(Parameters.Divisions.depreciation_rates > 1, 'all')
        error('There is at least one negative value or one value >1 in ''Parameters.Divisions.depreciation_rates''')
    end



    % DIVISIONS' CAPITAL ASSETS LOGICAL MATRIX
    % Build a logical matrix of dimension (nr sections)x(nr divisions) ..
    % ..containing 1 if the corresponding j-th Division has the corresponding i-th sectional commodity as capital assets..
    % ..and 0 otherwise.
    Parameters.Divisions.capital_assets_logical_matrix = ...
        initial_capital_productivity ~= 0;


    % SECTIONS' INDEXES /2
    % We now want to build an index of the sections that produce goods used (by any Division) as capital assets.
    % To do so, we will look at the depreciation matrix and, for each of its columns (Divisions),..
    % ..find the index of the Sections that supply capital assets to the considered Division.
    % Obviously, this index will contain repetitions; at the end, we will thus select only the unique values.    
    idx_capital_assets_repeated = [];
    for i = 1 : Parameters.Divisions.nr
        idx_capital_assets_repeated = [idx_capital_assets_repeated; find(Parameters.Divisions.capital_assets_logical_matrix(:,i) ~= 0)];
    end
    Parameters.Sections.idx_capital_assets = unique(idx_capital_assets_repeated, 'sorted')'; % it's important to have it sorted!
    Parameters.Sections.idx_not_capital_assets = setdiff(1:Parameters.Sections.nr, Parameters.Sections.idx_capital_assets);

    
         
    %% sectors & sections / behavioral parameters

    % LEVERAGE CEILING
    if numel(Variations.leverage_target) > 1
        Parameters.Sectors.leverage_target = Variations.leverage_target(sim_counter); 
    else
        Parameters.Sectors.leverage_target = Variations.leverage_target;
    end          


    % EXPECTED HOUSEHOLD DEMAND CORRECTION
    % Used when the Sections form naive expectations over hhs demand
    % i.e., instead of expecting simply Demand(t-1), they expect (1 + exp_hh_demand_correction) * Demand(t-1)
    % When exp_hh_demand_correction > 0, this helps preventing hhs demand rationing.        
    if numel(Variations.exp_hh_demand_correction) > 1
        Parameters.Sections.exp_hh_demand_correction = Variations.exp_hh_demand_correction(sim_counter); 
    else
        Parameters.Sections.exp_hh_demand_correction = Variations.exp_hh_demand_correction;
    end

    
    %% electricity sector: green share and weights

    % Load the MAT file containing:
        % the target green share
        % the electricity divisions' target weights
            % i.e. the target weights of each green technology within the green electricity sector, and of each brown technology within the brown electricity sector.
        % ..as given by the projections by the IEA for the 3 scenarios (STEPS, APS, NZE), for the years 2022-2050.        
    if energy_transition_rule == "NT"
        % We just load one of the 3 cases (STEPS, APS, NZE), it doesn't matter which one.
        load("electricity_weights_IEA_STEPS.mat")
    else
        load(sprintf("electricity_weights_IEA_%s.mat", erase(energy_transition_rule, " partial")))
    end
    % The loaded file contains the following structure:
    IEA_electricity_sectors;
            


    %%%%%%%%%%%%%%  TARGET GREEN SHARE  %%%%%%%%%%%%%%

    % = green share that the green electricity sector uses when computing its desired production that drives its desired investments.
    % Its value differs depending on which energy transition scenario we are looking at.
        % "NT" --> its value remains constant across the entire simulation.
        % all other scenarios -->
            % its value remains constant until the energy transition process starts;
            % during the energy transition, its value increases as given by the IEA projections.
            % after the end of the energy transition, its value remains constant until the end of the simulation. 
    
    % Indexes
    idx_initial_year = find(IEA_electricity_sectors.green_share_table.years == Parameters.year_of_simulations_kickoff);    
    idx_year_2022 = find(IEA_electricity_sectors.green_share_table.years == 2022);
    
    % Create the array
    Parameters.Sectors.target_green_share = NaN .* ones(Parameters.T, 1);
    % Assign values..
    if energy_transition_rule == "NT"        
        % ..in the model's stabilization period
        Parameters.Sectors.target_green_share(1 : (Parameters.simulations_kickoff_after_stabilization - 1)) = ...
            IEA_electricity_sectors.green_share_table.green_share(idx_initial_year);
        % ..in the period from the start of the proper simulation until 2022
        Parameters.Sectors.target_green_share(Parameters.simulations_kickoff_after_stabilization : Parameters.time_step_corresponding_to_2022) = ...
            IEA_electricity_sectors.green_share_table.green_share(idx_initial_year : idx_year_2022);
        % ..in the period from 2023 until the end of the simulation
        Parameters.Sectors.target_green_share((Parameters.time_step_corresponding_to_2022 + 1) : end) = ...
            IEA_electricity_sectors.green_share_table.green_share(idx_year_2022);       
    else        
        % ..in the model's stabilization period
        Parameters.Sectors.target_green_share(1 : (Parameters.simulations_kickoff_after_stabilization - 1)) = ...
            IEA_electricity_sectors.green_share_table.green_share(idx_initial_year);
        % ..in the period from the start of the proper simulation until the end of the energy transition
        Parameters.Sectors.target_green_share(Parameters.simulations_kickoff_after_stabilization : Parameters.end_of_energy_transition) = ...
            IEA_electricity_sectors.green_share_table.green_share(idx_initial_year : end);
        % ..in the period from the end of the energy transition until the end of the simulation
        Parameters.Sectors.target_green_share((Parameters.end_of_energy_transition + 1) : end) = ...
            IEA_electricity_sectors.green_share_table.green_share(end);
    end
    clear idx_initial_year  idx_year_2022


    %%%%%%%%%%%%%%  TARGET SECTORAL WEIGHTS  %%%%%%%%%%%%%%

    % = the electricity Divisions' target weights within their Sector of belonging
    % i.e. the target weights of each green technology within the green electricity sector, and of each brown technology within the brown electricity sector. 

    % Indexes
    idx_initial_year = find(IEA_electricity_sectors.weights_table.years == Parameters.year_of_simulations_kickoff);    
    idx_year_2022 = find(IEA_electricity_sectors.weights_table.years == 2022);

    % Create the array
    Parameters.Divisions.target_sectoral_weights = NaN .* ones(Parameters.T, Parameters.Divisions.nr);
    % Assign values..
    for i = 1 : Parameters.Divisions.nr
        if Parameters.Divisions.sector_id(i) == "Green electricity" || Parameters.Divisions.sector_id(i) == "Brown electricity"    

            % Index of the table column that corresponds to Division i
            idx_table_column = strcmp(IEA_electricity_sectors.weights_table.Properties.VariableNames, Parameters.Divisions.names(i));
            
            if energy_transition_rule == "NT"
                % ..in the model's stabilization period
                Parameters.Divisions.target_sectoral_weights(1 : (Parameters.simulations_kickoff_after_stabilization - 1), i) = ...
                    IEA_electricity_sectors.weights_table{idx_initial_year, idx_table_column};
                % ..in the period from the start of the proper simulation until 2022
                Parameters.Divisions.target_sectoral_weights(Parameters.simulations_kickoff_after_stabilization : Parameters.time_step_corresponding_to_2022, i) = ...
                    IEA_electricity_sectors.weights_table{idx_initial_year : idx_year_2022, idx_table_column};
                % ..in the period from 2023 until the end of the simulation
                Parameters.Divisions.target_sectoral_weights((Parameters.time_step_corresponding_to_2022 + 1) : end, i) = ...
                    IEA_electricity_sectors.weights_table{idx_year_2022, idx_table_column};
            else
                % ..in the model's stabilization period
                Parameters.Divisions.target_sectoral_weights(1 : (Parameters.simulations_kickoff_after_stabilization - 1), i) = ...
                    IEA_electricity_sectors.weights_table{idx_initial_year, idx_table_column};
                % ..in the period from the start of the proper simulation until the end of the energy transition
                Parameters.Divisions.target_sectoral_weights(Parameters.simulations_kickoff_after_stabilization : Parameters.end_of_energy_transition, i) = ...
                    IEA_electricity_sectors.weights_table{idx_initial_year : end, idx_table_column};
                % ..in the period from the end of the energy transition until the end of the simulation
                Parameters.Divisions.target_sectoral_weights((Parameters.end_of_energy_transition + 1) : end, i) = ...
                    IEA_electricity_sectors.weights_table{end, idx_table_column};                              
            end
        else
            Parameters.Divisions.target_sectoral_weights(:,i) = 1;
        end
    end
    clear idx_initial_year  idx_year_2022
    % TEST
    % Weights should not be <0 nor >1
    if any(Parameters.Divisions.target_sectoral_weights < 0, 'all') || any(Parameters.Divisions.target_sectoral_weights > 1, 'all')
        error('There is at least one negative value or one value >1 in ''Parameters.Divisions.target_sectoral_weights''')
    end
    % Weights must sum to 1.
    aggregating_weights_test = NaN * ones(Parameters.T, Parameters.Sectors.nr);
    for i = 1 : Parameters.Sectors.nr
        idx_divisions_belonging_to_sector_i = find(Parameters.Divisions.sector_idx == i);
        aggregating_weights_test(:,i) = ...
            sum(Parameters.Divisions.target_sectoral_weights(:, idx_divisions_belonging_to_sector_i), 2);
    end
    if any(abs(1 - aggregating_weights_test) > Parameters.error_tolerance_strong, 'all')
        error('The sum across sectoral weights in the electricity Divisions does not equal 1 in some year')
    end


    %%%%%%%%%%%%%%  TARGET SECTIONAL WEIGHTS  %%%%%%%%%%%%%%

    % = the electricity Divisions' target weights within their Section of belonging
    % i.e. the target weights of each electricity Division within the aggregate electricity Section.
    
    % Create the array
    Parameters.Divisions.target_sectional_weights = NaN .* ones(Parameters.T, Parameters.Divisions.nr);
    % Assign values
    for i = 1 : Parameters.Divisions.nr
        if Parameters.Divisions.sector_id(i) == "Green electricity"
            Parameters.Divisions.target_sectional_weights(:,i) = ...
                Parameters.Sectors.target_green_share .* Parameters.Divisions.target_sectoral_weights(:,i);
        elseif Parameters.Divisions.sector_id(i) == "Brown electricity"
            Parameters.Divisions.target_sectional_weights(:,i) = ...
                (1 - Parameters.Sectors.target_green_share) .* Parameters.Divisions.target_sectoral_weights(:,i);
        else
            Parameters.Divisions.target_sectional_weights(:,i) = 1;
        end
    end
    % TEST
    % Weights should not be <0 nor >1
    if any(Parameters.Divisions.target_sectional_weights < 0, 'all') || any(Parameters.Divisions.target_sectional_weights > 1, 'all')
        error('There is at least one negative value or one value >1 in ''Parameters.Divisions.target_sectional_weights''')
    end
    % Weights must sum to 1.
    aggregating_weights_test = NaN * ones(Parameters.T, Parameters.Sections.nr);
    for i = 1 : Parameters.Sections.nr
        idx_divisions_belonging_to_section_i = find(Parameters.Divisions.section_idx == i);
        aggregating_weights_test(:,i) = ...
            sum(Parameters.Divisions.target_sectional_weights(:, idx_divisions_belonging_to_section_i), 2);
    end
    if any(abs(1 - aggregating_weights_test) > Parameters.error_tolerance_strong, 'all')
        error('The sum across sectional weights in the electricity Divisions does not equal 1 in some year')
    end


    %% divisions: electrification, fossilization, carbonization

    % TFC = Total Final Consumption of energy

    % Now we deal with 4 type of parameters that describe the electrification and de-fossilization processes:
        % (1) Parameters.Divisions.electrification
            % captures the percentage of TFC (for each Division) that is supplied by electricity
        % (2) Parameters.Divisions.fossilization
            % captures the percentage of TFC (for each Division) that is supplied by fossil-fuels
            % Note that: (Parameters.Divisions.electrification + Parameters.Divisions.fossilization) ~= 1
            % ..because some TFC is supplied by alternative sources such as bioenergy.
        % (3) Parameters.Divisions.carbonization
            % captures the percentage of TFC (for each Division) that is supplied by GHG-emitting fossil-fuels.
            % Indeed, not all fossil-fuels within the TFC are used for energy purposes. 
            % E.g. some oil is used as chemical feedstock to produce plastic, asphalt, and since it's not burned it does not lead to GHG emissions.
            % This parameter will thus allow us to calibrate the decline in emission intensities associated with the de-fossilization process.
        % (4) Parameters.Divisions.TFC_change_to_electrification
            % percentage TFC reduction arising from a 1 percentage point increase in electrification (for each Division)
            % Indeed, substituting fossil-fuels with electricity leads to some TFC reduction because electricity is generally more efficient.


    % Load the MAT file containing the above 4 type of parameters..
        % ..as given by the projections by the IEA for the 3 scenarios (STEPS, APS, NZE), for the years 2022-2050            
    if energy_transition_rule == "NT"
        % We just load one of the 3 scenarios (STEPS, APS, NZE), it doesn't matter which one.
        load("electrification_IEA_STEPS.mat")
    else
        load(sprintf("electrification_IEA_%s.mat", erase(energy_transition_rule, " partial")))
    end
    % The loaded MAT file contains the following structure:
    IEA_energy_transition;

    % The above MAT file contains the above mentioned 4 type of parameters (electrification, fossilization, carbonization, TFC reduction)..
    % ..for the scenario we are currently analysing (STEPS, APS, or NZE),
    % ..for the years 2022 and 2050 (except for TFC reduction, which is a constant),
    % ..for IEA's 4 categories: (1) energy-intensive industries; (2) non-energy-intensive industries; (3) transport; (4) buildings (i.e. services sectors).
    % So, now we have to assign the 4 types of parameters to each of Triode's Divisions, which may belong to one of the IEA's 4 categories..
        % e.g. the Division "Metals processing" belongs to category (1), while the Division "Fossil fuels extraction" doesn't belong to any of IEA's categories.
    % In addition, for the parameters "electrification", "fossilization", and "carbonization", we only have the initial (2022) and final (2050) values..
    % ..thus, we need to do a linear interpolation between those values to find the value for each year between 2022 and 2050.
    
    if energy_transition_rule == "NT" || contains(energy_transition_rule, "partial")

        % We assign a value of 1 to electrification and fossilization, and a value of 0 to TFC reduction, 
        % ..since in this way they will have no impact on the simulation, meaning that no electrification and de-fossilization process is taking place, as implied by the NT scenario.
        Parameters.Divisions.electrification = ones(Parameters.T, Parameters.Divisions.nr);
        Parameters.Divisions.fossilization = ones(Parameters.T, Parameters.Divisions.nr);
        Parameters.Divisions.carbonization = ones(Parameters.T, Parameters.Divisions.nr);
        Parameters.Divisions.TFC_change_to_electrification = zeros(1, Parameters.Divisions.nr);
            
    else

        % Create the empty arrays
        Parameters.Divisions.electrification = NaN * ones(Parameters.T, Parameters.Divisions.nr);
        Parameters.Divisions.fossilization = NaN * ones(Parameters.T, Parameters.Divisions.nr);
        Parameters.Divisions.carbonization = NaN * ones(Parameters.T, Parameters.Divisions.nr);
        Parameters.Divisions.TFC_change_to_electrification = NaN * ones(1, Parameters.Divisions.nr);

        % Assign values to the arrays
        for i = 1 : Parameters.Divisions.nr


            %%%%%%%%   ENERGY INTENSIVE DIVISIONS  %%%%%%%%
            if ismember(Parameters.Divisions.names(i), Parameters.Divisions.IEAcategory.names.energy_intensive)

                % Percentage Total Final Consumption of energy (TFC) reduction arising from a 1 percentage point increase in electrification
                Parameters.Divisions.TFC_change_to_electrification(i) = IEA_energy_transition.TFC_change_to_electrification_industry;
                
                % Assign values in the period before 2022
                % Electrification
                Parameters.Divisions.electrification(1 : (Parameters.time_step_corresponding_to_2022 - 1), i) = ...
                    IEA_energy_transition.electrification_energy_intensive_industries_2022;
                % Fossilization
                Parameters.Divisions.fossilization(1 : (Parameters.time_step_corresponding_to_2022 - 1), i) = ...
                    IEA_energy_transition.fossilization_energy_intensive_industries_2022;
                % Carbonization
                Parameters.Divisions.carbonization(1 : (Parameters.time_step_corresponding_to_2022 - 1), i) = ...
                    IEA_energy_transition.carbonization_energy_intensive_industries_2022;
                
                % Assign values in the period interval from 2022 until the end of the energy transition
                % Electrification
                Parameters.Divisions.electrification(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition, i) = ...
                    linspace(IEA_energy_transition.electrification_energy_intensive_industries_2022, IEA_energy_transition.electrification_energy_intensive_industries_2050, numel(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition));
                % Fossilization
                Parameters.Divisions.fossilization(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition, i) = ...
                    linspace(IEA_energy_transition.fossilization_energy_intensive_industries_2022, IEA_energy_transition.fossilization_energy_intensive_industries_2050, numel(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition));
                % Carbonization
                Parameters.Divisions.carbonization(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition, i) = ...
                    linspace(IEA_energy_transition.carbonization_energy_intensive_industries_2022, IEA_energy_transition.carbonization_energy_intensive_industries_2050, numel(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition));

                % Assign values in the period from the end of the energy transition until the end of the simulation
                % Electrification
                Parameters.Divisions.electrification((Parameters.end_of_energy_transition + 1) : end, i) = ...
                    IEA_energy_transition.electrification_energy_intensive_industries_2050;
                % Fossilization
                Parameters.Divisions.fossilization((Parameters.end_of_energy_transition + 1) : end, i) = ...
                    IEA_energy_transition.fossilization_energy_intensive_industries_2050;
                % Carbonization
                Parameters.Divisions.carbonization((Parameters.end_of_energy_transition + 1) : end, i) = ...
                    IEA_energy_transition.carbonization_energy_intensive_industries_2050;


            %%%%%%%%   NON-ENERGY INTENSIVE DIVISIONS  %%%%%%%%
            elseif ismember(Parameters.Divisions.names(i), Parameters.Divisions.IEAcategory.names.non_energy_intensive)

                % Percentage Total Final Consumption of energy (TFC) reduction arising from a 1 percentage point increase in electrification
                Parameters.Divisions.TFC_change_to_electrification(i) = IEA_energy_transition.TFC_change_to_electrification_industry;
                
                % Assign values in the period before 2022
                % Electrification
                Parameters.Divisions.electrification(1 : (Parameters.time_step_corresponding_to_2022 - 1), i) = ...
                    IEA_energy_transition.electrification_other_industries_2022;
                % Fossilization
                Parameters.Divisions.fossilization(1 : (Parameters.time_step_corresponding_to_2022 - 1), i) = ...
                    IEA_energy_transition.fossilization_other_industries_2022;
                % Carbonization
                Parameters.Divisions.carbonization(1 : (Parameters.time_step_corresponding_to_2022 - 1), i) = ...
                    IEA_energy_transition.carbonization_other_industries_2022;
                
                % Assign values in the period interval from 2022 until the end of the energy transition
                % Electrification
                Parameters.Divisions.electrification(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition, i) = ...
                    linspace(IEA_energy_transition.electrification_other_industries_2022, IEA_energy_transition.electrification_other_industries_2050, numel(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition));
                % Fossilization
                Parameters.Divisions.fossilization(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition, i) = ...
                    linspace(IEA_energy_transition.fossilization_other_industries_2022, IEA_energy_transition.fossilization_other_industries_2050, numel(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition));
                % Carbonization
                Parameters.Divisions.carbonization(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition, i) = ...
                    linspace(IEA_energy_transition.carbonization_other_industries_2022, IEA_energy_transition.carbonization_other_industries_2050, numel(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition));

                % Assign values in the period from the end of the energy transition until the end of the simulation
                % Electrification
                Parameters.Divisions.electrification((Parameters.end_of_energy_transition + 1) : end, i) = ...
                    IEA_energy_transition.electrification_other_industries_2050;
                % Fossilization
                Parameters.Divisions.fossilization((Parameters.end_of_energy_transition + 1) : end, i) = ...
                    IEA_energy_transition.fossilization_other_industries_2050;
                % Carbonization
                Parameters.Divisions.carbonization((Parameters.end_of_energy_transition + 1) : end, i) = ...
                    IEA_energy_transition.carbonization_other_industries_2050;


            %%%%%%%%   TRANSPORTATION DIVISION  %%%%%%%%
            elseif ismember(Parameters.Divisions.names(i), Parameters.Divisions.IEAcategory.names.transport)

                % Percentage Total Final Consumption of energy (TFC) reduction arising from a 1 percentage point increase in electrification
                Parameters.Divisions.TFC_change_to_electrification(i) = IEA_energy_transition.TFC_change_to_electrification_transport;
                
                % Assign values in the period before 2022
                % Electrification
                Parameters.Divisions.electrification(1 : (Parameters.time_step_corresponding_to_2022 - 1), i) = ...
                    IEA_energy_transition.electrification_transport_2022;
                % Fossilization
                Parameters.Divisions.fossilization(1 : (Parameters.time_step_corresponding_to_2022 - 1), i) = ...
                    IEA_energy_transition.fossilization_transport_2022;
                % Carbonization
                Parameters.Divisions.carbonization(1 : (Parameters.time_step_corresponding_to_2022 - 1), i) = ...
                    IEA_energy_transition.carbonization_transport_2022;
                
                % Assign values in the period interval from 2022 until the end of the energy transition
                % Electrification
                Parameters.Divisions.electrification(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition, i) = ...
                    linspace(IEA_energy_transition.electrification_transport_2022, IEA_energy_transition.electrification_transport_2050, numel(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition));
                % Fossilization
                Parameters.Divisions.fossilization(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition, i) = ...
                    linspace(IEA_energy_transition.fossilization_transport_2022, IEA_energy_transition.fossilization_transport_2050, numel(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition));
                % Carbonization
                Parameters.Divisions.carbonization(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition, i) = ...
                    linspace(IEA_energy_transition.carbonization_transport_2022, IEA_energy_transition.carbonization_transport_2050, numel(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition));

                % Assign values in the period from the end of the energy transition until the end of the simulation
                % Electrification
                Parameters.Divisions.electrification((Parameters.end_of_energy_transition + 1) : end, i) = ...
                    IEA_energy_transition.electrification_transport_2050;
                % Fossilization
                Parameters.Divisions.fossilization((Parameters.end_of_energy_transition + 1) : end, i) = ...
                    IEA_energy_transition.fossilization_transport_2050;
                % Carbonization
                Parameters.Divisions.carbonization((Parameters.end_of_energy_transition + 1) : end, i) = ...
                    IEA_energy_transition.carbonization_transport_2050;


            %%%%%%%%   SERVICES DIVISIONS  %%%%%%%%
            elseif ismember(Parameters.Divisions.names(i), Parameters.Divisions.IEAcategory.names.services_buildings)

                % Percentage Total Final Consumption of energy (TFC) reduction arising from a 1 percentage point increase in electrification
                Parameters.Divisions.TFC_change_to_electrification(i) = IEA_energy_transition.TFC_change_to_electrification_buildings;
                
                % Assign values in the period before 2022
                % Electrification
                Parameters.Divisions.electrification(1 : (Parameters.time_step_corresponding_to_2022 - 1), i) = ...
                    IEA_energy_transition.electrification_buildings_2022;
                % Fossilization
                Parameters.Divisions.fossilization(1 : (Parameters.time_step_corresponding_to_2022 - 1), i) = ...
                    IEA_energy_transition.fossilization_buildings_2022;
                % Carbonization
                Parameters.Divisions.carbonization(1 : (Parameters.time_step_corresponding_to_2022 - 1), i) = ...
                    IEA_energy_transition.carbonization_buildings_2022;
                
                % Assign values in the period interval from 2022 until the end of the energy transition
                % Electrification
                Parameters.Divisions.electrification(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition, i) = ...
                    linspace(IEA_energy_transition.electrification_buildings_2022, IEA_energy_transition.electrification_buildings_2050, numel(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition));
                % Fossilization
                Parameters.Divisions.fossilization(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition, i) = ...
                    linspace(IEA_energy_transition.fossilization_buildings_2022, IEA_energy_transition.fossilization_buildings_2050, numel(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition));
                % Carbonization
                Parameters.Divisions.carbonization(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition, i) = ...
                    linspace(IEA_energy_transition.carbonization_buildings_2022, IEA_energy_transition.carbonization_buildings_2050, numel(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition));

                % Assign values in the period from the end of the energy transition until the end of the simulation
                % Electrification
                Parameters.Divisions.electrification((Parameters.end_of_energy_transition + 1) : end, i) = ...
                    IEA_energy_transition.electrification_buildings_2050;
                % Fossilization
                Parameters.Divisions.fossilization((Parameters.end_of_energy_transition + 1) : end, i) = ...
                    IEA_energy_transition.fossilization_buildings_2050;
                % Carbonization
                Parameters.Divisions.carbonization((Parameters.end_of_energy_transition + 1) : end, i) = ...
                    IEA_energy_transition.carbonization_buildings_2050;


            %%%%%%%%  DIVISIONS NOT UNDERGOING ELECTRIFICATION/DE-FOSSILIZATION PROCESSES  %%%%%%%%
            elseif ismember(Parameters.Divisions.names(i), Parameters.Divisions.IEAcategory.names.no_energy_transition)
                
                % We assign a value of 1 to electrification, fossilization and carbonization, and a value of 0 to TFC reduction, 
                % ..since in this way they will have no impact on the selected Divisions, meaning that no electrification/de-fossilization/de-carbonization process is taking place in those Divisions.
                Parameters.Divisions.electrification(:,i) = 1;
                Parameters.Divisions.fossilization(:,i) = 1;
                Parameters.Divisions.TFC_change_to_electrification(:,i) = 0;

                % CARBONIZATION
                % The Divisions "Electricity coal" and "Electricity gas" experience some de-carbonization thanks to CCUS technology
                % Note that we assume that if CCUS is installed, it captures 100% of GHG, which is a reasonable assumption
                    % ..see also here: https://www.lse.ac.uk/granthaminstitute/explainers/what-is-carbon-capture-and-storage-and-what-role-can-it-play-in-tackling-climate-change/
                    % "Currently operational facilities fitted with CCUS can capture around 90%﻿ of the CO2 present in flue gas"
                if Parameters.Divisions.names(i) == "Electricity coal"
                    % Assign values in the period before 2022
                    Parameters.Divisions.carbonization(1 : (Parameters.time_step_corresponding_to_2022 - 1), i) = ...
                        IEA_energy_transition.carbonization_electricity_coal_2022;
                    % Assign values in the period interval from 2022 until the end of the energy transition
                    Parameters.Divisions.carbonization(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition, i) = ...
                        linspace(IEA_energy_transition.carbonization_electricity_coal_2022, IEA_energy_transition.carbonization_electricity_coal_2050, numel(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition));
                    % Assign values in the period from the end of the energy transition until the end of the simulation
                    Parameters.Divisions.carbonization((Parameters.end_of_energy_transition + 1) : end, i) = ...
                        IEA_energy_transition.carbonization_electricity_coal_2050;
                elseif Parameters.Divisions.names(i) == "Electricity gas"
                    % Assign values in the period before 2022
                    Parameters.Divisions.carbonization(1 : (Parameters.time_step_corresponding_to_2022 - 1), i) = ...
                        IEA_energy_transition.carbonization_electricity_gas_2022;
                    % Assign values in the period interval from 2022 until the end of the energy transition
                    Parameters.Divisions.carbonization(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition, i) = ...
                        linspace(IEA_energy_transition.carbonization_electricity_gas_2022, IEA_energy_transition.carbonization_electricity_gas_2050, numel(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition));
                    % Assign values in the period from the end of the energy transition until the end of the simulation
                    Parameters.Divisions.carbonization((Parameters.end_of_energy_transition + 1) : end, i) = ...
                        IEA_energy_transition.carbonization_electricity_gas_2050;
                else
                    Parameters.Divisions.carbonization(:,i) = 1;
                end

            end            
        end
    end  


    %% bank

    % Basel-type capital requirement    
    if numel(Variations.bank_capital_requirement) > 1
        Parameters.Bank.capital_requirement = Variations.bank_capital_requirement(sim_counter);
    else
        Parameters.Bank.capital_requirement = Variations.bank_capital_requirement;
    end

    % Target CAR
    if numel(Variations.bank_CAR_target_delta) > 1
        Parameters.Bank.CAR_target = Parameters.Bank.capital_requirement + Variations.bank_CAR_target_delta(sim_counter);
    else
        Parameters.Bank.CAR_target = Parameters.Bank.capital_requirement + Variations.bank_CAR_target_delta;
    end    

    % Dividend payout ratio
    Parameters.Bank.dividend_payout_ratio = 1;
    
    
    %% households

    % Total number of households
    Parameters.Households.nr = 1; 

    % Marginal propensity to consume out of income
    if numel(Variations.delta_MPC_income) > 1
        Parameters.Households.MPC_income = 0.9 + Variations.delta_MPC_income(sim_counter); 
    else
        Parameters.Households.MPC_income = 0.9 + Variations.delta_MPC_income;
    end

    % Marginal propensity to consume out of wealth
    Parameters.Households.MPC_wealth = 0.1; 

    % TIME SPAN OVER WHICH TO COMPUTE THE AVERAGE INCOME OR WEALTH IN THE HH CONSUMPTION BUDGET
    if numel(Variations.hhs_consumption_budget_time_span_avg) > 1
        Parameters.Households.cons_budget_time_span_avg = Variations.hhs_consumption_budget_time_span_avg(sim_counter); 
    else
        Parameters.Households.cons_budget_time_span_avg = Variations.hhs_consumption_budget_time_span_avg;
    end

    % NOTE
    % we define "Parameters.Households.exiobase_demand_relations_phys" below, because we need initial prices to do so.



    % EMISSIONS RELATED TO HHS' CONSUMPTION
        
    % Let's import the table (derived from Exiobase) containing the total GHG emissions (in Kg) arising from final demands
    table_GHG_final_demand_Exiobase = readtable(excel_file_Exiobase, 'Sheet', 'total_emissions_final_demands', 'VariableNamingRule', 'preserve'); % setting 'VariableNamingRule' to 'preserve' prevents Matlab from renaming the variable names (it would erase blank spaces)

    % Total GHG emissions (in Kg) arising from households' consumption in Exiobase
    Parameters.Households.emissions_Exiobase = table_GHG_final_demand_Exiobase{:, 'FinalConsumptionExpenditureByHouseholds'};

    % CONVERT KG TO GIGATONNES
    % 1 Gt = 10^9 t = 10^9 * 10^3 kg = 10^12 kg  --> 1 kg = 1/(10^(12)) Gt
    how_many_Kg_in_one_Gt = 1e12;
    how_many_t_in_one_Gt = 1e9; % will be useful for other things
    Parameters.Households.emissions_Exiobase = Parameters.Households.emissions_Exiobase / how_many_Kg_in_one_Gt;
            

    %% government

    % GOV'T DEMAND EXOGENOUS GROWTH RATE
    % This applies only if the "Variations.govt_demand_rule" = "yes - growing constantly"
    if numel(Variations.govt_demand_exogenous_growth_rate) > 1
        Parameters.Government.demand_exogenous_growth_rate = Variations.govt_demand_exogenous_growth_rate(sim_counter); 
    else
        Parameters.Government.demand_exogenous_growth_rate = Variations.govt_demand_exogenous_growth_rate;
    end


    %%%%%%%%%%%%  PARAMETERS ON WHICH TAX RATE ADJUSTMENT IS BASED  %%%%%%%%%%%%
    % Tax rate adjustments are performed by targeting either the debt-to-GDP ratio, or the deficit-to-GDP ratio, depending on the adopted rule.
    % Now we define the floor and ceiling values for each measure.

    % FLOOR VALUE FOR THE DEBT-TO-GDP RATIO
    Parameters.Government.debt_to_GDP_floor = 0.2; 

    % CEILING VALUE FOR THE DEBT-TO-GDP RATIO
    % What value should we set as a ceiling?
    % Look at global public debt-to-GDP ratio trends in the chart in the following article
    % https://www.imf.org/en/Blogs/Articles/2023/09/13/global-debt-is-returning-to-its-rising-trend
    % We could use a reasonable value of 80%
    Parameters.Government.debt_to_GDP_ceiling = 0.8;

    % FLOOR VALUE FOR THE DEFICIT-TO-GDP RATIO
    Parameters.Government.deficit_to_GDP_floor = 0;

    % CEILING VALUE FOR THE DEFICIT-TO-GDP RATIO
    Parameters.Government.deficit_to_GDP_ceiling = 0.03;

    % TAX RATE STEPS
    % Value by which the gov't increases/decreases the tax rate
    Parameters.Government.tax_rate_steps = 0.01;




    % NOTE
    % we define "Parameters.Government.exiobase_demand_relations_phys" below, because we need initial prices to do so.


    % EMISSIONS RELATED TO GOV'T CONSUMPTION           
    % Total GHG emissions (in Kg) arising from gov't consumption in Exiobase
    Parameters.Government.emissions_Exiobase = table_GHG_final_demand_Exiobase{:, 'FinalConsumptionExpenditureByGovernment'};
    % Convert Kg to Gigatonnes    
    Parameters.Government.emissions_Exiobase = Parameters.Government.emissions_Exiobase / how_many_Kg_in_one_Gt;
    

%% DEFINITION OF ARRAYS
    %% households
    
    Households.income = NaN * ones(Parameters.T, Parameters.Households.nr);
    Households.deposits = NaN * ones(Parameters.T, Parameters.Households.nr);
    Households.final_demand_budget = NaN * ones(Parameters.T, Parameters.Households.nr);
    Households.consumption_expenditures = NaN * ones(Parameters.T, Parameters.Households.nr); % vector showing each household's total realized nominal consumption
    Households.consumption_basket_units_demanded = NaN * ones(Parameters.T, Parameters.Households.nr);
    Households.net_worth = NaN * ones(Parameters.T, Parameters.Households.nr);
    
    Households.demand_relations_phys_adj_for_price_changes = NaN * ones(Parameters.Sections.nr, Parameters.T);
    Households.phys_demand_relations = NaN * ones(Parameters.Sections.nr, Parameters.T);
    Households.lambda_AIDS_autonomous_coefficients = NaN * ones(Parameters.Sections.nr, Parameters.T);
    Households.demand_relations_phys_percentage_change = NaN * ones(Parameters.Sections.nr, Parameters.T);
        
    Households.emissions_flow = NaN * ones(Parameters.T, Parameters.Households.nr);        

    
    %% sections
    
    % FINAL DEMANDS AND SALES
    % .. are formulated at the sectional level, since hhs, investing sectors, and gov't don't distinguish..
    % .. between sectors belonging to the same section (e.g. green and brown electricity).
    
    % From/to households
    Sections.demand_from_hhs_nominal = NaN * ones(Parameters.Sections.nr, Parameters.Households.nr, Parameters.T);
    Sections.demand_from_hhs_phys = NaN * ones(Parameters.Sections.nr, Parameters.Households.nr, Parameters.T);
    Sections.demand_from_hhs_phys_growth_rate = NaN * ones(Parameters.Sections.nr, Parameters.T);
    Sections.sales_to_hhs_nominal = NaN * ones(Parameters.Sections.nr, Parameters.Households.nr, Parameters.T);
    Sections.sales_to_hhs_phys = NaN * ones(Parameters.Sections.nr, Parameters.Households.nr, Parameters.T);
    % From investing Divisions      
    Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys = NaN * ones(Parameters.Sections.nr, Parameters.Divisions.nr, Parameters.T);
    Sections.demand_in1year_from_invest_divisions_adj_after_loans_aggr_nomin = NaN * ones(Parameters.Sections.nr, Parameters.T);
    Sections.current_orders_from_investing_divisions_adj_for_rationing_phys = NaN * ones(Parameters.Sections.nr, Parameters.Divisions.nr, Parameters.T);
    Sections.sales_to_investing_divisions_nomin = NaN * ones(Parameters.Sections.nr, Parameters.Divisions.nr, Parameters.T);
    % From/to government
    Sections.current_demand_from_govt_nominal = NaN * ones(Parameters.Sections.nr, Parameters.T);
    Sections.demand_in1year_from_govt_phys = NaN * ones(Parameters.Sections.nr, Parameters.T);    
    Sections.sales_to_govt_phys = NaN * ones(Parameters.Sections.nr, Parameters.T);
    % Total
    Sections.final_demand_phys =  NaN * ones(Parameters.Sections.nr, Parameters.T);
    % Total expected
    Sections.final_demand_phys_exp = NaN * ones(Parameters.Sections.nr, Parameters.T);


    % PRODUCTS AVAILABLE FOR SALE TO FINAL DEMAND
    Sections.products_available_for_final_demand_phys = NaN * ones(Parameters.Sections.nr, Parameters.T);

    % SALES TO FINAL DEMAND
    Sections.sales_to_final_demand_phys = NaN * ones(Parameters.Sections.nr, Parameters.T);
    Sections.sales_to_final_demand_nominal = NaN * ones(Parameters.Sections.nr, Parameters.T);

    % PRICES
    Sections.prices = NaN * ones(Parameters.T, Parameters.Sections.nr); % we set it as a row vector since also Sectors.prices is a row vector.

    % PRODUCTION 
    Sections.production_phys = NaN * ones(Parameters.Sections.nr, Parameters.T);
    Sections.production_constraints = NaN * ones(Parameters.Sections.nr, Parameters.T);
    Sections.intermediate_sales_aggr_phys = NaN * ones(Parameters.Sections.nr, Parameters.T);

    % CONSTRAINTS IN THE FULFILLMENT OF ..
    % .. expected final demand
    Sections.exp_final_demand_fulfillment_constraints = NaN * ones(Parameters.Sections.nr, Parameters.T);
    % .. actual final demand
    Sections.final_demand_fulfillment_constraints = NaN * ones(Parameters.Sections.nr, Parameters.T);
    % Investment demand
    Sections.investm_demand_fulfillment_constraints = NaN * ones(Parameters.Sections.nr, Parameters.T);
    % Households' demand
    Sections.hhs_demand_fulfillment_constraints = NaN * ones(Parameters.Sections.nr, Parameters.T);
    % Government demand
    Sections.govt_demand_fulfillment_constraints = NaN * ones(Parameters.Sections.nr, Parameters.T);        


    %% sectors

    % FINAL DEMAND
    % from households
    Sectors.demand_from_hhs_phys = NaN * ones(Parameters.Sectors.nr, Parameters.Households.nr, Parameters.T);
    % from investing Divisions
    Sectors.demand_from_investing_divisions_aggr_phys = NaN * ones(Parameters.Sectors.nr, Parameters.T);
    % from government
    Sectors.demand_from_govt_phys = NaN * ones(Parameters.Sectors.nr, Parameters.T);
    % total
    Sectors.final_demand_phys = NaN * ones(Parameters.Sectors.nr, Parameters.T); 

    % SALES TO FINAL DEMAND BUYERS (hhs, gov't, investment)
    % to households
    Sectors.sales_to_hhs_phys = NaN * ones(Parameters.Sectors.nr, Parameters.Households.nr, Parameters.T);
    Sectors.sales_to_hhs_nominal = NaN * ones(Parameters.Sectors.nr, Parameters.Households.nr, Parameters.T);
    % to government
    Sectors.sales_to_govt_phys = NaN * ones(Parameters.Sectors.nr, Parameters.T); % vector showing sectors's sales to the government
    Sectors.sales_to_govt_nominal = NaN * ones(Parameters.Sectors.nr, Parameters.T); 
    % to investing Divisions or Sectors: following the structure of input-output tables, investments are not included in the interindustry transaction table (of intermediate inputs) but as part of final demand
    % Each Division's investment includes several different goods bought from different sections, according to the composition of its capital good.
    Sectors.aggr_investment_sales_phys = NaN * ones(Parameters.Sectors.nr, Parameters.T); 
    Sectors.aggr_investment_sales_nominal = NaN * ones(Parameters.Sectors.nr, Parameters.T);    
    % total sales to final demand buyers
    Sectors.sales_to_final_demand_phys = NaN * ones(Parameters.Sectors.nr, Parameters.T); % vector showing, for each sector, its total physical sales to final demand buyers           
    Sectors.sales_to_final_demand_nominal = NaN * ones(Parameters.Sectors.nr, Parameters.T); 

    % PRODUCTION & INVENTORIES
    Sectors.production_desired_driving_investment_phys = NaN * ones(Parameters.Sectors.nr, Parameters.T);
    Sectors.production_unbound_minus_inventories_phys = NaN * ones(Parameters.Sectors.nr, Parameters.T);
    Sectors.prod_cap = NaN * ones(Parameters.Sectors.nr, Parameters.T);       
    Sectors.production_phys = NaN * ones(Parameters.Sectors.nr, Parameters.T); 
    Sectors.production_nominal = NaN * ones(Parameters.Sectors.nr, Parameters.T); 
    Sectors.products_available_for_final_demand_phys = NaN * ones(Parameters.Sectors.nr, Parameters.T); % vector showing, for each sector, the amount of products available for sale to final demand
    % Sectors' production destined for sale to final demand (needed for real GDP computation)
    Sectors.production_for_final_demand_phys = NaN * ones(Parameters.Sectors.nr, Parameters.T); 
    Sectors.inventories_phys = NaN * ones(Parameters.Sectors.nr, Parameters.T); % vector showing inventories held by each sector of their own products
    Sectors.inventories_nominal = NaN * ones(Parameters.Sectors.nr, Parameters.T);
    Sectors.phys_inventories_to_tot_production_ratio = NaN * ones(Parameters.Sectors.nr, Parameters.T);
    Sectors.production_constraints = NaN * ones(Parameters.Sectors.nr, Parameters.T); % vector showing production constraints in the form of percentages
    
    % TECHNICAL COEFFICIENTS    
    Sectors.C_square = NaN * ones(Parameters.Sectors.nr, Parameters.Sectors.nr, Parameters.T); % sector-by-sector technical coefficients matrix (in physical terms)
    Sectors.C_rectangular = NaN * ones(Parameters.Sections.nr, Parameters.Sectors.nr, Parameters.T); % section-by-sector technical coefficients matrix (in physical terms)    
    Sectors.tightest_constraint = NaN * ones(Parameters.T, 1);
    % interindustry transaction matrices, total nominal production, value added
    Sectors.S_square = NaN * ones(Parameters.Sectors.nr, Parameters.Sectors.nr, Parameters.T); % matrix S of inter-sector transactions in physical quantities    
    Sectors.VA = NaN * ones(Parameters.T, Parameters.Sectors.nr);     

    % INVESTMENTS    
    Sectors.investments_rationing_percentage = NaN * ones(Parameters.T, Parameters.Sectors.nr); 
    Sectors.investments_costs = NaN * ones(Parameters.T, Parameters.Sectors.nr); 
    Sectors.investments_costs_defl = NaN * ones(Parameters.T, Parameters.Sectors.nr); 
    Sectors.desired_investments_costs_before_loans_rationing = NaN * ones(Parameters.T, Parameters.Sectors.nr);    
    Sectors.funds_available_for_future_investment = NaN * ones(Parameters.T, Parameters.Sectors.nr);    
    
    % CAPITAL    
    Sectors.capital_nominal = NaN * ones(Parameters.Sections.nr, Parameters.Sectors.nr, Parameters.T);
    Sectors.tot_capital_nominal = NaN * ones(Parameters.T, Parameters.Sectors.nr); 
    Sectors.tot_capital_defl = NaN * ones(Parameters.T, Parameters.Sectors.nr);         
    Sectors.capital_depreciation_nominal = NaN * ones(Parameters.T, Parameters.Sectors.nr);                           
    
    % FINANCIAL ASSETS & LIABILITIES
    Sectors.deposits = NaN * ones(Parameters.T, Parameters.Sectors.nr); 
    Sectors.loans_stock = NaN * ones(Parameters.T, Parameters.Sectors.nr);   
    Sectors.loans_demand_flow = NaN * ones(Parameters.T, Parameters.Sectors.nr); 
    Sectors.loans_received_flow = NaN * ones(Parameters.T, Parameters.Sectors.nr); 
    Sectors.loans_repaid = NaN * ones(Parameters.T, Parameters.Sectors.nr);    
    Sectors.net_worth = NaN * ones(Parameters.T, Parameters.Sectors.nr); 
    Sectors.leverage = NaN * ones(Parameters.T, Parameters.Sectors.nr); 

    % ASSETS & LIABILITIES
    Sectors.assets = NaN * ones(Parameters.T, Parameters.Sectors.nr);
    Sectors.liabilities = NaN * ones(Parameters.T, Parameters.Sectors.nr);
    
    % unit costs, mark-up, prices
    Sectors.intermediate_inputs_unit_costs = NaN * ones(Parameters.T, Parameters.Sectors.nr);        
    Sectors.capital_depreciation_unit_costs = NaN * ones(Parameters.T, Parameters.Sectors.nr);        
    Sectors.unit_costs = NaN * ones(Parameters.T, Parameters.Sectors.nr);            
    Sectors.shadow_prices = NaN * ones(Parameters.T, Parameters.Sectors.nr);  
    Sectors.prices = NaN * ones(Parameters.T, Parameters.Sectors.nr);  
    Sectors.green_vs_brown_shadow_price = NaN * ones(Parameters.T, 1);

    % revenues, profits, production costs, etc.
    Sectors.sales_nominal = NaN * ones(Parameters.Sectors.nr, Parameters.T); 
    Sectors.historic_costs = NaN * ones(Parameters.T, Parameters.Sectors.nr);     
    Sectors.taxes = NaN * ones(Parameters.T, Parameters.Sectors.nr); 
    Sectors.govt_subsidies = NaN * ones(Parameters.T, Parameters.Sectors.nr);  
    Sectors.interest_expenses = NaN * ones(Parameters.T, Parameters.Sectors.nr);    
    Sectors.entrepreneurial_profits = NaN * ones(Parameters.T, Parameters.Sectors.nr); 
    Sectors.entrepreneurial_profits_net_of_interest_expenses = NaN * ones(Parameters.T, Parameters.Sectors.nr);     
    Sectors.net_profits = NaN * ones(Parameters.T, Parameters.Sectors.nr); 
    Sectors.dividends = NaN * ones(Parameters.T, Parameters.Sectors.nr);
    Sectors.dividend_payout_ratio = NaN * ones(Parameters.T, Parameters.Sectors.nr);
    Sectors.retained_profits = NaN * ones(Parameters.T, Parameters.Sectors.nr);    

    % Emissions
    Sectors.emissions_flow = NaN * ones(Parameters.T, Parameters.Sectors.nr);    

    
    %% divisions

    Divisions.production_phys = NaN * ones(Parameters.Divisions.nr, Parameters.T); 
    Divisions.production_desired_driving_investment_phys = NaN * ones(Parameters.Divisions.nr, Parameters.T); 
    
    Divisions.prod_cap = NaN * ones(Parameters.Divisions.nr, Parameters.T);     
    Divisions.prod_cap_of_each_capital_asset = NaN * ones(Parameters.Sections.nr, Parameters.Divisions.nr, Parameters.T);     
    Divisions.desired_prod_cap_of_each_capital_asset_in2years = NaN * ones(Parameters.Sections.nr, Parameters.Divisions.nr, Parameters.T); 
    Divisions.desired_prod_cap_of_each_capital_asset_adj_after_loans_in2years = NaN * ones(Parameters.Sections.nr, Parameters.Divisions.nr, Parameters.T);     
    
    Divisions.capital_phys = NaN * ones(Parameters.Sections.nr, Parameters.Divisions.nr, Parameters.T);              
    Divisions.capital_depreciation_nominal = NaN * ones(Parameters.T, Parameters.Divisions.nr);                           
    Divisions.desired_investment_formula_cases = strings(Parameters.T, Parameters.Divisions.nr);

    Divisions.capital_productivity = NaN * ones(Parameters.Sections.nr, Parameters.Divisions.nr, Parameters.T);     
    Divisions.capacity_utilization_of_each_asset = NaN * ones(Parameters.Sections.nr, Parameters.Divisions.nr, Parameters.T); 
    Divisions.capacity_utilization_highest_value = NaN * ones(Parameters.T, Parameters.Divisions.nr);     
    Divisions.assumed_capacity_utilization_in1year = NaN * ones(Parameters.T, Parameters.Divisions.nr);
    Divisions.capacity_accumulation_rationing = NaN * ones(Parameters.T, Parameters.Divisions.nr); 

    Divisions.C_rectangular = NaN * ones(Parameters.Sections.nr, Parameters.Divisions.nr, Parameters.T); % section-by-division technical coefficients matrix (in physical terms)
    Divisions.C_rectangular_percentage_change = NaN * ones(Parameters.Sections.nr, Parameters.Divisions.nr, Parameters.T);
    Divisions.sectoral_weights = NaN * ones(Parameters.T, Parameters.Divisions.nr);
    Divisions.sectional_weights = NaN * ones(Parameters.T, Parameters.Divisions.nr);

    Divisions.share_of_initial_TFC = NaN * ones(Parameters.T, Parameters.Divisions.nr);        
    
    Divisions.intermediate_inputs_unit_costs = NaN * ones(Parameters.T, Parameters.Divisions.nr);
    Divisions.capital_depreciation_unit_costs = NaN * ones(Parameters.T, Parameters.Divisions.nr);
    Divisions.unit_costs = NaN * ones(Parameters.T, Parameters.Divisions.nr);
    Divisions.mark_up_desired = NaN * ones(Parameters.T, Parameters.Divisions.nr);    
    Divisions.shadow_prices = NaN * ones(Parameters.T, Parameters.Divisions.nr);
    Divisions.prices = NaN * ones(Parameters.T, Parameters.Divisions.nr);

    Divisions.desired_investments_costs_before_loans_rationing = NaN * ones(Parameters.T, Parameters.Divisions.nr);
    Divisions.funds_available_for_future_investment = NaN * ones(Parameters.T, Parameters.Divisions.nr);
    Divisions.investment_costs = NaN * ones(Parameters.T, Parameters.Divisions.nr);
    Divisions.NPV = NaN * ones(Parameters.T, Parameters.Divisions.nr);
    Divisions.NPV_discounted_revenues = NaN * ones(Parameters.T, Parameters.Divisions.nr);
    Divisions.NPV_investment_costs = NaN * ones(Parameters.T, Parameters.Divisions.nr);    
    Divisions.govt_subsidies = NaN * ones(Parameters.T, Parameters.Divisions.nr);

    Divisions.emission_intensities = NaN * ones(Parameters.T, Parameters.Divisions.nr);
    Divisions.emission_intensities_percentage_change = NaN * ones(Parameters.T, Parameters.Divisions.nr);
    Divisions.emissions_flow = NaN * ones(Parameters.T, Parameters.Divisions.nr); 


    %% bank
    
    % STOCKS
    % assets:
    Bank.loans_stock = NaN * ones(Parameters.T, 1); % outstanding stock of loans
    Bank.reserves_holdings = NaN * ones(Parameters.T, 1); 
    % liabilities:
    Bank.deposits = NaN * ones(Parameters.T, 1); 
    Bank.advances = NaN * ones(Parameters.T, 1); 
    % net worth:
    Bank.net_worth = NaN * ones(Parameters.T, 1); 
    
    % FLOWS
    Bank.loans_max_supply_flow = NaN * ones(Parameters.T, 1); % maximum amount of new supply of loans.
    Bank.loans_repaid = NaN * ones(Parameters.T, 1);
    Bank.profits = NaN * ones(Parameters.T, 1); 
    Bank.dividends = NaN * ones(Parameters.T, 1);
    Bank.profits_retained = NaN * ones(Parameters.T, 1); 
    
    % OTHER
    Bank.dividend_payout_ratio = NaN * ones(Parameters.T, 1);
    Bank.interest_on_loans = NaN * ones(Parameters.T, 1); 
    Bank.CAR = NaN * ones(Parameters.T, 1); % CAR = Capital Adequacy Ratio
    Bank.proportion_max_supply_vs_demanded_loans = NaN * ones(Parameters.T, 1); 
    Bank.proportion_supply_vs_demanded_loans = NaN * ones(Parameters.T, 1); 
    Bank.loans_stock_growth_rate = NaN * ones(Parameters.T, 1);
    Bank.deposits_growth_rate = NaN * ones(Parameters.T, 1);
    
    
    %% government
    
    % ASSETS & LIABILITIES
    % assets:
    Government.reserves_holdings = NaN * ones(Parameters.T, 1); 
    % liabilities:
    Government.advances = NaN * ones(Parameters.T, 1); 
    % net worth
    Government.net_worth = NaN * ones(Parameters.T, 1); 


    % FLOWS        
    Government.taxes = NaN * ones(Parameters.T, 1); 
    Government.consumption_expenditures = NaN * ones(Parameters.T, 1); 
    Government.subsidies = NaN * ones(Parameters.T, 1);
    Government.emissions_flow = NaN * ones(Parameters.T, 1);

    % OTHER MEASURES
    % Deficit
    Government.deficit = NaN * ones(Parameters.T, 1); 
    % Deficit-to-GDP ratio
    Government.deficit_to_GDP_ratio = NaN * ones(Parameters.T, 1); 
    % Debt-to-GDP ratio
    Government.debt_to_GDP_ratio = NaN * ones(Parameters.T, 1); 
    % Tax rate
    Government.sectors_tax_rate = NaN * ones(Parameters.T, 1); 
    % Growth rate of physical demand
    Government.demand_phys_growth_rate = NaN * ones(Parameters.T, 1);       
    % Consumption basket units demanded
    Government.consumption_basket_units_demanded_in1year = NaN * ones(Parameters.T, 1);       
    

    %% central bank
    
    CentralBank.advances = NaN * ones(Parameters.T, 1); 
    CentralBank.reserves = NaN * ones(Parameters.T, 1); 
    CentralBank.net_worth = NaN * ones(Parameters.T, 1); 
    
    %% macroeconomic variables
    
    % NOMINAL GDP
    Economy.GDP_nominal = NaN * ones(Parameters.T, 1);

    % NOMINAL GDP GROWTH RATE
    Economy.GDP_nominal_growth_rate = NaN * ones(Parameters.T, 1);
    
    % TOTAL NOMINAL SALES TO FINAL DEMAND
    % This is not equal nominal GDP when inventories are accumulated.
    Economy.sales_to_final_demand_nominal = NaN * ones(Parameters.T, 1);

    % TOTAL INCOME
    Economy.total_income = NaN * ones(Parameters.T, 1);
    
    % REAL GDP in chained (t=1) dollars
    Economy.GDP_real = NaN * ones(Parameters.T, 1);
    
    % REAL GDP GROWTH RATE
    Economy.GDP_real_growth_rate = NaN * ones(Parameters.T, 1);    

    % GDP DEFLATOR
    Economy.GDP_deflator = NaN * ones(Parameters.T, 1);

    % CONSUMER PRICE INDEX (CPI)
    Economy.CPI = NaN * ones(Parameters.T, 1);

    % INFLATION (based on GDP deflator)
    Economy.GDP_deflator_inflation = NaN * ones(Parameters.T, 1);

    % INFLATION (based on CPI)
    Economy.CPI_inflation = NaN * ones(Parameters.T, 1);


    % REAL HHS' DEMAND & CONSUMPTION        
    % Level
    Economy.hhs_demand_defl = NaN * ones(Parameters.T, 1);
    % Level
    Economy.hhs_consumption_defl = NaN * ones(Parameters.T, 1);
    % Growth rate
    Economy.hhs_consumption_defl_growth_rate = NaN * ones(Parameters.T, 1);
    % Growth rate of physical demand
    Economy.hhs_demand_phys_growth_rate = NaN * ones(Parameters.T, 1);


    % REAL (DEFLATED) INVESTMENT DEMAND & PURCHASES
    % Level
    Economy.current_investment_demand_defl = NaN * ones(Parameters.T, 1);
    % Level
    Economy.investment_defl = NaN * ones(Parameters.T, 1);
    % Growth rate
    Economy.investment_defl_growth_rate = NaN * ones(Parameters.T, 1);


    % REAL (DEFLATED) GOV'T DEMAND & CONSUMPTION
    Economy.current_govt_demand_defl = NaN * ones(Parameters.T, 1);
    Economy.govt_consumption_defl = NaN * ones(Parameters.T, 1);


    % TOTAL REAL (DEFLATED) FINAL DEMAND
    Economy.final_demand_defl = NaN * ones(Parameters.T, 1);


    % TOTAL REAL (DEFLATED) SALES
    Economy.tot_sales_to_final_demand_defl = NaN * ones(Parameters.T, 1);


    % FINAL DEMAND RATIONING
    Economy.final_demand_rationing = NaN * ones(Parameters.T, 1);
    Economy.hhs_demand_rationing = NaN * ones(Parameters.T, 1);
    Economy.govt_demand_rationing = NaN * ones(Parameters.T, 1);


    % CAPITAL STOCKS & INVESTMENTS
    % Physical capital stocks
    Economy.capital_stocks_phys = NaN * ones(Parameters.Sections.nr, Parameters.T);
    % Nominal capital stocks
    Economy.capital_stocks_nominal = NaN * ones(Parameters.Sections.nr, Parameters.T);
    % Nominal investments in each asset
    Economy.investments_in_each_asset_nominal = NaN * ones(Parameters.Sections.nr, Parameters.T);

   
    % GREEN SHARES
    % In production: the percentage of produced green electricity on total electricity produced
    Economy.green_share_production = NaN * ones(Parameters.T, 1);
    % In sales: the percentage of sold green electricity on total electricity sold
    Economy.green_share_sales = NaN * ones(Parameters.T, 1);


    % MOST CONSTRAINING INVESTMENT SECTION
    % i.e. the section which is the tightest in rationing investments (see Investments Rationing function).
    % index number
    Economy.most_constraining_investment_section_idx = NaN * ones(Parameters.T, 1);
    % name
    Economy.most_constraining_investment_section_id = strings([Parameters.T, 1]);


    % EMISSIONS: flow and stock
    Economy.emissions_flow = NaN * ones(Parameters.T, 1);
    Economy.emissions_stock = NaN * ones(Parameters.T, 1);
    Economy.emissions_flow_from_electricity_percentage = NaN * ones(Parameters.T, 1);

    
    % OTHER
    Economy.brown_divisions_weighting_for_Triode_Production_function = strings(Parameters.T, 1);
    Economy.share_hh_cons_in_nominal_production = NaN * ones(Parameters.T, 1);
    Economy.share_govt_cons_in_nominal_production = NaN * ones(Parameters.T, 1);
    Economy.share_investment_in_nominal_production = NaN * ones(Parameters.T, 1);
    Economy.share_intermediate_in_nominal_production = NaN * ones(Parameters.T, 1);
    Economy.share_delta_inventories_in_nominal_production = NaN * ones(Parameters.T, 1);    


%% INITIALIZATION
    %% sectors/1
        %% prices
     
        % SECTIONS' PRICES        
        Sections.prices(t,:) = 1;

        % SECTORS' PRICES
        for i = 1 : Parameters.Sectors.nr        
            Sectors.prices(t,i) = Sections.prices(t, Parameters.Sectors.section_idx(i));
        end
    
        % DIVISIONS' PRICES
        for i = 1 : Parameters.Divisions.nr        
            Divisions.prices(t,i) = Sections.prices(t, Parameters.Divisions.section_idx(i));
        end        


        %% adjusting production by electricity divisions

        % EXIOBASE NOMINAL OUTPUT                
        % Create empty Divisions' output vector
        divisions_nominal_output_Exiobase = NaN * ones(Parameters.Divisions.nr, 1);  
        % Filling the Divisions' output vector
        for i = 1 : Parameters.Divisions.nr
            % Name of Division i
            division_name_i = Parameters.Divisions.names(i);
            % Index of the table row that corresponds to Division i
            idx_division_table_rows = strcmp(table_total_output_Exiobase.SectorsNames, division_name_i);
            % Fill the Divisions' output vector
            divisions_nominal_output_Exiobase(i) = table_total_output_Exiobase.TotalOutput(idx_division_table_rows);
        end
        
        % EXIOBASE PHYSICAL OUTPUT
        % Divisions
        divisions_phys_output_Exiobase = divisions_nominal_output_Exiobase ./ Divisions.prices(t, randi(Parameters.Divisions.nr));
        % Sections
        sections_phys_output_Exiobase = NaN * ones(Parameters.Sections.nr, 1);
        for i = 1 : Parameters.Sections.nr
            sections_phys_output_Exiobase(i) = ...
                sum(divisions_phys_output_Exiobase(Parameters.Divisions.section_idx == i));
        end

     

        % GLOBAL ELECTRICITY PRODUCTION IN TWh
        % We know the physical production in TWh from actual data (IEA 2023), ..
        % ..which we have stored in the table "IEA_electricity_sectors.production_table" in the "electricity_weights_IEA.mat" file.
        % This table reports data for all electricity Divisions, which we want to sum together.
        % However, we want to exclude the column named "years" from the sum.
        % Index of the table column that we want to exclude from the sum
        idx_table_column = strcmp(IEA_electricity_sectors.production_table.Properties.VariableNames, "years");
        % Global electricity production in TWh
            % note that we pick only the year of interest depending on which year we are relying on to calibrate the model,..
            % .. as indicated by "Parameters.calibration_year".
        global_electricity_production_TWh = ...
            sum(IEA_electricity_sectors.production_table{IEA_electricity_sectors.production_table.years == Parameters.calibration_year, ~idx_table_column}, 2);
        % You can compare this value with the ones reported here:
        % https://ourworldindata.org/grapher/electricity-generation?tab=chart&country=~OWID_WRL
        % ..to verify that the value is quite accurate.

            
        % PHYSICAL GLOBAL ELECTRICITY PRODUCTION FROM EXIOBASE        
        global_electricity_production_Exiobase_phys = sum(divisions_phys_output_Exiobase(Parameters.Divisions.idx_electricity_producing));
    

        % CONVERSION FACTOR FROM UNITS OF ELECTRICITY TO TWh
        % See derivation in Latex file
        % By multipliying electricity units in the model with this number you obtain the amount of electricity in TWh.
        % In other words, one unit of electricity in the model corresponds to this amount of TWh.
        Parameters.electricity_units_to_TWh = ...
            global_electricity_production_TWh ./ global_electricity_production_Exiobase_phys;



        % CORRECTED PHYSICAL OUTPUT
        % It is likely the case that in reality, green and brown electricity Divisions have sold their output at different prices, ..
        % ..(or at least that Exiobase compilers have assumed so), implying that the values in "divisions_phys_output_Exiobase" are distorted.
        % Indeed, the resulting relative weights of our electricity Divisions are not in line with their actual weights in the real-world.
        % However, we know each Division's physical production in TWh from actual data (IEA), ..
        % ..which we have stored in the table "IEA_electricity_sectors.production_table" in the "electricity_weights_IEA.mat" file.
        % We can therefore take those data (for the year of interest depending on which year we are relying on to calibrate the model)..
        % ..and simply convert them into Triode's electricity units, ..
        % ..and set the resulting data as the physical productions of the electricity Divisions.

        % Electricity Divisions' physical production in TWh
        IEA_electricity_sectors.production_table;        
        % Create empty Divisions' output vector
        divisions_phys_output_corrected = NaN * ones(Parameters.Divisions.nr, 1);  

        % Filling the Divisions' output vector
        if Rules.electricity_sector_aggregation == "one_electricity_sector"
            % If we are not distinguishing between green and brown electricity sectors, then we don't need to correct the output values
            divisions_phys_output_corrected = divisions_phys_output_Exiobase;
        else
            for i = 1 : Parameters.Divisions.nr                
                % For electricity Divisions, we correct the data
                if ismember(i, [Parameters.Divisions.idx_green Parameters.Divisions.idx_brown])
                    % Name of Division i
                    division_name_i = Parameters.Divisions.names(i);
                    % Index of the table column that corresponds to Division i
                    idx_division_table_column = strcmp(IEA_electricity_sectors.production_table.Properties.VariableNames, division_name_i);
                    % Fill the Divisions' output vector..
                    % ..and convert the phyisical units from TWh to Triode's electricity units
                    divisions_phys_output_corrected(i) = ...
                        IEA_electricity_sectors.production_table{IEA_electricity_sectors.production_table.years == Parameters.calibration_year, idx_division_table_column} ...
                        ./ Parameters.electricity_units_to_TWh;               
                % For all other Divisions, we keep the original data
                else
                    divisions_phys_output_corrected(i) = divisions_phys_output_Exiobase(i);            
                end    
            end
        end


        % TEST
        % Total electricity production from Exiobase (in Triode units) must be equal to total electricity production "corrected" (in Triode units)
        global_electricity_production_corrected_phys = sum(divisions_phys_output_corrected(Parameters.Divisions.idx_electricity_producing));
        if abs(...
                (global_electricity_production_Exiobase_phys - global_electricity_production_corrected_phys) ...
                / global_electricity_production_Exiobase_phys ...
                ) ...
                > Parameters.error_tolerance_medium
            error('Check total electricity production')
        end

        % INTUITIVE FIGURE
        % figure;
        % sgtitle('Weights of electricity Divisions in total electricity production')
        % sp1 = subplot(1,2,1);
        % bar(100 * divisions_phys_output_Exiobase(Parameters.Divisions.idx_electricity_producing) ./ global_electricity_production_Exiobase_phys)
        % ytickformat("percentage");
        % title('Exiobase', 'FontSize', 17)        
        % sp2 = subplot(1,2,2);
        % bar(100 * divisions_phys_output_corrected(Parameters.Divisions.idx_electricity_producing) ./ global_electricity_production_corrected_phys);
        % ytickformat("percentage");
        % title('Corrected', 'FontSize', 17)
        % % Set the y-axis limits of the two subplots to be equal
        % linkaxes([sp1 sp2],'y')
        % Parameters.Divisions.names(Parameters.Divisions.idx_electricity_producing); 


        % SETTING DIVISIONS' PHYSICAL OUTPUT

        if Rules.electricity_divisions_tech_coeff_adjustment == "no"
            divisions_output_phys = divisions_phys_output_Exiobase;                        
        elseif Rules.electricity_divisions_tech_coeff_adjustment == "yes"            
            divisions_output_phys = divisions_phys_output_corrected;
        end


        %% technical coefficients


        %%%%%%%%  SECTIONS-BY-DIVISIONS TECHNICAL COEFFICIENTS MATRIX  %%%%%%%%
        
        % These are technical coefficients in physical (not monetary!) terms, indeed we call them C (and not A) following Miller & Blair (2009)      
    
        % Import the rectangular interindustry transactions table from the Exiobase excel sheet
        table_interindustry_transactions_monetary = readtable(excel_file_Exiobase, 'Sheet', 'interindustry_transactions', 'VariableNamingRule', 'preserve'); % setting 'VariableNamingRule' to 'preserve' prevents Matlab from renaming the variable names (it would erase blank spaces)
        % Create empty rectangular interindustry transactions matrix
        matrix_interindustry_transactions_monetary = NaN * ones(Parameters.Sections.nr, Parameters.Divisions.nr);
        
        % Filling the rectangular interindustry transactions matrix
        
        for i = 1 : Parameters.Divisions.nr
            
            % Index of the table column that corresponds to Division i
            idx_table_column = strcmp(table_interindustry_transactions_monetary.Properties.VariableNames, Parameters.Divisions.names(i));
    
            for j = 1 : Parameters.Sections.nr
                
                % Index of the row in the Exiobase interindustry transactions table that refers to section j
                idx_table_row = strcmp(table_interindustry_transactions_monetary.SectionsNames, Parameters.Sections.names(j));
    
                % Fill the rectangular interindustry transactions matrix
                matrix_interindustry_transactions_monetary(j,i) = table_interindustry_transactions_monetary{idx_table_row, idx_table_column};
            end
        end

        % Interindustry transactions in physical terms
        matrix_interindustry_transactions_phys = matrix_interindustry_transactions_monetary ./ Sections.prices(t,:)';

        % Rectangular technical coefficients matrix
        Parameters.Divisions.C = ...
            matrix_interindustry_transactions_phys ./ divisions_output_phys';                                
    
        
        % TEST
        % Values should not be <0 nor >1
        if any(Parameters.Divisions.C < 0, 'all') || any(Parameters.Divisions.C > 1, 'all')
            error('There is at least one negative value or one value >1 in ''Parameters.Divisions.C''')
        end


        % ASSIGN TECHNICAL COEFFICIENTS TO FIRST YEAR
        Divisions.C_rectangular(:,:,t) = Parameters.Divisions.C;

        
        %%%%%%%%  SAVE ADJUSTED TECHNICAL COEFFICIENTS INTO AN EXCEL FILE  %%%%%%%%
        if Rules.electricity_divisions_tech_coeff_adjustment == "yes"
            % Create the table
            technical_coeff_table = ...
                array2table(Parameters.Divisions.C, 'VariableNames', Parameters.Divisions.names);
            % Add a column with the names of the Sections (i.e. commodities)
            technical_coeff_table = ...
                addvars(technical_coeff_table, Parameters.Sections.names, 'NewVariableNames', 'Commodities', 'Before', Parameters.Divisions.names(1));
            % Save into an Excel file
            writetable(technical_coeff_table, sprintf('technical_coefficients_adj_%d.xlsx', Parameters.calibration_year), 'Sheet', 'technical_coefficients');
        end
        clear technical_coeff_table


        %% divisions' emission intensities

        % = (total emissions) / (total output)
        
        % Import the total emission table from the Exiobase excel sheet
        table_total_emissions = readtable(excel_file_Exiobase, 'Sheet', 'total_emissions', 'VariableNamingRule', 'preserve'); % setting 'VariableNamingRule' to 'preserve' prevents Matlab from renaming the variable names (it would erase blank spaces)
        % Create empty total emissions vector
        divisions_total_emissions_Exiobase = NaN * ones(1, Parameters.Divisions.nr);
        % Filling the total emissions vector
        for i = 1 : Parameters.Divisions.nr
            % Name of Division i
            division_name_i = Parameters.Divisions.names(i);
            % Index of the table column that corresponds to Division i
            idx_division_table_columns = strcmp(table_total_emissions.Properties.VariableNames, division_name_i);
            % Fill the emission intensities vector
            divisions_total_emissions_Exiobase(i) = table_total_emissions{1, idx_division_table_columns};
        end

        % CONVERT KG TO GIGATONNES
        divisions_total_emissions_Exiobase = divisions_total_emissions_Exiobase / how_many_Kg_in_one_Gt;
        
        % EMISSIONS INTENSITIES
        Parameters.Divisions.emission_intensities = ...
            divisions_total_emissions_Exiobase ./ divisions_output_phys';                               


        % COMPARE EMISSION INTENSITIES
        % Let's compare the adjusted emission intensities (where phys output is corrected) with the non-adjusted ones.
        % For all Divisions except electricity ones, they should be the same.
        % For the green electricity Divisions, it should be: adjusted < non-adjusted.
        % For the brown electricity Divisions, it should be: adjusted > non-adjusted.
        emission_intensities_Exiobase_original = divisions_total_emissions_Exiobase ./ divisions_phys_output_Exiobase';
        [emission_intensities_Exiobase_original; Parameters.Divisions.emission_intensities];
        % INTUITIVE FIGURE
        % figure;
        % sgtitle('Emission intensities')
        % sp1 = subplot(1,2,1);
        % bar(emission_intensities_Exiobase_original(Parameters.Divisions.idx_electricity_producing));
        % title('Exiobase', 'FontSize', 17)        
        % sp2 = subplot(1,2,2);
        % bar(Parameters.Divisions.emission_intensities(Parameters.Divisions.idx_electricity_producing));
        % title('Corrected', 'FontSize', 17)
        % set(gca, "YScale", 'linear')
        % % Set the y-axis limits of the two subplots to be equal
        % linkaxes([sp1 sp2],'y')
        % Parameters.Divisions.names(Parameters.Divisions.idx_electricity_producing)


        % TEST
        if any(Parameters.Divisions.emission_intensities < 0, 'all')
            error('There is at least one negative value in ''Parameters.Divisions.emission_intensities''')
        end

        % ACTUAL EMISSION INTENSITIES
        Divisions.emission_intensities(t,:) = Parameters.Divisions.emission_intensities; 


        %% capital, inventories, profits, leverage

        % CAPITAL PRODUCTIVITY
        Divisions.capital_productivity(:,:,t) = initial_capital_productivity;

        % Divisions.capital_productivity(:, Parameters.Divisions.idx_green, t) = ...
        %     3 * Divisions.capital_productivity(:, Parameters.Divisions.idx_green, t);
        % Divisions.capital_productivity(:, Parameters.Divisions.idx_brown, t) = ...
        %     3 * Divisions.capital_productivity(:, Parameters.Divisions.idx_brown, t);


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%  INITIAL CAPITAL STOCKS  %%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % We don't have data on global capital stocks, since EuKlems refers only to western countries.
        % To derive the initial capital stock levels, we therefore use the following formula:
                
        % PhysicalOutput = (Productivity) * (CapacityUtilization * PhysicalCapitalStock)  -->
        % PhysicalCapitalStock = (PhysicalOutput) / (CapacityUtilization * Productivity)        
        % .. where "CapacityUtilization" is assumed, and "Productivity" is the one computed from EuKlems.    

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % READJUSTED PHYSICAL OUTPUT

        % What values should we use for "PhysicalOutput" in the formula above?
        % For all Divisions except the electricity-producing ones, we can use the values implied by Exiobase.
        % For the electricity-producing Divisions, instead, we should keep in mind which year we have chosen for "Parameters.year_of_simulations_kickoff".
        % For instance imagine that "Parameters.calibration_year" = 2015, while "Parameters.year_of_simulations_kickoff" = 2022
            % ..in this case, we want the simulation to feature an initial green share and initial electricity weights that are those of 2022..
            % ..therefore, we need to assign to the electricity-producing Divisions a physical output level that is consistent with those green share and electricity weights.
        % Note that if "Parameters.calibration_year" = 2015 and "Parameters.year_of_simulations_kickoff" = 2015, then..
            % .. "divisions_phys_output_readjusted" is exactly the same as "divisions_phys_output_corrected"

        % Electricity-producing Divisions physical output, consistent with electricity weights of the year defined in "Parameters.year_of_simulations_kickoff"
        electricity_divisions_phys_output_readjusted = ...
            Parameters.Divisions.target_sectional_weights(1, Parameters.Divisions.idx_electricity_producing) .* global_electricity_production_Exiobase_phys;
        % Create new array of the Divisions' physical output, to be used to derive initial capital stocks
        divisions_phys_output_readjusted = divisions_phys_output_corrected;
        divisions_phys_output_readjusted(Parameters.Divisions.idx_electricity_producing) = electricity_divisions_phys_output_readjusted;

        % TEST
        % Total electricity production from Exiobase (in Triode units) must be equal to total electricity production "readjusted" (in Triode units)
        global_electricity_production_readjusted_phys = sum(divisions_phys_output_readjusted(Parameters.Divisions.idx_electricity_producing));
        if abs(...
                (global_electricity_production_Exiobase_phys - global_electricity_production_readjusted_phys) ...
                / global_electricity_production_Exiobase_phys ...
                ) ...
                > Parameters.error_tolerance_medium
            error(['Total electricity production from Exiobase (in Triode units) is not equal to total electricity production "readjusted" (in Triode units), ' ...
                'i.e. the array "global_electricity_production_Exiobase_phys" differs from "global_electricity_production_readjusted_phys"'])
        end

        % INTUITIVE FIGURE
        % figure;
        % sgtitle('ciao')
        % sp1 = subplot(1,2,1);
        % bar(divisions_phys_output_corrected(Parameters.Divisions.idx_electricity_producing));
        % title('Corrected', 'FontSize', 17)        
        % sp2 = subplot(1,2,2);
        % bar(divisions_phys_output_readjusted(Parameters.Divisions.idx_electricity_producing));
        % title('Readjusted', 'FontSize', 17)
        % set(gca, "YScale", 'linear')
        % % Set the y-axis limits of the two subplots to be equal
        % linkaxes([sp1 sp2],'y')
        % Parameters.Divisions.names(Parameters.Divisions.idx_electricity_producing);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        % PERTURBATION
        % Define the perturbation of original physical capital stocks values
        if numel(Variations.capital_stocks_perturbation) > 1
            capital_stocks_perturbation = Variations.capital_stocks_perturbation(sim_counter);
        else
            capital_stocks_perturbation = Variations.capital_stocks_perturbation;
        end

        
        % INITIAL PHYSICAL CAPITAL STOCKS
        
        if Rules.electricity_divisions_tech_coeff_adjustment == "no"
            
            divisions_initial_capital_phys = ...
                capital_stocks_perturbation * (divisions_output_phys' ./ (Parameters.Divisions.normal_capacity_utilization .* Divisions.capital_productivity(:,:,t)));
        
        elseif Rules.electricity_divisions_tech_coeff_adjustment == "yes"
        
            divisions_initial_capital_phys = ...
                capital_stocks_perturbation * (divisions_phys_output_readjusted' ./ (Parameters.Divisions.normal_capacity_utilization .* Divisions.capital_productivity(:,:,t)));
        
        end
        
        % Replace Infinite values with zeros
        divisions_initial_capital_phys(isinf(divisions_initial_capital_phys)) = 0;        
       
        % Adjust the value for the Construction sector
        % idx_sector_construction = find(Parameters.Sectors.names == "Construction");
        % divisions_initial_capital_phys(:, idx_sector_construction) = 1 * divisions_initial_capital_phys(:, idx_sector_construction);                
        


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%  OTHER VARIABLES  %%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % PRODUCTION LIMIT OF EACH CAPITAL ASSET, IN 1 YEAR
        divisions_prod_limit_of_each_capital_asset_in1year = ...
            Divisions.capital_productivity(:,:,t) .* divisions_initial_capital_phys;
    
        % PHYSICAL INVENTORIES
        % These are the inventories we assume the sectors begin with.
        % However, we will define the proper Sectors.inventories_phys(t) after the production and selling processes.
        initial_inventories_phys = NaN * ones(Parameters.Sectors.nr, 1);
        initial_inventories_phys(:) = 0;                     
        
        % LEVERAGE
        Sectors.leverage(t,:) = Parameters.Sectors.leverage_target;


        %% initial desired investment

        % We may have 3 different cases, depending on "Rules.initial_investment":
            % A. "no"                               --> at t=1, investment = 0
            % B. "yes - hypothetical growth rate"   --> at t=1, investment > 0; the amount is implied by a desired production level implied by an assumed growth rate.
            % C. "yes - capital depreciation"       --> at t=1, investment > 0; the amount is given by the depreciated capital, assuming that all capital is affected by depreciation.

        % It may be useful to introduce some investment at t=1.
        % Otherwise, GDP(t=1) << GDP(t=2), i.e. we would see a very high GDP growth in the second time step.

        % How should we define the initial investment in the case B. "yes - hypothetical growth rate"?        
            % Well, we just have to define a desired production amount (for each Division) that will drive the investments.
            % We first define such desired production amount at the Sectional (i.e. commodities') level as:
                % (Desired physical production) = (1 + hypothetical growth rate) * (Physical production given by Exiobase)
            % Then we translate it at the Divisional level by using the target sectional weights.


        if Rules.initial_investment == "no"

            sections_demand_in1year_from_invest_divisions_desired_phys = ...
                zeros(Parameters.Sections.nr, Parameters.Divisions.nr);

        else

            if Rules.initial_investment == "yes - capital depreciation"

                sections_demand_in1year_from_invest_divisions_desired_phys = ...
                    Parameters.Divisions.depreciation_rates .* divisions_initial_capital_phys;
            
            elseif Rules.initial_investment == "yes - hypothetical growth rate"
                    
                % Assumed growth rate
                hypothetical_growth_rate = 0.015;
                % Desired production amount at the Sectional level
                sections_phys_output_desired = (1 + hypothetical_growth_rate) .* sections_phys_output_Exiobase;
                % Desired production amount at the Divisional level
                divisions_production_driving_investment = NaN * ones(Parameters.Divisions.nr, 1);
                for i = 1 : Parameters.Divisions.nr            
                    divisions_production_driving_investment(i) = ...
                        Parameters.Divisions.target_sectional_weights(1,i) .* sections_phys_output_desired(Parameters.Divisions.section_idx(i));
                end

        
                % See explanations and equation derivation in the respective Latex file


                % ASSUMED CAPACITY UTILIZATION
                % Assumed capacity utilization in the next period        
                if Rules.depreciation == "only used capital"
                    % we assume it to be equal to the normal capacity utilization level
                    assumed_capacity_utilization_in1year = Parameters.Divisions.investment_threshold_coefficient;
                else
                    % If instead depreciation affects the entire capital stock, then it is as if capacity utilization was 100%
                    assumed_capacity_utilization_in1year = ones(1, Parameters.Divisions.nr);
                end 


                % HYPOTHETICAL PRODUCTION CAPACITY IN 2 YEARS, IF NOT INVESTING 
                prod_limit_of_each_capital_asset_in2years_without_invest = ...
                    Divisions.capital_productivity(:,:,t) .* ((1 - Parameters.Divisions.depreciation_rates .* assumed_capacity_utilization_in1year) .* divisions_initial_capital_phys); 


                % SECTIONAL DEMANDS IMPLIED BY DESIRED INVESTMENTS
                [sections_demand_in1year_from_invest_divisions_desired_phys, ~, ~, ~] = ...
                    Desired_Investments_function...
                        (t, Rules.desired_investment_function, Rules.min_investment, Rules.investment_reference_case_2B, Parameters.time_step_corresponding_to_2022, ...
                        Parameters.Sections.nr, Parameters.Divisions.nr, Parameters.Divisions.capital_assets_logical_matrix, ...    
                        Parameters.Divisions.idx_shrinking, Parameters.Divisions.investment_threshold_coefficient, assumed_capacity_utilization_in1year, ...
                        Parameters.Divisions.depreciation_rates, Divisions.capital_productivity(:,:,t), ...
                        divisions_production_driving_investment, divisions_initial_capital_phys, ...
                        divisions_prod_limit_of_each_capital_asset_in1year, prod_limit_of_each_capital_asset_in2years_without_invest);  
                
                % Test
                if any(sections_demand_in1year_from_invest_divisions_desired_phys < 0, 'all')
                    error('At time step %d, there is at least one negative value in ''sections_demand_in1year_from_invest_divisions_desired_phys''', t)
                end                 
            end
        end          

    %% households
        %% physical demand relations
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%   HOUSEHOLDS' PHYSICAL DEMAND RELATIONS   %%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        % We assume that each household, given its final demand budget, will allocate it across the goods..
        % ..in such a way as to ensure that the physical relations among the goods are kept constant.
        % The reasoning is as follows:
        % from Exiobase we have computed the nominal amounts that hhs consume of each good;
        % given our assumed initial prices, those amounts can be converted to physical amounts:
                % Parameters.Households.exiobase_demand_relations_phys = NominalConsumptionExiobase / InitialPrices            

        % Note that the final demand table from the Exiobase excel sheet refers to use of sectors' commodities, 
        % ..while we need a vector that refers to sections' commodities. Therefore, we'll need to sum across commodities
        % ..referring to the same section (e.g. green and brown electricity).
    
        % Import the final demand table from the Exiobase excel sheet
        table_final_demand = readtable(excel_file_Exiobase, 'Sheet', 'final_demands', 'VariableNamingRule', 'preserve'); % setting 'VariableNamingRule' to 'preserve' prevents Matlab from renaming the variable names (it would erase blank spaces)
        % Create empty hhs consumption vector
        hhs_consumption_nominal = NaN * ones(Parameters.Sections.nr, 1);
        
        % Filling the hhs' consumption vector
        for j = 1 : Parameters.Sections.nr            
            % Index of the rows in the Exiobase technical coefficients table that refer to section j
            idx_table_row = strcmp(table_final_demand.SectionsNames, Parameters.Sections.names(j));               
            % Fill the hhs' consumption vector
            hhs_consumption_nominal(j) = table_final_demand.FinalConsumptionExpenditureByHouseholds(idx_table_row);
        end
       
        
        % AGGREGATING FOSSIL-FUELS
        % The hh consumes quite some fossil-fuels from the "Fossil fuels processing" Section, but very little from the "Fossil fuels extraction" Section.
        % To compute the emission intensity of the household, i.e. the amount of emissions per unit of fossil-fuels consumed, ..
        % ..we would have to sum the two fossil-fuels sections together. However, that cannot be done because they aren't expressed in the same units.
        % Therefore, to make things easier, and since the hhs' demand from the "Fossil fuels extraction" Section is neglegible, we simply transfer it to the..
        % .."Fossil fuels processing" Section.
        if any(ismember(Parameters.Sections.names(Parameters.Sections.idx_demand_set_to_zero), "Fossil fuels extraction"))
            idx_ff_processing = Parameters.Sections.names == "Fossil fuels processing";
            idx_ff_extraction = Parameters.Sections.names == "Fossil fuels extraction";
            hhs_consumption_nominal(idx_ff_processing) = ...
                hhs_consumption_nominal(idx_ff_processing) + hhs_consumption_nominal(idx_ff_extraction);
            hhs_consumption_nominal(idx_ff_extraction) = 0;
        end


        % PHYSICAL DEMAND RELATIONS
        Parameters.Households.exiobase_demand_relations_phys = hhs_consumption_nominal ./ Sections.prices(t,:)';



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%   HOUSEHOLDS' PHYSICAL DEMAND ELASTICITIES   %%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % If we allow for elasticity in response to changes in relative prices, we use the Almost Ideal Demand System (AIDS)..
        % ..as done in Jackson & Jackson "Modelling energy transition risk" (2021), Appendix B.2.2 and Table C.1 in Appendix C.

        if Rules.hhs_demand_elasticity == "AIDS elasticity"            

            % SENSITIVITY COEFFICIENTS MATRIX
            % Values on the diagonal of the matrix capture the hh's responsiveness to the price of the commodity on the respective matrix row 
                % values are <0: when the relative price of a good increases (e.g. apples), the hh reduces the consumption of apples
            % Values that are not on the diagonal of the matrix capture the hh's responsiveness to the prices of the other commodities 
                % values are >0: when the relative price of another good (e.g. bananas) increases, the hh increases the consumption of apples

            Parameters.Households.lambda_AIDS_sensitivity_coefficients = NaN * ones(Parameters.Sections.nr, Parameters.Sections.nr);

            % Value of the lambdas on the matrix diagonal
            % The value is taken from Table C.1 in Appendix C (Jackson & Jackson 2021).
            lambda_diagonal_value = 0.05;            

            for i = 1 : Parameters.Sections.nr
                for j = 1 : Parameters.Sections.nr
                    if Parameters.Sections.idx_demand_set_to_zero(i) || Parameters.Sections.idx_demand_set_to_zero(j)
                        Parameters.Households.lambda_AIDS_sensitivity_coefficients(i,j) = 0;
                    else
                        if i == j           
                            % Coefficients on the matrix diagonal
                            Parameters.Households.lambda_AIDS_sensitivity_coefficients(i,j) = ...
                                - lambda_diagonal_value;
                        else 
                            % Coefficients not on the matrix diagonal
                                % As explained in Appendix B.2.2 (Jackson & Jackson 2021), the row sum of coefficients must be zero.
                                % In addition, coefficients not on the matrix diagonal are all equal.
                            Parameters.Households.lambda_AIDS_sensitivity_coefficients(i,j) = ...
                                lambda_diagonal_value / (Parameters.Sections.nr - sum(Parameters.Sections.idx_demand_set_to_zero) - 1);
                        end
                    end
                end
            end

            % Test
            % The horizontal sum of the matrix "Parameters.Households.lambda_AIDS_sensitivity_coefficients" must be zero
            if any(abs(sum(Parameters.Households.lambda_AIDS_sensitivity_coefficients(~Parameters.Sections.idx_demand_set_to_zero, :), 2)) > Parameters.error_tolerance_strong)
                error('The horizontal sum of the matrix "Parameters.Households.lambda_AIDS_sensitivity_coefficients" is significantly different from zero')
            end

        end


        %% Households: electrification, fossilization

        % In Triode, the household has a specific consumption bundle, comprising several commodities, among which also fossil-fuels and electricity. 
        % The relations between commodities are calibrated from Exiobase:
            % Example for 2022: for every computer consumed, the hh wants to consume 20 apples, 8 Joules of energy in fossil-fuels and 5 Joules of energy in electricity.
        
        % In the energy transition process entailed by STEPS, APS, NZE, the household will replace--to some extent--fossil fuels with electricity.
        % But the problem is that in Triode we don't distinguish whether the household is using energy (fossil-fuels and electricity):
            % for transportation (i.e. their cars) 
            % or for buildings (heating, cooking..).
        % Nonetheless, we would like to apply the Electrification and Fossilization values..
        % ..derived from IEA for Transportation and Buildings to model the energy transition in Triode's household's consumption relations:
            % Example for 2050 in NZE scenario: for every computer consumed, the hh wants to consume 20 apples, 2 Joules of energy in fossil-fuels and 11 Joules of energy in electricity.
        % This section of code does exactly this. All data needed comes from the MAT file "electrification_IEA_%s.mat".

        % REFERENCE: EXCEL FILE
        % To better understand the above reasoning and the calculations performed in this section of code..
        % ..see Excel file "Energy transition in coefficients" - sheet "Households 2".

        % TO BE NOTED
        % We have assumed that the hh consumes only from "Fossil fuels processing"
            % We thus apply the exogenous change to the hhs' demand relations for fossil fuels, entailed by the energy transition process, only to such Section.           
        % In Triode, we have 2 Sections supplying electricity: "Electricity transmission" and "Electricity"
            % We thus apply the exogenous change to the hhs' demand relations, entailed by the energy transition process, to both such Sections.


        %%%%%%%%%%%%%   EFFICIENCY GAINS FROM ELECTRIFICATION   %%%%%%%%%%%%%
        
        % Remember that replacing fossil-fuels with electricity reduces the total amount of energy required to deliver the same service (transport, heating, etc).
        
        % Now we define the share of initial (2022) TFC reached through electrification by 2050.
        
        % Example: if electrification has increased from 2022 to 2050 by 10 percentage points and this leads to a TFC reduction of 5%, then:
        % (share_of_initial_TFC) = 100% - 5% = 95% = 1 - 0.05
        % Note that since "IEA_energy_transition.TFC_change_to_electrification_.." is a negative number, we write "1+.." instead of "1-..".
        % Recall that "IEA_energy_transition.TFC_change_to_electrification_.." captures the percentage TFC reduction arising from a 1 percentage point increase in electrification:
        % this is why we multiply it by the change in electrification.

        share_of_initial_TFC_transport = ...
            1 + ((IEA_energy_transition.Households.electrification_road_transport_2050 - IEA_energy_transition.Households.electrification_road_transport_2022)...
            .* IEA_energy_transition.TFC_change_to_electrification_transport);

        share_of_initial_TFC_buildings = ...
            1 + ((IEA_energy_transition.electrification_buildings_2050 - IEA_energy_transition.electrification_buildings_2022)...
            .* IEA_energy_transition.TFC_change_to_electrification_buildings);


        %%%%%%%%%%%%%   FOSSIL-FUELS PROCESSING   %%%%%%%%%%%%%

        idx_section_ff_processing = find(Parameters.Sections.names == "Fossil fuels processing");

        %%%% 2022 %%%%
        % Total
        ff_processing_total_2022 = Parameters.Households.exiobase_demand_relations_phys(idx_section_ff_processing);
        % Fossil-fuels demand devoted to transport
        ff_processing_road_transport_2022 = ...
            IEA_energy_transition.Households.share_ff_consumption_road_transport_2022 .* ff_processing_total_2022;
        % Fossil-fuels demand devoted to buildings
        ff_processing_buildings_2022 = ...
            IEA_energy_transition.Households.share_ff_consumption_buildings_2022 .* ff_processing_total_2022;        
        
        %%%% 2050 %%%%
        % = (2022 value) * ((fossilization 2050) / (fossilization 2022)) * (share of initial TFC)
        % To understand the formula, see Excel file mentioned above.
        % Fossil-fuels demand devoted to transport        
        ff_processing_road_transport_2050 = ...
            ff_processing_road_transport_2022 ...
            .* (IEA_energy_transition.Households.fossilization_road_transport_2050 ./ IEA_energy_transition.Households.fossilization_road_transport_2022) ...
            .* share_of_initial_TFC_transport;
        % Fossil-fuels demand devoted to buildings
        ff_processing_buildings_2050 = ...
            ff_processing_buildings_2022 ...
            .* (IEA_energy_transition.fossilization_buildings_2050 ./ IEA_energy_transition.fossilization_buildings_2022) ...
            .* share_of_initial_TFC_buildings;
        % Total
        ff_processing_total_2050 = ff_processing_road_transport_2050 + ff_processing_buildings_2050;

        %%%% 2022 - 2050 %%%%
        % Linear interpolation between the 2022 value and the 2050 value                                
        ff_processing_total_2022_2050 = ...
            linspace(ff_processing_total_2022, ff_processing_total_2050, numel(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition));


        
        %%%%%%%%%%%%%   ELECTRICITY   %%%%%%%%%%%%%

        % We sum Electricity production and Electricity transmission together (we'll split it again later on)       

        %%%% 2022 %%%%
        % Total
        electricity_total_2022 = sum(Parameters.Households.exiobase_demand_relations_phys(Parameters.Sections.idx_electricity_producing_and_transmitting));
        % Electricity demand devoted to transport
        electricity_transport_2022 = ...
            IEA_energy_transition.Households.share_electricity_consumption_road_transport_2022 .* electricity_total_2022;
        % Electricity demand devoted to buildings
        electricity_buildings_2022 = ...
            IEA_energy_transition.Households.share_electricity_consumption_buildings_2022 .* electricity_total_2022;

        %%%% 2050 %%%%
        % = (2022 value) * ((electrification 2050) / (electrification 2022)) * (share of initial TFC)
        % To understand the formula, see Excel file mentioned above.
        % Electricity demand devoted to transport
        electricity_transport_2050 = ...
            electricity_transport_2022 ...
            .* (IEA_energy_transition.Households.electrification_road_transport_2050 ./ IEA_energy_transition.Households.electrification_road_transport_2022) ...
            .* share_of_initial_TFC_transport;
        % Electricity demand devoted to buildings
        electricity_buildings_2050 = ...
            electricity_buildings_2022 ...
            .* (IEA_energy_transition.electrification_buildings_2050 ./ IEA_energy_transition.electrification_buildings_2022) ...
            .* share_of_initial_TFC_buildings;
        % Total
        electricity_total_2050 = electricity_transport_2050 + electricity_buildings_2050;

        %%%% 2022 - 2050 %%%%
        % Linear interpolation between the 2022 value and the 2050 value
        electricity_total_2022_2050 = ...
            linspace(electricity_total_2022, electricity_total_2050, numel(Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition));

        % Share of Electricity transmission in (Electricity transmission + Electricity production)
        share_of_transmission_in_total = ...
            Parameters.Households.exiobase_demand_relations_phys(find(Parameters.Sections.names == "Electricity transmission")) ./ electricity_total_2022;
        

        
        %%%%%%%%%%%%%   ASSIGN ABOVE VALUES TO THE HOUSEHOLD'S DEMAND RELATIONS ARRAY   %%%%%%%%%%%%%

        if energy_transition_rule == "NT" || contains(energy_transition_rule, "partial")

            % In these cases, demand relations don't change

            Parameters.Households.demand_relations_phys_evolving = ...
                repmat(Parameters.Households.exiobase_demand_relations_phys, 1, Parameters.T);

        else

            % Create the empty array
            Parameters.Households.demand_relations_phys_evolving = NaN * ones(Parameters.Sections.nr, Parameters.T);

            % Keep constant the values in the rows referring to non-electricity, non-fossil-fuels Sections
            Parameters.Households.demand_relations_phys_evolving(Parameters.Sections.idx_not_electricity_not_fossil_fuels, :) = ...
                repmat(Parameters.Households.exiobase_demand_relations_phys(Parameters.Sections.idx_not_electricity_not_fossil_fuels), 1, Parameters.T);
            % Fossil-fuels extraction
                % recall that for simplicity we don't apply any changes to "Fossil fuels extraction" because its importance in the hhs consumption is very limited.
            Parameters.Households.demand_relations_phys_evolving(find(Parameters.Sections.names == "Fossil fuels extraction"), :) = ...
                repmat(Parameters.Households.exiobase_demand_relations_phys(find(Parameters.Sections.names == "Fossil fuels extraction")), 1, Parameters.T);
    
            % FOSSIL-FUELS PROCESSING
            % Assign values in the period before 2022
            Parameters.Households.demand_relations_phys_evolving(idx_section_ff_processing, 1 : (Parameters.time_step_corresponding_to_2022 - 1)) = ...
                ff_processing_total_2022_2050(1);
            % Assign values in the period interval from 2022 until the end of the energy transition
            Parameters.Households.demand_relations_phys_evolving(idx_section_ff_processing, Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition) = ...
                ff_processing_total_2022_2050;
            % Assign values in the period from the end of the energy transition until the end of the simulation
            Parameters.Households.demand_relations_phys_evolving(idx_section_ff_processing, (Parameters.end_of_energy_transition + 1) : end) = ...
                ff_processing_total_2022_2050(end);
    
            % ELECTRICITY TRANSMISSION
            % Index
            idx_section = find(Parameters.Sections.names == "Electricity transmission");
            % Assign values in the period before 2022
            Parameters.Households.demand_relations_phys_evolving(idx_section, 1 : (Parameters.time_step_corresponding_to_2022 - 1)) = ...
                share_of_transmission_in_total .* electricity_total_2022_2050(1);
            % Assign values in the period interval from 2022 until the end of the energy transition
            Parameters.Households.demand_relations_phys_evolving(idx_section, Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition) = ...
                share_of_transmission_in_total .* electricity_total_2022_2050;
            % Assign values in the period from the end of the energy transition until the end of the simulation
            Parameters.Households.demand_relations_phys_evolving(idx_section, (Parameters.end_of_energy_transition + 1) : end) = ...
                share_of_transmission_in_total .* electricity_total_2022_2050(end);
    
            % ELECTRICITY PRODUCTION
            % Index
            idx_section = find(Parameters.Sections.names == "Electricity");
            % Assign values in the period before 2022
            Parameters.Households.demand_relations_phys_evolving(idx_section, 1 : (Parameters.time_step_corresponding_to_2022 - 1)) = ...
                (1 - share_of_transmission_in_total) .* electricity_total_2022_2050(1);
            % Assign values in the period interval from 2022 until the end of the energy transition
            Parameters.Households.demand_relations_phys_evolving(idx_section, Parameters.time_step_corresponding_to_2022 : Parameters.end_of_energy_transition) = ...
                (1 - share_of_transmission_in_total) .* electricity_total_2022_2050;
            % Assign values in the period from the end of the energy transition until the end of the simulation
            Parameters.Households.demand_relations_phys_evolving(idx_section, (Parameters.end_of_energy_transition + 1) : end) = ...
                (1 - share_of_transmission_in_total) .* electricity_total_2022_2050(end);

        end


        %% current demand
        
        % We assume that each household, given its final demand budget, will allocate it across the goods..
        % ..in such a way as to ensure that the physical relations/proportions across the goods follow the ones defined in "Parameters.Households.demand_relations_phys_evolving".
        % The reasoning is as follows:
        % from Exiobase we have computed the nominal amounts that hhs consume of each good;
        % given our assumed initial prices, those amounts can be converted to physical amounts..
        % ..that we have stored in "Parameters.Households.exiobase_demand_relations_phys";
        % thus, say we find from Exiobase that hhs' consumption consist of 2 apples (A) and 3 bananas (B);
        % then, across the simulation of the model, we ensure that hhs demand z*2*A and z*3*B (where z is a rescaling value) such that:
                    % z*2*A*p_A + z*3*B*p_B = budget   -->   
                    % z = budget / (2*A*p_A + 3*B*p_B)    
        % .. where p_A and p_B are the prices of the two goods.
        % So e.g. in time step t>1, if we find that, given the budget and the prices, z = 1.5 --> the hh will demand 3 apples and 4.5 bananas.
        % Note that z can also be interpreted as the units of the consumption basket demanded by the household.
        
    
        % PHYSICAL DEMAND
        % We set hhs' initial physical demand to be equal to "Parameters.Households.exiobase_demand_relations_phys"
        % i.e. to be equal to the physical value of consumption derived by dividing..
        % ..the nominal value of consumption (as computed from Exiobase) by the assumed initial prices.
        % Of course if the hhs are more than 1, we spread the values contained in "Parameters.Households.exiobase_demand_relations_phys" equally across the hhs.
        Sections.demand_from_hhs_phys(:,:,t) = ...
            repmat(Parameters.Households.demand_relations_phys_evolving(:,t), 1, Parameters.Households.nr) ./ Parameters.Households.nr;
    
        % NOMINAL DEMAND
        % = physical demand * prices
        % By construction, at t=1 this is equal to the nominal demand computed from Exiobase.
        Sections.demand_from_hhs_nominal(:,:,t) = ...
            Sections.demand_from_hhs_phys(:,:,t) .* Sections.prices(t,:)';        


        %% income, net worth, deposits
    
        % INCOME AND NET WORTH IMPLIED BY NOMINAL DEMAND
    
        % Given nominal demand, we can now derive the implied initial hhs' income and net worth (which equals deposits) that would be consistent with that demand.
        % Indeed, our consumption budget formula reads:
            % ConsumptionBudget = MPC_I * Income + MPC_NW * NetWorth
        % If we set an initial NetWorth_To_Income_Ratio, then:
            % ConsumptionBudget = MPC_I * Income + MPC_NW * (NetWorth_To_Income_Ratio * Income)
            %                   = Income * (MPC_I + MPC_NW * NetWorth_To_Income_Ratio)
            % Income = ConsumptionBudget / (MPC_I + MPC_NW * NetWorth_To_Income_Ratio)
            %        = TotalNominalDemand / (MPC_I + MPC_NW * NetWorth_To_Income_Ratio)
    
        % Let's thus assume an initial NetWorth_To_Income_Ratio
        initial_net_worth_to_income_ratio = 6; %5;
    
        % INCOME
        Households.income(t,:) = ...
            sum(Sections.demand_from_hhs_nominal(:,:,t)) ./ ...
            (Parameters.Households.MPC_income + Parameters.Households.MPC_wealth * initial_net_worth_to_income_ratio);
        
        % NET WORTH
        Households.net_worth(t,:) = initial_net_worth_to_income_ratio * Households.income(t,:);
    
        % DEPOSITS
        Households.deposits(t,:) = Households.net_worth(t,:);    
    
        % FINAL DEMAND BUDGET
        % by construction, for each hh this must be equal to the sum of its nominal demands
        Households.final_demand_budget(t,:) = ... 
            Parameters.Households.MPC_income * Households.income(t,:) + ... 
            Parameters.Households.MPC_wealth * Households.net_worth(t,:);


    %% government
        %% physical demand relations
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%  GOVERNMENT'S PHYSICAL DEMAND RELATIONS  %%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % We assume that the gov't will demand the goods..
        % ..in such a way as to ensure that the physical relations among the goods are kept constant.
        % For example, if the physical relations of its final demand in the initial period consist of 2 apples and 3 cars..
        % .. in a subsequent period its demand may be 4 apples and 6 cars (4/6 = 2/3).
                    
        % From Exiobase we have computed the nominal amounts that the gov't consumes of each good;
        % given our assumed initial prices, those amounts can be converted to physical amounts:
                % Parameters.Government.exiobase_demand_relations_phys = NominalConsumptionExiobase / InitialPrices            
        
        % NO ELECTRIFICATION
        % We assume that the gov't doesn't change its final demand composition during the energy transition.
        % Indeed, if you look at the gov't demand proportions derived from Exiobase, you can see that the weight of fossil-fuels and electricity in the gov't demand is insignificant.
        % If instead you wished to undertake electrification/defossilization in the gov't demand, you'll need to find data: so far I haven't found anything in the IEA reports.

    
        % Create empty gov't consumption vector
        govt_consumption_nominal = NaN * ones(Parameters.Sections.nr, 1);
        
        % Filling the gov't consumption vector
        for j = 1 : Parameters.Sections.nr
            % Index of the rows in the Exiobase technical coefficients table that refer to section j
            idx_table_row = strcmp(table_final_demand.SectionsNames, Parameters.Sections.names(j));                                      
            % Fill the gov't consumption vector
            govt_consumption_nominal(j) = table_final_demand.FinalConsumptionExpenditureByGovernment(idx_table_row);
        end

        % AGGREGATING FOSSIL-FUELS
        % The gov't consumes very few fossil-fuels from the "Fossil fuels processing" Section, and even less from the "Fossil fuels extraction" Section.
        % To compute the emission intensity of the gov't, i.e. the amount of emissions per unit of fossil-fuels consumed, ..
        % ..we would have to sum the two fossil-fuels sections together. However, that cannot be done because they aren't expressed in the same units.
        % Therefore, to make things easier, and since the gov't demand from the "Fossil fuels extraction" Section is neglegible, we simply transfer it to the..
        % .."Fossil fuels processing" Section.
        if any(ismember(Parameters.Sections.names(Parameters.Sections.idx_demand_set_to_zero), "Fossil fuels extraction"))
            idx_ff_processing = Parameters.Sections.names == "Fossil fuels processing";
            idx_ff_extraction = Parameters.Sections.names == "Fossil fuels extraction";
            govt_consumption_nominal(idx_ff_processing) = ...
                govt_consumption_nominal(idx_ff_processing) + govt_consumption_nominal(idx_ff_extraction);
            govt_consumption_nominal(idx_ff_extraction) = 0;   
        end


        % PHYSICAL DEMAND RELATIONS
        Parameters.Government.exiobase_demand_relations_phys = govt_consumption_nominal ./ Sections.prices(t,:)';

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        % PERCENTAGE OF TOTAL NOMINAL FINAL DEMAND COVERED BY GOV'T CONSUMPTION
        % i.e. the share of gov't consumption in GDP
        % Index of the table column that we want to exclude from the sum
        if Rules.govt_demand == "yes - constant share of GDP"
            idx_table_column = strcmp(table_final_demand.Properties.VariableNames, "SectionsNames");
            Parameters.Government.share_of_GDP = ...
                sum(govt_consumption_nominal) ./ sum(table_final_demand{:, ~idx_table_column}, "all");
        end
        
  
        % PHYSICAL DEMAND
        % We set gov't initial physical demand to be equal to "Parameters.Government.exiobase_demand_relations_phys"
        % We assume that this initial demand holds at t=1 and also t=2 (since gov't demand in each period depends on previous period orders).                         
        if Rules.govt_demand == "no"
            Sections.demand_in1year_from_govt_phys(:,t) = zeros(Parameters.Sections.nr, 1);            
        else
            Sections.demand_in1year_from_govt_phys(:,t) = Parameters.Government.exiobase_demand_relations_phys;
        end
                    
    
        % NOMINAL DEMAND
        % = physical demand * prices
        % By construction, at t=1 this is equal to the nominal demand computed from Exiobase.
        Sections.current_demand_from_govt_nominal(:,t) = ...
            Sections.demand_in1year_from_govt_phys(:,t) .* Sections.prices(t,:)';


    %% EXOGENOUS CHANGES TO COEFFICIENTS

    % We could have actually put the following chunk of code in the simulation file, but it is better to put it here, ..
    % ..because in the simulation file we sometimes need the following variables' values at time t+2.

    for time = 2 : Parameters.T        

        %%%%%%%%  TECHNICAL COEFFICIENTS  %%%%%%%%
        
        % Keep constant the coefficients in the rows referring to non-electricity, non-fossil-fuels Sections
        Divisions.C_rectangular(Parameters.Sections.idx_not_electricity_not_fossil_fuels, :, time) = ...
            Divisions.C_rectangular(Parameters.Sections.idx_not_electricity_not_fossil_fuels, :, 1);
        
        % Share of initial TFC reached through current electricification level
            % recall that substituting fossil-fuels with electricity (i.e. increasing the electrification) leads to some TFC reduction because electricity is generally more efficient.
            % Example: if electrification has increased by 1 percentage point and this leads to a TFC reduction of 0.5 percentage points, then:
            % (share_of_initial_TFC) = 100% - 0.5% = 99.5% = 1 - 0.005
            % Note that since "Parameters.Divisions.TFC_change_to_electrification" is a negative number, we write "1+.." instead of "1-..".
            % Recall that "Parameters.Divisions.TFC_change_to_electrification" captures the percentage TFC reduction arising from a 1 percentage point increase in electrification:
            % this is why we multiply it by the change in electrification.
        Divisions.share_of_initial_TFC(time, :) = ...
            1 + ((Parameters.Divisions.electrification(time, :) - Parameters.Divisions.electrification(1,:)) .* Parameters.Divisions.TFC_change_to_electrification);
        
        % Change the coefficients in the rows referring to fossil-fuels Sections
        Divisions.C_rectangular(Parameters.Sections.idx_fossil_fuels, :, time) = ...
            Divisions.C_rectangular(Parameters.Sections.idx_fossil_fuels, :, 1) ...
            .* Parameters.Divisions.fossilization(time, :) ./ Parameters.Divisions.fossilization(1,:) ...
            .* Divisions.share_of_initial_TFC(time, :);
        
        % Change the coefficients in the rows referring to electricity Sections
        Divisions.C_rectangular(Parameters.Sections.idx_electricity_producing_and_transmitting, :, time) = ...
            Divisions.C_rectangular(Parameters.Sections.idx_electricity_producing_and_transmitting, :, 1) ...
            .* Parameters.Divisions.electrification(time, :) ./ Parameters.Divisions.electrification(1,:) ...
            .* Divisions.share_of_initial_TFC(time, :);

        % EXERCISE: EXOGENOUS SHOCK
        % Let's see what happens if we permanently shock technical coefficients by increasing/decreasing their values.
        % We apply the shock in a time step when we have already reached an equilibrium path.
        % if time >= 100
        %     % idx = Parameters.Divisions.names == "Public";     % in case you want to apply the shock to a specific Section or Division
        %     Divisions.C_rectangular(:,:,time) = 1.1 * Divisions.C_rectangular(:,:,time);
        % end
    
        
        %%%%%%%%  EMISSION INTENSITIES  %%%%%%%%
        Divisions.emission_intensities(time, :) = ...
            Divisions.emission_intensities(1,:) ...
            .* Parameters.Divisions.carbonization(time, :) ./ Parameters.Divisions.carbonization(1,:) ...
            .* Divisions.share_of_initial_TFC(time, :);
        
    
    
        %%%%%%%%  COEFFICIENTS DEVELOPMENT CHECKS  %%%%%%%%
    
        % We compute some ratios to check that the exogenous changes have been performed correctly.
        % You can plot the following variables and intuitively check if the exogenous changes have been performed correctly (see file "Triode_g1_fig_1").
    
        % DIVISIONS    
        % Technical coefficients
        Divisions.C_rectangular_percentage_change(:, :, time) = ...
            (Divisions.C_rectangular(:, :, time) - Divisions.C_rectangular(:,:,1)) ...
            ./ Divisions.C_rectangular(:,:,1);    
        % Emissions intensities
        Divisions.emission_intensities_percentage_change(time, :) = ...
            (Divisions.emission_intensities(time, :) - Divisions.emission_intensities(1,:)) ...
            ./ Divisions.emission_intensities(1,:);
    
        % HOUSEHOLDS    
        Households.demand_relations_phys_percentage_change(:, time) = ...
            (Parameters.Households.demand_relations_phys_evolving(:, time) - Parameters.Households.demand_relations_phys_evolving(:,1)) ...    
            ./ Parameters.Households.demand_relations_phys_evolving(:,1);                
    
    
        % TESTS
        if any(Divisions.C_rectangular(:, :, time) < 0, 'all')
            error('At time step %d, there is at least one negative value in ''Divisions.C_rectangular''', time)
        end
        if any(Divisions.emission_intensities(time, :) < 0, 'all')
            error('At time step %d, there is at least one negative value in ''Divisions.emission_intensities''', time)
        end
        if any(Parameters.Households.demand_relations_phys_evolving(:, time) < 0, 'all')
            error('At time step %d, there is at least one negative value in ''Parameters.Households.demand_relations_phys_evolving''', time)
        end

    end

    clear time          

    %% actual and expected final demand (physical)

    Sections.final_demand_phys(:,t) = ...
        sum(Sections.demand_from_hhs_phys(:,:,t), 2) ...
        + Sections.demand_in1year_from_govt_phys(:,t) ...
        + sum(sections_demand_in1year_from_invest_divisions_desired_phys, 2);

    Sections.final_demand_phys_exp(:,t) = ...
        Sections.final_demand_phys(:,t);            

    
    %% sectors/2
        %% Triode's core function


        % DIVISIONS VS SECTORS / GENERAL DESCRIPTION OF THE WHOLE BELOW PROCESS
        % Note that our function "Triode_Production" works at the Sectors' (not Divisions') level, because we have substitutability between green and brown electricity Sectors.
        % Therefore, all arrays that are used as inputs to the function must be defined at the Sectors' (not Divisions') level.
        % The most crucial inputs to the function are: 
            % (A) the Sectors' max production; 
            % (B) the rectangular sections-by-sectors technical coefficients matrix.
        % To compute (A) and (B), we first need to define the weights that Green and Brown Divisions have in the Green and Brown Sectors, respectively, ..
        % .. so that divisional arrays can be transformed into sectoral arrays.
        % For the Green Divisions, we define their weights within the Green Sector as those arising when each of them produces at its maximum production capacity.
        % The resulting weights will likely be very close to the target weights because the Green Divisions have invested by having those target weights in mind.
        % For the Brown Divisions, instead, we cannot do so because the resulting weights would likely be quite different from the target weights, ..
        % ..since Brown Divisions may not even be investing. 
        % Therefore, we first define the Brown Divisions' weights as being the target ones, implying that there may be some unutilized production capacity in some brown Division.
        % We then compute (A) and (B), and use them as inputs in "Triode_Production", and let the function yield its outputs.
        % We then check whether the Brown Sector is producing close to its maximum production (A) or not:
        % if not, we proceed; 
        % if yes, that means that the Brown Sector would like to produce more if it could; 
            % we thus redefine the Divisions' weights within the Brown Sector as those arising when each of them produces at its maximum production capacity.
            % We then compute (A) and (B), and use them as inputs in "Triode_Production", and let the function yield its outputs.        
    
    
        % DIVISIONS' PRODUCTION CAPACITIES
        % max real (physical) possible production given constraints from capital:
        % it is a Leontief production function, where the production factors are the different capital assets held by each division.
        % I.e., the max production of each Division is the minimum value among the values obtained multiplying capital productivities with the respective capital assets.
        % First, for each Division, we compute the max amount each of its capital assets is able to produce..        
        Divisions.prod_cap_of_each_capital_asset(:,:,t) = ...
            Divisions.capital_productivity(:,:,t) .* divisions_initial_capital_phys;
        % ..Then, we pick the minimum among those values (Leontief production function)
        % Note: several rows in "Divisions.prod_cap_of_each_capital_asset" are full of zeros, since not every commodity is used as a capital asset. 
        % Thus, if we would simply tell Matlab to select the minimum values, those would be zeros. Thus, we consider only non-zero values when finding the minimum.        
        for i = 1 : Parameters.Divisions.nr
            Divisions.prod_cap(i,t) = ...
                min(Divisions.prod_cap_of_each_capital_asset(Parameters.Divisions.capital_assets_logical_matrix(:,i), i, t));
        end
           
        % SECTORS' PRODUCTION CAPACITIES
        % (see also description above)
        % For the green sector: it is the max production arising when combining its Divisions, allowing all of them to produce at their max levels.
        % For the brown sector: it is the max production arising when combining its Divisions according to the target weights.
            % This means that there may be some unutilized production capacity in some brown Division.    
        for i = 1 : Parameters.Sectors.nr
            
            % For the Brown sector
            if i == Parameters.Sectors.idx_brown
                % The following function computes the max production of the brown sector as defined above.
                [Sectors.prod_cap(i,t)] = ...
                    Brown_sector_max_production_adj...
                    (Divisions.prod_cap(Parameters.Divisions.idx_brown, t), Parameters.Divisions.target_sectoral_weights(t, Parameters.Divisions.idx_brown));
            
            % For the Green sector (and all the others)
            else
                idx_divisions_belonging_to_sector_i = find(Parameters.Divisions.sector_idx == i);
                Sectors.prod_cap(i,t) = ...
                    sum(Divisions.prod_cap(idx_divisions_belonging_to_sector_i, t));
            end
        end
    
    
        % DIVISIONS' SECTORAL WEIGHTS
        % For the Brown Divisions: it is the target weights.
        % For the Green Divisions: it is the weights given by their maximum production.
        for j = 1 : Parameters.Divisions.nr
            % For the Brown Divisions
            if ismember(j, Parameters.Divisions.idx_brown)            
                Divisions.sectoral_weights(t,j) = ...
                    Parameters.Divisions.target_sectoral_weights(t,j);
            % For the Green Divisions
            else
                Divisions.sectoral_weights(t,j) = ...
                    Divisions.prod_cap(j,t) ./ Sectors.prod_cap(Parameters.Divisions.sector_idx(j), t);
            end
        end
        % TEST
        % Weights must sum to 1.
        aggregating_weights_test = NaN * ones(1, Parameters.Sectors.nr);
        for i = 1 : Parameters.Sectors.nr
            idx_divisions_belonging_to_sector_i = find(Parameters.Divisions.sector_idx == i);
            aggregating_weights_test(i) = ...
                sum(Divisions.sectoral_weights(t, idx_divisions_belonging_to_sector_i), 2);
        end
        if any(abs(1 - aggregating_weights_test) > Parameters.error_tolerance_strong, 'all')
            error('At time step %d, the sum across weights in the electricity sectors does not equal 1', t)
        end
    
    
        % SECTORS' RECTANGULAR TECHNICAL COEFFICIENTS MATRIX
        for i = 1 : Parameters.Sectors.nr
            idx_divisions_belonging_to_sector_i = find(Parameters.Divisions.sector_idx == i);
            Sectors.C_rectangular(:,i,t) = ...
                sum(Divisions.sectoral_weights(t, idx_divisions_belonging_to_sector_i) .* Divisions.C_rectangular(:, idx_divisions_belonging_to_sector_i, t), 2);
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%   FUNCTION   %%%%%%%%%%%%%%%%%%%
        
        % DESCRIPTION
        % The below function "Triode_Production" deals with: 
            % (1) Production constraints in any sector, using two alternative methods:
                    % (A) Strict proportional rationing: the rationing is applied equally to all customers (intermediate custormers and final demand customers).
                    % (B) Mixed model methodology: intermediate sales are prioritized over final demand sales. See Chapter 13.2.1 in Miller and Blair (2009).
            % (2) Substitutability between green & brown electricity, with grid priority for the green sector.
        
        % OUTPUTS OF THE FUNCTION
        % The square (sectoral) technical coefficients matrix
        % The green share in electricity production
        % Sectors' products available for sale to final demand
        % Sectors' actual production
        % Sectors' desired level of production
            % What are its values? 
            % In an economy without the green/brown electricity distinction: it simply is the sectors' production that would arise as a consequence of the expected final demand vector, assuming that there were no production constraints in any sectors.
            % In an economy with the green/brown electricity distinction:
                % for all the sectors except the green one, it is the production implied by the expected final demand vector, without considering their constraints, but by considering the constraint of the green sector (i.e. the green sector is providing all the required electricity it can supply, but not more that its production limit).
                % for the green sector, it is the production implied by the expected final demand vector, without considering any constraint in any sector, assuming that the green share is equal to the target green share in the current year.
        % Sectors' production constraints
            % In an economy without the green/brown electricity distinction: it is the constraints implied by the sectors' desired level of production, i.e. = (max production) / (desired production).
            % In an economy with the green/brown electricity distinction: 
                % for all the sectors except the green one, it is the constraints implied by the sectors' desired level of production, i.e. = (max production) / (desired production).
                % for the green sector, it simply is 100% (meaning no constraint).
        % Sections' production constraints
            % It simply is the sectional version of the sectors' production constraints.                
        
        [Sectors.C_square(:,:,t), Economy.green_share_production(t), Sectors.products_available_for_final_demand_phys(:,t),...
            Sectors.production_phys(:,t), Sectors.production_unbound_minus_inventories_phys(:,t)] = ...
                Triode_Production ... % name of the function
                    (Rules.target_green_share_enforcement, Rules.rationing, Parameters.Sectors.idx, Parameters.Sectors.section_idx, ...
                    Parameters.Sections.idx_electricity_producing, Parameters.Sectors.idx_green, Parameters.Sectors.idx_brown, Sectors.C_rectangular(:,:,t), ...
                    Sections.final_demand_phys_exp(:,t), Sectors.prod_cap(:,t), ...
                    initial_inventories_phys, Parameters.Sectors.target_green_share(t)); % NOTE: here in the file initialization we have to set "initial_inventories_phys" and not "Sectors.inventories_phys(:,t-1)" as in the Simulation file
            
        % BROWN DIVISIONS WEIGHTING
        % Keeping track of which weighting procedure we are using for the brown electricity Divisions
        Economy.brown_divisions_weighting_for_Triode_Production_function(t) = "target weights";


        % If the Brown Sector is producing at its maximum production..
        % ..then we have to redifine some stuff and re-run the function: see description above ("DIVISIONS VS SECTORS / GENERAL DESCRIPTION OF THE WHOLE BELOW PROCESS").
        if (Sectors.production_phys(Parameters.Sectors.idx_brown, t) / Sectors.prod_cap(Parameters.Sectors.idx_brown, t)) > 0.95      
        
            % BROWN DIVISIONS WEIGHTING
            % Keeping track of which weighting procedure we are using for the brown electricity Divisions
            Economy.brown_divisions_weighting_for_Triode_Production_function(t) = "weights implied by production capacities";

            % SECTORS' PRODUCTION CAPACITIES
            for i = 1 : Parameters.Sectors.nr            
                idx_divisions_belonging_to_sector_i = find(Parameters.Divisions.sector_idx == i);
                Sectors.prod_cap(i,t) = ...
                    sum(Divisions.prod_cap(idx_divisions_belonging_to_sector_i, t));
            end
    
            % DIVISIONS' SECTORAL WEIGHTS
            for j = 1 : Parameters.Divisions.nr
                Divisions.sectoral_weights(t,j) = ...
                    Divisions.prod_cap(j,t) ./ Sectors.prod_cap(Parameters.Divisions.sector_idx(j), t);
            end
            % TEST
            % Weights must sum to 1.
            aggregating_weights_test = NaN * ones(1, Parameters.Sectors.nr);
            for i = 1 : Parameters.Sectors.nr
                idx_divisions_belonging_to_sector_i = find(Parameters.Divisions.sector_idx == i);
                aggregating_weights_test(i) = ...
                    sum(Divisions.sectoral_weights(t, idx_divisions_belonging_to_sector_i), 2);
            end
            if any(abs(1 - aggregating_weights_test) > Parameters.error_tolerance_strong, 'all')
                error('At time step %d, the sum across weights in the electricity sectors does not equal 1', t)
            end    
        
            % SECTORS' RECTANGULAR TECHNICAL COEFFICIENTS MATRIX
            for i = 1 : Parameters.Sectors.nr
                idx_divisions_belonging_to_sector_i = find(Parameters.Divisions.sector_idx == i);
                Sectors.C_rectangular(:,i,t) = ...
                    sum(Divisions.sectoral_weights(t, idx_divisions_belonging_to_sector_i) .* Divisions.C_rectangular(:, idx_divisions_belonging_to_sector_i, t), 2);
            end
    
            [Sectors.C_square(:,:,t), Economy.green_share_production(t), Sectors.products_available_for_final_demand_phys(:,t),...
            Sectors.production_phys(:,t), Sectors.production_unbound_minus_inventories_phys(:,t)] = ...
                Triode_Production ... % name of the function
                    (Rules.target_green_share_enforcement, Rules.rationing, Parameters.Sectors.idx, Parameters.Sectors.section_idx, ...
                    Parameters.Sections.idx_electricity_producing, Parameters.Sectors.idx_green, Parameters.Sectors.idx_brown, Sectors.C_rectangular(:,:,t), ...
                    Sections.final_demand_phys_exp(:,t), Sectors.prod_cap(:,t), ...
                    initial_inventories_phys, Parameters.Sectors.target_green_share(t)); % NOTE: here in the file initialization we have to set "initial_inventories_phys" and not "Sectors.inventories_phys(:,t-1)" as in the Simulation file

        end

        %%%%%%%%%%%%%%%   END OF THE FUNCTION   %%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        
        % SECTORS' PRODUCTION CONSTRAINTS
        Sectors.production_constraints(:,t) = ...
            Sectors.prod_cap(:,t) ./ Sectors.production_unbound_minus_inventories_phys(:,t);
        
        % SECTIONS' PRODUCTION CONSTRAINTS
        for i = 1 : Parameters.Sections.nr
            idx = Parameters.Sectors.section_idx == i;
            Sections.production_constraints(i,t) = ...
                sum(Sectors.prod_cap(idx, t)) ./ sum(Sectors.production_unbound_minus_inventories_phys(idx, t));
        end


        %% allocating the function's outputs


        % DIVISIONS' PRODUCTION
        for j = 1 : Parameters.Divisions.nr            
            Divisions.production_phys(j,t) = ...
                Divisions.sectoral_weights(t,j) .* Sectors.production_phys(Parameters.Divisions.sector_idx(j), t);
        end


        % SECTIONS' PRODUCTION
        aggregation_rule = "values of sectors belonging to the same section get summed";
        Sections.production_phys(:,t) = ...
            From_Sectors_To_Sections_Function(aggregation_rule, Sectors.production_phys(:,t), Parameters.Sectors.section_idx); 
        clear aggregation_rule
    
    
        % DIVISIONS' SECTIONAL WEIGHTS
        for j = 1 : Parameters.Divisions.nr
            Divisions.sectional_weights(t,j) = ...
                Divisions.production_phys(j,t) ./ Sections.production_phys(Parameters.Divisions.section_idx(j), t);
        end
        

        % DIVISIONS' CAPACITY UTILIZATION
        % Each Division has a capacity utilization value for each of its capital assets j.
        % = (used j-th capital asset) / (tot j-th capital asset)
        % = (used j-th capital asset * productivity) / (tot j-th capital asset * productivity)
        % = actual production / production limit
        for i = 1 : Parameters.Divisions.nr
            for j = 1 : Parameters.Sections.nr
                if ismember(j, find(Parameters.Divisions.capital_assets_logical_matrix(:,i)))
                    if Divisions.prod_cap_of_each_capital_asset(j,i,t) ~= 0
                        Divisions.capacity_utilization_of_each_asset(j,i,t) = ...
                            Divisions.production_phys(i,t) ./ Divisions.prod_cap_of_each_capital_asset(j,i,t);
                    else
                        Divisions.capacity_utilization_of_each_asset(j,i,t) = 0;
                    end
                else
                    Divisions.capacity_utilization_of_each_asset(j,i,t) = 0;
                end
            end
        end


        % DIVISIONS' HIGHEST VALUE OF CAPACITY UTILIZATION
        % For each Division, we store the highest capacity utilization value among its assets.
        Divisions.capacity_utilization_highest_value(t,:) = ...
            max(Divisions.capacity_utilization_of_each_asset(:,:,t));
    
            
        % DIVISIONS' REAL (PHYSICAL) CAPITAL DEPRECIATION
        % In the initial period, we assume that the entire capital stock is affected by depreciation, whatever the "Rules.depreciation" actually is.
        % This seems to stabilize the initial fluctuations.
        divisions_capital_depreciation_phys = ...
            Parameters.Divisions.depreciation_rates .* divisions_initial_capital_phys;        
        % Sectoral level
        sectors_capital_depreciation_phys = NaN * ones(Parameters.Sections.nr, Parameters.Sectors.nr);
        for i = 1 : Parameters.Sectors.nr
            idx_divisions_belonging_to_sector_i = find(Parameters.Divisions.sector_idx == i);
            sectors_capital_depreciation_phys(:,i) = ...
                sum(divisions_capital_depreciation_phys(:, idx_divisions_belonging_to_sector_i), 2);
        end       


        % REAL (PHYSICAL) ACTUAL INTERINDUSTRY TRANSACTIONS (of intermediate inputs)
        Sectors.S_square(:,:,t) = ...
            Sectors.C_square(:,:,t) * diag(Sectors.production_phys(:,t)); 
        % This is Eq. 2.42 (inverted) of Miller & Blair (II edition), i.e. C = S*(q^)^-1

                
        % SECTORAL PRODUCTION FOR FINAL DEMAND
        % We need these arrays when computing real GDP
        % This vector will differ from "Sectors.products_available_for_final_demand_phys" when there are inventories!
        % Note that since there are inventories, you cannot simply define this vector as: (production) - (intermediate_sales)
        % ..indeed, the result could even become negative if a sector produced less than intermediate sales because it knew it had sufficient inventories in stock.
        % Instead, you should define it as:
        % = [production(t)] - max{0, [intermediate_sales(t) - inventories(t-1)]}
        % ..which assumes that a sector first sells inventories to intermediate purchasers, and what is then left over of those inventories will then be sold to final demand.
        Sectors.production_for_final_demand_phys(:,t) = ...
            Sectors.production_phys(:,t) - max(0, sum(Sectors.S_square(:,:,t), 2) - initial_inventories_phys); % NOTE: here in the file initialization we have to set "initial_inventories_phys" and not "Sectors.inventories_phys(:,t-1)" as in the Simulation file   
        % Due to some rounding imprecision, it may happen that there are very little (neglegible) negative values. We replace those with 0.
        idx_replacing = all([...
            Sectors.production_for_final_demand_phys(:,t) < 0, ...
            Sectors.production_for_final_demand_phys(:,t) > - Parameters.error_tolerance_medium .* Sectors.production_phys(:,t) ...
            ], 2);
        Sectors.production_for_final_demand_phys(idx_replacing, t) = 0;
        % Test
        if any(Sectors.production_for_final_demand_phys(:,t) < 0, 'all')
            error('At time step %d, there is at least one negative value in ''Sectors.production_for_final_demand_phys''', t)
        end


        % AVAILABLE PRODUCTS AT THE SECTIONAL LEVEL
        aggregation_rule = "values of sectors belonging to the same section get summed";
        Sections.products_available_for_final_demand_phys(:,t) = ...
            From_Sectors_To_Sections_Function(aggregation_rule, Sectors.products_available_for_final_demand_phys(:,t), Parameters.Sectors.section_idx); 
        clear aggregation_rule


        % DIVISIONS' EMISSIONS
        Divisions.emissions_flow(t,:) = Divisions.emission_intensities(t,:) .* Divisions.production_phys(:,t)'; 
        for i = 1 : Parameters.Sectors.nr
            idx_divisions_belonging_to_sector_i = find(Parameters.Divisions.sector_idx == i);
            Sectors.emissions_flow(t,i) = ...
                sum(Divisions.emissions_flow(t, idx_divisions_belonging_to_sector_i), 2);
        end


        % SECTORS' NOMINAL PRODUCTION
        % NOTE: this is just an auxiliary vector. Keep in mind that sectors will sell some of their products (e.g. to investing sectors) at previous year prices.
        Sectors.production_nominal(:,t) = Sectors.production_phys(:,t) .* Sectors.prices(t,:)';
                

        %% mark-up parameters
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  VARIABLE MARKUP  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%              

        % Sectors apply a variable markup, within a range defined by a min and max value.
        
        % Minimum level of mark-up
        Parameters.Divisions.mark_up_min = 1; 
        % Maximum level of mark-up
        Parameters.Divisions.mark_up_max = 1.2;


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  CONSTANT MARKUP  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

        % Price = (1 + markup) * (unit costs)

        % Alternative options:
            % 1. Unit costs don't include capital depreciation, and:
                % A. The markup is set arbitrarily
                % B. The markup is computed from Exiobase
            % 2. Unit costs include capital depreciation (= full-costing methodology), and:
                % A. The markup is set arbitrarily
                % B. The markup is computed from Exiobase



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%  1:  Markup over unit costs that don't include depreciation  %%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%  1.A: ARBITRARY  %%%%%%%%%

        % MARKUP
        markup_arbitrary_without_depreciation = 1;
               

        %%%%%%%%%  1.B: EXIOBASE  %%%%%%%%%                

        % We want to compute the Divisions' markup that is consistent ..
        % ..with the assumed initial prices and the intermediate input unit costs structure as implied by Exiobase.
                
        % price = (1 + markup) * (intermediate inputs unit costs) -->
        % markup = (price) / (intermediate inputs unit costs) - 1

        % Do we already have the prices and the intermediate input unit costs, so that we could already compute the markup?
        % Yes, for all Divisions except the Green electricity Divisions.
        % Indeed, the resulting markup of the Green electricity Divisions would be the one that would yield a price = 1. We don't want this.
        % The price of the Green electricity Divisions is set to be equal to the Brown electricity Divisions as a result of our assumptions on the functioning of the electricity market,
        % but the actual price of the Green electricity Divisions is lower than 1. 
        
        % So, we first derive the "adjusted" price for the Green electricity Divisions as implied by: 
            % (nominal output Exiobase) = (physical output) * (adjusted price)   -->
            % (adjusted price) = (nominal output Exiobase) / (physical output)
        % and then we use this adjusted price to compute the markups.
        % Note that (physical output) may be, depending on the adopted rule:
            % the one derived from Exiobase --> (adjusted price) = 1
            % or the adjusted phys output, from IEA --> (adjusted price) < 1

        % NOTE: MAYBE WE WANT ALSO THE BROWN DIVISIONS' PRICE TO BE THE ADJUSTED ONE, AND NOT = 1 ?
        
        
        % ADJUSTING THE PRICE OF THE GREEN ELECTRICITY DIVISIONS                       
        % Adjusted prices
        divisional_prices_adjusted = (divisions_nominal_output_Exiobase ./ divisions_output_phys)'; % resulting values should be all 1 except for the Green and Brown electricity sectors.
        % Re-setting the price of the Brown electricity Divisions to their initially assumed value.        
        divisional_prices_adjusted(Parameters.Divisions.idx_brown) = Divisions.prices(t, Parameters.Divisions.idx_brown);

        % INTERMEDIATE INPUTS UNIT COSTS AT t=1        
        divisions_intermediate_inputs_unit_costs = Sections.prices(t,:) * Divisions.C_rectangular(:,:,t);        

        % MARKUP
        markup_Exiobase_without_depreciation = ...
            divisional_prices_adjusted ./ divisions_intermediate_inputs_unit_costs - 1;

        % CHECK
        % Prices derived through the markup we just computed should be all equal to 1 except for the green electricity Divisions
        check_prices_without_depreciation = ...
            (1 + markup_Exiobase_without_depreciation) .* divisions_intermediate_inputs_unit_costs;        




        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%  2:  Markup over unit costs that include depreciation  %%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        %%%%%%%%%  2.A: ARBITRARY  %%%%%%%%%

        % MARKUP
        markup_arbitrary_with_depreciation = 0.7;
               

        %%%%%%%%%  2.B: EXIOBASE  %%%%%%%%%       
                
        % price = (1 + markup) * (intermediate inputs unit costs + depreciation unit costs)
        % markup = (price) / (intermediate inputs unit costs + depreciation unit costs) - 1

        % Do we already have all the data to compute the markup?
            % We have the prices, as given by "divisional_prices_adjusted" computed above
            % We have the intermediate inputs unit costs, as computed above
            % We need to have data on depreciation unit costs..
                % ..which we can find in Exiobase, i.e. the value added component called "Operating surplus: Consumption of fixed capital"..
                % ..which we have stored in the Excel file sheet "CFC" (Consumption of Fixed Capital).                

        % DIVISIONS' CONSUMPTION OF FIXED CAPITAL
        table_CFC_Exiobase = readtable(excel_file_Exiobase, 'Sheet', 'CFC', 'VariableNamingRule', 'preserve'); % setting 'VariableNamingRule' to 'preserve' prevents Matlab from renaming the variable names (it would erase blank spaces)
        
        % Store the data contained in "table_CFC_Exiobase" into an array
        divisions_CFC_Exiobase = NaN * ones(1, Parameters.Divisions.nr);
        % Filling the "divisions_CFC_Exiobase" vector
        for i = 1 : Parameters.Divisions.nr
            % Name of Division i
            division_name_i = Parameters.Divisions.names(i);
            % Index of the table column that corresponds to Division i
            idx_division_table_columns = strcmp(table_CFC_Exiobase.Properties.VariableNames, division_name_i);
            % Fill the "divisions_CFC_Exiobase" vector
            divisions_CFC_Exiobase(i) = table_CFC_Exiobase{1, idx_division_table_columns};
        end                    

        % MARKUP        
        markup_Exiobase_with_depreciation = ...
            divisional_prices_adjusted ./ (divisions_intermediate_inputs_unit_costs + divisions_CFC_Exiobase ./ divisions_output_phys') - 1;

        % CHECK
        % Prices derived through the markup we just computed should be all equal to 1 except for the green electricity Sector
        check_prices_with_depreciation = ...
            (1 + markup_Exiobase_with_depreciation) ...
            .* (divisions_intermediate_inputs_unit_costs + (divisions_CFC_Exiobase ./ divisions_output_phys'));        


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%   ASSIGNING VALUES   %%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if Rules.unit_costs == "not including capital depreciation"
            if Rules.markup == "constant: arbitrary"                
                Parameters.Divisions.constant_mark_up = markup_arbitrary_without_depreciation;
            elseif Rules.markup == "constant: Exiobase"                
                Parameters.Divisions.constant_mark_up = markup_Exiobase_without_depreciation;
            end
        elseif Rules.unit_costs == "including capital depreciation"
            if Rules.markup == "constant: arbitrary"                
                Parameters.Divisions.constant_mark_up = markup_arbitrary_with_depreciation;
            elseif Rules.markup == "constant: Exiobase"                
                Parameters.Divisions.constant_mark_up = markup_Exiobase_with_depreciation;
            end
        end

        
        %% unit costs


        % NOMINAL CAPITAL DEPRECIATION
        % is valued at replacement cost        
        Sectors.capital_depreciation_nominal(t,:) = ...
            sum(sectors_capital_depreciation_phys .* Sections.prices(t,:)');
        Divisions.capital_depreciation_nominal(t,:) = ...
            sum(divisions_capital_depreciation_phys .* Sections.prices(t,:)');


        %%%%%%%%%  UNIT COSTS  %%%%%%%%%
        
        % we allow for two different unit cost measures:
            % = (intermediate input unit costs) + (nominal capital depreciation per unit of products)
            % = (intermediate input unit costs)
        % We assume that sectors trade interindustry inputs at previous period prices.
        
        % Intermediate inputs unit costs        
        Divisions.intermediate_inputs_unit_costs(t,:) = ...
            Sections.prices(t,:) * Divisions.C_rectangular(:,:,t);

        % Capital depreciation unit costs
        Divisions.capital_depreciation_unit_costs(t,:) = ...
            Divisions.capital_depreciation_nominal(t,:) ./ Divisions.production_phys(:,t)'; 
        
        % Total unit costs
        if Rules.unit_costs == "including capital depreciation"                                                           
            Divisions.unit_costs(t,:) = ...
                Divisions.intermediate_inputs_unit_costs(t,:) + Divisions.capital_depreciation_unit_costs(t,:);        
        elseif Rules.unit_costs == "not including capital depreciation"                                           
            Divisions.unit_costs(t,:) = ...
                Divisions.intermediate_inputs_unit_costs(t,:);
        end


        % SECTORS' UNIT COSTS    
        for j = 1 : Parameters.Sectors.nr  
            % Index
            idx = Parameters.Divisions.sector_idx == j;
            % Capital depreciation unit costs
            Sectors.capital_depreciation_unit_costs(t,j) = ...
                sum(Divisions.capital_depreciation_unit_costs(t, idx) .* Divisions.sectoral_weights(t, idx));
            % Intermediate inputs unit costs
            Sectors.intermediate_inputs_unit_costs(t,j) = ...
                sum(Divisions.intermediate_inputs_unit_costs(t, idx) .* Divisions.sectoral_weights(t, idx));
            % Total unit costs
            Sectors.unit_costs(t,j) = ...
                sum(Divisions.unit_costs(t, idx) .* Divisions.sectoral_weights(t, idx));    
        end                    
          
    
        %% sales to final demand

        % DESCRIPTION
        % We assume that Sectors sell their products to final demand buyers according to the following pecking order:
            % 1. investing Sectors
            % 2. households
            % 3. government
        % If available products are more than total final demand, each of the above demands gets satisfied.
        % Instead if available products are less than total final demand, Sectors will first try to satisfy orders by investing Sectors;
            % then, they'll try to satisfy orders by the hhs; finally, what is left will be sold to gov't.
            
            
        % INVESTMENTS RATIONING --> ADJUSTMENT OF INVESTMENT ORDERS
        % See description in the function or in the Latex file
        [Sections.current_orders_from_investing_divisions_adj_for_rationing_phys(:,:,t)] = ... 
            Triode_InvestmentsRationing(...
                Rules.investment_rationing, sections_demand_in1year_from_invest_divisions_desired_phys, ...
                divisions_initial_capital_phys, Parameters.Divisions.depreciation_rates, Divisions.capital_productivity(:,:,t), ...
                Sections.products_available_for_final_demand_phys(:,t), Parameters.Sections.idx_capital_assets, Parameters.Divisions.capital_assets_logical_matrix);    
        % Test
        if any(Sections.current_orders_from_investing_divisions_adj_for_rationing_phys(:,:,t) < 0, 'all')
            error('At time step %d, there is at least one negative value in ''Sections.current_orders_from_investing_divisions_adj_for_rationing_phys''', t)
        end
        
        
        % SECTORS' SALES TO INVESTING DIVISIONS
        % Physical
        [sectors_sales_to_investing_divisions_phys] = ...
            From_Sectional_Demand_to_Sectoral_Sales... % name of the function
                (Sections.current_orders_from_investing_divisions_adj_for_rationing_phys(:,:,t), Sectors.products_available_for_final_demand_phys(:,t), ...
                Parameters.Sectors.section_idx, Parameters.Sectors.idx_green, Parameters.Sectors.idx_brown);
        % Test
        if any(sectors_sales_to_investing_divisions_phys < 0, 'all')
            error('At time step %d, there is at least one negative value in ''sectors_sales_to_investing_divisions_phys''', t)
        end
        % SECTORS' AGGREGATED INVESTMENT SALES
        % Physical        
        Sectors.aggr_investment_sales_phys(:,t) = ...
            sum(sectors_sales_to_investing_divisions_phys, 2);
        % Nominal 
        Sectors.aggr_investment_sales_nominal(:,t) = ...
            Sectors.aggr_investment_sales_phys(:,t) .* Sectors.prices(t,:)';
    
        
        % UPDATING SECTORS' QUANTITY OF AVAILABLE PRODUCTS         
        sectors_products_available_for_hhs_phys =  ...
            Sectors.products_available_for_final_demand_phys(:,t) - Sectors.aggr_investment_sales_phys(:,t);
        % Replacing very little negative values with zeros:
        % it can happen that (probably due to Matlab rounding procedures) some values may turn out to be very little negative values (instead of exact zeros), which we want to replace with zeros.
        % But how should we decide whether a value is sufficiently little or not? It makes more sense to look at percentage values (see also explanation when defining error tolerence).
        percentage_values_1 = ...
            (Sectors.products_available_for_final_demand_phys(:,t) - Sectors.aggr_investment_sales_phys(:,t))...
            ./ Sectors.products_available_for_final_demand_phys(:,t);
        % Index of sufficiently little negative values
        idx_little_negative_values_1 = (percentage_values_1 < 0) & (abs(percentage_values_1) < Parameters.error_tolerance_strong);
        sectors_products_available_for_hhs_phys(idx_little_negative_values_1) = 0;
        % Test
        if any(sectors_products_available_for_hhs_phys < 0, 'all')
            error('At time step %d, there is at least one negative value in ''sectors_products_available_for_hhs_phys''', t)
        end
        
    
        % SECTORS' SALES TO HOUSEHOLDS
        % Physical
        [Sectors.sales_to_hhs_phys(:,:,t)] = ...
            From_Sectional_Demand_to_Sectoral_Sales... % name of the function
                (Sections.demand_from_hhs_phys(:,:,t), sectors_products_available_for_hhs_phys, ...
                Parameters.Sectors.section_idx, Parameters.Sectors.idx_green, Parameters.Sectors.idx_brown);
        % Test
        if any(Sectors.sales_to_hhs_phys(:,:,t) < 0, 'all')
            error('At time step %d, there is at least one negative value in ''Sectors.sales_to_hhs_phys''', t)
        end
        % Nominal
        Sectors.sales_to_hhs_nominal(:,:,t) = ...
            Sectors.sales_to_hhs_phys(:,:,t) .* Sectors.prices(t,:)';
        
    
        % UPDATING SECTORS' QUANTITY OF AVAILABLE PRODUCTS 
        sectors_products_available_for_govt_phys = ...
            sectors_products_available_for_hhs_phys - sum(Sectors.sales_to_hhs_phys(:,:,t), 2);
        % Replacing very little negative values with zeros:
        % it can happen that (probably due to Matlab rounding procedures) some values may turn out to be very little negative values (instead of exact zeros), which we want to replace with zeros.
        % But how should we decide whether a value is sufficiently little or not? It makes more sense to look at percentage values (see also explanation when defining error tolerence).
        percentage_values_2 = ...
            (sectors_products_available_for_hhs_phys - sum(Sectors.sales_to_hhs_phys(:,:,t), 2))...
            ./ sectors_products_available_for_hhs_phys;
        % Index of sufficiently little negative values
        idx_little_negative_values_2 = (percentage_values_2 < 0) & (abs(percentage_values_2) < Parameters.error_tolerance_strong);
        sectors_products_available_for_govt_phys(idx_little_negative_values_2) = 0;
        % Test
        if any(sectors_products_available_for_govt_phys < 0, 'all')
            error('At time step %d, there is at least one negative value in ''sectors_products_available_for_govt_phys''', t)
        end
    
    
        % SECTORS' SALES TO GOVERNMENT   
        % Physical
        [Sectors.sales_to_govt_phys(:,t)] = ...
            From_Sectional_Demand_to_Sectoral_Sales... % name of the function
                (Sections.demand_in1year_from_govt_phys(:,t), sectors_products_available_for_govt_phys, ... 
                Parameters.Sectors.section_idx, Parameters.Sectors.idx_green, Parameters.Sectors.idx_brown); 
        % Test
        if any(Sectors.sales_to_govt_phys(:,t) < 0, 'all')
            error('At time step %d, there is at least one negative value in ''Sectors.sales_to_govt_phys''', t)
        end
        % Nominal
        Sectors.sales_to_govt_nominal(:,t) = ...
            Sectors.sales_to_govt_phys(:,t) .* Sectors.prices(t,:)';
    
    
        % UPDATING SECTORS' QUANTITY OF AVAILABLE PRODUCTS
        sectors_products_available_for_inventories_phys = ...
            sectors_products_available_for_govt_phys - Sectors.sales_to_govt_phys(:,t);
        % Replacing very little negative values with zeros:
        % it can happen that (probably due to Matlab rounding procedures) some values may turn out to be very little negative values (instead of exact zeros), which we want to replace with zeros.
        % But how should we decide whether a value is sufficiently little or not? It makes more sense to look at percentage values (see also explanation when defining error tolerence).
        percentage_values_3 = ...
            (sectors_products_available_for_govt_phys - Sectors.sales_to_govt_phys(:,t))...
            ./ sectors_products_available_for_govt_phys;
        % Index of sufficiently little negative values
        idx_little_negative_values_3 = (percentage_values_3 < 0) & (abs(percentage_values_3) < Parameters.error_tolerance_strong);
        sectors_products_available_for_inventories_phys(idx_little_negative_values_3) = 0;
        % Test
        if any(sectors_products_available_for_inventories_phys < 0, 'all')
            error('At time step %d, there is at least one negative value in ''sectors_products_available_for_inventories_phys''', t)
        end
    
    
        % SECTORS' INVENTORIES
        % Physical
        if Rules.inventories == "no"
            Sectors.inventories_phys(:,t) = 0;
        elseif Rules.inventories == "yes"
            Sectors.inventories_phys(:,t) = sectors_products_available_for_inventories_phys;
            % Electricity-producing and electricity-transmitting sectors cannot accumulate inventories
            Sectors.inventories_phys(Parameters.Sectors.idx_electricity_producing_and_transmitting, t) = 0;
        end
        % Nominal
        for i = 1 : Parameters.Sectors.nr
            if Sectors.inventories_phys(i,t) ~= 0
                Sectors.inventories_nominal(i,t) = Sectors.inventories_phys(i,t) .* Sectors.unit_costs(t,i);
            else
                % If physical inventories are nil, we can just assign a nominal value of zero.
                % Indeed it can happen that unit costs of the brown sector become infinite when depreciation is included in unit costs and the brown sector doesn't produce anything.
                % In that case: (physical inventories) x (unit costs) = 0 x Inf = NaN   but we can instead assign a value of zero without concerns.
                Sectors.inventories_nominal(i,t) = 0; 
            end
        end
    
    
        % TOTAL SECTORS' SALES TO FINAL DEMAND BUYERS
        % this is a column vector showing, for each sector, its total sales to final demand buyers
        % Physical terms
        Sectors.sales_to_final_demand_phys(:,t) = ...
            sum(Sectors.sales_to_hhs_phys(:,:,t), 2) ...
            + Sectors.aggr_investment_sales_phys(:,t) ...
            + Sectors.sales_to_govt_phys(:,t);
        % Nominal terms
        Sectors.sales_to_final_demand_nominal(:,t) = ...
            sum(Sectors.sales_to_hhs_nominal(:,:,t), 2) ...
            + Sectors.aggr_investment_sales_nominal(:,t) ...
            + Sectors.sales_to_govt_nominal(:,t);
            
    
    
        % TOTAL SECTIONS' SALES TO FINAL DEMAND BUYERS
        % this is a column vector showing, for each section, its total sales to final demand buyers    
        aggregation_rule = "values of sectors belonging to the same section get summed";
        % Physical
        Sections.sales_to_final_demand_phys(:,t) = ...
            From_Sectors_To_Sections_Function(aggregation_rule, Sectors.sales_to_final_demand_phys(:,t), Parameters.Sectors.section_idx);
        % Nominal
        Sections.sales_to_final_demand_nominal(:,t) = ...
            From_Sectors_To_Sections_Function(aggregation_rule, Sectors.sales_to_final_demand_nominal(:,t), Parameters.Sectors.section_idx);
        clear aggregation_rule
    
    
        % GREEN SHARE IN TOTAL ELECTRICITY SALES
        if Rules.electricity_sector_aggregation ~= "one_electricity_sector"
            Economy.green_share_sales(t) = ...
                (sum(Sectors.S_square(Parameters.Sectors.idx_green, :, t), 2) + Sectors.sales_to_final_demand_phys(Parameters.Sectors.idx_green, t)) ...
                ./ ...
                (sum(Sectors.S_square(Parameters.Sectors.idx_electricity_producing, :, t), "all") + sum(Sectors.sales_to_final_demand_phys(Parameters.Sectors.idx_electricity_producing, t), "all"));
        end


        %% capital accumulation

        % DIVISIONS' REAL (PHYSICAL) CAPITAL
        % = (previous period capital) - (depreciated capital) + (investment)
        Divisions.capital_phys(:,:,t) = ...
            divisions_initial_capital_phys - divisions_capital_depreciation_phys + Sections.current_orders_from_investing_divisions_adj_for_rationing_phys(:,:,t);
    

        % PRODUCTION CAPACITY OF EACH CAPITAL ASSET - in 1 year
        divisions_prod_cap_of_each_capital_asset_in1year = ...
            Divisions.capital_productivity(:,:,t) .* Divisions.capital_phys(:,:,t);


        % SECTORAL NOMINAL CAPITAL STOCKS
        sectors_capital_phys = NaN * ones(Parameters.Sections.nr, Parameters.Sectors.nr);
        for i = 1 : Parameters.Sectors.nr
            idx_divisions_belonging_to_sector_i = find(Parameters.Divisions.sector_idx == i);
            sectors_capital_phys(:,i) = ...
                sum(Divisions.capital_phys(:, idx_divisions_belonging_to_sector_i, t), 2);
        end
        Sectors.capital_nominal(:,:,t) = ...
            sectors_capital_phys .* Sections.prices(t,:)';        
        
        
        % NOMINAL VALUE OF TOTAL CAPITAL
        % it's a unique number for each sector, and it is given by the sum of the nominal values of the single capital assets.
        Sectors.tot_capital_nominal(t,:) = ...
            sum(Sectors.capital_nominal(:,:,t));


        %% desired investment

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%  DESIRED PRODUCTION DRIVING INVESTMENT  %%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
        % The desired production level that will drive investments is defined as the production implied ..
        % .. by the current period's actual final demand vector, assuming that: 
            % The green share is equal to the target green share in 2 years from now. 
            % The technical coefficients matrix is the one in 2 years from now (accounting for the devolpment of electrification and the electricity Divisions' target weights)
        % Note that we use values referring to 2 years from now because desired investment today will actually be productive in 2 years.
    
        % ASSUMED GREEN SHARE
        if Rules.electricity_sector_aggregation == "one_electricity_sector"        
            green_share_assumed = NaN; 
        else              
            if t < (Parameters.T - 1)
                green_share_assumed = Parameters.Sectors.target_green_share(t+2);
            else
                green_share_assumed = Parameters.Sectors.target_green_share(t);
            end
        end

        % SECTORS' RECTANGULAR TECHNICAL COEFFICIENTS MATRIX USED TO COMPUTE DESIRED PRODUCTION
        % Note that when computing the Sectors' desired production driving investment through the "Triode_Production_Nested" function, ..
        % ..we shouldn't use the current "Sectors.C_rectangular(:,:,t)" because there, electrification and electricity Divisions' weights are those of time t, ..
        % ..whereas we want to use those of time t+2. Therefore, here we compute the technical coefficients matrix of t+2.
        sectors_C_rectangular_for_investment = NaN * ones(Parameters.Sections.nr, Parameters.Sectors.nr);
        for i = 1 : Parameters.Sectors.nr
            idx_divisions_belonging_to_sector_i = find(Parameters.Divisions.sector_idx == i);
            if t < (Parameters.T - 1)
                sectors_C_rectangular_for_investment(:,i) = ...
                    sum(Parameters.Divisions.target_sectoral_weights(t+2, idx_divisions_belonging_to_sector_i) .* Divisions.C_rectangular(:, idx_divisions_belonging_to_sector_i, t+2), 2);
            else
                sectors_C_rectangular_for_investment(:,i) = ...
                    sum(Parameters.Divisions.target_sectoral_weights(t, idx_divisions_belonging_to_sector_i) .* Divisions.C_rectangular(:, idx_divisions_belonging_to_sector_i, t), 2);
            end
        end

        % FINAL DEMAND USED AS INPUT TO COMPUTE THE DESIRED PRODUCTION DRIVING INVESTMENT
        if Rules.desired_production_driving_investment == "old"
            final_demand = Sections.final_demand_phys_exp(:,t);
        elseif Rules.desired_production_driving_investment == "new"
            final_demand = Sections.final_demand_phys(:,t);
        end        
        
        % ANCILLARY VARIABLES 
        % ..needed to operate the "Triode_Production_Nested" function.
        % We don't consider sectors' constraints here.
        % Thus, we assume that no sector sets its production exogenously, that no sector has a negative final demand, and no haircut has to be applied.
        idx_sectors_exogenous_production = [];
        idx_sectors_negative_final_demand = [];
        haircut_value = 1;              
        green_share_enforcement = "not active";
        
        % SECTORS' DESIRED PRODUCTION DRIVING INVESTMENT
        % If a sector's desired production (without considering inventories) is larger than a certain threshold proportion of its max production, then the sector will want to invest.
        % We don't take into account inventories (indeed we are using "production_planned_sectoral" and not "production_planned_minus_inventories_sectoral" as relevant output of the "Triode_Production_Nested" function).
        % Indeed imagine desired metal production is 200 while max metal production is 150 but there are 100 metal inventories.
        % If we took into account inventories, then the metal sector wouldn't invest, which doesn't make sense.
        [~, ~, Sectors.production_desired_driving_investment_phys(:,t), ~, ~, ~, ~, ~, ~] = ...
            Triode_Production_Nested... % function
                (Parameters.Sectors.idx, Parameters.Sectors.section_idx, Parameters.Sections.idx_electricity_producing, Parameters.Sectors.idx_green, Parameters.Sectors.idx_brown, ...
                sectors_C_rectangular_for_investment, final_demand, Sectors.prod_cap(:,t), ...
                Sectors.inventories_phys(:,t), idx_sectors_exogenous_production, ...
                idx_sectors_negative_final_demand, haircut_value, green_share_assumed, green_share_enforcement);                 
    
        % DIVISIONS' DESIRED PRODUCTION DRIVING INVESTMENTS
        % This will drive desired investments by each division.
        % We allocate the Sectors' desired production to the Divisions, according to the target weights in 2 years from now.
        % We don't use current target weights but those of 2 years from now, because investments will actually be productive in 2 years from now.    
        if t < (Parameters.T - 1)
            target_sectoral_weights_in_two_years = Parameters.Divisions.target_sectoral_weights(t+2,:);
        else
            target_sectoral_weights_in_two_years = Parameters.Divisions.target_sectoral_weights(t,:);
        end
        for j = 1 : Parameters.Divisions.nr        
            Divisions.production_desired_driving_investment_phys(j,t) = ...
                target_sectoral_weights_in_two_years(j) .* Sectors.production_desired_driving_investment_phys(Parameters.Divisions.sector_idx(j), t);
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%  REAL (PHYSICAL) DESIRED INVESTMENTS  %%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Sectors calculate their desired level of investment that they plan to demand in the next period.
        % They'll actually purchase investment goods in the next period..             
            % .. but they already agree with suppliers that the price they'll pay in the next period will be the current period price.
        
        % See explanations and equation derivation in the respective Latex file
    
        
        % PRODUCTION VALUE DRIVING INVESTMENTS    
        if Rules.production_driving_investment == "desired"
            % the desired level of production is the value that Divisions look at to determine their desired investment
            divisions_production_driving_investment = Divisions.production_desired_driving_investment_phys(:,t);
        elseif Rules.production_driving_investment == "actual"
            % the actual level of production is the value that Divisions look at to determine their desired investment
            divisions_production_driving_investment = Divisions.production_phys(:,t);
        end


        % ASSUMED CAPACITY UTILIZATION
        % Assumed capacity utilization in the next period        
        if Rules.depreciation == "only used capital"
            % we assume it to be equal to the normal capacity utilization level
            Divisions.assumed_capacity_utilization_in1year(t,:) = Parameters.Divisions.investment_threshold_coefficient;
        else
            % If instead depreciation affects the entire capital stock, then it is as if capacity utilization was 100%
            Divisions.assumed_capacity_utilization_in1year(t,:) = ones(1, Parameters.Divisions.nr);
        end 


        % HYPOTHETICAL PRODUCTION CAPACITY IN 2 YEARS, IF NOT INVESTING    
        divisions_hypothetical_prod_cap_of_each_capital_asset_in2years = ...
            Divisions.capital_productivity(:,:,t) .* ((1 - Parameters.Divisions.depreciation_rates .* Divisions.assumed_capacity_utilization_in1year(t,:)) .* Divisions.capital_phys(:,:,t));                
    

        % SECTIONAL DEMANDS IMPLIED BY DESIRED INVESTMENTS
        [sections_demand_in1year_from_invest_divisions_desired_phys, Divisions.desired_investment_formula_cases(t,:), ~, second_term] = ...
            Desired_Investments_function...
                (t, Rules.desired_investment_function, Rules.min_investment, Rules.investment_reference_case_2B, Parameters.time_step_corresponding_to_2022, ...
                Parameters.Sections.nr, Parameters.Divisions.nr, Parameters.Divisions.capital_assets_logical_matrix, ...    
                Parameters.Divisions.idx_shrinking, Parameters.Divisions.investment_threshold_coefficient, Divisions.assumed_capacity_utilization_in1year(t,:), ...
                Parameters.Divisions.depreciation_rates, Divisions.capital_productivity(:,:,t), ...
                divisions_production_driving_investment, Divisions.capital_phys(:,:,t), ...
                divisions_prod_cap_of_each_capital_asset_in1year, divisions_hypothetical_prod_cap_of_each_capital_asset_in2years);            
    
        % Test
        if any(sections_demand_in1year_from_invest_divisions_desired_phys < 0, 'all')
            error('At time step %d, there is at least one negative value in ''sections_demand_in1year_from_invest_divisions_desired_phys''', t)
        end
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       


        % DESIRED CAPITAL STOCK - in 1 year
        % It's the capital stock Divisions would reach if:
            % (i) their desired investments (which we have just defined above) were fulfilled;
            % (ii) and future realized capital utilization equals the expected one (if depreciation affects only used capital).
        % See also definition in Latex file
        divisions_desired_capital_stock_phys_in1year = ...
            sections_demand_in1year_from_invest_divisions_desired_phys - second_term; 
    

        % DESIRED PRODUCTION CAPACITY OF EACH CAPITAL ASSET - in 2 years
        % it's the production limit implied by the desired capital stock in 1 year
        Divisions.desired_prod_cap_of_each_capital_asset_in2years(:,:,t) = ...
            divisions_desired_capital_stock_phys_in1year .* (Divisions.capital_productivity(:,:,t) .* (1 + Parameters.Divisions.capital_productivity_growth));


        % DIVISIONS' DESIRED INVESTMENT AND INVESTMENT DEMAND, ADJUSTED AFTER LOANS
        % If Divisions don't receive the total loan that they requested, they'll have to revise their investmend demands downwards.
        % We assume that in the first period Divisions receive the full amount of loans requested.
        Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys(:,:,t) = ...
            sections_demand_in1year_from_invest_divisions_desired_phys;
        % Nominal
        Sections.demand_in1year_from_invest_divisions_adj_after_loans_aggr_nomin(:,t) = ...
            sum(Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys(:,:,t) .* Sections.prices(t,:)', 2);
       

        % DESIRED CAPITAL STOCK, ADJUSTED AFTER LOANS - in 1 year
        % it's the capital stock sectors would reach if:
            % (i) their desired investments (adjusted after loans rationing) were fulfilled;
            % (ii) and future realized capital utilization equals the expected one (if depreciation affects only used capital).
        % Its definition is similar to that of "divisions_desired_capital_stock_phys_in1year"        
        divisions_desired_capital_stock_adj_after_loans_phys_in1year = ...
            Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys(:,:,t) - second_term;
        
        % DESIRED PRODUCTION CAPACITY OF EACH CAPITAL ASSET, ADJUSTED AFTER LOANS - in 2 years
        % it's the production limit implied by the future desired capital stock adjusted after loans
        Divisions.desired_prod_cap_of_each_capital_asset_adj_after_loans_in2years(:,:,t) = ...
            divisions_desired_capital_stock_adj_after_loans_phys_in1year .* (Divisions.capital_productivity(:,:,t) .* (1 + Parameters.Divisions.capital_productivity_growth));



        % TAX RATE
        Government.sectors_tax_rate(t) = 0;


        %% NPV

        % INTEREST RATE ON LOANS        
        if numel(Variations.interest_rate) > 1
            Bank.interest_on_loans(t) = Variations.interest_rate(sim_counter); 
        else
            Bank.interest_on_loans(t) = Variations.interest_rate;
        end



        % NPV = (discounted investment revenues) - (investment costs)

        % The idea is the following:
        % After having applied for loans at the bank and having possibly rescaled their investment demands downwards in case of loan rationing,..
        % the Divisions compute the NPV associated with this rescaled investment demand.
        % Then, the Divisions with negative NPV receive investment subsidies from the gov't,
        % ..of an amount equivalent to the negative NPV (such that the consequent NPV goes exactly to zero).
    
        % The Divisions that have received subsidies will not ask for less loans than previously applied for.
        % They'll still use the received loan to fund their investment expenses.
        % The subsidy may rather be used by sectors to compensate shareholders.
        
        % Note: it makes sense to compute the NPV after the loans requests, and not before.
        % Indeed, imagine they would compute NPV before asking for loans. Those with negative NPV, would receive gov't subsidies.
        % Then they would go to the bank and ask for loans. In case they were credit rationed, they would have to rescale their investment downwards, ..
        % .. implying that the invested amount isn't anymore consistent with the subsidy received!    
        
    
    
        %%%%%  DISCOUNTED INVESTMENT REVENUES  %%%%%
    
        % = ∑ {...
                % (delta production) * (price - intermediate input unit costs) * (1 - tax rate) ...
                % + (tax rate) * (amortization) ...
                % + (nominal value of idle capital stocks)...
                % } ...
                % / (1 + i)^t
        % (see formula in Slides "Pearson_Cap_08" (slide 42) provided by Marco Raberto -- which we have slightly modified by adding the term "nominal value of idle capital stocks")
    
        % We define them as the discounted revenues arising from the investment, i.e.:
        % for a certain future time horizon (e.g. 30 years), for each year we compute: 
        % The "Delta Production" as the difference between: 
            % = (maximum production capacity if investment occurs) - (maximum production capacity without investment)
            % ..see Excel file for intuitive understanding.
        % Then we multiply the resulting value by the following value: (price - intermediate input unit costs)
            % ..to obtain the expected revenue for that year, net of production costs (we assume that the current prices remain constant in the future for simplicity);
        % Then we multiply the resulting value by the following value: (1 - tax rate)
            % ..because your net revenue has to account for taxes to be paid (note that we assume that the tax rate remains constant in the future for simplicity)..
        % Then we add the term: (tax rate) * (amortization) 
            % ..because actually you will exclude the amortization from your (revenues - costs) value when paying taxes.
        % Then we add the term: (nominal value of idle capital stocks)
            % ..because you should consider those idle capital stocks as valuable assets that you could sell (or not buy, if they were needed for future investment plans)
            % ..See Excel file for intuitive understanding of how to compute this nominal value.    
        % Finally, we discount the resulting total value through the interest rate.
    
        % NOTE /1:
        % for simplicity, below we compute the "Delta Production" not as the difference between: 
            % = (maximum production capacity if investment occurs) - (maximum production capacity without investment)
        % but rather, as the difference between:
            % = (maximum production capacity if investment occurs and idle capital assets are sold) - (maximum production capacity without investment)
        % Indeed, actually the two procedures should yield the same result (see Excel file), and we already have the values to compute the second formula..
        % ..while we would need to perform additional calculations if we wanted to use the first formula.

        % NOTE /2:
        % for simplicity, we are assuming that depreciation affects the entire capital stock and not just the utilized one.

      
        for i = 1 : Parameters.Divisions.nr
    
            discounted_revenues = 0;
    
            % Physical values of the investment
            % (Note that this array is only used for the computation of the nominal amortization)
            residual_investment_phys = Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys(:,i,t);
    
            % Time horizon over which to perform the summation:
            % shouldn't be neither too short (--> imprecise) nor too long (--> burdensome for computation time)
            time_length = 30;
    
            % Year from which we let the for-loop start
            % We make it start from year 2, because desired investment in year 0 will actually be purchased in year 1, and will be productive only in year 2.
            % Therefore, the "Delta Production" achieved in year 1 is nil.
            initial_year = 2;
    
            for time_step = initial_year : time_length
    
                % Capital stocks in year=time_step-1, if investment took place and idle capital assets are sold
                    % Note: capital stocks in year=time_step-1 are productive in year=time_step
                if time_step == initial_year
                    capital_stocks_with_investment = divisions_desired_capital_stock_adj_after_loans_phys_in1year(:,i);
                else
                    capital_stocks_with_investment = ...
                        (1 - Parameters.Divisions.depreciation_rates(:,i)) .* capital_stocks_with_investment;
                end
    
                % Capital stocks in year=time_step-1, if investment did not take place                
                    % Note: capital stocks in year=time_step-1 are productive in year=time_step
                capital_stocks_without_investment = ...
                    ((1 - Parameters.Divisions.depreciation_rates(:,i)) .^ (time_step - 1)) .* Divisions.capital_phys(:,i,t);
    
                % Capital productivity in year=time_step-1
                    % Note: capital productivity in year=time_step-1 is the relevant one for year=time_step
                capital_productivity = ...
                    ((1 + Parameters.Divisions.capital_productivity_growth) .^ (time_step - 1)) .* Divisions.capital_productivity(:,i,t);
    
                % Production capacity in year=time_step, if investment took place
                % ..for all assets:
                production_capacity_with_investment = ...
                    capital_stocks_with_investment .* capital_productivity;
                % ..binding value:
                binding_production_capacity_with_investment = ...
                    min(production_capacity_with_investment(Parameters.Divisions.capital_assets_logical_matrix(:,i)));
    
                % Production capacity in year=time_step, if investment did not take place
                % ..for all assets:
                production_capacity_without_investment = ...
                    capital_stocks_without_investment .* capital_productivity;
                % ..binding value:
                binding_production_capacity_without_investment = ...
                    min(production_capacity_without_investment(Parameters.Divisions.capital_assets_logical_matrix(:,i)));
    
                % Production gains in year=time_step, thanks to investment
                delta_production = ...
                     binding_production_capacity_with_investment - binding_production_capacity_without_investment;
    
                % Nominal amortization in year=time_step
                amortization = ...
                    Sections.prices(t,:) * (Parameters.Divisions.depreciation_rates(:,i) .* residual_investment_phys);
    
                % Nominal value of idle capital stock in year=time_step
                    % ..see Excel file for intuitive understanding of how to compute this nominal value.
                    % To calculate the physical amount of the idle capital stock, we first compute, for each capital asset, ...
                    % ..its idle production capacity. The latter is defined as the difference between its production capacity with investment ...
                    % ..and the maximum value among its production capacity without investment and the overall binding production capacity with investment.
                    % Then, (phys idle capital stock) = (idle production capacity) / (productivity)
                % Maximum value among the production capacity without investment and the overall binding production capacity with investment.
                floor_production_value = ...
                    max(production_capacity_without_investment, binding_production_capacity_with_investment);
                floor_production_value(production_capacity_without_investment == 0) = 0;
                % Idle production capacity
                idle_production_capacity = ...
                    max(0, production_capacity_with_investment - floor_production_value);
                % Idle physical capital stock
                    % (Idle production capacity) = (Productivity) * (Idle capital stock)  -->
                    % (Idle capital stock) = (Idle production capacity) / (Productivity)
                idle_capital_stock_phys = ...
                    idle_production_capacity ./ capital_productivity;
                idle_capital_stock_phys(isnan(idle_capital_stock_phys)) = 0;
                % Idle nominal capital stock
                idle_capital_stock_nominal = Sections.prices(t,:)' .* idle_capital_stock_phys;
    
                % Assume that the Division sells its idle capital assets, which thus have to be subtracted from the capital stock.
                capital_stocks_with_investment = ...
                    capital_stocks_with_investment - idle_capital_stock_phys;
    
                % Physical values of the investment, adjusted for depreciation
                % (Note that this array is only used for the computation of the nominal amortization)
                residual_investment_phys = (1 - Parameters.Divisions.depreciation_rates(:,i)) .* residual_investment_phys;
                
                % Updating the discounted revenues
                discounted_revenues = ...
                    discounted_revenues ...
                    + (...
                    delta_production .* (Sectors.prices(t, Parameters.Divisions.sector_idx(i)) - Sections.prices(t,:) * Divisions.C_rectangular(:,i,t)) .* (1 - Government.sectors_tax_rate(t)) ...
                    + Government.sectors_tax_rate(t) * amortization ...
                    + sum(idle_capital_stock_nominal)...
                    )...
                    ./ ((1 + Bank.interest_on_loans(t)) .^ time_step);
    
            end
    
            % DISCOUNTED REVENUES
            Divisions.NPV_discounted_revenues(t,i) = discounted_revenues;
    
        end
    
        
        %%%%%  INVESTMENT COSTS  %%%%%
        Divisions.NPV_investment_costs(t,:) = ...
            Sections.prices(t,:) * Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys(:,:,t); % we use current period prices since indeed investment demand will translate in investment purchases in the next period and at the prices of the current period        
        
        
        %%%%%  NPV  %%%%%
        Divisions.NPV(t,:) = ...
            Divisions.NPV_discounted_revenues(t,:) - Divisions.NPV_investment_costs(t,:);
    
    
    
        % GOV'T SUBSIDIES
        % Electricity Divisions with negative NPV receive subsidies from the gov't..
        % ..of an amount equivalent to the negative NPV (such that the consequent NPV goes exactly to zero).
        idx_divisions_with_negative_NPV = find(Divisions.NPV(t,:) < 0);
        idx_electricity_divisions_with_negative_NPV = intersect(idx_divisions_with_negative_NPV, Parameters.Divisions.idx_electricity_producing);
        Divisions.govt_subsidies(t,:) = 0;
        if Rules.NPV == "yes"
            Divisions.govt_subsidies(t, idx_electricity_divisions_with_negative_NPV) = ...
                abs(Divisions.NPV(t, idx_electricity_divisions_with_negative_NPV));
        end
        % Sectoral level
        for i = 1 : Parameters.Sectors.nr
            Sectors.govt_subsidies(t,i) = ...
                sum(Divisions.govt_subsidies(t, Parameters.Divisions.sector_idx == i), 2);
        end


        %% deposits and loans
    
        % SECTORS' DEPOSITS
        % We assume that initial deposits equal the investment cost sectors expect to pay in the next period
        sections_future_demand_from_invest_sectors_adj_after_loans_phys = NaN * ones(Parameters.Sections.nr, Parameters.Sectors.nr);
        for i = 1 : Parameters.Sectors.nr
            idx_divisions_belonging_to_sector_i = find(Parameters.Divisions.sector_idx == i);
            sections_future_demand_from_invest_sectors_adj_after_loans_phys(:,i) = ...
                sum(Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys(:, idx_divisions_belonging_to_sector_i, t), 2);
        end
        Sectors.deposits(t,:) = ...
            Sections.prices(t,:) * sections_future_demand_from_invest_sectors_adj_after_loans_phys;

        % SECTORS' ASSETS
        Sectors.assets(t,:) = ...
            Sectors.tot_capital_nominal(t,:) + Sectors.inventories_nominal(:,t)' + Sectors.deposits(t,:);

        % SECTORS' LIABILITIES
        % ..are given by the leverage formula
        % Leverage = (Liabilities) / (Net Worth) = (Liabilities) / (Assets - Liabilities)
        % Leverage and Assets have already been defined, thus we can derive:        
        % Liabilities = (Leverage / [1 + Leverage]) * (Assets)        
        Sectors.liabilities(t,:) = ...
            (Sectors.leverage(t,:) ./ (1 + Sectors.leverage(t,:))) .* Sectors.assets(t,:);

        % SECTORS' LOANS
        % Since liabilities include only loans --> Loans = Liabilities
        Sectors.loans_stock(t,:) = Sectors.liabilities(t,:);

        % SECTORS' NET WORTH
        % = assets - liabilities
        Sectors.net_worth(t,:) = ...
            Sectors.assets(t,:) - Sectors.liabilities(t,:);
        % Test
        if any(Sectors.net_worth(t,:) < 0, 'all')
            error('At time step %d, there is at least one negative value in ''Sectors.net_worth''', t)
        end
            

    
        %% stocks and flows

        % SECTORS' NOMINAL SALES
        % = (nominal intermediate input sales to sectors) + (nominal sales to final demand buyers)
        % Remember that interindustry transactions and investment sales are made at previous period prices.        
        Sectors.sales_nominal(:,t) = ...
            sum(Sectors.S_square(:,:,t) .* Sectors.prices(t,:)', 2) ...        
            + Sectors.sales_to_final_demand_nominal(:,t);
       
    
        % SECTORS' TOTAL HISTORIC COSTS
        % This is the total historic costs as defined in Chapter 8 in Godley & Lavoie (2007)
        % = (intermediate inputs costs) + (labor costs) - (change in inventories)    
        % Recall that we've assumed that interindustry transactions are settled at previous period prices.
        Sectors.historic_costs(t,:) = ...
            Sectors.prices(t,:) * Sectors.S_square(:,:,t) ...
            - (Sectors.inventories_nominal(:,t) - Sectors.inventories_nominal(:,t))';
    
    
        % SECTORS' VALUE ADDED
        % = (nominal sales) + (change in inventories) - (intermediate input costs)    
        Sectors.VA(t,:) = ...
            Sectors.sales_nominal(:,t)' ...
            + (Sectors.inventories_nominal(:,t) - Sectors.inventories_nominal(:,t))' ...
            - Sectors.prices(t,:) * Sectors.S_square(:,:,t);


        % SECTORS' TAXES
        % taxes are paid on net profits of the previous period
        Sectors.taxes(t,:) = 0;

        
        % ENTREPRENEURIAL PROFITS
        % This is the definition of profits as defined in Chapter 8 in Godley & Lavoie (2007) ..
        % ..and as implied by the current account column of the SFC transactions flow matrix.
        Sectors.entrepreneurial_profits(t,:) = ...
            Sectors.sales_nominal(:,t)' + Sectors.govt_subsidies(t,:) - Sectors.historic_costs(t,:) - Sectors.taxes(t,:);


        % SECTORS' NET PROFITS
        % = (entrepreneurial profits) - (interest on loans) - (depreciation on capital?)
        % This is the value of profits on which sectors pay taxes.
        Sectors.net_profits(t,:) = ...
            Sectors.entrepreneurial_profits(t,:) ...
            - Sectors.capital_depreciation_nominal(t,:); 
        % we don't add interest expenses because we assume there are none in the first time step
    
    
    %% households' consumption and emissions

    % HOUSEHOLDS' PHYSICAL CONSUMPTION
    aggregation_rule = "values of sectors belonging to the same section get summed";
    Sections.sales_to_hhs_phys(:,:,t) = ...
        From_Sectors_To_Sections_Function(aggregation_rule, Sectors.sales_to_hhs_phys(:,:,t), Parameters.Sectors.section_idx);
    clear aggregation_rule

    
    % HOUSEHOLDS' NOMINAL CONSUMPTION
    Sections.sales_to_hhs_nominal(:,:,t) = ...
        Sections.sales_to_hhs_phys(:,:,t) .* Sections.prices(t,:)';


    % REALIZED CONSUMPTION EXPENDITURES    
    Households.consumption_expenditures(t,:) = sum(Sections.sales_to_hhs_nominal(:,:,t));


    %%%%%%%  HOUSEHOLDS' EMISSIONS  %%%%%%%

    % EMISSION INTENSITY
    % = emissions per unit of fossil-fuels consumed
    % Remember that the hh consumes fossil-fuels only from the "Fossil fuels processing" Section
    Parameters.Households.emissions_per_fossil_fuel_unit_consumed = ...
        Parameters.Households.emissions_Exiobase ./ Parameters.Households.exiobase_demand_relations_phys(Parameters.Sections.names == "Fossil fuels processing");

    % Emissions arising from each hhs' consumption
    Households.emissions_flow(t,:) = ...
        Parameters.Households.emissions_per_fossil_fuel_unit_consumed .* Sections.sales_to_hhs_phys(Parameters.Sections.names == "Fossil fuels processing", :, t);
    
    
    %% macroeconomic variables
    

    %%%%%%%%   NOMINAL GDP   %%%%%%%%

    % Blanchard (2016): "Nominal GDP is the sum of the quantities of final goods produced times their current price".
    % Note: it says "produced", not "sold"! So we should include inventory investment (II) in the computation of GDP.
    % GDP = C + I + G + II

    % total value added in the economy
    Economy.GDP_nominal(t) = sum(Sectors.VA(t,:),2);
    
    % TOTAL NOMINAL SALES TO FINAL DEMAND
    % This does not equal nominal GDP when inventories are accumulated.
    Economy.sales_to_final_demand_nominal(t) = ...
        sum(Sectors.sales_to_final_demand_nominal(:,t));

    % SUM OF INCOMES
    Economy.total_income(t) = ...
        sum(Sectors.dividends(t,:), 2) ...
        + sum(Sectors.retained_profits(t,:), 2) ...
        + sum(Sectors.taxes(t,:), 2) ...
        + Bank.dividends(t) + Bank.profits_retained(t);


    %%%%%%%%   REAL GDP   %%%%%%%%
    
    % real GDP in chained (t=1) dollars
    % We set real GDP at time 1 equal to nominal GDP at time 1
    Economy.GDP_real(t) = Economy.GDP_nominal(t);


    %%%%%%%%   TOTAL CAPITAL STOCKS   %%%%%%%%
    Economy.capital_stocks_phys(:,t) = sum(Divisions.capital_phys(:,:,t), 2);
    Economy.capital_stocks_nominal(:,t) = sum(Sectors.capital_nominal(:,:,t), 2);


    %%%%%%%%   INFLATION   %%%%%%%%

    % GDP deflator
    Economy.GDP_deflator(t) = Economy.GDP_nominal(t) ./ Economy.GDP_real(t);

    % CONSUMER PRICE INDEX (CPI)
    % = (cost of the market basket in year t) / (cost of the same market basket in the base year)
    Economy.CPI(t) = 100;        
    
    
    %% bank
    
    % Loans
    Bank.loans_stock(t) = sum(Sectors.loans_stock(t,:), 2);
    
    % Deposits
    Bank.deposits(t) = sum(Sectors.deposits(t,:), 2) + sum(Households.deposits(t,:), 2);

    % CAR
    % Let's assume that initial CAR equals the bank's target CAR
    Bank.CAR(t) = Parameters.Bank.CAR_target;
    
    % NET WORTH
    % is defined as a result from CAR and loans 
    Bank.net_worth(t) = Bank.CAR(t) .* Bank.loans_stock(t);

    % BANK'S RESERVES HOLDINGS AND ADVANCES
    % Look at the bank's column in the Balance Sheet matrix --> H - A - M + L - NW = 0
    % M, L, and NW have just been defined above --> let's thus define them as a "residual":
    % Residual:
    bank_stock_residual = ...
        Bank.loans_stock(t) - Bank.deposits(t) - Bank.net_worth(t);

    % Thus we can write the above equation as: 
    % residual = A - H
    % If the residual is positive, we'll assume that Advances (A) are equal to the residual and that Reserves (H) are zero;
    % If the residual is negative, we'll assume that Reserves (H) are equal to the negative of the residual and that Advances (A) are zero;
    if bank_stock_residual >= 0         
        Bank.advances(t) = bank_stock_residual;
        Bank.reserves_holdings(t) = 0;
    else
        Bank.reserves_holdings(t) = - bank_stock_residual;
        Bank.advances(t) = 0;
    end        
    
    
    %% government

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%   FLOWS   %%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % GOV'T NOMINAL CONSUMPTION
    Government.consumption_expenditures(t) = sum(Sectors.sales_to_govt_phys(:,t) .* Sectors.prices(t,:)');
        
    % GOV'T PHYSICAL CONSUMPTION
    aggregation_rule = "values of sectors belonging to the same section get summed";
    Sections.sales_to_govt_phys(:,t) = ...
        From_Sectors_To_Sections_Function(aggregation_rule, Sectors.sales_to_govt_phys(:,t), Parameters.Sectors.section_idx);
    clear aggregation_rule

    % GOV'T SUBSIDIES
    Government.subsidies(t) = sum(Sectors.govt_subsidies(t,:), 2);

    % GOV'T TAXES
    % We assume that the government doesn't collect any taxes in the first period
    Government.taxes(t) = 0;    
    


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%   OTHER VARIABLES /1   %%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % GOV'T DEFICIT
    % = expenditures - revenues
    Government.deficit(t) = ...
        Government.consumption_expenditures(t) + Government.subsidies(t) - Government.taxes(t);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%   ASSETS & LIABILITIES   %%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % PRE-EXISTING RESERVES AND ADVANCES
    government_preexisting_reserves = 0;
    government_preexisting_advances = 0;

    % GOV'T ADJUSTMENT OF RESERVES HOLDINGS AND ADVANCES

    % If the gov't deficit is positive (meaning it is running a deficit), the gov't will draw upon its stock of reserves holdings to cover the deficit; if that's insufficient, it will take loans (advances) from the central bank.
    % If the gov't deficit is negative (meaning it is running a surplus), the gov't will use the funds in excess to repay advances to the central bank. If there aren't advances to be repaid, it will park the funds as reserves holdings.
    if Government.deficit(t) >= 0
        if Government.deficit(t) <= government_preexisting_reserves
            Government.reserves_holdings(t) = government_preexisting_reserves - Government.deficit(t);
            Government.advances(t) = government_preexisting_advances;
        else
            Government.reserves_holdings(t) = 0;
            Government.advances(t) = government_preexisting_advances + Government.deficit(t) - government_preexisting_reserves;
        end
    else
        if -Government.deficit(t) <= government_preexisting_advances
            Government.advances(t) = government_preexisting_advances + Government.deficit(t);
            Government.reserves_holdings(t) = government_preexisting_reserves;
        else 
            Government.advances(t) = 0;
            Government.reserves_holdings(t) = government_preexisting_reserves - Government.deficit(t) - government_preexisting_advances;
        end
    end

    % Test
    if Government.advances(t) < 0
        error('At time step %d, there is a negative value in ''Government.advances''', t)
    end
    % Test
    if Government.reserves_holdings(t) < 0
        error('At time step %d, there is a negative value in ''Government.reserves_holdings''', t)
    end

    
    % NET WORTH
    % = assets - liabilities
    Government.net_worth(t) = Government.reserves_holdings(t) - Government.advances(t);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%   OTHER VARIABLES /2   %%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
    % DEFICIT-TO-GDP RATIO
    Government.deficit_to_GDP_ratio(t) = ...
        Government.deficit(t) ./ Economy.GDP_nominal(t);

    % DEBT-TO-GDP RATIO
    Government.debt_to_GDP_ratio(t) = ...
        Government.advances(t) / Economy.GDP_nominal(t);    


    %%%%%%%  EMISSIONS ARISING FROM GOV'T CONSUMPTION  %%%%%%%

    % EMISSION INTENSITY
    % = emissions per unit of fossil-fuels consumed
    % Remember that the gov't consumes fossil-fuels only from the "Fossil fuels processing" Section
    Parameters.Government.emissions_per_fossil_fuel_unit_consumed = ...
        Parameters.Government.emissions_Exiobase ./ Parameters.Government.exiobase_demand_relations_phys(Parameters.Sections.names == "Fossil fuels processing");    

    % CURRENT EMISSIONS
    Government.emissions_flow(t) = ...
        Parameters.Government.emissions_per_fossil_fuel_unit_consumed .* Sections.sales_to_govt_phys(Parameters.Sections.names == "Fossil fuels processing", t);

  
    %% central bank
    
    % ADVANCES
    CentralBank.advances(t) = Bank.advances(t) + Government.advances(t);
    
    % RESERVES
    CentralBank.reserves(t) = Bank.reserves_holdings(t) + Government.reserves_holdings(t);
    
    % NET WORTH 
    % = assets - liabilities
    CentralBank.net_worth(t) = CentralBank.advances(t) - CentralBank.reserves(t);


    %% real values, deflated (not physical units)

    
    % TOTAL REAL DEFLATED HHS CONSUMPTION
    Economy.hhs_consumption_defl(t) = ...
        sum(Households.consumption_expenditures(t,:), 2)...
        ./ Economy.GDP_deflator(t);


    % TOTAL REAL DEFLATED INVESTMENT
    % Level
    Economy.investment_defl(t) = ...
        sum(Sectors.aggr_investment_sales_nominal(:,t))...
        ./ Economy.GDP_deflator(t);    

    
    % TOTAL REAL DEFLATED GOV'T CONSUMPTION
    Economy.govt_consumption_defl(t) = ...
        sum(Sectors.sales_to_govt_nominal(:,t))...
        ./ Economy.GDP_deflator(t);


    % REAL DEFLATED CAPITAL STOCK
    Sectors.tot_capital_defl(t,:) = ...
        Sectors.tot_capital_nominal(t,:) ./ Economy.GDP_deflator(t);


    %% emissions

    % Emissions flow
    Economy.emissions_flow(t) = ...
        sum(Divisions.emissions_flow(t,:), 2) + sum(Households.emissions_flow(t,:), 2) + Government.emissions_flow(t);
    
    % Emissions stock
    Economy.emissions_stock(t) = Economy.emissions_flow(t);


    %% create TXT files

    % We want to save some matrices and vectors (e.g. technical coefficients, productivities, etc)..
    % ..into txt files that will then be imported into the respective Latex tables in the paper.
    % So, in the txt files we will write the tables in Latex language.
    % Note:
        % Double backslash "\\" is needed so that "fprintf" writes one backslash "\".
        % "\n" tells fprintf that it should create a new line.


    % Create a folder named "txt_files_for_paper" (if it doesn't exist already) where to store all txt files
    if ~exist('txt_files_for_paper', 'dir')
       mkdir('txt_files_for_paper')
    end
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%  PRODUCTIVITY MATRIX  %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Create the txt file
    txt_file_productivities = fopen('txt_files_for_paper/capital_productivities.txt', 'w');
    
    % Write the very first item in the Latex table, i.e. the vertical text "16 Products"
    fprintf(txt_file_productivities, '\\multirow{\\nrproducts}{*}{\\begin{sideways} \\textbf{\\nrproducts\\ Products} \\end{sideways}}');
    
    % Write the txt file row after row
    for i = 1 : Parameters.Sections.nr

        % The second column in the Latex table contains the names of the products
        fprintf(txt_file_productivities, ' & %s', Parameters.Sections.names_adj_as_products(i));                
        
        % Within each row, write the txt file Division after Division
        for j = 1 : Parameters.Divisions.nr                

            % If, within the current row, we are considering the last item, we want the row to end with "\\", and we also want to instruct the "fprintf" command to create a new line ("\n")..
            if j == Parameters.Divisions.nr
                
                if Parameters.Divisions.capital_assets_logical_matrix(i,j) == 0
                    % If i-th product isn't used as capital asset by j-th industry, we want a blank space
                    fprintf(txt_file_productivities, ' & \\\\ \n');
                else               
                    fprintf(txt_file_productivities, ' & %0.1f \\\\ \n', initial_capital_productivity(i,j));
                end

            % ..Otherwise, just write the technical coefficient.
            else

                if Parameters.Divisions.capital_assets_logical_matrix(i,j) == 0
                    % If i-th product isn't used as capital asset by j-th industry, we want a blank space
                    fprintf(txt_file_productivities, ' &');
                else
                    fprintf(txt_file_productivities, ' & %0.1f', initial_capital_productivity(i,j));
                end
            end                           
        end
    end
    
    % Close the txt file
    fclose(txt_file_productivities);  



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%  DEPRECIATION RATES  %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Create the txt file
    txt_file_depreciation_rates = fopen('txt_files_for_paper/depreciation_rates.txt', 'w');
    
    % Write the very first item in the Latex table, i.e. the vertical text "16 Products"
    fprintf(txt_file_depreciation_rates, '\\multirow{\\nrproducts}{*}{\\begin{sideways} \\textbf{\\nrproducts\\ Products} \\end{sideways}}');
    
    % Write the txt file row after row
    for i = 1 : Parameters.Sections.nr

        % The second column in the Latex table contains the names of the products
        fprintf(txt_file_depreciation_rates, ' & %s', Parameters.Sections.names_adj_as_products(i));                
        
        % Within each row, write the txt file Division after Division
        for j = 1 : Parameters.Divisions.nr                

            % If, within the current row, we are considering the last item, we want the row to end with "\\", and we also want to instruct the "fprintf" command to create a new line ("\n")..
            if j == Parameters.Divisions.nr
                
                if Parameters.Divisions.capital_assets_logical_matrix(i,j) == 0
                    % If i-th product isn't used as capital asset by j-th industry, we want a blank space
                    fprintf(txt_file_depreciation_rates, ' & \\\\ \n');
                else               
                    fprintf(txt_file_depreciation_rates, ' & %.0f\\%% \\\\ \n', 100 * Parameters.Divisions.depreciation_rates(i,j));
                end

            % ..Otherwise, just write the technical coefficient.
            else

                if Parameters.Divisions.capital_assets_logical_matrix(i,j) == 0
                    % If i-th product isn't used as capital asset by j-th industry, we want a blank space
                    fprintf(txt_file_depreciation_rates, ' &');
                else
                    fprintf(txt_file_depreciation_rates, ' & %.0f\\%%', 100 * Parameters.Divisions.depreciation_rates(i,j));
                end
            end                           
        end
    end
    
    % Close the txt file
    fclose(txt_file_depreciation_rates);  


    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%  TECHNICAL COEFFICIENTS  %%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Create the txt file
    txt_file_tech_coeff = fopen('txt_files_for_paper/technical_coefficients.txt', 'w');
    
    % Write the very first item in the Latex table, i.e. the vertical text "16 Products"
    fprintf(txt_file_tech_coeff, '\\multirow{\\nrproducts}{*}{\\begin{sideways} \\textbf{\\nrproducts\\ Products} \\end{sideways}}');
    
    % Write the txt file row after row
    for i = 1 : Parameters.Sections.nr

        % The second column in the Latex table contains the names of the products
        fprintf(txt_file_tech_coeff, ' & %s', Parameters.Sections.names_adj_as_products(i));                
        
        % Within each row, write the txt file Division after Division
        for j = 1 : Parameters.Divisions.nr                

            % If, within the current row, we are considering the last item, we want the row to end with "\\", and we also want to instruct the "fprintf" command to create a new line ("\n")..
            if j == Parameters.Divisions.nr

                % If we are considering a technical coefficient that experiences changes due to electrification, in a fossil-fuel row, we want to have it bold and purple in the Latex table..             
                if ismember(i, Parameters.Sections.idx_fossil_fuels) && ~ismember(Parameters.Divisions.names(j), Parameters.Divisions.IEAcategory.names.no_energy_transition)
                    fprintf(txt_file_tech_coeff, ' & \\textcolor{Mulberry}{\\textbf{%0.3f}} \\\\ \n', Parameters.Divisions.C(i,j));
                % If we are considering a technical coefficient that experiences changes due to electrification, in an electricity row, we want to have it bold and blue in the Latex table..
                elseif ismember(i, Parameters.Sections.idx_electricity_producing_and_transmitting) && ~ismember(Parameters.Divisions.names(j), Parameters.Divisions.IEAcategory.names.no_energy_transition)
                    fprintf(txt_file_tech_coeff, ' & \\textcolor{Turquoise}{\\textbf{%0.3f}} \\\\ \n', Parameters.Divisions.C(i,j));
                % .. Otherwise, we don't want it bold.
                else
                    fprintf(txt_file_tech_coeff, ' & %0.3f \\\\ \n', Parameters.Divisions.C(i,j));
                end

            % ..Otherwise, just write the technical coefficient.
            else

                % If we are considering a technical coefficient that experiences changes due to electrification, in a fossil-fuel row, we want to have it bold and purple in the Latex table..             
                if ismember(i, Parameters.Sections.idx_fossil_fuels) && ~ismember(Parameters.Divisions.names(j), Parameters.Divisions.IEAcategory.names.no_energy_transition)
                    fprintf(txt_file_tech_coeff, ' & \\textcolor{Mulberry}{\\textbf{%0.3f}}', Parameters.Divisions.C(i,j));
                % If we are considering a technical coefficient that experiences changes due to electrification, in an electricity row, we want to have it bold and blue in the Latex table..
                elseif ismember(i, Parameters.Sections.idx_electricity_producing_and_transmitting) && ~ismember(Parameters.Divisions.names(j), Parameters.Divisions.IEAcategory.names.no_energy_transition)
                    fprintf(txt_file_tech_coeff, ' & \\textcolor{Turquoise}{\\textbf{%0.3f}}', Parameters.Divisions.C(i,j));
                % .. Otherwise, we don't want it bold.
                else
                    fprintf(txt_file_tech_coeff, ' & %0.3f', Parameters.Divisions.C(i,j));
                end

            end                           
        end
    end
    
    % Close the txt file
    fclose(txt_file_tech_coeff); 



    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%  EMISSION INTENSITIES  %%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

    % First, let's express the emission intensity in tons instead of Gigatons, as this makes it more readable in the Latex table
    emission_intensities_in_tons = round(how_many_t_in_one_Gt * Parameters.Divisions.emission_intensities);
    
    % Create the txt file
    txt_file_emission_intensities = fopen('txt_files_for_paper/emission_intensities.txt', 'w');                            

    % Write the thing to be displayed in the first column of the table
    fprintf(txt_file_emission_intensities, '\\makecell{tons of $CO_2$ equivalents\\\\per physical unit of output}');                
    
    % Write the txt file Division after Division
    for j = 1 : Parameters.Divisions.nr                

        % If we are considering the last item, we want the row to end with "\\"..
        if j == Parameters.Divisions.nr

            % If we are considering an emission intensity that experiences changes due to electrification, we want to have it bold in the Latex table..
            if ~ismember(Parameters.Divisions.names(j), Parameters.Divisions.IEAcategory.names.no_energy_transition)        
                fprintf(txt_file_emission_intensities, ' & \\textcolor{Mulberry}{\\textbf{%d}} \\\\', emission_intensities_in_tons(j));
            % .. Otherwise, we don't want it bold.
            else
                fprintf(txt_file_emission_intensities, ' & %d \\\\', emission_intensities_in_tons(j));
            end

        % ..Otherwise, just write the emission intensity value.
        else

            % If we are considering an emission intensity that experiences changes due to electrification, we want to have it bold in the Latex table..
            if ~ismember(Parameters.Divisions.names(j), Parameters.Divisions.IEAcategory.names.no_energy_transition)
                fprintf(txt_file_emission_intensities, ' & \\textcolor{Mulberry}{\\textbf{%d}}', emission_intensities_in_tons(j));
            % .. Otherwise, we don't want it bold.
            else
                fprintf(txt_file_emission_intensities, ' & %d', emission_intensities_in_tons(j));
            end
        end                           
    end
    
    % Close the txt file
    fclose(txt_file_emission_intensities);  




    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%  PRICING MARKUPS  %%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%             
    
    % Create the txt file
    txt_file_pricing_markups = fopen('txt_files_for_paper/pricing_markups.txt', 'w');          
    
    % Write the txt file Division after Division
    for j = 1 : Parameters.Divisions.nr                
            
        if j == Parameters.Divisions.nr                
            % If we are considering the last item, we want the row to end with "\\"..
            fprintf(txt_file_pricing_markups, ' & %0.2f \\\\', Parameters.Divisions.constant_mark_up(j));                            
        else                    
            % ..Otherwise, just write the emission intensity value.
            fprintf(txt_file_pricing_markups, ' & %0.2f', Parameters.Divisions.constant_mark_up(j));
        end                           
    end
    
    % Close the txt file
    fclose(txt_file_pricing_markups);  



    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%  HH DEMAND RELATIONS VECTOR  %%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

    % First, let us rescale the demand relations vector by normalizing it to the "ICT equipment" value.
    % We do so just to make it easier to explain it in the paper.
    hh_demand_relations_rescaled = Parameters.Households.exiobase_demand_relations_phys / Parameters.Households.exiobase_demand_relations_phys(Parameters.Sections.names == "ICT");
    
    % Create the txt file
    txt_file_hh_demand_relations = fopen('txt_files_for_paper/hh_demand_relations.txt', 'w');
    
    % Write the very first item in the Latex table, i.e. the vertical text "16 Products"
    fprintf(txt_file_hh_demand_relations, '\\multirow{\\nrproducts}{*}{\\begin{sideways} \\textbf{\\nrproducts\\ Products} \\end{sideways}}');
    
    % Write the txt file row after row
    for i = 1 : Parameters.Sections.nr

        % The second column in the Latex table contains the names of the products
        fprintf(txt_file_hh_demand_relations, ' & %s', Parameters.Sections.names_adj_as_products(i));                                                                       
        
        % If we are considering a value that experiences changes due to electrification, in a fossil-fuel row, we want to have it bold and purple in the Latex table.. 
        if ismember(i, Parameters.Sections.idx_fossil_fuels)
            fprintf(txt_file_hh_demand_relations, ' & \\textcolor{Mulberry}{\\textbf{%0.3f}} \\\\ \n', hh_demand_relations_rescaled(i));
        % If we are considering a value that experiences changes due to electrification, in an electricity row, we want to have it bold and blue in the Latex table..
        elseif ismember(i, Parameters.Sections.idx_electricity_producing_and_transmitting)
            fprintf(txt_file_hh_demand_relations, ' & \\textcolor{Turquoise}{\\textbf{%0.3f}} \\\\ \n', hh_demand_relations_rescaled(i));
        % .. Otherwise, we don't want it bold.
        else
            fprintf(txt_file_hh_demand_relations, ' & %0.3f \\\\ \n', hh_demand_relations_rescaled(i));
        end
                                   
    end
    
    % Close the txt file
    fclose(txt_file_hh_demand_relations);




    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%  GOV'T DEMAND RELATIONS VECTOR  %%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % First, let us rescale the demand relations vector by normalizing it to the "Manufacturing" value.
    % We do so just to make it easier to explain it in the paper.
    govt_demand_relations_rescaled = Parameters.Government.exiobase_demand_relations_phys / Parameters.Government.exiobase_demand_relations_phys(Parameters.Sections.names == "Manufacturing");
    
    % Create the txt file
    txt_file_govt_demand_relations = fopen('txt_files_for_paper/govt_demand_relations.txt', 'w');
    
    % Write the very first item in the Latex table, i.e. the vertical text "16 Products"
    fprintf(txt_file_govt_demand_relations, '\\multirow{\\nrproducts}{*}{\\begin{sideways} \\textbf{\\nrproducts\\ Products} \\end{sideways}}');
    
    % Write the txt file row after row
    for i = 1 : Parameters.Sections.nr

        % The second column in the Latex table contains the names of the products
        fprintf(txt_file_govt_demand_relations, ' & %s', Parameters.Sections.names_adj_as_products(i));                                                                       
                
        % Print the value
        fprintf(txt_file_govt_demand_relations, ' & %0.3f \\\\ \n', govt_demand_relations_rescaled(i));        
                                   
    end
    
    % Close the txt file
    fclose(txt_file_govt_demand_relations);


end
    
