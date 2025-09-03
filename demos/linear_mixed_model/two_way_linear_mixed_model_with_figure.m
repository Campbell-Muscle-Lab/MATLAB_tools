function two_way_linear_mixed_model
% Demo for one-way linear mixed model

% Variables
data_file_string = 'data/two_way_data.xlsx';
data_label = 'pCa50';
f1_label = 'Heart Failure Status';
f2_label = 'Region';
grouping_label = 'hashcode';

% Code

% Read in table
t = readtable(data_file_string);

% Run a one-way linear mixed model
% stats = linear_mixed_model( ...
%             t, data_label, f1_label, ...
%             f2_label = f2_label, ...
%             grouping_label = grouping_label, ...
%             figure_handle = 1)
% 
% stats.main_effects

fig_jitter(t, data_label, f1_label, grouping_label=grouping_label)
