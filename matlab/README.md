# ThermalProfiler-Tools - Matlab

You **must** add *tools_setup.m* to your Matlab startup script. Customize *tools_setup.m* to 
include relevant directories on your system.

Example: add the following lines to your `startup.m` script (should be located in your [MATLAB Startup Folder](http://www.mathworks.com/help/matlab/matlab_env/matlab-startup-folder.html)):

```
cd('C:\Users\devivero\github\ThermalProfiler-Tools\matlab');
tools_setup;
```

Note: this changes your working directory. To avoid doing so, you may instead try:

```
original_dir = cd('C:\Users\devivero\github\ThermalProfiler-Tools\matlab');
tools_setup;
cd(original_dir);
```
