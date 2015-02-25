function DATA = parse_34410a_data_csv(FILENAME)
%
% Author: Charlie de Vivero
% Date  : 2015-02-21
%
% Organization:
%   Boston University PEAC Lab
%
% Function    : data extraction
% Description : This procedure parses the raw data output from the 
%               Agilent 34410A digital multimeter, formatted as a 
%               comma-separated file (.CSV file extension). This is
%               the exported data from the Keysight BenchVue program.
%               The exact format has changed according to the version
%               of BenchVue used.
% 
%               Prior to version 2.5:
%               The first data sample appears on line 7 of the CSV file.
%               The CSV file can also be formatted to include the Setup
%               information (this option appears when exporting the data
%               from BenchVue, "Include Setup Text"). In this case, some 
%               more information is printed at the top of the file, 
%               and the first data sample appears on line 18.
%
%               Version 2.5:
%               The first data sample appears on line 9 of the CSV file.
%               The CSV file can also be formatted to include the Setup
%               information (this option appears when exporting the data
%               from BenchVue, "Include Setup Text"). In this case, some 
%               more information is printed at the top of the file, 
%               and the first data sample appears on line 20. NOTE: this
%               version of BenchVue prints timestamps in 12hr-format,
%               i.e. yyyy-mm-dd HH:MM:SS.sss, but does NOT differentiate
%               between AM/PM. If data is taken after 12 noon, please set
%               the BENCHVUE_V25_PM flag to 1 (see below).
%
%
% Parameters  : FILENAME        - a string containing the name of the
%                                 file to be parsed
%
% Return      : DATA            - a [n x 2] matrix where the first column
%                                 denotes the time of the sampled data, in
%                                 seconds (since the beginning of the year), 
%                                 and the second column denotes the sampled
%                                 voltage, in Volts, for n samples.
%
% Error Handling : Errors are handled internally, and an empty matrix
%                  is returned if there was a failure parsing the file.
%
% Examples of usage:
%
%   >> data_filename = 'voltage_test_012.csv';
%   >> voltage_data = parse_34410a_data_csv(data_filename)
%   ans = 
%   
%     1411015905.349    0.3956
%     1411015905.362    0.4355
%     1411015905.375    0.4331
%     1411015905.388    0.4098
%     ...

DATA = load_from_mat(FILENAME);
if (~isempty(DATA))
    return;
end

% set to 1 if data was taken from BenchVue 2.5, and after 12pm noon.
BENCHVUE_V25_PM = 1;

% parameters dependent on BenchVue version
%--------------------------------------------------------------------------

% prior to version 2.5:
LINE_NUM_INFO1 = 1;
LINE_NUM_INFO2 = 6;
LINE_NUM_DATA = 7;
LINE_NUM_INFO_OFFSET = 11;

% version 2.5:
LINE_NUM_V25_INFO1 = 1;
LINE_NUM_V25_INFO2 = 8;
LINE_NUM_V25_DATA = 9;
LINE_NUM_V25_INFO_OFFSET = 11;

% default return values
DATA = [];

line_number_info = 0;
line_number_data = 0;
sample_count = 0;
using_benchvue_v25 = 0;

% open the data file
[fid, msg] = fopen(FILENAME, 'r');

% check valid file descriptor
if (fid < 0)
    error('util:parse_34410a_data_csv', 'error opening file: %s\n%s', FILENAME, msg);
    return
end

% check if this file came from BenchVue version 2.5
line = fgetl(fid);
tokens = strsplit(line, ',');
if (~isempty(strfind(tokens{1},'Address')))
    using_benchvue_v25 = 1;
    fprintf('[WARNING]: File %s \n', FILENAME);
    fprintf('           may have come from BenchVue version 2.5 (or later). \n');
    fprintf('           Please see parse_34410a_data_csv.m for a note regarding \n');
    fprintf('           timestamps (verify the BENCHVUE_V25_PM flag). \n');
end

% skip to line with header info
if (using_benchvue_v25)
    line_number_info = LINE_NUM_V25_INFO2;
else
    line_number_info = LINE_NUM_INFO2;
end

% starting from line 2...
for i = 2:line_number_info
    line = fgetl(fid);
end
tokens = strsplit(line, ',');

% check if this line contains the header information, or the extra Setup
% information (from the BenchVue export option)
if (strcmpi(tokens{1}, 'Sample Count'))
    if (using_benchvue_v25)
        line_number_data = LINE_NUM_V25_DATA + LINE_NUM_INFO_OFFSET;
    else
        line_number_data = LINE_NUM_DATA + LINE_NUM_V25_INFO_OFFSET;
    end
else
    if (using_benchvue_v25)
        line_number_data = LINE_NUM_V25_DATA;
    else
        line_number_data = LINE_NUM_DATA;
    end
end

% skip ahead to line with data
for i = (line_number_info+1):line_number_data
    line = fgetl(fid);
end

% Declare the format of the data samples.
% Prior to version 2.5:
%   <integer>,<string>,<double>,
%     which represents: <sample>,<timestamp>,<voltage>,
%
% Version 2.5
%   <string>,<double>
%     which represents: <timestamp>,<voltage>
if (using_benchvue_v25)
    formatspec = '%s%f';
else
    formatspec = '%d%s%f';
end

% use SAMPLE_COUNT if it is available (from the setup text)
raw_data = [];
try
    raw_data = textscan( ...
        fid, formatspec, ...
        'Delimiter', ',', ...
        'ReturnOnError', false);
catch me
    error('util:parse_34410a_data_csv', 'Exception occurred: %s', me.message);
end
fclose(fid);

% error check
if (isempty(raw_data))
    return
end

SAMPLE_COUNT = size(raw_data{1}, 1);

if (using_benchvue_v25)
    raw_data_timestamp = raw_data{1};
    raw_data_voltage = raw_data{2};
else
    raw_data_sample_number = raw_data{1};
    raw_data_timestamp = raw_data{2};
    raw_data_voltage = raw_data{3};
end

% final data output is two columns: [time, voltage]
DATA = zeros(SAMPLE_COUNT, 2);

DATE_FORMAT_K = 'YYYY-mm-dd HH:MM:SS.FFF';

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
    
    if (BENCHVUE_V25_PM)
        date_num = date_num + (12 / 24); % add a half-day
    end
    
    days_from_year = date_num - datenum(date_vec(1));
    secs_from_year = days_from_year * 24 * 3600;
    
    DATA(i,1) = secs_from_year;
    DATA(i,2) = raw_data_voltage(i);
end

% save locally
save_to_mat(FILENAME,DATA);

return
