function one_way_linear_mixed_model
% Demo for one-way linear mixed model

% Variables
data_file_string = 'data/one_way_data.xlsx';
data_label = 'y';
factor_1_label = 'Heart Failure Status';
grouping_label = 'person_id';

% Code

% Read in table
t = readtable(data_file_string);

% Run a one-way linear mixed model
stats = linear_mixed_model( ...
            t, data_label, factor_1_label, ...
            grouping_label = grouping_label)

stats.main_effects
