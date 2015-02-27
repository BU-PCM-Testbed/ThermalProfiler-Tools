function HS_STEADY = parse_hotspot_steady_data(FILENAME)

if (isempty(FILENAME) || ~ischar(FILENAME))
    disp('Invalid argument FILENAME');
    return
end

% open file for reading
fid = fopen(FILENAME, 'r');

% create a format for parsing the rest of the file
parse_format = '%s\t%f';

% read in the data
temperatures = textscan(fid, parse_format);
num_samples = length(temperatures{1});

% close out the file descriptor
fclose(fid);

%celldisp(temperatures);

HS_STEADY = temperatures;
