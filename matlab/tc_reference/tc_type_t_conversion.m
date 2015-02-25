function temperature_celsius = tc_type_t_conversion(millivolts)

REFERENCE_TABLE_TC_TYPE_T_FUNCTION_FILE = 'tc_type_t.mat';
REFERENCE_TABLE_TC_TYPE_T_FUNCTION_NAME = 'tc_type_t';

load(REFERENCE_TABLE_TC_TYPE_T_FUNCTION_FILE, ...
    REFERENCE_TABLE_TC_TYPE_T_FUNCTION_NAME);

temperature_celsius = interp1(tc_type_t(:,2), tc_type_t(:,1), millivolts);
