# ThermalProfiler-Tools - Shell Scripts

Scripts to interact with the Android OS on the IFC6410, and an alternative interface to the *ThermalProfiler* app.

----------------------------------------

## android_setup.sh
Run this script once **every time** you boot the IFC6410. This script will:

* Disable *mpdecision*

* Disable *thermald*

* Activate all 4 cores

* Set CPU core governors to *userspace*

* Enable all thermal sensors

* Set system time to current time


## android_activate_cores.sh
Enable 1, 2, 3, or 4 CPU cores. Remaining CPU cores are disabled.

```
$ android_activate_cores.sh <cores>

  arguments:
  <cores>         any number between 1 and 4, inclusive
```


## android_frequency.sh
Set CPU frequency of all active cores to `<frequency>` (in MHz).

```
$ android_frequency.sh <frequency>

  arguments:
  <frequency>     specify 384, 486, 594, 702, 810, 918, 1026, 1134, or 1242
```


## android_print_temperatures.sh
Print all readings from thermal sensors. CPU core temperatures denoted by *zone 7*, *8*, *9*, and *10*.

```
$ android_print_temperatures.sh [enable]
  
  optional:
  [enable]        enables all thermal sensors
```

## android_thermal_profiler.sh
Alternative user interface for the *ThermalProfiler* app.

```
$ android_thermal_profiler.sh start|home|record|benchmark|debug|(threads 1|2|3|4)
  
  arguments:
  start           starts the app
  home            goes to the Android home screen
  record          presses the Record button
  benchmark       presses the Benchmark button
  debug           presses the Debug button
  threads         specify 1, 2, 3, or 4. defines number of benchmark threads to execute
```


## Scripts for executing test runs
These scripts will execute a series of experiments. See comments inside script files to understand how they work.

**android_test_run_idle.sh**

* Used to run *idle power experiments*.

**android_test_run_idle_ordered.sh**

* An alternative to run *idle power experiments* based on a given list of experiments.

**android_test_run_benchmark_ss.sh**

* Used to run *steady-state benchmark experiments*.

**android_test_run_benchmark_tr.sh**

* Used to run *transient benchmark experiments*.

## Test lists
You can specify a test list as a comma-separated value (CSV) file. Test lists describe the order to which execute 
experiments, specified by a combination of number of active cores and frequency setting, and is currently implemented 
by *android_test_run_idle_ordered.sh*, and *android_test_run_benchmark_ss.sh*. See the following for examples:

**test_list_full_power_ramp.csv**

* A series of experiments in order of ascending power dissipation.

**test_list_steady_state.csv**

* A subset of *test_list_full_power_ramp.csv* which includes steady-state cases where the CPU settles to a thermally-safe temperature (for frequencies 594, 810, 1026, and 1242 MHz).







