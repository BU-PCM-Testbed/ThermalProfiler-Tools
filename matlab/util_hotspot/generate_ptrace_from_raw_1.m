function generate_ptrace_from_raw_1(POWER_DATA, CORE_NAMES, FILENAME)

% number of columns.
% CORE_NAMES labels should match number of cols in POWER_DATA.
COLUMNS = length(CORE_NAMES);

% number of data points
ROWS = size(POWER_DATA,1);

% open file
fid = fopen(FILENAME, 'w');

% print the header
for i = 1:COLUMNS
    fprintf(fid, '%s\t', CORE_NAMES{i});
end
fprintf(fid, '\n');

for i = 1:ROWS
    for j = 1:COLUMNS
        fprintf(fid, '%.6f\t', POWER_DATA(i,j));
    end
    
    if (i ~= ROWS)
        fprintf(fid, '\n');
    end
end

fclose(fid);
