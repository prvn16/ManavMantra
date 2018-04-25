function [ok, errmsg] = setProperties(this, hdlg)
%SETPROPERTIES Set the Properties
%   OUT = SETPROPERTIES(ARGS) <long description>

%   Copyright 2010-2012 The MathWorks, Inc.

ok = true;
errmsg = '';

% identify the model reference block used in the model
% find the block from root
baexplr = fxptui.BAExplorer.getBAExplorer;
root = baexplr.getRoot;
ModelBlksNode = root.SubMdlToBlkMap.getDataByKey(this.daobject.getFullName);

if isempty(ModelBlksNode)
    ok = false;
    errmsg = fxptui.message('NoMdlBlkToSubMdlMap');
end

setParameterValuesIgnoreExceptions('cbo_log_save_mode', 'MinMaxOverflowLogging', hdlg, this, ModelBlksNode); 
setParameterValuesIgnoreExceptions('cbo_dt_save_mode', 'DataTypeOverride', hdlg, this, ModelBlksNode); 
setParameterValuesIgnoreExceptions('cbo_dt_appliesto_save_mode', 'DataTypeOverrideAppliesTo', hdlg, this, ModelBlksNode); 

this.firehierarchychanged;


function setParameterValuesIgnoreExceptions(widgetStr, parameterStr, hdlg, subModelNode, ModelBlksNode)

try
    % set properties to parameters from widget values
    value = hdlg.getWidgetValue(widgetStr); 
    paramValue = fxptui.convertEnumToParamValue(parameterStr,value);
    subModelNode.(parameterStr) = paramValue; 
    for index = 1:length(ModelBlksNode)
        ModelBlksNode(index).(parameterStr) = paramValue; 
        ModelBlksNode(index).firepropertychange;
    end
    
catch e %#ok
    %if an invalid index is passed in don't set MinMaxOverflowLogging and
    %consume the error.
end

% [EOF]

% LocalWords:  cbo appliesto
