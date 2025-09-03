function subplots = layout_subplots(options);
% Function creates a reproducible panel layout

    arguments
        options.figure_handle (1,1) double = NaN
        options.panels_wide (1,1) double = 2
        options.panels_high (1,1) double = 2
        options.page_height (1,1) double = 11
        options.page_width (1,1) double = 8.5
        options.figure_width (1,1) double = 3.5
        options.top_margin (1,1) double = 0.0
        options.bottom_margin (1,1) double = 0.5
        options.left_margin (1,1) double = 0.5
        options.padding_top (1,:) double = 0.2
        options.padding_bottom (1,:) double = 0.5
        options.padding_left (1,:) double = 0.75
        options.padding_right (1,:) double = 0.25
        options.right_margin (1,1) double = NaN
        options.x_to_y_ratio (1,1) double = 1
        options.padding_left_adjustments (1,:) = 0
        options.padding_right_adjustments (1,:) = 0
        options.padding_top_adjustments (1,:) = 0
        options.padding_bottom_adjustments (1,:) = 0
        options.omit_subplots = NaN
        options.panel_label_font_size (1,1) double = 12
        options.panel_label_font_name (1,1) string = "Helvetica"
        options.panel_label_font_weight (1,1) string = "Bold"
    end

    % Set some defaults
    if (isnan(options.figure_handle))
        options.figure_handle = gcf;
    end

    % Work out some basics
    no_of_panels = options.panels_wide * options.panels_high;

    % Goal is to come up with arrays that are no_of_panels long for
    %   options.padding_top
    %   options.padding_top_adjustments
    %   options.padding_bottom
    %   options.padding_bottom_adjustments
    %   options.padding_left
    %   options.padding_left_adjustments
    %   options.padding_right
    %   options.padding_right_adjustments
    % If there is a single value, repeat it out for no_of_panels
    % For top and bottom adjustments, an input array implies values for
    % each row, expand out to handle columns
    % For left and right adjustments, an input array implies values for
    % each column, expand out to handle rows

    options.padding_top = expand_out_axes_properties( ...
        options.padding_top, options.panels_wide, options.panels_high, "col");
    options.padding_top_adjustments = expand_out_axes_properties( ...
        options.padding_top_adjustments, options.panels_wide, options.panels_high, "col");
    options.padding_bottom = expand_out_axes_properties( ...
        options.padding_bottom, options.panels_wide, options.panels_high, "col");
    options.padding_bottom_adjustments = expand_out_axes_properties( ...
        options.padding_bottom_adjustments, options.panels_wide, options.panels_high, "col");
    options.padding_left = expand_out_axes_properties( ...
        options.padding_left, options.panels_wide, options.panels_high, "row");
    options.padding_left_adjustments = expand_out_axes_properties( ...
        options.padding_left_adjustments, options.panels_wide, options.panels_high, "row");
    options.padding_right = expand_out_axes_properties( ...
        options.padding_right, options.panels_wide, options.panels_high, "row");
    options.padding_right_adjustments = expand_out_axes_properties( ...
        options.padding_right_adjustments, options.panels_wide, options.panels_high, "row");


    % Set a subplot counter and a top_anchor
    subplot_counter = 1;

    % Loop through the rows
    for row = 1 : options.panels_high

        row_indices = ((row - 1) * options.panels_wide) + ...
                            (1 : options.panels_wide);

        % Set the axis width
        if (row == 1)
            axis_width = (options.figure_width - ...
                            sum(options.padding_left(row_indices)) - ...
                            sum(options.padding_left_adjustments(row_indices)) - ...
                            sum(options.padding_right(row_indices)) + ...
                            sum(options.padding_right_adjustments(row_indices))) / ...
                        options.panels_wide;

            axis_height = axis_width / options.x_to_y_ratio;

            % Calculate the figure_height off the first col
            first_col_indices = 1:options.panels_wide:no_of_panels;
            
            options.figure_height = (options.panels_high * axis_height) + ...
                sum(options.padding_top(first_col_indices)) + ...
                sum(options.padding_top_adjustments(first_col_indices)) + ...
                sum(options.padding_bottom(first_col_indices)) - ...
                sum(options.padding_bottom_adjustments(first_col_indices));

            % Now we know the dimensions, we can make the figure
            options.figure_handle = figure(options.figure_handle);
            clf;
            set(options.figure_handle, 'Units', 'inches', 'PaperType', 'usletter');
            set(options.figure_handle, 'Position', ...
                [options.left_margin ...
                    options.page_height-options.bottom_margin - options.figure_height ...
                    options.figure_width ...
                    options.figure_height]);
        end

        % And the columns
        for col = 1 : options.panels_wide
            
            % Check for omit panel
            if (any(options.omit_subplots == subplot_counter))
                continue;
            end

            lhs(subplot_counter) = ((col-1)*(axis_width)) + ...
                sum(options.padding_left(row_indices(1 : col))) + ...
                sum(options.padding_right(row_indices(1 : (col-1)))) + ...
                options.padding_left_adjustments(row_indices(col));

            rhs(subplot_counter) = lhs(subplot_counter) + axis_width + ...
                options.padding_right_adjustments(row_indices(col));

            top(subplot_counter) = options.figure_height - ...
                sum(options.padding_top(first_col_indices(1:row))) - ...
                sum(options.padding_bottom(first_col_indices(1:(row-1)))) - ...
                ((row-1) * axis_height);

            bottom(subplot_counter) = top(subplot_counter) - ...
                axis_height;

            l = lhs(subplot_counter) / options.figure_width;
            b = bottom(subplot_counter) / options.figure_height;
            w = (rhs(subplot_counter) - lhs(subplot_counter)) / options.figure_width;
            h = (top(subplot_counter) - bottom(subplot_counter)) / options.figure_height;

            subplots(subplot_counter) = subplot('Position', [l b w h]);

            % Increment counter
            subplot_counter = subplot_counter + 1;

        end
    end

    % Restore defaults
    set(options.figure_handle,'PaperUnits','inches')

