function jitter_data = table_to_jitter_format( ...
    t, data_label, f1_label, options)

    arguments
        t (:,:) table
        data_label (1,1) string
        f1_label (1,1) string
        options.f2_label (1,1) string = ""
        options.f1_values (1,:) string = ""
        options.f2_values (1,:) string = ""
        options.grouping_label (1,1) string
    end

    % Code

    % Initialise output structure
    jitter_data = [];

    % Do some conversions
    % Useful for == operator later
    if (iscell(t.(f1_label)(1)))
        t.(f1_label) = string(t.(f1_label));
    end
    if (iscell(t.(options.f2_label)(1)))
        t.(options.f2_label) = string(t.(options.f2_label));
    end
    if ((~isempty(options.grouping_label)) && ...
            (iscell(t.(options.grouping_label)(1))))
        t.(options.grouping_label) = string(t.(options.grouping_label));
    end

    % Work out the unique values
    if (~isempty(options.f1_values))
        options.f1_values = unique(t.(f1_label));
        jitter_data.f1_values = options.f1_values;
    end

    if (~isempty(options.f2_label))
        if (~isempty(options.f2_values))
            options.f2_values = unique(t.(options.f2_label));
            jitter_data.f2_values = options.f2_values;
        end
    else
        options.f2_values = [];
    end

    % Loop through combinations
    for f1_i = 1 : numel(options.f1_values)

        if (isempty(options.f2_values))
            % One factor only
            vi = find(t.(f1_label) == options.f1_values(i));
            jitter_data(1).points{f1_i} = t.(data_label)(vi);
            if (~isempty(options.grouping_label))
                jitter_data(1).groups{f1_i} = t.(options.grouping_label)(vi);
            end
        else
            % Two factors
            for f2_i = 1 : numel(options.f2_values)
                vi = find((t.(f1_label) == options.f1_values(f1_i)) & ...
                        (t.(options.f2_label) == options.f2_values(f2_i)));
                jitter_data(f2_i).points{f1_i} = t.(data_label)(vi);
                if (~isempty(options.grouping_label))
                    jitter_data(f2_i).groups{f1_i} = t.(options.grouping_label)(vi);
                end
            end
        end
    end








