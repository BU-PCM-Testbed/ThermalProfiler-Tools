% SCRIPT_test_041
%
% script to calibrate thermal resistance values
%
% datasets:
% policy_300
% policy_301
% policy_302
clc
DATA_REDUCTION_SETUP;

% set directory with test data
% test_name = 'policy_300';
% test_name = 'policy_301';
% test_name = 'policy_302';
test_name = 'policy_303';

disp(['TEST DATA: ', test_name]);
fprintf('Policies, ');
if (strcmp(test_name,'policy_303'))
    fprintf('MEDIUM');
elseif (strcmp(test_name,'policy_302'))
    fprintf('SHORT');
elseif (strcmp(test_name,'policy_304'))
    fprintf('LONG');
end
fprintf(' duration experiments. \n');
disp(repmat('-',1,40));
disp('temperatures are averaged across benchmark running time');
fprintf('\n\n');

% set directory with test data
run_directory = sprintf('%s%s', DR_TESTBED_LOG_DIR, test_name);
cd(run_directory);

% MATLAB data file containing data for this script
SCRIPT_DATA_FILE = 'testbed.mat';

% get list of ThermalProfiler data files
[TP_files, TP_tags] = list_ThermalProfiler_files(run_directory);
bnch_runtimes = cell(length(TP_files),1);

% retrieve data from saved file if it exists, otherwise parse the raw data
if (exist(SCRIPT_DATA_FILE,'file'))
    SCRIPT_DATA = load(SCRIPT_DATA_FILE);
    testbed_dataset = SCRIPT_DATA.testbed_dataset;
    bnch_runtimes = SCRIPT_DATA.bnch_runtimes;
else
    % parse current measurements
    current_data = parse_34410a_data_csv('current.csv');

    % store contents of test runs
    num_TP_files = length(TP_files);
    testbed_dataset = cell(num_TP_files,1);

    for t = 1:num_TP_files
        [TP_data, start, stop] = parse_android_data_csv(TP_files{t});
        bnch_runtimes{t} = [start,stop];
        num_samples = length(TP_data);
        num_TP_cols = size(TP_data,2);

        TP_data = [TP_data, zeros(num_samples,2)];
        avg_cpu_temp_column = num_TP_cols + 1;
        cpu_power_column = num_TP_cols + 2;

        for n = 1:num_samples
            time = TP_data(n,1);
            
            % calculate avg cpu temperature
            avg_cpu_temp = 0;
            for c = 1:4
                avg_cpu_temp = avg_cpu_temp + TP_data(n,c+1);
            end
            avg_cpu_temp = avg_cpu_temp / 4;

            % store avg cpu temp
            %--------------------------------------------------------------
            TP_data(n,avg_cpu_temp_column) = avg_cpu_temp;

            % store power consumption
            %--------------------------------------------------------------
            TP_data(n,cpu_power_column) = 5.11 * interp1( ...
                current_data(:,1), current_data(:,2), time);

        end
        
        testbed_dataset{t} = TP_data;
    end
    
    % store data for this script
    save(SCRIPT_DATA_FILE,'testbed_dataset','bnch_runtimes');
end

% data format
% col 1 : time
%     2 : core 0 temp
%     3 : core 1 temp
%     4 : core 2 temp
%     5 : core 3 temp
%     6 : pcm temp
%     7 : ambient temp
%     8 : pcm energy
%     9 : Rsi
%    10 : Rpcm
%    11 : avg cpu temp
%    12 : sys power

%% analysis

R_SI  = 0.150; % units K/W
R_PCM = 13.58; % units K/W

% R_method = 'const';   % use fixed values for R_SI and R_PCM
% R_method = 'linear';  % use linear relation for R_SI and R_PCM
R_method = 'log';     % use logarithmic relation for R_SI and R_PCM

PCM_MELT_TEMP_MIN = 55;
PCM_MELT_TEMP_MAX = 60;
PCM_ENERGY_MAX = 230;

