% function Triode_g1_fig_1(Parameters, Sections, Sectors, Divisions, Bank, Households, CentralBank, Government, Economy,...
%    folder_name, figures_name)
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%  SETTINGS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Figures' settings

    % ASSIGN VALUES TO NON-EXISTING VARIABLES
    % These variables should be assigned through the function "Triode_g1_fig_1" ..
    % ..but it may sometimes happen that we are not using the function and thus we need to define them here.
    if ~exist('figures_name', 'var')
        figures_name = 'prova';
    end
    if ~exist('folder_name', 'var')
        folder_name = 'prova';
    end
    

    % € TO $ CONVERSION
    % When you want to show the values in million dollars instead of million euros, just multiply the values with this conversion factor:
    euro_to_dollars_conversion = 1.07; % this is the exchange rate in September 2023

    % METRICS (log or linear)
    % y_scale_metrics = 'linear'; 
    y_scale_metrics = 'log';
    
    
    %%%%%  FOR PLOTS WHERE EACH LINE REPRESENTS A SECTOR OR SECTION  %%%%%
    
    % LINES STYLES
    my_lines_styles = {'-', ':'};
    
    % COLORS FOR LINES
    % Choose your colormap among the ones listed here: https://www.mathworks.com/help/matlab/ref/colormap.html#buc3wsn-6
    % "turbo", "hsv", "jet", and "lines" are the best ones    
    my_colors_sections = turbo(ceil(Parameters.Sections.nr / numel(my_lines_styles))); % lines(ceil(Parameters.Sections.nr / numel(my_lines_styles)));
    my_colors_sectors = turbo(ceil(Parameters.Sectors.nr / numel(my_lines_styles))); % lines(ceil(Parameters.Sectors.nr / numel(my_lines_styles)));
    my_colors_divisions = turbo(ceil(Parameters.Divisions.nr / numel(my_lines_styles))); % lines(ceil(Parameters.Divisions.nr / numel(my_lines_styles))); 
    my_colors_electricity_divisions = turbo(ceil(numel(Parameters.Divisions.idx_electricity_producing)));
    
    
    %%%%%  FOR PLOTS WHERE EACH SUBPLOT REFERS TO A SECTOR OR SECTION  %%%%%
    
    % When we have a large number of sectors or sections (e.g. more than 8), and we want each subplot to be referring to a specific sector or section,..
    % ..it implies that we'll have more than 8 subplots --> so we may need more than 1 figure to contain all those subplots.
        
    % Number of rows in each figure
    nr_rows = 2;
    % Number of columns in each figure
    nr_columns = 4;
    % Max number of subplots in each figure
    max_nr_subplots_per_figure = nr_rows * nr_columns;
    % Total implied number of figures needed when plotting sectoral data
    nr_figures_for_sectoral_subplots = ceil(Parameters.Sectors.nr / max_nr_subplots_per_figure);
    % Total implied number of figures needed when plotting divisional data
    nr_figures_for_divisional_subplots = ceil(Parameters.Divisions.nr / max_nr_subplots_per_figure);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%  MACROECONOMIC PLOTS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% 0.0    GDP
    
    figure('Name', sprintf('%s_0.0_gdp', figures_name));    
    
    
    %%%%%%%%%%%%  REAL GDP  %%%%%%%%%%%%
    
    % maybe you need to correct the time of prices here: nominal_sales_plus_inventories = Economy.sales_to_final_demand_nominal + sum([Sectors.inventories_phys(:,:) .* Sectors.prices(:,:)'], 'omitnan');
    legend_text = [];
    legend_text{1,1} = 'level';
    legend_text{1,2} = 'growth rate (GR)';
    legend_text{1,3} = 'average GR';
    legend_text{1,4} = 'compound GR';
    
    subplot(1,2,1); 
    hold on
    yyaxis left
    plot(Economy.GDP_real, 'LineWidth', 2);
    set(gca, 'yscale', y_scale_metrics);
    yyaxis right
    plot(Economy.GDP_real_growth_rate, 'LineWidth', 1);
    plot(repmat(Economy.average_GDP_real_growth_rate, Parameters.T, 1), 'LineStyle', '--', 'LineWidth', 1);
    plot(repmat(Economy.compound_GDP_real_growth_rate, Parameters.T, 1), 'LineStyle', ':', 'LineWidth', 1);
    hold off
    %xlim([1 Parameters.T]);
    %xticks(0:10:Parameters.T);
    title(sprintf('REAL GDP (%s scale)', y_scale_metrics), 'FontSize', 16);
    legend(legend_text,'Location','best', 'FontSize', 14);
    set(gca,'fontsize', 15);
    clear legend_text



    %%%%%%%%%%%%  NOMINAL GDP  %%%%%%%%%%%%

    legend_text_nominal_GDP = [];
    legend_text_nominal_GDP{1,1} = 'sum of value added';
    legend_text_nominal_GDP{1,2} = 'sum of sales to final demand';
    legend_text_nominal_GDP{1,3} = 'sum of incomes and taxes';
    legend_text_nominal_GDP{1,4} = 'growth rate (right axis)';
    
    subplot(1,2,2); 
    hold on
    %yyaxis left
    plot(Economy.GDP_nominal, 'LineWidth', 8);
    plot(Economy.sales_to_final_demand_nominal, 'LineWidth', 4);
    plot(Economy.total_income, 'LineWidth', 2);
    set(gca, 'yscale', y_scale_metrics);
    yyaxis right
    plot(Economy.GDP_nominal_growth_rate, 'LineWidth', 2);
    hold off
    title(sprintf('NOMINAL GDP (%s scale)', y_scale_metrics), 'FontSize', 16);
    legend(legend_text_nominal_GDP,'Location','best', 'FontSize', 14);
    set(gca,'fontsize', 15);
    clear legend_text_nominal_GDP
    
    
    %% 0.1  expected final demand

    figure('Name', sprintf('%s_0.1_exp_final_demand', figures_name));
    

    %%%%%%%%%%%%  EXPECTED REAL (DEFLATED) FINAL DEMAND  %%%%%%%%%%%%      
    
    % Legend
    legend_exp_demand = [];
    legend_exp_demand{1,1} = 'households';
    legend_exp_demand{1,2} = 'investing sectors';
    legend_exp_demand{1,3} = 'government';
    %legend_exp_demand{1,4} = 'total';
        
    x = 1 : Parameters.T;
    hold on
    % NOTE: here we use "x+1" for the hh demand, because we want to plot EXPECTED demand!
    plot(x+1, Economy.hhs_demand_defl, 'LineWidth', 2);
    plot(Economy.current_investment_demand_defl, 'LineWidth', 2);
    plot(Economy.current_govt_demand_defl, 'LineWidth', 2);
    % plot(sum(Sections.final_demand_phys_exp), 'LineWidth', 2);
    hold off
    xlim([1 Parameters.T]);
    title(sprintf('EXPECTED REAL (DEFLATED) FINAL DEMAND (%s scale)', y_scale_metrics), 'FontSize', 15);
    legend(legend_exp_demand, 'Location', 'best', 'FontSize', 12);
    set(gca,'fontsize', 13);
    set(gca, 'yscale', y_scale_metrics);
    clear legend_exp_demand    
    
    
    %% 0.2.1  final demand and sales / levels

    figure('Name', sprintf('%s_0.2.1_final_demand_levels', figures_name));        
    
    legend_text_2 = [];
    legend_text_2{1,1} = 'households'' demand';
    legend_text_2{1,2} = 'households'' consumption';
    legend_text_2{1,3} = 'investment demand';
    legend_text_2{1,4} = 'investment realized';
    legend_text_2{1,5} = 'government''s demand';
    legend_text_2{1,6} = 'government''s consumption';
        
    hold on   
    plot(Economy.hhs_demand_defl, 'LineWidth', 2, 'Color', "#0072BD", 'LineStyle', ':');
    plot(Economy.hhs_consumption_defl, 'LineWidth', 2, 'Color', "#0072BD");    
    plot(Economy.current_investment_demand_defl, 'LineWidth', 2, 'Color', "#D95319", 'LineStyle', ':');
    plot(Economy.investment_defl, 'LineWidth', 2, 'Color', "#D95319");    
    plot(Economy.current_govt_demand_defl, 'LineWidth', 2, 'Color', "#EDB120", 'LineStyle', ':');
    plot(Economy.govt_consumption_defl, 'LineWidth', 2, 'Color', "#EDB120");
    hold off
    xlim([1 Parameters.T]);
    title(sprintf('REAL (DEFLATED) FINAL DEMANDS & PURCHASES (%s scale)', y_scale_metrics), 'FontSize', 18);
    %xticks(0:10:Parameters.T);
    legend(legend_text_2,'Location','best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);
    clear legend_text_2
    
    
    %% 0.2.2  final demand and sales / percentages
    
    figure('Name', sprintf('%s_0.2.2_final_demand_percentages', figures_name));
    sgtitle('--------- COMPOSITION PERCENTAGES OF TOTAL DEFLATED DEMAND AND TOTAL DEFLATED SALES ---------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
    
    legend_text = [];
    legend_text{1,1} = 'household';
    legend_text{1,2} = 'investment';
    legend_text{1,3} = 'government';

    line_style_current_plot = ':';
    
    
    % DEMAND    
    subplot(1,2,1); 
    hold on    
    plot(100 * Economy.hhs_demand_defl ./ Economy.final_demand_defl, 'LineWidth', 2, 'LineStyle', line_style_current_plot);
    plot(100 * Economy.current_investment_demand_defl ./ Economy.final_demand_defl, 'LineWidth', 2, 'LineStyle', line_style_current_plot);
    plot(100 * Economy.current_govt_demand_defl ./ Economy.final_demand_defl, 'LineWidth', 2, 'LineStyle', line_style_current_plot);
    hold off
    ytickformat("percentage");
    title('DEMAND', 'FontSize', 16);
    legend(legend_text,'Location','best', 'FontSize', 14);
    set(gca,'fontsize', 15);


    % SALES    
    subplot(1,2,2); 
    hold on    
    plot(100 * Economy.hhs_consumption_defl ./ Economy.tot_sales_to_final_demand_defl, 'LineWidth', 2, 'LineStyle', line_style_current_plot);
    plot(100 * Economy.investment_defl ./ Economy.tot_sales_to_final_demand_defl, 'LineWidth', 2, 'LineStyle', line_style_current_plot);
    plot(100 * Economy.govt_consumption_defl ./ Economy.tot_sales_to_final_demand_defl, 'LineWidth', 2, 'LineStyle', line_style_current_plot);
    hold off
    ytickformat("percentage");
    title('SALES', 'FontSize', 16);
    legend(legend_text,'Location','best', 'FontSize', 14);
    set(gca,'fontsize', 15);


    %% 0.3  consumption basket units demand

    figure('Name', sprintf('%s_0.3_cons_basket_units_demand', figures_name));        
    
    % Legend
    my_legend = [];
    my_legend{1,1} = 'households';    
    my_legend{1,2} = 'government';    
        
    x = 1 : Parameters.T;
    hold on
    plot(Households.consumption_basket_units_demanded, 'LineWidth', 2);        
    plot(x+1, Government.consumption_basket_units_demanded_in1year, 'LineWidth', 2);    
    hold off
    xlim([1 Parameters.T]);
    title(sprintf('CONSUMPTION BASKET UNITS DEMANDED (%s scale)', y_scale_metrics), 'FontSize', 15);
    legend(my_legend, 'Location', 'best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);
    clear my_legend
    

    %% 0.4  final demand rationing
    
    figure('Name', sprintf('%s_0.4_final_demand_rationing', figures_name));
        

    % % tot_inventories_defl = ...
    % %     sum(Sectors.inventories_nominal)' ./ Economy.GDP_deflator;
    % 
    % legend_text_3 = [];
    % legend_text_3{1,1} = 'final demand';    
    % legend_text_3{1,2} = 'final sales';
    % %legend_text_3{1,3} = 'inventories';
    % 
    % subplot(1,2,1);
    % hold on
    % 
    % plot(Economy.final_demand_defl, 'LineWidth',2);    
    % plot(Economy.tot_sales_to_final_demand_defl, 'LineWidth', 2);
    % %plot(tot_inventories_defl, 'LineWidth', 2);            
    % hold off    
    % title(sprintf('TOTAL REAL (DEFLATED) FINAL DEMAND, SALES & INVENTORIES (%s scale)', y_scale_metrics), 'FontSize', 15);
    % xlim([1 Parameters.T]);
    % %xticks(0:10:Parameters.T);
    % set(gca, 'yscale', y_scale_metrics);
    % legend(legend_text_3,'Location','best', 'FontSize', 12);
    % set(gca,'fontsize', 13);    
    % clear legend_text_3

    legend_final_demand_rationing = [];
    legend_final_demand_rationing{1,1} = 'values';
    legend_final_demand_rationing{1,2} = 'average value';

    %subplot(1,2,2);
    hold on
    plot(Economy.final_demand_rationing, 'LineWidth', 2);
    plot(repmat(Economy.average_final_demand_rationing, Parameters.T, 1), 'LineStyle', ':', 'LineWidth', 3);
    hold off
    title('FINAL DEMAND RATIONING (= sales / demand)', 'FontSize', 15);
    legend(legend_final_demand_rationing, 'Location', 'best', 'FontSize', 15);
    set(gca,'fontsize', 17);
        
    
    %% 0.5  total capital stocks

    figure('Name', sprintf('%s_0.5_total_capital_stocks', figures_name));
    sgtitle('---------- OVERALL CAPITAL STOCKS (SUMMED ACROSS SECTORS) ----------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
    
    % PHYSICAL    
    subplot(1,2,1);
    plot(Economy.capital_stocks_phys(Parameters.Sections.idx_capital_assets, :)', 'LineWidth', 2);    
    title(sprintf('PHYSICAL (%s scale)', y_scale_metrics), 'FontSize', 16);
    legend(Parameters.Sections.names(Parameters.Sections.idx_capital_assets),'Location','best', 'FontSize', 15);    
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);
    
    
    % NOMINAL    
    subplot(1,2,2);        
    plot(Economy.capital_stocks_nominal(Parameters.Sections.idx_capital_assets, :)', 'LineWidth', 2);
    title(sprintf('NOMINAL (%s scale)', y_scale_metrics), 'FontSize', 16);
    legend(Parameters.Sections.names(Parameters.Sections.idx_capital_assets),'Location','best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);


    %% 0.6  inflation
    
    figure('Name', sprintf('%s_0.6_inflation', figures_name));
    
    
    % PRICE LEVELS
    
    subplot(1,2,1);
    
    legend_price_level = [];
    legend_price_level{1,1} = 'CPI';
    legend_price_level{1,2} = 'GDP deflator';
    
    hold on
    plot(Economy.CPI, 'LineWidth', 2);
    plot(100 * Economy.GDP_deflator, 'LineWidth', 2);
    hold off
    title(sprintf('PRICE LEVELS (%s scale)', y_scale_metrics), 'FontSize', 16);
    legend(legend_price_level, 'Location', 'best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);
    
    
    % INFLATION RATES
    
    subplot(1,2,2);
    
    legend_inflation = [];
    legend_inflation{1,1} = 'CPI growth rate (GR)';
    legend_inflation{1,2} = 'average CPI GR';
    legend_inflation{1,3} = 'compound CPI GR';
    legend_inflation{1,4} = 'GDP deflator GR';
    legend_inflation{1,5} = 'average deflator GR';
    legend_inflation{1,6} = 'compound deflator GR';
    
    hold on
    plot(Economy.CPI_inflation, 'LineWidth', 2, 'Color', "#0072BD");
    plot(repmat(Economy.average_CPI_inflation, Parameters.T, 1), 'LineStyle', '--', 'LineWidth', 2, 'Color', "#0072BD");
    plot(repmat(Economy.compound_CPI_inflation, Parameters.T, 1), 'LineStyle', ':', 'LineWidth', 2, 'Color', "#0072BD");
    plot(Economy.GDP_deflator_inflation, 'LineWidth', 2, 'Color', "#D95319");
    plot(repmat(Economy.average_GDP_deflator_inflation, Parameters.T, 1), 'LineStyle', '--', 'LineWidth', 2, 'Color', "#D95319");
    plot(repmat(Economy.compound_GDP_deflator_inflation, Parameters.T, 1), 'LineStyle', ':', 'LineWidth', 2, 'Color', "#D95319");
    hold off
    title('INFLATION RATES', 'FontSize', 16);
    legend(legend_inflation, 'Location', 'best', 'FontSize', 15);
    set(gca,'fontsize', 15);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%  SECTIONAL, SECTORAL, and DIVISIONAL PLOTS  %%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PRODUCTION & FINAL DEMAND
    %% 1.0.1  physical and nominal production
    
    %%%%%%%%%%%   ON SAME FIGURE   %%%%%%%%%%%
    figure('Name', sprintf('%s_1.0.1_sectors_production', figures_name));
    
    % PHYSICAL
    sbp = subplot(1,2,1); 
    plot(Sectors.production_phys', 'LineWidth', 3); 
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sectors;
    title(sprintf('TOTAL PHYSICAL PRODUCTION (%s scale)', y_scale_metrics), 'FontSize', 20);
    clickableLegend(Parameters.Sectors.names,'Location','best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);
    
    % NOMINAL
    sbp = subplot(1,2,2); 
    plot(Sectors.production_nominal', 'LineWidth', 3); 
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sectors;
    title(sprintf('TOTAL NOMINAL PRODUCTION (%s scale)', y_scale_metrics), 'FontSize', 20);
    clickableLegend(Parameters.Sectors.names,'Location','best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);
    
    
    
    %%%%%%%%%%%   ON DIFFERENT FIGURES   %%%%%%%%%%%
    
    % % SECTORS' TOTAL PHYSICAL PRODUCTION
    % 
    % figure('Name', sprintf('%s_1.0.1.1_sectors_physical_production', figures_name));
    % 
    % ax = axes(); 
    % plot(Sectors.production_phys', 'LineWidth', 3);    
    % ax.LineStyleOrder = my_lines_styles; 
    % ax.ColorOrder = my_colors_sectors;
    % 
    % title('TOTAL PHYSICAL PRODUCTION', 'FontSize', 20);
    % clickableLegend(Parameters.Sectors.names,'Location','best', 'FontSize', 15);
    % set(gca,'fontsize', 13);
    % 
    % 
    % % SECTORS' TOTAL NOMINAL PRODUCTION
    % 
    % figure('Name', spritf('%s_1.0.1.2_sectors_nominal_production', figures_name));
    % 
    % ax = axes(); 
    % plot(Sectors.production_nominal', 'LineWidth', 3);
    % ax.LineStyleOrder = my_lines_styles; 
    % ax.ColorOrder = my_colors_sectors;
    % 
    % title('TOTAL NOMINAL PRODUCTION', 'FontSize', 20);
    % clickableLegend(Parameters.Sectors.names,'Location','best', 'FontSize', 15);
    % set(gca,'fontsize', 13);


    %% 1.0.2  physical final demand
    % .. at the sectional level

    figure('Name', sprintf('%s_1.0.2_final_demand', figures_name));
    sgtitle(sprintf('--------- SECTIONAL PHYSICAL FINAL DEMAND .. - %s scale ---------', y_scale_metrics), 'FontSize', 22, 'fontweight', 'bold', 'Color', 'black');            
    
    if Rules.govt_demand == "no"
        nr_subplots = 2;
    else
        nr_subplots = 3;
    end

    % HOUSEHOLD DEMAND
    sbp1 = subplot(1, nr_subplots, 1);   
    data = reshape(sum(Sections.demand_from_hhs_phys, 2), Parameters.Sections.nr, Parameters.T)';
    idx = Parameters.Households.exiobase_demand_relations_phys > 0;
    plot(data(:,idx), 'LineWidth', 3); 
    sbp1.LineStyleOrder = my_lines_styles; 
    sbp1.ColorOrder = my_colors_sections;
    title('..FROM HOUSEHOLDS', 'FontSize', 20);
    clickableLegend(Parameters.Sections.names(idx), 'Location', 'best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);


    % FINAL DEMAND FROM INVESTING SECTORS
    sbp2 = subplot(1, nr_subplots, 2);   
    final_demand_from_investment = reshape(sum(Sections.demand_in1year_from_invest_divisions_adj_after_loans_phys, 2), Parameters.Sections.nr, Parameters.T)';
    plot(final_demand_from_investment(:, Parameters.Sections.idx_capital_assets), 'LineWidth', 3); 
    sbp2.LineStyleOrder = my_lines_styles;
    sbp2.ColorOrder = my_colors_sections;
    title('..FROM INVESTING DIVISIONS', 'FontSize', 20);
    clickableLegend(Parameters.Sections.names(Parameters.Sections.idx_capital_assets), 'Location', 'best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);


    % GOV'T DEMAND
    if Rules.govt_demand ~= "no"
        sbp3 = subplot(1, nr_subplots, 3);       
        idx = Parameters.Government.exiobase_demand_relations_phys > 0;
        plot(Sections.demand_in1year_from_govt_phys(idx,:)', 'LineWidth', 3); 
        sbp3.LineStyleOrder = my_lines_styles; 
        sbp3.ColorOrder = my_colors_sections;
        title('..FROM GOV''T', 'FontSize', 20);
        clickableLegend(Parameters.Sections.names(idx), 'Location', 'best', 'FontSize', 15);
        set(gca,'fontsize', 15);
        set(gca, 'yscale', y_scale_metrics);
    end

    % Set the y-axis limits of the two subplots to be equal
    if Rules.govt_demand == "no"
        linkaxes([sbp1 sbp2],'y')
    else
        linkaxes([sbp1 sbp2 sbp3],'y')
    end
    
    
    %% 1.0.3  physical and nominal sales to final demand / totals
    % .. at the sectional level

    figure('Name', sprintf('%s_1.0.3_sales_to_final_demand', figures_name));
    
    % PHYSICAL
    sbp = subplot(1,2,1); 
    plot(Sections.sales_to_final_demand_phys', 'LineWidth', 3); 
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sections;
    title(sprintf('SECTIONAL PHYSICAL SALES TO FINAL DEMAND (%s scale)', y_scale_metrics), 'FontSize', 20);
    clickableLegend(Parameters.Sections.names,'Location','best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);
    
    % NOMINAL
    sbp = subplot(1,2,2); 
    plot(Sections.sales_to_final_demand_nominal', 'LineWidth', 3); 
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sections;
    title(sprintf('SECTIONAL NOMINAL SALES TO FINAL DEMAND (%s scale)', y_scale_metrics), 'FontSize', 20);
    clickableLegend(Parameters.Sections.names,'Location','best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);    


    %% 1.0.4.1  final demand / version 1
    
    % Version 1: the investment lines show investment demand.
    
    % For each sector, we make a plot showing: 
        % its total final demand
        % its final demand components (from hhs, investing sectors, gov't) 
        % products available for sale to final demand
        % and total sales to final demand sectors.
    
    % Legend
    legend_text_final_demands = [];
    legend_text_final_demands{1,1} = 'tot';
    legend_text_final_demands{1,2} = 'available';
    legend_text_final_demands{1,3} = 'hhs';
    legend_text_final_demands{1,4} = 'invest';
    legend_text_final_demands{1,5} = 'gov';
    legend_text_final_demands{1,6} = 'sales';
    
    
    for f = 1 : nr_figures_for_sectoral_subplots
      
        figure('Name',sprintf('%s_1.0.4.1.%d_sectors_final_demand', figures_name, f));
        sgtitle(sprintf('---------- REAL (PHYSICAL) FINAL DEMAND (%s scale) ----------', y_scale_metrics), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
            
        % Number of subplots in current figure. In the last figure, this value will be <= max_nr_subplots_per_figure
        if f < nr_figures_for_sectoral_subplots        
            nr_subplots_current_figure = max_nr_subplots_per_figure;
        else % i.e. when f == nr_figures_for_sectoral_subplots
            if mod(Parameters.Sectors.nr, max_nr_subplots_per_figure) ~= 0  % mod(a,m) returns the remainder after division of a by m. Example: mod(23,5) yields 3
                nr_subplots_current_figure = mod(Parameters.Sectors.nr, max_nr_subplots_per_figure); 
            else
                nr_subplots_current_figure = max_nr_subplots_per_figure;
            end
        end
        
    
        for j = 1 : nr_subplots_current_figure
    
            idx_sector = (f-1) * max_nr_subplots_per_figure + j;            
        
            subplot(nr_rows, nr_columns, j);
    
            hold on
            p1 = plot(Sectors.final_demand_phys(idx_sector,:)', 'LineWidth', 5);
            p2 = plot(Sectors.products_available_for_final_demand_phys(idx_sector,:)', 'LineWidth', 5);
            p3 = plot(reshape(sum(Sectors.demand_from_hhs_phys(idx_sector,:,:), 2), [], 1), 'LineWidth', 2);
            p4 = plot(reshape(Sectors.demand_from_investing_divisions_aggr_phys(idx_sector,:), [], 1), 'LineWidth', 2);
            p5 = plot(Sectors.demand_from_govt_phys(idx_sector,:)', 'LineWidth', 2);
            p6 = plot(Sectors.sales_to_final_demand_phys(idx_sector,:), 'LineWidth', 2);
            hold off 
            
            title(Parameters.Sectors.names(idx_sector), 'FontSize', 15);
            legend(legend_text_final_demands,'Location','best', 'FontSize', 12);
            
            % label(p1, 'tot', 'slope', 'location', 'center', 'FontSize', 15);
            % label(p2, 'avail', 'location', 'right', 'FontSize', 15);
            % label(p3, 'hhs', 'slope', 'location', 'center', 'FontSize', 15);
            % label(p4, 'invest', 'location', 'center', 'slope', 'FontSize', 15);
            % label(p5, 'gov', 'location', 'right', 'slope', 'FontSize', 15);
            % label(p6, 'sales', 'location', 'center', 'FontSize', 15);
            
            set(gca,'fontsize', 13);
            set(gca, 'yscale', y_scale_metrics);
        end
    
    end
    
    
    %% 1.0.4.2  final demand / version 2
    
    % Version 2: the investment lines show investment orders adjusted after taking into account the rationing on investments..
    % .. arising from limited products availability.
    
    % For each sector, we make a plot showing: 
        % its total final demand
        % its final demand components (from hhs, investing sectors, gov't) 
        % products available for sale to final demand
        % and total sales to final demand sectors.
    
    
    % Legend
    legend_text_final_demands = [];
    legend_text_final_demands{1,1} = 'tot';
    legend_text_final_demands{1,2} = 'available';
    legend_text_final_demands{1,3} = 'hhs';
    legend_text_final_demands{1,4} = 'invest';
    legend_text_final_demands{1,5} = 'gov';
    legend_text_final_demands{1,6} = 'sales';
    
    
    for f = 1 : nr_figures_for_sectoral_subplots
      
        figure('Name', sprintf('%s_1.0.4.2.%d_sectors_final_demand', figures_name, f));
        sgtitle(sprintf('---------- REAL (PHYSICAL) FINAL DEMAND (%s scale) ----------', y_scale_metrics), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');    
        
        % Number of subplots in current figure. In the last figure, this value will be <= max_nr_subplots_per_figure
        if f < nr_figures_for_sectoral_subplots        
            nr_subplots_current_figure = max_nr_subplots_per_figure;
        else % i.e. when f == nr_figures_for_sectoral_subplots
            if mod(Parameters.Sectors.nr, max_nr_subplots_per_figure) ~= 0  % mod(a,m) returns the remainder after division of a by m. Example: mod(23,5) yields 3
                nr_subplots_current_figure = mod(Parameters.Sectors.nr, max_nr_subplots_per_figure); 
            else
                nr_subplots_current_figure = max_nr_subplots_per_figure;
            end
        end
        
    
        for j = 1 : nr_subplots_current_figure
    
            idx_sector = (f-1) * max_nr_subplots_per_figure + j;
            idx_section = Parameters.Sectors.section_idx(idx_sector);            
    
            % BROWN SECTOR
            if ismember(idx_sector, Parameters.Sectors.idx_brown)        
                
                % Total real (physical) demand from investing sectors
                sectional_current_orders_from_investing_sectors_adj = NaN * ones(1, Parameters.T);
                brown_current_orders_from_investing_sectors_adj = NaN * ones(1, Parameters.T);
                for t = 1:Parameters.T
                    sectional_current_orders_from_investing_sectors_adj(t) = sum(Sections.current_orders_from_investing_divisions_adj_for_rationing_phys(idx_section, :, t), 2);
                    brown_current_orders_from_investing_sectors_adj(t) = sectional_current_orders_from_investing_sectors_adj(t) ...
                        - Sectors.aggr_investment_sales_phys(Parameters.Sectors.idx_green, t);
                end               
            
                subplot(nr_rows, nr_columns, j);              
                
                hold on
                p1 = plot(Sectors.final_demand_phys(idx_sector,:)', 'LineWidth', 2);
                p2 = plot(Sectors.products_available_for_final_demand_phys(idx_sector,:)', 'LineWidth', 3);
                p3 = plot(reshape(sum(Sectors.demand_from_hhs_phys(idx_sector,:,:), 2), [], 1), 'LineWidth', 2);
        
                p4 = plot(brown_current_orders_from_investing_sectors_adj', 'LineWidth', 2);
                
                p5 = plot(Sectors.demand_from_govt_phys(idx_sector,:)', 'LineWidth', 2);
                p6 = plot(Sectors.sales_to_final_demand_phys(idx_sector,:), 'LineWidth', 2);
                hold off 
                
                title(Parameters.Sectors.names(idx_sector), 'FontSize', 15);
                legend(legend_text_final_demands,'Location','best', 'FontSize', 12);
    
                % label(p1, 'tot', 'slope', 'location', 'center', 'FontSize', 15);
                % label(p2, 'avail', 'location', 'right', 'FontSize', 15);
                % label(p3, 'hhs', 'slope', 'location', 'center', 'FontSize', 15);
                % label(p4, 'invest', 'location', 'center', 'slope', 'FontSize', 15);
                % label(p5, 'gov', 'location', 'right', 'slope', 'FontSize', 15);
                % label(p6, 'sales', 'location', 'center', 'FontSize', 15);
                set(gca,'fontsize', 13);
                set(gca, 'yscale', y_scale_metrics);
                
        
            % NON-BROWN SECTORS
            else            
                subplot(nr_rows, nr_columns, j);  
                
                hold on
                p1 = plot(Sectors.final_demand_phys(idx_sector,:)', 'LineWidth', 2);
                p2 = plot(Sectors.products_available_for_final_demand_phys(idx_sector,:)', 'LineWidth', 3);
                p3 = plot(reshape(sum(Sectors.demand_from_hhs_phys(idx_sector,:,:), 2), [], 1), 'LineWidth', 2);
        
                p4 = plot(reshape(sum(Sections.current_orders_from_investing_divisions_adj_for_rationing_phys(idx_section, :, :), 2), [], 1), 'LineWidth', 2);
                
                p5 = plot(Sectors.demand_from_govt_phys(idx_sector,:)', 'LineWidth', 2);
                p6 = plot(Sectors.sales_to_final_demand_phys(idx_sector,:), 'LineWidth', 2);
                hold off 
                
                title(Parameters.Sectors.names(idx_sector), 'FontSize', 15);
                legend(legend_text_final_demands,'Location','best', 'FontSize', 12);
    
                % label(p1, 'tot', 'slope', 'location', 'center', 'FontSize', 15);
                % label(p2, 'avail', 'location', 'right', 'FontSize', 15);
                % label(p3, 'hhs', 'slope', 'location', 'center', 'FontSize', 15);
                % label(p4, 'invest', 'location', 'center', 'slope', 'FontSize', 15);
                % label(p5, 'gov', 'location', 'right', 'slope', 'FontSize', 15);
                % label(p6, 'sales', 'location', 'center', 'FontSize', 15);
                set(gca,'fontsize', 13);
                set(gca, 'yscale', y_scale_metrics);
            end
        end
    
    end


    %% 1.0.5  inventories to total production ratio

    figure('Name', sprintf('%s_1.0.5_inventories', figures_name));
    
    ax = axes();
    plot(100 * Sectors.phys_inventories_to_tot_production_ratio', 'LineWidth', 3); 
    ytickformat("percentage");
    ax.LineStyleOrder = my_lines_styles; 
    ax.ColorOrder = my_colors_sectors;
    title('RATIO OF INVENTORIES TO TOTAL PRODUCTION (physical)', 'FontSize', 20);
    clickableLegend(Parameters.Sectors.names,'Location','best', 'FontSize', 15);
    set(gca,'fontsize', 15);


    %% 1.0.6  intermediate sales vs total production

    % It may be interesting to check how much of a Section's total physical production is devoted to intermediate sales.
    % Note that even though a Section may be selling nothing to final demand (e.g. Fossil fuels extraction), ..
    % .. the share may be less than 100% because the Section may be accumulating inventories.

    figure('Name', sprintf('%s_1.0.6_intermediate_vs_total_prod', figures_name));
    
    ax = axes();
    plot(100 * (Sections.intermediate_sales_aggr_phys ./ Sections.production_phys)', 'LineWidth', 3); 
    ytickformat("percentage");
    ax.LineStyleOrder = my_lines_styles; 
    ax.ColorOrder = my_colors_sections;
    title('SHARE OF INTERMEDIATE SALES IN TOTAL PRODUCTION (beware of inventories)', 'FontSize', 20);
    clickableLegend(Parameters.Sections.names,'Location','best', 'FontSize', 15);
    set(gca,'fontsize', 15);
            

%% CAPITAL
    %% 1.1.1.1  capacity utilization

    figure('Name', sprintf('%s_1.1.1.1_capacity_utilization', figures_name));

    ax = axes();
    hold on
    plot(Divisions.capacity_utilization_highest_value, 'LineWidth', 2);     
    ax.LineStyleOrder = my_lines_styles; 
    ax.ColorOrder = my_colors_divisions;
    plot(repmat(Parameters.Divisions.normal_capacity_utilization, Parameters.T, 1), 'Color', 'black', 'LineStyle', '--', 'LineWidth', 2);
    hold off
    title('CAPACITY UTILIZATION', 'FontSize', 20);
    clickableLegend(Parameters.Divisions.names,'Location','best', 'FontSize', 15);
    set(gca,'fontsize', 15);    


    %% 1.1.1.2  capacity utilization / of each asset

    for f = 1 : nr_figures_for_divisional_subplots
      
        figure('Name', sprintf('%s_1.1.1.2.%d_capacity_utilization_detailed', figures_name, f));
        sgtitle('---------- CAPACITY UTILIZATION OF EACH CAPITAL ASSET IN EACH DIVISION ----------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
            
        % Number of subplots in current figure. In the last figure, this value will be <= max_nr_subplots_per_figure
        if f < nr_figures_for_divisional_subplots        
            nr_subplots_current_figure = max_nr_subplots_per_figure;
        else % i.e. when f == nr_figures_for_divisional_subplots
            if mod(Parameters.Divisions.nr, max_nr_subplots_per_figure) ~= 0   % mod(a,m) returns the remainder after division of a by m. Example: mod(23,5) yields 3
                nr_subplots_current_figure = mod(Parameters.Divisions.nr, max_nr_subplots_per_figure); 
            else
                nr_subplots_current_figure = max_nr_subplots_per_figure;
            end
        end
        
    
        for j = 1 : nr_subplots_current_figure
    
            idx_division = (f-1) * max_nr_subplots_per_figure + j;            
        
            subplot(nr_rows, nr_columns, j);
            
            hold on
            plot(reshape(Divisions.capacity_utilization_of_each_asset(Parameters.Sections.idx_capital_assets, idx_division, :), numel(Parameters.Sections.idx_capital_assets), [])', 'LineWidth', 2);
            plot(ones(Parameters.T, 1) * Parameters.Divisions.normal_capacity_utilization(idx_division), 'Color', 'black', 'LineStyle', '--', 'LineWidth', 2);
            ylim([0,1]);
            title(Parameters.Divisions.names(idx_division), 'FontSize', 15);
            clickableLegend(Parameters.Sections.names(Parameters.Sections.idx_capital_assets),'Location','best', 'FontSize', 13);
            set(gca,'fontsize', 13);
        end
    
        %clickableLegend(Parameters.Sections.names(Parameters.Sections.idx_capital_assets),'Location','best', 'FontSize', 13);
    
    end
    
    
    %% 1.1.2  production capacity and nominal capital
    
    figure('Name', sprintf('%s_1.1.2_sectors_capital', figures_name));
    
    % PRODUCTION CAPACITY
    sbp = subplot(1,2,1); 
    plot(Sectors.prod_cap', 'LineWidth', 3); 
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sectors;
    xlim([1 Parameters.T]);
    xticks(0:10:Parameters.T);
    title(sprintf('Maximum possible (physical) production (%s scale)', y_scale_metrics), 'FontSize', 20);
    clickableLegend(Parameters.Sectors.names, 'Location', 'best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);
    
    
    % NOMINAL CAPITAL
    sbp = subplot(1,2,2); 
    plot(Sectors.tot_capital_nominal, 'LineWidth', 3);
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sectors;
    title(sprintf('Nominal capital (%s scale)', y_scale_metrics), 'FontSize', 20);
    xlim([1 Parameters.T]);
    xticks(0:10:Parameters.T);
    clickableLegend(Parameters.Sectors.names, 'Location', 'best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);    


    %% 1.1.3  production capacity / actual / of each asset
    
    for f = 1 : nr_figures_for_divisional_subplots
      
        figure('Name', sprintf('%s_1.1.3.%d_production_capacity', figures_name, f));
        sgtitle(sprintf('---------- PRODUCTION CAPACITY OF EACH CAPITAL ASSET (%s scale) ----------', y_scale_metrics), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
            
        % Number of subplots in current figure. In the last figure, this value will be <= max_nr_subplots_per_figure
        if f < nr_figures_for_divisional_subplots        
            nr_subplots_current_figure = max_nr_subplots_per_figure;
        else % i.e. when f == nr_figures_for_divisional_subplots
            if mod(Parameters.Divisions.nr, max_nr_subplots_per_figure) ~= 0   % mod(a,m) returns the remainder after division of a by m. Example: mod(23,5) yields 3
                nr_subplots_current_figure = mod(Parameters.Divisions.nr, max_nr_subplots_per_figure); 
            else
                nr_subplots_current_figure = max_nr_subplots_per_figure;
            end
        end
        
    
        for j = 1 : nr_subplots_current_figure
    
            idx_division = (f-1) * max_nr_subplots_per_figure + j;            
        
            subplot(nr_rows, nr_columns, j);
    
            plot(reshape(Divisions.prod_cap_of_each_capital_asset(Parameters.Sections.idx_capital_assets, idx_division, :), numel(Parameters.Sections.idx_capital_assets), [])', 'LineWidth', 2);    
            title(Parameters.Divisions.names(idx_division), 'FontSize', 15);
            set(gca,'fontsize', 13);
            set(gca, 'yscale', y_scale_metrics);
        end
    
        clickableLegend(Parameters.Sections.names(Parameters.Sections.idx_capital_assets),'Location', 'best', 'FontSize', 13);
    
    end
    
    
    %% 1.1.4  production capacity / desired / of each asset
    
    for f = 1 : nr_figures_for_divisional_subplots
      
        figure('Name', sprintf('%s_1.1.4.%d_production_capacity', figures_name, f));
        sgtitle(sprintf('---------- DESIRED PRODUCTION CAPACITY OF EACH CAPITAL ASSET (%s scale) ----------', y_scale_metrics), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');    
            
        % Number of subplots in current figure. In the last figure, this value will be <= max_nr_subplots_per_figure
        if f < nr_figures_for_divisional_subplots        
            nr_subplots_current_figure = max_nr_subplots_per_figure;
        else % i.e. when f == nr_figures_for_divisional_subplots
            if mod(Parameters.Divisions.nr, max_nr_subplots_per_figure) ~= 0   % mod(a,m) returns the remainder after division of a by m. Example: mod(23,5) yields 3
                nr_subplots_current_figure = mod(Parameters.Divisions.nr, max_nr_subplots_per_figure); 
            else
                nr_subplots_current_figure = max_nr_subplots_per_figure;
            end
        end
        
    
        for j = 1 : nr_subplots_current_figure
    
            idx_division = (f-1) * max_nr_subplots_per_figure + j;            
        
            subplot(nr_rows, nr_columns, j);
    
            plot(reshape(Divisions.desired_prod_cap_of_each_capital_asset_in2years(Parameters.Sections.idx_capital_assets, idx_division, :), numel(Parameters.Sections.idx_capital_assets), [])', 'LineWidth', 2);    
            title(Parameters.Divisions.names(idx_division), 'FontSize', 15);
            set(gca,'fontsize', 13);
            set(gca, 'yscale', y_scale_metrics);
        end
    
        legend(Parameters.Sections.names(Parameters.Sections.idx_capital_assets),'Location','best', 'FontSize', 15);
    end
    
    
    %% 1.1.5  production capacity / desired / of each asset / adjusted after loans
    
    for f = 1 : nr_figures_for_divisional_subplots
      
        figure('Name', sprintf('%s_1.1.5.%d_production_capacity', figures_name, f));
        sgtitle(sprintf('---------- DESIRED PRODUCTION CAPACITY OF EACH CAPITAL ASSET, ADJ AFTER LOANS (%s scale) ----------', y_scale_metrics), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');    
            
        % Number of subplots in current figure. In the last figure, this value will be <= max_nr_subplots_per_figure
        if f < nr_figures_for_divisional_subplots        
            nr_subplots_current_figure = max_nr_subplots_per_figure;
        else % i.e. when f == nr_figures_for_divisional_subplots
            if mod(Parameters.Divisions.nr, max_nr_subplots_per_figure) ~= 0   % mod(a,m) returns the remainder after division of a by m. Example: mod(23,5) yields 3
                nr_subplots_current_figure = mod(Parameters.Divisions.nr, max_nr_subplots_per_figure); 
            else
                nr_subplots_current_figure = max_nr_subplots_per_figure;
            end
        end
        
    
        for j = 1 : nr_subplots_current_figure
    
            idx_division = (f-1) * max_nr_subplots_per_figure + j;            
        
            subplot(nr_rows, nr_columns, j);
    
            plot(reshape(Divisions.desired_prod_cap_of_each_capital_asset_adj_after_loans_in2years(Parameters.Sections.idx_capital_assets, idx_division, :), numel(Parameters.Sections.idx_capital_assets), [])', 'LineWidth', 2);    
            title(Parameters.Divisions.names(idx_division), 'FontSize', 15);
            set(gca,'fontsize', 13);
            set(gca, 'yscale', y_scale_metrics);
        end
        
        legend(Parameters.Sections.names(Parameters.Sections.idx_capital_assets),'Location','best', 'FontSize', 15);
    end


    %% 1.1.6  physical capital stocks / of each asset

    for f = 1 : nr_figures_for_divisional_subplots
      
        figure('Name', sprintf('%s_1.1.6.%d_physical_capital_stocks', figures_name, f));
        sgtitle(sprintf('---------- PHYSICAL CAPITAL STOCKS (%s scale) ----------', y_scale_metrics), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
            
        % Number of subplots in current figure. In the last figure, this value will be <= max_nr_subplots_per_figure
        if f < nr_figures_for_divisional_subplots        
            nr_subplots_current_figure = max_nr_subplots_per_figure;
        else % i.e. when f == nr_figures_for_divisional_subplots
            if mod(Parameters.Divisions.nr, max_nr_subplots_per_figure) ~= 0   % mod(a,m) returns the remainder after division of a by m. Example: mod(23,5) yields 3
                nr_subplots_current_figure = mod(Parameters.Divisions.nr, max_nr_subplots_per_figure); 
            else
                nr_subplots_current_figure = max_nr_subplots_per_figure;
            end
        end
        
    
        for j = 1 : nr_subplots_current_figure
    
            idx_division = (f-1) * max_nr_subplots_per_figure + j;            
        
            subplot(nr_rows, nr_columns, j);
    
            plot(reshape(Divisions.capital_phys(Parameters.Sections.idx_capital_assets, idx_division, :), numel(Parameters.Sections.idx_capital_assets), [])', 'LineWidth', 2);    
            title(Parameters.Divisions.names(idx_division), 'FontSize', 15);
            legend(Parameters.Sections.names(Parameters.Sections.idx_capital_assets),'Location','best', 'FontSize', 13);
            set(gca,'fontsize', 13);
            set(gca, 'yscale', y_scale_metrics);
        end            
    
    end


    %% 1.1.7  nominal capital stocks / of each asset

    for f = 1 : nr_figures_for_sectoral_subplots
      
        figure('Name', sprintf('%s_1.1.7.%d_nominal_capital_stocks', figures_name, f));
        sgtitle(sprintf('---------- NOMINAL CAPITAL STOCKS (%s scale) ----------', y_scale_metrics), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
            
        % Number of subplots in current figure. In the last figure, this value will be <= max_nr_subplots_per_figure
        if f < nr_figures_for_sectoral_subplots        
            nr_subplots_current_figure = max_nr_subplots_per_figure;
        else % i.e. when f == nr_figures_for_sectoral_subplots
            if mod(Parameters.Sectors.nr, max_nr_subplots_per_figure) ~= 0  % mod(a,m) returns the remainder after division of a by m. Example: mod(23,5) yields 3
                nr_subplots_current_figure = mod(Parameters.Sectors.nr, max_nr_subplots_per_figure); 
            else
                nr_subplots_current_figure = max_nr_subplots_per_figure;
            end
        end
        
    
        for j = 1 : nr_subplots_current_figure
    
            idx_sector = (f-1) * max_nr_subplots_per_figure + j;            
        
            subplot(nr_rows, nr_columns, j);
    
            plot(reshape(Sectors.capital_nominal(Parameters.Sections.idx_capital_assets, idx_sector, :), numel(Parameters.Sections.idx_capital_assets), [])', 'LineWidth', 2);    
            title(Parameters.Sectors.names(idx_sector), 'FontSize', 15);
            legend(Parameters.Sections.names(Parameters.Sections.idx_capital_assets),'Location','best', 'FontSize', 13);
            set(gca,'fontsize', 13);
            set(gca, 'yscale', y_scale_metrics);
        end            
    
    end


    %% 1.1.8  physical investments / actual / in each asset

    for f = 1 : nr_figures_for_divisional_subplots
      
        figure('Name', sprintf('%s_1.1.8.%d_actual_physical_investments', figures_name, f));
        sgtitle(sprintf('---------- ACTUAL PHYSICAL INVESTMENTS (%s scale) ----------', y_scale_metrics), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
            
        % Number of subplots in current figure. In the last figure, this value will be <= max_nr_subplots_per_figure
        if f < nr_figures_for_divisional_subplots        
            nr_subplots_current_figure = max_nr_subplots_per_figure;
        else % i.e. when f == nr_figures_for_divisional_subplots
            if mod(Parameters.Divisions.nr, max_nr_subplots_per_figure) ~= 0   % mod(a,m) returns the remainder after division of a by m. Example: mod(23,5) yields 3
                nr_subplots_current_figure = mod(Parameters.Divisions.nr, max_nr_subplots_per_figure); 
            else
                nr_subplots_current_figure = max_nr_subplots_per_figure;
            end
        end                
    
        for j = 1 : nr_subplots_current_figure
    
            idx_division = (f-1) * max_nr_subplots_per_figure + j;            
        
            subplot(nr_rows, nr_columns, j);
                
            plot(reshape(Sections.current_orders_from_investing_divisions_adj_for_rationing_phys(Parameters.Sections.idx_capital_assets, idx_division, :), numel(Parameters.Sections.idx_capital_assets), [])', 'LineWidth', 2);            

            title(Parameters.Divisions.names(idx_division), 'FontSize', 15);
            set(gca,'fontsize', 13);
            set(gca, 'yscale', y_scale_metrics);
        end
    
        legend(Parameters.Sections.names(Parameters.Sections.idx_capital_assets),'Location', 'best', 'FontSize', 13);
    
    end    


    %% 1.1.9  nominal investment proportions / actual / in each asset

    % Let's first compute the proportions
    investment_proportions = Sections.sales_to_investing_divisions_nomin ./ sum(Sections.sales_to_investing_divisions_nomin);


    for f = 1 : nr_figures_for_divisional_subplots
      
        figure('Name', sprintf('%s_1.1.9.%d_actual_nominal_investment_proportions', figures_name, f));
        sgtitle('---------- ACTUAL NOMINAL INVESTMENT PROPORTIONS ----------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
            
        % Number of subplots in current figure. In the last figure, this value will be <= max_nr_subplots_per_figure
        if f < nr_figures_for_divisional_subplots        
            nr_subplots_current_figure = max_nr_subplots_per_figure;
        else % i.e. when f == nr_figures_for_divisional_subplots
            if mod(Parameters.Divisions.nr, max_nr_subplots_per_figure) ~= 0   % mod(a,m) returns the remainder after division of a by m. Example: mod(23,5) yields 3
                nr_subplots_current_figure = mod(Parameters.Divisions.nr, max_nr_subplots_per_figure); 
            else
                nr_subplots_current_figure = max_nr_subplots_per_figure;
            end
        end                
    
        for j = 1 : nr_subplots_current_figure
    
            idx_division = (f-1) * max_nr_subplots_per_figure + j;            
        
            subplot(nr_rows, nr_columns, j);
                
            plot(100 * reshape(investment_proportions(Parameters.Sections.idx_capital_assets, idx_division, :), numel(Parameters.Sections.idx_capital_assets), [])', 'LineWidth', 2);            
            ytickformat("percentage");

            title(Parameters.Divisions.names(idx_division), 'FontSize', 15);
            set(gca,'fontsize', 13);
            
            legend(Parameters.Sections.names(Parameters.Sections.idx_capital_assets), 'Location', 'best', 'FontSize', 13);

        end          
    
    end 


%% RATIONING MEASURES
    %% 1.2.1  production constraints
    
    figure('Name', sprintf('%s_1.2.1_production constraints', figures_name));
    sgtitle('--------- PRODUCTION CONSTRAINTS (values < 1) = max production / unbound production ---------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
    
    threshold_value = ones(Parameters.T, 1);
    
    % SECTORAL CONSTRAINTS
    sp1 = subplot(1,2,1); 
    hold on
    a = plot(Sectors.production_constraints', 'LineWidth', 2);
    b = plot(threshold_value, 'LineWidth', 3, 'Color', 'black');
    hold off
    sp1.LineStyleOrder = my_lines_styles; 
    sp1.ColorOrder = my_colors_sectors;
    xticks(0:10:Parameters.T);
    title(sprintf('Sectoral constraints (%s scale)', y_scale_metrics), 'FontSize', 15);
    legend_text_sectors_with_threshold = [Parameters.Sectors.names; 'THRESHOLD'];
    clickableLegend(legend_text_sectors_with_threshold, 'Location', 'best', 'FontSize', 13);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);
    uistack(b,'bottom') % puts line from plot b in the background
    
    
    % SECTIONAL CONSTRAINTS
    sp2 = subplot(1,2,2); 
    hold on
    colororder(my_colors_sections)
    a = plot(Sections.production_constraints', 'LineWidth', 2);
    b = plot(threshold_value, 'LineWidth', 3, 'Color', 'black');
    hold off
    sp2.LineStyleOrder = my_lines_styles; 
    sp2.ColorOrder = my_colors_sections;
    xticks(0:10:Parameters.T);
    title(sprintf('Sectional constraints (%s scale)', y_scale_metrics), 'FontSize', 15);
    legend_text_sections_with_threshold = [Parameters.Sections.names; 'THRESHOLD'];
    clickableLegend(legend_text_sections_with_threshold, 'Location', 'best', 'FontSize', 13);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);
    uistack(b,'bottom') % puts line from plot b in the background
    
    
    % Set the y-axis limits of the two subplots to be equal
    linkaxes([sp1 sp2],'y')
    
    
    %% 1.2.2  constraints in the supply of goods to final demand
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%  SECTIONAL CONSTRAINTS IN THE SUPPLY OF GOODS..  %%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    threshold_value = ones(Parameters.T, 1);
    legend_text_sections_with_threshold = [Parameters.Sections.names; 'THRESHOLD'];

    y_scale_metrics_constraints_plots = 'linear';

    y_lim_max_value = 1.2;
    
    

    %%%%%%%%%%%%%% .. TO EXPECTED FINAL DEMAND  %%%%%%%%%%%%%%

    figure('Name', sprintf('%s_1.2.2.1_sectional_constraints_in_the_supply_of_goods', figures_name));
    ax = axes(); 
    ax.LineStyleOrder = my_lines_styles; 
    ax.ColorOrder = my_colors_sections;
    hold on
    for i = 1 : Parameters.Sections.nr
        plot(Sections.exp_final_demand_fulfillment_constraints(i,:)', 'LineWidth', 20-(i+1.3));
    end
    b = plot(threshold_value, 'LineWidth', 5, 'Color', 'black');
    hold off
    title(sprintf('SECTIONAL CONSTRAINTS (values < 1) IN THE SUPPLY OF GOODS .. to expected final demand (%s scale) \n = available products / exp final demand', y_scale_metrics_constraints_plots), 'FontSize', 14);
    clickableLegend(legend_text_sections_with_threshold, 'Location', 'best', 'FontSize', 14);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics_constraints_plots);
    uistack(b,'bottom') % puts line from plot b in the background
    
    

    %%%%%%%%%%%%%% .. TO FINAL DEMAND  %%%%%%%%%%%%%%

    figure('Name', sprintf('%s_1.2.2.2_sectional_constraints_in_the_supply_of_goods', figures_name));
    ax = axes(); 
    ax.LineStyleOrder = my_lines_styles; 
    ax.ColorOrder = my_colors_sections;
    hold on
    % for i = 1 : Parameters.Sections.nr
    %     plot(Sections.final_demand_fulfillment_constraints(i,:)', 'LineWidth', 2);
    % end
    plot(Sections.final_demand_fulfillment_constraints', 'LineWidth', 2);
    b = plot(threshold_value, 'LineWidth', 5, 'Color', 'black');
    hold off
    title(sprintf('SECTIONAL CONSTRAINTS (values < 1) IN THE SUPPLY OF GOODS .. to final demand (%s scale) \n = available products / final demand', y_scale_metrics_constraints_plots), 'FontSize', 14);
    clickableLegend(legend_text_sections_with_threshold, 'Location', 'best', 'FontSize', 14);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics_constraints_plots);
    uistack(b,'bottom') % puts line from plot b in the background
    
    

    %%%%%%%%%%%%%% .. TO INVESTING INDUSTRIES  %%%%%%%%%%%%%%

    % Y-AXIS LIMITS
    % Without y-axis limits it may be the case that you cannot properly read the figure.
    % If you set the following rule to "with limits", then the y-axis will be limited to [0,1]
    y_limits_rule = "with limits";
    %y_limits_rule = "without limits";
    
    figure('Name', sprintf('%s_1.2.2.3_sectional_constraints_in_the_supply_of_goods', figures_name));
    ax = axes(); 
    ax.LineStyleOrder = my_lines_styles; 
    ax.ColorOrder = my_colors_sections;    
    hold on    
    plot(Sections.investm_demand_fulfillment_constraints(Parameters.Sections.idx_capital_assets, :)', 'LineWidth', 2);
    b = plot(threshold_value, 'LineWidth', 5, 'Color', 'black');
    hold off
    if y_limits_rule == "with limits"        
        ylim([min(ylim) y_lim_max_value])
    end
    if y_limits_rule == "with limits"
        title(sprintf('SECTIONAL CONSTRAINTS (values < 1) IN THE SUPPLY OF GOODS .. to investing industries (%s scale) \n = available products / investment demand \n \\color{red}!!! NOTE: y-axis limits have been applied to improve readibility !!!', y_scale_metrics_constraints_plots), 'interpreter', 'tex', 'FontSize', 14);
    else
        title(sprintf('SECTIONAL CONSTRAINTS (values < 1) IN THE SUPPLY OF GOODS .. to investing industries (%s scale) \n = available products / investment demand', y_scale_metrics_constraints_plots), 'FontSize', 14);
    end    
    clickableLegend([Parameters.Sections.names(Parameters.Sections.idx_capital_assets); 'THRESHOLD'], 'Location', 'best', 'FontSize', 14);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics_constraints_plots);
    uistack(b,'bottom') % puts line from plot b in the background


    
    %%%%%%%%%%%%%% .. TO HOUSEHOLDS  %%%%%%%%%%%%%%
    
    % You may want to read the figure better by looking only at the goods on which the household demands most
    % Define how many goods to look at
    number_of_largest_elements = sum(Parameters.Households.exiobase_demand_relations_phys > 0); % set it equal to "sum(Parameters.Households.exiobase_demand_relations_phys > 0)" if you want to feature all goods that the hh demands
    [~, idx_largest_elements] = ...
        maxk(Parameters.Households.exiobase_demand_relations_phys ./ sum(Parameters.Households.exiobase_demand_relations_phys), number_of_largest_elements);
    idx_largest_elements = sort(idx_largest_elements);  

    % Y-AXIS LIMITS
    % Without y-axis limits it may be the case that you cannot properly read the figure.
    % If you set the following rule to "with limits", then the y-axis will be limited to [0,1]
    y_limits_rule = "with limits";
    %y_limits_rule = "without limits";

    figure('Name', sprintf('%s_1.2.2.4_sectional_constraints_in_the_supply_of_goods', figures_name));
    ax = axes(); 
    ax.LineStyleOrder = my_lines_styles; 
    ax.ColorOrder = my_colors_sections;
    hold on
    plot(Sections.hhs_demand_fulfillment_constraints(idx_largest_elements, :)', 'LineWidth', 2);
    b = plot(threshold_value, 'LineWidth', 5, 'Color', 'black');    
    hold off    
    if y_limits_rule == "with limits"        
        ylim([min(ylim) y_lim_max_value])
    end
    if y_limits_rule == "with limits"
        title(sprintf('SECTIONAL CONSTRAINTS (values < 1) IN THE SUPPLY OF GOODS .. to households (%s scale) \n = available products / household demand \n \\color{red}!!! NOTE: y-axis limits have been applied to improve readibility !!!', y_scale_metrics_constraints_plots), 'interpreter', 'tex', 'FontSize', 14);
    else
        title(sprintf('SECTIONAL CONSTRAINTS (values < 1) IN THE SUPPLY OF GOODS .. to households (%s scale) \n = available products / household demand', y_scale_metrics_constraints_plots), 'FontSize', 14);
    end
    clickableLegend([Parameters.Sections.names(idx_largest_elements); 'THRESHOLD'], 'Location', 'best', 'FontSize', 14);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics_constraints_plots);
    uistack(b,'bottom') % puts line from plot b in the background



    %%%%%%%%%%%%%% .. TO GOV'T  %%%%%%%%%%%%%%
    
    % You may want to read the figure better by looking only at the goods on which the gov't demands most
    % Define how many goods to look at
    number_of_largest_elements = sum(Parameters.Government.exiobase_demand_relations_phys > 0); % set it equal to "sum(Parameters.Government.exiobase_demand_relations_phys > 0)" if you want to feature all goods that the gov't demands
    [~, idx_largest_elements] = ...
        maxk(Parameters.Government.exiobase_demand_relations_phys ./ sum(Parameters.Government.exiobase_demand_relations_phys), number_of_largest_elements);
    idx_largest_elements = sort(idx_largest_elements);  

    % Y-AXIS LIMITS
    % Without y-axis limits it may be the case that you cannot properly read the figure.
    % If you set the following rule to "with limits", then the y-axis will be limited to [0,1]
    y_limits_rule = "with limits";
    %y_limits_rule = "without limits";

    figure('Name', sprintf('%s_1.2.2.5_sectional_constraints_in_the_supply_of_goods', figures_name));
    ax = axes(); 
    ax.LineStyleOrder = my_lines_styles; 
    ax.ColorOrder = my_colors_sections;
    hold on
    plot(Sections.govt_demand_fulfillment_constraints(idx_largest_elements, :)', 'LineWidth', 2);
    b = plot(threshold_value, 'LineWidth', 5, 'Color', 'black');
    hold off    
    if y_limits_rule == "with limits"        
        ylim([min(ylim) y_lim_max_value])
    end
    if y_limits_rule == "with limits"
        title(sprintf('SECTIONAL CONSTRAINTS (values < 1) IN THE SUPPLY OF GOODS .. to government (%s scale) \n = available products / government demand \n \\color{red}!!! NOTE: y-axis limits have been applied to improve readibility !!!', y_scale_metrics_constraints_plots), 'interpreter', 'tex', 'FontSize', 14);
    else
        title(sprintf('SECTIONAL CONSTRAINTS (values < 1) IN THE SUPPLY OF GOODS .. to government (%s scale) \n = available products / government demand', y_scale_metrics_constraints_plots), 'FontSize', 14);
    end
    clickableLegend([Parameters.Sections.names(idx_largest_elements); 'THRESHOLD'], 'Location', 'best', 'FontSize', 14);
    set(gca, 'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics_constraints_plots);
    uistack(b, 'bottom') % puts line from plot b in the background
    
    
    
    %%%%%%%%%  NOTE %%%%%%%%%%%%%
    % The commented script below was used to plot all 3 plots as subplots in the same figure.
    % However, now we plot them each in a separate figure for convenience.
    
    
    % figure('Name', sprintf('%s_1.1.2_sectional_constraints_in_the_supply_of_goods', figures_name));
    % sgtitle('--------- SECTIONAL CONSTRAINTS (values < 1) IN THE SUPPLY OF GOODS.. ---------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
    % 
    % threshold_value = ones(Parameters.T, 1);
    % legend_text_sections_with_threshold = [Parameters.Sections.names, 'THRESHOLD'];
    % 
    % nr_subplots = 3;
    % struct_field_names = strings([1,nr_subplots]);
    % my_titles = strings([1,nr_subplots]);
    % my_subplots = strings([1,nr_subplots]);
    % 
    % struct_field_names(1) = "exp_final_demand_fulfillment_constraints";
    % my_titles(1) = ".. to expected final demand";
    % struct_field_names(2) = "final_demand_fulfillment_constraints";
    % my_titles(2) = ".. to final demand";
    % struct_field_names(3) = "investment_goods_supply_constraints";
    % my_titles(3) = ".. to investing industries";
    % 
    % for k = 1 : numel(struct_field_names)
    % 
    %     Subplots.(sprintf('nr%d', k)) = subplot(1, nr_subplots, k);
    %     hold on
    %     my_plot = Sections.(struct_field_names(k));
    %     for i = 1 : Parameters.Sections.nr
    %         plot(my_plot(i,:,:)', 'LineWidth', 1.5); %   14.5-(i+1.6)
    %     end
    %     b = plot(threshold_value, 'LineWidth', 10, 'Color', 'black');
    %     hold off
    %     Subplots.(sprintf('nr%d', k)).LineStyleOrder = my_lines_styles; 
    %     Subplots.(sprintf('nr%d', k)).ColorOrder = my_colors_sections;
    %     title(my_titles(k), 'FontSize', 14); 
    %     legend(legend_text_sections_with_threshold, 'Location', 'best', 'FontSize', 12);
    %     set(gca,'fontsize', 15);
    %     uistack(b,'bottom') % puts line from plot b in the background
    % 
    % end
    % 
    % % Set the y-axis limits of the first two subplots to be equal
    % linkaxes([Subplots.nr1 Subplots.nr2],'y')
    % 
    % % Eliminate variables from the Workspace
    % clear Subplots my_plot
    
    
    %% 1.2.3  capacity accumulation rationing

    figure('Name', sprintf('%s_1.2.3_capacity_accumulation_rationing', figures_name));

    ax = axes();
    plot(Divisions.capacity_accumulation_rationing, 'LineWidth', 2); 
    ax.LineStyleOrder = my_lines_styles; 
    ax.ColorOrder = my_colors_divisions;
    title('CAPACITY ACCUMULATION RATIONING (values < 1 imply rationing)', 'FontSize', 20);
    clickableLegend(Parameters.Divisions.names,'Location','best', 'FontSize', 15);
    set(gca,'fontsize', 15); 
    
    
    %% 1.2.4.1  production capacity / desired vs actual / in levels

    legend_text_production_capacity = [];    
    legend_text_production_capacity{1,1} = 'desired production capacity';
    legend_text_production_capacity{1,2} = 'desired production capacity, adj after loans';
    legend_text_production_capacity{1,3} = 'actual production capacity';


    for f = 1 : nr_figures_for_divisional_subplots
      
        figure('Name', sprintf('%s_1.2.4.1.%d_desired_vs_actual_production_capacity', figures_name, f));
        sgtitle(sprintf('---------- DESIRED VS ACTUAL PRODUCTION CAPACITY (%s scale) ----------', y_scale_metrics), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
            
        % Number of subplots in current figure. In the last figure, this value will be <= max_nr_subplots_per_figure
        if f < nr_figures_for_divisional_subplots        
            nr_subplots_current_figure = max_nr_subplots_per_figure;
        else % i.e. when f == nr_figures_for_divisional_subplots
            if mod(Parameters.Divisions.nr, max_nr_subplots_per_figure) ~= 0   % mod(a,m) returns the remainder after division of a by m. Example: mod(23,5) yields 3
                nr_subplots_current_figure = mod(Parameters.Divisions.nr, max_nr_subplots_per_figure); 
            else
                nr_subplots_current_figure = max_nr_subplots_per_figure;
            end
        end
        
        x = 1 : Parameters.T;
    
        for j = 1 : nr_subplots_current_figure
    
            idx_division = (f-1) * max_nr_subplots_per_figure + j;            
        
            subplot(nr_rows, nr_columns, j);
    
            hold on            
            plot(x+2, reshape(min(Divisions.desired_prod_cap_of_each_capital_asset_in2years(Parameters.Divisions.capital_assets_logical_matrix(:, idx_division), idx_division, :)), 1, []), 'LineWidth', 6);
            plot(x+2, reshape(min(Divisions.desired_prod_cap_of_each_capital_asset_adj_after_loans_in2years(Parameters.Divisions.capital_assets_logical_matrix(:, idx_division), idx_division, :)), 1, []), 'LineWidth', 4);            
            plot(Divisions.prod_cap(idx_division, :), 'LineWidth', 2);            
            hold off

            title(Parameters.Divisions.names(idx_division), 'FontSize', 15);
            set(gca,'fontsize', 13);
            set(gca, 'yscale', y_scale_metrics);
        end
    
        legend(legend_text_production_capacity,'Location', 'best', 'FontSize', 13);
    
    end 


    %% 1.2.4.2  production capacity / desired vs actual / in percentages

    legend_text_production_capacity = [];        
    legend_text_production_capacity{1,1} = 'desired production capacity, adj after loans';
    legend_text_production_capacity{1,2} = 'actual production capacity';


    for f = 1 : nr_figures_for_divisional_subplots
      
        figure('Name', sprintf('%s_1.2.4.2.%d_desired_vs_actual_production_capacity_percentages', figures_name, f));
        sgtitle('---------- PRODUCTION CAPACITIES AS % OF DESIRED PRODUCTION CAPACITY BEFORE LOANS ----------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
            
        % Number of subplots in current figure. In the last figure, this value will be <= max_nr_subplots_per_figure
        if f < nr_figures_for_divisional_subplots        
            nr_subplots_current_figure = max_nr_subplots_per_figure;
        else % i.e. when f == nr_figures_for_divisional_subplots
            if mod(Parameters.Divisions.nr, max_nr_subplots_per_figure) ~= 0   % mod(a,m) returns the remainder after division of a by m. Example: mod(23,5) yields 3
                nr_subplots_current_figure = mod(Parameters.Divisions.nr, max_nr_subplots_per_figure); 
            else
                nr_subplots_current_figure = max_nr_subplots_per_figure;
            end
        end
        
        x = 1 : Parameters.T;
    
        for j = 1 : nr_subplots_current_figure
    
            idx_division = (f-1) * max_nr_subplots_per_figure + j;            
        
            subplot(nr_rows, nr_columns, j);

            future_desired_prod_limit = ...
                reshape(min(Divisions.desired_prod_cap_of_each_capital_asset_in2years(Parameters.Divisions.capital_assets_logical_matrix(:, idx_division), idx_division, :)), 1, []);

            future_desired_prod_limit_adj_after_loans = ...
                reshape(min(Divisions.desired_prod_cap_of_each_capital_asset_adj_after_loans_in2years(Parameters.Divisions.capital_assets_logical_matrix(:, idx_division), idx_division, :)), 1, []);
    
            percentage_1 = ...
                future_desired_prod_limit_adj_after_loans ./ future_desired_prod_limit;

            percentage_2 = NaN * ones(Parameters.T, 1);
            for t = 3 : Parameters.T
                percentage_2(t) = ...
                    Divisions.prod_cap(idx_division, t) ./ future_desired_prod_limit(t-2);
            end

            hold on                        
            plot(x+2, 100 * percentage_1, 'LineWidth', 2);            
            plot(100 * percentage_2, 'LineWidth', 2);            
            hold off
            ytickformat("percentage");

            title(Parameters.Divisions.names(idx_division), 'FontSize', 15);
            set(gca,'fontsize', 13);
        end
    
        legend(legend_text_production_capacity,'Location', 'best', 'FontSize', 13);
    
    end 
                
    
%% NOMINAL VARIABLES / FINANCIALS
    %% 1.4.1.1  profits
    
    figure('Name', sprintf('%s_1.4.1_sectors_profits', figures_name));     
    sgtitle('---------- PROFITS (net of interest expenses) ----------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');        
    
    idx_sectors_with_negative_profits = any(Sectors.entrepreneurial_profits_net_of_interest_expenses <= 0);

    % POSITIVE VALUES
    sbp = subplot(1,2,1);
    plot(Sectors.entrepreneurial_profits_net_of_interest_expenses(:, ~idx_sectors_with_negative_profits), 'LineWidth', 2);
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sectors;
    clickableLegend(Parameters.Sectors.names(~idx_sectors_with_negative_profits),'Location','best', 'FontSize', 13);
    title(sprintf('Sectors with only positive profits (%s scale)', y_scale_metrics), 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);
    
    % NEGATIVE VALUES
    sbp = subplot(1,2,2);
    plot(Sectors.entrepreneurial_profits_net_of_interest_expenses(:, idx_sectors_with_negative_profits), 'LineWidth', 2);
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sectors;
    clickableLegend(Parameters.Sectors.names(idx_sectors_with_negative_profits),'Location','best', 'FontSize', 13);
    title('Sectors with negative or null profits (linear scale)', 'FontSize', 15);
    set(gca,'fontsize', 15);    


    %% 1.4.1.2  profits composition detailed

    % Here we show the composition of the measure of profits that sectors will then split into dividends and retained profits.
    % These profits are defined as follows
    % Profits = Inflows - Outflows 
            % = (Sales + Subsidies) - (Historic costs + Taxes + Interest expenses)

    % Legend
    legend_text_profits = [];
    legend_text_profits{1,1} = 'PROFITS'; 
    legend_text_profits{1,2} = 'sales';
    legend_text_profits{1,3} = 'subsidies';
    legend_text_profits{1,4} = 'historic costs';
    legend_text_profits{1,5} = 'taxes';
    legend_text_profits{1,6} = 'interest expenses';     
    
    
    for f = 1 : nr_figures_for_sectoral_subplots
      
        figure('Name',sprintf('%s_1.4.1.2.%d_profits_composition', figures_name, f));
        sgtitle(sprintf('---------- SECTORS'' PROFITS COMPOSITION (%s scale) ----------', y_scale_metrics), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
            
        % Number of subplots in current figure. In the last figure, this value will be <= max_nr_subplots_per_figure
        if f < nr_figures_for_sectoral_subplots        
            nr_subplots_current_figure = max_nr_subplots_per_figure;
        else % i.e. when f == nr_figures_for_sectoral_subplots
            if mod(Parameters.Sectors.nr, max_nr_subplots_per_figure) ~= 0  % mod(a,m) returns the remainder after division of a by m. Example: mod(23,5) yields 3
                nr_subplots_current_figure = mod(Parameters.Sectors.nr, max_nr_subplots_per_figure); 
            else
                nr_subplots_current_figure = max_nr_subplots_per_figure;
            end
        end
        
    
        for j = 1 : nr_subplots_current_figure
    
            idx_sector = (f-1) * max_nr_subplots_per_figure + j;
        
            subplot(nr_rows, nr_columns, j);
    
            hold on
            plot(Sectors.entrepreneurial_profits_net_of_interest_expenses(:, idx_sector), 'LineWidth', 3);
            plot(Sectors.sales_nominal(idx_sector, :)', 'LineWidth', 2);
            plot(Sectors.govt_subsidies(:, idx_sector), 'LineWidth', 2);
            plot(- Sectors.historic_costs(:, idx_sector), 'LineWidth', 2);
            plot(- Sectors.taxes(:, idx_sector), 'LineWidth', 2);
            plot(- Sectors.interest_expenses(:, idx_sector), 'LineWidth', 2);                       
            hold off 
            
            title(Parameters.Sectors.names(idx_sector), 'FontSize', 15);
            legend(legend_text_profits,'Location','best', 'FontSize', 12);            
            
            set(gca,'fontsize', 13);
            set(gca, 'yscale', y_scale_metrics);
        end
    
    end


    %% 1.4.2.0  prices

    figure('Name', sprintf('%s_1.4.2.0_prices', figures_name));        

    ax = axes();
    plot(Sections.prices, 'LineWidth', 2);
    ax.LineStyleOrder = my_lines_styles; 
    ax.ColorOrder = my_colors_sections;
    title(sprintf('Prices (%s scale)', y_scale_metrics), 'FontSize', 20);
    %xlim([1 Parameters.T]);
    xticks(0:10:Parameters.T);
    legend(Parameters.Sections.names,'Location','best', 'FontSize', 14);
    set(gca,'fontsize', 14);
    set(gca, 'yscale', y_scale_metrics);
    
    
    %% 1.4.2.1  detailed pricing
    
    figure('Name', sprintf('%s_1.4.2.1_sectors_pricing', figures_name));
    sgtitle('----------- PRICE SETTING ----------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
    
    
    % sbp = subplot(1,3,1);
    % plot(Sectors.prices, 'LineWidth', 2);
    % sbp.LineStyleOrder = my_lines_styles; 
    % sbp.ColorOrder = my_colors_sectors;
    % title(sprintf('Prices (%s scale)', y_scale_metrics), 'FontSize', 20);
    % xticks(0:10:Parameters.T);
    % legend(Parameters.Sectors.names,'Location','best', 'FontSize', 11);
    % set(gca,'fontsize', 13);
    % set(gca, 'yscale', y_scale_metrics);
    
    
    sbp = subplot(1,2,1);
    plot(Sectors.unit_costs, 'LineWidth', 2);
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sectors;
    title(sprintf('Unit costs (%s scale)', y_scale_metrics), 'FontSize', 20);
    xticks(0:10:Parameters.T);
    legend(Parameters.Sectors.names,'Location','best', 'FontSize', 11);
    set(gca,'fontsize', 13);
    set(gca, 'yscale', y_scale_metrics);


    %% 1.4.2.2  unit costs
    
    figure('Name', sprintf('%s_1.4.2.2_unit_costs', figures_name));
    sgtitle(sprintf('----------- UNIT COSTS (%s scale).. ----------', y_scale_metrics), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
    
    % INTERMEDIATE INPUTS UNIT COSTS
    sp1 = subplot(1,2,1);
    plot(Sectors.intermediate_inputs_unit_costs, 'LineWidth', 2);
    sp1.LineStyleOrder = my_lines_styles; 
    sp1.ColorOrder = my_colors_sectors;
    title('..of intermediate inputs', 'FontSize', 20);
    xticks(0:10:Parameters.T);
    clickableLegend(Parameters.Sectors.names,'Location','best', 'FontSize', 11);
    set(gca,'fontsize', 13);
    set(gca, 'yscale', y_scale_metrics);
    
    % CAPITAL DEPRECIATION UNIT COSTS
    sp2 = subplot(1,2,2);
    plot(Sectors.capital_depreciation_unit_costs, 'LineWidth', 2);
    sp2.LineStyleOrder = my_lines_styles; 
    sp2.ColorOrder = my_colors_sectors;
    title('..of capital depreciation', 'FontSize', 20);
    xticks(0:10:Parameters.T);
    clickableLegend(Parameters.Sectors.names,'Location','best', 'FontSize', 11);
    set(gca,'fontsize', 13);
    set(gca, 'yscale', y_scale_metrics);

    % Set the y-axis limits of the two subplots to be equal
    linkaxes([sp1 sp2],'y')


    %% 1.4.3  electricity pricing

    figure('Name', sprintf('%s_1.4.3_electricity_pricing', figures_name));

    sp1 = subplot(1,2,1);
    plot(Divisions.shadow_prices(:, Parameters.Divisions.idx_electricity_producing), 'LineWidth', 2);    
    sp1.ColorOrder = my_colors_electricity_divisions;
    title('Divisions'' shadow prices', 'FontSize', 20);
    xticks(0:10:Parameters.T);
    clickableLegend(Parameters.Divisions.names(Parameters.Divisions.idx_electricity_producing), 'Location', 'best', 'FontSize', 13);
    set(gca,'fontsize', 13);
    set(gca, 'yscale', y_scale_metrics);

    sp2 = subplot(1,2,2);
    hold on
    plot(Sections.prices(:, Parameters.Sections.idx_electricity_producing), 'LineWidth', 5);
    plot(Sectors.shadow_prices(:, Parameters.Sectors.idx_electricity_producing), 'LineWidth', 2);
    hold off
    title('Electricity price and Sectors'' shadow prices', 'FontSize', 20);
    xticks(0:10:Parameters.T);
    legend([Parameters.Sections.names(Parameters.Sections.idx_electricity_producing); Parameters.Sectors.names(Parameters.Sectors.idx_electricity_producing)], 'Location', 'best', 'FontSize', 13);
    set(gca,'fontsize', 13);
    set(gca, 'yscale', y_scale_metrics);

    % Set the y-axis limits of the two subplots to be equal
    linkaxes([sp1 sp2],'y')
    
    
    %% 1.5.1.1  nominal capital; average net worth, debt, and leverage across sectors
    
    figure('Name', sprintf('%s_1.5.1.1_sectors_balance_sheet', figures_name));
    
    % AVERAGE NET WORTH, DEBT, AND LEVERAGE ACROSS SECTORS
    legend_text_balance_sheet = [];
    legend_text_balance_sheet{1,1} = "net worth";
    legend_text_balance_sheet{1,2} = "debt";
    legend_text_balance_sheet{1,3} = "leverage";
    subplot(1,2,1);
    hold on
    plot(mean(Sectors.net_worth, 2), 'LineWidth', 2);
    plot(mean(Sectors.loans_stock, 2), 'LineWidth', 2);
    plot(mean(Sectors.leverage, 2), 'LineWidth', 2);
    hold off
    title('AVERAGE OVER SECTORS', 'FontSize', 15);
    legend(legend_text_balance_sheet, 'Location', 'best', 'FontSize', 11);
    set(gca,'fontsize', 13);

    % SECTORS' NOMINAL CAPITAL
    sbp = subplot(1,2,2);
    plot(Sectors.tot_capital_nominal, 'LineWidth', 1.5);
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sectors;
    clickableLegend(Parameters.Sectors.names,'Location','best', 'FontSize', 11);
    title(sprintf('NOMINAL CAPITAL (%s scale)', y_scale_metrics), 'FontSize', 15);
    set(gca,'fontsize', 13);
    set(gca, 'yscale', y_scale_metrics);


    %% 1.5.1.2  leverage
    
    figure('Name', sprintf('%s_1.5.1.2_leverage', figures_name));
    sgtitle('---------- LEVERAGE ----------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');        
    
    sectors_threshold_leverage = Parameters.Sectors.leverage_target * ones(Parameters.T, 1);

    idx_sectors_with_negative_leverage = any(Sectors.leverage <= 0);

    % POSITIVE VALUES    
    sbp = subplot(1,2,1);
    hold on
    plot(Sectors.leverage(:, ~idx_sectors_with_negative_leverage), 'LineWidth', 2);    
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sectors;
    b = plot(sectors_threshold_leverage, 'LineStyle', '-', 'LineWidth', 5, 'Color', 'black');
    hold off
    legend_text_sectors_with_leverage = [Parameters.Sectors.names(~idx_sectors_with_negative_leverage); 'THRESHOLD'];
    clickableLegend(legend_text_sectors_with_leverage, 'Location', 'best', 'FontSize', 13);
    title(sprintf('Sectors with only positive leverage (%s scale)', y_scale_metrics), 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);
    uistack(b, 'bottom') % puts line from plot b in the background
    
    % NEGATIVE VALUES
    sbp = subplot(1,2,2);
    hold on
    plot(Sectors.leverage(:, idx_sectors_with_negative_leverage), 'LineWidth', 2);    
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sectors;
    b = plot(sectors_threshold_leverage, 'LineStyle', '-', 'LineWidth', 5, 'Color', 'black');
    hold off
    legend_text_sectors_with_leverage = [Parameters.Sectors.names(idx_sectors_with_negative_leverage); 'THRESHOLD'];
    clickableLegend(legend_text_sectors_with_leverage, 'Location', 'best', 'FontSize', 13);
    title('Sectors with negative or null leverage (linear scale)', 'FontSize', 15);
    set(gca,'fontsize', 15);    


    %% 1.5.1.3  net worth

    figure('Name', sprintf('%s_1.5.1.3_net_worth', figures_name));
    sgtitle('---------- NET WORTH ----------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');                

    idx_sectors_with_negative_net_worth = any(Sectors.net_worth <= 0);

    % POSITIVE VALUES
    sbp = subplot(1,2,1);
    plot(Sectors.net_worth(:, ~idx_sectors_with_negative_net_worth), 'LineWidth', 2);
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sectors;
    clickableLegend(Parameters.Sectors.names(~idx_sectors_with_negative_net_worth),'Location','best', 'FontSize', 13);
    title(sprintf('Sectors with only positive net worth (%s scale)', y_scale_metrics), 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);
    
    % NEGATIVE VALUES
    sbp = subplot(1,2,2);
    plot(Sectors.net_worth(:, idx_sectors_with_negative_net_worth), 'LineWidth', 2);
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sectors;
    clickableLegend(Parameters.Sectors.names(idx_sectors_with_negative_net_worth),'Location','best', 'FontSize', 13);
    title('Sectors with negative or null net worth (linear scale)', 'FontSize', 15);
    set(gca,'fontsize', 15);       


    %% 1.5.1.4  deposits and loans
    
    figure('Name', sprintf('%s_1.5.1.4_sectors_balance_sheet', figures_name));
    
    % DEPOSITS
    sbp = subplot(1,2,1);
    plot(Sectors.deposits, 'LineWidth', 1.5);
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sectors;
    clickableLegend(Parameters.Sectors.names,'Location','best', 'FontSize', 11);
    title(sprintf('DEPOSITS (%s scale)', y_scale_metrics), 'FontSize', 15);
    set(gca,'fontsize', 13);
    set(gca, 'yscale', y_scale_metrics);
    
    % LOANS
    sbp = subplot(1,2,2);
    plot(Sectors.loans_stock, 'LineWidth', 1.5);
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sectors;
    clickableLegend(Parameters.Sectors.names,'Location','best', 'FontSize', 11);
    title(sprintf('STOCK OF LOANS (%s scale)', y_scale_metrics), 'FontSize', 15);
    set(gca,'fontsize', 13);
    set(gca, 'yscale', y_scale_metrics);


    %% 1.5.1.5  assets and liabilities

    % Legend
    legend_text_balance_sheet = [];
    legend_text_balance_sheet{1,1} = 'capital stock'; 
    legend_text_balance_sheet{1,2} = 'inventories';
    legend_text_balance_sheet{1,3} = 'deposits';
    legend_text_balance_sheet{1,4} = 'loans';        
    
    
    for f = 1 : nr_figures_for_sectoral_subplots
      
        figure('Name',sprintf('%s_1.5.1.5.%d_balance_sheet', figures_name, f));
        sgtitle(sprintf('---------- SECTORS'' BALANCE SHEET COMPOSITION (%s scale) ----------', y_scale_metrics), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
            
        % Number of subplots in current figure. In the last figure, this value will be <= max_nr_subplots_per_figure
        if f < nr_figures_for_sectoral_subplots        
            nr_subplots_current_figure = max_nr_subplots_per_figure;
        else % i.e. when f == nr_figures_for_sectoral_subplots
            if mod(Parameters.Sectors.nr, max_nr_subplots_per_figure) ~= 0  % mod(a,m) returns the remainder after division of a by m. Example: mod(23,5) yields 3
                nr_subplots_current_figure = mod(Parameters.Sectors.nr, max_nr_subplots_per_figure); 
            else
                nr_subplots_current_figure = max_nr_subplots_per_figure;
            end
        end
        
    
        for j = 1 : nr_subplots_current_figure
    
            idx_sector = (f-1) * max_nr_subplots_per_figure + j;            
        
            subplot(nr_rows, nr_columns, j);
    
            hold on
            plot(Sectors.tot_capital_nominal(:, idx_sector), 'LineWidth', 2);
            plot(Sectors.inventories_nominal(idx_sector, :)', 'LineWidth', 2);
            plot(Sectors.deposits(:, idx_sector), 'LineWidth', 2);
            plot(Sectors.loans_stock(:, idx_sector), 'LineWidth', 2, 'LineStyle', '--');                                
            hold off 
            
            title(Parameters.Sectors.names(idx_sector), 'FontSize', 15);
            legend(legend_text_balance_sheet,'Location','best', 'FontSize', 12);            
            
            set(gca,'fontsize', 13);
            set(gca, 'yscale', y_scale_metrics);
        end
    
    end


    %% 1.5.2.1  dividends and retained profits: total across sectors
    
    figure('Name', sprintf('%s_1.5.2.1_dividends', figures_name));
    
    legend_text_dividends = [];
    legend_text_dividends{1,1} = "dividends";
    legend_text_dividends{1,2} = "retained profits";    
    hold on
    plot(sum(Sectors.dividends, 2), 'LineWidth', 2);
    plot(sum(Sectors.retained_profits, 2), 'LineWidth', 2);
    hold off
    title('SECTORS TOTALS', 'FontSize', 15);    
    legend(legend_text_dividends, 'Location', 'best', 'FontSize', 14);
    set(gca,'fontsize', 13);


    %% 1.5.2.2  dividends: detail
    
    figure('Name', sprintf('%s_1.5.2.2_dividends', figures_name));
    sgtitle('---------- DIVIDENDS ----------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');  
    
    idx_sectors_with_null_dividends = any(Sectors.dividends == 0);

    % SECTORS WITH ALWAYS POSITIVE DIVIDENDS
    sbp = subplot(1,2,1);
    plot(Sectors.dividends(:, ~idx_sectors_with_null_dividends), 'LineWidth', 1.5);
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sectors;
    clickableLegend(Parameters.Sectors.names(~idx_sectors_with_null_dividends),'Location','best', 'FontSize', 15);
    title('SECTORS WITH ALWAYS POSITIVE DIVIDENDS', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);

    % SECTORS WITH NULL DIVIDENDS
    sbp = subplot(1,2,2);
    plot(Sectors.dividends(:, idx_sectors_with_null_dividends), 'LineWidth', 1.5);
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sectors;
    clickableLegend(Parameters.Sectors.names(idx_sectors_with_null_dividends),'Location','best', 'FontSize', 15);
    title('SECTORS WITH NULL DIVIDENDS', 'FontSize', 15);
    set(gca,'fontsize', 15);


    %% 1.5.2.3  dividend payout ratio

    figure('Name', sprintf('%s_1.5.2.3_dividend_payout_ratio', figures_name));        

    ax = axes();
    plot(Sectors.dividend_payout_ratio, 'LineWidth', 2);
    ax.LineStyleOrder = my_lines_styles; 
    ax.ColorOrder = my_colors_sectors;
    title('DIVIDEND PAYOUT RATIO', 'FontSize', 20);        
    clickableLegend(Parameters.Sectors.names,'Location','best', 'FontSize', 14);
    set(gca,'fontsize', 14);


    %% 1.5.2.4  retained profits: detail
    
    figure('Name', sprintf('%s_1.5.2.4_retained_profits', figures_name));
    sgtitle('---------- RETAINED PROFITS ----------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');        
    
    idx_sectors_with_negative_retained_profits = any(Sectors.retained_profits <= 0);

    % POSITIVE VALUES
    sbp = subplot(1,2,1);
    plot(Sectors.retained_profits(:, ~idx_sectors_with_negative_retained_profits), 'LineWidth', 2);
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sectors;
    clickableLegend(Parameters.Sectors.names(~idx_sectors_with_negative_retained_profits),'Location','best', 'FontSize', 13);
    title(sprintf('Sectors with only positive retained profits (%s scale)', y_scale_metrics), 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);
    
    % NEGATIVE VALUES
    sbp = subplot(1,2,2);
    plot(Sectors.retained_profits(:, idx_sectors_with_negative_retained_profits), 'LineWidth', 2);
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sectors;
    clickableLegend(Parameters.Sectors.names(idx_sectors_with_negative_retained_profits),'Location','best', 'FontSize', 13);
    title('Sectors with negative or null retained profits (linear scale)', 'FontSize', 15);
    set(gca,'fontsize', 15);  
    
    
    %% 1.6.1  received vs demanded loans        
    
    % LEGEND
    legend_text = [];
    legend_text{1,1} = 'received loans';
    legend_text{1,2} = 'demanded loans';    
    
    
    % Creating the figures
    for f = 1 : nr_figures_for_sectoral_subplots
      
        figure('Name', sprintf('%s_1.6.1.%d_loans', figures_name, f));
        sgtitle(sprintf('---------- RECEIVED VS DEMANDED LOANS (%s scale) ----------', y_scale_metrics), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');        
            
        % Number of subplots in current figure. In the last figure, this value will be <= max_nr_subplots_per_figure
        if f < nr_figures_for_sectoral_subplots        
            nr_subplots_current_figure = max_nr_subplots_per_figure;
        else % i.e. when f == nr_figures_for_sectoral_subplots
            if mod(Parameters.Sectors.nr, max_nr_subplots_per_figure) ~= 0  % mod(a,m) returns the remainder after division of a by m. Example: mod(23,5) yields 3
                nr_subplots_current_figure = mod(Parameters.Sectors.nr, max_nr_subplots_per_figure); 
            else
                nr_subplots_current_figure = max_nr_subplots_per_figure;
            end
        end
        
    
        for j = 1 : nr_subplots_current_figure
    
            idx_sector = (f-1) * max_nr_subplots_per_figure + j;   
        
            subplot(nr_rows, nr_columns, j);
    
            hold on
            plot(Sectors.loans_received_flow(:, idx_sector), 'LineWidth', 4);    
            plot(Sectors.loans_demand_flow(:, idx_sector), 'LineWidth', 2);            
            hold off
            
            title(Parameters.Sectors.names(idx_sector), 'FontSize', 15);
            set(gca,'fontsize', 13);
            set(gca, 'yscale', y_scale_metrics);
        end
        
        legend(legend_text, 'Location', 'best', 'FontSize', 15);
    end
    
    
    %% 1.6.2  aggregate credit constraints
    
    figure('Name', sprintf('%s_1.6.2_sectors_credit_constraints', figures_name));
    
    legend_text_credit = [];
    legend_text_credit{1,1} = 'demand (left axis)';
    legend_text_credit{1,2} = 'supply (left axis)';
    legend_text_credit{1,3} = 'max supply (left axis)';
    legend_text_credit{1,4} = 'credit constraint (right axis)';
    
    hold on
    yyaxis left
    plot(sum(Sectors.loans_demand_flow, 2), 'LineStyle', '-', 'LineWidth', 6, 'Color', '#A2142F');
    plot(sum(Sectors.loans_received_flow, 2), 'LineStyle', '-', 'LineWidth', 4, 'Color', '#EDB120');
    plot(Bank.loans_max_supply_flow, 'LineStyle', '--', 'LineWidth', 2, 'Color', '#4DBEEE');
    set(gca, 'yscale', y_scale_metrics);
    yyaxis right
    plot(Bank.proportion_supply_vs_demanded_loans, 'LineStyle', ':', 'LineWidth', 2, 'Color', '#77AC30');
    hold off
    title(sprintf('LOANS (%s scale)', y_scale_metrics), 'FontSize', 20);
    legend(legend_text_credit, 'Location', 'best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    
    % Force the two vertical axis ticks' colors to be black (otherwise Matlab would assign them red and blue colors)
    ax = gca;
    ax.YAxis(1).Color = 'k';
    ax.YAxis(2).Color = '#77AC30';           
    
    
    %% 1.6.3  aggregate deposits and loans
    
    legend_text_9 = [];
    legend_text_9{1,1} = 'deposits';
    legend_text_9{1,2} = 'loans'' stock';
    legend_text_9{1,3} = 'new loans';
    legend_text_9{1,4} = 'repaid loans';
    legend_text_9{1,5} = 'investments';
    
    figure('Name', sprintf('%s_1.6.3_sectors_totals_dep&loans', figures_name));
    
    hold on
    p1 = plot(sum(Sectors.deposits, 2), 'LineWidth', 6);
    p2 = plot(Bank.loans_stock, 'LineWidth', 2);
    p5 = plot(sum(Sectors.loans_received_flow, 2), 'LineWidth', 2);
    p3 = plot(sum(Sectors.loans_repaid, 2), 'LineWidth', 2);
    p4 = plot(sum(Sectors.investments_costs, 2), 'LineWidth', 2);
    hold off
    % label(p1, 'deposits', 'FontSize', 15);
    % label(p2, 'loans stock', 'location', 'center', 'slope', 'FontSize', 15);
    % label(p3, 'loans repaid', 'location', 'right', 'slope', 'FontSize', 15);
    % label(p4, 'investment', 'location', 'right', 'slope', 'FontSize', 15);
    % label(p5, 'loans flow', 'location', 'center', 'slope', 'FontSize', 15);
    title(sprintf('SECTORS'' TOTALS (%s scale)', y_scale_metrics), 'FontSize', 15);
    legend(legend_text_9,'Location','best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);
    
    
    % FOR A SPECIFIC SECTOR
    % figure;
    % hold on
    % p1 = plot(Sectors.deposits(:, 5), 'LineWidth', 4);
    % p2 = plot(Sectors.loans_stock(:, 5), 'LineWidth', 2);
    % p5 = plot(Sectors.loans_received_flow(:, 5), 'LineWidth', 2);
    % p3 = plot(Sectors.loans_repaid(:, 5), 'LineWidth', 2);
    % p4 = plot(Sectors.investments_costs(:, 5), 'LineWidth', 2);
    % hold off
    % label(p1, 'deposits', 'FontSize', 15);
    % label(p2, 'loans stock', 'location', 'right', 'slope', 'FontSize', 15);
    % label(p3, 'loans repaid', 'location', 'right', 'slope', 'FontSize', 15);
    % label(p4, 'investment', 'location', 'right', 'slope', 'FontSize', 15);
    % label(p5, 'loans flow', 'location', 'right', 'slope', 'FontSize', 15);
    % title('SECTORS TOTALS', 'FontSize', 15);         


    %% 1.7.1  deflated investment costs
    
    figure('Name', sprintf('%s_1.7.1_investment_costs', figures_name));
    
    ax = axes();
    plot(Sectors.investments_costs_defl, 'LineWidth', 3); 
    ax.LineStyleOrder = my_lines_styles; 
    ax.ColorOrder = my_colors_sectors;
    title('SECTORS'' DEFLATED INVESTMENT COSTS', 'FontSize', 20);
    clickableLegend(Parameters.Sectors.names,'Location','best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);    


    %% 1.7.2  NPV

    figure('Name', sprintf('%s_1.7.2_NPV', figures_name));
    
    sbp = subplot(1,2,1);
    plot(Divisions.NPV, 'LineWidth', 2); 
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_divisions;
    title('DIVISIONS'' NPV', 'FontSize', 20);
    clickableLegend(Parameters.Divisions.names,'Location','best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', 'linear');

    sbp = subplot(1,2,2);
    idx_divisions_with_negative_NPV = any(Divisions.NPV < 0);
    plot(Divisions.NPV(:, idx_divisions_with_negative_NPV), 'LineWidth', 2); 
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_divisions;
    title('DIVISIONS WITH NEGATIVE NPV', 'FontSize', 20);
    clickableLegend(Parameters.Divisions.names(idx_divisions_with_negative_NPV),'Location','best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', 'linear');


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%  HOUSEHOLDS' PLOTS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% 2.1  stocks and flows
    
    legend_text_hhs = [];
    legend_text_hhs{1,1} = 'income';
    legend_text_hhs{1,2} = 'deposits';
    legend_text_hhs{1,3} = 'final demand';
    legend_text_hhs{1,4} = 'consumption';
    
    figure('Name', sprintf('%s_2.1_hh_stocks_flows', figures_name));
    
    hold on
    p1 = plot(sum(Households.income, 2), 'LineWidth', 2);
    p2 = plot(sum(Households.deposits, 2), 'LineWidth', 2);
    p3 = plot(sum(Households.final_demand_budget, 2), 'LineWidth', 4);
    p4 = plot(sum(Households.consumption_expenditures, 2), 'LineWidth', 2);
    hold off
    title(sprintf('HOUSEHOLDS (%s scale)', y_scale_metrics), 'FontSize', 20);
    xlim([1 Parameters.T]);
    xticks(0:10:Parameters.T);
    set(gca,'fontsize', 17);
    set(gca, 'yscale', y_scale_metrics);
    legend(legend_text_hhs,'Location','best');
    
    
    % USEFUL IN CASE WE HAVE MORE THAN ONE HHS
    
    % figure;
    % ax = axes;
    % my_colors = rand(Parameters.Households.nr, 3);
    % ax.ColorOrder = my_colors;
    % hold on
    % plot(Households.income, '-', 'LineWidth',1); 
    % plot(Households.deposits, '--', 'LineWidth',1);
    % plot(Households.consumption_expenditures, ':', 'LineWidth', 2);
    % title('households income (solid), deposits (dashed), consumption (dotted)'); xticks(1:1:Parameters.T);
    % legend_text_households = [];
    % for j = 1:Parameters.Households.nr
    %     legend_text_households{1,j} = ['household ', num2str(j)]; 
    % end
    % clear j
    % legend(legend_text_households,'Location','best');
    % hold off
    % clear my_colors
    
    
    %% 2.2  nominal demand and consumption
    
    figure('Name', sprintf('%s_2.2_hh_demand_consumption', figures_name));
    
    
    % NOMINAL DEMAND AT THE SECTIONAL LEVEL
    
    sbp1 = subplot(1,2,1); 
    plot(reshape(sum(Sections.demand_from_hhs_nominal, 2), Parameters.Sections.nr, Parameters.T)', 'LineWidth', 2);
    sbp1.LineStyleOrder = my_lines_styles; 
    sbp1.ColorOrder = my_colors_sections;
    title(sprintf('HOUSEHOLDS NOMINAL DEMAND (%s scale)', y_scale_metrics), 'FontSize', 20);
    clickableLegend(Parameters.Sections.names,'Location','best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);
    
    
    % NOMINAL CONSUMPTION AT THE SECTIONAL LEVEL
    
    sbp2 = subplot(1,2,2); 
    plot(reshape(sum(Sections.sales_to_hhs_nominal, 2), Parameters.Sections.nr, Parameters.T)', 'LineWidth', 2);
    sbp2.LineStyleOrder = my_lines_styles; 
    sbp2.ColorOrder = my_colors_sections;
    title(sprintf('HOUSEHOLDS NOMINAL CONSUMPTION (%s scale)', y_scale_metrics), 'FontSize', 20);
    clickableLegend(Parameters.Sections.names,'Location','best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);
    
    
    % Set the y-axis limits of the two subplots to be equal
    linkaxes([sbp1 sbp2],'y')


    %% 2.3  nominal demand

    % NOMINAL DEMAND AT THE SECTIONAL LEVEL
    figure('Name', sprintf('%s_2.3_hh_nominal_demand', figures_name));
    ax = axes();     
    plot(reshape(sum(Sections.demand_from_hhs_nominal(:, :, Parameters.valid_results_time_span), 2), Parameters.Sections.nr, [])', 'LineWidth', 3);   
    ax.LineStyleOrder = my_lines_styles; 
    ax.ColorOrder = my_colors_sections;
    title(sprintf('HOUSEHOLDS NOMINAL DEMAND (%s scale)', y_scale_metrics), 'FontSize', 20);
    clickableLegend(Parameters.Sections.names,'Location','best', 'FontSize', 18);
    set(gca,'fontsize', 18);
    set(gca, 'yscale', y_scale_metrics);    
    xticks(0 : 10 : Parameters.valid_results_time_span_length);    
    xlabel('years'); 
    set(gca,'XTickLabel', 2020 : 10 : 2080);


    %% 2.4  income sources

    legend_text_hhs_income = [];
    legend_text_hhs_income{1,1} = 'total income';
    legend_text_hhs_income{1,2} = 'sectors'' dividends';
    legend_text_hhs_income{1,3} = 'bank''s dividends';


    figure('Name', sprintf('%s_2.4_hhs_income_sources', figures_name));       

    hold on
    plot(sum(Households.income, 2), 'LineWidth', 4);
    plot(sum(Sectors.dividends, 2), 'LineWidth', 2);
    plot(Bank.dividends, 'LineWidth', 2);
    hold off
    
    title(sprintf('HOUSEHOLDS INCOME SOURCES (%s scale)', y_scale_metrics), 'FontSize', 20);
    
    set(gca,'fontsize', 18);    
    set(gca, 'yscale', y_scale_metrics);
    xticks(0:10:Parameters.T);    

    legend(legend_text_hhs_income,'Location','best');


    %% 2.5  physical demand relations

    figure('Name', sprintf('%s_2.5_phys_demand_relations', figures_name));   
    sgtitle('--------- HOUSEHOLD''S PHYSICAL DEMAND RELATIONS ---------', 'FontSize', 22, 'fontweight', 'bold', 'Color', 'black');            

    % IF PRICES DIDN'T IMPACT DEMAND
    sbp = subplot(1,2,1); 
    plot(Households.lambda_AIDS_autonomous_coefficients', 'LineWidth', 3); 
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sections;
    title('IF ELASTICITY WAS ZERO', 'FontSize', 20);
    legend(Parameters.Sections.names,'Location','best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    
    % AFTER PRICES IMPACT DEMAND
    sbp = subplot(1,2,2);
    plot(Households.phys_demand_relations', 'LineWidth', 3); 
    sbp.LineStyleOrder = my_lines_styles; 
    sbp.ColorOrder = my_colors_sections;
    title('AFTER CONSIDERING PRICES', 'FontSize', 20);
    legend(Parameters.Sections.names,'Location','best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%  BANK PLOTS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% 3.  bank
    
    figure('Name', sprintf('%s_3_bank', figures_name));
    sgtitle('----------- BANK ----------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
    
    
    legend_text_bank = [];
    legend_text_bank{1,1} = 'loans stock';
    legend_text_bank{1,2} = 'deposits';
    legend_text_bank{1,3} = 'reserves';
    legend_text_bank{1,4} = 'advances';
    legend_text_bank{1,5} = 'net worth';
    
    subplot(1,2,1);
    hold on
    p1 = plot(Bank.loans_stock, 'LineWidth', 2);
    p2 = plot(Bank.deposits, 'LineWidth', 2);
    p3 = plot(Bank.reserves_holdings, 'LineWidth', 2);
    p4 = plot(Bank.advances, 'LineWidth', 2);
    p5 = plot(Bank.net_worth, 'LineWidth', 2);
    hold off
    title(sprintf('ASSETS AND LIABILITIES (%s scale)', y_scale_metrics), 'FontSize', 20);
    xticks(0:10:Parameters.T);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);
    legend(legend_text_bank,'Location','best', 'FontSize', 14);
    % label(p1, 'Loans', 'slope', 'location', 'right', 'FontSize', 15);
    % label(p2, 'Deposits', 'slope', 'location', 'center', 'FontSize', 15);
    % label(p3, 'Reserves', 'slope', 'location', 'left', 'FontSize', 15);
    % label(p4, 'Advances', 'slope', 'location', 'right', 'FontSize', 15);
    % label(p5, 'Net Worth', 'slope', 'location', 'right', 'FontSize', 15);
    


    
    legend_text_bank_2 = [];
    legend_text_bank_2{1,1} = 'CAR';    
    legend_text_bank_2{1,2} = 'capital requirement';
    legend_text_bank_2{1,3} = 'CAR target';
    legend_text_bank_2{1,4} = 'loan rationing (< 1)';

    capital_requirement = Parameters.Bank.capital_requirement * ones(Parameters.T, 1); 
    CAR_target = Parameters.Bank.CAR_target * ones(Parameters.T, 1); 
    
    subplot(1,2,2);
    hold on
    %yyaxis left
    plot(Bank.CAR, 'LineWidth', 2);    
    plot(capital_requirement, 'LineWidth', 2);
    plot(CAR_target, 'LineWidth', 2);
    %yyaxis right
    plot(Bank.proportion_supply_vs_demanded_loans, 'LineWidth', 2);
    hold off
    title('RATIOS', 'FontSize', 15);
    xticks(0:10:Parameters.T);
    legend(legend_text_bank_2,'Location','best', 'FontSize', 14);
    set(gca,'fontsize', 15);



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%  GOV'T & CENTRAL BANK PLOTS  %%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% 4.0  gov't
   
    figure('Name', sprintf('%s_4.0_govt', figures_name));
    sgtitle('--------- GOVERNMENT ---------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
    
    
    % ASSETS & LIABILITIES
    
    legend_text_gov_1 = [];
    legend_text_gov_1{1,1} = 'Central bank loans';
    legend_text_gov_1{1,2} = 'Reserves';    

    subplot(1,3,1);
    hold on
    plot(Government.advances, 'LineWidth', 2);
    plot(Government.reserves_holdings, 'LineWidth', 2);    
    hold off
    title(sprintf('ASSETS & LIABILITIES - %s scale', y_scale_metrics), 'FontSize', 15);
    legend(legend_text_gov_1, 'Location', 'best');
    set(gca,'fontsize', 14);
    set(gca, 'yscale', 'linear');


    % FLOWS

    legend_text_gov_2 = [];
    legend_text_gov_2{1,1} = 'Consumption';    
    legend_text_gov_2{1,2} = 'Subsidies';
    legend_text_gov_2{1,3} = 'Taxes';

    subplot(1,3,2);
    hold on
    plot(Government.consumption_expenditures, 'LineWidth', 2);
    plot(Government.subsidies, 'LineWidth', 2);
    plot(Government.taxes, 'LineWidth', 2);
    hold off
    title(sprintf('FLOWS - %s scale', y_scale_metrics), 'FontSize', 15);
    legend(legend_text_gov_2, 'Location', 'best');
    set(gca,'fontsize', 14);
    set(gca, 'yscale', 'linear');


    % OTHER MEASURES
    
    legend_text_gov_3 = [];
    legend_text_gov_3{1,1} = 'Deficit-to-GDP ratio';
    legend_text_gov_3{1,2} = 'Debt-to-GDP ratio'; 
    legend_text_gov_3{1,3} = 'Tax rate';
    
    subplot(1,3,3);
    hold on
    plot(100 * Government.deficit_to_GDP_ratio, 'LineWidth', 2);
    plot(100 * Government.debt_to_GDP_ratio, 'LineWidth', 2);
    plot(100 * Government.sectors_tax_rate, 'LineWidth', 2);    
    hold off    
    ytickformat("percentage");
    title('OTHER MEASURES', 'FontSize', 15);
    legend(legend_text_gov_3, 'Location', 'best');
    set(gca,'fontsize', 14);    


    %% 5.1  central bank and SFC plots /1

    % figure('Name', sprintf('%s_5.1_SFC', figures_name));
    % 
    % subplot(1,2,1);
    % hold on
    % p1 = plot(CentralBank.advances, 'LineWidth', 2);
    % p2 = plot(CentralBank.reserves, 'LineWidth', 2);
    % hold off
    % title('VARIATION IN CENTRAL BANK MONEY', 'FontSize', 15);
    % %label(p1, 'Advances', 'location', 'center', 'slope', 'FontSize', 15);
    % %label(p2, 'Reserves', 'location', 'center', 'slope', 'FontSize', 15);
    % text_1 = '\color[rgb]{0.8500 0.3250 0.0980}\Delta Reserves_t \color{black}= \color[rgb]{0 0.4470 0.7410}\Delta Advances_t';
    % text(10, 1500, text_1, 'Interpreter', 'Tex', 'FontSize', 18, 'Color', 'k');
    % 
    % subplot(1,2,2);
    % x = 1:Parameters.T;
    % hold on
    % plot(x+1, Bank.deposits, 'LineWidth', 2);
    % plot(Bank.deposits, 'LineWidth', 2);
    % delta_bank_loans = NaN * ones(Parameters.T, 1);
    % for t = 2:Parameters.T
    %     delta_bank_loans(t) = Bank.loans_stock(t) - Bank.loans_stock(t-1);
    % end
    % plot(delta_bank_loans, 'LineWidth', 2);
    % flows = Government.consumption_expenditures - Government.taxes - Bank.profits_retained;
    % plot(flows, 'LineWidth', 2);
    % hold off
    % title('VARIATION IN PRIVATE MONEY', 'FontSize', 15);
    % % label(h1, '$$M_{t-1}$$', 'location', 'left', 'slope', 'FontSize', 19, 'interpreter','latex');
    % % label(h2, '$$M_t$$', 'location', 'center', 'slope', 'FontSize', 19, 'interpreter','latex');
    % % label(h3, '$$\Delta L_t$$', 'location', 'right', 'slope', 'FontSize', 19, 'interpreter','latex');
    % % label(h4, '$$G_t-T_t+GS_t-FU_b$$', 'location', 'center', 'slope', 'FontSize', 19, 'interpreter','latex');
    % 
    % text_2 = '\color[rgb]{0.8500 0.3250 0.0980}M_t \color{black}= \color[rgb]{0 0.4470 0.7410}M_{t-1} \color{black}+ \color[rgb]{0.9290 0.6940 0.1250}\DeltaL_t \color{black}+ \color[rgb]{0.4940 0.1840 0.5560}(G_t-T_t+GS_t-FU_b)';
    % text(10, 2000, text_2, 'Interpreter', 'Tex', 'FontSize', 18); 



    %% 5.2  central bank and SFC plots /2

    figure('Name', sprintf('%s_5.2_SFC', figures_name));
    
    
    % CENTRAL BANK MONEY
    legend_text_CB = [];
    legend_text_CB{1,1} = 'CB reserves';
    legend_text_CB{1,2} = 'CB advances';
    legend_text_CB{1,3} = 'bank reserves';
    legend_text_CB{1,4} = 'bank advances';
    legend_text_CB{1,5} = 'gov''t reserves';
    legend_text_CB{1,6} = 'gov''t advances';
    subplot(1,2,1);
    hold on
    plot(CentralBank.reserves, 'LineWidth', 4);
    plot(CentralBank.advances, 'LineWidth', 4);
    plot(Bank.reserves_holdings, 'LineWidth', 3, 'LineStyle', '--');
    plot(Bank.advances, 'LineWidth', 3, 'LineStyle', '--');
    plot(Government.reserves_holdings, 'LineWidth', 2, 'LineStyle', ':');
    plot(Government.advances, 'LineWidth', 2, 'LineStyle', ':');
    hold off
    title('VARIATION IN CENTRAL BANK MONEY (linear scale)', 'FontSize', 20);
    legend(legend_text_CB, 'Location', 'best', 'FontSize', 15);
    %label(p1, 'Advances', 'location', 'center', 'slope', 'FontSize', 15);
    %label(p2, 'Reserves', 'location', 'center', 'slope', 'FontSize', 15);
    text_1 = '\color[rgb]{0 0.4470 0.7410}\DeltaR_t \color{black}= \color[rgb]{0.8500 0.3250 0.0980}\DeltaA_t';
    text(0.05, 0.45, text_1, 'Interpreter', 'Tex', 'FontSize', 18, 'Color', 'k', 'Units', 'normalized');
    text_2 = '\color[rgb]{0 0.4470 0.7410}R = reserves \newline\color[rgb]{0.8500 0.3250 0.0980}A = advances';
    text(0.05, 0.55, text_2, 'FontSize', 16, 'Color', 'k', 'Units', 'normalized');
    set(gca,'fontsize', 15);
    set(gca, 'yscale', 'linear');
    
    
    
    % PRIVATE MONEY

    % If, in the SFC's Transactions Flow Matrix, you sum the gov't column with the Bank's capital account column, ..
    % ..you get rid of central bank money and obtain the following equivalence, describing the variation in private money (bank deposits):
        % Delta(Deposits) = Delta(Loans) + (Other flows)
    % ..where (Other flows) = (Gov't deficit) - (Bank's retained profits)           
    
    subplot(1,2,2);    
    hold on
    % Variation bank deposits
    plot([NaN; diff(Bank.deposits)], 'LineWidth', 2);
    % Variation bank loans
    plot([NaN; diff(Bank.loans_stock)], 'LineWidth', 2);
    % Other flows
    plot((Government.deficit - Bank.profits_retained), 'LineWidth', 2);
    hold off
    title('VARIATION IN PRIVATE MONEY (linear scale)', 'FontSize', 20);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', 'linear');
    % label(h1, '$$M_{t-1}$$', 'location', 'left', 'slope', 'FontSize', 19, 'interpreter','latex');
    % label(h2, '$$M_t$$', 'location', 'center', 'slope', 'FontSize', 19, 'interpreter','latex');
    % label(h3, '$$\Delta L_t$$', 'location', 'right', 'slope', 'FontSize', 19, 'interpreter','latex');
    % label(h4, '$$G_t-T_t+GS_t-FU_b$$', 'location', 'center', 'slope', 'FontSize', 19, 'interpreter','latex');
    
    text_3 = '\color[rgb]{0 0.4470 0.7410}\DeltaM_t \color{black}= \color[rgb]{0.8500 0.3250 0.0980}\DeltaL_t \color{black}+ \color[rgb]{0.9290 0.6940 0.1250}(DEF_t-FU_{b,t})';
    text(0.05, 0.9, text_3, 'Interpreter', 'Tex', 'FontSize', 16, 'Units', 'normalized');
    text_4 = '\color[rgb]{0 0.4470 0.7410}M = bank deposits \newline\color[rgb]{0.8500 0.3250 0.0980}L = bank loans \newline\color[rgb]{0.9290 0.6940 0.1250}DEF = govt deficit \newlineFU = bank retained profits';    
    text(0.05, 0.7, text_4, 'Interpreter', 'Tex', 'FontSize', 16, 'Units', 'normalized');


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%  GREEN VARIABLES PLOTS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% 6.1  green electricity investments

    % if Rules.electricity_sector_aggregation ~= "one_electricity_sector"
        % figure('Name', sprintf('%s_6.1_green_investments', figures_name));
        % 
        % subplot(1,3,1);
        % hold on
        % p1 = plot(Sectors.investments_phys(:, Parameters.Sectors.idx_green), 'LineWidth', 2);         
        % p3 = plot(Sectors.investments_costs(:, Parameters.Sectors.idx_green), 'LineWidth', 2);
        % hold off
        % title('GREEN INVESTMENTS and SUBSIDIES', 'FontSize', 15);
        % label(p1, 'green investments real (physical)', 'FontSize', 15);
        % label(p2, 'green subsidies', 'location', 'right', 'slope', 'FontSize', 15);
        % label(p3, 'green investment costs', 'location', 'right', 'slope', 'FontSize', 15);
        % set(gca,'fontsize', 13);

    % end


    %% 6.2  green share

    if Rules.electricity_sector_aggregation ~= "one_electricity_sector"

        figure('Name', sprintf('%s_6.2_green_share', figures_name));
    
        legend_green_share = [];
        legend_green_share{1,1} = 'production';
        legend_green_share{1,2} = 'sales (interindustry & final)';
        legend_green_share{1,3} = 'target';
        hold on
        plot(100 * Economy.green_share_production, 'LineWidth', 5);
        plot(100 * Economy.green_share_sales, 'LineWidth', 3);
        plot(100 * Parameters.Sectors.target_green_share, 'LineWidth', 3);        
        hold off
        ytickformat("percentage");
        title('GREEN SHARE', 'FontSize', 15);
        legend(legend_green_share,'Location','best', 'FontSize', 12);
        set(gca,'fontsize', 13);

    end


    %% 6.3  divisions' weights

    if Rules.electricity_sector_aggregation == "many_electricity_sectors"
    
        % TARGET

        figure('Name', sprintf('%s_6.3.1_divisions_weights_target', figures_name));
        sgtitle('--------- TARGET WEIGHT OF EACH DIVISION WITHIN THE SECTOR ---------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
    
        subplot(1,2,1);
        plot(100 * Parameters.Divisions.target_sectoral_weights(:, Parameters.Divisions.idx_green'), 'LineWidth', 2);
        ytickformat("percentage");
        title('Green electricity divisions', 'FontSize', 15);
        legend(Parameters.Divisions.names(Parameters.Divisions.idx_green),'Location','best', 'FontSize', 14);
        set(gca,'fontsize', 15);
        
        subplot(1,2,2);
        plot(100 * Parameters.Divisions.target_sectoral_weights(:, Parameters.Divisions.idx_brown'), 'LineWidth', 2);
        ytickformat("percentage");
        title('Brown electricity divisions', 'FontSize', 15);
        legend(Parameters.Divisions.names(Parameters.Divisions.idx_brown),'Location','best', 'FontSize', 14);
        set(gca,'fontsize', 15);

       
        % ACTUAL    

        figure('Name', sprintf('%s_6.3.2_divisions_weights_actual', figures_name));
        sgtitle('--------- ACTUAL WEIGHT OF EACH DIVISION WITHIN THE SECTOR ---------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
    
        subplot(1,2,1);
        plot(100 * Divisions.sectoral_weights(:, Parameters.Divisions.idx_green'), 'LineWidth', 2);
        ytickformat("percentage");
        title('Green electricity divisions', 'FontSize', 15);
        legend(Parameters.Divisions.names(Parameters.Divisions.idx_green),'Location','best', 'FontSize', 14);
        set(gca,'fontsize', 15);
        
        subplot(1,2,2);
        plot(100 * Divisions.sectoral_weights(:, Parameters.Divisions.idx_brown'), 'LineWidth', 2);
        ytickformat("percentage");
        title('Brown electricity divisions', 'FontSize', 15);
        legend(Parameters.Divisions.names(Parameters.Divisions.idx_brown),'Location','best', 'FontSize', 14);
        set(gca,'fontsize', 15);

    end


    %% 6.4  coefficients development

    % These figures provide an intuitive way to check whether the exogenous changes to coefficients have been performed correctly.
    
    % In each of the following figures (except for the household), we create subplots for each IEA category ..
    % ..included in the structure "Parameters.Divisions.IEAcategory.names" (energy intensive, non-energy intensive, etc)       


    % EMISSION INTENSITIES  
    figure;
    sgtitle(sprintf('EMISSION INTENSITIES DEVELOPMENT ACROSS THE SIMULATION \n Percentage change compared to initial value'), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');    
    linkaxes_array = []; % useful to link y-axes across subplots
    clear sbp % If variable "sbp" had already been defined elsewhere, we clear it
    my_fieldnames = fieldnames(Parameters.Divisions.IEAcategory.names);
    for j = 1 : numel(my_fieldnames)
        sbp{j} = subplot(2,3,j);        
        sbp{j}.LineStyleOrder = my_lines_styles; 
        sbp{j}.ColorOrder = my_colors_divisions;        
        hold on
        idx_current_divisions = Parameters.Divisions.IEAcategory.idx.(my_fieldnames{j});            
        plot(100 * Divisions.emission_intensities_percentage_change(:, idx_current_divisions), 'LineWidth', 2)     
        ytickformat("percentage");        
        title(sprintf('IEA category: %s', strrep(my_fieldnames{j}, '_', ' ')), 'FontSize', 15);
        legend(Parameters.Divisions.names(idx_current_divisions),'Location', 'best', 'FontSize', 14);
        linkaxes_array = [linkaxes_array sbp{j}];
    end
    linkaxes(linkaxes_array, 'y')    


    % SHARE OF INITIAL TFC
    figure;
    sgtitle(sprintf('SHARE OF INITIAL TFC: DEVELOPMENT ACROSS THE SIMULATION \n Percentage of initial value'), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
    linkaxes_array = []; % useful to link y-axes across subplots
    clear sbp % If variable "sbp" had already been defined elsewhere, we clear it
    my_fieldnames = fieldnames(Parameters.Divisions.IEAcategory.names);
    for j = 1 : numel(my_fieldnames)
        sbp{j} = subplot(2,3,j);        
        sbp{j}.LineStyleOrder = my_lines_styles; 
        sbp{j}.ColorOrder = my_colors_divisions;        
        hold on
        idx_current_divisions = Parameters.Divisions.IEAcategory.idx.(my_fieldnames{j});            
        plot(100 * Divisions.share_of_initial_TFC(:, idx_current_divisions), 'LineWidth', 2)     
        ytickformat("percentage");        
        title(sprintf('IEA category: %s', strrep(my_fieldnames{j}, '_', ' ')), 'FontSize', 15);
        legend(Parameters.Divisions.names(idx_current_divisions),'Location', 'best', 'FontSize', 14);
        linkaxes_array = [linkaxes_array sbp{j}];
    end    
    linkaxes(linkaxes_array, 'y')


    % HOUSEHOLD'S DEMAND RELATIONS
    figure;    
    ax = axes();  
    plot(100 * Households.demand_relations_phys_percentage_change', 'LineWidth', 2)
    ytickformat("percentage");        
    ax.LineStyleOrder = my_lines_styles; 
    ax.ColorOrder = my_colors_divisions;
    title('HOUSEHOLD''S DEMAND RELATIONS DEVELOPMENT ACROSS THE SIMULATION', 'Percentage of initial value', 'FontSize', 15);
    legend(Parameters.Sections.names,'Location', 'best', 'FontSize', 14);
    

    
    %%%%%%%%%  TECHNICAL COEFFICIENTS  %%%%%%%%%    

    % Fossil fuels Sections
    for i = 1 : numel(Parameters.Sections.idx_fossil_fuels)
        figure;
        sgtitle(sprintf('Technical coefficients requirements from Section: %s \n Percentage change compared to initial value', ...
            Parameters.Sections.names(Parameters.Sections.idx_fossil_fuels(i))), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
        linkaxes_array = []; % useful to link y-axes across subplots
        clear sbp % If variable "sbp" had already been defined elsewhere, we clear it
        my_fieldnames = fieldnames(Parameters.Divisions.IEAcategory.names);
        for j = 1 : numel(my_fieldnames)
            sbp{j} = subplot(2,3,j);
            sbp{j}.LineStyleOrder = my_lines_styles; 
            sbp{j}.ColorOrder = my_colors_divisions;            
            hold on
            idx_current_divisions = Parameters.Divisions.IEAcategory.idx.(my_fieldnames{j});                
            plot(squeeze(100 * Divisions.C_rectangular_percentage_change(Parameters.Sections.idx_fossil_fuels(i), idx_current_divisions, :))', 'LineWidth', 2)                   
            ytickformat("percentage");
            title(sprintf('IEA category: %s', strrep(my_fieldnames{j}, '_', ' ')), 'FontSize', 15);
            legend(Parameters.Divisions.names(idx_current_divisions),'Location', 'best', 'FontSize', 14);
            linkaxes_array = [linkaxes_array sbp{j}];
        end
        linkaxes(linkaxes_array, 'y')
    end

    % Electricity Sections (producing and transmitting)
    for i = 1 : numel(Parameters.Sections.idx_electricity_producing_and_transmitting)
        figure;
        sgtitle(sprintf('Technical coefficients requirements from Section: %s \n Percentage change compared to initial value', ...
            Parameters.Sections.names(Parameters.Sections.idx_electricity_producing_and_transmitting(i))), 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
        my_fieldnames = fieldnames(Parameters.Divisions.IEAcategory.names);
        for j = 1 : numel(my_fieldnames)
            sbp{j} = subplot(2,3,j);
            sbp{j}.LineStyleOrder = my_lines_styles; 
            sbp{j}.ColorOrder = my_colors_divisions;            
            hold on
            idx_current_divisions = Parameters.Divisions.IEAcategory.idx.(my_fieldnames{j});                
            plot(squeeze(100 * Divisions.C_rectangular_percentage_change(Parameters.Sections.idx_electricity_producing_and_transmitting(i), idx_current_divisions, :))', 'LineWidth', 2)                   
            ytickformat("percentage");
            title(sprintf('IEA category: %s', strrep(my_fieldnames{j}, '_', ' ')), 'FontSize', 15);
            legend(Parameters.Divisions.names(idx_current_divisions),'Location', 'best', 'FontSize', 14);            
        end                
    end

    
    %% 6.5  emissions

    figure('Name', sprintf('%s_6.5_emissions', figures_name));
    sgtitle('--------- EMISSIONS FLOW ---------', 'FontSize', 18, 'fontweight', 'bold', 'Color', 'black');
        
    subplot(1,2,1);    
    legend_emissions = [];    
    legend_emissions{1,1} = 'industries';
    legend_emissions{1,2} = 'households';
    legend_emissions{1,3} = 'government';
    legend_emissions{1,4} = 'total';
    hold on    
    plot(sum(Sectors.emissions_flow, 2), 'LineWidth', 2);
    plot(sum(Households.emissions_flow, 2), 'LineWidth', 2);
    plot(Government.emissions_flow, 'LineWidth', 2);
    plot(Economy.emissions_flow, 'LineWidth', 2);
    hold off
    title(sprintf('LEVELS (%s scale)', y_scale_metrics), 'FontSize', 16);
    legend(legend_emissions, 'Location', 'best', 'FontSize', 15);
    set(gca,'fontsize', 15);
    set(gca, 'yscale', y_scale_metrics);

    subplot(1,2,2);
    legend_emissions_percentages = [];    
    legend_emissions_percentages{1,1} = 'industries';
    legend_emissions_percentages{1,2} = 'households';
    legend_emissions_percentages{1,3} = 'government';
    hold on    
    plot(100 * sum(Sectors.emissions_flow, 2) ./ Economy.emissions_flow, 'LineWidth', 2);
    plot(100 * sum(Households.emissions_flow, 2) ./ Economy.emissions_flow, 'LineWidth', 2);
    plot(100 * Government.emissions_flow ./ Economy.emissions_flow, 'LineWidth', 2);
    hold off
    ytickformat("percentage");
    title('PERCENTAGES', 'FontSize', 16);
    legend(legend_emissions_percentages, 'Location', 'best', 'FontSize', 15);
    set(gca,'fontsize', 15);    


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%  SAVING & CLOSING  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% save all

% Make new folder where to store the figures
mkdir(folder_name);

FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
  FigHandle = FigList(iFig);
  FigName   = get(FigHandle, 'Name');  
  savefig(FigHandle, fullfile([folder_name, '/', FigName, '.fig']));
end

%% close all

close all
%% end