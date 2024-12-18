function [Rules, Parameters, Sections, Sectors, Divisions, Bank, Households, CentralBank, Government, Economy, Tests] = ...
    Triode_g1_sim(sim_counter, Variations)
%% INSTRUCTIONS WHEN CHANGING CALIBRATION YEAR

% When you change the year from which you take data from Exiobase and EuKlems--e.g. move from 2015 to 2020--there are some things you need to do.

% Parameters.calibration_year

% Changing the calibration year will imply a change in the definition of Triode's physical units of electricity (i.e. the correspondence to real-world TWh) 
    % ..this will happen automatically in the Inizialization file (see "Parameters.electricity_units_to_TWh")
    % ..instead, you'll have to change it manually in the Latex file.
    % And you need to change it manually also in the Excel file where you compute the productivities of the electricity sectors, which will change as well.

% Green share and weights?
% Electrification, fossilization, carbonization?


%% GUIDELINES & CONVENTIONS

% STOCKS AND FLOWS
% We follow the convention that stocks in the current period are the result of previous stocks plus current flows
    % e.g. Capital(t) = Capital(t-1) + Investment(t)
% Flows in the current period are dependent on stocks of the previous period
    % in other words, Stock(t-1) --> Flow(t) --> Stock(t) --> Flow(t+1) --> Stock(t+1) --> Flow(t+2) --> ...


% PRICES
% The following things are being transacted/valued at previous-period prices:
    % intermediate inputs
    % investment goods (and thus also nominal depreciation)
    % inventories


%% CLEARING AND PATHS

% CLEARING WORKSPACE, COMMAND WINDOW, AND CLOSING IMAGES
%clc
%clearvars -except Data % Parameters Sections Sectors Bank Households CentralBank Government Economy  % "Data" is the structure that contains data for our figures that compare different policies
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
% %cd(folder)
% % Add that folder plus all subfolders to the path.
% addpath(genpath(folder));
% clear folder


%% RUN THE INITIALIZATION FUNCTION

[Rules, Parameters, Sections, Sectors, Divisions, Bank, Households, CentralBank, Government, Economy] = ...
    Triode_g1_initial(sim_counter, Variations);


%% COMMENTS ON TESTS

% TEST TO BE RUN AT THE END, OUTSIDE THE LOOP
% 1. Here we run the tests that can be run indifferently from period 1 till the end.
    % Indeed, some tests may be performed in a little different way in period 1 than in the subsequent periods,..
    % ..because some variables in the test are expressed at time (t) while others at time (t-1) ..
    % ..--> at t=1 you cannot run a test with variables expressed at time (t-1).
% 2. Also, here you should run the tests reporting not errors but warning messages.
    % Indeed, if you would run them inside the loop, then you will probably not even notice the warning messages.
    % This is because a warning message doesn't stop the code, so you may miss it in the command window among other printed stuff.


% TESTS TO BE RUN INSIDE THE LOOP
% Here you should run the test


