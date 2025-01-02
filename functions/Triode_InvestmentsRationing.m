function [sectors_adj_investment_orders] = ...
    Triode_InvestmentsRationing...
    (investment_rationing_rule, sectors_desired_investments, sectors_capital_stock_previous_period, ...
    sectors_depreciation_rates, sectors_capital_productivities, sections_available_products, ...
    sections_idx_capital_assets, capital_assets_logical_matrix)
%% Description of the function

% This function addresses the following issue related to investments rationing:
% How do sectors purchase goods related to their investments, when there are constraints on the availability of such goods?

% Indeed, imagine that the Services industry wants to increase its capital stocks by investing in 2 units of computers and 4 units of construction.
% However, suppose the computers sector can only supply 50% of such demand, while there is full availability of constructions. 
% We allow for 2 different rules:
    % 1. "SIMPLE"
            % Sectors simply acquire the available investment goods without rescaling their demand for the other complementary investment goods.
            % In the above example, the Services industry would simply buy 1 unit of computers and 4 units of construction, even if that leads to excess capacity of the capital stock of constructions.
    % 2. "RESCALED"
            % Any sector reacts to the rationing by rescaling its demands of all investment goods so as to ensure ..
            % ..that the resulting new capital stocks levels are all equal in terms of maximum production capacity, ..
            % ..thereby avoiding excess capacity in any capital asset.
            % So, given the availability of investment goods, a sector looks at which of its future potential capital assets stocks ..
            % ..would deliver the lowest production capacity: then it takes that production capacity value and uses it ..
            % ..to rescale all its other investment demands, to ensure that all resulting capital assets stocks deliver the same production capacity.
            % Note that it may be the case at the end of the rescaling process that not all investment goods are being sold, ..
            % ..not even those that were causing the constraints in the first place.            

% See the Excel file "Investments Rationing new version" to have an intuitive understanding of the issue.


%% Description of the arrays


%%%%%%  INPUTS OF THE FUNCTION  %%%%%%

% "investment_rationing_rule"
    % defines whether we are using the "simple" or the "rescaled" rule explained previously.

% "sectors_desired_investments"
    % is a rectangular matrix whose cell (i,j) reports demand by Sector j of capital goods supplied by Section i.

% "sectors_capital_stock_previous_period"
    % is a rectangular matrix whose cell (i,j) reports Sector j's stock of capital goods produced by Section i.

% "sections_available_products"
    % is a vertical vector whose cell (i) reports the total amount of products that can be sold by Section i.

% "sections_idx_capital_assets"
    % index of the sections that produce goods used (by any sector) as capital assets.

% "capital_assets_logical_matrix"
    % logical rectangular matrix whose cell (i,j) contains 1 if Sector j..
    % ..uses goods supplied by Section i as capital assets and 0 otherwise.



%%%%%%  OUTPUTS OF THE FUNCTION  %%%%%%

% "sectors_adj_investment_orders"
    % is a rectangular matrix whose cell (i,j) reports adjusted orders (and therefore also realized purchases)..
    % ..by Sector j of capital goods supplied by Section i.


%% The function

% NR OF SECTIONS AND NR OF SECTORS
[nr_sections, nr_sectors] = size(sectors_desired_investments);

% TOTAL INVESTMENT DEMAND FOR SECTIONAL PRODUCTS
investment_demands_total = sum(sectors_desired_investments, 2);

% CONSTRAINTS IN THE AVAILABILITY OF INVESTMENT GOODS
% values < 1 denote a constraint
constraints = ones(nr_sections, 1);
constraints(sections_idx_capital_assets) = ...
    sections_available_products(sections_idx_capital_assets) ./ investment_demands_total(sections_idx_capital_assets);

% POSSIBLE INVESTMENTS
% Investments that could actually occur, taking into account the availability of products.
% Sectors are not yet rescaling their demand for the other complementary investment goods.
sectors_possible_investments = min(sectors_desired_investments, sectors_desired_investments .* constraints);


if investment_rationing_rule == "simple"

    % ADJUSTED INVESTMENT ORDERS/PURHASES
    sectors_adj_investment_orders = sectors_possible_investments;    

elseif investment_rationing_rule == "rescaled"
                
    % MAX PRODUCTION POTENTIAL OF EACH CAPITAL ASSET IN EACH SECTOR    
    potential_implied_max_production = sectors_capital_productivities .* ((1 - sectors_depreciation_rates) .* sectors_capital_stock_previous_period + sectors_possible_investments);
    
    % BINDING PRODUCTION POTENTIAL IN EACH SECTOR
    binding_value_of_max_production = NaN * ones(1, nr_sectors);
    for i = 1 : nr_sectors
        binding_value_of_max_production(i) = min(potential_implied_max_production(capital_assets_logical_matrix(:,i), i));
    end
    
    % ADJUSTED INVESTMENT ORDERS/PURHASES (I_(t))
    % K_(t+1) = (1 - depreciation) * K_(t) + I_(t)
    % Q_(max) = productivity * K_(t+1)  --> K_(t+1) = Q_(max) / productivity
    % .. which implies that:
    % I_(t) = Q_(max) / productivity  -  (1 - depreciation) * K_(t)
    % Note that some I_(t) values could even become negative, which we don't want: therefore we set a floor to zero.
    sectors_adj_investment_orders = zeros(nr_sections, nr_sectors);
    for i = 1 : nr_sectors
        sectors_adj_investment_orders(capital_assets_logical_matrix(:,i), i) = ...
            max(0, ...
            binding_value_of_max_production(i) ./ sectors_capital_productivities(capital_assets_logical_matrix(:,i), i) ...
            - (1 - sectors_depreciation_rates(capital_assets_logical_matrix(:,i), i)) .* sectors_capital_stock_previous_period(capital_assets_logical_matrix(:,i), i) ...
            );
    end
    
end


end
