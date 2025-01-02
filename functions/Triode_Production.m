function ...
    [technical_coefficients_sectors_x_sectors, green_share_realized, products_available_for_final_demand_sectoral, ...
    production_realized_sectoral, production_unbound_minus_inventories_sectoral] = ...
        Triode_Production ... % name of the function
            (target_green_share_enforcement_rule, rationing_rule, sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, ...
            technical_coefficients_sections_x_sectors, expected_final_demand_sectional, production_max_sectoral, ...
            inventories_sectoral, target_green_share)
%% IMPORTANT NOTE

% The function is not yet able to deal with the target green share enforcement in the Mixed model case, but only in the Proportional rationing case.

%% Description


%%%%%%%%%%%%%%  GENERAL FEATURES  %%%%%%%%%%%%%%

% This function implements the algorithms shown in the Excel files: 
    % "technical coefficients - complex economy - mixed model - case 1" 
    % "technical coefficients - complex economy - mixed model - case 2"
    % "technical coefficients - complex economy - proportional rationing"
    % "technical coefficients - complex economy - proportional rationing - with target green share"
        % Sheets: Example 1, Example 2, Example 8
    % "technical coefficients - simple economy - proportional rationing"
% The latter are very useful to understand what's going on in this function, which is quite complex.

% This function deals with: 
    % (1) Production constraints in any sector, using two alternative methods:
            % (A) Strict proportional rationing: the rationing is applied equally to all customers (intermediate custormers and final demand customers).
            % (B) Mixed model methodology: intermediate sales are prioritezed over final demand sales. See Chapter 13.2.1 in Miller and Blair (2009).
    % (2) Substitutability between green & brown electricity, with grid priority for the green sector.
    % (3) In addition, you may want to avoid that the green share overshoots the target green share (which is exogenously given by the IEA projections).
        % This is controlled by the "target_green_share_enforcement_rule": if it is equal to "yes", then the function applies the enforcement. 
        % If it is equal to "no", then the function does not apply the enforcement.

% So, this function is able to address all following situations:
    % a "complex" economy with green & brown electricity sectors (--> substitutability + grid priority). Rationing rule: strict proportional rationing.
    % a "complex" economy with green & brown electricity sectors (--> substitutability + grid priority). Rationing rule: mixed model methodology.
    % a "simple" economy with sectors where no substitutability is needed. Rationing rule: strict proportional rationing.
    % a "simple" economy with sectors where no substitutability is needed. Rationing rule: mixed model methodology.

% You don't need to tell the function whether you are in the "complex" economy or "simple" economy case, the code is able to tackle both situations.
% But you need to tell the function which rationing rule you want to follow: proportional rationing or mixed model.

% NOTE: all values are in REAL (physical) terms, NOT NOMINAL!




%%%%%%%%%%%%%%  SUBSTITUTABILITY GREEN / BROWN, AND GRID PRIORITY  %%%%%%%%%%%%%%

% While the green and brown electricity sectors are completely different when looking at the intermediate inputs they need (e.g. green electricity needs little intermediate inputs while brown electricity needs a lot of fossil fuels),
% .. they are instead completely substitutable from the perspective of the other industrial sectors that want to purchase electricity as intermediate inputs.
% Take for example the manufacturing sector: say it has a technical coefficient of 0.2 vis-a-vis electricity. It doesn't care whether this electricity is supplied by green or by brown producers.
% So the problem is how to define the technical coefficients along the rows of the green and brown electricity sectors.
% Indeed, as soon as you define those technical coefficients you are "freezing" the technology, i.e. you are basically saying that green and brown electricity are not substitutable.
% The solution is that we assume grid priority for the green sector.
% Let's assume that we know the electricity requirements of all sectors (e.g. manufacturing has a technical coefficient of 0.2 vis-a-vis electricity).
% The function starts by considering the case of electricity being 100% green. 
% If the green electricity sector isn't able to supply the whole amount of required electricity, 
% ..we assume a lower percentage of green electricity in the system, until we reach a level which the green electricity can supply.

% A further complication is given by the fact that not only the green, but also the brown or even other sectors can encounter production constraints.




%%%%%%%%%%%%%%  MIXED MODEL METHODOLOGY  %%%%%%%%%%%%%%

% We are using the Mixed Model methodology explained in Chapter 13.2.1 in Miller and Blair (2009).
% (As explained in the "Triode_Production_Nested" function, the Mixed Model formulation works also for the case when no production constraint is operating, in which case the standard Leontief quantity model is used)

