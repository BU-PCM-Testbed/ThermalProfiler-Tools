# ThermalProfiler-Tools - Shell Scripts

Scripts to interact with the Android OS on the IFC6410, and an alternative interface to the *ThermalProfiler* app.

These scripts use the [Android Debug Bridge (*adb*)](http://developer.android.com/tools/help/adb.html) to execute shell 
commands on the IFC6410. *adb* is included in the [Android SDK tools](http://developer.android.com/sdk/index.html).

Useful *adb* commands:

**Start a remote shell**

```
$ adb shell
```

**Download *ThermalProfiler* data to your computer**

*ThermalProfiler* data is always saved to `/sdcard/Download/stat.csv` on the IFC6410 filesystem (existing data is 
overwritten after every recording session).

```
$ adb pull /sdcard/Download/stat.csv [local]

  optional:
  [local]        location and/or filename to save on your computer
```

**Shutdown IFC6410**

Switch to root to shutdown the system.

```
$ su
# reboot -p
```

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
$ android_thermal_profiler.sh start|home|record|benchmark|debug|ambientplus|ambientminus|(ambient <temp>)|(threads <num>)
  
  arguments:
  start           starts the app
  home            goes to the Android home screen
  record          presses the Record button
  benchmark       presses the Benchmark button
  debug           presses the Debug button
  ambientplus     presses the Ambient Temperature (+) button
  ambientminus    presses the Ambient Temperature (-) button
  ambient <temp>  specify <temp> as a floating point number. defines Ambient Temperature, in Celsius
  threads <num>   specify <num> as 1, 2, 3, or 4. defines number of benchmark threads to execute
```

## android_measure_usage.sh
Measure CPU usage of the *ThermalProfiler* app.

```
$ android_measure_usage.sh [time]
  
  optional:
  [time]          time interval (seconds) to sample CPU usage (defaults to 5 sec)
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








