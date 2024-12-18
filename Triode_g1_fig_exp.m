%function Triode_g1_fig_exp(Rules, Parameters, Data, simulations_names)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%       BAR PLOTS      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Generic settings

    % COLORS FOR EACH SIMULATION
    % Random colors
    %my_colors_policy_exp = lines(nr_simulations);   
    % Green and brown colors
    my_colors_policy_exp = ...
        [0.6706, 0.4078, 0.3412; % brown
        0, 0.5, 0; % first green        
        0.4660, 0.6740, 0.1880; % second green
        0.3010 0.7450 0.9330]; % blue
    

    % Font sizes
    my_gca_fontsize = 10.6; %15;
    my_legend_fontsize = 13; %16;
    my_percentage_change_fontsize = 10.6; %12;
    
    % metrics (log or linear)
    y_scale_metrics_bar_plots = 'linear';
    %y_scale_metrics_bar_plots = 'log';
    
    
    % Create array with industries' names..
    % .. because we want some names to be split into two or more lines
    X = categorical({sprintf('Agric.'), ...
        sprintf('Metals\\newline mining'), ...
        sprintf('Metals\\newline process.'), ...
        sprintf('Fuels\\newline extr.'), ...
        sprintf('Fuels\\newline process.'), ...
        sprintf('Chemic.'), ...
        sprintf('ICT\\newline equipm.'), ...
        sprintf('Transp.\\newline equipm.'), ...
        sprintf('Other\\newline machin.'), ...
        sprintf('Constr.'), ...
        sprintf('Other\\newline manuf.'), ...
        sprintf('PSTA'), ...
        sprintf('Softw.\\newline datab.'), ...
        sprintf('Transport\\newline services'), ...
        sprintf('Other\\newline services'), ...
        sprintf('Public\\newline services'), ...
        sprintf('Electr.\\newline transm.'), ...
        sprintf('Green\\newline electr.'), ...
        sprintf('Brown\\newline electr.')});
    % Categorical arrays sort elements according to alphabetical order, but we want to preserve the original order.
    % This is done by imposing the order string(X)
    X = reordercats(X, string(X));
    % TEST
    if numel(X) ~= Parameters.Sectors.nr
        error('When defining X there is an error as the number of items in X does not equal the number of Sectors.')
    end


    % Create an array with the Sections' names..
    % .. because we want some names to be split into two or more lines
    X_sections = categorical({sprintf('Agric.'), ...
        sprintf('Metals\\newline mining'), ...
        sprintf('Metals\\newline process.'), ...
        sprintf('Fuels\\newline extr.'), ...
        sprintf('Fuels\\newline process.'), ...
        sprintf('Chemic.'), ...
        sprintf('ICT\\newline equipm.'), ...
        sprintf('Transp.\\newline equipm.'), ...
        sprintf('Other\\newline machin.'), ...
        sprintf('Constr.'), ...
        sprintf('Other\\newline manuf.'), ...
        sprintf('PSTA'), ...
        sprintf('Softw.\\newline datab.'), ...
        sprintf('Transport\\newline services'), ...
        sprintf('Other\\newline services'), ...
        sprintf('Public\\newline services'), ...
        sprintf('Electr.\\newline transm.'), ...        
        sprintf('Electricity')});
    % Categorical arrays sort elements according to alphabetical order, but we want to preserve the original order.
    % This is done by imposing the order string(X_sections)
    X_sections = reordercats(X_sections, string(X_sections));
    % TEST
    if numel(X_sections) ~= Parameters.Sections.nr
        error('When defining X_sections there is an error as the number of items in X_sections does not equal the number of Sections.')
    end
    
    
    %% 1.0 Only %, expressed in units of products
    
    nr_plots = 3;
    struct_field_names = strings([1, nr_plots]);
    my_titles = strings([1, nr_plots]);
    struct_field_names(1) = "bar_plot_productions_phys";
    my_titles(1) = "% VARIATION OF AVERAGE PHYSICAL PRODUCTION COMPARED TO NT SCENARIO";
    struct_field_names(2) = "bar_plot_final_demand_sales_phys";
    my_titles(2) = "% VARIATION OF AVERAGE PHYSICAL SALES TO FINAL DEMAND COMPARED TO NT SCENARIO"; 
    struct_field_names(3) = "bar_plot_interindustry_sales_phys";
    my_titles(3) = "% VARIATION OF AVERAGE PHYSICAL INTERMEDIATE INPUTS SALES COMPARED TO NT SCENARIO"; 
    
    idx_NT_simulation = 1;
    idx_non_NT_simulations = setdiff(1 : nr_simulations, idx_NT_simulation);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%  1st SERIES OF BAR PLOTS  %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    
    for k = 1 : numel(struct_field_names)
    
        fg = figure('Name', sprintf('fig_1.1.%d_%s', k, struct_field_names(k))); 
        fg.WindowState = 'fullscreen';
    
        colororder(my_colors_policy_exp(idx_non_NT_simulations, :))
        % X = categorical(Parameters.Sectors.names);
        % X = reordercats(X, Parameters.Sectors.names);
    
        % Percentage changes are computed with respect to the NT
        percentage_change_value = (Data.(struct_field_names(k)) ./ Data.(struct_field_names(k))(:, idx_NT_simulation) - 1) * 100;
        % Exclude the values referring to NT vis-a-vis NT, which are obviously 0
        percentage_change_value = percentage_change_value(:, idx_non_NT_simulations);
    
        bar_plot = bar(X, percentage_change_value);
        ylim([-100 inf]) % Set minimum y-axis value to -100%
        ytickformat("percentage");    
        
        set(bar_plot, {'DisplayName'}, simulations_names(idx_non_NT_simulations)');
        legend(FontSize=my_legend_fontsize);
        set(gca,'fontsize', my_gca_fontsize, 'yscale', y_scale_metrics_bar_plots);
        %title(compose(my_titles(k)), 'FontSize', 18);
    
    
        % Adding percentage change text on top of bars        
        percentage_change = round(percentage_change_value);
        signs_percentage_change_original = sign(percentage_change);
        signs_percentage_change = reshape(signs_percentage_change_original, [], 1);
        percentage_change = compose('%d', percentage_change(:));
        percentage_change = strcat(percentage_change,'%');
        for j = 1 : length(percentage_change)
            if signs_percentage_change(j) == 1
                percentage_change{j} = strcat('+', percentage_change{j});
            end
        end
        xCnt = vertcat(bar_plot.XEndPoints)';
        text_on_bars = text(xCnt(:), percentage_change_value(:), percentage_change, 'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', my_percentage_change_fontsize);
        % We want negative percentage values to appear below bars (https://www.mathworks.com/matlabcentral/answers/1812450-how-to-draw-negative-values-on-bar-when-it-contains-negative-values#answer_1061165)
        set(text_on_bars((signs_percentage_change_original < 0)), {'VerticalAlign'}, {'top'})

    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%  2nd SERIES OF BAR PLOTS  %%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % It is likely to be the case that one bar (green electricity) is much higher than the others.
    % Therefore, to improve the readability of the plot, we want to introduce a break in the vertical dimension of the plot..
    % .. as explained here: https://www.mathworks.com/matlabcentral/answers/21292-bar-graph-with-broken-y-axis#answer_1283807
    % This is accomplished by using a tiled layout: https://www.mathworks.com/help/matlab/ref/tiledlayout.html
    % The idea is as follows: you create the same bar chart in two plots (an upper and a lower plot),..
    % ..and then you set the y-axis limits of both plots in such a way that it seems that you have a unique plot with a break in it.
    
    % By looking at the 1st series of bar plots, you can now manually set the y-axis limits of the plots
    % Limits for the upper plots in the tiled layout
    upper_plot_limits = [
        340 480;  % limits for physical production plots
        1400 1600;  % limits for physical final demand plots
        1800 2000]; % limits for physical intermediate sales plots
    % Limits for the lower plots in the tiled layout
    lower_plot_limits = [
        -100 220;  % limits for physical production plots
        -100 400;  % limits for physical final demand plots
        -100 250]; % limits for physical intermediate sales plots
    
    % HOW MANY SCENARIOS TO SHOW
        % "only first" --> show only the 1st scenario on the bar plot
        % "only second" --> show only the 2nd scenario on the bar plot
        % "all" --> show all scenarios on the bar plot
    % This distinction is useful for creating plots to be shown in presentations as step-by-step slides..
    % .. i.e. first you show a slide with only the bar plot for the first scenario, and then a slide with the bar plot for both scenarios.
    show_bars_for_which_scenario = "all";
    
    
    for k = 1 : numel(struct_field_names)
    
        fg = figure('Name', sprintf('fig_1.1.%d_%s', k, struct_field_names(k))); 
        fg.WindowState = 'fullscreen';
        
        % Set the colors to be used
        colororder(my_colors_policy_exp(idx_non_NT_simulations, :))
        
        % X = categorical(Parameters.Sectors.names);
        % X = reordercats(X, Parameters.Sectors.names);
    
        % Percentage changes are computed with respect to the NT
        percentage_change_value = (Data.(struct_field_names(k)) ./ Data.(struct_field_names(k))(:, idx_NT_simulation) - 1) * 100;
        % Exclude the values referring to NT vis-a-vis NT, which are obviously 0
        percentage_change_value = percentage_change_value(:, idx_non_NT_simulations);
    
        % Delete values for the second scenario in case we want to display only the first scenario in the bar plots
        if show_bars_for_which_scenario == "only first"
            percentage_change_value(:,2) = 0;
        elseif show_bars_for_which_scenario == "only second"
            percentage_change_value(:,1) = 0;
        end
    
        % CREATE TILED LAYOUT
        % Set number of tiles along the vertical dimension (on the horizontal dimension we are fine with 1 tile only)
        % The higher this number, the smaller the top chart becomes.        
        nr_tiles_vertically=6; 
        % Create tiled layout
        t = tiledlayout(nr_tiles_vertically, 1); 
        
        
        % UPPER PLOT
        ax1 = nexttile;
        bar_plot_1 = bar(X, percentage_change_value);        
        ytickformat("percentage");           
        set(gca,'Xtick',[]) % remove x-axis labels
        ylim(upper_plot_limits(k,:)); % set y-axis limits
        % set(bar_plot_1, {'DisplayName'}, simulations_names(idx_non_NT_simulations)');
        % legend('Location', 'northwest', 'FontSize', my_legend_fontsize);
        set(gca,'fontsize', my_gca_fontsize, 'yscale', y_scale_metrics_bar_plots); 
        title(compose(my_titles(k)), 'FontSize', 18);
    
        % Adding percentage change text on top of bars
        percentage_change = round(percentage_change_value);
        signs_percentage_change = sign(percentage_change);
        signs_percentage_change = reshape(signs_percentage_change, [], 1);
        percentage_change = compose('%d', percentage_change(:));
        percentage_change = strcat(percentage_change,'%');
        for j = 1 : length(percentage_change)
            if signs_percentage_change(j) == 1
                percentage_change{j} = strcat('+', percentage_change{j});
            end
        end
        % Delete values for the second scenario in case we want to display only the first scenario in the bar plots
        if show_bars_for_which_scenario == "only first"
            for i = 1 : Parameters.Sectors.nr                
                percentage_change{Parameters.Sectors.nr + i} = [];
            end
        elseif show_bars_for_which_scenario == "only second"
            for i = 1 : Parameters.Sectors.nr                
                percentage_change{i} = [];
            end
        end
        xCnt = vertcat(bar_plot_1.XEndPoints)';
        text(xCnt(:), percentage_change_value(:), percentage_change, 'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', my_percentage_change_fontsize);
        
      
        % LOWER PLOT
        ax2 = nexttile(2, [(nr_tiles_vertically - 1) 1]);
        bar_plot_2 = bar(X, percentage_change_value);  
        ytickformat("percentage");  
        set(gca,'fontsize', my_gca_fontsize, 'yscale', y_scale_metrics_bar_plots);                      
        ylim(lower_plot_limits(k,:)); % set y-axis limits
        set(bar_plot_2, {'DisplayName'}, simulations_names(idx_non_NT_simulations)');
        legend('Location', 'northwest', 'FontSize', my_legend_fontsize);
    
        % Adding percentage change text on top of bars
        xCnt = vertcat(bar_plot_2.XEndPoints)';
        text_on_bars = text(xCnt(:), percentage_change_value(:), percentage_change, 'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', my_percentage_change_fontsize);
        % We want negative percentage values to appear below bars (https://www.mathworks.com/matlabcentral/answers/1812450-how-to-draw-negative-values-on-bar-when-it-contains-negative-values#answer_1061165)
        set(text_on_bars((signs_percentage_change_original < 0)), {'VerticalAlign'}, {'top'})

        % Adjust space between plots
        %t.TileSpacing = 'tight'; 
    
    end    
    
    
    %% 1.1 Expressed in units of products
    
    nr_plots = 3;
    struct_field_names = strings([1, nr_plots]);
    my_titles = strings([1, nr_plots]);
    struct_field_names(1) = "bar_plot_productions_phys";
    my_titles(1) = "AVERAGE REAL PRODUCTION (physical)";
    struct_field_names(2) = "bar_plot_final_demand_sales_phys";
    my_titles(2) = "AVERAGE REAL SALES TO FINAL DEMAND (physical)";
    struct_field_names(3) = "bar_plot_interindustry_sales_phys";
    my_titles(3) = "AVERAGE REAL INTERMEDIATE INPUTS SALES (physical)";      
    
    
    for k = 1 : numel(struct_field_names)
    
        fg = figure('Name', sprintf('fig_1.1.%d_%s', k, struct_field_names(k))); 
        fg.WindowState = 'fullscreen';
        colororder(my_colors_policy_exp)
        %X = categorical(Parameters.Sectors.names);
        %X = reordercats(X, Parameters.Sectors.names);
        bar_plot = bar(X, Data.(struct_field_names(k)));
        set(bar_plot, {'DisplayName'}, simulations_names');
        legend(FontSize=my_legend_fontsize);
        set(gca,'fontsize', my_gca_fontsize, 'yscale', y_scale_metrics_bar_plots);             
        title(strcat(my_titles(k), sprintf(" - %s scale", y_scale_metrics_bar_plots)), 'FontSize', 18); 
    
        % Adding percentage change text on top of bars
        % Percentage changes are computed with respect to the NT
        percentage_change = (Data.(struct_field_names(k)) ./ Data.(struct_field_names(k))(:,1) - 1) * 100;
        percentage_change = round(percentage_change);
        signs_percentage_change = sign(percentage_change);
        signs_percentage_change = reshape(signs_percentage_change, [], 1);
        percentage_change = compose('%d', percentage_change(:));
        percentage_change = strcat(percentage_change,'%');
        for j = 1 : length(percentage_change)
            if signs_percentage_change(j) == 1
                percentage_change{j} = strcat('+', percentage_change{j});
            end
        end
        for i = 1 : Parameters.Sectors.nr
            % Erase the values for the first simulation
            percentage_change{i} = [];
        end
        xCnt = vertcat(bar_plot.XEndPoints)';
        text(xCnt(:), Data.(struct_field_names(k))(:), percentage_change, 'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', my_percentage_change_fontsize);
    
    end
    
    
    
    
    %     %%%%%%%%%%%%%   AVERAGE REAL (PHYSICAL) PRODUCTION    %%%%%%%%%%%%%
    %     
    %     fg = figure('Name','fig_bar_plot_productions_phys');
    %     %fg.WindowState = 'fullscreen';
    %     colororder(my_colors_policy_exp)
    %     X = categorical(Parameters.Sectors.names);
    %     X = reordercats(X, Parameters.Sectors.names);
    %     bar_plot_1 = bar(X, Data.bar_plot_productions_phys);
    %     set(bar_plot_1, {'DisplayName'}, simulations_names');
    %     legend(FontSize=my_legend_fontsize);
    %     set(gca,'fontsize', my_gca_fontsize);
    %     %title('AVERAGE REAL PRODUCTION (physical)', 'FontSize', 18);
    %     
    %     % Adding percentage change text on top of bars
    %     % Percentage changes are computed with respect to the NT
    %     percentage_change = (Data.bar_plot_productions_phys ./ Data.bar_plot_productions_phys(:,1) - 1) * 100;
    %     percentage_change = round(percentage_change);
    %     signs_percentage_change = sign(percentage_change);
    %     signs_percentage_change = reshape(signs_percentage_change, [], 1);
    %     percentage_change = compose('%d', percentage_change(:));
    %     percentage_change = strcat(percentage_change,'%');
    %     for j = 1 : length(percentage_change)
    %         if signs_percentage_change(j) == 1
    %             percentage_change{j} = strcat('+', percentage_change{j});
    %         end
    %     end
    %     for i = 1 : Parameters.Sectors.nr
    %         percentage_change{i} = [];
    %     end
    %     xCnt = vertcat(bar_plot_1.XEndPoints)';
    %     text(xCnt(:), Data.bar_plot_productions_phys(:), percentage_change,'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', my_percentage_change_fontsize);
    %     
    %     
    %     
    %     %%%%%%%%%%%%%    AVERAGE REAL (PHYSICAL) SALES TO FINAL DEMAND    %%%%%%%%%%%%%
    %     
    %     fg = figure('Name','fig_bar_plot_final_demand_sales_phys');
    %     %fg.WindowState = 'fullscreen';
    %     colororder(my_colors_policy_exp)
    %     X = categorical(Parameters.Sectors.names);
    %     X = reordercats(X, Parameters.Sectors.names);
    %     bar_plot_2 = bar(X, Data.bar_plot_final_demand_sales_phys);
    %     set(bar_plot_2, {'DisplayName'}, simulations_names');
    %     legend(FontSize=my_legend_fontsize);
    %     set(gca,'fontsize', my_gca_fontsize);
    %     %title('AVERAGE REAL SALES TO FINAL DEMAND (physical)', 'FontSize', 18);
    %     
    %     % Adding percentage change text on top of bars
    %     % Percentage changes are computed with respect to the NT
    %     percentage_change = (Data.bar_plot_final_demand_sales_phys ./ Data.bar_plot_final_demand_sales_phys(:,1) - 1) * 100;
    %     percentage_change = round(percentage_change);
    %     signs_percentage_change = sign(percentage_change);
    %     signs_percentage_change = reshape(signs_percentage_change, [], 1);
    %     percentage_change = compose('%d', percentage_change(:));
    %     percentage_change = strcat(percentage_change,'%');
    %     for j = 1 : length(percentage_change)
    %         if signs_percentage_change(j) == 1
    %             percentage_change{j} = strcat('+', percentage_change{j});
    %         end
    %     end
    %     for i = 1 : Parameters.Sectors.nr
    %         percentage_change{i} = [];
    %     end
    %     xCnt = vertcat(bar_plot_2.XEndPoints)';
    %     text(xCnt(:), Data.bar_plot_final_demand_sales_phys(:), percentage_change,'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', my_percentage_change_fontsize);
    %     
    %     
    %     
    %     
    %     %%%%%%%%%%%%%    AVERAGE REAL (PHYSICAL) INTERINDUSTRY SALES    %%%%%%%%%%%%%
    %     
    %     fg = figure('Name','fig_bar_plot_interindustry_sales_phys');
    %     %fg.WindowState = 'fullscreen';
    %     colororder(my_colors_policy_exp)
    %     X = categorical(Parameters.Sectors.names);
    %     X = reordercats(X, Parameters.Sectors.names);
    %     bar_plot_3 = bar(X, Data.bar_plot_interindustry_sales_phys);
    %     set(bar_plot_3, {'DisplayName'}, simulations_names');
    %     legend(FontSize=my_legend_fontsize);
    %     set(gca,'fontsize', my_gca_fontsize);
    %     %title('AVERAGE REAL INTERMEDIATE INPUTS SALES (physical)', 'FontSize', 18);
    %     
    %     % Adding percentage change text on top of bars
    %     % Percentage changes are computed with respect to the NT
    %     percentage_change = (Data.bar_plot_interindustry_sales_phys ./ Data.bar_plot_interindustry_sales_phys(:,1) - 1) * 100;
    %     percentage_change = round(percentage_change);
    %     signs_percentage_change = sign(percentage_change);
    %     signs_percentage_change = reshape(signs_percentage_change, [], 1);
    %     percentage_change = compose('%d', percentage_change(:));
    %     percentage_change = strcat(percentage_change,'%');
    %     for j = 1 : length(percentage_change)
    %         if signs_percentage_change(j) == 1
    %             percentage_change{j} = strcat('+', percentage_change{j});
    %         end
    %     end
    %     for i = 1 : Parameters.Sectors.nr
    %         percentage_change{i} = [];
    %     end
    %     xCnt = vertcat(bar_plot_3.XEndPoints)';
    %     text(xCnt(:), Data.bar_plot_interindustry_sales_phys(:), percentage_change,'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', my_percentage_change_fontsize);
    %     
    
    
    %% 1.2 Expressed in deflated values


    %%%%%%%%%%%%%   AVERAGE REAL (DEFLATED) PRODUCTION    %%%%%%%%%%%%%

    fg = figure('Name','fig_1.2.1_bar_plot_productions_deflated');
    fg.WindowState = 'fullscreen';
    colororder(my_colors_policy_exp)
    %X = categorical(Parameters.Sectors.names);
    %X = reordercats(X, Parameters.Sectors.names);
    bar_plot_1 = bar(X, Data.bar_plot_productions_defl);
    set(bar_plot_1, {'DisplayName'}, simulations_names');
    legend(FontSize=my_legend_fontsize);
    set(gca,'fontsize', my_gca_fontsize, 'yscale', y_scale_metrics_bar_plots);
    title('AVERAGE REAL PRODUCTION (deflated)', 'FontSize', 18);

    % Adding percentage change text on top of bars
    % Percentage changes are computed with respect to the NT
    percentage_change = (Data.bar_plot_productions_defl ./ Data.bar_plot_productions_defl(:,1) - 1) * 100;
    percentage_change = round(percentage_change);
    signs_percentage_change = sign(percentage_change);
    signs_percentage_change = reshape(signs_percentage_change, [], 1);
    percentage_change = compose('%d', percentage_change(:));
    percentage_change = strcat(percentage_change,'%');
    for j = 1 : length(percentage_change)
        if signs_percentage_change(j) == 1
            percentage_change{j} = strcat('+', percentage_change{j});
        end
    end
    for i = 1 : Parameters.Sectors.nr
        % Erase the values for the first simulation
        percentage_change{i} = [];
    end
    xCnt = vertcat(bar_plot_1.XEndPoints)';
    text(xCnt(:), Data.bar_plot_productions_defl(:), percentage_change,'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', my_percentage_change_fontsize);



    %%%%%%%%%%%%%    AVERAGE REAL (DEFLATED) SALES TO FINAL DEMAND    %%%%%%%%%%%%%

    fg = figure('Name','fig_1.2.2_bar_plot_final_demand_sales_deflated');
    fg.WindowState = 'fullscreen';
    colororder(my_colors_policy_exp)
    %X = categorical(Parameters.Sectors.names);
    %X = reordercats(X, Parameters.Sectors.names);
    bar_plot_2 = bar(X, Data.bar_plot_final_demand_sales_defl);
    set(bar_plot_2, {'DisplayName'}, simulations_names');
    legend(FontSize=my_legend_fontsize);
    set(gca,'fontsize', my_gca_fontsize, 'yscale', y_scale_metrics_bar_plots);
    title('AVERAGE REAL SALES TO FINAL DEMAND (deflated)', 'FontSize', 18);

    % Adding percentage change text on top of bars
    % Percentage changes are computed with respect to the NT
    percentage_change = (Data.bar_plot_final_demand_sales_defl ./ Data.bar_plot_final_demand_sales_defl(:,1) - 1) * 100;
    percentage_change = round(percentage_change);
    signs_percentage_change = sign(percentage_change);
    signs_percentage_change = reshape(signs_percentage_change, [], 1);
    percentage_change = compose('%d', percentage_change(:));
    percentage_change = strcat(percentage_change,'%');
    for j = 1 : length(percentage_change)
        if signs_percentage_change(j) == 1
            percentage_change{j} = strcat('+', percentage_change{j});
        end
    end
    for i = 1 : Parameters.Sectors.nr
        % Erase the values for the first simulation
        percentage_change{i} = [];
    end
    xCnt = vertcat(bar_plot_2.XEndPoints)';
    text(xCnt(:), Data.bar_plot_final_demand_sales_defl(:), percentage_change,'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', my_percentage_change_fontsize);



    %%%%%%%%%%%%%    AVERAGE REAL (DEFLATED) INTERINDUSTRY SALES    %%%%%%%%%%%%%

    fg = figure('Name','fig_1.2.3_bar_plot_interindustry_sales_deflated');
    fg.WindowState = 'fullscreen';
    colororder(my_colors_policy_exp)
    %X = categorical(Parameters.Sectors.names);
    %X = reordercats(X, Parameters.Sectors.names);
    bar_plot_3 = bar(X, Data.bar_plot_interindustry_sales_defl);
    set(bar_plot_3, {'DisplayName'}, simulations_names');
    legend(FontSize=my_legend_fontsize);
    set(gca,'fontsize', my_gca_fontsize, 'yscale', y_scale_metrics_bar_plots);
    title('AVERAGE REAL INTERMEDIATE INPUTS SALES (deflated)', 'FontSize', 18);

    % Adding percentage change text on top of bars
    % Percentage changes are computed with respect to the NT
    percentage_change = (Data.bar_plot_interindustry_sales_defl ./ Data.bar_plot_interindustry_sales_defl(:,1) - 1) * 100;
    percentage_change = round(percentage_change);
    signs_percentage_change = sign(percentage_change);
    signs_percentage_change = reshape(signs_percentage_change, [], 1);
    percentage_change = compose('%d', percentage_change(:));
    percentage_change = strcat(percentage_change,'%');
    for j = 1 : length(percentage_change)
        if signs_percentage_change(j) == 1
            percentage_change{j} = strcat('+', percentage_change{j});
        end
    end
    for i = 1 : Parameters.Sectors.nr
        % Erase the values for the first simulation
        percentage_change{i} = [];
    end
    xCnt = vertcat(bar_plot_3.XEndPoints)';
    text(xCnt(:), Data.bar_plot_interindustry_sales_defl(:), percentage_change,'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', my_percentage_change_fontsize);
    


    %% 1.3 Shares in nominal production

    % In this bar plot we want to show, for each scenario, for the year 2050 (= end_of_transition_time_step)..
    % ..the shares in total nominal production by each industry.

    % First we want to compute the data and store it into an array
    data_bar_plot_nominal_shares = NaN * ones(Parameters.Sectors.nr, nr_simulations);
    for i = 1 : nr_simulations
        data_bar_plot_nominal_shares(:,i) = ...
            Data.sectors_production_nominal(:, end_of_transition_time_step, i) ./ sum(Data.sectors_production_nominal(:, end_of_transition_time_step, i));
    end

    % TEST
    % The sum of nominal shares must be 1
    if any(abs(1 - sum(data_bar_plot_nominal_shares)) > Parameters.error_tolerance_strong)
        error('The sum across nominal shares does not equal 1')
    end


    % PLOTTING THE BAR PLOT

    fg = figure('Name','fig_1.3_bar_plot_nominal_production_shares');
    fg.WindowState = 'fullscreen';
    
    colororder(my_colors_policy_exp)
    %X = categorical(Parameters.Sectors.names);
    %X = reordercats(X, Parameters.Sectors.names);
    bar_plot_1 = bar(X, 100 * data_bar_plot_nominal_shares);
    set(bar_plot_1, {'DisplayName'}, simulations_names');
    ytickformat("percentage");
    legend(FontSize=my_legend_fontsize);
    set(gca,'fontsize', my_gca_fontsize, 'yscale', y_scale_metrics_bar_plots);
    title('SHARES IN TOTAL NOMINAL PRODUCTION', 'FontSize', 18);    

    % Adding percentage values text on top of bars    
    % percentage_change = data_bar_plot_nominal_shares * 100;
    % percentage_change = round(percentage_change);
    % signs_percentage_change = sign(percentage_change);
    % signs_percentage_change = reshape(signs_percentage_change, [], 1);
    % percentage_change = compose('%d', percentage_change(:));
    % percentage_change = strcat(percentage_change,'%');
    % for j = 1 : length(percentage_change)
    %     if signs_percentage_change(j) == 1
    %         percentage_change{j} = strcat('+', percentage_change{j});
    %     end
    % end
    % xCnt = vertcat(bar_plot_1.XEndPoints)';
    % text(xCnt(:), 100 * data_bar_plot_nominal_shares(:), percentage_change,'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', my_percentage_change_fontsize);
    
    
    %% 1.4 Sectoral emissions

    % We want to show, for each scenario, how much each sector emits.
    % However, the amount of emissions is very much dependent on the size of the economy.
    % So you should decide what values you want to plot: averages, totals across the entire period, ..
    % ..but maybe the best option is to look at a specific year where all real GDP levels are very close to each other across the different simulations.
    
    % Also, remember that you should rescale the values for the same reason explained in the section of code below named "Rescaling the time series"
    % Therefore, we first express the sectoral emissions in percentage terms.
    sectoral_emission_percentages = ...
        Data.bar_plot_sectoral_emissions ./ sum(Data.bar_plot_sectoral_emissions);
    % ..and then we allocate these percentages to the total (adjusted) emissions for the year(s) we want to consider
    bar_plot_emissions = ...
        sectoral_emission_percentages .* adjusted_emissions(58,:);
    
    fg = figure('Name','fig_1.4_bar_plot_emissions');
    fg.WindowState = 'fullscreen';
    colororder(my_colors_policy_exp)
    %X = categorical(Parameters.Sectors.names);
    %X = reordercats(X, Parameters.Sectors.names);
    bar_plot_4 = bar(X, bar_plot_emissions);
    set(bar_plot_4, {'DisplayName'}, simulations_names');    
    legend(FontSize=my_legend_fontsize);
    set(gca,'fontsize', my_gca_fontsize, 'yscale', y_scale_metrics_bar_plots);
    %title('EMISSIONS (Gt CO_2 eq.)', 'FontSize', 18);

    % Adding percentage change text on top of bars
    % Percentage changes are computed with respect to the NT
    percentage_change = (bar_plot_emissions ./ bar_plot_emissions(:,1) - 1) * 100;
    percentage_change = round(percentage_change);
    signs_percentage_change = sign(percentage_change);
    signs_percentage_change = reshape(signs_percentage_change, [], 1);
    percentage_change = compose('%d', percentage_change(:));
    percentage_change = strcat(percentage_change,'%');
    for j = 1 : length(percentage_change)
        if signs_percentage_change(j) == 1
            percentage_change{j} = strcat('+', percentage_change{j});
        end
    end
    for i = 1 : Parameters.Sectors.nr
        % Erase the values for the first simulation
        percentage_change{i} = [];
    end
    xCnt = vertcat(bar_plot_4.XEndPoints)';
    text(xCnt(:), bar_plot_emissions(:), percentage_change,'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', my_percentage_change_fontsize);

    
    
    %% 1.5 All together (physical)
    
    % %  figure('Name','fig_1.5_bar_plots_together');
    % % 
    % %  % Create array with industries' names..
    % %  % .. because we want some names to be split into two lines
    % %  X = categorical({sprintf('Minerals'), ...
    % %      sprintf('Fossil\\newline fuels'), ...
    % %      sprintf('Manufact.'), ...
    % %      sprintf('Miscell.'), ...
    % %      sprintf('Green\\newline electr.'), ...
    % %      sprintf('Brown\\newline electr.')});
    % %  % Categorical arrays sort elements according to alphabetical order, but we want to preserve the original order.
    % %  % This is done by imposing the order string(X)
    % %  X = reordercats(X, string(X));
    % % 
    % % 
    % % 
    % % %%%%%%%%%%%%%    AVERAGE REAL (PHYSICAL) SALES TO FINAL DEMAND    %%%%%%%%%%%%%
    % % 
    % %  subplot(2,2,1)
    % %  colororder(my_colors_policy_exp)
    % %  bar_plot_2 = bar(X, Data.bar_plot_final_demand_sales_phys);
    % %  set(bar_plot_2, {'DisplayName'}, simulations_names');
    % %  legend(FontSize=my_legend_fontsize);
    % %  set(gca,'fontsize', my_gca_fontsize, 'yscale', y_scale_metrics_bar_plots);
    % %  title('AVERAGE SALES TO FINAL DEMAND (physical)', 'FontSize', 18);
    % % 
    % %  % Adding percentage change text on top of bars
    % %  % Percentage changes are computed with respect to the NT
    % %  percentage_change = (Data.bar_plot_final_demand_sales_phys ./ Data.bar_plot_final_demand_sales_phys(:,1) - 1) * 100;
    % %  percentage_change = round(percentage_change);
    % %  signs_percentage_change = sign(percentage_change);
    % %  signs_percentage_change = reshape(signs_percentage_change, [], 1);
    % %  percentage_change = compose('%d', percentage_change(:));
    % %  percentage_change = strcat(percentage_change,'%');
    % %  for j = 1 : length(percentage_change)
    % %      if signs_percentage_change(j) == 1
    % %          percentage_change{j} = strcat('+', percentage_change{j});
    % %      end
    % %  end
    % %  for i = 1 : Parameters.Sectors.nr
    % %      percentage_change{i} = [];
    % %  end
    % %  xCnt = vertcat(bar_plot_2.XEndPoints)';
    % %  text(xCnt(:), Data.bar_plot_final_demand_sales_phys(:), percentage_change,'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', my_percentage_change_fontsize);
    % % 
    % % 
    % % 
    % % 
    % %  %%%%%%%%%%%%%    AVERAGE REAL (PHYSICAL) INTERINDUSTRY SALES    %%%%%%%%%%%%%
    % % 
    % %  subplot(2,2,2)
    % %  colororder(my_colors_policy_exp)
    % %  bar_plot_3 = bar(X, Data.bar_plot_interindustry_sales_phys);
    % %  set(bar_plot_3, {'DisplayName'}, simulations_names');
    % %  legend(FontSize=my_legend_fontsize);
    % %  set(gca,'fontsize', my_gca_fontsize, 'yscale', y_scale_metrics_bar_plots);
    % %  title('AVERAGE INTERMEDIATE INPUTS SALES (physical)', 'FontSize', 18);
    % % 
    % %  % Adding percentage change text on top of bars
    % %  % Percentage changes are computed with respect to the NT
    % %  percentage_change = (Data.bar_plot_interindustry_sales_phys ./ Data.bar_plot_interindustry_sales_phys(:,1) - 1) * 100;
    % %  percentage_change = round(percentage_change);
    % %  signs_percentage_change = sign(percentage_change);
    % %  signs_percentage_change = reshape(signs_percentage_change, [], 1);
    % %  percentage_change = compose('%d', percentage_change(:));
    % %  percentage_change = strcat(percentage_change,'%');
    % %  for j = 1 : length(percentage_change)
    % %      if signs_percentage_change(j) == 1
    % %          percentage_change{j} = strcat('+', percentage_change{j});
    % %      end
    % %  end
    % %  for i = 1 : Parameters.Sectors.nr
    % %      percentage_change{i} = [];
    % %  end
    % %  xCnt = vertcat(bar_plot_3.XEndPoints)';
    % %  text(xCnt(:), Data.bar_plot_interindustry_sales_phys(:), percentage_change,'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', my_percentage_change_fontsize);
    % % 
    % % 
    % % 
    % % 
    % %  %%%%%%%%%%%%%   AVERAGE REAL (PHYSICAL) PRODUCTION    %%%%%%%%%%%%%
    % % 
    % %  subplot(1,2,1)
    % %  colororder(my_colors_policy_exp)
    % %  bar_plot_1 = bar(X, Data.bar_plot_productions_phys);
    % %  set(bar_plot_1, {'DisplayName'}, simulations_names');
    % %  legend(FontSize=my_legend_fontsize);
    % %  set(gca,'fontsize', my_gca_fontsize, 'yscale', y_scale_metrics_bar_plots);
    % %  title('AVERAGE PRODUCTION (physical)', 'FontSize', 18);
    % % 
    % %  % Adding percentage change text on top of bars
    % %  % Percentage changes are computed with respect to the NT
    % %  percentage_change = (Data.bar_plot_productions_phys ./ Data.bar_plot_productions_phys(:,1) - 1) * 100;
    % %  percentage_change = round(percentage_change);
    % %  signs_percentage_change = sign(percentage_change);
    % %  signs_percentage_change = reshape(signs_percentage_change, [], 1);
    % %  percentage_change = compose('%d', percentage_change(:));
    % %  percentage_change = strcat(percentage_change,'%');
    % %  for j = 1 : length(percentage_change)
    % %      if signs_percentage_change(j) == 1
    % %          percentage_change{j} = strcat('+', percentage_change{j});
    % %      end
    % %  end
    % %  for i = 1 : Parameters.Sectors.nr
    % %      percentage_change{i} = [];
    % %  end
    % %  xCnt = vertcat(bar_plot_1.XEndPoints)';
    % %  text(xCnt(:), Data.bar_plot_productions_phys(:), percentage_change,'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', my_percentage_change_fontsize);
    % % 
    % % 
    % % 
    % % 
    % %  %%%%%%%%%%%%%    SECTORAL EMISSIONS    %%%%%%%%%%%%%
    % % 
    % %  subplot(1,2,2)
    % %  colororder(my_colors_policy_exp)
    % %  bar_plot_4 = bar(X, 1000 * Data.bar_plot_sectoral_emissions);
    % %  set(bar_plot_4, {'DisplayName'}, simulations_names');
    % %  legend(FontSize=my_legend_fontsize);
    % %  set(gca,'fontsize', my_gca_fontsize, 'yscale', y_scale_metrics_bar_plots);
    % %  title('EMISSIONS (units CO_2 eq.)', 'FontSize', 18);
    % % 
    % %  % Adding percentage change text on top of bars
    % %  % Percentage changes are computed with respect to the NT
    % %  percentage_change = (Data.bar_plot_sectoral_emissions ./ Data.bar_plot_sectoral_emissions(:,1) - 1) * 100;
    % %  percentage_change = round(percentage_change);
    % %  signs_percentage_change = sign(percentage_change);
    % %  signs_percentage_change = reshape(signs_percentage_change, [], 1);
    % %  percentage_change = compose('%d', percentage_change(:));
    % %  percentage_change = strcat(percentage_change,'%');
    % %  for j = 1 : length(percentage_change)
    % %      if signs_percentage_change(j) == 1
    % %          percentage_change{j} = strcat('+', percentage_change{j});
    % %      end
    % %  end
    % %  for i = 1 : Parameters.Sectors.nr
    % %      percentage_change{i} = [];
    % %  end
    % %  xCnt = vertcat(bar_plot_4.XEndPoints)';
    % %  text(xCnt(:), 1000 * Data.bar_plot_sectoral_emissions(:), percentage_change,'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', my_percentage_change_fontsize);
    
    
    %% 1.6 Sectors' average deflated investment

    % We may want to display the rescaled data in chained (2021) euros, as we do further below for the line plot of aggregate investment.
    sectoral_deflated_investment_chained_euros = ...
        (Data.bar_plot_sectoral_deflated_investment ./ Data.investment_defl_comparison(1,:)) ...
        .* (global_nominal_GDP_2021_trillion_euros * (Data.investment_defl_comparison(1,:) ./ Data.GDP_level_real_comparison(1,:)));
    
    
    fg = figure('Name','fig_1.6_bar_plot_deflated_investment');
    fg.WindowState = 'fullscreen';
    colororder(my_colors_policy_exp)
    %X = categorical(Parameters.Sectors.names);
    %X = reordercats(X, Parameters.Sectors.names);
    bar_plot = bar(X, sectoral_deflated_investment_chained_euros);
    %bar_plot = bar(X, Data.bar_plot_sectoral_deflated_investment); % NOTE: use this code here instead of the previous line of code if you want to see the original data, not the rescaled one.
    set(bar_plot, {'DisplayName'}, simulations_names');
    ylabel("chained (2021) € (trillions)");
    legend(FontSize=my_legend_fontsize);
    set(gca,'fontsize', 10.6, 'yscale', y_scale_metrics_bar_plots);  % my_gca_fontsize           
    %title(sprintf("AVERAGE REAL INVESTMENT - %s scale", y_scale_metrics_bar_plots), 'FontSize', 18); 
    
    % Adding percentage change text on top of bars
    % Percentage changes are computed with respect to the NT
    percentage_change = (Data.bar_plot_sectoral_deflated_investment ./ Data.bar_plot_sectoral_deflated_investment(:,1) - 1) * 100;        
    percentage_change = round(percentage_change);
    signs_percentage_change = sign(percentage_change);
    signs_percentage_change = reshape(signs_percentage_change, [], 1);
    percentage_change = compose('%d', percentage_change(:));
    percentage_change = strcat(percentage_change,'%');
    for j = 1 : length(percentage_change)
        if signs_percentage_change(j) == 1
            percentage_change{j} = strcat('+', percentage_change{j});
        end
    end
    for i = 1 : Parameters.Sectors.nr
        % Erase the values for the first simulation
        percentage_change{i} = [];
    end
    xCnt = vertcat(bar_plot.XEndPoints)';        
    text(xCnt(:), Data.bar_plot_sectoral_deflated_investment(:), percentage_change,'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', my_percentage_change_fontsize);
    

    %% 1.7 Sectors' investment costs breakdown

    % We want to show the investment costs breakdown for each Sector, i.e. showing how the total investment cost is split into the different capital assets.
    % We want to create a stacked bar plot where the sum of the percentages is 100%.
    
    % First we need to transform the data from Divisional to Sectoral
    Data.bar_plot_sectoral_investment_cost_breakdown = NaN * ones(Parameters.Sections.nr, Parameters.Sectors.nr, nr_simulations);
    for j = 1 : nr_simulations
        for i = 1 : Parameters.Sectors.nr            
            % We sum across the Divisions belonging to the same Sector
            Data.bar_plot_sectoral_investment_cost_breakdown(:,i,j) = ...
                sum(Data.bar_plot_divisional_investment_cost_breakdown(:, Parameters.Divisions.sector_idx == i, j), 2); 
        end
    end

    % CREATE 1 BAR PLOT FOR EACH SIMULATION
    for k = 1 : nr_simulations
        
        % Compute the investment proportions
        investment_proportions = ...
            Data.bar_plot_sectoral_investment_cost_breakdown(:,:,k) ./ sum(Data.bar_plot_sectoral_investment_cost_breakdown(:,:,k));

        % We want to show the data on the stacked bar plot such that the capital assets in which Sectors invest most in are being showed first..
        % ..because this facilitates the reading of the plot.
        % So we create a sorted index of the capital assets. We do so just once, for the 1st simulation, and keep such index for all simulations.
        if k == 1
            [~, idx] = sort(sum(investment_proportions, 2), 'descend');
            idx = intersect(idx, Parameters.Sections.idx_capital_assets, 'stable');
        end

        fg = figure('Name', sprintf('fig_1.7_bar_plot_sectors_investment_breakdown_sim_%d', k));
        fg.WindowState = 'fullscreen';

        bar_plot = bar(X, 100 * investment_proportions(idx, :), 'stacked', 'BarWidth', 0.5);
        ytickformat("percentage");
        ylim([0 100])        

        legend(Parameters.Sections.names(idx), FontSize=my_legend_fontsize)
        title(sprintf("INVESTMENT COSTS BREAKDOWN (in the last period of the simulation) - %s", string(simulations_names(k))), 'FontSize', 18); 
        set(gca,'fontsize', my_gca_fontsize)

    end


    %% 1.8 Average price change

    % First we want to compute the data and store it into an array
    prices_compound_growth_rate = NaN * ones(Parameters.Sections.nr, nr_simulations);
    for k = 1 : nr_simulations        
        my_field = sprintf('sectional_prices_sim_%d', k);
        my_data = Data.(my_field);
        % Computing the average growth rate
        prices_compound_growth_rate(:,k) = ...
            (my_data(end_of_transition_time_step, :) ./ my_data(1,:)) .^ (1 / (end_of_transition_time_step - 1)) - 1;
    end           


    % PLOTTING THE BAR PLOT

    fg = figure('Name','fig_1.8_bar_plot_prices');
    fg.WindowState = 'fullscreen';
    
    colororder(my_colors_policy_exp)  
    bar_plot_1 = bar(X_sections, 100 * prices_compound_growth_rate);
    set(bar_plot_1, {'DisplayName'}, simulations_names');
    ytickformat("percentage");
    legend(FontSize=my_legend_fontsize);
    set(gca,'fontsize', my_gca_fontsize, 'yscale', y_scale_metrics_bar_plots);
    %title('AVERAGE ANNUAL PRICE GROWTH RATE (2021-2050)', 'FontSize', 18);

    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%       LINE PLOTS      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Generic settings

    % COLORS FOR EACH SIMULATION
    % Random colors
    %my_colors_policy_exp = lines(nr_simulations);   
    % Green and brown colors
    my_colors_policy_exp = ...
        [0.6706, 0.4078, 0.3412; % brown
        0, 0.5, 0; % first green        
        0.4660, 0.6740, 0.1880; % second green
        0.3010 0.7450 0.9330]; % blue

    % Linewidth
    my_line_width = 4;
    my_line_width_little = 2;
    
    % Label on x-axis
    my_x_axis_label = 'years';
    
    % gca fontsize
    my_gca_fontsize = 20;
    my_gca_fontsize_little = 15;
    
    % Legend fontsize
    my_legend_fontsize = 20;
    my_legend_fontsize_little = 15;
    my_legend_fontsize_tiny = 10;
    
    % metrics (log or linear)
    % y_scale_metrics = 'linear';
    y_scale_metrics = 'log';
    y_scale_metrics_constraints_plots = 'linear';
    
    % Initial year to be displayed on horizontal axis
    initial_year = 2020;
    % Choose the ticks interval
    x_axis_ticks_interval = 10;
    % Final year to be displayed on horizontal axis
    final_year = initial_year + Parameters.valid_results_time_span_length;
    % Time step corresponding to end of the energy transition
    end_of_transition_time_step = Parameters.end_of_energy_transition - Parameters.valid_results_time_span(1) + 1;
    
    %%%%%  FOR PLOTS WHERE EACH LINE REPRESENTS A SECTOR OR SECTION  %%%%%
    
    % LINES STYLES
    my_lines_styles = {'-', ':'};
    
    % COLORS FOR LINES
    % Choose your colormap among the ones listed here: https://www.mathworks.com/help/matlab/ref/colormap.html
    % "turbo", "hsv", "jet", and "lines" are the best ones
    my_colors_divisions = turbo(ceil(Parameters.Divisions.nr / numel(my_lines_styles))); % turbo(Parameters.Sectors.nr);
    my_colors_sectors = turbo(ceil(Parameters.Sectors.nr / numel(my_lines_styles))); % turbo(Parameters.Sectors.nr);
    my_colors_sections = turbo(ceil(Parameters.Sections.nr / numel(my_lines_styles))); % turbo(Parameters.Sections.nr);
        

    %% Rescaling the time series

    % Since we usually use a stabilization period in the model, spanning several periods to reach a steady state ..
    % ..before applying the different energy transition scenarios, this implies that the level of real GDP, investment, consumption, and emissions ..
    % ..needs to be rescaled to their 2021 real-world levels.


    %%%%%%%%  REAL GDP  %%%%%%%%
    
    % GLOBAL NOMINAL GDP IN 2021, EXPRESSED IN TRILLION €   
    % Data are usually provided in $
    global_nominal_GDP_2021_trillion_dollars = 97.53;
    % Average exchange rate in 2021
    exchange_rate_dollars_for_1_euro_2021 = 1.18;
    % Nominal GDP in trillion €
    global_nominal_GDP_2021_trillion_euros = global_nominal_GDP_2021_trillion_dollars ./ exchange_rate_dollars_for_1_euro_2021;
    
    % RESCALING REAL GDP
    % Now we divide our real GDP measure by its initial value to obtain an index starting with an initial value of 1;
    % then we multiply the series by "global_nominal_GDP_2021_trillion_euros" to obtain real GDP in chained (2021) euros.
    % Note that this adjusted measure of real GDP has the same growth rates of the original time series (Data.GDP_level_real_comparison).
    GDP_level_real_comparison_chained_2021_euros = ...
        (Data.GDP_level_real_comparison ./ Data.GDP_level_real_comparison(1,:)) .* global_nominal_GDP_2021_trillion_euros;


    %%%%%%%%  REAL INVESTMENT  %%%%%%%%    

    % Since we rescaled GDP data to start with an initial value consistent with actual-world GDP in 2021,
    % .. we also have to rescale the investment data.
    investment_defl_comparison_chained_2021_euros = ...
        (Data.investment_defl_comparison ./ Data.investment_defl_comparison(1,:)) ...
        .* (global_nominal_GDP_2021_trillion_euros * (Data.investment_defl_comparison(1,:) ./ Data.GDP_level_real_comparison(1,:)));


    %%%%%%%%  REAL HH CONSUMPTION  %%%%%%%%

    % Since we rescaled GDP data to start with an initial value consistent with actual-world GDP in 2021,
    % .. we also have to rescale the hh consumption data.
    hhs_consumption_defl_comparison_chained_2021_euros = ...
        (Data.hhs_consumption_defl_comparison ./ Data.hhs_consumption_defl_comparison(1,:)) ...
        .* (global_nominal_GDP_2021_trillion_euros * (Data.hhs_consumption_defl_comparison(1,:) ./ Data.GDP_level_real_comparison(1,:)));

    
    %%%%%%%%  REAL GOV'T CONSUMPTION  %%%%%%%%

    % Since we rescaled GDP data to start with an initial value consistent with actual-world GDP in 2021,
    % .. we also have to rescale the gov't consumption data.
    govt_consumption_defl_comparison_chained_2021_euros = ...
        (Data.govt_consumption_defl_comparison ./ Data.govt_consumption_defl_comparison(1,:)) ...
        .* (global_nominal_GDP_2021_trillion_euros * (Data.govt_consumption_defl_comparison(1,:) ./ Data.GDP_level_real_comparison(1,:)));


    %%%%%%%%  EMISSIONS FLOW  %%%%%%%%

    % The flow of emissions obviously depends on the size of the economy. Therefore we skip all the growth in emissions associated ..
    % .. to the economic growth occuring during the stabilization period of the model, i.e. before the start of the different energy transition scenarios.
    % Imagine that emissions (E)--after the stabilization period--are like this: 
    % in the 1st period E(2021) = 100, and in the 2nd period E(2022) = 110 (i.e. a 10% growth rate).
    % (Keep in mind that our simulations may already take different values starting from 2022)
    % However we know that in the real world, emission (ER) where ER(2021) = 60.
    % We therefore rescale the flow of emissions (E) to the 2021 real-world level, so that E(2021) = 60 instead of 100.
    % However, which value should E(2022) then have? 
    % E(2022) = 110-(100-60) = 70 or rather E(2022) = 60 + 10% *60 = 66 ?
    % It is obviously better to opt for having the same growth rates and not the same delta (as the delta itself depends on the size of the economy).
    
    % Global GHG emissions in 2021, in Gigatonnes. Source: https://ourworldindata.org/greenhouse-gas-emissions
    global_emissions_2021 = 53.5;
    % Now we divide our GHG emissions measure by its initial value to obtain an index starting with an initial value of 1
    % then we multiply the series by "global_emissions_2021"    
    % Note that this adjusted measure of emissions has the same growth rates of the original time series (Data.emissions_total_flow_comparison).
    adjusted_emissions = ...
        (Data.emissions_total_flow_comparison ./ Data.emissions_total_flow_comparison(1,:)) .* global_emissions_2021; 


    %% Electricity generation

    %%%%%%%%  ELECTRICITY GENERATION PROJECTIONS BY IEA  %%%%%%%%

    % We take the data from Tables A.3a, A.3b, A.3c in World Energy Outlook 2024 (Annex A)

    % We take data for 2021, 2022, 2030, 2035, 2040, 2050
    % And then we do a linear interpolation to fill the remaining years in between

    electricity_generation_IEA_short = [
        28346 29033 37489 42766 48409 58352; % STEPS
        28346 29033 38285 45759 54638 70564; % APS
        28346 29033 39783 50084 61965 80194 % NZE
        ];

    initial_year_IEA = 2021;
    final_year_IEA = 2050;
    years_IEA = (initial_year_IEA : final_year_IEA)';
    nr_years_IEA = numel(years_IEA);
    years_data_points_IEA = [2021 2022 2030 2035 2040 2050]; % data points that we've taken from the IEA table
    nr_data_points_IEA = numel(years_data_points_IEA);
    years_interval_IEA = diff(years_data_points_IEA);
    nr_years_in_interval_IEA = years_interval_IEA + 1;

    nr_scenarios_IEA = 3;


    % Create empty array with a 1-year time step    
    electricity_generation_IEA_long = NaN * ones(nr_years_IEA, nr_scenarios_IEA);
    
    % Performing the linear interpolation
    for i = 1 : nr_data_points_IEA    
        
        if i ~= nr_data_points_IEA
            
            % Create the data that linearly fit the interval between the (i)th-value and the (i+1)th-value
            % i.e. if we're considering i->2030  and i+1->2035, we want to find the values for the interval 2030,2031,2032,2033,2034,2035.                        
            interval_filling = NaN * ones(nr_years_in_interval_IEA(i), nr_scenarios_IEA);
            for k = 1 : nr_scenarios_IEA
                interval_filling(:,k) = linspace(electricity_generation_IEA_short(k,i), electricity_generation_IEA_short(k,i+1), nr_years_in_interval_IEA(i));
            end
            
            % Fill the final arrays with the current data, that covers the interval between the (i)th-value and the (i+1)th-value
            for j = 1 : years_interval_IEA(i)
                if i ~= 1
                    already_filled_years = sum(years_interval_IEA(1:(i-1)));
                else
                    already_filled_years = 0;
                end
                
                electricity_generation_IEA_long(already_filled_years + j, :) = interval_filling(j,:);
            end
        
        % If i==nr_data_points_IEA, it means that we have reached the final year (i.e. 2050)
        else        
            
            j = 1;
            already_filled_years = sum(years_interval_IEA(1:(i-1)));                       
            
            electricity_generation_IEA_long(already_filled_years + j, :) = electricity_generation_IEA_short(:, nr_data_points_IEA);
        
        end
    end


    %%%%%%%%  RESCALING ELECTRICITY PRODUCTION IN TRIODE  %%%%%%%%

    % The rationale behind the rescaling process is explained in the section of code "Rescaling the time series".
    % The rescaling process here is the same as for the emissions flow (see explanation there).   

    % Global electricity production in 2021 (TWh): we take the data from the IEA array
    global_electricity_production_TWh_2021 = electricity_generation_IEA_short(1,1);
    % Convert the model's time series from Triode units of electricity to TWh
    electricity_production_TWh = Parameters.electricity_units_to_TWh * Data.electricity_production_phys;
    % Adjust the model's time series such that first year values equal global real-world values in 2021
    adjusted_electricity_production_TWh = ...
        (electricity_production_TWh ./ electricity_production_TWh(1,:)) .* global_electricity_production_TWh_2021;     


    %% %%%%%%%%%%%    MACROECONOMIC PLOTS    %%%%%%%%%%%%%%
    %% 2.1  Real GDP

    fg = figure('Name','fig_2.1_GDP_level_comparison');
    fg.WindowState = 'fullscreen';
    sgtitle('--------- REAL GDP ---------', 'FontSize', 22, 'fontweight', 'bold', 'Color', 'black');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%  LEVEL  %%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    subplot(1,2,1)
    hold on
    %yyaxis left
    for i = 1 : nr_simulations
        plot(GDP_level_real_comparison_chained_2021_euros(:,i), 'LineStyle', '-', 'LineWidth', my_line_width, 'Color', my_colors_policy_exp(i,:));
    end
    ylabel("chained (2021) € (trillions)");
    set(gca, 'yscale', y_scale_metrics);
    % yyaxis right
    % for i = 1 : nr_simulations
    %     plot(100 * repmat(Data.avg_GDP_growth_rate_real_comparison(i), Parameters.valid_results_time_span_length, 1), 'LineStyle', '--', 'LineWidth', my_line_width, 'Color', my_colors_policy_exp(i,:), 'Marker', 'none');
    % end
    % ytickformat("percentage");    
    % Set the right y-axis limits in a way as to prevent the lines to be on the edge of the plot
    %ylim([min(Data.avg_GDP_growth_rate_real_comparison) - 0.01; max(Data.avg_GDP_growth_rate_real_comparison) + 0.01]);
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end
    hold off    
    %title(sprintf('LEVEL - %s scale', y_scale_metrics), 'FontSize', my_gca_fontsize); 
    % yticks(2:1:5)
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);    
    legend(simulations_names,'Location','best', 'FontSize', my_legend_fontsize);    
    set(gca,'fontsize', my_gca_fontsize);
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    
    % Force the two vertical axis ticks' colors to be black
    % ax = gca;
    % ax.YAxis(1).Color = 'k';
    % ax.YAxis(2).Color = 'k'; 
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%  GROWTH RATE  %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    subplot(1,2,2)
    colororder(my_colors_policy_exp);
    plot(100 * Data.GDP_growth_rate_real_comparison, 'LineWidth', my_line_width);      
    ytickformat("percentage");
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end
    %title('REAL GDP GROWTH RATE', 'FontSize', my_gca_fontsize); 
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);    
    legend(simulations_names,'Location','best', 'FontSize', my_legend_fontsize);
    set(gca,'fontsize', my_gca_fontsize);
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);



    % This command may be useful when exporting the figures for the paper as it allows you to set the height-width ratio
    % See also here: https://www.mathworks.com/help/matlab/ref/matlab.ui.figure-properties.html#d126e492262
    % set(gcf, 'Position', [0, 0, 900, 700]);
    
    
    %% 2.3  Real investment
    
    fg = figure('Name','fig_2.3_investment_comparison');
    fg.WindowState = 'fullscreen';
    colororder(my_colors_policy_exp);
    plot(investment_defl_comparison_chained_2021_euros, 'LineWidth', my_line_width);
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end
    title(sprintf('REAL INVESTMENT (deflated) - %s scale', y_scale_metrics), 'FontSize', 16); 
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
    ylabel("chained (2021) € (trillions)");
    xlabel(my_x_axis_label);
    legend(simulations_names,'Location','northwest', 'FontSize', my_legend_fontsize);
    set(gca,'fontsize', my_gca_fontsize, 'yscale', y_scale_metrics);
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    
    
    %% 2.4.1  Real consumption & real investment: levels
    
    fg = figure('Name','fig_2.4.1_consumption_and_investment_comparison');
    fg.WindowState = 'fullscreen';
    colororder(my_colors_policy_exp)
    
    sp1 = subplot(1,2,1);
    hold on    
    % yyaxis right
    % for i = 1 : nr_simulations
    %     plot(repmat(Data.avg_hhs_consumption_defl_growth_rate_comparison(i), Parameters.valid_results_time_span_length, 1), 'LineStyle', '--', 'LineWidth', my_line_width, 'Color', my_colors_policy_exp(i,:));
    % end
    % % Set the right y-axis limits in a way as to (1) prevent the lines to be on the edge of the plot; (2) make the axis limits equal across the two subplots.
    % ylim([min([Data.avg_hhs_consumption_defl_growth_rate_comparison  Data.avg_investment_defl_growth_rate_comparison]) - 0.01; max([Data.avg_hhs_consumption_defl_growth_rate_comparison  Data.avg_investment_defl_growth_rate_comparison]) + 0.01]);
    % yyaxis left
    for i = 1 : nr_simulations
        plot(hhs_consumption_defl_comparison_chained_2021_euros(:,i), 'LineStyle', '-', 'LineWidth', my_line_width, 'Color', my_colors_policy_exp(i,:));
    end
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end    
    hold off
    set(gca, 'yscale', y_scale_metrics);
    title(sprintf('REAL CONSUMPTION - %s scale', y_scale_metrics), 'FontSize', 16); 
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
    ylabel("chained (2021) € (trillions)");
    legend(simulations_names,'Location','NorthWest', 'FontSize', my_legend_fontsize);    
    set(gca,'fontsize', my_gca_fontsize); 
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);    
    
    % Force the two vertical axis ticks' colors to be black
    % ax = gca;
    % ax.YAxis(1).Color = 'k';
    % ax.YAxis(2).Color = 'k';
    
    
    sp2 = subplot(1,2,2);
    hold on    
    % yyaxis right
    % for i = 1 : nr_simulations
    %     plot(repmat(Data.avg_investment_defl_growth_rate_comparison(i), Parameters.valid_results_time_span_length, 1), 'LineStyle', '--', 'LineWidth', my_line_width, 'Color', my_colors_policy_exp(i,:));
    % end
    % % Set the right y-axis limits in a way as to (1) prevent the lines to be on the edge of the plot; (2) make the axis limits equal across the two subplots.
    % ylim([min([Data.avg_hhs_consumption_defl_growth_rate_comparison  Data.avg_investment_defl_growth_rate_comparison]) - 0.01; max([Data.avg_hhs_consumption_defl_growth_rate_comparison  Data.avg_investment_defl_growth_rate_comparison]) + 0.01]);
    % yyaxis left
    for i = 1 : nr_simulations
        plot(investment_defl_comparison_chained_2021_euros(:,i), 'LineStyle', '-', 'LineWidth', my_line_width, 'Color', my_colors_policy_exp(i,:));
    end    
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end  
    hold off
    set(gca, 'yscale', y_scale_metrics);
    title(sprintf('REAL INVESTMENT - %s scale', y_scale_metrics), 'FontSize', 16);     
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
    ylabel("chained (2021) € (trillions)");
    legend(simulations_names,'Location','NorthWest', 'FontSize', my_legend_fontsize);    
    set(gca,'fontsize', my_gca_fontsize);  
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    
    % Force the two vertical axis ticks' colors to be black
    % ax = gca;
    % ax.YAxis(1).Color = 'k';
    % ax.YAxis(2).Color = 'k';
    
    
    % Set the y-axis limits of the two subplots to be equal
    %linkaxes([sp1 sp2],'y')



    % This command may be useful when exporting the figures for the paper as it allows you to set the height-width ratio
    % See also here: https://www.mathworks.com/help/matlab/ref/matlab.ui.figure-properties.html#d126e492262
    % set(gcf, 'Position', [0, 0, 1800, 700]);


    %% 2.4.2  Real consumption & real investment: growth rates
    
    fg = figure('Name','fig_2.4.2_consumption_and_investment_comparison');
    fg.WindowState = 'fullscreen';
    colororder(my_colors_policy_exp)
    
    % CONSUMPTION
    sp1 = subplot(1,2,1);       
    plot(100 * Data.hhs_consumption_defl_growth_rate_comparison, 'LineWidth', my_line_width);    
    ytickformat("percentage");
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end        
    title('REAL CONSUMPTION GROWTH RATE', 'FontSize', 16); 
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);    
    legend(simulations_names,'Location','NorthWest', 'FontSize', my_legend_fontsize);    
    set(gca,'fontsize', my_gca_fontsize); 
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);    
    
    
    % INVESTMENT
    sp2 = subplot(1,2,2);    
    plot(100 * Data.investment_defl_growth_rate_comparison, 'LineWidth', my_line_width);
    ytickformat("percentage");
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end      
    title('REAL INVESTMENT GROWTH RATE', 'FontSize', 16);     
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);    
    legend(simulations_names,'Location','NorthWest', 'FontSize', my_legend_fontsize);    
    set(gca,'fontsize', my_gca_fontsize);  
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
        
        
    % Set the y-axis limits of the two subplots to be equal
    linkaxes([sp1 sp2],'y')


    % This command may be useful when exporting the figures for the paper as it allows you to set the height-width ratio
    % See also here: https://www.mathworks.com/help/matlab/ref/matlab.ui.figure-properties.html#d126e492262
    % set(gcf, 'Position', [0, 0, 900, 700]);
    
    
    %% 2.5  Real GDP + investment + hh consumption + gov't consumption
    
    fg = figure('Name','fig_2.5_GDP_investment_consumption_comparison');    
    %fg.WindowState = 'maximized';
    
    colororder(my_colors_policy_exp)

    % Array to be used when linking axes of investment, hh consumption, and gov't consumption
    linkaxes_array = [];
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%  GDP  %%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%               
    
    subplot(2,2,1)
    hold on
    yyaxis left
    for i = 1 : nr_simulations
        plot(GDP_level_real_comparison_chained_2021_euros(:,i), 'LineStyle', '-', 'LineWidth', my_line_width, 'Color', my_colors_policy_exp(i,:), 'Marker', 'none');
    end
    ylabel("chained (2021) € (trillions)");
    set(gca, 'yscale', y_scale_metrics);
    yyaxis right
    for i = 1 : nr_simulations
        plot(100 * repmat(Data.avg_GDP_growth_rate_real_comparison(i), Parameters.valid_results_time_span_length, 1), 'LineStyle', '--', 'LineWidth', my_line_width, 'Color', my_colors_policy_exp(i,:), 'Marker', 'none');
    end
    ytickformat("percentage");
    % Set the right y-axis limits in a way as to prevent the lines to be on the edge of the plot
    %ylim([min(Data.avg_GDP_growth_rate_real_comparison) - 0.01; max(Data.avg_GDP_growth_rate_real_comparison) + 0.01]);
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end 
    hold off    
    title(sprintf('REAL GPD - %s scale (left axis) \n AVERAGE GROWTH RATE (right axis)', y_scale_metrics), 'FontSize', 16); 
    %yticks(2:1:5)
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);    
    legend(simulations_names,'Location','best', 'FontSize', my_legend_fontsize_little);    
    set(gca,'fontsize', my_gca_fontsize_little);
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    
    % Force the two vertical axis ticks' colors to be black
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = 'k';              
      
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%  INVESTMENT  %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%                   
    
    figsp{1} = subplot(2,2,2);    
    plot(investment_defl_comparison_chained_2021_euros, 'LineWidth', my_line_width);
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end  
    title(sprintf('REAL INVESTMENT - %s scale', y_scale_metrics), 'FontSize', 16); 
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
    ylabel("chained (2021) € (trillions)");
    legend(simulations_names,'Location','northwest', 'FontSize', my_legend_fontsize_little);
    set(gca,'fontsize', my_gca_fontsize_little, 'yscale', y_scale_metrics);
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    linkaxes_array = [linkaxes_array figsp{1}];
       
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%  HH CONSUMPTION  %%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    
    figsp{2} = subplot(2,2,3);    
    plot(hhs_consumption_defl_comparison_chained_2021_euros, 'LineWidth', my_line_width);  
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end  
    title(sprintf('REAL HOUSEHOLDS'' CONSUMPTION - %s scale', y_scale_metrics), 'FontSize', 16); 
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);    
    ylabel("chained (2021) € (trillions)");
    legend(simulations_names,'Location','best', 'FontSize', my_legend_fontsize_little);
    set(gca,'fontsize', my_gca_fontsize_little, 'yscale', y_scale_metrics);
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    linkaxes_array = [linkaxes_array figsp{2}];
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%  GOV'T CONSUMPTION  %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    if any(any(~isnan(govt_consumption_defl_comparison_chained_2021_euros)))
        figsp{3} = subplot(2,2,4);    
        plot(govt_consumption_defl_comparison_chained_2021_euros, 'LineWidth', my_line_width);   
        % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
        if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
            xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
        end  
        title(sprintf('REAL GOV''T CONSUMPTION - %s scale', y_scale_metrics), 'FontSize', 16); 
        xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);    
        ylabel("chained (2021) € (trillions)");
        legend(simulations_names,'Location','best', 'FontSize', my_legend_fontsize_little);
        set(gca,'fontsize', my_gca_fontsize_little, 'yscale', y_scale_metrics);
        set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
        linkaxes_array = [linkaxes_array figsp{3}];
    end
    
    
    % Set the y-axis limits of the investment and consumption subplots to be equal
    linkaxes(linkaxes_array,'y')
    
    
    %% 2.6  Consumption basket units demanded

    x = 1 : numel(Parameters.valid_results_time_span);
    
    fg = figure('Name','fig_2.6_consumption_baskets_comparison');
    fg.WindowState = 'fullscreen';    
    sgtitle(sprintf('--------- CONSUMPTION BASKET UNITS DEMANDED - %s scale ---------', y_scale_metrics), 'FontSize', 22, 'fontweight', 'bold', 'Color', 'black');
    
    colororder(my_colors_policy_exp)
    
    % ..BY THE HOUSEHOLD
    sp1 = subplot(1,2,1);
    hold on        
    for i = 1 : nr_simulations
        plot(Data.hhs_consumption_basket_units_demanded(:,:,i), 'LineWidth', my_line_width, 'Color', my_colors_policy_exp(i,:));
    end
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end    
    hold off
    set(gca, 'yscale', y_scale_metrics);
    title(sprintf('HH PHYSICAL DEMAND - %s scale', y_scale_metrics), 'FontSize', 16); 
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);    
    legend(simulations_names,'Location','NorthWest', 'FontSize', my_legend_fontsize);    
    set(gca,'fontsize', my_gca_fontsize); 
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
      
    
    % ..BY THE GOVERNMENT
    % If the gov't demand is zero in all simulations, then we don't want to plot anything
    if any(any(Data.govt_consumption_basket_units_demanded_in1year > 0))
        sp2 = subplot(1,2,2);
        hold on        
        for i = 1 : nr_simulations
            plot(x+1, Data.govt_consumption_basket_units_demanded_in1year(:,i), 'LineWidth', 2*nr_simulations + 2 - i*2, 'Color', my_colors_policy_exp(i,:));
        end
        % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
        if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
            xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
        end    
        hold off
        set(gca, 'yscale', y_scale_metrics);
        title(sprintf('GOVT PHYSICAL DEMAND - %s scale', y_scale_metrics), 'FontSize', 16); 
        xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);    
        legend(simulations_names,'Location','NorthWest', 'FontSize', my_legend_fontsize);    
        set(gca,'fontsize', my_gca_fontsize); 
        set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
        
        
        % Set the y-axis limits of the two subplots to be equal
        %linkaxes([sp1 sp2],'y')
    end




    % OTHER FORMAT OF THE PLOT: ONE SUBPLOT FOR EACH SIMULATION

    % legend_text = [];
    % legend_text{1,1} = 'household';
    % legend_text{1,2} = 'gov''t';   
    % 
    % % Array to be used when linking axes
    % linkaxes_array = [];
    % 
    % x = 1 : numel(Parameters.valid_results_time_span);
    % 
    % fg = figure('Name','fig_2.6_consumption_baskets_comparison');
    % fg.WindowState = 'fullscreen';    
    % sgtitle(sprintf('--------- CONSUMPTION BASKET UNITS DEMANDED - %s scale ---------', y_scale_metrics), 'FontSize', 22, 'fontweight', 'bold', 'Color', 'black');
    % 
    % for i = 1 : nr_simulations
    %     figsp{i} = subplot(1, nr_simulations, i);
    %     hold on
    %     plot(Data.hhs_consumption_basket_units_demanded(:,:,i), 'LineWidth', my_line_width_little);
    %     plot(x+1, Data.govt_consumption_basket_units_demanded_in1year(:,i), 'LineWidth', my_line_width_little);        
    %     % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    %     if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
    %         xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    %     end
    %     hold off
    %     title(sprintf('%s', string(simulations_names(i))), 'FontSize', 14);
    %     xlim([1 numel(Parameters.valid_results_time_span)]);
    %     xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
    %     legend(legend_text,'Location','best', 'FontSize', my_legend_fontsize_little);
    %     set(gca,'fontsize', my_gca_fontsize_little, 'yscale', y_scale_metrics);
    %     set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    % 
    %     linkaxes_array = [linkaxes_array figsp{i}];
    % end
    % 
    % linkaxes(linkaxes_array, 'y')
    
    
    %% 2.7  Inflation
    
    fg = figure('Name','fig_2.7_inflation_comparison');
    fg.WindowState = 'fullscreen';
    %sgtitle('---------- INFLATION (left axis) and AVERAGE INFLATION (right axis) ----------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
    
    
    % GDP DEFLATOR INFLATION
    subplot(1,2,1);
    hold on
    % yyaxis left
    for i = 1 : nr_simulations
        plot(100 * Data.GDP_deflator_inflation(:,i), 'LineWidth', my_line_width, 'LineStyle', '-', 'Color', my_colors_policy_exp(i,:));                
    end
    ytickformat("percentage");
    % yyaxis right
    % for i = 1 : nr_simulations        
    %     plot(repmat(100 * Data.avg_GDP_deflator_inflation(i), Parameters.valid_results_time_span_length, 1), 'LineWidth', my_line_width_little, 'LineStyle', '--', 'Color', my_colors_policy_exp(i,:));            
    % end
    % ytickformat("percentage");
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end
    hold off
    %ylim([-0.5 inf])
    title('GDP deflator inflation', 'FontSize', 20); 
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);        
    legend(simulations_names,'Location','best', 'FontSize', my_legend_fontsize_little);
    set(gca,'fontsize', my_gca_fontsize_little);
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    
    % Force the two vertical axis ticks' colors to be black
    % ax = gca;
    % ax.YAxis(1).Color = 'k';
    % ax.YAxis(2).Color = 'k';
    
    
    % CPI INFLATION
    subplot(1,2,2);
    hold on
    %yyaxis left
    for i = 1 : nr_simulations
        plot(100 * Data.CPI_inflation(:,i), 'LineWidth', my_line_width, 'LineStyle', '-', 'Color', my_colors_policy_exp(i,:));                
    end
    ytickformat("percentage");
    % yyaxis right
    % for i = 1 : nr_simulations        
    %     plot(repmat(100 * Data.avg_CPI_inflation(i), Parameters.valid_results_time_span_length, 1), 'LineWidth', my_line_width_little, 'LineStyle', '--', 'Color', my_colors_policy_exp(i,:));            
    % end
    % ytickformat("percentage");
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end
    hold off
    %ylim([-0.5 inf])
    title('CPI inflation', 'FontSize', 20); 
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);        
    legend(simulations_names,'Location','best', 'FontSize', my_legend_fontsize_little);
    set(gca,'fontsize', my_gca_fontsize_little);
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    
    % Force the two vertical axis ticks' colors to be black
    % ax = gca;
    % ax.YAxis(1).Color = 'k';
    % ax.YAxis(2).Color = 'k';  


    % This command may be useful when exporting the figures for the paper as it allows you to set the height-width ratio
    % See also here: https://www.mathworks.com/help/matlab/ref/matlab.ui.figure-properties.html#d126e492262
    % set(gcf, 'Position', [0, 0, 900, 700]);


    %% 2.8  Share of .. in nominal production
    
    fg = figure('Name','fig_2.8_shares_in_nominal_production');
    fg.WindowState = 'fullscreen';
    sgtitle('--------- SHARE OF .. IN TOTAL NOMINAL PRODUCTION ---------', 'FontSize', 22, 'fontweight', 'bold', 'Color', 'black');

    colororder(my_colors_policy_exp);


    % HOUSEHOLD CONSUMPTION
    subplot(2,3,1)
    plot(100 * Data.share_hh_cons_in_nominal_production, 'LineWidth', my_line_width);
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end
    ytickformat("percentage");
    title('HOUSEHOLD CONSUMPTION', 'FontSize', 16); 
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);        
    legend(simulations_names, 'Location', 'best', 'FontSize', my_legend_fontsize_little);
    set(gca,'fontsize', my_gca_fontsize_little);
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);

    
    % GOV'T CONSUMPTION
    subplot(2,3,2)
    plot(100 * Data.share_govt_cons_in_nominal_production, 'LineWidth', my_line_width);
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end
    ytickformat("percentage");
    title('GOV''T CONSUMPTION', 'FontSize', 16); 
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);        
    legend(simulations_names, 'Location', 'best', 'FontSize', my_legend_fontsize_little);
    set(gca,'fontsize', my_gca_fontsize_little);
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);


    % INVESTMENT
    subplot(2,3,3)
    plot(100 * Data.share_investment_in_nominal_production, 'LineWidth', my_line_width);
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end
    ytickformat("percentage");
    title('INVESTMENT', 'FontSize', 16); 
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);        
    legend(simulations_names, 'Location', 'best', 'FontSize', my_legend_fontsize_little);
    set(gca,'fontsize', my_gca_fontsize_little);
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);


    % INTERMEDIATE SALES
    subplot(2,3,4)
    plot(100 * Data.share_intermediate_in_nominal_production, 'LineWidth', my_line_width);
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end
    ytickformat("percentage");
    title('INTERMEDIATE PRODUCTION', 'FontSize', 16); 
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);        
    legend(simulations_names, 'Location', 'best', 'FontSize', my_legend_fontsize_little);
    set(gca,'fontsize', my_gca_fontsize_little);
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);


    % CHANGE IN INVENTORIES
    subplot(2,3,5)
    plot(100 * Data.share_delta_inventories_in_nominal_production, 'LineWidth', my_line_width);
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end
    ytickformat("percentage");
    title('CHANGE IN INVENTORIES', 'FontSize', 16); 
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);        
    legend(simulations_names, 'Location', 'best', 'FontSize', my_legend_fontsize_little);
    set(gca,'fontsize', my_gca_fontsize_little);
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);


    %% 2.9  Total investments proportions

    fg = figure('Name','fig_2.9_aggr_investment_proportions');
    fg.WindowState = 'fullscreen';
    sgtitle('--------- INVESTMENT PROPORTIONS AT THE ECONOMY-WIDE LEVEL ---------', 'FontSize', 22, 'fontweight', 'bold', 'Color', 'black');

    % Array to be used when linking axes
    linkaxes_array = [];
            

    % Nr of columns and rows in displaying the subplots
    nr_columns = 2;
    nr_rows = ceil(nr_simulations / nr_columns);
    
    for i = 1 : nr_simulations
        
        investment_proportions = Data.aggr_investments_in_each_asset_nominal(:,:,i) ./ sum(Data.aggr_investments_in_each_asset_nominal(:,:,i));

        figsp{i} = subplot(nr_rows, nr_columns, i);
        hold on
        plot(100 * investment_proportions(Parameters.Sections.idx_capital_assets, :)', 'LineWidth', my_line_width_little);        
        % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
        if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
            xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
        end
        hold off
        ytickformat("percentage");
        title(sprintf('%s', string(simulations_names(i))), 'FontSize', my_gca_fontsize_little);
        xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);        
        legend(Parameters.Sections.names(Parameters.Sections.idx_capital_assets), 'Location', 'best', 'FontSize', my_legend_fontsize_little);
        set(gca,'fontsize', my_gca_fontsize);
        set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    
        linkaxes_array = [linkaxes_array figsp{i}];
    end
    
    linkaxes(linkaxes_array,'y')
    
     