% The problem is that with the Mixed model approach, since final demand (actually, products available for final demand)..
% .. of the constrained sector is a dependent variable, it could in some cases even become negative.

% If final demand is negative, we don't apply the mixed model to that sector anymore; instead, we fix its final demand to zero.

% If after this the constraint persists, and if there also still is a constraint in another sector,
% .. we don't apply the haircut solution (see below) but first we apply the Mixed model to this latter sector.
% Indeed, we want to be coherent with the Mixed model approach and thus we always first try this approach before using the haircut solution.

% If after this, the sector whose final demand was set to zero is still constrained (e.g. at 80%), we apply a 80% "haircut": 
% ..basically we assume that final demand by all other sectors is reduced by 80%.
% See Examples 8, 8(2), 8(3), 8(4) in the file "technical coefficients - complex economy - mixed model - case 1".



%%%%%%%%%%%%%%  HAIRCUT  %%%%%%%%%%%%%%

% Applying a haircut is the typical solution of the proportional rationing methodology, but it sometimes has also to be used within the Mixed model methodology case.

% IMPORTANT NOTE: when we apply a haircut, we cut the final demand of all sectors by that haircut value (to understand the underlying rationale, see Excel file "production constraints").
    % The underlying assumption is that all sectors are directly or indirectly connected to the constrained sector!!!
    % If this is not true (but I think this is basically impossible to happen), then this haircut method should be modified to take into account that some sectors won't be affected by the constraint.



%%%%%%%%%%%%%%  ENSURING ACTUAL GREEN SHARE EQUALS ASSUMED GREEN SHARE  %%%%%%%%%%%%%%

% As you can see in the below algorithms, each time we make a change (e.g. applying a haircut or the mixed model, setting final demand to zero, etc)..
% .. before continuing with another change, we need to make sure the actual green share equals assumed green share.

% The reason for doing so is that some constraints or problems (such as a negative final demand) may disappear once the actual green share equals the assumed green share. 
% See Example 4(2) and Example 7 in "technical coefficients - case 1" and "Example 5" in the file "technical coefficients - case 2".

   

%% Legenda

% Arrays named "_sectional" deal with sections, i.e. the green & brown electricity sector are aggregated.
    % Example: "expected_final_demand_sectional" contains expected final demand values for each section.
% Arrays named "_sectoral" deal with sectors, i.e. the green & brown electricity sector are disaggregated.
    % Example: "products_available_for_final_demand_sectoral" contains values at the sectoral level.


%% Defining new arrays

nr_sectors = length(sectors_sector_idx); % number of sectors
nr_sections = length(unique(sectors_section_idx)); % number of sections
max_length = 500; % max lenght of our arrays. We want to save the data generated during the while loops in the respective arrays, in order to be able to look at that data if needed.

green_share_assumed = NaN * ones(1, max_length);
green_share_actual = NaN * ones(1, max_length);

technical_coefficients_sectors_x_sectors_tmp = NaN * ones(nr_sectors, nr_sectors, max_length);
expected_final_demand_sectoral = NaN * ones(nr_sectors, max_length);
production_planned_sectoral = NaN * ones(nr_sectors, max_length);
production_planned_minus_inventories_sectoral = NaN * ones(nr_sectors, max_length);

% Production constraints
    % values should be >= 1
    % values = 1 --> sectors/sections that are constraining the economy and that are producing their maximum possible amount.
    % values > 1 --> sectors/sections that aren't constraining the economy and that are producing less than their maximum possible amount.
constraints_sectoral_tmp = NaN * ones(nr_sectors, max_length);
constraints_sectional_tmp = NaN * ones(nr_sections, max_length);

exogenous_values = NaN * ones(nr_sectors, max_length);
endogenous_values = NaN * ones(nr_sectors, max_length);
idx_sectors_exogenous_production = [];
idx_sectors_negative_final_demand = [];
idx_sections_negative_final_demand = [];
haircut_value = NaN * ones(1, max_length);


% Percentage value by which the haircut value is increased or decreased
percentage_increase = 0.01;

% Variable that controls for the target green share enforcement procedure. 
    % "active"     --> the actual green share has already overshot the target green share, and therefore we are forcing the assumed green share to be equal to target.
                     % In addition, as discussed at the end of "Example 2" in the Excel file "technical coefficients - complex economy - proportional rationing - with target green share",
                     % ..the definitions of the actual green share and of the sectional constraints change. This is implemented in the "Triode_Production_Nested" function.
    % "not active" --> the actual green share has not overshot the target green share yet, and thefore there is no enforcement procedure going on.
