function FIXED_STRING = stat_fixer_1(CORRUPT_TIME)

FIXED_STRING = [];
delimiters = {':','.'};

tokens = strsplit(CORRUPT_TIME,delimiters);
num_tokens = length(tokens);

if (num_tokens ~= 4)
    disp(['Problem parsing: ', CORRUPT_TIME]);
    return
end

hour = str2num(tokens{1});
mins = str2num(tokens{2});
secs = str2num(tokens{3});
msec = str2num(tokens{4});

if (hour <= 0)
    hour = hour + 23;
end

if (mins <= 0)
    mins = mins + 59;
end

if (secs <= 0)
    secs = secs + 59;
end

if (msec <= 0)
    msec = msec + 1000;
end

FIXED_STRING = sprintf('%02d:%02d:%02d.%03d', ...
    hour,mins,secs,msec);
