function [green_share_actual, expected_final_demand_sectoral, production_planned_sectoral, ...
    production_planned_minus_inventories_sectoral, sectoral_constraints, sectional_constraints, ...
    technical_coefficients_sectors_x_sectors, exogenous_values, endogenous_values] = ...
    Triode_Production_Nested... % name of the function
        (sectors_sector_idx, sectors_section_idx, idx_electricity_section, idx_green, idx_brown, technical_coefficients_sections_x_sectors, ...
        expected_final_demand_sectional, production_max_sectoral, inventories_sectoral, ...
        idx_exogenous_production, idx_negative_final_demand, haircut_value, green_share_assumed, green_share_enforcement)
%% Description of the function


% RELATIONSHIP WITH THE MAIN FUNCTION
% The present function is repeatedly called within the main function that is crucial of the Triode model, namely the "Triode_Production" function.
% Have a look at the "Description" and "Legenda" sections in the "Triode_Production" function:
% those sections are useful to understand the present function.


% THIS FUNCTION ENSURES THAT THE ACTUAL GREEN SHARE EQUALS THE ASSUMED GREEN SHARE.
% You can see that this process is repeatedly needed within our algorithmic solution of the problem of searching for the green share that is compatible with the economy,
% as depicted in the Excel files "technical coefficients - complex economy - mixed model - case 1" and "technical coefficients - complex economy - proportional rationing".


% MIXED MODEL FORMULATION
% In this function, we make use of the Mixed model formulation of the input-output model --> see Chapter 13.2.1 in Miller and Blair (2009).
% The Mixed model formulation is able to take into account possible production constraints. 
% While it is not explicitly mentioned by Miller & Blair, I have realized that the standard Leontief quantity model formula x=L*f (eq. 2.11 in Chapter 2, Miller and Blair 2009) ..
%.. (which does not take potential production constraints into account) can be regarded to as a specific case of the Mixed model formula.
% Indeed, when there is no constraint operating, the formula of the Mixed model boils down to the x=L*f formula.
% So in this function we simply use the Mixed model formulation, which will work also for the case when no production constraint is operating.


% INPUT ARRAYS
% "green_share_assumed" --> it's the assumed green share inherited from the "Triode_Production" function.
% These arrays: "idx_exogenous_production", "idx_negative_final_demand", "haircut_value"..
    % ..are inherited from the "Triode_Production" function, are applied within the present function but do not change whithin the present function.
    % Indeed, this function simply ensures that the actual green share equals the assumed green share;
    % it does NOT decide: whether to exogenously set the production of a sector, whether to set a negative final demand to zero, or whether to apply a haircut.
    % These decisions are taken in the "Triode_Production" function and are simply inherited into this function and applied if relevant.


%% Defining new arrays

nr_sectors = length(sectors_sector_idx); % number of sectors
nr_sections = length(unique(sectors_section_idx)); % number of sections
ID_Matrix = eye(nr_sectors); % identity matrix that will be useful when using the input-output formulas (Mixed model)
sectors_shares_assumed = NaN * ones(nr_sectors, 1);
technical_coefficients_sectors_x_sectors = NaN * ones(nr_sectors, nr_sectors);
production_planned_sectoral = NaN * ones(nr_sectors, 1);
expected_final_demand_sectoral = NaN * ones(nr_sectors, 1);
exogenous_values = NaN * ones(nr_sectors, 1);
sectional_constraints = NaN * ones(nr_sections, 1);


%% Computations


% SECTORS' SHARES
% this is an auxiliary vector that contains the green and the brown shares. 
% For instance, if the green share in electricity production is 35%, then the brown share is (100%-35%) = 65% = 0.65.
% The shares of the other sectors are just auxiliary and are simply 1 by default (they are actually meaningless..).
for i = 1 : nr_sectors
    if sectors_sector_idx(i) == idx_green % for the green sector
        sectors_shares_assumed(i) = green_share_assumed;
    elseif sectors_sector_idx(i) == idx_brown % for the brown sector
        sectors_shares_assumed(i) = 1 - green_share_assumed;
    else % for all other sectors
        sectors_shares_assumed(i) = 1;
    end
end