% At the beginning we set it to "not active". It may then be automatically changed later by the code.
green_share_enforcement = "not active";

% Error tolerance
error_tolerance_strong = 1e-12;


%% ALGORITHM
%% Initialization

% This block of the algorithm corresponds to the block labeled "Initialization" in each sheet of the above mentioned Excel files.


% COUNTER
counter = 1; % setting a counter that will be used to appropriately store data.


% ASSUMED GREEN SHARE
% We start by assuming a green electricity share of 100%
if isempty(idx_green)
    green_share_assumed(counter) = NaN;
else
    green_share_assumed(counter) = 1;
end


% HAIRCUT VALUE
haircut_value(counter) = 1; % This value may change within the function if a haircut has to be applied; ..
% ..for the beginning, since there is no haircut to be applied, we simply set the variable to 1, which means no haircut is present; ..
% ..when there will be a haircut to be applied, the variable "haircut" will take a value < 1.


% ACTUAL GREEN SHARE, TECHNICAL COEFFICIENTS SQUARE MATRIX, PLANNED PRODUCTION, PRODUCTION CONSTRAINTS..
[green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
exogenous_values(:, counter), endogenous_values(:, counter)] = ...
    Triode_Production_Nested... % function
        (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
         expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
         idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);


%% Ensuring actual green share equals assumed green share

% This block of the algorithm corresponds to the first block labeled "Ensuring actual green share equals assumed green share" in each sheet of the above mentioned Excel files.


% Now we compute the green share that is compatible with the green sector's max production:
    % e.g. this is 1 if the green sector is not constrained, i.e. it is able to supply all required electricity.
    % e.g. this is 0.7 if the green sector is constrained and able to supply only 70% of all required electricity.
% So in this block we are not taking into account the constraints that could arise from other sectors.
% Once we have computed the green share, we can see the constraints in the other sectors and address them, which we'll do in the following block.


while abs(green_share_actual(counter) - green_share_assumed(counter)) > error_tolerance_strong  % the while loop stops when the actual green share is equal to the assumed green share.
    
    counter = counter + 1;
    green_share_assumed(counter) = green_share_actual(counter - 1);
    haircut_value(counter) = haircut_value(counter - 1);
    
    [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
    production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
    constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
    exogenous_values(:, counter), endogenous_values(:, counter)] = ...
        Triode_Production_Nested... % function
            (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
             expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
             idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);
        
end


%% Ensuring green share doesn't overshoot target

% See "Example 1" and "Example 2" in Excel file "technical coefficients - complex economy - proportional rationing - with target green share"

if rationing_rule == "proportional rationing" && target_green_share_enforcement_rule == "yes" && target_green_share < green_share_actual(counter)

    green_share_enforcement = "active";

    counter = counter + 1;
    green_share_assumed(counter) = target_green_share;
    haircut_value(counter) = haircut_value(counter - 1);
    
    [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
    production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
    constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
    exogenous_values(:, counter), endogenous_values(:, counter)] = ...
        Triode_Production_Nested... % function
            (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
             expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
             idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);

end


%% Saving unbound production

% SAVING UNBOUND PRODUCTION MINUS INVENTORIES

% This is the production level implied by the final demand vector, without considering the sectoral production capacities, ..
% ..except for the green electricity sector, which complies with its production capacity and with the target green share
% (i.e. the actual green share is the minimum between the green share implied by its production capacity and the target green share).

% We want to store this array because it is useful to compare such "ideal", "unbound" production level..
% ..with the actual/realized one or with the production capacity.
% For example, it will allow us to compute the production constraints.
% Note that we are considering production net of inventories (i.e. they are subtracted).

production_unbound_minus_inventories_sectoral = production_planned_minus_inventories_sectoral(:, counter);


%% Addressing production constraints

% This block corresponds to the block labeled "Addressing production constraints" in each sheet of the above mentioned Excel files.

% Now we address the production constraints arising from the brown electricity sector and/or from non-electricity sectors.