num_test_runs = length(testbed_dataset);
for i = 1:num_test_runs
    testbed_data = testbed_dataset{i};
    T_start = testbed_data(1,1);
    dt = testbed_data(2,1) - testbed_data(1,1);
    
    T1 =  10.0; T1_idx = find(testbed_data(:,1)-T_start >= T1,1);
    T2 = 150.0; T2_idx = find(testbed_data(:,1)-T_start >= T2,1);
    
    num_samples = length(testbed_data);
    num_columns = size(testbed_data,2);
    testbed_data = [testbed_data, zeros(num_samples,5)];
    
    pcm_energy = 0;
    pcm_melted = 0;
    
    for n = 1:num_samples
        if (n > 1)
            dt = testbed_data(n,1) - testbed_data(n-1,1);
        end
        
        % get temperatures
        %------------------------------------------------------------------
        cpu_temp = testbed_data(n,11);
        pcm_temp = testbed_data(n,6);
        amb_temp = testbed_data(n,7);
    
        % calculate R_SI and R_PCM
        %------------------------------------------------------------------
        dT_si_pcm  = cpu_temp - pcm_temp;
        dT_pcm_amb = pcm_temp - amb_temp;
        if (strcmpi(R_method, 'linear'))
            R_SI  = 0.312 * dT_si_pcm + 0.0573;
            R_PCM = 13.58;
        elseif (strcmpi(R_method, 'log'))
            dT_si_pcm  = max(abs(cpu_temp - pcm_temp), 0.3);
            dT_pcm_amb = max(abs(pcm_temp - amb_temp), 0.3);
            
            R_SI  = 0.35 * log(dT_si_pcm) + 0.54;
            R_PCM = 0.0436 * log(dT_pcm_amb) + 12.221;
        else
            R_SI  = 0.0686;
            R_PCM = 13.58;
        end
        testbed_data(n,num_columns+1) = R_SI;
        testbed_data(n,num_columns+2) = R_PCM;
        
        % calculate PCM Power In
        %------------------------------------------------------------------
        pcm_pwr_in = dT_si_pcm / R_SI;
        testbed_data(n,num_columns+3) = pcm_pwr_in;
        
        % calculate PCM Power Out
        %------------------------------------------------------------------
        pcm_pwr_out = dT_pcm_amb / R_PCM;
        testbed_data(n,num_columns+4) = pcm_pwr_out;
        
        % calculate PCM energy
        %------------------------------------------------------------------
        if (~pcm_melted && (pcm_temp < PCM_MELT_TEMP_MIN))
            pcm_energy = 0;
        elseif (~pcm_melted)
            pcm_energy = pcm_energy + (pcm_pwr_in - pcm_pwr_out) * dt;
            if (pcm_energy >= PCM_ENERGY_MAX)
                pcm_energy = PCM_ENERGY_MAX;
                pcm_melted = 1;
            end
        elseif (pcm_melted && (pcm_temp < PCM_MELT_TEMP_MAX))
            pcm_energy = pcm_energy + (pcm_pwr_in - pcm_pwr_out) * dt;
            pcm_energy = max(0,pcm_energy);
        end
        testbed_data(n,num_columns+5) = pcm_energy;
    
    
    end
    testbed_dataset{i} = testbed_data;
end

% data format
% col 1 : time
%     2 : core 0 temp
%     3 : core 1 temp
%     4 : core 2 temp
%     5 : core 3 temp
%     6 : pcm temp
%     7 : ambient temp
%     8 : pcm energy
%     9 : Rsi
%    10 : Rpcm
%    11 : avg cpu temp
%    12 : sys power
%    13 : calc R_si
%    14 : calc R_pcm
%    15 : PCM power input
%    16 : PCM power output
%    17 : calc PCM energy

%% plot
figure(1)
clf

x_lim = [0,480];

if (strcmp(test_name, 'policy_300'))
    melt_temp = [0, 68.7, 66.6, 68, 67.5, 68.3];
