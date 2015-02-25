% SCRIPT_analysis_steady_state
%
% Analysis script for Steady State experiments with PCM.
%
% datasets:
% sor_200
% smult_201
% lu_202
%
clc
DATA_REDUCTION_SETUP;

% set directory with test data
% test_name = 'sor_200';
% test_name = 'smult_201';
test_name = 'lu_202';

disp(['TEST DATA: ', test_name]);

run_directory = sprintf('%s%s', DR_TESTBED_LOG_DIR, test_name);
cd(run_directory);

% MATLAB data file containing data for this script
SCRIPT_DATA_FILE = 'testbed.mat';

% get list of ThermalProfiler data files
[TP_files, TP_tags, CF_map, core_options, freq_options] = ...
    list_ThermalProfiler_files(run_directory);

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
        fprintf('Processing: %s \n', TP_files{t});
        
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

%% plot

figure(1)
clf

num_core_options = length(core_options);
num_freq_options = length(freq_options);
subplot_size = [num_core_options,num_freq_options];

ss_interval_override = cell(num_core_options,num_freq_options);
if (strcmp(test_name,'sor_200'))
    ss_interval_override{3,2} = [0.82,0.98];
    ss_interval_override{4,1} = [0.92,0.99];
elseif (strcmp(test_name,'smult_201'))
    ss_interval_override{3,3} = [0.80,0.95];
    ss_interval_override{4,2} = [0.75,0.95];
end

% record steady-state power
ss_testbed_power = zeros(num_core_options,num_freq_options);

% record steady-state temperatures
ss_testbed_temps = cell(num_core_options,num_freq_options);

for c = 1:num_core_options
    for f = 1:num_freq_options
        
        subplot_idx = (c-1)*num_core_options + f;
        subplot(num_core_options,num_freq_options,subplot_idx);
        hold all;
        
        testbed_idx = CF_map(c,f);
        if (testbed_idx > 0)
            testbed_data = testbed_dataset{testbed_idx};
            
            % define the bounds of the data recorded
            start_time = testbed_data(1,1);
            stop_time  = testbed_data(end,1);
            delta_time = stop_time - start_time;
            
            % define an interval to measure the steady-state.
            % normally this will be approx the last 25% of the recorded
            % data, where temperature and power should be settled.
            % allow an override of speecifying the interval for a specific
            % core/freq experiment (using ss_interval_override).
            %
            if (~isempty(ss_interval_override{c,f}))
                start_factor  = ss_interval_override{c,f}(1);
                stop_factor   = ss_interval_override{c,f}(2);
                ss_start_time = start_time + delta_time * start_factor;
                ss_stop_time  = start_time + delta_time * stop_factor;
            else
                ss_start_time = start_time + delta_time * 0.75;
                ss_stop_time  = bnch_runtimes{testbed_idx}(2);
            end
            
            ss_start_idx = find(testbed_data(:,1) >= ss_start_time,1);
            ss_stop_idx  = find(testbed_data(:,1) >= ss_stop_time,1);
            if (isempty(ss_stop_idx))
                ss_stop_time = start_time + delta_time * 0.95;
                ss_stop_idx  = find(testbed_data(:,1) >= ss_stop_time,1);
            end
            
            ss_delta_time = ss_stop_time - ss_start_time;
            
            % calculate statistics
            %
            
%             fprintf('CORE: %d \nFREQ: %d \n', core_options(c), freq_options(f));
%             fprintf('%d, %.2f = %.2f \n', ss_start_idx, ...
%                 ss_start_time-start_time, ...
%                 testbed_data(ss_start_idx,1)-start_time);
%             fprintf('%d, %.2f = %.2f \n\n', ss_stop_idx, ...
%                 ss_stop_time-start_time, ...
%                 testbed_data(ss_stop_idx,1)-start_time);
            
%             ss_power_ts = timeseries(testbed_data(ss_start_idx:ss_stop_idx,12), ...
%                 testbed_data(ss_start_idx:ss_stop_idx,1));
%             ss_t_cpu_ts = timeseries(testbed_data(ss_start_idx:ss_stop_idx,11), ...
%                 testbed_data(ss_start_idx:ss_stop_idx,1));
%             
%             ss_power_ts_avg = mean(ss_power_ts);
%             ss_power_ts_std = std(ss_power_ts);
%             
%             ss_t_cpu_ts_avg = mean(ss_t_cpu_ts);
%             ss_t_cpu_ts_std = std(ss_t_cpu_ts);
            
