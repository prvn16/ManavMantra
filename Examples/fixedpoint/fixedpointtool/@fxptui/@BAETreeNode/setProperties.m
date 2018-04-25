function [ok, errmsg] = setProperties(this, hdlg)
%SETPROPERTIES Set the Properties
%   OUT = SETPROPERTIES(ARGS) <long description>

%   Copyright 2015 The MathWorks, Inc.

ok = true;
errmsg = '';

try
    value = hdlg.getWidgetValue('cbo_log_save_mode');
    this.MinMaxOverflowLogging = fxptui.convertEnumToParamValue('MinMaxOverflowLogging',value);
catch
    %if an invalid index is passed in don't set MinMaxOverflowLogging and
    %consume the error.
end

try
    value = hdlg.getWidgetValue('cbo_dt_save_mode');
    this.DataTypeOverride = fxptui.convertEnumToParamValue('DataTypeOverride',value);
catch
    %if an invalid value is passed in don't set DataTypeOverride and
    %consume the error.
end

try
    value = hdlg.getWidgetValue('cbo_dt_appliesto_save_mode');
    this.DataTypeOverrideAppliesTo = fxptui.convertEnumToParamValue('DataTypeOverrideAppliesTo',value);
catch
    %if an invalid value is passed in don't set DataTypeOverride and
    %consume the error.
end

this.firehierarchychanged;
% [EOF]
