function generate_ttrace(FILENAME, SAMPLE_INTERVAL, TEMPERATURE_TRACE)

if (isempty(FILENAME) || ~ischar(FILENAME))
    disp('Invalid argument FILENAME');
    return
end

if (SAMPLE_INTERVAL <= 0.0)
    disp('Invalid argument SAMPLE_INTERVAL');
    return
end

% open file for writing
fid = fopen(FILENAME, 'w');

% write header
for i = 1:4
    fprintf(fid, 'Core_%d', i-1);
    if (i < 4)
        fprintf(fid, '\t');
    else
        fprintf(fid, '\tThermocouple\n');
    end
end

% interpolate data
stop_time = TEMPERATURE_TRACE(end,1);
num_samples = floor(stop_time / SAMPLE_INTERVAL) + 1;

for i = 1:num_samples
    sample_time = (i-1) * SAMPLE_INTERVAL;
    
%     trace_time_index = find(TEMPERATURE_TRACE(:,1) > sample_time,1);
%     
%     ttrace_time_1 = TEMPERATURE_TRACE(trace_time_index,1);
%     ttrace_time_0 = TEMPERATURE_TRACE(trace_time_index-1,1);
%     
%     ttrace_time_index_fraction = 

    temperatures = zeros(1,5);
    for j = 1:length(temperatures)
        temperatures(j) = interp1(TEMPERATURE_TRACE(:,1), TEMPERATURE_TRACE(:,j+2), sample_time);
    end
    
    % write temperatures
    for j = 1:length(temperatures)
        fprintf(fid, '%.3f', temperatures(j));
        if (j < length(temperatures))
            fprintf(fid, '\t');
        else
            fprintf(fid, '\n');
        end
    end
    
end

fclose(fid);