elseif (strcmp(test_name, 'policy_301'))
    melt_temp = [73, 74, 74.5, 67.6, 67.4, 69.1];
elseif (strcmp(test_name, 'policy_302'))
    melt_temp = [0,0,0,0,0,0];
elseif (strcmp(test_name, 'policy_303'))
    melt_temp = [0, 69, 70.1, 70, 69.7, 69.9];
end

test_run_titles = { ...
    sprintf('Basic Sprinting'), ...
    sprintf('Improved Sprinting'), ...
    sprintf('Temperature-\nTriggered DVFS'), ...
    sprintf('PCM-Aware Policy with \n75%% remaining capacity'), ...
    sprintf('PCM-Aware Policy with \n50%% remaining capacity'), ...
    sprintf('PCM-Aware Policy with \n25%% remaining capacity') ...
};

runtime_baseline = bnch_runtimes{1}(2) - bnch_runtimes{1}(1);


plot_order = [1,2,3,4,5,6];
% plot_order = [1,3,6];
num_test_runs = length(plot_order);

for j = 1:num_test_runs
    i = plot_order(j);
    
    testbed_data = testbed_dataset{i};
    T_start = testbed_data(1,1);
    Ts = testbed_data(2,1)-testbed_data(1,1);
    LP_filter = fdesign.lowpass('N,Fc',3,0.1,Ts);
    Hd = design(LP_filter);
    
    % find temperature where PCM fully melts
    if (melt_temp(i) > 0)
        pcm_melt_idx = find(testbed_data(:,6) > melt_temp(i), 1);
        pcm_melt_time = testbed_data(pcm_melt_idx,1) - T_start;
        pcm_energy_at_melt = testbed_data(pcm_melt_idx,8);
    else
        pcm_melt_idx = 1;
        pcm_melt_time = -1;
        pcm_energy_at_melt = 0;
    end
    
    % benchmark run time
    runtime    = bnch_runtimes{i}(2) - bnch_runtimes{i}(1);
    comparison = (runtime_baseline - runtime) / runtime_baseline;
    
    % avg pcm temperature over 450s
    start_time = bnch_runtimes{i}(1) - 20;
    time_data  = testbed_data(:,1) - start_time;
    bnch_start = bnch_runtimes{i}(1) - start_time;
    bnch_stop  = bnch_runtimes{i}(2) - start_time;
    
    cpu_trace = testbed_data(:,11);
    pcm_trace = testbed_data(:,6);
    energy_trace = (testbed_data(:,17) .* (-1) + PCM_ENERGY_MAX) / PCM_ENERGY_MAX * 100;
    time_range = [0,480];
    
    % clean up energy_trace
    for k = 1:length(energy_trace)
        if (energy_trace(k) < 0)
            energy_trace(k) = 0;
        elseif (energy_trace(k) > 100)
            energy_trace(k) = 100;
        end
    end
    
