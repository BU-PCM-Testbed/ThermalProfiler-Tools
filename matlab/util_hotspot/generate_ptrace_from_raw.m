function generate_ptrace_from_raw(PWR_VS_TIME_DATA, ...
    CACHE_POWER_IDLE, CACHE_POWER_PEAK, ...
    BENCHMARK_START_TIME, BENCHMARK_STOP_TIME, ...
    NUM_CORES, TOTAL_UNCORE_POWER, FILENAME, PCM)

SAMPLE_INTERVAL = 0.01; % seconds

SI_BLOCKS = 10;
SI_BLOCKS_CORES = 4;
CORE_NAMES = cell(1,SI_BLOCKS);
for i = 1:SI_BLOCKS_CORES
    CORE_NAMES{i} = sprintf('Core_%d', i-1);
end
for i = 1:5
    CORE_NAMES{i + SI_BLOCKS_CORES} = sprintf('SoC_%d', i-1);
end
CORE_NAMES{10} = 'L2';

% PCM enabled
if (PCM)
    PCM_CORE_NAMES = cell(1,SI_BLOCKS*2);
    for i = 1:SI_BLOCKS
        PCM_CORE_NAMES{i} = CORE_NAMES{i};
        PCM_CORE_NAMES{SI_BLOCKS+i} = sprintf('pcm_%s', CORE_NAMES{i});
    end
    SI_BLOCKS = SI_BLOCKS*2;
    CORE_NAMES = PCM_CORE_NAMES;
end

% "un-core" power dissipation
UNCORE_AREA_FRACTIONS = [ ...
    0.085, ...
    0.199, ...
    0.195, ...
    0.048, ...
    0.472  ...
];

% un-core weight distribution
UNCORE_BALANCING = [ ...
   -0.08, ...
   -0.16 ...
    0.00, ...
    0.00, ...
    0.24  ...
];
UNCORE_AREA_FRACTIONS = UNCORE_AREA_FRACTIONS + UNCORE_BALANCING;

% time interval
DELTA_T = PWR_VS_TIME_DATA(end,1) - PWR_VS_TIME_DATA(1,1);
ROWS = floor(DELTA_T / SAMPLE_INTERVAL);

POWER_DATA = zeros(ROWS,SI_BLOCKS);

fprintf('%d samples.\n', ROWS);
PROGRESS_10_PCT = floor(ROWS / 10);

% fill in power data
%--------------------------------------------------------------------------
fprintf('  * progress: %5.1f%% complete \n', 0.0);
for i = 1:ROWS
    current_time = PWR_VS_TIME_DATA(1,1) + (i-1) * SAMPLE_INTERVAL;
    power = interp1(PWR_VS_TIME_DATA(:,1), PWR_VS_TIME_DATA(:,2), current_time);
    
    % fill in un-core power
    for j = 1:5
        POWER_DATA(i,j+4) = TOTAL_UNCORE_POWER * UNCORE_AREA_FRACTIONS(j);
    end
    
    % fill in cache power
    if ((NUM_CORES > 1) && ...
            (current_time >= BENCHMARK_START_TIME) && ...
            (current_time <= BENCHMARK_STOP_TIME))
        POWER_DATA(i,10) = CACHE_POWER_PEAK;
    else
        POWER_DATA(i,10) = CACHE_POWER_IDLE;
    end
    
    % fill in core power:
    %
    %  single core power = (total power - cache power - uncore power) / (number of active cores)
    %
    per_core_power = (power - POWER_DATA(i,10) - TOTAL_UNCORE_POWER) / ...
        NUM_CORES;
    
    for j = 1:4
        if (NUM_CORES >= j)
            POWER_DATA(i,j) = per_core_power;
        else
            POWER_DATA(i,j) = 0.0;
        end
    end
    
    if (mod(i,PROGRESS_10_PCT) == 0)
        fprintf(repmat('\b',1,17));
        %fprintf('progress: %5.1f%% complete \n', i/ROWS*100.0);
        fprintf('%5.1f%% complete \n', i/ROWS*100.0);
    end
end

generate_ptrace_from_raw_1(POWER_DATA, CORE_NAMES, FILENAME);