%             fprintf('* Avg Power = %.3f \n', ss_power_ts_avg);
%             fprintf('* Std Power = %.3f \n', ss_power_ts_std);
%             fprintf('* Avg T_CPU = %.3f \n', ss_t_cpu_ts_avg);
%             fprintf('* Std T_CPU = %.3f \n\n', ss_t_cpu_ts_std);
            
            
            ss_avg_power = trapz(testbed_data(ss_start_idx:ss_stop_idx,1), ...
                testbed_data(ss_start_idx:ss_stop_idx,12)) / ss_delta_time;
            ss_avg_t_cpu = trapz(testbed_data(ss_start_idx:ss_stop_idx,1), ...
                testbed_data(ss_start_idx:ss_stop_idx,11)) / ss_delta_time;
            
            ss_avg_temps = zeros(1,5);
            for i = 1:5
                ss_avg_temps(i) = trapz(testbed_data(ss_start_idx:ss_stop_idx,1), ...
                    testbed_data(ss_start_idx:ss_stop_idx,i+1)) / ss_delta_time;
            end
            
            %fprintf('%d,%d,%.3f\n', core_options(c), freq_options(f), ss_avg_power);
            
            ss_testbed_power(c,f) = ss_avg_power;
            ss_testbed_temps{c,f} = ss_avg_temps;
            
%             fprintf('* Avg Power = %.3f \n', ss_avg_power);
%             fprintf('* Avg T_CPU = %.3f \n\n', ss_avg_t_cpu);

            [ax,p1,p2] = plotyy(testbed_data(:,1)-start_time, testbed_data(:,11), ...
                testbed_data(:,1)-start_time, testbed_data(:,12));
            
            y_lim = ylim;
            plot(ax(1), [ss_start_time,ss_start_time]-start_time, y_lim, 'k--', 'LineWidth', 2);
            plot(ax(1), [ss_stop_time,ss_stop_time]-start_time, y_lim, 'k--', 'LineWidth', 2);
            
            if (f == 1)
                ylabel(ax(1), sprintf('Cores: %d\nTemp (C)', core_options(c)));
            elseif (f == num_core_options)
                ylabel(ax(2), 'Power (W)');
            end
            
            if (c == 1)
                title(sprintf('Frequency: %d MHz', freq_options(f)));
            end
        end % testbed_idx > 0
    end % freq
end % core

%% system power

% set cache power (W)
cache_power_idle = 0.344;
cache_power_peak = 0.847;

% set external chip consumption (W)
ddr3_pmic  = 0.0030149; % 590 uA * 5.11 V
soc_pmic   = 0.027083; % 5.3 mA * 5.11 V
ddr3_stdby = 0.258; % DDR3-1600 x16 bank, 43 mA * 1.5V * (4 chips)
external_power = ddr3_pmic + soc_pmic + ddr3_stdby;
external_power = 0;

% record core-only power
ss_testbed_core_power = zeros(num_core_options,num_freq_options);

% generate ptraces
ptrace_dir = 'C:\Users\Charlie\Dropbox\InterPack_2015 (1)\testbed_sw\hotspot\ptrace\ptrace_pcm_ss\';

for f = 1:num_freq_options
    fprintf('FREQUENCY: %d MHz \n', freq_options(f));
    
    power_values_idx = find(ss_testbed_power(:,f) > 0);
    power_values = ss_testbed_power(power_values_idx,f);
    core_values = core_options(power_values_idx);
    
    % General model Exp1:
    % f(x) = a*exp(b*x)
    %
    fit_exp = fit(core_values,power_values,'exp1');
    zero_cores_power = fit_exp.a * exp(fit_exp.b * 0);
    
    uncore_power = zero_cores_power - external_power - cache_power_peak;
    
    for c = 1:num_core_options
        ss_power = ss_testbed_power(c,f);
        
        if (ss_power > 0)
            fprintf('Cores %d: %6.3f ', core_options(c), ss_power);
            if (c > 1)
                fprintf('(+%5.3f)', ss_power - ss_testbed_power(c-1,f));
            end
            fprintf('\n');

            core_power = ss_power - uncore_power - external_power - cache_power_peak;

            fprintf('* external power = %.3f \n', external_power);
            fprintf('* L2 cache power = %.3f \n', cache_power_peak);
            fprintf('* non-core power = %.3f \n', uncore_power);
            fprintf('* %2d cores power = %.3f \n', core_options(c), core_power);
            fprintf('\n');

            ptrace_filename = sprintf('snapdragon_pcm_%s_ss_c%d_%dM.ptrace', ...
                test_name, core_options(c), freq_options(f));
            ptrace_file = sprintf('%s%s', ptrace_dir, ptrace_filename);

            generate_ptrace(core_options(c), core_power, uncore_power, ...
                cache_power_peak, ptrace_file);
        end % ss_power > 0
    end % core
    
    
    fprintf('\n\n');
end % freq

%% temperatures

for c = 1:num_core_options
    for f = 1:num_freq_options
        fprintf('%d,%d', core_options(c), freq_options(f));
        
        testbed_temps = ss_testbed_temps{c,f};
        if (~isempty(testbed_temps))
            for i = 1:5
                fprintf(',%.4f', testbed_temps(i));
            end
        end
        
        fprintf('\n');
    end
end
