function fig_jitter(t, data_label, f1_label, options)
% Make a jitter figure

    arguments
        t (:,:) table
        data_label (1,1) string
        f1_label (1,1) string

        options.f2_label (1,1) string = ""
        options.grouping_label (1,1) string = ""
        options.figure_handle (1,1) double = 0
        options.subplot_handle (1,1) double = 0
        
        options.f2_spacing = 1
    end

    % Code

    % Make the figure if necessary
    if ((options.subplot_handle ~= 0) || ...
            (options.figure_handle ~= 0))

        if (options.subplot_handle ~= 0)
            subplot(options.subplot_handle);
            hold on;
        else
            figure(options.figure_handle);
            sp = layout_subplots()
         end
    end

    % Extract the data
    jd = table_to_jitter_format(t, data_label, f1_label, ...
            f2_label = options.f2_label, ...
            grouping_label = options.grouping_label);

    % Work out how many groups there are


    % Work out number of f1 and f2 categories
    no_of_f1_cats = 0;
    no_of_f2_cats = numel(jd);
    for f2 = 1 : no_of_f2_cats
        no_of_f1_cats = max([no_of_f1_cats numel(jd(f2).points)])
    end

    % Create a matrix for swarm plot
    x_anchor = 1;
    x = [];
    y = [];
    for f2_i = 1 : no_of_f2_cats
        for f1_i = 1 : no_of_f1_cats
            try
                y_temp = jd(f2_i).points{f1_i};
            catch
                x_anchor = x_ancho + 1
                continue;
            end
            x = [x ; x_anchor * ones(numel(y_temp), 1)];
            y = [y ; y_temp];

            x_anchor = x_anchor + 1;
        end
        if (f2_i < no_of_f2_cats)
            x_anchor = x_anchor + options.f2_spacing;
        end
    end

    % plot(2,3, 'bo')

    swarmchart(x, y)

    % hold on;
    % 
    % swarmchart(x, y+0.3)






