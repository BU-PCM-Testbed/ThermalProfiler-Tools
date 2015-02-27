%%% ******************************************************************* %%%
%
%    directory names should include trailing slash!
%
%%% ******************************************************************* %%%

%%%------------------------------------------------------------------------
%%% PLATFORM: PC
%
if (ispc)
    % Matlab script directories
    TESTBED_MATLAB_ROOT         = pwd;
    TESTBED_MATLAB_SCRIPTS      = [TESTBED_MATLAB_ROOT '\scripts\'];
    TESTBED_MATLAB_TC_REF       = [TESTBED_MATLAB_ROOT '\tc_reference\'];
    TESTBED_MATLAB_UTIL         = [TESTBED_MATLAB_ROOT '\util\'];
    TESTBED_MATLAB_UTIL_HS      = [TESTBED_MATLAB_ROOT '\util_hotspot\'];
    
    addpath( ...
        TESTBED_MATLAB_ROOT, ...
        TESTBED_MATLAB_SCRIPTS, ...
        TESTBED_MATLAB_TC_REF, ...
        TESTBED_MATLAB_UTIL, ...
        TESTBED_MATLAB_UTIL_HS ...
    );
    
    % test log directory
    TESTBED_LOG_DIR = 'C:\Users\Charlie\Dropbox\BU\Research\Testbed\agilent_capture\';
    
    % Hotspot-related directories
    HOTSPOT_PTRACE_OUTPUT_DIR = 'C:\Users\Charlie\Dropbox\BU\Research\Testbed\ptrace_pcm\';

%%%------------------------------------------------------------------------
%%% PLATFORM: LINUX
%
elseif (isunix)    
    % Matlab script directories
    TESTBED_MATLAB_ROOT         = pwd;
    TESTBED_MATLAB_SCRIPTS      = [TESTBED_MATLAB_ROOT 'scripts'];
    TESTBED_MATLAB_TC_REF       = [TESTBED_MATLAB_ROOT 'tc_reference'];
    TESTBED_MATLAB_UTIL         = [TESTBED_MATLAB_ROOT 'util'];
    TESTBED_MATLAB_UTIL_HS      = [TESTBED_MATLAB_ROOT 'util_hotspot'];
    
    addpath( ...
        TESTBED_MATLAB_ROOT, ...
        TESTBED_MATLAB_SCRIPTS, ...
        TESTBED_MATLAB_TC_REF, ...
        TESTBED_MATLAB_UTIL, ...
        TESTBED_MATLAB_UTIL_HS ...
    );
    
    % test log directory
    TESTBED_LOG_DIR = '/ad/eng/users/d/e/devivero/MATLAB/testbed_runlogs/';
    
    % Hotspot-related directories
    HOTSPOT_PTRACE_OUTPUT_DIR = '/mnt/nokrb/devivero/hotspot/HotSpot-5.02_varCp/ptrace_files/snapdragon/';
    HOTSPOT_SCRIPTS           = '/mnt/nokrb/devivero/hotspot/tools/';
    
end
