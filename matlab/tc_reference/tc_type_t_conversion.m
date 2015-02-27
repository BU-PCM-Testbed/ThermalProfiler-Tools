function temperature_celsius = tc_type_t_conversion(millivolts)
%
% Author: Charlie de Vivero
% Date  : 2014-08-14
%
% Organization:
%   Boston University PEAC Lab
%
% Function    : data conversion
% Description : This function converts voltage to temperature, according
%               to the Omega Type-T Thermocouple reference table.
%
% Parameters  : millivolts            - a positive floating point number
%                                       representing voltage (in Volts)
%
% Return      : temperature_celsius   - a floating point number
%                                       representing temperature (in
%                                       Celsius).
%
% Error Handling : Error thrown for invalid argument. Returns NaN if
%                  voltage is out of thermocouple temperature range.
%
% Examples of usage:
%
% tc_type_t_conversion(1.4)
% 
% ans =
% 
%    34.9268
%

validateattributes(millivolts,{'double'},{'positive'})

global tc_type_t

REFERENCE_TABLE_TC_TYPE_T_FUNCTION_FILE = 'tc_type_t.mat';
REFERENCE_TABLE_TC_TYPE_T_FUNCTION_NAME = 'tc_type_t';

if (isempty(tc_type_t))
    if (exist(REFERENCE_TABLE_TC_TYPE_T_FUNCTION_FILE,'file'))
        load(REFERENCE_TABLE_TC_TYPE_T_FUNCTION_FILE, ...
            REFERENCE_TABLE_TC_TYPE_T_FUNCTION_NAME);
    else
        tc_type_t = ref_table_to_func;
        save(REFERENCE_TABLE_TC_TYPE_T_FUNCTION_FILE, ...
            REFERENCE_TABLE_TC_TYPE_T_FUNCTION_NAME);
    end
end

temperature_celsius = interp1(tc_type_t(:,2), tc_type_t(:,1), millivolts);
