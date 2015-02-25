%%% ******************************************************************* %%%
%
%    directory names should include trailing slash!
%
%%% ******************************************************************* %%%

%%%------------------------------------------------------------------------
%%% PLATFORM: PC
%
if (ispc)
    DR_TESTBED_SCRIPTS_DIR = 'C:\Users\Charlie\Dropbox\BU\Research\Testbed\matlab_Scripts\';
    DR_TESTBED_SCRIPTS_UTIL_DIR = 'C:\Users\Charlie\Dropbox\BU\Research\Testbed\matlab_Scripts\util\';
    DR_TESTBED_SCRIPTS_TC_REF_DIR = 'C:\Users\Charlie\Dropbox\BU\Research\Testbed\matlab_Scripts\thermocouple_reference\';
    addpath( ...
        DR_TESTBED_SCRIPTS_DIR, ...
        DR_TESTBED_SCRIPTS_UTIL_DIR, ...
        DR_TESTBED_SCRIPTS_TC_REF_DIR);
    
    DR_TESTBED_LOG_DIR = 'C:\Users\Charlie\Dropbox\BU\Research\Testbed\agilent_capture\';
    %DR_TESTBED_LOG_DIR = 'Z:\MATLAB\testbed_runlogs';
    
    DR_PTRACE_OUTPUT_DIR = 'C:\Users\Charlie\Dropbox\BU\Research\Testbed\ptrace_pcm\';

%%%------------------------------------------------------------------------
%%% PLATFORM: LINUX
%
elseif (isunix)
    
    DR_TESTBED_LOG_DIR = '/ad/eng/users/d/e/devivero/MATLAB/testbed_runlogs';
    DR_PTRACE_OUTPUT_DIR = '/mnt/nokrb/devivero/hotspot/HotSpot-5.02_varCp/ptrace_files/snapdragon/';
    
    DR_TESTBED_SCRIPTS_DIR = '/mnt/nokrb/devivero/hotspot/testbed_scripts/';
end