if rationing_rule == "proportional rationing"  % RATIONING RULE: STRICT PROPORTIONAL
    %% While loop
    
    % We want the while loop to continue until there are no production constraints.
    
    while any(constraints_sectional_tmp(:, counter) < 1 - error_tolerance_strong)
        %% Apply the haircut
                
        % UPDATING THE COUNTER
        counter = counter + 1;


        % HAIRCUT VALUE
        % Most constraining value among the sectional constraints.
        haircut_value(counter) = min(constraints_sectional_tmp(:, counter-1));


        % ASSUMED GREEN SHARE
        green_share_assumed(counter) = green_share_actual(counter-1);


        % ACTUAL GREEN SHARE, TECHNICAL COEFFICIENTS SQUARE MATRIX, PLANNED PRODUCTION, PRODUCTION CONSTRAINTS..        
        [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
        production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
        constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
        exogenous_values(:, counter), endogenous_values(:, counter)] = ...
            Triode_Production_Nested... % function
                (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
                 expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
                 idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);
       


        %% Ensuring actual green share equals assumed green share
            
        % We want to make sure that the actual green share equals the assumed green share before continuing.

        while abs(green_share_actual(counter) - green_share_assumed(counter)) > error_tolerance_strong  % the while loop stops when the actual green share is equal to the assumed green share.
            
            counter = counter + 1;
            green_share_assumed(counter) = green_share_actual(counter - 1);
            haircut_value(counter) = haircut_value(counter - 1);
            
            [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
            production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
            constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
            exogenous_values(:, counter), endogenous_values(:, counter)] = ...
                Triode_Production_Nested... % function
                    (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
                     expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
                     idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);
        end


        %% Check if there is abundant production capacity in all sections
        % It could be that after having applied the haircut and having reached the new equilibrium green share, all sections have abundant production capacity.
        % This is because the haircut value was determined in a setting with a lower green share than the current equilibrium one;
        % since now the green share is higher, overall intermediate inputs requirements in the economy are lower and thus there might be abundant production capacity in all sections.
        % In case all sections have abundant production capacity, we want to find the mildest haircut value compatible with production capacities.
        while all(constraints_sectional_tmp(:, counter) > 1 + error_tolerance_strong)
            %% Slightly soften the haircut

            % UPDATING THE COUNTER
            counter = counter + 1;


            % NEW HAIRCUT VALUE    
            % We soften the haircut by 1 percentage point.
            haircut_value(counter) = haircut_value(counter-1) + percentage_increase;


            % ASSUMED GREEN SHARE
            green_share_assumed(counter) = green_share_actual(counter-1);


            % ACTUAL GREEN SHARE, TECHNICAL COEFFICIENTS SQUARE MATRIX, PLANNED PRODUCTION, PRODUCTION CONSTRAINTS..
            [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
            production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
            constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
            exogenous_values(:, counter), endogenous_values(:, counter)] = ...
                Triode_Production_Nested... % function
                    (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
                     expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
                     idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);


            %% Ensuring actual green share equals assumed green share
    
            % We want to make sure that the actual green share equals the assumed green share before continuing.
    
            while abs(green_share_actual(counter) - green_share_assumed(counter)) > error_tolerance_strong  % the while loop stops when the actual green share is equal to the assumed green share.
                
                counter = counter + 1;
                green_share_assumed(counter) = green_share_actual(counter - 1);
                haircut_value(counter) = haircut_value(counter - 1);
                
                [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
                production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
                constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
                exogenous_values(:, counter), endogenous_values(:, counter)] = ...
                    Triode_Production_Nested... % function
                        (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
                         expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
                         idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);
            end


        end
        %% If a constraint is hit, return to previous haircut value
        
        % At some point, by slightly softening the haircut step by step (as done in the previous while loop), we'll reach a haircut value that is too mild..
        % ..and that implies some production constraints. If this is the case, we'll want to tighten the haircut by 1 percentage point to go back to a setting where no production constraint arises.
        
        if any(constraints_sectional_tmp(:, counter) < 1 - error_tolerance_strong)     

            % UPDATING THE COUNTER
            counter = counter + 1;


            % NEW HAIRCUT VALUE
            % Slightly tighten the haircut value by 1 percentage point.
            haircut_value(counter) = haircut_value(counter-1) - percentage_increase;


            % ASSUMED GREEN SHARE
            green_share_assumed(counter) = green_share_actual(counter-1);


            % ACTUAL GREEN SHARE, TECHNICAL COEFFICIENTS SQUARE MATRIX, PLANNED PRODUCTION, PRODUCTION CONSTRAINTS..
            [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
            production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
            constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
            exogenous_values(:, counter), endogenous_values(:, counter)] = ...
                Triode_Production_Nested... % function
                    (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
                     expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
                     idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);
        end


        %% Ensuring actual green share equals assumed green share
    
        % We want to make sure that the actual green share equals the assumed green share before continuing.

        while abs(green_share_actual(counter) - green_share_assumed(counter)) > error_tolerance_strong  % the while loop stops when the actual green share is equal to the assumed green share.
            
            counter = counter + 1;
            green_share_assumed(counter) = green_share_actual(counter - 1);
            haircut_value(counter) = haircut_value(counter - 1);
            
            [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
            production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
            constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
            exogenous_values(:, counter), endogenous_values(:, counter)] = ...
                Triode_Production_Nested... % function
                    (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
                     expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
                     idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);
        end


        %% Ensuring green share doesn't overshoot target

        % See "Example 8" in Excel file "technical coefficients - complex economy - proportional rationing - with target green share"

        if target_green_share_enforcement_rule == "yes" && target_green_share < green_share_actual(counter)
        
            green_share_enforcement = "active";
        
            counter = counter + 1;
            green_share_assumed(counter) = target_green_share;
            haircut_value(counter) = haircut_value(counter - 1);
            
            [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
            production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
            constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
            exogenous_values(:, counter), endogenous_values(:, counter)] = ...
                Triode_Production_Nested... % function
                    (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
                     expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
                     idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);


            while any(constraints_sectional_tmp(:, counter) < 1 - error_tolerance_strong)
                
                counter = counter + 1;                    
                green_share_assumed(counter) = green_share_actual(counter-1);

                % NEW HAIRCUT VALUE
                % Slightly tighten the haircut value by 1 percentage point.
                haircut_value(counter) = haircut_value(counter-1) - percentage_increase;
    
    
                % ACTUAL GREEN SHARE, TECHNICAL COEFFICIENTS SQUARE MATRIX, PLANNED PRODUCTION, PRODUCTION CONSTRAINTS..
                [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
                production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
                constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
                exogenous_values(:, counter), endogenous_values(:, counter)] = ...
                    Triode_Production_Nested... % function
                        (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
                         expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
                         idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);

            end
        
        end

    end
