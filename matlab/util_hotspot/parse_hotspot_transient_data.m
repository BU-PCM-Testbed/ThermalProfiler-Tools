function TRACE = parse_hotspot_transient_data(FILENAME, SAMPLE_INTERVAL)

if (isempty(FILENAME) || ~ischar(FILENAME))
    disp('Invalid argument FILENAME');
    return
end

if (SAMPLE_INTERVAL <= 0.0)
    disp('Invalid argument SAMPLE_INTERVAL');
    return
end

% open file for reading
fid = fopen(FILENAME, 'r');

% read the first line (contains header names)
header_line = fgetl(fid);

headers = strsplit(header_line, '\t');
%celldisp(headers)
num_headers = length(headers);

if (num_headers <= 0)
    disp('error parsing header line');
    fclose(fid);
    return
end

% create a format for parsing the rest of the file
parse_format = repmat('%f', 1, num_headers);

% read in the data
temp_traces = textscan(fid, parse_format);
num_samples = length(temp_traces{1});

% close out the file descriptor
fclose(fid);

% create the x-axis
TIME = SAMPLE_INTERVAL:SAMPLE_INTERVAL:(num_samples*SAMPLE_INTERVAL);

TRACE = zeros(num_samples, (num_headers+1));
TRACE(:,1) = TIME;
for i = 1:num_headers
    TRACE(:,i+1) = temp_traces{i};
end

return