%% LOOP
for t = 2 : Parameters.T
    %% time-dependent rules

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%   TIME-DEPENDENT RULES   %%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % ENERGY TRANSITION SCENARIO RULE    
    if t < Parameters.simulations_kickoff_after_stabilization
        Rules.energy_transition{t} = "NT";
    else
        if numel(Variations.energy_transition_rule) > 1
            Rules.energy_transition{t} = Variations.energy_transition_rule(sim_counter);
        else
            Rules.energy_transition{t} = Variations.energy_transition_rule;
        end
    end        


    %% expected final demand

    % SECTIONAL LEVEL
    % Hhs, investing sectors, and gov't formulate final demand at the sectional level, 
    % ..because they cannot distinguish between green and brown electricity.

    % EXPECTED REAL (PHYSICAL) FINAL DEMAND 
    % We assume that sections expect a final real demand equal to the sum of:
        % hhs' demand:
            % if known by sections: current period orders from hhs
            % if unkown by sections: real expected household demand
        % current period orders from investing sectors (these aren't therefore expected, but certain). These orders depend on investment demand defined in the previous period.
        % current period orders from gov't (these aren't therefore expected, but certain). These orders depend on gov't demand defined in the previous period.    

    % Time span over which average growth rate of hhs physical demand is computed
    time_span_avg_growth_rate_hh_phys_demand = 5; 

    if Rules.hhs_demand_exp == "known"

        % We assume an exogenously growing hhs' demand
        hhs_demand_exog_growth_rate = 0.03;
        Sections.demand_from_hhs_phys(:,:,t) = (1 + hhs_demand_exog_growth_rate) * Sections.demand_from_hhs_phys(:,:,t-1);        
    
        Sections.final_demand_phys_exp(:,t) = ...
            sum(Sections.demand_from_hhs_phys(:,:,t), 2) ...
            + sum(Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys(:,:,t-1), 2) ...
            + Sections.demand_in1year_from_govt_phys(:,t-1);

    elseif Rules.hhs_demand_exp == "unknown & naive" || (Rules.hhs_demand_exp == "unknown & complex" && t <= (time_span_avg_growth_rate_hh_phys_demand + 1))

        Sections.final_demand_phys_exp(:,t) = ...
            sum((1 + Parameters.Sections.exp_hh_demand_correction) .* Sections.demand_from_hhs_phys(:,:,t-1), 2) ...
            + sum(Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys(:,:,t-1), 2) ...
            + Sections.demand_in1year_from_govt_phys(:,t-1);

    elseif Rules.hhs_demand_exp == "unknown & complex"
        
        Sections.final_demand_phys_exp(:,t) = ...
            (1 + mean(Sections.demand_from_hhs_phys_growth_rate(:, (t - time_span_avg_growth_rate_hh_phys_demand : t-1)), 2)) .* sum(Sections.demand_from_hhs_phys(:,:,t-1), 2) ...
            + sum(Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys(:,:,t-1), 2) ...
            + Sections.demand_in1year_from_govt_phys(:,t-1);

    end    

   
    %% Triode's core function
      
    % We assume that when planning the total real (physical) amount they want to produce, Sectors.. 
    % .. (1) consider their expected real final demand; (2) as a consequence they place orders with suppliers; (3) they take orders from customers which are also placing orders given their expected real final demand.
    % Thus, we use the Leontief quantity model to compute the real total amount Sectors plan to produce.
    % Note that the Leontief quantity model captures all round-by-round effects of a change in final demand,
        % i.e., basically we are capturing not only the fact that a sector places orders with suppliers given its expected final demand..
        % .. but also the fact that the sector will place additional orders with suppliers once it receives orders from customers.
        % NOTE: maybe it is unrealistic to assume that Sectors' planned production takes into account all the round-by-round effects. 
            % In other words, we are assuming that we reach a sort of equilibrium in planning for production. But maybe this is not a crucial point in the model and we can leave it like this.


    % PRODUCTION CONSTRAINTS    
    % Are Sectors able to produce what they plan? 
    % This will depend on Sectors' maximal possible production given constraints in production factors.
    % Basically, constraints to production arise from availability of: intermediate inputs, capital, labor (but we assume no labor for the time being).
    % If for all Sectors there are no constraints from capital and labor (e.g. because both are abundant), then a sector is able to produce the planned amount, .. 
        %.. since the only constraining factor would be intermediate inputs but these are available in the necessary amount since the level of other Sectors' planned production is taking into account intermediate input orders from other Sectors.
    % Instead, if capital and/or labor constrain production below the planned level for at least one Sector, ..
        %.. then this implies that also other Sectors won't be able to produce the planned amount because they won't receive the required level of intermediate inputs from the constrained Sector.


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
    % it is a Leontief production function, where the production factors are the different capital assets held by each Division.
    % I.e., the max production of each Division is the minimum value among the values obtained multiplying capital productivities with the respective capital assets.
    % First, for each Division, we compute the max amount each of its capital assets is able to produce..        
    Divisions.prod_cap_of_each_capital_asset(:,:,t) = ...
        Divisions.capital_productivity(:,:,t-1) .* Divisions.capital_phys(:,:,t-1);
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
        % For the Green Divisions (and all the other Divisions)
        else
            Divisions.sectoral_weights(t,j) = ...
                Divisions.prod_cap(j,t) ./ Sectors.prod_cap(Parameters.Divisions.sector_idx(j), t);
        end
    end
    % TEST
    % Weights should not be <0 nor >1
    if any(Divisions.sectoral_weights(t,:) < 0, 'all') || any(Divisions.sectoral_weights(t,:) > 1, 'all')
        error('At time step %d, there is at least one negative value or one value >1 in ''Divisions.sectoral_weights''', t)
    end
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
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
    % Sectors' production constraints
        % In an economy without the green/brown electricity distinction: it is the constraints implied by the sectors' unbound level of production, i.e. = (max production) / (unbound production).
        % In an economy with the green/brown electricity distinction: 
            % for all the sectors except the green one, it is the constraints implied by the sectors' unbound level of production, i.e. = (max production) / (unbound production).
            % for the green sector, it simply is 100% (meaning no constraint).
    % Sections' production constraints
        % It simply is the sectional version of the sectors' production constraints.                
    
    [Sectors.C_square(:,:,t), Economy.green_share_production(t), Sectors.products_available_for_final_demand_phys(:,t),...
        Sectors.production_phys(:,t), Sectors.production_unbound_minus_inventories_phys(:,t)] = ...
            Triode_Production ... % name of the function
                (Rules.target_green_share_enforcement, Rules.rationing, Parameters.Sectors.idx, Parameters.Sectors.section_idx, ...
                Parameters.Sections.idx_electricity_producing, Parameters.Sectors.idx_green, Parameters.Sectors.idx_brown, Sectors.C_rectangular(:,:,t), ...
                Sections.final_demand_phys_exp(:,t), Sectors.prod_cap(:,t), ...
                Sectors.inventories_phys(:,t-1), Parameters.Sectors.target_green_share(t));    
    
    % BROWN DIVISIONS WEIGHTING
    % Keeping track of which weighting procedure we are using for the brown electricity Divisions
    Economy.brown_divisions_weighting_for_Triode_Production_function(t) = "target weights";


    % If the Brown Sector is producing close to its maximum production..
    % ..then we have to redifine some stuff and re-run the function: see description above ("DIVISIONS VS SECTORS / GENERAL DESCRIPTION OF THE WHOLE BELOW PROCESS").
    if (Sectors.production_phys(Parameters.Sectors.idx_brown, t) / Sectors.prod_cap(Parameters.Sectors.idx_brown, t)) > 0.95

        % BROWN DIVISIONS WEIGHTING
        % Keeping track of which weighting procedure we are using for the brown electricity Divisions
        Economy.brown_divisions_weighting_for_Triode_Production_function(t) = "weights implied by production capacities";
        
        % SECTORS' PRODUCTION CAPACITY
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

        % FUNCTION
        [Sectors.C_square(:,:,t), Economy.green_share_production(t), Sectors.products_available_for_final_demand_phys(:,t),...
        Sectors.production_phys(:,t), Sectors.production_unbound_minus_inventories_phys(:,t)] = ...
            Triode_Production ... % name of the function
                (Rules.target_green_share_enforcement, Rules.rationing, Parameters.Sectors.idx, Parameters.Sectors.section_idx, ...
                Parameters.Sections.idx_electricity_producing, Parameters.Sectors.idx_green, Parameters.Sectors.idx_brown, Sectors.C_rectangular(:,:,t), ...
                Sections.final_demand_phys_exp(:,t), Sectors.prod_cap(:,t), ...
                Sectors.inventories_phys(:,t-1), Parameters.Sectors.target_green_share(t));

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%   END OF THE FUNCTION   %%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % SECTORS' PRODUCTION CONSTRAINTS
    % = (production capacity) / (unbound, ideal production)
    % The latter is the production level implied by the final demand vector, without considering the sectoral production capacities, ..
    % ..except for the green electricity sector, which complies with its production capacity and with the target green share
    % (i.e. the actual green share is the minimum between the green share implied by its production capacity and the target green share).    
    Sectors.production_constraints(:,t) = ...
        Sectors.prod_cap(:,t) ./ Sectors.production_unbound_minus_inventories_phys(:,t);
    
    % SECTIONS' PRODUCTION CONSTRAINTS
    for i = 1 : Parameters.Sections.nr
        idx = Parameters.Sectors.section_idx == i;
        Sections.production_constraints(i,t) = ...
            sum(Sectors.prod_cap(idx, t)) ./ sum(Sectors.production_unbound_minus_inventories_phys(idx, t));
    end

    
    %%%%  TESTS  %%%%

    % Test
    if any(Sectors.C_square(:,:,t) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Sectors.C_square''', t)
    end

    % Test
    if any(Sectors.products_available_for_final_demand_phys(:,t) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Sectors.products_available_for_final_demand_phys''', t)
    end

    % Test
    if any(Sectors.production_phys(:,t) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Sectors.production_phys''', t)
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
    % TEST
    % Weights should not be <0 nor >1
    if any(Divisions.sectional_weights(t,:) < 0, 'all') || any(Divisions.sectional_weights(t,:) > 1, 'all')
        error('At time step %d, there is at least one negative value or one value >1 in ''Divisions.sectional_weights''', t)
    end
    % Weights must sum to 1.
    aggregating_weights_test = NaN * ones(1, Parameters.Sections.nr);
    for i = 1 : Parameters.Sections.nr
        idx_divisions_belonging_to_section_i = find(Parameters.Divisions.section_idx == i);
        aggregating_weights_test(i) = ...
            sum(Divisions.sectional_weights(t, idx_divisions_belonging_to_section_i), 2);
    end
    if any(abs(1 - aggregating_weights_test) > Parameters.error_tolerance_strong, 'all')
        error('At time step %d, the sum across weights in the electricity Divisions does not equal 1', t)
    end


    % DIVISIONS' CAPACITY UTILIZATION OF EACH ASSET
    % Each division has a capacity utilization value for each of its capital assets j.
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
    % Test
    % Values should not be <0 nor >1
    if any(Divisions.capacity_utilization_of_each_asset(:,:,t) < 0, 'all') || any(Divisions.capacity_utilization_of_each_asset(:,:,t) > 1 + Parameters.error_tolerance_medium, 'all')
        error('At time step %d, there is at least one negative value or one value >1 in ''Divisions.capacity_utilization_of_each_asset''', t)
    end


    % DIVISIONS' HIGHEST VALUE OF CAPACITY UTILIZATION
    % For each Division, we store the highest capacity utilization value among its assets.
    Divisions.capacity_utilization_highest_value(t,:) = ...
        max(Divisions.capacity_utilization_of_each_asset(:,:,t));


    % DIVISIONS' REAL (PHYSICAL) CAPITAL DEPRECIATION
    if Rules.depreciation == "entire capital"
        divisions_capital_depreciation_phys = ...
            Parameters.Divisions.depreciation_rates .* Divisions.capital_phys(:,:,t-1);
    else
        divisions_capital_depreciation_phys = ...
            Parameters.Divisions.depreciation_rates .* Divisions.capacity_utilization_of_each_asset(:,:,t) .* Divisions.capital_phys(:,:,t-1);
    end
    % Sectoral level
    sectors_capital_depreciation_phys = NaN * ones(Parameters.Sections.nr, Parameters.Sectors.nr);
    for i = 1 : Parameters.Sectors.nr
        idx_divisions_belonging_to_sector_i = find(Parameters.Divisions.sector_idx == i);
        sectors_capital_depreciation_phys(:,i) = ...
            sum(divisions_capital_depreciation_phys(:, idx_divisions_belonging_to_sector_i), 2);
    end 


    % REAL (PHYSICAL) INTERINDUSTRY TRANSACTIONS (of intermediate inputs)
    Sectors.S_square(:,:,t) = ...
        Sectors.C_square(:,:,t) * diag(Sectors.production_phys(:,t)); 
    % This is Eq. 2.42 (inverted) of Miller & Blair (II edition), i.e. C = S*(q^)^-1


    % SECTIONS' PHYSICAL INTERMEDIATE SALES (TOTALS)    
    % Total sectoral intermediate sales (physical)
    sectors_intermediate_sales_total = sum(Sectors.S_square(:,:,t), 2);    
    % Total sectional intermediate sales (physical)
    aggregation_rule = "values of sectors belonging to the same section get summed";
    Sections.intermediate_sales_aggr_phys(:,t) = ...
        From_Sectors_To_Sections_Function(aggregation_rule, sectors_intermediate_sales_total, Parameters.Sectors.section_idx); 
    clear aggregation_rule    
    

    % SECTORAL PRODUCTION FOR FINAL DEMAND
    % We need these arrays when computing real GDP
    % This vector will differ from "Sectors.products_available_for_final_demand_phys" when there are inventories!
    % Note that since there are inventories, you cannot simply define this vector as: (production) - (intermediate_sales)
    % ..indeed, the result could even become negative if a sector produced less than intermediate sales because it knew it had sufficient inventories in stock.
    % Instead, you should define it as:
    % = [production(t)] - max{0, [intermediate_sales(t) - inventories(t-1)]}
    % ..which assumes that a sector first sells inventories to intermediate purchasers, and what is then left over of those inventories will then be sold to final demand.
    Sectors.production_for_final_demand_phys(:,t) = ...
        Sectors.production_phys(:,t) - max(0, sum(Sectors.S_square(:,:,t), 2) - Sectors.inventories_phys(:,t-1));
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


    % DIVISIONS' EMISSIONS FLOW
    Divisions.emissions_flow(t,:) = Divisions.emission_intensities(t,:) .* Divisions.production_phys(:,t)';
    % Test
    if any(Divisions.emissions_flow(t,:) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Divisions.emissions_flow''', t)
    end
    for i = 1 : Parameters.Sectors.nr
        idx_divisions_belonging_to_sector_i = find(Parameters.Divisions.sector_idx == i);
        Sectors.emissions_flow(t,i) = ...
            sum(Divisions.emissions_flow(t, idx_divisions_belonging_to_sector_i), 2);
    end



    %% prices
    
    % We assume that Divisions set prices by applying a mark-up on unit costs.


    % NOMINAL CAPITAL DEPRECIATION
    % is valued at replacement cost
    % We use previous period prices because investment purchases are made at previous period prices.
    Sectors.capital_depreciation_nominal(t,:) = ...
        sum(sectors_capital_depreciation_phys .* Sections.prices(t-1,:)');
    Divisions.capital_depreciation_nominal(t,:) = ...
        sum(divisions_capital_depreciation_phys .* Sections.prices(t-1,:)');


    %%%%%%%%%%%  UNIT COSTS  %%%%%%%%%%%

    % we allow for two different unit cost measures:
        % = (intermediate input unit costs) + (nominal capital depreciation per unit of products)
        % = (intermediate input unit costs)
    % We assume that sectors trade interindustry inputs at previous period prices.

    % Intermediate inputs unit costs
    Divisions.intermediate_inputs_unit_costs(t,:) = ...
        Sections.prices(t-1,:) * Divisions.C_rectangular(:,:,t);

    % Capital depreciation unit costs
    Divisions.capital_depreciation_unit_costs(t,:) = ...
        Divisions.capital_depreciation_nominal(t,:) ./ Divisions.production_phys(:,t)'; 
    
    % Total unit costs
    if Rules.unit_costs == "including capital depreciation"                       

        % If Division i's production is zero AND if depreciation affects the entire capital stock (and not just the utilized portion), then depreciation unit costs would be infinite.
        % We want to avoid this, otherwise the price of Division i would be infinite. Therefore, in this case we set the unit costs to be equal to the previous period's ones.
        % The only exception is if we are considering a Brown Electricity Division: in that case, it's fine to have unit costs equal to infinite.

        for i = 1 : Parameters.Divisions.nr            
            if Divisions.production_phys(i,t) == 0 && Rules.depreciation == "entire capital" && i ~= Parameters.Divisions.idx_brown
                Divisions.unit_costs(t,i) = Divisions.unit_costs(t-1,i);
            else
                Divisions.unit_costs(t,i) = ...
                    Divisions.intermediate_inputs_unit_costs(t,i) + Divisions.capital_depreciation_unit_costs(t,i);
            end
        end
    
    elseif Rules.unit_costs == "not including capital depreciation"
                      
        Divisions.unit_costs(t,:) = Divisions.intermediate_inputs_unit_costs(t,:);
    
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


    
    % MARK-UP "DESIRED"    
        % The "desired" mark-up is the one that Divisions would like to apply.        
        % However, since the green and brown electricity Divisions have to sell at the same price,..
        % ..the "actual" mark-up will be different from the "desired" one.
    % The "desired" mark-up may be determined according to different rules: 
        % "constant: arbitrary"           --> the markup is constant and uniform across sectors (exogenously and arbitrarily set)
        % "constant: Exiobase"            --> the markup is constant, but sector-specific, and derived from Exiobase
        % "variable: demand vs supply"    --> the markup is variable and can move within a range, depending on the discrepancy of supply vs demand. The more the supply is abundant compared to expected demand, the lower the markup. See also description in Overleaf.        
            
    if Rules.markup == "constant: arbitrary" || Rules.markup == "constant: Exiobase"
        
        Divisions.mark_up_desired(t,:) = Parameters.Divisions.constant_mark_up;

    elseif Rules.markup == "variable: demand vs supply"

        for i = 1 : Parameters.Divisions.nr
    
            idx_section = Parameters.Divisions.section_idx(i);
         
            if Sections.final_demand_phys_exp(idx_section, t) > (1 + Parameters.Divisions.mark_up_max) * Sections.products_available_for_final_demand_phys(idx_section, t)
                Divisions.mark_up_desired(t,i) = Parameters.Divisions.mark_up_max;
            elseif (Sections.final_demand_phys_exp(idx_section, t) <= (1 + Parameters.Divisions.mark_up_max) * Sections.products_available_for_final_demand_phys(idx_section, t)) ...
                && (Sections.final_demand_phys_exp(idx_section, t) >= (1 + Parameters.Divisions.mark_up_min) * Sections.products_available_for_final_demand_phys(idx_section, t))
                Divisions.mark_up_desired(t,i) = ...
                    Sections.final_demand_phys_exp(idx_section, t) ./ Sections.products_available_for_final_demand_phys(idx_section, t) - 1;
            else
                Divisions.mark_up_desired(t,i) = Parameters.Divisions.mark_up_min;
            end
        end
    end

    % Test    
    if any(Divisions.mark_up_desired(t,:) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Divisions.mark_up_desired''', t)
    end


    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%   PRICE SETTING   %%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % = (1 + mark-up) * unit costs
        % For non-electricity Sectors: the price is simply given by the formula above.
        % For electricity Sectors: 
            % if (green share) < 1 
                % CASE_1: the price is the highest value among the green and brown's shadow prices.
            % if (green share) ≃ 1 --> we allow for two different rules:
                % CASE_2: "max price among green and brown, unless green share is 100%" --> when the green share is 100%, the price equals the green electricity price.
                % CASE_3: "max price among green and brown, always" --> even if the green share is 100%, the price is the highest value among the green and brown's shadow prices.
            % Note that ideally you should look at the green share in sales. However you don't know it yet (because households' physical demand depends on current prices), so you have to use the green share in production instead.    
    % NOTE: we need to exclude extremely high prices of electricity: 
        % CASE_4: when the green share is very high (e.g. above 90%), then the brown sector is producing very little, ..
        % ..implying that its unit costs are extremely high (if they include capital depreciation and if depreciation affects total--not used--capital).     
        % Solution: in this case, we assume that the electricity price is given by the green one.   



    %%%%%%%%%%%%%%%  SHADOW PRICES  %%%%%%%%%%%%%%%
    
    % We define as shadow price the hypothetical price that electricity Divisions/Sectors would apply considering their unit costs and markups.
    % But at the end, the actual price of electricity will be the same for all.

    % Divisions' shadow prices
    Divisions.shadow_prices(t,:) = ...
        (1 + Divisions.mark_up_desired(t,:)) .* Divisions.unit_costs(t,:);

    % Sectors' shadow prices
    for j = 1 : Parameters.Sectors.nr
        idx = Parameters.Divisions.sector_idx == j;
        if Rules.electricity_sectors_shadow_price == "max among all divisions within that sector" 
            Sectors.shadow_prices(t,j) = ...
                max(Divisions.shadow_prices(t, idx));
        elseif Rules.electricity_sectors_shadow_price == "weighted average among all divisions within that sector"
            Sectors.shadow_prices(t,j) = ...
                sum(Divisions.shadow_prices(t, idx) .* Divisions.sectoral_weights(t, idx));
        end
    end

    % Green vs brown shadow prices
    if Rules.electricity_sector_aggregation ~= "one_electricity_sector"
        Sectors.green_vs_brown_shadow_price(t) = ...
            Sectors.shadow_prices(t, Parameters.Sectors.idx_green) ./ Sectors.shadow_prices(t, Parameters.Sectors.idx_brown);
    end
    

    
    %%%%%%%%%%%%%%%  ACTUAL PRICES  %%%%%%%%%%%%%%%

    for i = 1 : Parameters.Sections.nr        

        % Case_2 and Case_4 (see definitions in description above)
        case_2 = (Economy.green_share_production(t) > 0.99) && (Rules.electricity_price == "max price among green and brown, unless green share is 100%");
        case_4 = (Economy.green_share_production(t) > 0.93)  &&  (Rules.unit_costs == "including capital depreciation")  &&  (Rules.depreciation == "entire capital");        

        if case_2 || case_4
            Sections.prices(t,i) = ...
                Sectors.shadow_prices(t, Parameters.Sectors.idx_green);                                               
        else
            Sections.prices(t,i) = ...
                max(Sectors.shadow_prices(t, Parameters.Sectors.section_idx == i));
        end
    end 

    % TEST
    % Check if any prices have become <= 0
    if any(Sections.prices(t,:) <= 0, 'all')
        error('At time step %d, there is at least one value that is <=0 in ''Sections.prices''', t)
    end

    % SECTORS' PRICES
    for i = 1 : Parameters.Sectors.nr        
        Sectors.prices(t,i) = Sections.prices(t, Parameters.Sectors.section_idx(i));
    end

    % SECTIONS' PRICES
    for i = 1 : Parameters.Divisions.nr        
        Divisions.prices(t,i) = Sections.prices(t, Parameters.Divisions.section_idx(i));
    end    

    %% households' final demand


    %%%%%%%%%%  FINAL DEMAND BUDGET  %%%%%%%%%%
    
    % We set a floor of 0 to the final demand budget; otherwise, if income is a large negative number, the budget could become negative as well, which we don't want.      

    if (Rules.hhs_consumption_budget_income == "rough" && Rules.hhs_consumption_budget_wealth == "rough") || t <= Parameters.Households.cons_budget_time_span_avg % if (t <= Parameters.Households.cons_budget_time_span_avg), we can't compute the average income and wealth yet..
        
        Households.final_demand_budget(t,:) = ... 
            max(0, ...
                Parameters.Households.MPC_income * Households.income(t-1,:) + ... 
                Parameters.Households.MPC_wealth * Households.net_worth(t-1,:) ...
                );
    
    elseif Rules.hhs_consumption_budget_income == "smooth" && Rules.hhs_consumption_budget_wealth == "rough" && t > Parameters.Households.cons_budget_time_span_avg
    
        Households.final_demand_budget(t,:) = ... 
            max(0, ...
                Parameters.Households.MPC_income * mean(Households.income((t - Parameters.Households.cons_budget_time_span_avg) : t-1, :)) + ... 
                Parameters.Households.MPC_wealth * Households.net_worth(t-1,:) ...
                );
    
    elseif Rules.hhs_consumption_budget_income == "rough" && Rules.hhs_consumption_budget_wealth == "smooth" && t > Parameters.Households.cons_budget_time_span_avg
    
        Households.final_demand_budget(t,:) = ... 
            max(0, ...
                Parameters.Households.MPC_income * Households.income(t-1,:) + ... 
                Parameters.Households.MPC_wealth * mean(Households.net_worth((t - Parameters.Households.cons_budget_time_span_avg) : t-1, :)) ...
                );

    elseif Rules.hhs_consumption_budget_income == "smooth" && Rules.hhs_consumption_budget_wealth == "smooth" && t > Parameters.Households.cons_budget_time_span_avg
    
        Households.final_demand_budget(t,:) = ... 
            max(0, ...
                Parameters.Households.MPC_income * mean(Households.income((t - Parameters.Households.cons_budget_time_span_avg) : t-1, :)) + ... 
                Parameters.Households.MPC_wealth * mean(Households.net_worth((t - Parameters.Households.cons_budget_time_span_avg) : t-1, :)) ...
                );
    
    end    
    

    % Test
    if any(Households.final_demand_budget(t,:) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Households.final_demand_budget''', t)
    end



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%  HOUSEHOLD'S DEMAND  %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % We allow for 3 alternative rules:    

     %%%%%%%  1. "FIXED PHYSICAL PROPORTIONS"  %%%%%%%
    % Household's physical demand for different goods isn't impacted by relative prices, and therefore physical demand relations are constant over time.
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

    %%%%%%%  2. "AIDS ELASTICITY"  %%%%%%%
    % When relative prices change, the household changes its physical demand behavior. 
    % I.e., in terms of physical proportions, it demands less of the good that has become relatively more expensive and more of the good that has become relatively cheaper.
    % We use the Almost Ideal Demand System (AIDS) as done in Jackson & Jackson "Modelling energy transition risk" (2021), Appendix B.2.2 and Table C.1 in Appendix C.
    % NOTE: you could actually implement this method by applying the formula to define the nominal demand weights, rather than the physical demand relations.
        % However, that would imply a more than perfect elasticity (where the latter is define below), which is, I believe, almost impossible to happen in reality.

    %%%%%%%  3. "FIXED NOMINAL PROPORTIONS"  %%%%%%%
    % The hh always allocates its final demand budget to the different goods according to the proportions defined in "Parameters.Households.demand_relations_phys_evolving".
    % In short, this case is exactly the opposite of the case defined in the "fixed physical proportions" case: instead of respecting relations in physical terms, we respect them in nominal terms.
    % E.g. imagine that the proportions defined in "Parameters.Households.demand_relations_phys_evolving" are 2 apples (A) to 3 bananas (B), and that the hh budget is 10€.
    % If prices where p_A=1 and p_B=1, the hhs budget would be allocated 4€ to A and 6€ to B --> in physical units: 4A and 6B.
    % If prices where p_A=2 and p_B=1, the hhs budget would be allocated 4€ to A and 6€ to B --> in physical units: 2A and 6B. The price of A has doubled, thus the units demanded halve.


    % AUTONOMOUS COEFFICIENTS VECTOR
    % ..capturing the weights of hh nominal spending on each good if prices were all equal.
    % If prices were all equal, we want the household to consume--in nominal and physical terms--..
    % ..according to the relations defined in "Parameters.Households.demand_relations_phys_evolving"
    Households.lambda_AIDS_autonomous_coefficients(:,t) = ...
        Parameters.Households.demand_relations_phys_evolving(:,t) ./ sum(Parameters.Households.demand_relations_phys_evolving(:,t));
    
    
    %%%%%%%  1. "FIXED PHYSICAL PROPORTIONS"  %%%%%%%
    if Rules.hhs_demand_elasticity == "fixed physical proportions"

        % PHYSICAL DEMAND AT THE SECTIONAL LEVEL
        % if hhs' demand was unknown by sections at the beginning of the period, it has to be defined now. 
        if Rules.hhs_demand_exp ~= "known"    
            % This is the real demand rescaling value z as described at the beginning of this section of code.
            Households.consumption_basket_units_demanded(t,:) = ...
                Households.final_demand_budget(t,:) ./ (Sections.prices(t,:) * Parameters.Households.demand_relations_phys_evolving(:,t));
            % Hhs' physical demand       
            Sections.demand_from_hhs_phys(:,:,t) = ...
                Households.consumption_basket_units_demanded(t,:) .* repmat(Parameters.Households.demand_relations_phys_evolving(:,t), 1, Parameters.Households.nr);
        end

        % NOMINAL DEMAND AT THE SECTIONAL LEVEL
        Sections.demand_from_hhs_nominal(:,:,t) = Sections.demand_from_hhs_phys(:,:,t) .* Sections.prices(t,:)';


    %%%%%%%  2. "AIDS ELASTICITY"  %%%%%%%
    elseif Rules.hhs_demand_elasticity == "AIDS elasticity"        

        % ADJUSTED PHYSICAL DEMAND RELATIONS
        % Physical demand relations adjust in response to changes in relative prices.
        % This formula is in line with the AIDS methodology. See equations (72)-(74) in Appendix B.2.2 cited above.
        % It's actually a bit unclear whether we should use logarithms in base "e" (natural log) or in base 10, but it seems more likely that we should use natural logarithms as they are more common in the economics discipline.
        Households.demand_relations_phys_adj_for_price_changes(:,t) = ...
            Households.lambda_AIDS_autonomous_coefficients(:,t) + Parameters.Households.lambda_AIDS_sensitivity_coefficients * log(Sections.prices(t,:)');

        % PHYSICAL DEMAND AT THE SECTIONAL LEVEL
        % if hhs' demand was unknown by sections at the beginning of the period, it has to be defined now. 
        if Rules.hhs_demand_exp ~= "known"    
            % This is the real demand rescaling value z as described at the beginning of this section of code.
            Households.consumption_basket_units_demanded(t,:) = ...
                Households.final_demand_budget(t,:) ./ (Sections.prices(t,:) * Households.demand_relations_phys_adj_for_price_changes(:,t));
            % Hhs' physical demand       
            Sections.demand_from_hhs_phys(:,:,t) = ...
                Households.consumption_basket_units_demanded(t,:) .* repmat(Households.demand_relations_phys_adj_for_price_changes(:,t), 1, Parameters.Households.nr);
        end

        % NOMINAL DEMAND AT THE SECTIONAL LEVEL
        Sections.demand_from_hhs_nominal(:,:,t) = Sections.demand_from_hhs_phys(:,:,t) .* Sections.prices(t,:)';


    %%%%%%%  3. "FIXED NOMINAL PROPORTIONS"  %%%%%%%
    elseif Rules.hhs_demand_elasticity == "fixed nominal proportions"

        % NOMINAL DEMAND AT THE SECTIONAL LEVEL
        Sections.demand_from_hhs_nominal(:,:,t) = ...
            Households.lambda_AIDS_autonomous_coefficients(:,t) .* Households.final_demand_budget(t,:);

        % PHYSICAL DEMAND AT THE SECTIONAL LEVEL
        Sections.demand_from_hhs_phys(:,:,t) = ...
            Sections.demand_from_hhs_nominal(:,:,t) ./ Sections.prices(t,:)';

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % HOUSEHOLDS' PHYSICAL DEMAND RELATIONS
    % Physical demand relations in percentage terms.
    % While this doesn't make much sense from a logical point of view, it helps capturing the demand relations among goods.
    % E.g. if at t=10 you demand 1 banana and 3 apples you can interpret it as a relation of 0.25 bananas every 0.75 apples.
    % If at t=11 you demand 2 bananas and 3 apples you can interpret it as a relation of 0.4 bananas every 0.6 apples.
    Households.phys_demand_relations(:,t) = ...
        Sections.demand_from_hhs_phys(:,1,t) ./ sum(Sections.demand_from_hhs_phys(:,1,t));


    % PHYSICAL DEMAND GROWTH RATE
    Sections.demand_from_hhs_phys_growth_rate(:,t) = ...
        (sum(Sections.demand_from_hhs_phys(:,:,t), 2) ./ sum(Sections.demand_from_hhs_phys(:,:,t-1), 2)) - 1;
    % For the fossil-fuels extraction Section, we need to set it to zero
    if ~isempty(Parameters.Sections.idx_demand_set_to_zero)
        Sections.demand_from_hhs_phys_growth_rate(Parameters.Sections.idx_demand_set_to_zero, t) = 0;
    end    


    % TESTS
    % Test
    if any(Sections.demand_from_hhs_phys(:,:,t) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Sections.demand_from_hhs_phys''', t)
    end
    % Test
    if Rules.hhs_demand_exp ~= "known" && abs(...
            (sum(Sections.demand_from_hhs_nominal(:,:,t), "all") - sum(Households.final_demand_budget(t,:), 2)) ...
            ./ sum(Sections.demand_from_hhs_nominal(:,:,t), "all")) ...
            > Parameters.error_tolerance_strong
        error('At time step %d, total households'' nominal demand differs from total households'' final demand budget', t)
    end


    %% real final demands & constraints to final demand

    % SECTIONAL PHYSICAL FINAL DEMAND
    % Total final demand (hhs + inv + gov't) faced by each section
    Sections.final_demand_phys(:,t) = ...
        sum(Sections.demand_from_hhs_phys(:,:,t), 2) ...
        + sum(Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys(:,:,t-1), 2) ...
        + Sections.demand_in1year_from_govt_phys(:,t-1);

    % SECTIONAL CONSTRAINTS IN THE FULFILLMENT OF EXPECTED FINAL DEMAND
    Sections.exp_final_demand_fulfillment_constraints(:,t) = ...
        Sections.products_available_for_final_demand_phys(:,t) ./ Sections.final_demand_phys_exp(:,t);

    % SECTIONAL CONSTRAINTS IN THE FULFILLMENT OF FINAL DEMAND
    Sections.final_demand_fulfillment_constraints(:,t) = ...
        Sections.products_available_for_final_demand_phys(:,t) ./ Sections.final_demand_phys(:,t);    


    %% sales to final demand and inventory accumulation

    % DESCRIPTION
    % We assume that Sectors sell their products to final demand buyers according to the following pecking order:
        % 1. investing Divisions
        % 2. households
        % 3. government
    % If available products are more than total final demand, each of the above demands gets satisfied.
    % Instead if available products are less than total final demand, Sectors will first try to satisfy orders by investing Sectors;
        % then, they'll try to satisfy orders by the hhs; finally, what is left will be sold to gov't.
        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%     SALES TO INVESTING DIVISIONS     %%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % INVESTMENTS RATIONING --> ADJUSTMENT OF INVESTMENT ORDERS
    % See description in the function or in the Latex file
    [Sections.current_orders_from_investing_divisions_adj_for_rationing_phys(:,:,t)] = ... 
        Triode_InvestmentsRationing(...
            Rules.investment_rationing, Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys(:,:,t-1), ...
            Divisions.capital_phys(:,:,t-1), Parameters.Divisions.depreciation_rates, Divisions.capital_productivity(:,:,t-1), ...
            Sections.products_available_for_final_demand_phys(:,t), Parameters.Sections.idx_capital_assets, Parameters.Divisions.capital_assets_logical_matrix);    
    % Test
    if any(Sections.current_orders_from_investing_divisions_adj_for_rationing_phys(:,:,t) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Sections.current_orders_from_investing_divisions_adj_for_rationing_phys''', t)
    end
    
    % DIVISIONS' NOMINAL INVESTMENTS
    Sections.sales_to_investing_divisions_nomin(:,:,t) = ...
        Sections.prices(t-1,:)' .* Sections.current_orders_from_investing_divisions_adj_for_rationing_phys(:,:,t);
    
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
        Sectors.aggr_investment_sales_phys(:,t) .* Sectors.prices(t-1,:)';

    % SECTIONAL CONSTRAINTS IN THE FULFILLMENT OF INVESTMENT DEMAND    
    Sections.investm_demand_fulfillment_constraints(Parameters.Sections.idx_capital_assets, t) = ...
        Sections.products_available_for_final_demand_phys(Parameters.Sections.idx_capital_assets, t) ./ sum(Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys(Parameters.Sections.idx_capital_assets, :, t-1), 2);



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%     SALES TO HOUSEHOLDS     %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
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


    % SECTIONAL CONSTRAINTS IN THE FULFILLMENT OF HOUSEHOLD DEMAND
    aggregation_rule = "values of sectors belonging to the same section get summed";
    sections_products_available_for_hhs_phys = ...
        From_Sectors_To_Sections_Function(aggregation_rule, sectors_products_available_for_hhs_phys, Parameters.Sectors.section_idx);    
    idx = Parameters.Households.exiobase_demand_relations_phys > 0;
    Sections.hhs_demand_fulfillment_constraints(idx, t) = ...
        sections_products_available_for_hhs_phys(idx) ...
        ./ sum(Sections.demand_from_hhs_phys(idx, :, t), 2);
    clear aggregation_rule idx



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%     SALES TO GOVERNMENT     %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
            (Sections.demand_in1year_from_govt_phys(:,t-1), sectors_products_available_for_govt_phys, ... % demand from gov't comes from previous period (it's orders)
            Parameters.Sectors.section_idx, Parameters.Sectors.idx_green, Parameters.Sectors.idx_brown); 
    % Test
    if any(Sectors.sales_to_govt_phys(:,t) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Sectors.sales_to_govt_phys''', t)
    end

    % Nominal
    Sectors.sales_to_govt_nominal(:,t) = ...
        Sectors.sales_to_govt_phys(:,t) .* Sectors.prices(t,:)';


    % SECTIONAL CONSTRAINTS IN THE FULFILLMENT OF GOV'T DEMAND
    aggregation_rule = "values of sectors belonging to the same section get summed";
    sections_products_available_for_govt_phys = ...
        From_Sectors_To_Sections_Function(aggregation_rule, sectors_products_available_for_govt_phys, Parameters.Sectors.section_idx);    
    idx = Parameters.Government.exiobase_demand_relations_phys > 0;
    Sections.govt_demand_fulfillment_constraints(idx, t) = ...
        sections_products_available_for_govt_phys(idx) ...
        ./ sum(Sections.demand_in1year_from_govt_phys(idx, t-1), 2);
    clear aggregation_rule idx


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%     INVENTORIES ACCUMULATION     %%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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

    % INVENTORIES TO TOTAL PRODUCTION RATIO
    Sectors.phys_inventories_to_tot_production_ratio(:,t) = ...
        Sectors.inventories_phys(:,t) ./ Sectors.production_phys(:,t);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%     TOTAL SALES     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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


    %% auxiliary final demand arrays


    % SECTORAL PHYSICAL FINAL DEMANDS

    % Note that the brown sector is a special case since it acts as a back-up option to green electricity. So we define its:
        % total final demand = total demand for electricity minus green electricity sales
        % demand from hhs = demand for electricity by hhs minus green electricity sales to hhs
        % demand from investing sectors = demand for electricity by investing sectors minus green electricity sales to investing sectors
        % demand from gov't = demand for electricity by gov't minus green electricity sales to gov't

    for j = 1 : Parameters.Sectors.nr

        idx_section = Parameters.Sectors.section_idx(j);

        % BROWN SECTOR
        if j == Parameters.Sectors.idx_brown

            % Real (physical) final demand
            Sectors.final_demand_phys(j,t) = ...
                Sections.final_demand_phys(idx_section, t) - Sectors.sales_to_final_demand_phys(Parameters.Sectors.idx_green, t);

            % Real (physical) demand from hhs
            Sectors.demand_from_hhs_phys(j,:,t) = ...
                Sections.demand_from_hhs_phys(idx_section, :, t) - Sectors.sales_to_hhs_phys(Parameters.Sectors.idx_green, :, t);

            % Real (physical) demand from investing Divisions
            Sectors.demand_from_investing_divisions_aggr_phys(j,t) = ...
                sum(Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys(idx_section, :, t-1), 2) ...
                - Sectors.aggr_investment_sales_phys(Parameters.Sectors.idx_green, t);                                

            % Real (physical) demand from gov't
            Sectors.demand_from_govt_phys(j,t) = ...
                Sections.demand_in1year_from_govt_phys(idx_section, t-1) - Sectors.sales_to_govt_phys(Parameters.Sectors.idx_green, t);

        % OTHER SECTORS
        else

            % Real (physical) final demand
            Sectors.final_demand_phys(j,t) = ...
                Sections.final_demand_phys(idx_section, t);

            % Real (physical) demand from hhs
            Sectors.demand_from_hhs_phys(j,:,t) = ...
                Sections.demand_from_hhs_phys(idx_section, :, t);

            % Real (physical) demand from investing Divisions
            Sectors.demand_from_investing_divisions_aggr_phys(j,t) = ...
                sum(Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys(idx_section, :, t-1), 2);

            % Real (physical) demand from gov't
            Sectors.demand_from_govt_phys(j,t) = ...
                Sections.demand_in1year_from_govt_phys(idx_section, t-1);

        end
    end


    %%%%  TESTS  %%%%

    % Test
    if any(Sectors.final_demand_phys(:,t) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Sectors.final_demand_phys''', t)
    end

    % Test
    if any(Sectors.demand_from_hhs_phys(:,:,t) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Sectors.demand_from_hhs_phys''', t)
    end

    % Test
    if any(Sectors.demand_from_investing_divisions_aggr_phys(:,t) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Sectors.demand_from_investing_divisions_aggr_phys''', t)
    end

    % Test
    if any(Sectors.demand_from_govt_phys(:,t) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Sectors.demand_from_govt_phys''', t)
    end

    
    %% households' consumption

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



    %%%%%%%  EMISSIONS ARISING FROM HHS' CONSUMPTION  %%%%%%%    
    
    % Emissions arising from each hhs' consumption
    Households.emissions_flow(t,:) = ...
        Parameters.Households.emissions_per_fossil_fuel_unit_consumed .* Sections.sales_to_hhs_phys(Parameters.Sections.names == "Fossil fuels processing", :, t);        


    %% capital accumulation and capital productivity

    % DIVISIONS' REAL (PHYSICAL) CAPITAL
    % = (previous period capital) - (depreciated capital) + (investment)
    Divisions.capital_phys(:,:,t) = ...
        Divisions.capital_phys(:,:,t-1) - divisions_capital_depreciation_phys + Sections.current_orders_from_investing_divisions_adj_for_rationing_phys(:,:,t);
    % Test
    if any(Divisions.capital_phys(:,:,t) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Divisions.capital_phys''', t)
    end


    % SECTORS' NOMINAL CAPITAL STOCKS
    sectors_capital_phys = NaN * ones(Parameters.Sections.nr, Parameters.Sectors.nr);
    for i = 1 : Parameters.Sectors.nr
        idx_divisions_belonging_to_sector_i = find(Parameters.Divisions.sector_idx == i);
        sectors_capital_phys(:,i) = ...
            sum(Divisions.capital_phys(:, idx_divisions_belonging_to_sector_i, t), 2);
    end
    Sectors.capital_nominal(:,:,t) = ...
        sectors_capital_phys .* Sections.prices(t,:)';


    % SECTORS' NOMINAL VALUE OF TOTAL CAPITAL    
    Sectors.tot_capital_nominal(t,:) = ...
        sum(Sectors.capital_nominal(:,:,t));


    % DIVISIONS' CAPITAL PRODUCTIVITY
    Divisions.capital_productivity(:,:,t) = ...
        Divisions.capital_productivity(:,:,t-1) .* (1 + Parameters.Divisions.capital_productivity_growth);
    % Test
    if any(Divisions.capital_productivity(:,:,t) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Divisions.capital_productivity''', t)
    end


    % PRODUCTION CAPACITY OF EACH CAPITAL ASSET - in 1 year
    divisions_prod_cap_of_each_capital_asset_in1year = ...
        Divisions.capital_productivity(:,:,t) .* Divisions.capital_phys(:,:,t);


    % DIVISIONS' CAPACITY ACCUMULATION RATIONING
    % = (appropriate measure of future production capacity) / (desired future production capacity adj after loans)
    % It's a measure of investment rationing. There is rationing whenever the value is < 1
    
    for i = 1 : Parameters.Divisions.nr
        
        if Rules.depreciation == "entire capital"
            % When depreciation affects the entire capital stock, the measure of capacity accumulation rationing is pretty intuitive:
            % ..you divide the actual future production capacity (in 1 year) by the previous period's desired future production capacity (in two years) adjusted after loans
            Divisions.capacity_accumulation_rationing(t,i) = ...
                min(divisions_prod_cap_of_each_capital_asset_in1year(Parameters.Divisions.capital_assets_logical_matrix(:,i), i)) ...
                ./ min(Divisions.desired_prod_cap_of_each_capital_asset_adj_after_loans_in2years(Parameters.Divisions.capital_assets_logical_matrix(:,i), i, t-1));
        
        else
            % Instead when depreciation affects only the utilized capital stock, the measure of capacity accumulation rationing is less straightforward.
            % Indeed, you have to account for the fact that when a Division determined its desired investment in the previous period, ..
            % ..it used an expected capacity utilization level for the current period. Therefore, when computing the capacity accumulation rationing measure, ..
            % ..you should use the same expected capacity utilization value for both the numerator and the denominator. That is to say, you should not use the ..
            % ..actual future production capacity in the numerator, because it is very likely the case that the actual capacity utilization value differs from ..
            % ..the expected one. Therefore, we compute a fictitious measure of the capital stock and associated production capacity, that assume that the ..
            % ..actual capacity utilization was equal to the expected one.

            % Fictitious capital stock            
            divisions_capital_phys_fictitious = ...
                (1 - Parameters.Divisions.depreciation_rates .* Divisions.assumed_capacity_utilization_in1year(t-1,:)) .* Divisions.capital_phys(:,:,t-1) + Sections.current_orders_from_investing_divisions_adj_for_rationing_phys(:,:,t);
            % Fictitious future production capacity of each capital asset arising from the fictitious capital stock
            divisions_future_prod_cap_of_each_capital_asset_fictitious = ...
                Divisions.capital_productivity(:,:,t) .* divisions_capital_phys_fictitious;
            Divisions.capacity_accumulation_rationing(t,i) = ...
                min(divisions_future_prod_cap_of_each_capital_asset_fictitious(Parameters.Divisions.capital_assets_logical_matrix(:,i), i)) ...
                ./ min(Divisions.desired_prod_cap_of_each_capital_asset_adj_after_loans_in2years(Parameters.Divisions.capital_assets_logical_matrix(:,i), i, t-1));
        end
    end

    % Test
    if any(Divisions.capacity_accumulation_rationing(t,:) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Divisions.capacity_accumulation_rationing''', t)
    end


    % INVESTMENT COSTS
    % Divisions
    Divisions.investment_costs(t,:) = ...
        sum(Sections.sales_to_investing_divisions_nomin(:,:,t));
    % Sectors
    for i = 1 : Parameters.Sectors.nr        
        Sectors.investments_costs(t,i) = ...
            sum(Divisions.investment_costs(t, Parameters.Divisions.sector_idx == i), 2);
    end



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

    % Test
    if any(Sectors.production_desired_driving_investment_phys(:,t) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Sectors.production_desired_driving_investment_phys''', t)
    end

    % DIVISIONS' DESIRED PRODUCTION
    % This will drive desired investments by each Division.
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

    % Each Division calculates its desired level of investments that it plans to demand in the next period.    
    % Even though Divisions will actually purchase capital goods in the next period.. 
        % .. they already agree with suppliers that the price they'll pay in the next period will be the current period price. 
    
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
    [sections_demand_in1year_from_invest_divisions_desired_phys, Divisions.desired_investment_formula_cases(t,:), first_term, second_term] = ...
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
    % it's the production limit implied by the future desired capital stock
    Divisions.desired_prod_cap_of_each_capital_asset_in2years(:,:,t) = ...
        divisions_desired_capital_stock_phys_in1year .* (Divisions.capital_productivity(:,:,t) .* (1 + Parameters.Divisions.capital_productivity_growth));

    % TEST    
    for i = 1 : Parameters.Divisions.nr
        if any(divisions_production_driving_investment(i) > Divisions.desired_prod_cap_of_each_capital_asset_in2years(Parameters.Divisions.capital_assets_logical_matrix(:,i), i, t))
            error('At time step %d, for Division %s, the desired production value that drives investment is larger than the desired production capacity arising from the desired investment process. This should not happen.', t, Parameters.Divisions.names(i))
        end
    end


    % COSTS RELATED TO THE DESIRED INVESTMENT

    % = (price of investment goods) * (planned investment demands)
    % We assume that investment purchases, that will actually occur in the next period, will settle at prices of the current period.

    % Divisional version
    Divisions.desired_investments_costs_before_loans_rationing(t,:) = ...
        Sections.prices(t,:) * sections_demand_in1year_from_invest_divisions_desired_phys; % we use current period prices since indeed investment demand will translate in investment purchases in the next period and at the prices of the current period

    % Sectoral version
    for i = 1 : Parameters.Sectors.nr
        idx_divisions_belonging_to_sector_i = find(Parameters.Divisions.sector_idx == i);
        Sectors.desired_investments_costs_before_loans_rationing(t,i) = ...
            sum(Divisions.desired_investments_costs_before_loans_rationing(t, idx_divisions_belonging_to_sector_i), 2);
    end


    %% NPV

    % BANK'S INTEREST ON LOANS
    % We put it here because it's needed for the computation of NPV
    Bank.interest_on_loans(t) = Bank.interest_on_loans(t-1);
    % Test
    if Bank.interest_on_loans(t) < 0
        error('At time step %d, there is a value that is <0 in ''Bank.interest_on_loans''', t)
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
        residual_investment_phys = sections_demand_in1year_from_invest_divisions_desired_phys(:,i);

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
                capital_stocks_with_investment = divisions_desired_capital_stock_phys_in1year(:,i);
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
                delta_production .* (Sectors.prices(t, Parameters.Divisions.sector_idx(i)) - Sections.prices(t-1,:) * Divisions.C_rectangular(:,i,t)) .* (1 - Government.sectors_tax_rate(t-1)) ...
                + Government.sectors_tax_rate(t-1) * amortization ...
                + sum(idle_capital_stock_nominal)...
                )...
                ./ ((1 + Bank.interest_on_loans(t)) .^ time_step);

        end

        % DISCOUNTED REVENUES
        Divisions.NPV_discounted_revenues(t,i) = discounted_revenues;

    end

    
    %%%%%  INVESTMENT COSTS  %%%%%
    Divisions.NPV_investment_costs(t,:) = ...
        Sections.prices(t,:) * sections_demand_in1year_from_invest_divisions_desired_phys; % we use current period prices since indeed investment demand will translate in investment purchases in the next period and at the prices of the current period        
    
    
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


    %% sectors' stocks and flows /1

    % SECTORS' NOMINAL SALES
    % = (nominal intermediate input sales to sectors) + (nominal sales to final demand buyers)
    % Remember that interindustry transactions and investment sales are made at previous period prices.
    Sectors.sales_nominal(:,t) = ...
        sum(Sectors.S_square(:,:,t) .* Sectors.prices(t-1,:)', 2) ...        
        + Sectors.sales_to_final_demand_nominal(:,t);


    % SECTORS' NOMINAL PRODUCTION
    % See definition in Godley & Lavoie (2007), p. 262 Eq. 8.22
    Sectors.production_nominal(:,t) = ...
        Sectors.sales_nominal(:,t) ...
        + (Sectors.inventories_phys(:,t) - Sectors.inventories_phys(:,t-1)) .* Sectors.unit_costs(t,:)';


    % SECTORS' TOTAL HISTORIC COSTS
    % This is the total historic costs as defined in Chapter 8 in Godley & Lavoie (2007)
    % = (intermediate inputs costs) + (labor costs) - (change in inventories)    
    % Recall that we've assumed that interindustry transactions are settled at previous period prices.
    Sectors.historic_costs(t,:) = ...
        Sectors.prices(t-1,:) * Sectors.S_square(:,:,t) ...
        - (Sectors.inventories_nominal(:,t) - Sectors.inventories_nominal(:,t-1))';       


    % SECTORS' VALUE ADDED
    % = (nominal sales) + (change in inventories) - (intermediate input costs)   
    Sectors.VA(t,:) = ...
        Sectors.sales_nominal(:,t)' ...
        + (Sectors.inventories_nominal(:,t) - Sectors.inventories_nominal(:,t-1))' ...
        - Sectors.prices(t-1,:) * Sectors.S_square(:,:,t);  
    % We test for negative value added outside the loop.


    % SECTORS' TAXES
    % taxes are paid on net profits of the previous period
    Sectors.taxes(t,:) = max(0, ...
        Government.sectors_tax_rate(t-1) * Sectors.net_profits(t-1,:));
    % We test for negative taxes at the end of the loop.


    % SECTORS' INTEREST EXPENSES
    Sectors.interest_expenses(t,:) = Bank.interest_on_loans(t-1) * Sectors.loans_stock(t-1,:);


    % ENTREPRENEURIAL PROFITS
    % This is the definition of profits as defined in Chapter 8 in Godley & Lavoie (2007) ..
    % ..and as implied by the current account column of the SFC transactions flow matrix.
    Sectors.entrepreneurial_profits(t,:) = ...
        Sectors.sales_nominal(:,t)' - Sectors.historic_costs(t,:) - Sectors.taxes(t,:) + Sectors.govt_subsidies(t,:);


    % ENTREPRENEURIAL PROFITS NET OF INTEREST EXPENSES
    % This is the value that sectors will then split into dividends and retained profits.
    Sectors.entrepreneurial_profits_net_of_interest_expenses(t,:) = ...
        Sectors.entrepreneurial_profits(t,:) - Sectors.interest_expenses(t,:);        


    % SECTORS' NET PROFITS
    % = (entrepreneurial profits) - (interest on loans) - (depreciation on capital)
    % This is the value of profits on which sectors pay taxes.
    Sectors.net_profits(t,:) = ...
        Sectors.entrepreneurial_profits_net_of_interest_expenses(t,:) ...
        - Sectors.capital_depreciation_nominal(t,:);


    %% sectors' retained profits

    % DELTA INVENTORIES
    % Sectors' change in the value of nominal inventories
    sectors_delta_nominal_inventories = Sectors.inventories_nominal(:,t) - Sectors.inventories_nominal(:,t-1);

    % SECTORS' REPAID LOANS            
    Sectors.loans_repaid(t,:) = Sectors.loans_stock(t-1,:);

    % ADDITIONAL FUNDS NEEDED
    % See definition in Latex file.
    % Note that it can also become negative.
    additional_funds_needed = ...
        Sectors.investments_costs(t,:) + sectors_delta_nominal_inventories' + Sectors.loans_repaid(t,:) + Sectors.desired_investments_costs_before_loans_rationing(t,:) - Sectors.deposits(t-1,:);


    %%%%%%%%%%%  HYPOTHETICAL LOAN DEMAND AND RETAINED PROFITS  %%%%%%%%%%%

    % HYPOTHETICAL NEW LOANS DEMAND - FOR TARGET LEVERAGE
    % Amount of loans needed to bring leverage to target.
    % Note that it can also become negative.
    hyp_new_loans_demand_for_target_leverage = ...
        Sectors.loans_repaid(t,:) - Sectors.loans_stock(t-1,:) ...
        + Parameters.Sectors.leverage_target / (1 + Parameters.Sectors.leverage_target) ...
        .* (Sectors.tot_capital_nominal(t,:) + Sectors.inventories_nominal(:,t)' + Sectors.desired_investments_costs_before_loans_rationing(t,:));

    % HYPOTHETICAL NEW LOANS DEMAND
    % Obviously loan demand shouldn't be negative, nor be higher than actually needed funds
    hyp_new_loans_demand = ...
        max(0, min(hyp_new_loans_demand_for_target_leverage, additional_funds_needed));

    % HYPOTHETICAL RETAINED PROFITS
    % This variable may get a negative value only in case "additional_funds_needed" < 0
    hyp_retained_profits = ...
        additional_funds_needed - hyp_new_loans_demand;

    % RETAINED PROFITS - TMP
    % Obviously retained profits cannot be larger than actually available profits.
    % It is fine that this variable may get a negative value. There are 2 cases:
        % "Sectors.entrepreneurial_profits_net_of_interest_expenses" < 0
            % --> "retained_profits_tmp" = "Sectors.entrepreneurial_profits_net_of_interest_expenses" < 0 --> "Sectors.dividends" = 0
            % Look at the Latex file: this implies that loan demand will be increased by the value
        % "hyp_retained_profits" < 0 --> "additional_funds_needed" < 0 --> the Sector has excess funds that it could distribute as dividends
    retained_profits_tmp = ...
        min(hyp_retained_profits, Sectors.entrepreneurial_profits_net_of_interest_expenses(t,:));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % SECTORS' DIVIDENDS
    % = (profits) - (retained profits)
    Sectors.dividends(t,:) = ...
        max(0, Sectors.entrepreneurial_profits_net_of_interest_expenses(t,:) - retained_profits_tmp);

    if any(Sectors.dividends(t,:) < 0, 'all')
        error('At time step %d, there is at least one value that is <0 in ''Sectors.dividends''', t)
    end

    % SECTORS' DIVIDEND PAYOUT RATIO
    Sectors.dividend_payout_ratio(t,:) = ...
        Sectors.dividends(t,:) ./ Sectors.entrepreneurial_profits_net_of_interest_expenses(t,:);

    % SECTORS' RETAINED PROFITS
    % This variable may get a negative value. In such case, the demand for loans will be higher than "additional_funds_needed"
    Sectors.retained_profits(t,:) = ...
        Sectors.entrepreneurial_profits_net_of_interest_expenses(t,:) - Sectors.dividends(t,:);

    % LOAN DEMAND
    Sectors.loans_demand_flow(t,:) = ...
        additional_funds_needed - Sectors.retained_profits(t,:);
    if any(Sectors.loans_demand_flow(t,:) < 0, 'all')
        error('At time step %d, there is at least one value that is <0 in ''Sectors.loans_demand_flow''', t)
    end


    %% loan demand and supply

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%  BANK'S MAXIMUM SUPPLY OF LOANS  %%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

    
    % BANK'S PROFITS
    % = revenues - costs
    Bank.profits(t) = ...
        Bank.loans_stock(t-1) * Bank.interest_on_loans(t-1);


    % LOANS REPAID BY SECTORS
    Bank.loans_repaid(t) = ...
        sum(Sectors.loans_repaid(t,:), 2);


    % BANK'S MAX POSSIBLE LOANS SUPPLY FLOW
    % See also description in Latex file.
    % Maximum level of loans stock, assuming the bank will retain all profits
    if Parameters.Bank.capital_requirement == 0
        % You may think that this specification is unnecessary since it is already implied by the formula below; 
        % however if also the numerator in the formula below is zero (e.g. because net worth is zero and the interest rate [and therefore profits] is zero), then the ratio yields a NaN value.
        max_loans_stock = Inf; 
    else
        max_loans_stock = ...
            (Bank.net_worth(t-1) + Bank.profits(t)) ...
                ./ Parameters.Bank.capital_requirement;
    end
    % Max supply of new loans
    Bank.loans_max_supply_flow(t) = ...
        max(0, max_loans_stock - Bank.loans_stock(t-1) + Bank.loans_repaid(t));

    % Test
    if Bank.loans_max_supply_flow(t) < 0
        error('At time step %d, there is a negative value in ''Bank.loans_max_supply_flow''', t)
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  LOAN SUPPLY  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    % The bank will check whether its (Basel-type) capital requirements allow it to provide the total amount of loans demanded by Sectors.
    % If capital requirements constrain its supply of loans (e.g. it can provide only 80% of demanded loans) 
        % --> credit rationing will be applied to all Sectors according to the same percentage constraint 
        % (every Sector will receive only 80% of the demanded loan).        


    % PROPORTION OF MAX SUPPLY OF LOANS VS DEMANDED LOANS
    if sum(Sectors.loans_demand_flow(t,:), 2) ~= 0
        Bank.proportion_max_supply_vs_demanded_loans(t) = ...
            Bank.loans_max_supply_flow(t) / sum(Sectors.loans_demand_flow(t,:), 2);
    else
        Bank.proportion_max_supply_vs_demanded_loans(t) = NaN; % otherwise this would be Infinite when denominator is zero (i.e. when no sector demands loans)
    end


    % SECTORS' FLOW OF RECEIVED LOANS
    % If total loans demanded are less than the bank's maximum loans supply flow, Sectors will receive the full amount demanded.
    % Otherwise, they'll receive only a fraction of demanded loans.
    if sum(Sectors.loans_demand_flow(t,:), 2) <= Bank.loans_max_supply_flow(t)
        Sectors.loans_received_flow(t,:) = ...
            Sectors.loans_demand_flow(t,:);
    else
        Sectors.loans_received_flow(t,:) = ...
            Sectors.loans_demand_flow(t,:) * Bank.proportion_max_supply_vs_demanded_loans(t);
    end
    % Test
    if any(Sectors.loans_received_flow(t,:) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Sectors.loans_received_flow''', t)
    end    
    

    % PROPORTION OF RECEIVED LOANS VS DEMANDED LOANS
    Bank.proportion_supply_vs_demanded_loans(t) = ...    
        sum(Sectors.loans_received_flow(t,:), 2) / sum(Sectors.loans_demand_flow(t,:), 2);
    % this becomes NaN if both numerator and denominator are 0.


    % SECTORS' DEPOSITS
    % their definintion follows from the capital account column in the SFC transaction flow matrix; they are the residual of the other items:
    % = (previous period deposits) + ([received loans] - [repaid loans]) - (investment costs) - (delta inventories) + (retained profits)
    Sectors.deposits(t,:) = ...
        Sectors.deposits(t-1,:) ...
        + Sectors.loans_received_flow(t,:) - Sectors.loans_repaid(t,:)...
        - Sectors.investments_costs(t,:) ...
        - (Sectors.inventories_nominal(:,t) - Sectors.inventories_nominal(:, t-1))' ...                
        + Sectors.retained_profits(t,:);
    
    % TESTING FOR NEGATIVE DEPOSITS
    % We don't test directly for "Sectors.deposits(t,:) < 0" because deposits could actually be negative but very close to zero, due to some rounding errors.
    % Note that however it doesn't make much sense to test for "Sectors.deposits(t,:) < - Parameters.error_tolerance_strong", because that does not take ..
    % ..into account the order of magnitudes of the quantities. 
    % Therefore, we may conceive "Deposits = A - B" and test whether "(A - B) / abs(B) < - Parameters.error_tolerance_strong".
    denominator_test = Sectors.loans_repaid(t,:) + Sectors.inventories_nominal(:,t)' + Sectors.investments_costs(t,:);
    if any(Sectors.deposits(t,:) ./ abs(denominator_test) < - Parameters.error_tolerance_strong, 'all')
        error('At time step %d, there is at least one negative value in ''Sectors.deposits''', t)
    end


    %% adjusting desired investment after loan rationing


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%  FUNDS AVAILABLE FOR FUTURE INVESTMENT  %%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % If funds available for future investment are less than desired investment, Divisions will have to rescale their investment demands downwards.
    % Since this process is done at the Divisional level, we first have to build the Divisional version of available funds.
    
    % SECTORAL VERSION
    Sectors.funds_available_for_future_investment(t,:) = Sectors.deposits(t,:);
    
    % DIVISIONAL VERSION
    % To build the Divisional version, we split it according to the weights of each Division's investment cost within the respective Sector's investment costs.
    divisions_desired_investments_costs_sectoral_weights = NaN * ones(1, Parameters.Divisions.nr);    

    for i = 1 : Parameters.Divisions.nr

        % We define "divisions_desired_investments_costs_sectoral_weights" as the ratio: (Division's desired investment costs) / (Sector's desired investment costs)
        % However, if both the numerator and denominator are zero, then the ratio would yield a NaN value;
            % in that case, we assign the weight as: 1 / (total number of Divisions within the considered Sector)
            % e.g. if there are 3 Divisions within the considere Sector, then each will have a 0.33 weight.
        if Divisions.desired_investments_costs_before_loans_rationing(t,i) == 0 && Sectors.desired_investments_costs_before_loans_rationing(t, Parameters.Divisions.sector_idx(i)) == 0
            divisions_desired_investments_costs_sectoral_weights(i) = ...
                1 ./ nnz(Parameters.Divisions.sector_idx == Parameters.Divisions.sector_idx(i)); % the function "nnz" counts the number of non-zero elements          
        else
            divisions_desired_investments_costs_sectoral_weights(i) = ...
                Divisions.desired_investments_costs_before_loans_rationing(t,i) / Sectors.desired_investments_costs_before_loans_rationing(t, Parameters.Divisions.sector_idx(i));
        end                
        
    end

    % TEST
    % Weights should not be <0 nor >1
    if any(divisions_desired_investments_costs_sectoral_weights < 0, 'all') || any(divisions_desired_investments_costs_sectoral_weights > 1, 'all')
        error('At time step %d, there is at least one negative value or one value >1 in ''divisions_desired_investments_costs_sectoral_weights''', t)
    end
    % Weights must sum to 1.
    aggregating_weights_test = NaN * ones(1, Parameters.Sectors.nr);
    for i = 1 : Parameters.Sectors.nr
        idx_divisions_belonging_to_sector_i = Parameters.Divisions.sector_idx == i;
        aggregating_weights_test(i) = ...
            sum(divisions_desired_investments_costs_sectoral_weights(idx_divisions_belonging_to_sector_i), 2);
    end
    if any(abs(1 - aggregating_weights_test) > Parameters.error_tolerance_strong, 'all')
        error('At time step %d, the sum across weights in the electricity Divisions in ''divisions_desired_investments_costs_sectoral_weights'' does not equal 1', t)
    end 

    % Assign values to final variable
    for i = 1 : Parameters.Divisions.nr
        idx_sector = Parameters.Divisions.sector_idx(i);
        Divisions.funds_available_for_future_investment(t,i) = ...
            divisions_desired_investments_costs_sectoral_weights(i) .* Sectors.funds_available_for_future_investment(t, idx_sector);
    end



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%  ADJUSTED DESIRED INVESTMENT  %%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%           

    % ADJUSTMENT OF DIVISIONS' DESIRED INVESTMENTS AFTER LOANS RATIONING
    % If Divisions don't have enough funds to cover future investment costs, they'll have to revise their investment demands downwards.
    % See explanations and equation derivation in the respective Latex file
    for i = 1 : Parameters.Divisions.nr
        
        % If Division i doesn't have enough funds to cover future investment costs, it revises its investment demand downwards.
        if Divisions.funds_available_for_future_investment(t,i) < Divisions.desired_investments_costs_before_loans_rationing(t,i)

            % Logical index of the commodities used as capital assets by Division i
            idx_assets = Parameters.Divisions.capital_assets_logical_matrix(:,i);

            % COMPUTING THE HAIRCUT VALUE
            % As you can see from the Latex file, you need to find the haircut value through a non-linear equation.
            % See example at: https://www.mathworks.com/matlabcentral/answers/1848543-solving-nonlinear-equation-including-max-function
            my_options = optimset('TolX', 1e-10, 'TolFun', 1e-10, 'Display', 'off'); % setting 'Display' to 'off' hides the comments in the command window that fsolve would automatically generate and that are a bit bothering to have printed in the command window.
            % Write a function handle (https://www.mathworks.com/help/matlab/function-handles.html) containing our non-linear equation
            my_function = @(desired_production_haircut)...
                [sum(...
                    Sections.prices(t, idx_assets)' .* ...
                    max(0, desired_production_haircut .* first_term(idx_assets, i) + second_term(idx_assets, i))...
                    ) ...
                    - Divisions.funds_available_for_future_investment(t,i)];
            % Solve the non-linear equation and thereby find the haircut value
            desired_production_haircut = fsolve(@(z)my_function(z(1)), [1], my_options);  


            % DETERMINE THE ADJUSTED INVESTMENT DEMANDS
            % For goods used as capital assets
            Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys(idx_assets, i, t) = ...
                max(0, desired_production_haircut .* first_term(idx_assets, i) + second_term(idx_assets, i));
            % For goods not used as capital assets, demand is obviously zero
            Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys(~idx_assets, i, t) = 0;            
            

        % If Division i has enough funds to cover future investment costs, its investment demand remains unchanged.
        else
            Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys(:,i,t) = ...
                sections_demand_in1year_from_invest_divisions_desired_phys(:,i);
        end
    end
    % Test
    if any(Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys(:,:,t) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys''', t)
    end

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


    %% sectors' stocks and flows /2


    % SECTORS' LOANS STOCK
    % = (previous period stock) - (repaid loans) + (flow of new loans)
    Sectors.loans_stock(t,:) = ...
        Sectors.loans_stock(t-1,:) - Sectors.loans_repaid(t,:) + Sectors.loans_received_flow(t,:);

    % Test
    if any(Sectors.loans_stock(t,:) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Sectors.loans_stock''', t)
    end

    
    % SECTORS' ASSETS
    Sectors.assets(t,:) = ...
        Sectors.tot_capital_nominal(t,:) + Sectors.inventories_nominal(:,t)' + Sectors.deposits(t,:);


    % SECTORS' LIABILITIES
    Sectors.liabilities(t,:) = ...
        Sectors.loans_stock(t,:);


    % SECTORS' NET WORTH
    % = assets - liabilities
    Sectors.net_worth(t,:) = ...
        Sectors.assets(t,:) - Sectors.liabilities(t,:);    


    % SECTORS' LEVERAGE
    % = liabilities / net worth
    Sectors.leverage(t,:) = ...
        Sectors.liabilities(t,:) ./ Sectors.net_worth(t,:);


    %% bank's profits and dividends


    % BANK'S STOCK OF LOANS
    % = sum of all loans to sectors
    Bank.loans_stock(t) = sum(Sectors.loans_stock(t,:), 2);
    % Growth rate
    Bank.loans_stock_growth_rate(t) = ...
        (Bank.loans_stock(t) - Bank.loans_stock(t-1)) ./ Bank.loans_stock(t-1);    


    % BANK'S DIVIDENDS
    % We allow for different rules
        % "no"           --> the bank never distributes dividends
        % "yes - rough"  --> the bank checks its previous year's Capital Adequacy Ratio (CAR): if it is less than the target, the bank will not distribute dividends. Otherwise, it will distribute all profits (or a fixed share of them).
        % "yes - smooth" --> the bank distributes an amount of dividends that will imply the resulting CAR to be equal to the target. If that requires dividends to become negative, we prevent this from happening by setting a floor of zero.

    if Rules.bank_dividends == "no"
    
        Bank.dividends(t) = 0;        
        Bank.profits_retained(t) = Bank.profits(t) - Bank.dividends(t);

    elseif Rules.bank_dividends == "yes - rough"
        
        % If Capital Adequacy Ratio (CAR) is less than the target, the bank will not distribute dividends. Otherwise, it will.
        if Bank.CAR(t-1) < Parameters.Bank.CAR_target
            Bank.dividends(t) = 0;
        else
            Bank.dividends(t) = Parameters.Bank.dividend_payout_ratio * max(0, Bank.profits(t));
        end

        Bank.profits_retained(t) = Bank.profits(t) - Bank.dividends(t);
    
    elseif Rules.bank_dividends == "yes - smooth"

        Bank.profits_retained(t) = ...
            max(0, ...
                min(Bank.profits(t), ...
                    Parameters.Bank.CAR_target * Bank.loans_stock(t) - Bank.net_worth(t-1) ...
            ));        

        Bank.dividends(t) = Bank.profits(t) - Bank.profits_retained(t);
    
    end

    % We test for negative dividends outside the loop    

    
    % BANK'S DIVIDEND PAYOUT RATIO
    Bank.dividend_payout_ratio(t) = ...
        Bank.dividends(t) ./ Bank.profits(t);


    %% households' income and deposits

    % INCOME
    % sectors' and bank's dividends are equally distributed among households
    Households.income(t,:) = ...
        (sum(Sectors.dividends(t,:), 2) + Bank.dividends(t)) ...
        / Parameters.Households.nr;
    % We test for negative income outside the loop
    

    % DEPOSITS
    % = (previous period deposits) + income - consumption
    Households.deposits(t,:) = Households.deposits(t-1,:) + Households.income(t,:) - Households.consumption_expenditures(t,:);
    % Test
    if any(Households.deposits(t,:) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Households.deposits''', t)
    end

    % NET WORTH
    Households.net_worth(t,:) = Households.deposits(t,:);
    

    %% nominal and real GDP
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%   NOMINAL GDP   %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Blanchard (2016): "Nominal GDP is the sum of the quantities of final goods produced times their current price".
    % Note: it says "produced", not "sold"! So we should include inventory investment (II) in the computation of GDP.
    % GDP = C + I + G + II

    % TOTAL VALUE ADDED
    Economy.GDP_nominal(t) = sum(Sectors.VA(t,:), 2);
    Economy.GDP_nominal_growth_rate(t) = Economy.GDP_nominal(t) ./ Economy.GDP_nominal(t-1) - 1;
    
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
        
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%   REAL GDP   %%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % We follow the procedure described in Blanchard (2016) "Macroeconomics" book, Appendix to Chapter 2.

    % Blanchard (2016): "Nominal GDP is the sum of the quantities of final goods produced times their current price".
    % We use physical production destined for sale to final demand, and not actual physical sales to final demand, when computing real GDP.    
    % This should be the correct way of computing GDP. Indeed, GDP includes inventory investment (II), i.e. the difference between production and sales.
    % GDP = C + I + G + II
    % Note that: 
        % C + I + G = final sales
        % II = inventory investment = (production of final goods) - (final sales)
    % GDP = (final sales) + (production of final goods) - (final sales)
    %     = (production of final goods)
    
    % REAL GDP LEVELS AND GROWTH RATE EXPRESSED IN PREVIOUS YEAR'S PRICES
    % Real GDP of the previous year and the current year:
    real_GDP_previous_year_previous_prices = Sectors.prices(t-1,:) * Sectors.production_for_final_demand_phys(:,t-1);
    real_GDP_current_year_previous_prices = Sectors.prices(t-1,:) * Sectors.production_for_final_demand_phys(:,t);
    % Growth rate
    real_GDP_growth_rate_previous_prices = (real_GDP_current_year_previous_prices - real_GDP_previous_year_previous_prices) / real_GDP_previous_year_previous_prices;
    
    % REAL GDP LEVELS AND GROWTH RATE EXPRESSED IN CURRENT YEAR'S PRICES
    % Real GDP of the previous year and the current year:
    real_GDP_previous_year_current_prices = Sectors.prices(t,:) * Sectors.production_for_final_demand_phys(:,t-1);
    real_GDP_current_year_current_prices = Sectors.prices(t,:) * Sectors.production_for_final_demand_phys(:,t);
    % Growth rate
    real_GDP_growth_rate_current_prices = (real_GDP_current_year_current_prices - real_GDP_previous_year_current_prices) / real_GDP_previous_year_current_prices;
    
    % REAL GDP GROWTH RATE
    % = average of the two above growth rates
    Economy.GDP_real_growth_rate(t) = mean([real_GDP_growth_rate_previous_prices, real_GDP_growth_rate_current_prices]);
    
    % REAL GDP
    % .. in chained (t=1) dollars (we have set real GDP at time 1 equal to nominal GDP at time 1).
    Economy.GDP_real(t) = Economy.GDP_real(t-1) * (1 + Economy.GDP_real_growth_rate(t));


    %% price level and inflation

    % 2 definitions of price levels and corresponding inflation rates:
        % GDP deflator
        % Consumer Price Index


    % GDP DEFLATOR
    Economy.GDP_deflator(t) = Economy.GDP_nominal(t) ./ Economy.GDP_real(t);


    % CONSUMER PRICE INDEX (CPI)
    % = (cost of the market basket in year t) / (cost of the same market basket in the base year)
    % TO BE CHECKED: check if it is really the correct definition!
    % Since the hhs' (desired) consumption weights are fixed, we simply multiply these with the respective prices.
    % If we used not the desired but the actual consumption weights, this could be problematic since often in our model it happens..
    % ..that hhs cannot consume some goods because they aren't available.
    Economy.CPI(t) = 100 ...
        .* (Sections.prices(t,:) * Parameters.Households.demand_relations_phys_evolving(:,t)) ...
        ./ (Sections.prices(1,:) * Parameters.Households.demand_relations_phys_evolving(:,t));


    % INFLATION based on GDP deflator
    Economy.GDP_deflator_inflation(t) = Economy.GDP_deflator(t) ./ Economy.GDP_deflator(t-1) - 1;


    % INFLATION based on CPI
    Economy.CPI_inflation(t) = Economy.CPI(t) ./ Economy.CPI(t-1) - 1;

        
    %% government /1

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%   FLOWS   %%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % GOV'T NOMINAL DEMAND
    Sections.current_demand_from_govt_nominal(:,t) = ...
        Sections.demand_in1year_from_govt_phys(:,t-1) .* Sections.prices(t,:)';

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
    Government.taxes(t) = sum(Sectors.taxes(t,:), 2);

    


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

    % GOV'T ADJUSTMENT OF RESERVES HOLDINGS AND ADVANCES

    % If the gov't deficit is positive (meaning it is running a deficit):
        % the gov't will draw upon its stock of reserves holdings to cover the deficit. 
        % If that's insufficient, it will deplete all reserves, and will take loans (advances) from the central bank to cover the remaining expenditure.
    % If the gov't deficit is negative (meaning it is running a surplus):
        % the gov't will use the funds in excess to repay advances to the central bank. 
        % If there aren't advances to be repaid, it will park the funds as reserves holdings.
    if Government.deficit(t) >= 0
        if Government.deficit(t) <= Government.reserves_holdings(t-1)
            govt_reserves_holdings_tmp = Government.reserves_holdings(t-1) - Government.deficit(t);
            govt_advances_tmp = Government.advances(t-1);
        else
            govt_reserves_holdings_tmp = 0;
            govt_advances_tmp = Government.advances(t-1) + Government.deficit(t) - Government.reserves_holdings(t-1);
        end
    else
        if -Government.deficit(t) <= Government.advances(t-1)
            govt_advances_tmp = Government.advances(t-1) + Government.deficit(t);
            govt_reserves_holdings_tmp = Government.reserves_holdings(t-1);
        else 
            govt_advances_tmp = 0;
            govt_reserves_holdings_tmp = Government.reserves_holdings(t-1) - Government.deficit(t) - Government.advances(t-1);
        end
    end

    % If both advances and reserves are positive, the gov't will pay back all advances it can with the reserves it holds.
    if govt_advances_tmp > 0 && govt_reserves_holdings_tmp > 0
        Government.advances(t) = max(0, govt_advances_tmp - govt_reserves_holdings_tmp);
        Government.reserves_holdings(t) = max(0, govt_reserves_holdings_tmp - govt_advances_tmp);
    else
        Government.advances(t) = govt_advances_tmp;
        Government.reserves_holdings(t) = govt_reserves_holdings_tmp;
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


    % TAX RATE ADJUSTMENTS
    % If the relevant measure (debt-to-GDP ratio or deficit-to-GDP ratio) goes above the ceiling, the gov't increases the tax rate.
    % If the relevant measure goes below the floor, the gov't decreases the tax rate.
    % If the relevant measure lies within the tolerance range, the gov't doesn't change the tax rate.
    % Note: the tax rate must not go below 0 or above 1.
    
    if Rules.govt_taxation == "targeting debt-to-GDP"
        
        if Government.debt_to_GDP_ratio(t) > Parameters.Government.debt_to_GDP_ceiling
            Government.sectors_tax_rate(t) = ...
                min(1, Government.sectors_tax_rate(t-1) + Parameters.Government.tax_rate_steps);
        elseif Government.debt_to_GDP_ratio(t) < Parameters.Government.debt_to_GDP_floor
            Government.sectors_tax_rate(t) = ...
                max(0, Government.sectors_tax_rate(t-1) - Parameters.Government.tax_rate_steps);
        else
            Government.sectors_tax_rate(t) = Government.sectors_tax_rate(t-1);
        end
    
    elseif Rules.govt_taxation == "targeting deficit-to-GDP"
    
        if Government.deficit_to_GDP_ratio(t) > Parameters.Government.deficit_to_GDP_ceiling
            Government.sectors_tax_rate(t) = ...
                min(1, Government.sectors_tax_rate(t-1) + Parameters.Government.tax_rate_steps);
        elseif Government.deficit_to_GDP_ratio(t) < Parameters.Government.deficit_to_GDP_floor
            Government.sectors_tax_rate(t) = ...
                max(0, Government.sectors_tax_rate(t-1) - Parameters.Government.tax_rate_steps);
        else
            Government.sectors_tax_rate(t) = Government.sectors_tax_rate(t-1);
        end

    end

    % Test
    if Government.sectors_tax_rate(t) < 0
        error('At time step %d, there is a negative value in ''Government.sectors_tax_rate''', t)
    elseif Government.sectors_tax_rate(t) > 1
        error('At time step %d, ''Government.sectors_tax_rate'' is larger than 1', t)
    end


    %%%%%%%  EMISSIONS ARISING FROM GOV'T CONSUMPTION  %%%%%%%        

    % CURRENT EMISSIONS
    Government.emissions_flow(t) = ...
        Parameters.Government.emissions_per_fossil_fuel_unit_consumed .* Sections.sales_to_govt_phys(Parameters.Sections.names == "Fossil fuels processing", t);


    %% government /2

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%   PHYSICAL DEMAND   %%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % .. that it will order in the next period.
    % The gov't will demand the goods in such a way as to ensure that the physical relations among the goods are kept constant.
        % For example, if the physical relations of its final demand in the initial period consist of 2 apples (A) and 3 bananas (B)..
        % .. in a subsequent period its demand may e.g. be 4 apples and 6 bananas (4/6 = 2/3).

    % But how does the gov't increase/decrease its final demand? It depends on which rule we apply:
        %%%%%  "yes - constant share of GDP"  %%%%%
            % The gov't wants to keep its nominal consumption as a constant, exogenously set share of nominal GDP.        
            % Thus, across the simulation of the model, we ensure that the gov't demands z*2*A and z*3*B (where z is a rescaling value) such that:
                        % z*2*A*p_A + z*3*B*p_B = (share of GDP)   -->   
                        % z = (share of GDP) / (2*A*p_A + 3*B*p_B)    
            % .. where p_A and p_B are the prices of the two goods.
            % So e.g. in time step t>1, if we find that, given the budget and the prices, z = 1.5 --> the gov't will demand 3 apples and 4.5 bananas.
            % Note that, as is the case for the households, z can also be interpreted as the units of the consumption basket demanded by the gov't.
        %%%%%  "yes - changing adaptively"  %%%%%
            % The growth rate of its physical demand equals the growth rate of some variable (specifically, the average growth rate over the past X years).
            % Which reference variable should we choose? There are two options:
                % 1. The growth rate of real GDP
                % 2. The growth rate of hhs' physical final demand. We don't consider the growth rate of investments because those are too volatile..

                
    % GROWTH RATE OF HHS PHYSICAL DEMAND
    % % Since the growth rate of hhs' physical demand is equal across all commodities, we just look at one commodity
    % [~, index_max_value] = max(Parameters.Households.exiobase_demand_relations_phys);
    % % Let's pick the first hh
    % index_hhs = 1;
    % % Growth rate of hhs' physical demand
    % Economy.hhs_demand_phys_growth_rate(t) = ...
    %     Sections.demand_from_hhs_phys(index_max_value, index_hhs, t) ./ Sections.demand_from_hhs_phys(index_max_value, index_hhs, t-1) - 1;
        


    % GOV'T PHYSICAL DEMAND
    
    if Rules.govt_demand == "yes - constant share of GDP"
        
        % Its nominal budget is a constant share of nominal GDP
        nominal_budget = Parameters.Government.share_of_GDP .* Economy.GDP_nominal(t);

        % This is the real demand rescaling value z as described at the beginning of this section of code.
        Government.consumption_basket_units_demanded_in1year(t) = ...
            nominal_budget ./ (Sections.prices(t,:) * Parameters.Government.exiobase_demand_relations_phys);
        
        % Gov't physical demand
        Sections.demand_in1year_from_govt_phys(:,t) = ...
            Government.consumption_basket_units_demanded_in1year(t) .* Parameters.Government.exiobase_demand_relations_phys;

        % Gov't physical demand growth rate
        Government.demand_phys_growth_rate(t) = ...
            (Government.consumption_basket_units_demanded_in1year(t) ./ Government.consumption_basket_units_demanded_in1year(t-1)) - 1;

    else

        % GROWTH RATE OF GOV'T PHYSICAL DEMAND
        
        % Number of years across which we want to compute the average growth rate of the reference variable
        time_span_average_growth_rate = 10;
        % Time step by which we can start computing the average
        year_start_endogenous_govt_demand_growth_rate = 15;
                
        if Rules.govt_demand == "no" || Rules.govt_demand == "yes - constant"
        
            Government.demand_phys_growth_rate(t) = 0;            
        
        elseif Rules.govt_demand == "yes - growing constantly"
            
            Government.demand_phys_growth_rate(t) = Parameters.Government.demand_exogenous_growth_rate;
        
        elseif Rules.govt_demand == "yes - changing adaptively"
            
            if t < year_start_endogenous_govt_demand_growth_rate
                Government.demand_phys_growth_rate(t) = Parameters.Government.demand_exogenous_growth_rate;
            else
                Government.demand_phys_growth_rate(t) = mean(Economy.GDP_real_growth_rate((t - time_span_average_growth_rate + 1) : t));
            end
        
        end

        % GOV'T PHYSICAL DEMAND
        Sections.demand_in1year_from_govt_phys(:,t) = ...        
            (1 + Government.demand_phys_growth_rate(t)) .* Sections.demand_in1year_from_govt_phys(:,t-1);

        % EXERCISE: SHOCK
        % Let's see what happens if we shock gov't demand by changing the weight of the public good (which is the most demanded good by the gov't).
        % We apply the shock in a time step when we have already reached an equilibrium path.
        % if t == 230
        %     [~, idx_max] = max(Sections.current_demand_from_govt_nominal(:,t));
        %     Sections.demand_in1year_from_govt_phys(idx_max,t) = ...        
        %         (1 + Government.demand_phys_growth_rate(t)) .* 0.7 * Sections.demand_in1year_from_govt_phys(idx_max,t-1);
        % end

        % CONSUMPTION BASKET UNITS BEING DEMANDED
        [~, idx] = max(Parameters.Government.exiobase_demand_relations_phys);
        Government.consumption_basket_units_demanded_in1year(t) = ...
            Sections.demand_in1year_from_govt_phys(idx, t) ./ Parameters.Government.exiobase_demand_relations_phys(idx);

    end    


    % TEST
    if any(Sections.demand_in1year_from_govt_phys(:,t) < 0, 'all')
        error('At time step %d, there is at least one negative value in ''Sections.demand_in1year_from_govt_phys''', t)
    end
    
    
    %% bank's stocks and flows


    % BANK'S STOCK OF DEPOSITS
    % sum of all deposits of sectors and households
    Bank.deposits(t) = ...
        sum(Sectors.deposits(t,:), 2) + sum(Households.deposits(t,:), 2);
    % Growth rate
    Bank.deposits_growth_rate(t) = ...
        (Bank.deposits(t) - Bank.deposits(t-1)) ./ Bank.deposits(t-1);


    % BANK'S RESERVES HOLDINGS AND ADVANCES
    
    % We define the bank's reserves and advances as residuals from the capital account column of the bank in the SFC transactions flow matrix.
    % Indeed, the bank's retained profits, delta loans, and delta deposits have already been defined.
    % Note that we must ensure that neither reserves nor advances become negative.

    bank_flow_residual = ...
        Bank.profits_retained(t) ...
        + (Bank.deposits(t) - Bank.deposits(t-1)) ... % change in deposits
        - (Bank.loans_stock(t) - Bank.loans_stock(t-1)); % change in loans
    
    % If the residual is positive, the bank will use it to reduce advances, and what remains after paying back all advances gets accumulated as reserves.
    if bank_flow_residual >= 0
        if bank_flow_residual <= Bank.advances(t-1)
            Bank.advances(t) = Bank.advances(t-1) - bank_flow_residual;
            Bank.reserves_holdings(t) = Bank.reserves_holdings(t-1);
        else 
            Bank.advances(t) = 0;
            Bank.reserves_holdings(t) = Bank.reserves_holdings(t-1) + bank_flow_residual - Bank.advances(t-1);
        end

    % If the residual is negative, the bank will see its reserves declining by the corresponding amount; if its reserves are insufficient, it will take advances from the central bank.
    else 
        if Bank.reserves_holdings(t-1) + bank_flow_residual >= 0
            Bank.reserves_holdings(t) = Bank.reserves_holdings(t-1) + bank_flow_residual;
            Bank.advances(t) = Bank.advances(t-1);
        else
            Bank.reserves_holdings(t) = 0;
            Bank.advances(t) = Bank.advances(t-1) - bank_flow_residual - Bank.reserves_holdings(t-1);
        end
    end

    % Test
    if Bank.advances(t) < 0
        error('At time step %d, there is a negative value in ''Bank.advances''', t)
    end
    % Test
    if Bank.reserves_holdings(t) < 0
        error('At time step %d, there is a negative value in ''Bank.reserves_holdings''', t)
    end

    

    % BANK'S NET WORTH
    % = assets - liabilities 
    % = loans + reserves - deposits - advances
    Bank.net_worth(t) = ...
        Bank.loans_stock(t) + Bank.reserves_holdings(t) - Bank.deposits(t) - Bank.advances(t);
    % Test
    if Bank.net_worth(t) < 0
        error('At time step %d, there is a negative value in ''Bank.net_worth''', t)
    end


    % BANK'S CAPITAL ADEQUACY RATIO
    % = equity / risky assets
    % (we don't include reserves holdings among assets, since they aren't risky)
    Bank.CAR(t) = Bank.net_worth(t) / Bank.loans_stock(t);


    %% central bank

    % ADVANCES
    % = (advances supplied to government) + (advances supplied to bank)
    CentralBank.advances(t) = Government.advances(t) + Bank.advances(t);

    % RESERVES
    % = (reserves held by bank) + (reserves held by gov't)
    CentralBank.reserves(t) = Bank.reserves_holdings(t) + Government.reserves_holdings(t);

    % NET WORTH 
    % = assets - liabilities
    CentralBank.net_worth(t) = CentralBank.advances(t) - CentralBank.reserves(t);

    
    %% tests
    
    % Government's stocks and flows balance
    if abs(...
            (...
            Government.taxes(t) - Government.consumption_expenditures(t) - Government.subsidies(t) ...
            + (Government.advances(t) - Government.advances(t-1)) - (Government.reserves_holdings(t) - Government.reserves_holdings(t-1)) ...
            )...
            ./ (Government.taxes(t) - Government.consumption_expenditures(t) - Government.subsidies(t))...
            ) > Parameters.error_tolerance_weak
        error('In time step %d, the sum along the Government column in the Transactions Flow Matrix is different than zero', t)
    end
    

    % SFC REDUNDANT EQUATION
    % Central Bank: the change in assets should be equal to the change in liabilities
    % delta(A) - delta(H) = 0
    % However if we test for:
    % abs(delta(A) - delta(H)) / (delta(A)) > error_tolerance
    % ..we may have problems since the denominator may be often close to zero, implying that the result is larger than the error tolerance.
    % Therefore, we use the fact that
    % delta(A) - delta(H) = 0 
    % ..can be rewritten as:
    % A(t) - A(t-1) - H(t) + H(t-1) = 0  --> (A(t) - H(t)) - (A(t-1) - H(t-1)) = 0
    % and therefore we test:
    % abs{[(A(t) - H(t)) - (A(t-1) - H(t-1))] / (A(t) - H(t))}  > error_tolerance
    if abs(...
           ((CentralBank.advances(t) - CentralBank.reserves(t)) - (CentralBank.advances(t-1) - CentralBank.reserves(t-1))) ...
           ./ (CentralBank.advances(t) - CentralBank.reserves(t))...
           ) > Parameters.error_tolerance_weak
        error('In time step %d, the change in central bank advances does not equal the change in central bank reserves (as should be the case from the central bank column in the Transactions Flow Matrix)', t) 
    end


    %% real values, deflated (not physical units)

    % When computing total real final demand or consumption (e.g. from hhs) we cannot sum units of different products (e.g. units of metals with units of fossil fuels).
    % Instead, we must first sum over nominal sales of different goods, and then divide by the GPD deflator.


    %%%%%%%%  HOUSEHOLDS  %%%%%%%%

    % TOTAL REAL DEFLATED HHS DEMAND
    % Level
    Economy.hhs_demand_defl(t) = ...
        sum(Sections.demand_from_hhs_nominal(:,:,t), "all")...
        ./ Economy.GDP_deflator(t);
    
    % TOTAL REAL DEFLATED HHS CONSUMPTION
    % Level
    Economy.hhs_consumption_defl(t) = ...
        sum(Households.consumption_expenditures(t,:), 2)...
        ./ Economy.GDP_deflator(t);
    % Growth rate
    Economy.hhs_consumption_defl_growth_rate(t) = ...
        Economy.hhs_consumption_defl(t) ./ Economy.hhs_consumption_defl(t-1) - 1;


    %%%%%%%%  SECTORS  %%%%%%%%
    
    % TOTAL REAL DEFLATED INVESTMENT DEMAND
    % Level
    Economy.current_investment_demand_defl(t) = ...
        sum(Sections.demand_in1year_from_invest_divisions_adj_after_loans_aggr_nomin(:,t-1)) ...
        ./ Economy.GDP_deflator(t);
    
    % TOTAL REAL DEFLATED INVESTMENT
    % Level
    Economy.investment_defl(t) = ...
        sum(Sectors.aggr_investment_sales_nominal(:,t))...
        ./ Economy.GDP_deflator(t);
    % Growth rate
    Economy.investment_defl_growth_rate(t) = ...
        Economy.investment_defl(t) ./ Economy.investment_defl(t-1) - 1;

    % REAL DEFLATED CAPITAL STOCK
    Sectors.tot_capital_defl(t,:) = ...
        Sectors.tot_capital_nominal(t,:) ./ Economy.GDP_deflator(t);

    % DEFLATED INVESTMENT COSTS
    Sectors.investments_costs_defl(t,:) = ...
        Sectors.investments_costs(t,:) ./ Economy.GDP_deflator(t);

    
    %%%%%%%%  GOVERNMENT  %%%%%%%%

    % TOTAL REAL DEFLATED GOV'T DEMAND
    Economy.current_govt_demand_defl(t) = ...
        sum(Sections.current_demand_from_govt_nominal(:,t))...
        ./ Economy.GDP_deflator(t);
    
    % TOTAL REAL DEFLATED GOV'T CONSUMPTION
    Economy.govt_consumption_defl(t) = ...
        sum(Sectors.sales_to_govt_nominal(:,t))...
        ./ Economy.GDP_deflator(t);


    %%%%%%%%  AGGREGATE  %%%%%%%%

    % TOTAL REAL DEFLATED FINAL DEMAND
    Economy.final_demand_defl(t) = ...
        Economy.hhs_demand_defl(t) + Economy.current_investment_demand_defl(t) + Economy.current_govt_demand_defl(t);

    % TOTAL REAL DEFLATED SALES
    Economy.tot_sales_to_final_demand_defl(t) = ...
        Economy.hhs_consumption_defl(t) + Economy.investment_defl(t) + Economy.govt_consumption_defl(t);
               

    %% macroeconomic variables

    % SHARE OF .. IN TOTAL NOMINAL PRODUCTION
    % .. Household consumption ..
    Economy.share_hh_cons_in_nominal_production(t) = ...
        sum(Sectors.sales_to_hhs_nominal(:,:,t), "all") ./ sum(Sectors.production_nominal(:,t));
    % .. Gov't consumption ..
    Economy.share_govt_cons_in_nominal_production(t) = ...
        sum(Sectors.sales_to_govt_nominal(:,t)) ./ sum(Sectors.production_nominal(:,t));
    % .. Investment ..
    Economy.share_investment_in_nominal_production(t) = ...
        sum(Sectors.aggr_investment_sales_nominal(:,t)) ./ sum(Sectors.production_nominal(:,t));
    % .. Intermediate sales ..
    Economy.share_intermediate_in_nominal_production(t) = ...
        sum(Sectors.S_square(:,:,t) .* Sectors.prices(t-1,:)', "all") ./ sum(Sectors.production_nominal(:,t));
    % .. Change in inventories ..
    Economy.share_delta_inventories_in_nominal_production(t) = ...
        sum((Sectors.inventories_phys(:,t) - Sectors.inventories_phys(:,t-1)) .* Sectors.unit_costs(t,:)') ./ sum(Sectors.production_nominal(:,t));
    % TEST
    if abs(1 - (Economy.share_hh_cons_in_nominal_production(t) + Economy.share_govt_cons_in_nominal_production(t) + Economy.share_investment_in_nominal_production(t) + Economy.share_intermediate_in_nominal_production(t) + Economy.share_delta_inventories_in_nominal_production(t))) > Parameters.error_tolerance_medium
        error('Sum of shares in total nominal production does not equal 1')
    end

    % TOTAL CAPITAL STOCKS & INVESTMENTS
    Economy.capital_stocks_phys(:,t) = sum(Divisions.capital_phys(:,:,t), 2);
    Economy.capital_stocks_nominal(:,t) = sum(Sectors.capital_nominal(:,:,t), 2);
    Economy.investments_in_each_asset_nominal(:,t) = sum(Sections.current_orders_from_investing_divisions_adj_for_rationing_phys(:,:,t), 2);


    % FINAL DEMAND RATIONING
    % = (total sales) / (total final demand)
    % Note that this measure is independed of whether you are using deflated or nominal values, because it is a ratio.
    Economy.final_demand_rationing(t) = ...
        Economy.tot_sales_to_final_demand_defl(t) ./ Economy.final_demand_defl(t);


    % HOUSEHOLDS' DEMAND RATIONING
    % = (total consumption) / (total final demand)
    Economy.hhs_demand_rationing(t) = ...
        Economy.hhs_consumption_defl(t) ./ Economy.hhs_demand_defl(t);


    % GOV'T DEMAND RATIONING
    % = (total consumption) / (total final demand)
    Economy.govt_demand_rationing(t) = ...
        Economy.govt_consumption_defl(t) ./ Economy.current_govt_demand_defl(t);


    %% emissions

    % Emissions flow
    Economy.emissions_flow(t) = ...
        sum(Divisions.emissions_flow(t,:), 2) + sum(Households.emissions_flow(t,:), 2) + Government.emissions_flow(t);

    % Emissions stock
    Economy.emissions_stock(t) = Economy.emissions_stock(t-1) + Economy.emissions_flow(t);

    % Percentage of total emissions flow due to electricity
    Economy.emissions_flow_from_electricity_percentage(t) = ...
        sum(Sectors.emissions_flow(t, Parameters.Sectors.idx_electricity_producing), 2) ./ Economy.emissions_flow(t);

    
end
%% AVERAGE VARIABLES

% NOTE: 
% We compute average variables by considering the "Parameters.valid_results_time_span"..
% ..which starts with the end of the model's stabilization period, and ends at the end of the simulation.

% AVERAGE GDP GROWTH RATE
% There are two different methodologies: "Average Annual Growth Rate" and "Compound Annual Growth Rate", see https://www.investopedia.com/terms/a/aagr.asp
Economy.average_GDP_real_growth_rate = ...
    mean(Economy.GDP_real_growth_rate(Parameters.valid_results_time_span), 'omitnan');
Economy.compound_GDP_real_growth_rate = ...
    (Economy.GDP_real(end) ./ Economy.GDP_real(Parameters.simulations_kickoff_after_stabilization)) ^ (1 / Parameters.valid_results_time_span_length) - 1;


% AVERAGE INFLATION RATES
% There are two different methodologies: "Average Annual Growth Rate" and "Compound Annual Growth Rate", see https://www.investopedia.com/terms/a/aagr.asp
% CPI
Economy.average_CPI_inflation = ...
    mean(Economy.CPI_inflation(Parameters.valid_results_time_span), 'omitnan');
Economy.compound_CPI_inflation = ...
    (Economy.CPI(end) ./ Economy.CPI(Parameters.simulations_kickoff_after_stabilization)) ^ (1 / Parameters.valid_results_time_span_length) - 1;
% GDP deflator
Economy.average_GDP_deflator_inflation = ...
    mean(Economy.GDP_deflator_inflation(Parameters.valid_results_time_span), 'omitnan');
Economy.compound_GDP_deflator_inflation = ...
    (Economy.GDP_deflator(end) ./ Economy.GDP_deflator(Parameters.simulations_kickoff_after_stabilization)) ^ (1 / Parameters.valid_results_time_span_length) - 1;


% AVERAGE REAL CONSUMPTION GROWTH RATE
Economy.average_hhs_consumption_defl_growth_rate = ...
    mean(Economy.hhs_consumption_defl_growth_rate(Parameters.valid_results_time_span), 'omitnan');

% AVERAGE REAL INVESTMENT GROWTH RATE
% We need to omit Inf values, otherwise the average is Inf as well
economy_investment_defl_growth_rate_valid_values = Economy.investment_defl_growth_rate(Parameters.valid_results_time_span);
Economy.average_investment_defl_growth_rate = ...
    mean(economy_investment_defl_growth_rate_valid_values(~isinf(economy_investment_defl_growth_rate_valid_values)), 'omitnan');

% AVERAGE LOANS GROWTH RATE
Economy.average_loans_stock_growth_rate = ...
    mean(Bank.loans_stock_growth_rate(Parameters.valid_results_time_span), 'omitnan');

% AVERAGE DEPOSITS GROWTH RATE
Economy.average_deposits_growth_rate = ...
    mean(Bank.deposits_growth_rate(Parameters.valid_results_time_span), 'omitnan');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%  RATIONING MEASURES  %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% We want to measure the rationing that is occuring in the economy.
% We use several indicators: rationing of hhs demand, investment, loans..

% For each measure, we find the number of years in which rationing occured..
% ..and then, we compute the average rationing percentage across those years in which rationing occured.

% Remind that we look only at the "valid_results_time_span"

% Let's define a threshold value of 99.9..%: whenever a value is below this threshold, rationing occurs
% (We don't use a value of 1 because it seems that because of a rounding error some rationing values are 99.999999..% instead of 1)
value_defining_rationing = 1 - 1e-3;


%%%%%%%  LOANS RATIONING  %%%%%%%

idx_years_with_loans_rationing = ...
    intersect(find(Bank.proportion_supply_vs_demanded_loans < value_defining_rationing), Parameters.valid_results_time_span);

% Number of years in which loans rationing occurs
Economy.nr_years_with_loans_rationing = numel(idx_years_with_loans_rationing);

% Average loans rationing across the years where rationing occurs
if ~isempty(idx_years_with_loans_rationing)
    Economy.average_loans_rationing = mean(Bank.proportion_supply_vs_demanded_loans(idx_years_with_loans_rationing));
else
    Economy.average_loans_rationing = 1;
end


%%%%%%%  FINAL DEMAND RATIONING  %%%%%%%

idx_years_with_final_demand_rationing = ...
    intersect(find(Economy.final_demand_rationing < value_defining_rationing), Parameters.valid_results_time_span);

% Number of years in which final demand rationing occures
Economy.nr_years_with_final_demand_rationing = numel(idx_years_with_final_demand_rationing);

% Average final demand rationing across the years where rationing occurs
if ~isempty(idx_years_with_final_demand_rationing)
    Economy.average_final_demand_rationing = mean(Economy.final_demand_rationing(idx_years_with_final_demand_rationing));
else
    Economy.average_final_demand_rationing = 1;
end


%%%%%%%  HOUSEHOLDS' DEMAND RATIONING  %%%%%%%

idx_years_with_hhs_demand_rationing = ...
    intersect(find(Economy.hhs_demand_rationing < value_defining_rationing), Parameters.valid_results_time_span);

% Number of years in which hhs demand rationing occures
Economy.nr_years_with_hhs_demand_rationing = numel(idx_years_with_hhs_demand_rationing);

% Average hhs demand rationing across the years where rationing occurs
if ~isempty(idx_years_with_hhs_demand_rationing)
    Economy.average_hhs_demand_rationing = mean(Economy.hhs_demand_rationing(idx_years_with_hhs_demand_rationing));
else
    Economy.average_hhs_demand_rationing = 1;
end


%%%%%%%  GOV'T DEMAND RATIONING  %%%%%%%

idx_years_with_govt_demand_rationing = ...
    intersect(find(Economy.govt_demand_rationing < value_defining_rationing), Parameters.valid_results_time_span);

% Number of years in which gov't demand rationing occures
Economy.nr_years_with_govt_demand_rationing = numel(idx_years_with_govt_demand_rationing);

% Average gov't demand rationing across the years where rationing occurs
if ~isempty(idx_years_with_govt_demand_rationing)
    Economy.average_govt_demand_rationing = mean(Economy.govt_demand_rationing(idx_years_with_govt_demand_rationing));
else
    Economy.average_govt_demand_rationing = 1;
end


%%%%%%%  CAPACITY ACCUMULATION RATIONING  %%%%%%%

idx_capacity_accumulation_rationing = Divisions.capacity_accumulation_rationing < value_defining_rationing;
nr_rationed_divisions_each_year = sum((Divisions.capacity_accumulation_rationing < value_defining_rationing), 2);
idx_years_with_cap_acc_rationing = intersect(find(nr_rationed_divisions_each_year ~= 0), Parameters.valid_results_time_span);

% Number of years in which at least one Division suffered from capacity accumulation rationing
Economy.nr_years_with_capacity_accumulation_rationing = numel(idx_years_with_cap_acc_rationing);

% Average number of Divisions suffering from rationing in the years where rationing occurs
if ~isempty(idx_years_with_cap_acc_rationing)
    Economy.average_nr_divisions_with_capacity_accumulation_rationing = ...
        mean(nr_rationed_divisions_each_year(idx_years_with_cap_acc_rationing));
else
    Economy.average_nr_divisions_with_capacity_accumulation_rationing = 0;
end

% Average capacity accumulation rationing in the years where rationing occurs, across Divisions where rationing occurs
average_capacity_accumulation_rationing_by_year = NaN * ones(Economy.nr_years_with_capacity_accumulation_rationing, 1);
for n = 1 : Economy.nr_years_with_capacity_accumulation_rationing
    current_year = idx_years_with_cap_acc_rationing(n);
    average_capacity_accumulation_rationing_by_year(n) = mean(Divisions.capacity_accumulation_rationing(current_year, idx_capacity_accumulation_rationing(current_year, :)), 2);
end
if ~isempty(idx_years_with_cap_acc_rationing)
    Economy.average_capacity_accumulation_rationing = mean(average_capacity_accumulation_rationing_by_year);
else
    Economy.average_capacity_accumulation_rationing = 1;
end



%% CLEARING THE WORKSPACE

clear i  j  k   File2Load   bank_flow_residual   sectors_deposits_before_loan_repayment...
    idx_section   proportion    ...
    real_GDP_current_year_current_prices   real_GDP_current_year_previous_prices...
    real_GDP_growth_rate_current_prices   real_GDP_growth_rate_previous_prices  ...
    real_GDP_previous_year_current_prices   real_GDP_previous_year_previous_prices ...
    aggregation_rule...
    sectors_products_available_for_hhs_phys   sectors_products_available_for_govt_phys   sectors_products_available_for_inventories_phys ...    
        

%% SAVING

save(sprintf('Triode %s simulation.mat', Rules.rationing), 'Rules', 'Parameters', 'Sections', 'Sectors', 'Bank', 'Households', 'CentralBank', 'Government', 'Economy')


%% TESTS

% NEGATIVE NPV
% We want to store those non-electricity Divisions that have experienced at least once, during the simulation, a negative NPV.
% Index
idx_non_electricity_divisions_with_negative_NPV = setdiff(find(any(Divisions.NPV < 0)), Parameters.Divisions.idx_electricity_producing);
% Names
Tests.non_electricity_divisions_with_negative_NPV = Parameters.Divisions.names(idx_non_electricity_divisions_with_negative_NPV);


% OTHER TESTS

for time = 1 : Parameters.T

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%  STOCK-FLOW CONSISTENCY  %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % SFC test
    if abs(...
            (...
            sum(Households.net_worth(time,:), 2) + sum(Sectors.net_worth(time,:), 2) + Bank.net_worth(time) + Government.net_worth(time) + CentralBank.net_worth(time) ...
            - (sum(Sectors.tot_capital_nominal(time,:), 2) + sum(Sectors.inventories_nominal(:,time)))...
            )...
            ./ (sum(Sectors.tot_capital_nominal(time,:), 2) + sum(Sectors.inventories_nominal(:,time))) ...
            ) > Parameters.error_tolerance_weak
        error (['In time step %d, total net worth in the economy is different from total nominal value of capital ' ...
            'plus total nominal value of inventories (as should be true from last row of SFC balance sheet matrix)'], time)
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%  SECTORS  %%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % NEGATIVE VALUE ADDED
    if any(Sectors.VA(time, :) < 0)
        warning('At time step %d, there is at least one negative value in ''Sectors.VA''', time)
    end

    % NEGATIVE DIVIDENDS
    % Check if any dividends have become negative
    if any(Sectors.dividends(time, :) < 0)
        warning(['At time step %d, there is at least one negative value in ''Sectors.dividends''. ' ...
            'However, you may want to interpret these as the households covering the sectors'' losses, i.e. bailing them out'], time)
    end        

    % NEGATIVE TAXES
    % Check if any taxes have become negative
    if any(Sectors.taxes(time, :) < 0)
        warning(['At time step %d, there is at least one negative value in ''Sectors.taxes''. ' ...
            'However, you may want to interpret this as the government helping sectors that face difficulties'], time)
    end

    % EXTREMELY NEGATIVE NET WORTH
    % Check if any net worth has become extremely negative
    if any(Sectors.net_worth(time, :) < - Sectors.assets(time, :))
        warning('At time step %d, there is at least one sector that has a very large negative net worth', time)
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%  BANK  %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % NEGATIVE DIVIDENDS
    % Check if dividends have become negative
    if Bank.dividends(time) < 0
        warning(['At time step %d, there is a negative value in ''Bank.dividends''.' ...
            'However, you may want to interpret these as the households covering the bank''s losses, i.e. bailing it out'], time)
    end            


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%  HOUSEHOLDS  %%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % NEGATIVE INCOME
    % Check if any income has become negative
    if any(Households.income(time, :) < 0)
        warning(['At time step %d, there is at least one negative value in ''Households.income''. ' ...
            'However, you may want to interpret this as the (capitalist) households helping sectors and/or bank that face difficulties, i.e. bailing them out'], time)
    end

end

clear time

% % total nominal sales must not be higher than total desired consumption expenditure
% if ~isempty(find(sum(Sectors.sales_to_hhs_nominal(:,2:Parameters.T), 'omitnan') > sum(Households.final_demand_budget(2:Parameters.T, :), 2)'))
%     error('total nominal sales are higher than total desired consumption expenditure')
% end

% % real sales to hhs must not be higher than real production destined to be sold to final demand sectors
% if ~isempty(find(Sectors.sales_to_hhs_phys > Sectors.products_available_for_final_demand_phys + 1e-9))
%     error('some real sales to hhs are higher than real production destined to be sold to final demand sectors')
% end


end

