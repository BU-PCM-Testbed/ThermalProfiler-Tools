function save_to_mat(FILENAME, DATA)

MAT_DATA_DIR_NAME = 'mat';

% check if subdirectory MAT_DATA_DIR_NAME exists
current_dir = pwd;
if (ispc)
    MAT_DATA_DIR = sprintf('%s\\%s', current_dir, MAT_DATA_DIR_NAME);
else
    MAT_DATA_DIR = sprintf('%s/%s', current_dir, MAT_DATA_DIR_NAME);
end
if (~exist(MAT_DATA_DIR,'dir'))
    mkdir(MAT_DATA_DIR_NAME);
end

old_dir = cd(MAT_DATA_DIR);


% saved as FILENAME.mat, in the directory MAT_DATA_DIR

[pathstr,name,ext] = fileparts(FILENAME);
if (ispc)
    FILENAME_MAT = sprintf('%s\\%s.mat', MAT_DATA_DIR, name);
else
    FILENAME_MAT = sprintf('%s/%s.mat', MAT_DATA_DIR, name);
end

save(FILENAME_MAT,'DATA');
cd(old_dir);
