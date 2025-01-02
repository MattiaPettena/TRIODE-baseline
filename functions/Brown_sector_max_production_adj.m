function [max_production_brown_sector] = Brown_sector_max_production_adj(max_production_original, target_weights)
%% DESCRIPTION

% See also description in the Simulation file.

% We want the Brown Sector's Divisions to be producing according to the target weights.
% Weights given by the Divisions' max production capacities may differ substantially from the target weights.
% The objective of this function is to find the Brown Sector's max production level that is consistent with the Divisions' target weights.

% EXAMPLE:
% Imagine we have 2 Divisions, A and B, within the Brown Sector.
% Max production capacity of A = 60
% Max production capacity of B = 50
% Max production capacity of the Brown Sector = 60+50 = 110
% Target weight of A = 60%
% Target weight of B = 40%
% Actual weight of A = 60/110 = 55%
% Actual weight of B = 50/110 = 45%
% Brown Sector's max production level (Z) that is consistent with the Divisions' target weights:
    % 60% Z = 60 --> Z = 100
% Adjusted max production levels:
    % A = 60
    % B = 40


% The function works as follows:
    % Compute the Divisions' actual weight, i.g. the weight given by the Divisions' max production capacities.
    % Compute the difference between target and actual weights.
    % Select the Division Y for which the difference is largest (i.e. the most constrained Division)..
    % ..and compute the Brown Sector's adjusted max production level that is consistent with that Division's target weight:
            % (Target weight of Division Y) = (Division's Y max production) / (Brown Sector's adjusted max production level)
    % Compute the adjusted max production level of each Division, consistent with the target weights and the Brown Sector's adjusted max production level.
    % Compute the "actual" weights resulting from the adjusted max production level of each Division.
    % If these "actual" weights are equal to the target weights, the function stops and simply returns the output, i.e. the max production of the Brown Sector.
    % If these "actual" weights are not all equal to the target weights, we select the 2nd most constrained Division and repeat the whole process.
    % It may be the case that the "while loop" isn't actually necessary, i.e. that the actual weights will always be equal to the target ones after the first trial.
    % But I wasn't sure about this and preferred to introduce the possibility for a second trial through the "while loop".
    

% LEGENDA
% D = nr of brown divisions, e.g. usually 3 (gas, coal, oil)

% INPUTS OF THE FUNCTION
% max_production_original = Dx1 vector = max production capacity of the brown divisions
% target_weights = 1xD vector = target weights of the brown divisions

% OUTPUT OF THE FUNCTION
% max_production_brown_sector = 1X1 array = max production of the brown sector


%% COMPUTATIONS

% Let's transpose the vector for usefulness
max_production_original = max_production_original'; 

% Actual weight, i.g. the weight given by the Divisions' max production capacities.
actual_weight = max_production_original ./ sum(max_production_original);

% Difference between target and actual weights
difference = target_weights - actual_weight;
% Sort in descending order
difference_descending_order = sort(difference, 'descend');

% Brown Sector's max production level if all Divisions were producing at their maximum capacity.
% We need to define this already here and not only in the while loop, because if the while loop does not run..
% ..(e.g. because actual weights are equal to target weights), then the function would not yield any output.
max_production_sectoral = sum(max_production_original, 2);

% Counter
counter = 0;

% The loop runs until actual and target weights are not equal
while any(abs(actual_weight - target_weights) > 1e-12)

    counter = counter + 1;

    % Index of the most constrained Division
    idx_most_constrained_division = find(difference == difference_descending_order(counter));

    % Brown Sector's adjusted max production level that is consistent with that Division's target weight
        % (Brown Sector's adjusted max production level) = (Division's Y max production) / (Target weight of Division Y)
    max_production_sectoral = max_production_original(idx_most_constrained_division) ./ target_weights(idx_most_constrained_division);

    % Adjusted max production level of each Division    
    max_production_adjusted = min(target_weights .* max_production_sectoral, max_production_original);

    % Actual weight
    actual_weight = max_production_adjusted ./ sum(max_production_adjusted);

end

% OUTPUT OF THE FUNCTION
% Max production of the brown sector
max_production_brown_sector = max_production_sectoral;

end


% EXAMPLE FROM THE MODEL
% max_production_original = Divisions.production_max_given_constraints_phys(Parameters.Divisions.idx_brown, t);
% target_weights = Parameters.Divisions.target_sectoral_weights(t, Parameters.Divisions.idx_brown);