elseif rationing_rule == "mixed model"   % RATIONING RULE: MIXED MODEL
    %% While loop

    % The while loop stops as soon as:
        % there is no production constraint in any sector
                        % AND 
        % there is no negative value for products available for sale to final demand

    % In other words, the while loop continues until:
        % there are production constraints                        
                        % OR 
        % there is a negative value for products available for sale to final demand  
   

    while (any(constraints_sectional_tmp(:, counter) < 1 - error_tolerance_strong)) || ...
          (any(expected_final_demand_sectoral(:, counter) < 0))
        %% Mixed Model: exogenously fixing production of most constrained section
    
        % If there are constrained sections, whose final demand was not already set to zero, we apply the Mixed model to those sections,
        % i.e. we exogenously fix the total production of the most constrained section to its max value, while letting its final demand be computed endogenously.
        % We exclude sections whose final demand had been set to zero, because to those sections the Mixed model has already been applied! (see Example 8(3) in Excel file "technical coefficients - complex economy - mixed model - case 1")

        if ~isempty (setdiff(find(constraints_sectional_tmp(:, counter) < 1 - error_tolerance_strong), idx_sections_negative_final_demand))

            
            % UPDATING THE COUNTER
            counter = counter + 1;
        
        
            % INDEXES
            % index of the most constrained section whose final demand was not already set to zero
            tightest_constraint = min(constraints_sectional_tmp(setdiff(1:end, idx_sections_negative_final_demand), counter-1));
            idx_most_constrained_section = find(constraints_sectional_tmp(:, counter-1) == tightest_constraint);
            % index of the corresponding most constrained sector(s) (e.g. if the most constrained section is electricity, then the following vector will return the indexes of both green and brown electricity sectors)
            idx_most_constrained_sector = find(sectors_section_idx == idx_most_constrained_section);
            % index of sectors whose production has to be set exogenously
            idx_sectors_exogenous_production = [idx_sectors_exogenous_production, idx_most_constrained_sector];
            
            
            % ASSUMED GREEN SHARE
            if ismember(idx_brown, idx_most_constrained_sector)
                % The electricity section is the most constrained.
                % In this case, since we'll exogenously set the production of green and brown electricity to their max values, we set the green share to simply be equal to the implied green proportion.
                % See Example 2 in Excel file "technical coefficients - complex economy - mixed model - case 1"
                green_share_assumed(counter) = production_max_sectoral(idx_green) / (production_max_sectoral(idx_green) + production_max_sectoral(idx_brown));
            else 
                % If a non-electricity section is the most constrained one..
                green_share_assumed(counter) = green_share_actual(counter-1);        
            end


            % HAIRCUT VALUE
            haircut_value(counter) = haircut_value(counter-1);


            % ACTUAL GREEN SHARE, TECHNICAL COEFFICIENTS SQUARE MATRIX, PLANNED PRODUCTION, PRODUCTION CONSTRAINTS..
            [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
            production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
            constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
            exogenous_values(:, counter), endogenous_values(:, counter)] = ...
                Triode_Production_Nested... % function
                    (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
                     expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
                     idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);


        end


        %% Ensuring actual green share equals assumed green share
        
        % We want to make sure that the actual green share equals the assumed green share before continuing. 

        while abs(green_share_actual(counter) - green_share_assumed(counter)) > error_tolerance_strong  % the while loop stops when the actual green share is equal to the assumed green share.
            
            counter = counter + 1;
            green_share_assumed(counter) = green_share_actual(counter - 1);
            haircut_value(counter) = haircut_value(counter-1);
            
            [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
            production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
            constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
            exogenous_values(:, counter), endogenous_values(:, counter)] = ...
                Triode_Production_Nested... % function
                    (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
                     expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
                     idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);
        end


        %% Setting negative final demand to zero
        
        % For sectors that may have a negative final demand (or better said, products available for final demand), we set their final demand to zero.

        if any(expected_final_demand_sectoral(:, counter) < 0)

            % UPDATING THE COUNTER
            counter = counter + 1;
    
    
            % INDEXES
            % Index of sectors with negative final demand
            idx_sectors_negative_final_demand = [idx_sectors_negative_final_demand, find(expected_final_demand_sectoral(:, counter-1) < 0)];
            % Index of sections with negative final demand
            idx_sections_negative_final_demand = unique(sectors_section_idx(idx_sectors_negative_final_demand));
            % Updating the index of sectors whose production is exogenously set:
                % the sector whose final demand is negative won't be part of the index anymore, since we set its final demand to zero. 
            idx_sectors_exogenous_production = setdiff(idx_sectors_exogenous_production, idx_sectors_negative_final_demand);
    
    
            % ASSUMED GREEN SHARE
            green_share_assumed(counter) = green_share_actual(counter-1);


            % HAIRCUT VALUE
            haircut_value(counter) = haircut_value(counter-1);
    
    
            % ACTUAL GREEN SHARE, TECHNICAL COEFFICIENTS SQUARE MATRIX, PLANNED PRODUCTION, PRODUCTION CONSTRAINTS..
            [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
            production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
            constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
            exogenous_values(:, counter), endogenous_values(:, counter)] = ...
                Triode_Production_Nested... % function
                    (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
                     expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
                     idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);
            
        end

        %% Ensuring actual green share equals assumed green share
        
        % We want to make sure that the actual green share equals the assumed green share before continuing.

        while abs(green_share_actual(counter) - green_share_assumed(counter)) > error_tolerance_strong  % the while loop stops when the actual green share is equal to the assumed green share.
            
            counter = counter + 1;
            green_share_assumed(counter) = green_share_actual(counter - 1);
            haircut_value(counter) = haircut_value(counter-1);
            
            [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
            production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
            constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
            exogenous_values(:, counter), endogenous_values(:, counter)] = ...
                Triode_Production_Nested... % function
                    (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
                     expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
                     idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);
        end
            
            
        %% Fixing further production constraints
    
        % IF the sections whose final demand was set to zero are still facing production constraints, ..
        % AND IF there are no other sections facing constraints (in which case we would first want to apply the Mixed model to those sectors, which would be done by returning to the first block in this while loop)..
        % THEN we take the tightest constraint and use it to cut the final demand of all other sections.

        if any(constraints_sectional_tmp(idx_sections_negative_final_demand, counter) < 1 - error_tolerance_strong) && ...
            all(constraints_sectional_tmp(setdiff(1:end, idx_sections_negative_final_demand), counter) > 1 - error_tolerance_strong)
            %% Apply the haircut 
            
            % UPDATING THE COUNTER
            counter = counter + 1;


            % HAIRCUT VALUE
            % Most constraining value among sections whose final demand was exogenously set to zero.
            haircut_value(counter) = min(constraints_sectional_tmp(idx_sections_negative_final_demand, counter-1));


            % UPDATING FINAL DEMAND VECTOR
            % see Example 8(5) in Excel file "technical coefficients - complex economy - mixed model - case 1"
            % In case there are sections whose production had been exogenously set, we have to redifine their final demand as the final demand implied by the mixed model.
            idx_sections_exogenous_production = unique(sectors_section_idx(idx_sectors_exogenous_production));
            expected_final_demand_sectional(idx_sections_exogenous_production) = sum(expected_final_demand_sectoral(idx_sectors_exogenous_production, counter-1));
            % (we use the sum because if the section whose production had been exogenously set is the electricity one, then the final demand is the sum of green and brown final demand)


            % UPDATING INDEX OF SECTORS WITH EXOGENOUSLY SET PRODUCTION
            % Once we apply a haircut, no sector has its production exogenously set anymore.
            idx_sectors_exogenous_production = [];
            idx_sections_exogenous_production = [];


            % ASSUMED GREEN SHARE
            green_share_assumed(counter) = green_share_actual(counter-1);


            % ACTUAL GREEN SHARE, TECHNICAL COEFFICIENTS SQUARE MATRIX, PLANNED PRODUCTION, PRODUCTION CONSTRAINTS..
            [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
            production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
            constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
            exogenous_values(:, counter), endogenous_values(:, counter)] = ...
                Triode_Production_Nested... % function
                    (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
                     expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
                     idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);


            %% Ensuring actual green share equals assumed green share
        
            % We want to make sure that the actual green share equals the assumed green share before continuing.
    
            while abs(green_share_actual(counter) - green_share_assumed(counter)) > error_tolerance_strong  % the while loop stops when the actual green share is equal to the assumed green share.
                
                counter = counter + 1;
                green_share_assumed(counter) = green_share_actual(counter - 1);
                haircut_value(counter) = haircut_value(counter-1);
                
                [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
                production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
                constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
                exogenous_values(:, counter), endogenous_values(:, counter)] = ...
                    Triode_Production_Nested... % function
                        (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
                         expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
                         idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);
            end


            %% Check if there is abundant production capacity in all sectors
            % It could be that after having applied the haircut and having reached the new equilibrium green share, all sections have abundant production capacity.
            % This is because the haircut value was determined in a setting with a lower green share than the current equilibrium one;
            % since now the green share is higher, overall intermediate inputs requirements in the economy are lower and thus there might be abundant production capacity in all sections.
            % In case all sections have abundant production capacity, we want to find the mildest haircut value compatible with production capacities.            
            while all(constraints_sectional_tmp(:, counter) > 1 + error_tolerance_strong)
                %% Slightly soften the haircut

                % UPDATING THE COUNTER
                counter = counter + 1;


                % NEW HAIRCUT VALUE
                % We soften the haircut by 1 percentage point.
                haircut_value(counter) = haircut_value(counter-1) + percentage_increase;


                % ASSUMED GREEN SHARE
                green_share_assumed(counter) = green_share_actual(counter-1);
    
    
                % ACTUAL GREEN SHARE, TECHNICAL COEFFICIENTS SQUARE MATRIX, PLANNED PRODUCTION, PRODUCTION CONSTRAINTS..
                [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
                production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
                constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
                exogenous_values(:, counter), endogenous_values(:, counter)] = ...
                    Triode_Production_Nested... % function
                        (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
                         expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
                         idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);


                %% Ensuring actual green share equals assumed green share
        
                % We want to make sure that the actual green share equals the assumed green share before continuing.
        
                while abs(green_share_actual(counter) - green_share_assumed(counter)) > error_tolerance_strong  % the while loop stops when the actual green share is equal to the assumed green share.
                    
                    counter = counter + 1;
                    green_share_assumed(counter) = green_share_actual(counter - 1);
                    haircut_value(counter) = haircut_value(counter-1);
                    
                    [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
                    production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
                    constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
                    exogenous_values(:, counter), endogenous_values(:, counter)] = ...
                        Triode_Production_Nested... % function
                            (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
                             expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
                             idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);
                end


            end
            %% If a constraint is hit, return to previous haircut value
            
            % At some point, by slightly soften the haircut step by step (as done in the previous while loop), we'll reach a haircut value that is too mild..
            % ..and that implies some production constraints. If this is the case, we'll want to tighten the haircut by 1 percentage point to go back to a setting where no production constraint arises.
        
            if any(constraints_sectional_tmp(:, counter) < 1 - error_tolerance_strong)

                % UPDATING THE COUNTER
                counter = counter + 1;


                % NEW HAIRCUT VALUE
                % Slightly tighten the haircut value by 1 percentage point.
                haircut_value(counter) = haircut_value(counter-1) - percentage_increase;


                % ASSUMED GREEN SHARE
                green_share_assumed(counter) = green_share_actual(counter-1);
    
    
                % ACTUAL GREEN SHARE, TECHNICAL COEFFICIENTS SQUARE MATRIX, PLANNED PRODUCTION, PRODUCTION CONSTRAINTS..
                [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
                production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
                constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
                exogenous_values(:, counter), endogenous_values(:, counter)] = ...
                    Triode_Production_Nested... % function
                        (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
                         expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
                         idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);
            end


            %% Ensuring actual green share equals assumed green share
        
            % We want to make sure that the actual green share equals the assumed green share before continuing.
    
            while abs(green_share_actual(counter) - green_share_assumed(counter)) > error_tolerance_strong  % the while loop stops when the actual green share is equal to the assumed green share.
                
                counter = counter + 1;
                green_share_assumed(counter) = green_share_actual(counter - 1);
                haircut_value(counter) = haircut_value(counter-1);
                
                [green_share_actual(counter), expected_final_demand_sectoral(:, counter),...
                production_planned_sectoral(:, counter), production_planned_minus_inventories_sectoral(:, counter),...
                constraints_sectoral_tmp(:, counter), constraints_sectional_tmp(:, counter), technical_coefficients_sectors_x_sectors_tmp(:, :, counter),...
                exogenous_values(:, counter), endogenous_values(:, counter)] = ...
                    Triode_Production_Nested... % function
                        (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
                         expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, idx_sectors_exogenous_production, ...
                         idx_sectors_negative_final_demand, haircut_value(counter), green_share_assumed(counter), green_share_enforcement);
            end



        end    
    end
