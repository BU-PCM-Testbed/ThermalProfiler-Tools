function MAT_DATA = load_from_mat(FILENAME)

MAT_DATA = [];
MAT_DATA_DIR_NAME = 'mat';

% check if subdirectory MAT_DATA_DIR_NAME exists
current_dir = pwd;
if (ispc)
    MAT_DATA_DIR = sprintf('%s\\%s', current_dir, MAT_DATA_DIR_NAME);
else
    MAT_DATA_DIR = sprintf('%s/%s', current_dir, MAT_DATA_DIR_NAME);
end
if (~exist(MAT_DATA_DIR,'dir'))
    return;
end


% see if we've already parsed this file. it would be saved as:
% FILENAME.mat, in the directory MAT_DATA_DIR

[pathstr,name,ext] = fileparts(FILENAME);
if (ispc)
    FILENAME_MAT = sprintf('%s\\%s.mat', MAT_DATA_DIR, name);
else
    FILENAME_MAT = sprintf('%s/%s.mat', MAT_DATA_DIR, name);
end
if (exist(FILENAME_MAT,'file'))
    fprintf('Found %s, loading this file instead. \n', FILENAME_MAT);
    DATA_struct = load(FILENAME_MAT,'DATA');
    MAT_DATA = DATA_struct.DATA;
end
