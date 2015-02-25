clc

% list files in current directory
directories = dir;
dir_names = cell(length(directories), 1);
for i = 1:length(dir_names)
    if (directories(i).name(1) ~= '.')
        dir_names{i} = directories(i).name;
    end
end
dir_names = dir_names(~cellfun(@isempty, dir_names));

% figure out how many different core options there are.
% assume files start with 'stat_'
filenames = {};
file_idx = 1;
for i = 1:length(dir_names)
    tokens = sscanf(dir_names{i}, 'stat%s');
    if (numel(tokens) == 0)
        continue
    end
    
    % add to list of files to inspect
    file = sprintf('stat%s', tokens);
    filenames{file_idx} = file;
    file_idx = file_idx + 1;
end

% number of files to check:
num_files = length(filenames);

% make a directory to store the original files
backup_files_dir = sprintf('backup_stat_%s', datestr(datetime('now'),'yyyy_mm_dd_HHMMSS'));
fprintf('Creating directory: %s', backup_files_dir);
mkdir(backup_files_dir);

% now check each file
for i = 1:num_files
    file_buffer = [];
    fid = fopen(filenames{i},'r');
    
    %
    % grab first line. should look like:
    %   <char>,<timestamp>,<timestamp>
    %
    % where <char> is a single ASCII character,
    % <timestamp> is a date/time with format yyyy-mm-dd HH:MM:SS.sss
    %
    % The timestamp is what gets f****d up for some unknown reason. The
    % app records hours/minutes/seconds as negative numbers.
    %
    
    line = fgetl(fid);
    tokens = strsplit(line, ',')
    broken = 0;
    
    fprintf('File: %s \n', filenames{i});
    fprintf('First line: %s\n',line);
    
    % skip fixing this if the timestamps are actually 0
    if (strcmp(tokens{2}, '0') || strcmp(tokens{3}, '0'))
        reconstr = sprintf('%c,%s,%s\n', tokens{1},tokens{2},tokens{3});
    else
        % fix the start/stop timestamps
        [start_time_fixed,broken1] = stat_fixer_0(tokens{2});
        fprintf('\n');
        
        [stop_time_fixed,broken2]  = stat_fixer_0(tokens{3});
        fprintf('\n');
        
        reconstr = sprintf('%c,%s,%s\n',tokens{1},start_time_fixed,stop_time_fixed);
        if (broken1 || broken2)
            fprintf('  Reconstructed: %s\n',reconstr);
        end
    end
    
    % store the reconstructed line
    file_buffer = [file_buffer, reconstr];
    
    % now check the rest of the lines
    while (1)
        line = fgetl(fid);
        
        % skip empty lines
        if (isempty(line))
            continue;
        end
        
        % stop at end-of-file
        if (line == -1)
            break;
        end
        
        tokens = strsplit(line, ',');
        num_tokens = length(tokens);
        if (num_tokens < 1)
            disp(['error parsing string: ', line]);
            break;
        end
        
        date_time = tokens{1};
        [reconstr, broken] = stat_fixer_0(date_time);
        
        for j = 2:num_tokens
            reconstr = [reconstr, sprintf(',%s',tokens{j})];
        end
        reconstr = sprintf('%s\n', reconstr);
        
        if (broken)
            fprintf('| Reconstructed: %s', reconstr);
        end
        
        % store the reconstructed line
        file_buffer = [file_buffer, reconstr];
        
    end
    
    
    % ------------------------------------------------------------
    fclose(fid);
    fprintf('\nRe-writing file %d: %s \n', i, filenames{i});
    
    % back up the original file
    backup_file = sprintf('%s\\%s', backup_files_dir, filenames{i});
    copyfile(filenames{i}, backup_file);
    
    % print the reconstructed file
    fid = fopen(filenames{i},'w');
    fwrite(fid,file_buffer);
    fclose(fid);
    
    fprintf('\n-------------------\n');
    
end

fprintf('\nDone.\n');