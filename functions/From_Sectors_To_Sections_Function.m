function [output_array_sectional] = From_Sectors_To_Sections_Function(aggregation_rule, input_array_sectoral, sectors_section_index)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMPORTANT NOTES

% The "input_array_sectoral" must be in vertical form, i.e. the sectoral data (to be collapsed to sectional data) must be along the vertical dimension.
% Along the horizontal dimension, it can be of dimension 1 or more (e.g. the number of households in case of sectoral sales to households)

% The "output_array_sectional" has a similar shape to "input_array_sectoral", i.e. it is in vertical form.
% The difference is that the former has the "nr_sections" as vertical dimension, while the latter has "nr_sectors" as vertical dimension.
% Their horizontal dimension is the same.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nr_sectors = numel(sectors_section_index);
nr_sections = numel(unique(sectors_section_index));

horizontal_length = size(input_array_sectoral, 2);

% Output array (vertical vector)
output_array_sectional = NaN * ones(nr_sections, horizontal_length);

for j = 1 : horizontal_length
    for i = 1 : nr_sections
        if aggregation_rule == "values of sectors belonging to the same section get averaged" % meaning that for example since both green and brown sectors have price equal to 1, so the value for the corresponding section (electricity) is 1.    
            output_array_sectional(i,j) = mean(input_array_sectoral(sectors_section_index == i, j));
    
        elseif aggregation_rule == "values of sectors belonging to the same section get summed" % meaning that for example green and brown sectoral values have to be summed, yielding the corresponding sectional value.
            output_array_sectional(i,j) = sum(input_array_sectoral(sectors_section_index == i, j));
        end
    end
end

end


% EXAMPLE

% aggregation_rule = "values of sectors belonging to the same section get averaged";
% %aggregation_rule = "values of sectors belonging to the same section get summed";
% input_array_sectoral = [10;11;12;13];
% sectors_section_index = [3 2 1 3];
