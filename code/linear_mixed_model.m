function stats = linear_mixed_model(t, data_label, f1_label, options);

    arguments
        t (:,:) table
        data_label (1,:) string
        f1_label (1,:) string
        options.f2_label (1,1) string = ""
        options.grouping_label (1,1) string = ""
        options.figure_handle (1,1) double = 0
        options.subplot_handle (1,1) double = 0
    end

    % Code

    % Start by defining the mode as "one_way", could be updated later
    model_mode = "one_way";

    % Try to fix variable names by removing sapces
    f1_label = strrep(f1_label, ' ', '');
    if (options.f2_label ~= "")
        options.f2_label = strrep(options.f2_label, ' ', '');
    end

    % Set the model_string
    model_string = data_label + " ~ 1 + " + f1_label;
    
    if (options.f2_label ~= "")
        model_mode = "two_way";
        model_string = model_string + " + " + options.f2_label + ...
            " + (" + f1_label +  " * " + options.f2_label + ")";
    end 

    if (options.grouping_label ~= "")
        model_string = model_string + " + (1 | " + options.grouping_label + ")";
    end

    % Get estimates of groups
    lin_mix_mod_ref = fitlme(t, model_string, ...
        FitMethod = "REML", ...
        CovariancePattern = "CompSym", ...
        DummyVarCoding = "Reference");

    % Run the model
    lin_mix_mod_effects = fitlme(t, model_string, ...
        FitMethod = "REML", ...
        CovariancePattern = "CompSym", ...
        DummyVarCoding = "Effects");

    % Set the main effects
    main_stats = anova(lin_mix_mod_effects, ...
        DFMethod = "satterthwaite");

    % Switch depending on mode
    switch model_mode

        case "one_way"
           
            % Work out the variable names for the post-hoc tests
            d_m = designMatrix(lin_mix_mod_ref);
            d_un = unique(d_m, 'rows');
            for i = 1 : size(d_un, 1)
                [~, ia, ib] = intersect(d_m, d_un(i,:), 'rows');
                d_vn(i) = t.(f1_label)(ia);
            end

            % Now get the combinations we need to test
            nck = nchoosek(1:size(d_un, 1), 2);

            % Run them
            for i = 1 : size(nck, 1)
                post_hoc.varname_1(i) = d_vn(nck(i,1));
                post_hoc.varname_2(i) = d_vn(nck(i,2));
                h = d_un(nck(i,1), :) - d_un(nck(i,2), :);

                [post_hoc.p_raw(i), post_hoc.F(i), ...
                    post_hoc.df1(i), post_hoc.df2(i)] = ...
                    coefTest(lin_mix_mod_ref, h, [0], ...
                        DFMethod = 'Satterthwaite');
            end

        case "two_way"
            % Work out the factor_1 and factor_2 names
            f1_values = unique(t.(f1_label));
            f2_values = unique(t.(options.f2_label));

             % Work out the variable names for the post-hoc tests
            d_m = designMatrix(lin_mix_mod_ref);
            d_un = unique(d_m, 'rows');
            for i = 1 : size(d_un, 1)
                [~, ia, ib] = intersect(d_m, d_un(i,:), 'rows');
                d_vn1(i) = t.(f1_label)(ia);
                d_vn2(i) = t.(options.f2_label)(ia);
            end

            % Find the design matrices for each combination;
            un_f1 = unique(d_vn1);
            un_f2 = unique(d_vn2);

            combos = [];
            counter = 1;
            for i = 1 : numel(un_f1)
                for j = 1 : numel(un_f2)
                    vi = find( (strcmp(d_vn1, un_f1{i})) & ...
                            (strcmp(d_vn2, un_f2{j})));
                    combos.var_names(counter) = string(sprintf('%s:%s', ...
                        d_vn1{vi}, d_vn2{vi}));
                    combos.matrix_entries(counter,:) = d_un(vi,:);
                    counter = counter + 1;
                end
            end

            % Build up the combinations
            comps = [];
            for i = 1 : numel(un_f1)
                % Find the combos that start with the chosen f1
                vi_f1 = find(startsWith(combos.var_names, un_f1(i)));
                if (numel(vi_f1) > 1)
                    comps = [comps ; nchoosek(vi_f1, 2)];
                end
            end
            for i = 1 : numel(un_f2)
                % Find the combos that end with the chose chosen f2
                vi_f2 = find(endsWith(combos.var_names, un_f2(i)));
                comps = [comps ; nchoosek(vi_f2, 2)];
            end

            % Now run the tests
            for i = 1 : size(comps, 1)
                post_hoc.varname_1(i) = combos.var_names(comps(i,1));
                post_hoc.varname_2(i) = combos.var_names(comps(i,2));

                h = combos.matrix_entries(comps(i,1), :) - ...
                        combos.matrix_entries(comps(i,2), :);

                [post_hoc.p_raw(i), post_hoc.F(i), ...
                    post_hoc.df1(i), post_hoc.df2(i)] = ...
                        coefTest(lin_mix_mod_ref, h, [0], ...
                            DFMethod = 'Satterthwaite');
            end
    end

    if (exist('post_hoc'))
        % Form the table
        post_hoc = struct2table(columnize_structure(post_hoc));
    
        % Perform Holm-Bonferroni correction
        % Sort table
        post_hoc = sortrows(post_hoc, 'p_raw');
    
        mult = size(post_hoc, 1);
        for i = 1 : size(post_hoc, 1)
            post_hoc.p_corrected(i) = mult * post_hoc.p_raw(i);
            mult = mult - 1;
        end

        % Sort by new order
        post_hoc = sortrows(post_hoc, 'p_corrected');
    end

    % Assemble output
    stats.main_effects = main_stats;
    stats.main_effects(1,:) = [];

    stats.post_hoc = post_hoc;
    stats.model_string = model_string;

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

        % Organize the data
        if (model_mode == "one_way")
            jd = extract_data_for_jitter_plot( ...
                    t, data_label, f1_label, ...
                    groupinging_label = grouping_label);

            main_labels = [];
            sub_labels = jd.f1_values;            
           
        else
            jd = extract_data_for_jitter_plot( ...
                t, data_label, f1_label, ...
                f2_label = f2_label, ...
                grouping_label = grouping_label);

            main_labels = jd.f1_values;
            sub_labels = jd.f2_values;            
        end

        % Try to do some clever scaling
        y_stats = summary_stats(od.(data_label));

        if (y_stats.min > (0.7 * y_stats.mean))
            y_from_zero = 0;
        else
            y_from_zero = 1;
        end

        jitter_plot( ...
            'data', jd, ...
            'group_names', main_labels, ...
            'sub_names', sub_labels, ...
            'y_main_label_offset', 0.3, ...
            'marker_size', 40, ...
            'marker_transparency', 0.5, ...
            'y_axis_label', data_label, ...
            'y_label_offset', -0.35, ...
            'y_from_zero', y_from_zero)
    end



