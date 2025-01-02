function [sections_future_demand_from_invest_divisions_desired_phys, divisions_desired_investment_formula_cases, first_term, second_term] = ...
    Desired_Investments_function...
        (t, desired_investment_function_rule, rules_min_investment, rules_investment_reference_case_2B, time_step_corresponding_to_2022, ...
        sections_nr, divisions_nr, divisions_capital_assets_logical_matrix, ...    
        divisions_idx_shrinking, divisions_investment_threshold_coefficient, divisions_assumed_future_capacity_utilization, ...
        divisions_depreciation_rates, divisions_capital_productivity, ...
        divisions_production_driving_investment, divisions_capital_phys, ...
        divisions_prod_cap_of_each_asset_in1year, divisions_hypo_prod_cap_of_each_asset_in2years)


% FIRST TERM AND SECOND TERM
first_term = NaN * ones(sections_nr, divisions_nr); % This corresponds to the "1st term" as defined in the Latex file
first_term_numerator = NaN * ones(sections_nr, divisions_nr); % numerator of the "1st term"
second_term = NaN * ones(sections_nr, divisions_nr); % This corresponds to the "2nd term" as defined in the Latex file

% OUTPUTS OF THE FUNCTION
sections_future_demand_from_invest_divisions_desired_phys = NaN * ones(sections_nr, divisions_nr);
divisions_desired_investment_formula_cases = strings(1, divisions_nr);


% Desired production capacity in 2 years
divisions_desired_prod_cap_in2years = ...
    divisions_production_driving_investment ./ divisions_investment_threshold_coefficient';


for j = 1 : divisions_nr

    % Logical index of the commodities used as capital assets by Division j
    idx_assets = divisions_capital_assets_logical_matrix(:,j);    


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%  CASE 1  %%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if desired_investment_function_rule == "old" && any(divisions_hypo_prod_cap_of_each_asset_in2years(idx_assets, j) < divisions_desired_prod_cap_in2years(j))

        first_term_numerator(idx_assets, j) = ...
            divisions_desired_prod_cap_in2years(j);

        divisions_desired_investment_formula_cases(j) = "case 1";
        

    %%%%%%%  CASE 1.A  %%%%%%%
    elseif desired_investment_function_rule == "new" && all(divisions_hypo_prod_cap_of_each_asset_in2years(idx_assets, j) < divisions_desired_prod_cap_in2years(j))

        %%%  Case 1.A.1  %%%
        if divisions_desired_prod_cap_in2years(j) < min(divisions_prod_cap_of_each_asset_in1year(idx_assets, j)) && rules_min_investment == "yes" && rules_investment_reference_case_2B == "min" && not(ismember(j, divisions_idx_shrinking) &&  t > time_step_corresponding_to_2022)

            first_term_numerator(idx_assets, j) = ...
                min(divisions_prod_cap_of_each_asset_in1year(idx_assets, j));

            divisions_desired_investment_formula_cases(j) = "case 1.A.1";

        %%%  Case 1.A.2  %%%
        else

            first_term_numerator(idx_assets, j) = ...
                divisions_desired_prod_cap_in2years(j);
    
            divisions_desired_investment_formula_cases(j) = "case 1.A.2";

        end

    %%%%%%%  CASE 1.B  %%%%%%%
    elseif desired_investment_function_rule == "new" && any(divisions_hypo_prod_cap_of_each_asset_in2years(idx_assets, j) < divisions_desired_prod_cap_in2years(j))

        %%%  Case 1.B.1  %%%
        if rules_min_investment == "no" || (ismember(j, divisions_idx_shrinking) &&  t > time_step_corresponding_to_2022)

            first_term_numerator(idx_assets, j) = ...
                divisions_desired_prod_cap_in2years(j);
    
            divisions_desired_investment_formula_cases(j) = "case 1.B.1";

        %%%  Case 1.B.2  %%%
        else

            % Case 1.B.2.1 %
            if rules_investment_reference_case_2B == "max"

                first_term_numerator(idx_assets, j) = ...
                    max(divisions_hypo_prod_cap_of_each_asset_in2years(idx_assets, j));                    
        
                divisions_desired_investment_formula_cases(j) = "case 1.B.2.1"; 

            % Case 1.B.2.2 %
            else

                first_term_numerator(idx_assets, j) = ...
                    max(divisions_desired_prod_cap_in2years(j), min(divisions_prod_cap_of_each_asset_in1year(idx_assets, j)));                    
        
                divisions_desired_investment_formula_cases(j) = "case 1.B.2.2"; 

            end

        end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%  CASE 2  %%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    else

        %%%%%%%  CASE 2.A  %%%%%%%
        if rules_min_investment == "no" || (ismember(j, divisions_idx_shrinking) &&  t > time_step_corresponding_to_2022)

            first_term_numerator(idx_assets, j) = 0;

            divisions_desired_investment_formula_cases(j) = "case 2.A";


        %%%%%%%  CASE 2.B  %%%%%%%
        else
            
            %%%  Case 2.B.1: "Rule max"  %%%
            if rules_investment_reference_case_2B == "max"

                first_term_numerator(idx_assets, j) = ...
                    max(divisions_hypo_prod_cap_of_each_asset_in2years(idx_assets, j));

                divisions_desired_investment_formula_cases(j) = "case 2.B.1";

            %%%  Case 2.B.2: "Rule min"  %%%
            else
        
                first_term_numerator(idx_assets, j) = ...
                    min(divisions_prod_cap_of_each_asset_in1year(idx_assets, j));

                divisions_desired_investment_formula_cases(j) = "case 2.B.2";

            end

        end                                       
    end


    % "FIRST TERM"
    first_term(idx_assets, j) = ...
        first_term_numerator(idx_assets, j) ./ divisions_capital_productivity(idx_assets, j);


    % "FIRST TERM" FOR COMMODITIES NOT BEING USED AS CAPITAL ASSETS
    % Demand must be zero for commodities that are not being used as capital assets. Setting the first_term to zero ensures this.
    first_term(~idx_assets, j) = 0; 


    % THE "SECOND TERM"..        
    second_term(:,j) = ...
        - (1 - divisions_depreciation_rates(:,j) .* divisions_assumed_future_capacity_utilization(j)) .* divisions_capital_phys(:,j);                                        

        
    % SECTIONAL DEMANDS IMPLIED BY DESIRED INVESTMENTS
    sections_future_demand_from_invest_divisions_desired_phys(:,j) = ...
        max(0, first_term(:,j) + second_term(:,j));

end

end