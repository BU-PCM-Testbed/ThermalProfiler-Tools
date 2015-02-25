function generate_ptrace( ...
    NUM_ACTIVE_CORES, ...
    TOTAL_CORE_POWER, ...
    NON_CORE_POWER, ...
    CACHE_POWER, ...
    PTRACE_FILENAME)

if (NUM_ACTIVE_CORES < 1 || ...
    NUM_ACTIVE_CORES > 4)
    error('util:generate_ptrace', 'invalid NUM_ACTIVE_CORES (should be 1, 2, 3, or 4)');
end

block_names = { ...
    'Core_0', ...
    'Core_1', ...
    'Core_2', ...
    'Core_3', ...
    'SoC_0', ...
    'SoC_1', ...
    'SoC_2', ...
    'SoC_3', ...
    'SoC_4', ...
    'L2' ...
};

% header columns
num_cols = length(block_names);

% number of data points
num_rows = size(TOTAL_CORE_POWER,1);

if ( size(NON_CORE_POWER,1) ~= num_rows || ...
     size(CACHE_POWER,1) ~= num_rows )
    error('util:generate_ptrace', 'rows of TOTAL_CORE_POWER, NON_CORE_POWER, CACHE_POWER should all match');
end

% non-core power dissipation
UNCORE_AREA_FRACTIONS = [ ...
    0.085, ...
    0.199, ...
    0.195, ...
    0.048, ...
    0.472  ...
];

% non-core weighting
UNCORE_BALANCING = [ ...
   -0.08, ...
   -0.16 ...
    0.00, ...
    0.00, ...
    0.24  ...
];
UNCORE_AREA_FRACTIONS = UNCORE_AREA_FRACTIONS + UNCORE_BALANCING;

% open file
fid = fopen(PTRACE_FILENAME, 'w');

% print the header
for i = 1:num_cols
    fprintf(fid, '%s\t', block_names{i});
end
fprintf(fid, '\n');

for i = 1:num_rows
    per_core_power = TOTAL_CORE_POWER(i) / NUM_ACTIVE_CORES;
    
    for j = 1:4
        if (j <= NUM_ACTIVE_CORES)
            fprintf(fid, '%.6f\t', per_core_power);
        else
            fprintf(fid, '%.6f\t', 0);
        end
    end
    
    for j = 1:5
        non_core_block_power = UNCORE_AREA_FRACTIONS(j) * NON_CORE_POWER(i);
        fprintf(fid, '%.6f\t', non_core_block_power);
    end
    
    fprintf(fid, '%.6f\t', CACHE_POWER(i));
    
    if (i ~= num_rows)
        fprintf(fid, '\n');
    end
end

fclose(fid);