%     start_idx = find(time_data > 0,1);
%     stop_idx = find(time_data > 480,1);

    start_idx = find(time_data >= 20,1);
    stop_idx = find(time_data >= (20 + runtime),1);

    start_time = time_data(start_idx);
    stop_time = time_data(stop_idx);
    pcm_avg_temp = trapz(time_data(start_idx:stop_idx), pcm_trace(start_idx:stop_idx)) / (stop_time - start_time); 
    cpu_avg_temp = trapz(time_data(start_idx:stop_idx), cpu_trace(start_idx:stop_idx)) / (stop_time - start_time); 
    
    pcm_max_temp = max(pcm_trace(start_idx:stop_idx));
    cpu_max_temp = max(cpu_trace(start_idx:stop_idx));
    
    fprintf('%s \n%s \n', test_run_titles{i}, repmat('-',40,1));
    %fprintf('PCM Energy at Melting Temp. = %.2f J \n', pcm_energy_at_melt);
    fprintf('Benchmark runtime           = %.2f s \n', runtime);
    fprintf('* improvement               = %.3f %% \n', comparison * 100);
    fprintf('* Avg PCM Temp = %.2f C\n', pcm_avg_temp);
    fprintf('* Avg CPU Temp = %.2f C\n\n', cpu_avg_temp);
    fprintf('* Max PCM Temp = %.2f C\n', pcm_max_temp);
    fprintf('* Max CPU Temp = %.2f C\n\n', cpu_max_temp);
    
    %fprintf('%d,%d\n', start_idx, stop_idx);
    %fprintf('%.2f,%.2f\n', start_time, stop_time);
    
    fprintf('\n\n');
    
    figure(1)
    num_plot_rows = 2;
    
    % plot temperatures
    %----------------------------------------------------------------------
    row = 1;
    subplot(num_plot_rows, num_test_runs, (row - 1)*num_test_runs + j);
    hold all;
    
    y_lim = [40,97];
    
    plot(time_data, cpu_trace, 'LineWidth', 3);
    plot(time_data, pcm_trace, 'LineWidth', 3);
    plot([pcm_melt_time,pcm_melt_time], y_lim, 'r--', 'LineWidth', 2);
    plot([bnch_start,bnch_start], [y_lim(1),(0.25*y_lim(1)+0.75*y_lim(2))], 'k-.', 'LineWidth', 2);
    plot([bnch_stop,bnch_stop], [y_lim(1),(0.25*y_lim(1)+0.75*y_lim(2))], 'k-.', 'LineWidth', 2);
