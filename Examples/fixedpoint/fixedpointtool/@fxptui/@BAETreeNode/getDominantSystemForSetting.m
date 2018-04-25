function [dSys, dParam] = getDominantSystemForSetting(this, param)
% GETDOMINANTSYSTEM Get the system that is controlling the provided parameter

% Copyright 2015 The MathWorks, Inc

    dSys = [];
    dParam = [];
    if ~this.isValid
        return;
    end
    
    
    %throw an error if an invalid param is passed in
    %initialize the output args with the current system and param value
    dSys = this.daobject;
    dParam = this.daobject.(param);
    %get this systems parent
    parent = this.daobject.getParent;
    %loop until the model root is reached, we want to find the highest system
    %with a dominant setting (ie: anything but UseLocalSettings)
    while ~isempty(parent)
        if fxptds.isStateflowChartObject(parent)
            % we want the Simulink.Subsystem object which wraps the chart in a model.
            parent = get_param(parent.Path,'Object');
        end
        %if this parent doesn't have a dominant setting get the next parent
        if ~isa(parent, 'Stateflow.Object') && ~strcmp('UseLocalSettings', parent.(param))
            %this parent contains dominant setting, hold on to it
            dSys =   parent;
            dParam = parent.(param);
        end
        parent = parent.getParent;
    end
end
