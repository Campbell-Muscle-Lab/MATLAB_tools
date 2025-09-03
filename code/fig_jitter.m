function fig_jitter(t, data_label, f1_label, options)
% Make a jitter figure

    arguments
        t (:,:) table
        data_label (1,1) string
        f1_label (1,1) string

        options.grouping_label (1,1) string = ""
        options.figure_handle (1,1) double = 0
        options.subplot_handle (1,1) double = 0
        
        options.f2_spacing = 1
    end

    jd(1).points{1} = [1, 2, 3, 4];
    jd(1).points{2} = [2.5, 3.5, 5];
 
    jd(2).points{1} = [3.5, 3.7, 5];
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
            % sp = initialise_publication_quality_figure( ...
            %     'no_of_panels_high', 1, ...
            %     'no_of_panels_wide', 1, ...
            %     'axes_padding_left', 1.25, ...
            %     'axes_padding_right', 0.3, ...
            %     'axes_padding_top', 1.5, ...
            %     'axes_padding_bottom', 1, ...
            %     'panel_label_font_size', 0);
        end
    end

    % Work out number of f1 and f2 categories
    no_of_f1_cats = 0;
    no_of_f2_cats = numel(jd);
    for f2 = 1 : no_of_f2_cats
        no_of_f1_cats = max([no_of_f1_cats numel(jd(f2).points)])
    end

    % Draw
    hold on;

    x = 1;
    for f2_i = 1 : no_of_f2_cats
        for f1_i = 1 : no_of_f1_cats
            try
                y = jd(f2_i).points{f1_i};
            catch
                x = x + 1
                continue;
            end
            plot(x, y, 'bo');
            x = x + 1;
        end
        if (f2_i < (no_of_f2_cats - 1))
            x = x + options.f2_spacing;
        end
    end