%% %%%%%%%%%    SECTIONAL, SECTORAL, and DIVISIONAL PLOTS   %%%%%%%%%%%
    %% 3.1  Prices
    
    fg = figure('Name','fig_3.1_prices');
    fg.WindowState = 'fullscreen';
    sgtitle(sprintf('--------- PRICES - %s scale ---------', y_scale_metrics), 'FontSize', 22, 'fontweight', 'bold', 'Color', 'black');            
    
    % figure's subplots names
    figsp = cell(1, nr_simulations);
    
    % Array to be used when linking axes
    linkaxes_array = [];

    % Nr of columns and rows in displaying the subplots
    nr_columns = 2;
    nr_rows = ceil(nr_simulations / nr_columns);
    
    for k = 1 : nr_simulations
        figsp{k} = subplot(nr_rows, nr_columns, k);
        hold on
        my_field = sprintf('sectional_prices_sim_%d', k);
        my_data = Data.(my_field);
        plot(my_data, 'LineWidth', 2);        
        figsp{k}.LineStyleOrder = my_lines_styles; 
        figsp{k}.ColorOrder = my_colors_sections;      
        % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
        if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
            xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
        end
        hold off            
        xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
        title(sprintf('%s', string(simulations_names(k))), 'FontSize', 14); 
        clickableLegend(Parameters.Sections.names, 'Location', 'best', 'FontSize', 14);            
        set(gca,'fontsize', my_gca_fontsize_little, 'yscale', y_scale_metrics);
        set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    
        linkaxes_array = [linkaxes_array figsp{k}];
    
    end
        
    linkaxes(linkaxes_array,'y') 
    
    clear my_field my_plot
    
    
    %% 3.2  Sectors' deflated investment costs
    
    fg = figure('Name','fig_3.2_sectors_deflated_investment_costs');
    fg.WindowState = 'fullscreen';
    sgtitle('--------- SECTORS'' DEFLATED INVESTMENT COSTS ---------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');

    % figure's subplots names
    figsp = cell(1, nr_simulations);

    % Array to be used when linking axes
    linkaxes_array = [];          

    y_scale_metrics = 'linear';
    x_axis_ticks_interval = 1;
    
    for i = 1 : nr_simulations
        
        %figsp{i} = subplot(2, 2, i);
        figure;
        
        my_field = sprintf('sectors_deflated_investment_sim_%d', i);
        my_plot = Data.(my_field);
        plot(my_plot, 'LineWidth', my_line_width_little);

        % figsp{i}.LineStyleOrder = my_lines_styles; 
        % figsp{i}.ColorOrder = my_colors_sectors;  
        linestyleorder(my_lines_styles, "aftercolor");
        colororder(my_colors_sectors);        

        % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
        if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
            xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
        end
        
        title(sprintf('%s - %s scale', string(simulations_names(i)), y_scale_metrics), 'FontSize', 14);
        xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
        clickableLegend(Parameters.Sectors.names, 'Location', 'best', 'FontSize', my_legend_fontsize_little);
        set(gca,'fontsize', my_gca_fontsize_little, 'yscale', y_scale_metrics);
        set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    
        linkaxes_array = [linkaxes_array figsp{i}];
    end
    
    %linkaxes(linkaxes_array, 'y')  
    
    clear my_field my_plot
    
    
    %% 3.3  Sectoral production capacity
    
    if nr_simulations <= 2
        fg = figure('Name','fig_3.3_production_limits_comparison');
        fg.WindowState = 'fullscreen';
        ax = axes;
        my_colors_production_limits = turbo(Parameters.Sectors.nr);
        ax.ColorOrder = my_colors_production_limits;
        hold on
        plot_sim_1 = plot(Data.sectors_production_capacity_sim_1', 'LineWidth', 2);
        plot_sim_2 = plot(Data.sectors_production_capacity_sim_2', '--', 'LineWidth', 2);
        %plot_sim_3 = plot(Data.sectors_production_capacity_sim_3', ':', 'LineWidth', 2);
        % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
        if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
            xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
        end
        hold off
        title('PRODUCTION CAPACITY (log scale) \newline NT = continuous line; NetZero = discontinuous line', 'FontSize', 14); 
        xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
        xlabel(my_x_axis_label);
        clickableLegend(Parameters.Sectors.names, 'Location', 'best', 'FontSize', 15);
        set(gca,'fontsize', my_gca_fontsize);
        set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
        set(gca, 'yscale', 'log');
        
        % extract the handles that require legend entries
        %hleglines = [plot_sim_1   plot_sim_2(end)];
        % create the legend
        %hleg = legend(hleglines, 'NT', 'Net Zero', 'Location','northwest', 'FontSize', my_legend_fontsize);
        
        %text_1 = '-- NT \newline - - Net Zero';
        %text(5, 10e12, text_1, 'Interpreter', 'Tex', 'FontSize', 15, 'Color', 'k');
    
    end
    
    
    %% 3.4  Sectional constraints in the supply of goods..
        %% 3.4.1 ..to expected final demand
    
        fg = figure('Name','fig_3.4.1_sectional_constraints_in_supply_to_exp_final_demand_comparison');
        fg.WindowState = 'fullscreen';
        sgtitle('--------- SECTIONAL CONSTRAINTS (values < 1) IN SUPPLY OF GOODS TO EXPECTED FINAL DEMAND ---------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
    
        threshold_value = ones(Parameters.valid_results_time_span_length, 1);
    
        % figure's subplots names
        figsp = cell(1, nr_simulations);
    
        % Array to be used when linking axes
        linkaxes_array = [];
        
        for k = 1 : nr_simulations
            figsp{k} = subplot(1, nr_simulations, k);
            hold on
            my_field = sprintf('sectional_supply_constraints_to_exp_final_demand_sim_%d', k);
            my_plot = Data.(my_field);
            for i = 1 : Parameters.Sections.nr
                plot(my_plot(i,:)', 'LineWidth', 20-(i+1.6));
            end
            figsp{k}.LineStyleOrder = my_lines_styles; 
            figsp{k}.ColorOrder = my_colors_sections;
            b = plot(threshold_value, 'LineWidth', 10, 'Color', 'black', 'LineStyle', '-');
            % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
            if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
                xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
            end
            hold off    
            xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
            title(sprintf('%s - %s scale', string(simulations_names(k)), y_scale_metrics_constraints_plots), 'FontSize', 14); 
            legend_text_sectors_with_threshold = [Parameters.Sections.names; 'THRESHOLD'];
            legend(legend_text_sectors_with_threshold, 'Location', 'best', 'FontSize', 15);            
            set(gca,'fontsize', 15, 'yscale', y_scale_metrics_constraints_plots);
            set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
            uistack(b,'bottom') % puts line from plot b in the background
    
            linkaxes_array = [linkaxes_array figsp{k}];
    
        end
            
        linkaxes(linkaxes_array,'y') 
    
        clear my_field my_plot
        
        
        %% 3.4.2 ..to final demand buyers
    
        fg = figure('Name','fig_3.4.2_sectional_constraints_in_supply_to_final_demand_comparison');
        fg.WindowState = 'fullscreen';
        sgtitle('--------- SECTIONAL CONSTRAINTS (values < 1) IN SUPPLY OF GOODS TO FINAL DEMAND ---------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
    
        threshold_value = ones(Parameters.valid_results_time_span_length, 1);
    
        % figure's subplots names
        figsp = cell(1, nr_simulations);
    
        % Array to be used when linking axes
        linkaxes_array = [];
        
        for k = 1 : nr_simulations
            figsp{k} = subplot(1, nr_simulations, k);
            hold on
            my_field = sprintf('sectional_supply_constraints_to_final_demand_sim_%d', k);
            plot(Data.(my_field)', 'LineWidth', 2);
            figsp{k}.LineStyleOrder = my_lines_styles; 
            figsp{k}.ColorOrder = my_colors_sections;
            b = plot(threshold_value, 'LineWidth', 3, 'Color', 'black', 'LineStyle', '-');
            hold off
            % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
            if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
                xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
            end
            xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
            title(sprintf('%s - %s scale', string(simulations_names(k)), y_scale_metrics_constraints_plots), 'FontSize', 14);                       
            clickableLegend([Parameters.Sections.names; 'THRESHOLD'], 'Location', 'best', 'FontSize', 15);
            set(gca,'fontsize', 15, 'yscale', y_scale_metrics_constraints_plots);
            set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
            uistack(b,'bottom') % puts line from plot b in the background
    
            linkaxes_array = [linkaxes_array figsp{k}];
        end
    
        linkaxes(linkaxes_array,'y')
    
    
        %% 3.4.3 ..used for investment by purchasers

        % Y-AXIS LIMITS
        % Without y-axis limits it may be the case that you cannot properly read the figure.
        % If you set the following rule to "with limits", then the y-axis will be limited to [0,1]
        y_limits_rule = "with limits";
        %y_limits_rule = "without limits";
    
        fg = figure('Name','fig_3.4.3_sectional_constraints_in_investment_supply_comparison');
        fg.WindowState = 'fullscreen';        
        if y_limits_rule == "with limits"
            sgtitle(sprintf('--------- SECTIONAL CONSTRAINTS (values < 1) IN SUPPLY OF GOODS TO INVESTING INDUSTRIES --------- \n \\color{red}!!! NOTE: y-axis limits have been applied to improve readibility !!!'), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
        else
            sgtitle('--------- SECTIONAL CONSTRAINTS (values < 1) IN SUPPLY OF GOODS TO INVESTING INDUSTRIES ---------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
        end

        threshold_value = ones(Parameters.valid_results_time_span_length, 1);
    
        % figure's subplots names
        figsp = cell(1, nr_simulations);
    
        % Array to be used when linking axes
        linkaxes_array = [];
        
        for k = 1 : nr_simulations
            figsp{k} = subplot(1, nr_simulations, k);
            hold on
            my_field = sprintf('investment_goods_supply_sectional_constraints_sim_%d', k);
            my_data = Data.(my_field);
            plot(my_data(Parameters.Sections.idx_capital_assets, :)', 'LineWidth', 2);
            figsp{k}.LineStyleOrder = my_lines_styles; 
            figsp{k}.ColorOrder = my_colors_sections;
            b = plot(threshold_value, 'LineWidth', 3, 'Color', 'black', 'LineStyle', '-');            
            % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
            if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
                xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
            end
            hold off
            if y_limits_rule == "with limits"                
                ylim([min(ylim) 1.1])
            end
            xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
            title(sprintf('%s - %s scale', string(simulations_names(k)), y_scale_metrics_constraints_plots), 'FontSize', 14);             
            legend_text_sectors_with_threshold = [Parameters.Sections.names(Parameters.Sections.idx_capital_assets); 'THRESHOLD'];
            legend(legend_text_sectors_with_threshold, 'Location', 'best', 'FontSize', 15);
            set(gca,'fontsize', 15, 'yscale', y_scale_metrics_constraints_plots);
            set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
            uistack(b,'bottom') % puts line from plot b in the background
        
            linkaxes_array = [linkaxes_array figsp{k}];
        end
    
        linkaxes(linkaxes_array,'y')


        %% 3.4.4 ..to households

        % Y-AXIS LIMITS
        % Without y-axis limits it may be the case that you cannot properly read the figure.
        % If you set the following rule to "with limits", then the y-axis will be limited to [0,1]
        y_limits_rule = "with limits";
        %y_limits_rule = "without limits";
    
        fg = figure('Name','fig_3.4.4_sectional_constraints_in_supply_to_hh_comparison');
        fg.WindowState = 'fullscreen';
        if y_limits_rule == "with limits"
            sgtitle(sprintf('--------- SECTIONAL CONSTRAINTS (values < 1) IN SUPPLY OF GOODS TO HOUSEHOLDS --------- \n \\color{red}!!! NOTE: y-axis limits have been applied to improve readibility !!!'), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
        else
            sgtitle('--------- SECTIONAL CONSTRAINTS (values < 1) IN SUPPLY OF GOODS TO HOUSEHOLDS ---------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
        end

        threshold_value = ones(Parameters.valid_results_time_span_length, 1);
    
        % figure's subplots names
        figsp = cell(1, nr_simulations);       

        % Array to be used when linking axes
        linkaxes_array = [];

        % There may be some products that the household does not demand. We want to exclude them from the figure.
        idx = Parameters.Households.exiobase_demand_relations_phys > 0;
        
        for k = 1 : nr_simulations
            figsp{k} = subplot(1, nr_simulations, k);
            hold on
            my_field = sprintf('sectional_supply_constraints_to_hh_demand_sim_%d', k);
            my_data = Data.(my_field);            
            plot(my_data(idx,:)', 'LineWidth', 2);
            figsp{k}.LineStyleOrder = my_lines_styles; 
            figsp{k}.ColorOrder = my_colors_sections;
            b = plot(threshold_value, 'LineWidth', 3, 'Color', 'black', 'LineStyle', '-');
            % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
            if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
                xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
            end
            hold off
            if y_limits_rule == "with limits"                
                ylim([min(ylim) 1.1])
            end
            xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
            title(sprintf('%s - %s scale', string(simulations_names(k)), y_scale_metrics_constraints_plots), 'FontSize', 14);                       
            clickableLegend([Parameters.Sections.names(idx); 'THRESHOLD'], 'Location', 'best', 'FontSize', 15);
            set(gca,'fontsize', 15, 'yscale', 'linear');
            set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
            uistack(b,'bottom') % puts line from plot b in the background
    
            linkaxes_array = [linkaxes_array figsp{k}];
        end
    
        linkaxes(linkaxes_array,'y')


        %% 3.4.5 ..to gov't

        % Y-AXIS LIMITS
        % Without y-axis limits it may be the case that you cannot properly read the figure.
        % If you set the following rule to "with limits", then the y-axis will be limited to [0,1]
        y_limits_rule = "with limits";
        %y_limits_rule = "without limits";
    
        fg = figure('Name','fig_3.4.5_sectional_constraints_in_supply_to_govt_comparison');
        fg.WindowState = 'fullscreen';
        if y_limits_rule == "with limits"
            sgtitle(sprintf('--------- SECTIONAL CONSTRAINTS (values < 1) IN SUPPLY OF GOODS TO GOV''T --------- \n \\color{red}!!! NOTE: y-axis limits have been applied to improve readibility !!!'), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
        else
            sgtitle('--------- SECTIONAL CONSTRAINTS (values < 1) IN SUPPLY OF GOODS TO GOV''T ---------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
        end

        threshold_value = ones(Parameters.valid_results_time_span_length, 1);
    
        % figure's subplots names
        figsp = cell(1, nr_simulations);       

        % Array to be used when linking axes
        linkaxes_array = [];

        % There may be some products that the gov't does not demand. We want to exclude them from the figure.
        idx = Parameters.Government.exiobase_demand_relations_phys > 0;
        
        for k = 1 : nr_simulations
            figsp{k} = subplot(1, nr_simulations, k);
            hold on
            my_field = sprintf('sectional_supply_constraints_to_govt_demand_sim_%d', k);
            my_data = Data.(my_field);
            plot(my_data(idx,:)', 'LineWidth', 2);
            figsp{k}.LineStyleOrder = my_lines_styles; 
            figsp{k}.ColorOrder = my_colors_sections;
            b = plot(threshold_value, 'LineWidth', 3, 'Color', 'black', 'LineStyle', '-');
            % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
            if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
                xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
            end
            hold off
            if y_limits_rule == "with limits"                
                ylim([min(ylim) 1.1])
            end
            xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
            title(sprintf('%s - %s scale', string(simulations_names(k)), y_scale_metrics_constraints_plots), 'FontSize', 14);                       
            clickableLegend([Parameters.Sections.names(idx); 'THRESHOLD'], 'Location', 'best', 'FontSize', 15);
            set(gca,'fontsize', 15, 'yscale', 'linear');
            set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
            uistack(b,'bottom') % puts line from plot b in the background
    
            linkaxes_array = [linkaxes_array figsp{k}];
        end
    
        linkaxes(linkaxes_array,'y')
    
    
    %% 3.5  Divisions' capacity accumulation rationing
    
    fg = figure('Name','fig_3.5_cap_accumulation_rationing');
    fg.WindowState = 'fullscreen';
    sgtitle('--------- Divisions'' capacity accumulation rationing ---------', 'FontSize', 22, 'fontweight', 'bold', 'Color', 'black');            
    
    % figure's subplots names
    figsp = cell(1, nr_simulations);
    
    % Array to be used when linking axes
    linkaxes_array = [];
    
    for k = 1 : nr_simulations
        figsp{k} = subplot(1, nr_simulations, k);
        hold on
        my_field = sprintf('divisions_capacity_accumulation_rationing_sim_%d', k);               
        plot(Data.(my_field), 'LineWidth', 2);
        figsp{k}.LineStyleOrder = my_lines_styles; 
        figsp{k}.ColorOrder = my_colors_divisions;   
        % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
        if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
            xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
        end
        hold off            
        xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
        title(sprintf('%s', string(simulations_names(k))), 'FontSize', 14); 
        legend(Parameters.Divisions.names, 'Location', 'best', 'FontSize', 14);            
        set(gca, 'fontsize', my_gca_fontsize_little, 'yscale', 'linear');
        set(gca, 'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    
        linkaxes_array = [linkaxes_array figsp{k}];
    
    end
        
    linkaxes(linkaxes_array,'y')
    
    clear my_field my_plot


    %% 3.6  NPV
    
    fg = figure('Name','fig_3.6_NPV');
    fg.WindowState = 'fullscreen';
    sgtitle('--------- Divisions with negative NPV ---------', 'FontSize', 22, 'fontweight', 'bold', 'Color', 'black');            
    
    % figure's subplots names
    figsp = cell(1, nr_simulations);
    
    % Array to be used when linking axes
    linkaxes_array = [];
    
    for k = 1 : nr_simulations
        figsp{k} = subplot(1, nr_simulations, k);
        hold on
        my_field = sprintf('divisions_NPV_sim_%d', k);
        divisions_NPV_sim_k = Data.(my_field);
        idx_divisions_with_negative_NPV = any(divisions_NPV_sim_k < 0);
        plot(divisions_NPV_sim_k(:, idx_divisions_with_negative_NPV), 'LineWidth', 2);
        figsp{k}.LineStyleOrder = my_lines_styles; 
        figsp{k}.ColorOrder = my_colors_divisions;     
        % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
        if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
            xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
        end
        hold off            
        xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
        title(sprintf('%s', string(simulations_names(k))), 'FontSize', 14); 
        legend(Parameters.Divisions.names(idx_divisions_with_negative_NPV), 'Location', 'best', 'FontSize', 14);            
        set(gca, 'fontsize', my_gca_fontsize_little, 'yscale', 'linear');
        set(gca, 'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    
        linkaxes_array = [linkaxes_array figsp{k}];
    
    end
        
    linkaxes(linkaxes_array,'y')
    
    clear my_field my_plot


    %% 3.7  Sectors' nominal production shares
    
    % Array to be used when linking axes
    linkaxes_array = [];
    
    
    fg = figure('Name','fig_3.7_sectors_nominal_shares');
    fg.WindowState = 'fullscreen';    
    sgtitle('--------- INDUSTRIES'' NOMINAL PRODUCTION SHARES ---------', 'FontSize', 22, 'fontweight', 'bold', 'Color', 'black');
    
    for i = 1 : nr_simulations
        figsp{i} = subplot(2, 2, i);
        hold on
        plot((Data.sectors_production_nominal(:,:,i) ./ sum(Data.sectors_production_nominal(:,:,i)))', 'LineWidth', my_line_width_little);
        ytickformat("percentage");
        % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
        if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
            xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
        end
        hold off
        figsp{i}.LineStyleOrder = my_lines_styles; 
        figsp{i}.ColorOrder = my_colors_sectors; 
        title(sprintf('%s', string(simulations_names(i))), 'FontSize', 14);
        xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
        clickableLegend(Parameters.Sectors.names,'Location','best', 'FontSize', my_legend_fontsize_little);
        set(gca,'fontsize', my_gca_fontsize_little);
        set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    
        linkaxes_array = [linkaxes_array figsp{i}];
    end
    
    linkaxes(linkaxes_array, 'y')    

        
%% %%%%%%%%%%%    GREEN VARIABLES PLOTS    %%%%%%%%%%%%%%
    %% 4.1  Green share
    
    fg = figure('Name','fig_4.1_green_share_comparison');
    fg.WindowState = 'fullscreen';
    colororder(my_colors_policy_exp);
    hold on
    plot(100 * Data.green_share_comparison, 'LineWidth', my_line_width);
    plot(100 * Data.green_share_target_comparison, 'LineWidth', my_line_width, 'LineStyle', '--');
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end
    hold off
    title('GREEN SHARE IN ELECTRICITY PRODUCTION', 'FontSize', 20);     
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
    %xlabel(my_x_axis_label);
    ytickformat("percentage");
    legend(simulations_names,'Location','northwest', 'FontSize', my_legend_fontsize);
    set(gca,'fontsize', my_gca_fontsize);
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);    
    
    
    %% 4.2  Electricity divisions weights
    
    %%%%%%%%%%%%  SECTORAL WEIGHTS  %%%%%%%%%%%%

    for i = 1 : nr_simulations

        fg = figure('Name', sprintf('fig_4.2.1.%d_electricity_sectoral_weights', i));
        %fg.WindowState = 'fullscreen';
        %sgtitle(sprintf('ELECTRICITY INDUSTRIES'' SECTORAL WEIGHTS \n %s', string(simulations_names(i))), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
        
        for j = 1 : numel(Parameters.Sectors.idx_electricity_producing)
            % We create one subplot for green industries, and one subplot for brown industries
            sbp = subplot(1,2,j);       
            hold on
            idx = Parameters.Divisions.sector_idx == Parameters.Sectors.idx_electricity_producing(j);            
            if Parameters.Sectors.names(Parameters.Sectors.idx_electricity_producing(j)) == "Green electricity"
                sbp.ColorOrder = parula(sum(idx)); % https://www.mathworks.com/help/matlab/ref/colormap.html#buc3wsn-6
            elseif Parameters.Sectors.names(Parameters.Sectors.idx_electricity_producing(j)) == "Brown electricity"
                sbp.ColorOrder = copper(sum(idx)); % https://www.mathworks.com/help/matlab/ref/colormap.html#buc3wsn-6
            end
            plot(100 * Data.divisions_sectoral_weights(:, idx, i), 'LineWidth', my_line_width);
            %plot(100 * Data.divisions_sectoral_target_weights(:, idx, i), 'LineWidth', my_line_width, 'LineStyle', '--');
            % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
            if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
                xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
            end
            hold off
            title(sprintf('%s industries', Parameters.Sectors.names(Parameters.Sectors.idx_electricity_producing(j))), 'FontSize', 20); 
            xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
            %xlabel(my_x_axis_label);
            ytickformat("percentage");
            legend(Parameters.Divisions.names(idx),'Location','northeast', 'FontSize', my_legend_fontsize);
            set(gca,'fontsize', my_gca_fontsize);
            set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
        end        

        % This command may be useful when exporting the figures for the paper as it allows you to set the height-width ratio
        % See also here: https://www.mathworks.com/help/matlab/ref/matlab.ui.figure-properties.html#d126e492262
        % set(gcf, 'Position', [0, 0, 1800, 700]);

    end

    
    
    
    %%%%%%%%%%%%  SECTIONAL WEIGHTS  %%%%%%%%%%%%
    
    % ONE FIGURE, MANY SUBLOTS
    fg = figure('Name', 'fig_4.2.2_electricity_sectional_weights');
    fg.WindowState = 'fullscreen';
    sgtitle('---------- WEIGHTS IN ELECTRICITY PRODUCTION ----------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
    
    for i = 1 : nr_simulations
                      
        subplot(2,2,i)
        colororder(turbo(numel(Parameters.Divisions.idx_electricity_producing)));
        hold on
        plot(100 * Data.divisions_sectional_weights(:, Parameters.Divisions.idx_electricity_producing, i), 'LineWidth', my_line_width_little);
        %plot(100 * Data.divisions_sectional_target_weights(:, Parameters.Divisions.idx_electricity_producing, i), 'LineWidth', my_line_width, 'LineStyle', '--');
        hold off
        % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
        if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
            xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
        end
        title(sprintf('%s', string(simulations_names(i))), 'FontSize', 20); 
        xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
        %xlabel(my_x_axis_label);
        ytickformat("percentage");
        clickableLegend(Parameters.Divisions.names(Parameters.Divisions.idx_electricity_producing),'Location','northwest', 'FontSize', my_legend_fontsize_little);
        set(gca,'fontsize', my_gca_fontsize_little);
        set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    
    end

    
    % % SEPARATE FIGURES
    % for i = 1 : nr_simulations
    % 
    %     fg = figure('Name', sprintf('fig_4.2.%d_electricity_weights', i));
    %     fg.WindowState = 'fullscreen';
    %     colororder(turbo(numel(Parameters.Divisions.idx_electricity_producing)));
    %     hold on
    %     plot(100 * Data.divisions_sectional_weights(:, Parameters.Divisions.idx_electricity_producing, i), 'LineWidth', my_line_width);
    %     %plot(100 * Data.divisions_sectional_target_weights(:, Parameters.Divisions.idx_electricity_producing, i), 'LineWidth', my_line_width, 'LineStyle', '--');
    %     % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
            % if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
            %     xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
            % end
    %       hold off
    %     title(sprintf('WEIGHTS IN ELECTRICITY PRODUCTION - %s', string(simulations_names(i))), 'FontSize', 20); 
    %     xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
    %     %xlabel(my_x_axis_label);
    %     ytickformat("percentage");
    %     clickableLegend(Parameters.Divisions.names(Parameters.Divisions.idx_electricity_producing),'Location','northwest', 'FontSize', my_legend_fontsize_little);
    %     set(gca,'fontsize', my_gca_fontsize_little);
    %     set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    % 
    % end
    
    
    %% 4.3  GHG emissions
    
    fg = figure('Name','fig_4.3_emissions');
    %fg.WindowState = 'maximized';    
    colororder(my_colors_policy_exp)   

    % Define the period to be shown on the plot
    period_to_be_plotted = 1 : end_of_transition_time_step;
    period_to_be_plotted = 1 : max(size(adjusted_emissions));
   
    plot(adjusted_emissions(period_to_be_plotted, :), 'LineWidth', my_line_width);    
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end
    %title(sprintf('EMISSIONS FLOW (Gt CO_2 eq.) - %s scale', y_scale_metrics), 'FontSize', 16);    
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);        
    legend(simulations_names,'Location','best', 'FontSize', my_legend_fontsize);
    set(gca,'fontsize', my_gca_fontsize, 'yscale', y_scale_metrics); 
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);     


    % This command may be useful when exporting the figures for the paper as it allows you to set the height-width ratio
    % See also here: https://www.mathworks.com/help/matlab/ref/matlab.ui.figure-properties.html#d126e492262
    % set(gcf, 'Position', [0, 0, 900, 700]);
    

    %% 4.4  Electricity production

    %%%% NOTE!!
    % Check the unit of measure, we might be using PWh instead of TWh


    fg = figure('Name','fig_4.4_electricity_production');
    %fg.WindowState = 'maximized';

    % We exclude the NT scenario since we are comparing Triode results with IEA projections
    Triode_scenarios_considered = 2:4; 
         
            
    hold on
    for i = 1 : numel(Triode_scenarios_considered)
        % Triode lines
        p1 = plot(adjusted_electricity_production_TWh(1 : end_of_transition_time_step, Triode_scenarios_considered(i)) ./ 1000, 'LineWidth', my_line_width, 'Color', my_colors_policy_exp(Triode_scenarios_considered(i), :));                
        % IEA lines
        p2 = plot(electricity_generation_IEA_long(:,i) ./ 1000, 'LineStyle', '--', 'LineWidth', my_line_width, 'Color', my_colors_policy_exp(Triode_scenarios_considered(i), :));            
    
        % Labelling the lines
        label(p1, sprintf('%s - our', simulations_names{Triode_scenarios_considered(i)}), 'location', 'center', 'slope', 'FontSize', 17);
        label(p2, sprintf('%s - IEA', simulations_names{Triode_scenarios_considered(i)}), 'location', 'center', 'slope', 'FontSize', 17);
    end
    hold off

    %title(sprintf('ELECTRICITY PRODUCTION (PWh) - comparison with IEA - %s', y_scale_metrics), 'FontSize', 16);     
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);    
    %ylabel("TWh");    

    set(gca,'fontsize', my_gca_fontsize, 'yscale', y_scale_metrics); 
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);


    % This command may be useful when exporting the figures for the paper as it allows you to set the height-width ratio
    % See also here: https://www.mathworks.com/help/matlab/ref/matlab.ui.figure-properties.html#d126e492262
    % set(gcf, 'Position', [0, 0, 900, 700]);

    
    %% 4.5  Emissions due to electricity
    
    fg = figure('Name','fig_4.5_emissions_due_to_electricity');
    fg.WindowState = 'fullscreen';
    colororder(my_colors_policy_exp)
    plot(100 * Data.emissions_flow_from_electricity_percentage_comparison, 'LineWidth', my_line_width); % I multiply by 100 because below I set the y-axis scale as percentage
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end
    title('RESPONSIBILITY OF ELECTRICITY PRODUCTION IN TOTAL EMISSIONS', 'FontSize', 16);     
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
    ytickformat("percentage");
    legend(simulations_names,'Location','best', 'FontSize', my_legend_fontsize);
    set(gca,'fontsize', my_gca_fontsize); 
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    
    
    %% 4.6  Green max production capacity
    
    fg = figure('Name','fig_4.6_green_max_prod_comparison');
    fg.WindowState = 'fullscreen';
    colororder(my_colors_policy_exp);
    % We convert the units of electricity in TWh         
    plot(Parameters.electricity_units_to_TWh * Data.green_max_production_comparison, 'LineWidth', my_line_width);
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end
    title('GREEN MAX PRODUCTION CAPACITY', 'FontSize', 20); 
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
    xlabel(my_x_axis_label);
    ylabel('TWh');
    legend(simulations_names,'Location','northwest', 'FontSize', my_legend_fontsize);
    set(gca,'fontsize', my_gca_fontsize, 'yscale', y_scale_metrics);
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    

    %% 4.7  Coefficients development

    % In these figures we want to show the development of those variables capturing the electrification process ..
    % .. i.e. technical coefficients and hh's demand relations.
    % Note that instead of showing the change for "Fossil fuels extraction", "Fossil fuels processing" (the change is the same in both cases),
    % "Electricity transmission", and "Electricity" (the change is the same in both cases), ..
    % .. we just show one fossil fuel and one electricity.

    %%%%%%%%%  HOUSEHOLD'S DEMAND RELATIONS  %%%%%%%%%
    
    fg = figure('Name','fig_4.7_hh_demand_relations_development');
    fg.WindowState = 'fullscreen';
    %sgtitle('---------- HOUSEHOLD''S DEMAND RELATIONS DEVELOPMENT ----------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
    
    % 1st subplot: fossil fuels
    subplot(1,2,1)    
    hold on    
    for i = 1 : nr_simulations
        plot(100 * Data.hhs_demand_relations_phys_percentage_change(Parameters.Sections.names == "Fossil fuels processing", :, i)',  'LineWidth', my_line_width, 'Color', my_colors_policy_exp(i,:));
    end    
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end
    hold off    
    ytickformat("percentage");
    title('Fossil fuels requirements', 'FontSize', my_gca_fontsize);     
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);    
    legend(simulations_names,'Location','best', 'FontSize', my_legend_fontsize);    
    set(gca,'fontsize', my_gca_fontsize);
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);

    % 2nd subplot: electricity
    subplot(1,2,2)    
    hold on    
    for i = 1 : nr_simulations
        plot(100 * Data.hhs_demand_relations_phys_percentage_change(Parameters.Sections.idx_electricity_producing, :, i)',  'LineWidth', my_line_width, 'Color', my_colors_policy_exp(i,:));
    end    
    % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
    if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
        xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
    end
    hold off    
    ytickformat("percentage");
    title('Electricity requirements', 'FontSize', my_gca_fontsize);     
    xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);    
    legend(simulations_names,'Location','best', 'FontSize', my_legend_fontsize);    
    set(gca,'fontsize', my_gca_fontsize);
    set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);

    % This command may be useful when exporting the figures for the paper as it allows you to set the height-width ratio
    % See also here: https://www.mathworks.com/help/matlab/ref/matlab.ui.figure-properties.html#d126e492262
    % set(gcf, 'Position', [0, 0, 1800, 700]);
    
    
    %%%%%%%%%  TECHNICAL COEFFICIENTS  %%%%%%%%%

    % In each of the following figures, we create subplots for each IEA category ..
    % ..included in the structure "Parameters.Divisions.IEAcategory.names" (energy intensive, non-energy intensive, etc).
    % Note that since we want to show the differences across scenarios, in each subplot we don't plot all Divisions belonging ..
    % ..to the respective IEA category (indeed such Divisions behave all the same in each scenario), ..
    % ..but we randomly choose one representative Division to be plotted.

    % FOSSIL FUELS
    fg = figure('Name','fig_4.6_fuels_coefficients_development');
    fg.WindowState = 'fullscreen';
    %sgtitle('Fossil fuels requirements', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
    linkaxes_array = []; % useful to link y-axes across subplots
    clear sbp % If variable "sbp" had already been defined elsewhere, we clear it
    my_fieldnames = fieldnames(Parameters.Divisions.IEAcategory.names);
    % Erase the "no_energy_transition" as we don't want to display it in the figure
    my_fieldnames(contains(my_fieldnames, 'no_energy_transition')) = [];
    for j = 1 : numel(my_fieldnames)
        sbp{j} = subplot(2,2,j);        
        sbp{j}.ColorOrder = my_colors_policy_exp;   
        idx_current_divisions = Parameters.Divisions.IEAcategory.idx.(my_fieldnames{j});    
        hold on        
        for k = 1 : nr_simulations
            my_field = sprintf('tech_coeff_perc_change_sim_%d', k);
            my_data = Data.(my_field);
            plot(squeeze(100 * my_data(Parameters.Sections.names == "Fossil fuels processing", idx_current_divisions(randi(numel(idx_current_divisions))), :)), 'LineWidth', my_line_width) % We randomly choose one Division to be plotted           
        end
        % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
        if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
            xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
        end
        hold off
        xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);    
        ytickformat("percentage");
        title(sprintf('%s', strrep(my_fieldnames{j}, '_', ' ')), 'FontSize', 15);
        legend(simulations_names,'Location','best', 'FontSize', my_legend_fontsize_little);
        set(gca,'fontsize', my_gca_fontsize_little);
        set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
        linkaxes_array = [linkaxes_array sbp{j}];
    end
    linkaxes(linkaxes_array, 'y')    


    % ELECTRICITY
    fg = figure('Name','fig_4.6_electricity_coefficients_development');
    fg.WindowState = 'fullscreen';
    %sgtitle('Electricity requirements', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');    
    clear sbp % If variable "sbp" had already been defined elsewhere, we clear it
    my_fieldnames = fieldnames(Parameters.Divisions.IEAcategory.names);
    % Erase the "no_energy_transition" as we don't want to display it in the figure
    my_fieldnames(contains(my_fieldnames, 'no_energy_transition')) = [];
    for j = 1 : numel(my_fieldnames)
        sbp{j} = subplot(2,2,j);        
        sbp{j}.ColorOrder = my_colors_policy_exp;   
        idx_current_divisions = Parameters.Divisions.IEAcategory.idx.(my_fieldnames{j});    
        hold on        
        for k = 1 : nr_simulations
            my_field = sprintf('tech_coeff_perc_change_sim_%d', k);
            my_data = Data.(my_field);
            plot(squeeze(100 * my_data(Parameters.Sections.idx_electricity_producing, idx_current_divisions(randi(numel(idx_current_divisions))), :)), 'LineWidth', my_line_width) % We randomly choose one Division to be plotted           
        end
        % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
        if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
            xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
        end
        hold off
        xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);    
        ytickformat("percentage");
        title(sprintf('%s', strrep(my_fieldnames{j}, '_', ' ')), 'FontSize', 15);
        legend(simulations_names,'Location','best', 'FontSize', my_legend_fontsize_little);
        set(gca,'fontsize', my_gca_fontsize_little);
        set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);        
    end    


%% %%%%%%%%%%%    OTHER PLOTS    %%%%%%%%%%%%%%
    %% 5.1  Bank: assets and liabilities
    
    legend_text_bank = [];
    legend_text_bank{1,1} = 'loans stock';
    legend_text_bank{1,2} = 'deposits';
    legend_text_bank{1,3} = 'central bank deposits';
    legend_text_bank{1,4} = 'central bank loans';
    legend_text_bank{1,5} = 'net worth';
    
    % Array to be used when linking axes
    linkaxes_array = [];
    
    
    fg = figure('Name','fig_5.1_bank_comparison');
    fg.WindowState = 'fullscreen';    
    sgtitle(sprintf('--------- BANK''S ASSETS AND LIABILITIES - %s scale ---------', y_scale_metrics), 'FontSize', 22, 'fontweight', 'bold', 'Color', 'black');
    
    for i = 1 : nr_simulations
        figsp{i} = subplot(1, nr_simulations, i);
        hold on
        plot(Data.bank_loans_stock(:,i), 'LineWidth', my_line_width_little);
        plot(Data.bank_deposits(:,i), 'LineWidth', my_line_width_little);
        plot(Data.bank_reserves_holdings(:,i), 'LineWidth', my_line_width_little);
        plot(Data.bank_advances(:,i), 'LineWidth', my_line_width_little);
        plot(Data.bank_net_worth(:,i), 'LineWidth', my_line_width_little);
        % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
        if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
            xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
        end
        hold off
        title(sprintf('%s', string(simulations_names(i))), 'FontSize', 14);
        xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
        legend(legend_text_bank,'Location','best', 'FontSize', my_legend_fontsize_little);
        set(gca,'fontsize', my_gca_fontsize_little, 'yscale', y_scale_metrics);
        set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    
        linkaxes_array = [linkaxes_array figsp{i}];
    end
    
    linkaxes(linkaxes_array, 'y')


    %% 5.2  Bank: ratios
    
    legend_text_bank_CAR = [];
    legend_text_bank_CAR{1,1} = 'CAR';    
    legend_text_bank_CAR{1,2} = 'CAR target'; 
    legend_text_bank_CAR{1,3} = 'capital requirement';      
    legend_text_bank_CAR{1,4} = 'loan rationing (< 1)';

    % Array to be used when linking axes
    linkaxes_array = [];
    
    
    fg = figure('Name','fig_5.2_bank_ratios_comparison');
    fg.WindowState = 'fullscreen';    
    sgtitle('--------- BANK''S RATIOS ---------', 'FontSize', 22, 'fontweight', 'bold', 'Color', 'black');
    
    for i = 1 : nr_simulations
        figsp{i} = subplot(1, nr_simulations, i);
        hold on
        plot(100 * Data.bank_CAR(:,i), 'LineWidth', 6);        
        plot(100 * Data.bank_CAR_target(:,i), 'LineWidth', my_line_width);
        plot(100 * Data.bank_capital_requirement(:,i), 'LineWidth', my_line_width_little);        
        plot(100 * Data.proportion_supply_vs_demanded_loans(:,i), 'LineWidth', my_line_width_little);     
        % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
        if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
            xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
        end
        hold off
        ytickformat("percentage");
        title(sprintf('%s', string(simulations_names(i))), 'FontSize', 14);
        xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
        legend(legend_text_bank_CAR,'Location','best', 'FontSize', my_legend_fontsize_little);
        set(gca,'fontsize', my_gca_fontsize_little);
        set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    
        linkaxes_array = [linkaxes_array figsp{i}];
    end
    
    linkaxes(linkaxes_array,'y')
    
    
    %% 5.3  Government

    legend_text_govt = [];
    legend_text_govt{1,1} = 'deficit-to-GDP ratio';
    legend_text_govt{1,2} = 'debt-to-GDP ratio';
    legend_text_govt{1,3} = 'tax rate';
    
    % Array to be used when linking axes
    linkaxes_array = [];
    
    
    fg = figure('Name','fig_5.3_government');
    fg.WindowState = 'fullscreen';    
    sgtitle('--------- GOVERNMENT ---------', 'FontSize', 22, 'fontweight', 'bold', 'Color', 'black');

    % Nr of columns and rows in displaying the subplots
    nr_columns = 2;
    nr_rows = ceil(nr_simulations / nr_columns);
    
    for i = 1 : nr_simulations
        figsp{i} = subplot(nr_rows, nr_columns, i);
        hold on
        plot(100 * Data.govt_deficit_to_GDP_ratio(:,i), 'LineWidth', my_line_width);
        plot(100 * Data.govt_debt_to_GDP_ratio(:,i), 'LineWidth', my_line_width);
        plot(100 * Data.tax_rate(:,i), 'LineWidth', my_line_width_little);
        % If at least one of our simulations is either STEPS, APS or NZE, we want to make a vertical line in the plot indicating the end of the energy transition
        if any(ismember(["STEPS" "APS" "NZE"], Variations.energy_transition_rule))
            xline(end_of_transition_time_step, '-.', 'LineWidth', 1)
        end
        hold off
        ytickformat("percentage");
        title(sprintf('%s', string(simulations_names(i))), 'FontSize', my_gca_fontsize_little);
        xticks(0 : x_axis_ticks_interval : Parameters.valid_results_time_span_length);
        legend(legend_text_govt, 'Location', 'best', 'FontSize', my_legend_fontsize);
        set(gca,'fontsize', my_gca_fontsize, 'yscale', 'linear');
        set(gca,'XTickLabel', initial_year : x_axis_ticks_interval : final_year);
    
        linkaxes_array = [linkaxes_array figsp{i}];
    end
    
    linkaxes(linkaxes_array,'y')
    

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%       SAVE FIGURES AND CLOSE      %%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% save all .FIG format
    
    % Make new folder where to store the figures
    folder_name = 'figures comparing simulations fig format';
    mkdir(folder_name);
    
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    for iFig = 1 : length(FigList)
      FigHandle = FigList(iFig);
      FigName   = get(FigHandle, 'Name');
      savefig(FigHandle, fullfile([folder_name, '/', FigName, '.fig']));
      %close
    end    
    
    
    %% save all .PDF format
    
    % Make new folder where to store the figures
    folder_name = 'figures comparing simulations pdf format';
    mkdir(folder_name);
    
    FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
    for iFig = 1 : length(FigList)
      FigHandle = FigList(iFig);
      FigName   = get(FigHandle, 'Name');      
      exportgraphics(gcf, fullfile([folder_name, '/', FigName, '.pdf']), 'ContentType', 'vector'); % specify the 'ContentType' as 'vector' (to ensure tightly cropped, scalable output)
      close      
    end
    
    
    %% close all
    
    close all
    %% SAVE DATA
    
    save('Triode_comparative_figures_data.mat', 'Data')

%end