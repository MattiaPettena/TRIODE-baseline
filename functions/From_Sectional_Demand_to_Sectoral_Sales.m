function [sales_sectors_x_buyers] = ...
    From_Sectional_Demand_to_Sectoral_Sales... % name of the function
        (demand_sections_x_buyers, supply_sectoral, sectors_section_idx, idx_green, idx_brown)
%% Desciption of the function

% Input of the function: buyers' (investing sectors, or households, or the government) final demand for sectional products.
% Output of the function: sales by sectors to final demand buyers.

% The function takes into account the fact that a sector's available products may be less than final demand.
% If that's the case, the sector will ration its buyers by the same proportion:
    % If e.g. total demand of metals by households is 100 units (e.g. say two households, the first demanding 40 and the second demanding 60)..
    % .. but total available units of metals by the interested sector is 80 (i.e. 80% of demand)..
    % .. then the sector will sell 0.8*40 to the first household and 0.8*60 to the second household.

% The function also takes into account that there is grid priority for the green electricity sector over the brown electricity sector:
% this means that first the green sector sells its electricity to final demand; if that's not sufficient, the brown sector covers the rest.


%% Description of arrays

% "demand_sections_x_buyers" is a matrix of dimension sections x buyers, containing buyers' final demand for sectional products

% "supply_sectoral" is a vector showing the available products by each sector

% "sectors_section_idx" shows the sectional idx to which each sector belongs

% "sales_sectors_x_buyers" is a matrix of dimension sectors x buyers, containing sales by sectors to final demand buyers

%% New arrays

nr_sectors = numel(sectors_section_idx);
nr_buyers = size(demand_sections_x_buyers, 2);
sales_sectors_x_buyers = NaN * ones(nr_sectors, nr_buyers);
demand_sectoral = NaN * ones(nr_sectors, nr_buyers);
ratio_supply_vs_demand = NaN * ones(nr_sectors, 1);


%% Computations

ratio_green_supply_vs_electricity_demand = min(1, supply_sectoral(idx_green) / sum(demand_sections_x_buyers(sectors_section_idx(idx_green), :), 2));

for i = 1 : nr_sectors    
    if i == idx_green   % for the green sector
        demand_sectoral(i,:) = ratio_green_supply_vs_electricity_demand .* demand_sections_x_buyers(sectors_section_idx(i), :);
        ratio_supply_vs_demand(i) = min(1, supply_sectoral(i) / sum(demand_sectoral(i,:), 2));
    elseif i == idx_brown   % for the brown sector        
        demand_sectoral(i,:) = (1 - ratio_green_supply_vs_electricity_demand) .* demand_sections_x_buyers(sectors_section_idx(i), :);
        ratio_supply_vs_demand(i) = min(1, supply_sectoral(i) / sum(demand_sectoral(i,:), 2));
    else   % for all sectors except the green & brown        
        demand_sectoral(i,:) = demand_sections_x_buyers(sectors_section_idx(i), :);
        ratio_supply_vs_demand(i) = min(1, supply_sectoral(i) / sum(demand_sections_x_buyers(sectors_section_idx(i), :), 2));
    end
end

sales_sectors_x_buyers = ratio_supply_vs_demand .* demand_sectoral;


end


% EXAMPLES

% clear
% demand_sections_x_buyers = [50;100;100];
% supply_sectoral = [60;50;120;60];
% sectors_section_idx = [1 2 3 3];
% idx_green = 3;
% idx_brown = 4;

% clear
% demand_sections_x_buyers = [50 50;20 80;60 40];
% supply_sectoral = [120;70;60;20];
% sectors_section_idx = [1 2 3 3];
% idx_green = 3;
% idx_brown = 4;

% clear
% demand_sections_x_buyers = [0;0;0];
% supply_sectoral = [60;50;120;60];
% sectors_section_idx = [1 2 3 3];
% idx_green = 3;
% idx_brown = 4;

% demand_sections_x_buyers = Sections.demand_from_hhs_phys(:,:,t);
% supply_sectoral = sectors_products_available_for_hhs_phys;
% sectors_section_idx = Parameters.Sectors.section_idx;
% idx_green = Parameters.Sectors.idx_green;
% idx_brown = Parameters.Sectors.idx_brown;