end
%% Delete unfilled values from arrays

% For convenience and readability, we delete from the arrays all values that are still NaNs because of the fact that the while loop stopped before filling them.

technical_coefficients_sectors_x_sectors_tmp(:, :, counter+1 : end) = [];
green_share_assumed(counter+1 : end) = [];
green_share_actual(counter+1 : end) = [];
expected_final_demand_sectoral(:, counter+1 : end) = [];
production_planned_sectoral(:, counter+1 : end) = [];
production_planned_minus_inventories_sectoral(:, counter+1 : end) = [];
exogenous_values(:, counter+1 : end) = [];
constraints_sectoral_tmp(:, counter+1 : end) = [];
constraints_sectional_tmp(:, counter+1 : end) = [];
haircut_value(counter+1 : end) = [];


%% Tests


% CHECK THAT ACTUAL GREEN SHARE EQUALS ASSUMED GREEN SHARE
% When the while loop stops, it has to be the case that actual green share equals the assumed green share.
if abs(green_share_actual(counter) - green_share_assumed(counter)) > 1e-6
    error("actual green share is different from the assumed green share")
end


% CHECK THAT FINAL DEMAND IS NON-NEGATIVE
% With the Mixed model approach that we use (i.e., for a constrained sector, fixing as exogenous its quantity of total production to its max level..
% and letting its final demand adapt endogenously), final demand of the constrained sector could in some cases even become negative.
% However, in Algorithm/2 above we address this issue and make sure that final demand doesn't become negative.
% Thus, if at the end of the computations the function returns a negative final demand, this is an error.
if any(expected_final_demand_sectoral(:, counter) < 0)
    error("The quantity of available products for final demand of one or more sectors is negative.")
end

%% Output arrays

% Let's define the arrays that will be given as an output by our function.

% Technical coefficients matrix
technical_coefficients_sectors_x_sectors = technical_coefficients_sectors_x_sectors_tmp(:, :, counter);

% Green electricity share
green_share_realized = green_share_actual(counter);

% Products available for final demand
products_available_for_final_demand_sectoral = expected_final_demand_sectoral(:, counter);

% Total realized production (no previous inventories included!)
production_realized_sectoral = production_planned_minus_inventories_sectoral(:, counter);


end