% TECHNICAL COEFFICIENTS, PLANNED PRODUCTION, FINAL DEMAND
for i = 1 : nr_sectors
    technical_coefficients_sectors_x_sectors(i,:) = sectors_shares_assumed(i) * technical_coefficients_sections_x_sectors(sectors_section_idx(i), :);
    if ismember(i, idx_exogenous_production) % if the sector is among those whose production has to be exogenously set, we do so.
        production_planned_sectoral(i) = production_max_sectoral(i);
    elseif ismember(i, idx_negative_final_demand) % if the sector is the one that had a negative final demand, we set its final demand to zero.
        expected_final_demand_sectoral(i) = 0;
    else % .. in the other cases, the sector's final demand is set equal to the demand of that sector's product, multiplied by the haircut value (which is 1 if there is no haircut to be applied).
        expected_final_demand_sectoral(i) = haircut_value * sectors_shares_assumed(i) * expected_final_demand_sectional(sectors_section_idx(i));
    end
end
    

% VECTOR OF EXOGENOUS VALUES
% We fill the vector of exogenously set values, which we'll need when computing the endogenous values through formula 13.52 in Chapter 13.2.1 in Miller and Blair (2009).
% Basically, this vector of exogenously set values corresponds to the vector on the right hand side of equation 13.52.
    % For sectors whose production is exogenously set, obviously the exogenous value is their production.
    % For sectors whose production is not exogenously set, the exogenous value is their final demand, as in the standard Leontief quantity model.
for i = 1 : nr_sectors
    if ismember(i, idx_exogenous_production)
        exogenous_values(i) = production_planned_sectoral(i);
    else
        exogenous_values(i) = expected_final_demand_sectoral(i);
    end
end


% N-MATRIX
% This is the N matrix as defined in Chapter 13.2.1 in Miller and Blair (2009) at the beginning of page 623.
N_matrix = NaN * ones(nr_sectors, nr_sectors);
for i = 1 : nr_sectors
    if ismember(i, idx_exogenous_production)
        N_matrix(:,i) = technical_coefficients_sectors_x_sectors(:,i) - ID_Matrix(:,i);
    else
        N_matrix(:,i) = ID_Matrix(:,i);
    end
end


% M-MATRIX
% This is the M matrix as defined in Chapter 13.2.1 in Miller and Blair (2009) at the beginning of page 623.
M_matrix = NaN * ones(nr_sectors, nr_sectors);
for i = 1 : nr_sectors
    if ismember(i, idx_exogenous_production)
        M_matrix(:,i) = - ID_Matrix(:,i);
    else
        M_matrix(:,i) = ID_Matrix(:,i) - technical_coefficients_sectors_x_sectors(:,i);
    end
end


% VECTOR OF ENDOGENOUS VALUES
% Now we compute the vector of endogenous values, following formula 13.52 in Chapter 13.2.1 in Miller and Blair (2009).
% Note that when there is no production constraint operating (meaning that the vector of exogenous values contains only final demands), the below formula boils down to the x=L*f formula.
endogenous_values = M_matrix \ (N_matrix * exogenous_values); % this is analogous to (but faster in computing than): inv(M_matrix) * N_matrix * exogenous_values


% ALLOCATION OF ENDOGENOUS VALUES TO VECTORS
% The just computed endogenous values may be final demand values or total production values, depending on whether they belong to sectors whose production was exogenously set or not.
for i = 1 : nr_sectors
    if ismember(i, idx_exogenous_production)
        expected_final_demand_sectoral(i) = endogenous_values(i);
    else
        production_planned_sectoral(i) = endogenous_values(i);
    end
end


% PLANNED PRODUCTION ADJUSTED FOR INVENTORIES
production_planned_minus_inventories_sectoral = ...
    max(0, production_planned_sectoral - inventories_sectoral);


% SECTORAL CONSTRAINTS
% Production constraints at the sectoral level
sectoral_constraints = ...
    production_max_sectoral ./ production_planned_minus_inventories_sectoral;


% SECTIONAL CONSTRAINTS
% Production constraints at the sectional level
for i = 1 : nr_sections    
    if green_share_enforcement == "active" && i == idx_electricity_section
        % If the green share is being enforced to be equal to the target green share, the definition changes for the electricity Section.
        sectional_constraints(i) = sectoral_constraints(idx_brown);
    else
        idx_tmp = find(sectors_section_idx == i);
        sectional_constraints(i) = sum(production_max_sectoral(idx_tmp)) ./ sum(production_planned_minus_inventories_sectoral(idx_tmp));
    end
end


% ACTUAL GREEN SHARE
if green_share_enforcement == "active"
    % If the green share is being enforced to be equal to the target green share, the actual green share is equal to the assumed green share by default.
    green_share_actual = green_share_assumed;
else
    green_share_actual = ...
        min(1, ...
            (production_max_sectoral(idx_green) + inventories_sectoral(idx_green)) ...
            / (production_planned_sectoral(idx_green) + production_planned_sectoral(idx_brown)) ...
            );
end
if isempty(green_share_actual) == 1
    green_share_actual = NaN;
end


end