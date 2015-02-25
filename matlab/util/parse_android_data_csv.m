function [DATA, START_TIME, STOP_TIME] = parse_android_data_csv(FILENAME)
%
% Author: Charlie de Vivero
% Date  : 2015-02-21
%
% Organization:
%   Boston University PEAC Lab
%
% Function    : data extraction
% Description : This procedure parses the raw data output from the 
%               IFC6410 running on Android 4.1.2, formatted as a 
%               comma-separated file (.CSV file extension). This 
%               is the exported data from the ThermalProfiler app
%               for Android (com.testbed.thermalprofiler).
%               Format has varied over revisions of the app.
% 
%               The first data sample appears on line 2 of the CSV file.
%
% Parameters  : FILENAME        - a string containing the name of the
%                                 file to be parsed
%
% Return      : DATA            - a [n x 10] matrix where the first column
%                                 denotes the time of the sampled data, in
%                                 seconds (since beginning of year), 
%                                 columns 2-5 denote the sampled temperature
%                                 of each CPU core, column 6 is sampled 
%                                 thermocouple temperature column 7 is 
%                                 ambient temperature, column 8 is
%                                 calculated PCM stored energy, columns
%                                 9-10 are calculated thermal resistance
%                                 values (K/W). All temperatures in Celsius.
%               
%               START_TIME      - if a benchmark was run, START_TIME denotes
%                                 the time (in seconds since beginning of 
%                                 year) at which a benchmark test was run, 
%                                 during the sampled time range of this log.
%               
%               STOP_TIME       - if a benchmark was run, STOP_TIME denotes
%                                 the time (in seconds since beginning of 
%                                 year) at which a benchmark test finished, 
%                                 during the sampled time range of this log.
%
% Error Handling : Errors are handled internally, and an empty matrix
%                  is returned if there was a failure parsing the file.
%
% Examples of usage:
%
%   >> data_filename = 'cpu_test_012.csv';
%   >> [DATA, START_TIME, STOP_TIME] = parse_android_data_csv(data_filename)
%
%   DATA = 
%   
%     1411015905    22    25    22    23    30.2    1    2    1
%     1411015906    25    20    20    23    29.9    1    2    1
%     1411015907    23    19    20    22    30.3    1    0    0
%     ...
%
%   START_TIME = 
%
%     1411016002
%
%   STOP_TIME = 
%
%     1411016108
%

ANDROID_DATA = load_from_mat(FILENAME);
if (~isempty(ANDROID_DATA))
    DATA = ANDROID_DATA{1};
    START_TIME = ANDROID_DATA{2};
    STOP_TIME = ANDROID_DATA{3};
    return;
end

% CSV formatted file
DATA_HEADERS_LINE_K = 1;
DATA_SAMPLE_LINE_K = 2;
DATE_FORMAT_K = 'YYYY-mm-dd HH:MM:SS.FFF';

% default return values
DATA = [];
START_TIME = 0;
STOP_TIME = 0;
DATA_START_LINE = DATA_SAMPLE_LINE_K;
SAMPLE_COUNT = 0;

% open the data file
[fid, msg] = fopen(FILENAME, 'r');

% check valid file descriptor
if (fid < 0)
    fprintf('Failed to open: %s \n', FILENAME);
	fprintf('%s \n', msg);
    return
end

% start by skipping to line with data
for i = 1:DATA_HEADERS_LINE_K
    line = fgetl(fid);
end

% parse the header line
tokens = strsplit(line, ',');

% parse file format options
UNIX_TIME_ENABLED = 0;
TCPL_ENABLED = 0;
PCME_ENABLED = 0;
options = tokens{1};
if (options == 'u' || options == 't')
    UNIX_TIME_ENABLED = 1;
elseif (options == 'p')
    TCPL_ENABLED = 1;
elseif (options == 'e')
    PCME_ENABLED = 1;
end

% get the start time
if (strcmp(tokens{2}, '0') == 0)
    date_str = tokens{2};
    date_num = datenum(date_str, DATE_FORMAT_K);
    date_vec = datevec(date_str, DATE_FORMAT_K);
    days_from_year = date_num - datenum(date_vec(1));
    secs_from_year = days_from_year * 24 * 3600;
    
    start_time = secs_from_year;
else
    start_time = 0.0;
end
START_TIME = start_time;

% get the stop time
if (strcmp(tokens{3}, '0') == 0)
    date_str = tokens{3};
    date_num = datenum(date_str, DATE_FORMAT_K);
    date_vec = datevec(date_str, DATE_FORMAT_K);
    days_from_year = date_num - datenum(date_vec(1));
    secs_from_year = days_from_year * 24 * 3600;
    
    stop_time = secs_from_year;
else
    stop_time = 0.0;
end
STOP_TIME = stop_time;

% declare the format of the data samples. should be:
% <string>,<integer>,<integer>,<integer>,<integer>,<double>,<double>,<double>,<double>
%
% which represents: <timestamp>,<core 0 temp>,<core 1 temp>,<core 2 temp>,<core 3 temp>,<core 0 utilization>,<core 1 utilization>,<core 2 utilization>,<core 3 utilization>
NUM_DATA_COLUMNS = 0;
if (TCPL_ENABLED)
    formatspec = '%s%d%d%d%d%f%f';
    NUM_DATA_COLUMNS = 7;
elseif (PCME_ENABLED)
    formatspec = '%s%d%d%d%d%f%f%f%f%f';
    NUM_DATA_COLUMNS = 10;
else
    formatspec = '%s%d%d%d%d%f%f%f%f';
    NUM_DATA_COLUMNS = 9;
end

% although if Unix timestamp is being printed in this file, append a field
% at the end of the formatspec:
if (UNIX_TIME_ENABLED)
    formatspec = [formatspec, '%d'];
    NUM_DATA_COLUMNS = NUM_DATA_COLUMNS + 1;
end

% parse the data
raw_data = [];
try
    raw_data = textscan( ...
        fid, formatspec, ...
        'Delimiter', ',', ...
        'ReturnOnError', false);
catch me
    fprintf('Exception occurred: %s\n', me.message);
end
fclose(fid);

% error check
if (isempty(raw_data))
    return
end

SAMPLE_COUNT = size(raw_data{1}, 1);

raw_data_timestamp = raw_data{1};

DATA = zeros(SAMPLE_COUNT, NUM_DATA_COLUMNS);

for i = 1:SAMPLE_COUNT
    date_str = raw_data_timestamp(i);
    date_num = datenum(date_str, DATE_FORMAT_K);
    date_vec = datevec(date_str, DATE_FORMAT_K);
    
    % date_vec(1): year
    % date_vec(2): month
    % date_vec(3): day
    % date_vec(4): hour
    % date_vec(5): minute
    % date_vec(6): seconds (1.234)
    
    days_from_year = date_num - datenum(date_vec(1));
    secs_from_year = days_from_year * 24 * 3600;
    
    DATA(i,1) = secs_from_year;
    for j = 2:NUM_DATA_COLUMNS
        DATA(i,j) = raw_data{j}(i);
    end
end

ANDROID_DATA = {DATA, START_TIME, STOP_TIME};
save_to_mat(FILENAME,ANDROID_DATA);

return