%     arrow([1,41],[400,80]);
    xlim(time_range);
    if (j == 1)
        ylabel('Temperature (C)');
    end
    if (j == 1)
        hl = legend( ...
            'CPU', ...
            'PCM', ...
            sprintf('PCM fully\nmelted'), ...
            sprintf('Benchmark\nruntime'), ...
            'Location','NorthEast');
        set(hl,'FontSize',12');
    end
    ylim(y_lim);
    
    title(test_run_titles{i},'FontSize', 16);
    ax = gca;
    set(ax, 'FontSize', 16);
    set(ax,'XTick', 0:100:500);
    set(ax,'YTick', 40:10:90);
    
    
    % plot PCM energy
    %----------------------------------------------------------------------
    row = 2;
    subplot(num_plot_rows, num_test_runs, (row - 1)*num_test_runs + j);
    hold all;
    
    y_lim = [0,100];
    
    plot(time_data,energy_trace,'LineWidth',3);
    
    %plot([pcm_melt_time,pcm_melt_time], y_lim, 'k--', 'LineWidth', 2);
    xlim(time_range);
    xlabel('Time (s)');
    if (j == 1)
        ylabel('% remaining PCM capacity');
    end
    if (j == 1)
        hl = legend(sprintf('PCM capacity\nremaining'),'Location','SouthEast');
        set(hl,'FontSize',12');
    end
    ylim(y_lim);
    %legend('re-calc stored PCM energy', 'PCM fully melted');
    
    ax = gca;
    set(ax, 'FontSize', 16);
    set(ax,'XTick', 0:100:500);
    set(ax,'YTick', 0:25:100);
    
end

return

figure(3)
clf

baseline_data = testbed_dataset{1};
baselinepp_data = testbed_dataset{3};
pcm75_data = testbed_dataset{4};
pcm50_data = testbed_dataset{5};

start_times = [ ...
    bnch_runtimes{1}(1) - 20, ...
    bnch_runtimes{3}(1) - 20, ...
    bnch_runtimes{4}(1) - 20, ...
    bnch_runtimes{5}(1) - 20  ...
];

baseline_data(:,1) = baseline_data(:,1) - start_times(1);
baselinepp_data(:,1) = baselinepp_data(:,1) - start_times(2);
pcm75_data(:,1) = pcm75_data(:,1) - start_times(3);
pcm50_data(:,1) = pcm50_data(:,1) - start_times(4);

x_min = 0;
x_max = 480;
x_range = [x_min,x_max];
x_delta = x_max - x_min;

COL_PCM = 6;
COL_CPU = 11;
COL_EN  = 17;

%==========================================================================

subplot(1,3,1);
hold all

energy_trace = (baseline_data(:,COL_EN) .* (-1) + PCM_ENERGY_MAX) / PCM_ENERGY_MAX * 100;

[ax,p1,p2] = plotyy( ...
    baseline_data(:,1), baseline_data(:,COL_CPU), ...
    baseline_data(:,1), energy_trace);

set(p1,'LineWidth',3,'Color','r');
set(p2,'LineWidth',3);

p3 = plot(ax(1), baseline_data(:,1), baseline_data(:,COL_PCM), 'r-.', 'LineWidth', 3);

% plot(baselinepp_data(:,1), baselinepp_data(:,COL_CPU), 'LineWidth', 3);
% plot(baselinepp_data(:,1), baselinepp_data(:,COL_PCM), 'LineWidth', 3);

set(ax(1), 'FontSize', 24);
xlim(ax(1),x_range);
ylim(ax(1), [10,100]);
set(ax(1), 'YTick', 40:10:100);
xlabel('Time (s)', 'FontSize', 32);

set(ax(2), 'FontSize', 24);
xlim(ax(2),x_range);
ylim(ax(2), [0,400]);
set(ax(2), 'YTick', 0:50:100);
set(ax(2), 'YTickLabels', '');
ylabel(ax(1), 'Temperature (C)');

%==========================================================================

subplot(1,3,2);
hold all

energy_trace = (baselinepp_data(:,COL_EN) .* (-1) + PCM_ENERGY_MAX) / PCM_ENERGY_MAX * 100;

[ax,p1,p2] = plotyy( ...
    baselinepp_data(:,1), baselinepp_data(:,COL_CPU), ...
    baselinepp_data(:,1), energy_trace);

set(p1,'LineWidth',3);
set(p2,'LineWidth',3);

p3 = plot(ax(1), baselinepp_data(:,1), baselinepp_data(:,COL_PCM), 'LineWidth', 3);

% plot(baselinepp_data(:,1), baselinepp_data(:,COL_CPU), 'LineWidth', 3);
% plot(baselinepp_data(:,1), baselinepp_data(:,COL_PCM), 'LineWidth', 3);

set(ax(1), 'FontSize', 24);
xlim(ax(1),x_range);
ylim(ax(1), [10,100]);
set(ax(1), 'YTick', 40:10:100);
set(ax(1), 'YTickLabels', '');
xlabel('Time (s)');

set(ax(2), 'FontSize', 24);
xlim(ax(2),x_range);
ylim(ax(2), [0,400]);
set(ax(2), 'YTick', 0:50:100);
set(ax(2), 'YTickLabels', '');



%==========================================================================

subplot(1,3,3);
hold all

energy_trace = (pcm75_data(:,COL_EN) .* (-1) + PCM_ENERGY_MAX) / PCM_ENERGY_MAX * 100;

[ax,p1,p2] = plotyy( ...
    pcm75_data(:,1), pcm75_data(:,COL_CPU), ...
    pcm75_data(:,1), energy_trace);

set(p1,'LineWidth',3);
set(p2,'LineWidth',3);

p3 = plot(ax(1), pcm75_data(:,1), pcm75_data(:,COL_PCM), 'LineWidth', 3);

% plot(pcm75_data(:,1), pcm75_data(:,COL_CPU), 'LineWidth', 3);
% plot(pcm75_data(:,1), pcm75_data(:,COL_PCM), 'LineWidth', 3);

set(ax(1), 'FontSize', 24);
xlim(ax(1),x_range);
ylim(ax(1), [10,100]);
set(ax(1), 'YTick', 40:10:100);
set(ax(1), 'YTickLabels', '');
xlabel('Time (s)');

set(ax(2), 'FontSize', 24);
xlim(ax(2),x_range);
ylim(ax(2), [0,400]);
set(ax(2), 'YTick', 0:50:100);
ylabel(ax(2), '% remaining PCM capacity');

%==========================================================================
