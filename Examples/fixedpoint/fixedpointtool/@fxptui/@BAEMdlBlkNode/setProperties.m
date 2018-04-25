function [ok, errmsg] = setProperties(this, hdlg)
%SETPROPERTIES Set the Properties
%   OUT = SETPROPERTIES(ARGS) <long description>

%   Copyright 2010-2012 The MathWorks, Inc.

ok = true;
errmsg = '';

objectHandle = get_param(this.modelName, 'Object');
% identify the sub-models
subMdlName = this.daobject.ModelName;
% find the block from root
baexplr = fxptui.BAExplorer.getBAExplorer;
root = baexplr.getRoot;
subModelNode = find(root.Children, '-isa', 'fxptui.BAESubMdlNode', 'daobject', objectHandle);  %#ok<GTARG>

allInstances = root.SubMdlToBlkMap.getDataByKey(subMdlName);

setParameterValuesIgnoreExceptions('cbo_log_save_mode', 'MinMaxOverflowLogging', hdlg, subModelNode, allInstances); 
setParameterValuesIgnoreExceptions('cbo_dt_save_mode', 'DataTypeOverride', hdlg, subModelNode, allInstances); 
setParameterValuesIgnoreExceptions('cbo_dt_appliesto_save_mode', 'DataTypeOverrideAppliesTo', hdlg, subModelNode, allInstances); 

% broadcast changes on submodel node
subModelNode.firepropertychange;
hdlg.refresh;
this.firehierarchychanged;


function setParameterValuesIgnoreExceptions(widgetStr, parameterStr, hdlg, subModelNode, allInstances)

try
    % set properties to parameters from widget values
    value = hdlg.getWidgetValue(widgetStr); 
    paramValue = fxptui.convertEnumToParamValue(parameterStr,value);
    for index = 1:length(allInstances)
        allInstances(index).(parameterStr) = paramValue; 
        allInstances(index).firepropertychange;
    end
    subModelNode.(parameterStr) = paramValue; 
    
catch e %#ok
    %if an invalid index is passed in don't set MinMaxOverflowLogging and
    %consume the error.
end

% [EOF]

% LocalWords:  fxptui BAE daobject cbo appliesto
