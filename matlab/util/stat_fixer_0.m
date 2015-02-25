function [FIXED_STRING, BROKEN] = stat_fixer_0(CORRUPT_TIMESTAMP)

FIXED_STRING = CORRUPT_TIMESTAMP;
BROKEN = 0;

date_time = CORRUPT_TIMESTAMP;
date_time_tokens = strsplit(date_time,' ');
num_date_time_tokens = length(date_time_tokens);
if (num_date_time_tokens ~= 2)
    fprintf('util:stat_fixer_0: error parsing string: %s',date_time);
    return;
end

date = date_time_tokens{1};
time = date_time_tokens{2};

if (~isempty(strfind(time,'-')))
    % fix the time
    fix = stat_fixer_1(time);
    fprintf('  Fixed timestamp: %18s => %14s ', time, fix);
    BROKEN = 1;
    time = fix;

    % fix the day
    date_num = datenum(date,'YYYY-mm-dd');
    date_num = date_num - 1;
    date = datestr(date_num,'YYYY-mm-dd');
else
    return;
end

FIXED_STRING = sprintf('%s %s', date, time);
