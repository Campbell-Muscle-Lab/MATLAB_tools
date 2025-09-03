function [od,jd] = extract_one_way_data(varargin)

% Parse inputs
p = inputParser;
addOptional(p,'data_table', []);
addOptional(p,'excel_file_string','');
addOptional(p,'excel_sheet','Sheet1');
addOptional(p,'parameter_string','');
addOptional(p,'factor_1','');
addOptional(p,'factor_1_strings','');
addOptional(p,'conditions',[]);
addOptional(p,'grouping_string','');
addOptional(p,'convert_grouping_numbers_to_strings',0);
addOptional(p,'exclude_NaNs',1);

parse(p,varargin{:});

% Code

% Read input data
if (isempty(p.Results.data_table))
    d = read_structure_from_excel( ...
            'filename',p.Results.excel_file_string, ...
            'sheet',p.Results.excel_sheet);
else
    d = p.Results.data_table;
end
    
% Reformat grouping numbers as strings if required
if (p.Results.convert_grouping_numbers_to_strings)
    if (iscell(d.(p.Results.grouping_string)))
        for i = 1 : numel(d.(p.Results.grouping_string))
            d.(p.Results.grouping_string){i} = ...
                num2str(d.(p.Results.grouping_string){i});
        end
    end
end

% Deduce factor_1_strings
if (isempty(p.Results.factor_1_strings))
    factor_1_strings = unique(d.(p.Results.factor_1));
else
    factor_1_strings = p.Results.factor_1_strings;
end
       
% Check for numerics
if (isnumeric(factor_1_strings))
    factor_1_strings = cellstr(num2str(factor_1_strings));
end
if (isnumeric(d.(p.Results.factor_1)))
    d.(p.Results.factor_1) = cellstr(num2str(d.(p.Results.factor_1)));
end

% Now organize the data
counter = 0;
for i=1:numel(factor_1_strings)
    vi = find( ...
            strcmp(d.(p.Results.factor_1),factor_1_strings{i}));

    if (~isempty(p.Results.conditions))
        vi = intersect(vi, ...
            find(strcmp(d.(p.Results.conditions{1}), ...
                p.Results.conditions{2})));
    end
    
    % Exclude NaNs if required
    if (p.Results.exclude_NaNs)
        y_temp = d.(p.Results.parameter_string)(vi);
        vi = vi(find(~isnan(y_temp)));
    end
    
    % Check for numerics
    if (~isempty(p.Results.grouping_string))
        if (isnumeric(d.(p.Results.grouping_string)))
            d.(p.Results.grouping_string) = cellstr(num2str(d.(p.Results.grouping_string)));
        end
    end
    
    for k=1:numel(vi)
        counter=counter+1;
        od.(p.Results.factor_1){counter}=factor_1_strings{i};
        if (~isempty(p.Results.grouping_string))
            od.(p.Results.grouping_string){counter} = ...
                d.(p.Results.grouping_string){vi(k)};
        end
        if (~isempty(p.Results.conditions))
            od.(p.Results.conditions{1}){counter} = ...
                d.(p.Results.conditions{1}){vi(k)};
        end
        od.(p.Results.parameter_string)(counter) = ...
            d.(p.Results.parameter_string)(vi(k));
    end
    if (numel(vi)>0)
        jd.points{i} = d.(p.Results.parameter_string)(vi);
    end
end

jd.f1_strings = factor_1_strings;