end

function z = expand_out_axes_properties(z, panels_wide, panels_high, mode)
% Fills out z so that its length is equal to the number of panels

    % Code
    no_of_panels = panels_wide * panels_high;

    if (mode == "row")
        switch numel(z)
            case 1
                z = repmat(z, [1 no_of_panels]);
            case (panels_wide)
                z = repmat(z, [1 panels_high]);
        end
    else
        switch numel(z)
            case 1
                z = repmat(z, [1 no_of_panels]);
            case (panels_wide)
                z = repmat(z, [1 panels_wide]);
        end
    end

end




    % Calculate some values
    % options.right_margin = options.page_width - options.left_margin - ...
    %     options.figu

    % subplots = 1;

% 
% 
% 
% % Default values
% params.figure_handle=gcf;
% params.left_margin=0.5;             % 0.5 inch margin
% params.right_margin=4.6;            % One column (3.5 inch) wide
% params.top_margin=0.0;              % 0.5 inch margin
% params.bottom_margin=0.5;
% params.no_of_panels_wide=2;
% params.no_of_panels_high=2;
% params.axes_padding_left=0.75;  	% 0.75 inch left padding for labels
% params.axes_padding_right=0.25;     % 0.25 inch right padding
% params.axes_padding_top=0.25;		% 0.25 inch top padding
% params.x_to_y_axes_ratio=1.0;       % ratio of x to y axes lengths
% params.panel_label_font_size=14;    % font size label
% params.font_name='Helvetica';
% params.starting_letter=0;
% params.individual_panel_labels='';
% params.axes_padding_bottom=0.75;
% params.relative_row_heights=[];
% params.right_dead_space=0;
% params.individual_padding=0;
% params.left_pads=[];
% params.right_pads=[];
% 
% params.left_subplot_adjustments=[];
% params.right_subplot_adjustments=[];
% params.bottom_subplot_adjustments=[];
% params.height_subplot_adjustments=[];
% 
% params.panel_label_x_offset=[];
% params.panel_label_y_offset=[];
% 
% params.individual_panels_wide=0;
% params.omit_panels=[];
% 
% 
% % Check for overrides
% params=parse_pv_pairs(params,varargin);
% 
% % Updates
% if (length(params.axes_padding_bottom)==1)
%     params.axes_padding_bottom=params.axes_padding_bottom * ...
%         ones(params.no_of_panels_high,1);
% end
% 
% if (isempty(params.relative_row_heights))
%     params.relative_row_heights=ones(params.no_of_panels_high,1);
% end
% 
% if (params.individual_panels_wide == 0)
%     params.individual_panels_wide = params.no_of_panels_wide * ...
%                                         ones(1, params.no_of_panels_high);
% end
% 
% % Error checking
% if (length(params.axes_padding_bottom)~=params.no_of_panels_high)
%     disp('Axes padding problem');
% end
% 
% % Do some preparatory calculations
% for row_counter=1:params.no_of_panels_high
% 
%     across(row_counter)=params.no_of_panels_wide;
%     if (params.individual_panels_wide(1)>0)
%         across(row_counter)=params.individual_panels_wide(row_counter);
%     end
% 
%     if (~params.individual_padding)
%         axes_width_inches(row_counter)= ...
%             (8.5-(params.left_margin+params.right_margin+ ...
%                 params.right_dead_space)- ...
%             (params.no_of_panels_wide*(params.axes_padding_left+ ...
%                 					params.axes_padding_right)))/ ...
%             across(row_counter);
%     else
%         % Calculate the row indices
%         if (row_counter==1)
%             row_indices=1:across;
%         else
%             row_indices= ...
%                 sum(params.individual_panels_wide(1:(row_counter-1))) + ...
%                 (1:across(row_counter));
%         end
% 
%         %  Override if horizontal paddings is individually specified
%         axes_width_inches(row_counter) = (8.5 -  ...
%             (params.left_margin+params.right_margin) - ...
%             sum(params.left_pads(row_indices)) - ...
%             sum(params.right_pads(row_indices))) / ...
%                 across(row_counter);
%     end
% end
% 
% 
% base_axes_height_inches=axes_width_inches(1)/params.x_to_y_axes_ratio;
% 
% % Figure width and height in inches
% figure_width=8.5-(params.left_margin+params.right_margin);
% 
% if (length(params.axes_padding_top)==1)
% 
%     figure_height= params.top_margin + ...
%         (params.no_of_panels_high * params.axes_padding_top) + ...
%             sum(params.axes_padding_bottom(1:params.no_of_panels_high)) + ...
%             ((sum(params.relative_row_heights(1:params.no_of_panels_high))) ...
%                 *base_axes_height_inches+ ...
%         params.bottom_margin);
% else
%     figure_height = params.top_margin + ...
%         (sum(params.axes_padding_top(1:params.no_of_panels_high))) + ...
%             sum(params.axes_padding_bottom(1:params.no_of_panels_high)) + ...
%             ((sum(params.relative_row_heights(1:params.no_of_panels_high))) ...
%                 *base_axes_height_inches+ ...
%         params.bottom_margin);
% end
% 
% ptm=params.top_margin;
% pnph=params.no_of_panels_high;
% paxpt=params.axes_padding_top;
% papb=params.axes_padding_bottom;
% prrh=params.relative_row_heights;
% pbm=params.bottom_margin;
% 
% if (length(params.left_subplot_adjustments)==0)
%     lhs_adjustments=zeros( ...
%         params.no_of_panels_wide*params.no_of_panels_high,1);
% else
%     lhs_adjustments=params.left_subplot_adjustments;
% end
% 
% if (length(params.right_subplot_adjustments)==0)
%     rhs_adjustments=zeros( ...
%         params.no_of_panels_wide*params.no_of_panels_high,1);
% else
%     rhs_adjustments=params.right_subplot_adjustments;
% end
% 
% 
% if (length(params.bottom_subplot_adjustments)==0)
%     bot_adjustments=zeros( ...
%         params.no_of_panels_wide*params.no_of_panels_high,1);
% else
%     bot_adjustments=params.bottom_subplot_adjustments;
% end
% 
% if (length(params.height_subplot_adjustments)==0)
%     height_adjustments=zeros( ...
%         params.no_of_panels_wide*params.no_of_panels_high,1);
% else
%     height_adjustments=params.height_subplot_adjustments;
% end
% 
% % Clear figure
% figure(params.figure_handle);
% clf;
% set(params.figure_handle,'Units','inches','PaperType','usletter');
% set(params.figure_handle,'Position', ...
%     [params.left_margin 9-figure_height figure_width figure_height]);
% 
% % Loop through sub-plots
% 
% subplots=[];
% subplot_counter=0;
% 
% for row_counter=1:params.no_of_panels_high
% 
%     % Calculate the row indices
%     if (row_counter==1)
%         row_indices=1:across;
%     else
%         if (params.individual_panels_wide(1)>0)
%             row_indices= ...
%                 sum(params.individual_panels_wide(1:(row_counter-1))) + ...
%                 (1:across(row_counter));
%         else
%             row_indices=(row_counter-1)*params.no_of_panels_wide + ...
%                 (1:params.no_of_panels_wide);
%         end
%     end
% 
%     if (~params.individual_panels_wide(1))
%         holder=params.no_of_panels_wide;
%     else
%          holder=params.individual_panels_wide(row_counter);
%     end
% 
%     for column_counter=1:holder
% 
%         subplot_counter=subplot_counter+1;
% 
%         % Check for omit panels
%         if (any(params.omit_panels==subplot_counter))
%             continue;
%         end
% 
%         % Set lhs normalized to figure width
%         if (~params.individual_padding)
%             lhs=((column_counter-1)* ...
%                 (params.axes_padding_left+axes_width_inches(row_counter)+ ...
%                         params.axes_padding_right) + ...
%                 params.axes_padding_left)/figure_width;
%         else
%             lhs = (((column_counter-1)*axes_width_inches(row_counter) ) + ...
%                 sum(params.left_pads(row_indices(1:column_counter))) + ...
%                 sum(params.right_pads(row_indices(1:column_counter-1)))) / figure_width;
%         end
% 
%         if (length(params.axes_padding_top)==1)
%             bottom=(figure_height - params.top_margin - ...
%                         (row_counter*params.axes_padding_top) -...
%                         (sum(params.relative_row_heights(1:row_counter))* ...
%                             base_axes_height_inches) - ...
%                         bot_adjustments(subplot_counter) - ...
%                         sum(params.axes_padding_bottom(1:row_counter-1)))/ ...
%                     figure_height;
%         else
%             bottom=(figure_height - params.top_margin - ...
%                         (sum(params.axes_padding_top(1:row_counter))) -...
%                         (sum(params.relative_row_heights(1:row_counter))* ...
%                             base_axes_height_inches - ...
%                             bot_adjustments(subplot_counter)) - ...
%                         sum(params.axes_padding_bottom(1:row_counter-1)))/ ...
%                     figure_height;
%         end
% 
%         subplots(subplot_counter)=subplot('Position', ...
%             [lhs+(lhs_adjustments(subplot_counter)/figure_width) bottom ...
%             (axes_width_inches(row_counter)- ...
%                 lhs_adjustments(subplot_counter)- ...
%                 rhs_adjustments(subplot_counter))/figure_width ...
%                 (params.relative_row_heights(row_counter)* ...
%                     base_axes_height_inches + ...
%                     bot_adjustments(subplot_counter) + ...
%                     height_adjustments(subplot_counter))/figure_height]);
% 
%         % Draw Label
%         if (params.panel_label_font_size>0)
% 
%             if (0)
%             % Create the subplot and set up the coordinates for the label
%             subplot(subplots(subplot_counter));
% 
%             x_pos=-params.axes_padding_left;
%             y_pos=params.axes_padding_top + ...
%                 params.relative_row_heights(row_counter)* ...
%                     base_axes_height_inches;
%             if (row_counter==1)
%                 y_pos=y_pos+params.top_margin;
%             end
%             text(x_pos,y_pos, ...
%                 char(subplot_counter+64+params.starting_letter), ...
%                 'FontSize',params.panel_label_font_size, ...
%                 'FontWeight','bold', ...
%                 'Units','inches', ...
%                 'HorizontalAlignment','left', ...
%                 'VerticalAlignment','top', ...
%                 'FontName',params.font_name ...
%                 );
% 
%             text('Units','data');
%             else
%                 % Move to the subplot
%                 h=subplot(subplots(subplot_counter));
%                 set(h,'Units','inches');
%                 pos_vector=get(h,'Position');
%                 lhs=pos_vector(1);
%                 top=pos_vector(2)+pos_vector(4);
% 
%                 % Find the positions for the labels
%                 if (~params.individual_padding)
%                     x_pos=-params.axes_padding_left;
%                 else
%                     x_pos=-params.left_pads( ...
%                         row_indices(column_counter));
%                 end
%                 x_pos=x_pos-lhs_adjustments(subplot_counter);
% 
%                 if (~isempty(params.panel_label_x_offset))
%                     x_pos = x_pos + params.panel_label_x_offset(subplot_counter);
%                 end
% 
%                 if (length(params.axes_padding_top)==1)
%                     y_pos=params.axes_padding_top + ...
%                         params.relative_row_heights(row_counter)* ...
%                             base_axes_height_inches;
%                 else
%                     y_pos=params.axes_padding_top(row_counter) + ...
%                         params.relative_row_heights(row_counter)* ...
%                             base_axes_height_inches;
%                 end
%                 if (row_counter==1)
%                     y_pos=y_pos+params.top_margin;
%                 end
%                 y_pos=y_pos+bot_adjustments(subplot_counter)+ ...
%                     height_adjustments(subplot_counter);
% 
%                 if (~isempty(params.panel_label_y_offset))
%                     y_pos = y_pos + params.panel_label_y_offset(subplot_counter);
%                 end
% 
% 
%                 if (length(params.individual_panel_labels)>0)
%                     text_string=params.individual_panel_labels{ ...
%                         subplot_counter};
%                 else
%                     text_string=sprintf('%c', ...
%                         subplot_counter+64+params.starting_letter);
%                 end
% 
%                 % Slight x offset added to prevent labels being cropped
%                 text(x_pos+0.01,y_pos,text_string, ...
%                     'Units','inches', ...
%                     'FontSize',params.panel_label_font_size, ...
%                     'FontWeight','bold', ...
%                     'Units','inches', ...
%                     'HorizontalAlignment','left', ...
%                     'VerticalAlignment','top', ...
%                     'FontName',params.font_name ...
%                     );
%                 text('Units','data');
%             end
%         end
% 
%         hold on;
%         drawnow;
%     end
% end
% 
% % Restore defaults
% set(gcf,'PaperUnits','inches')
% 
% 
