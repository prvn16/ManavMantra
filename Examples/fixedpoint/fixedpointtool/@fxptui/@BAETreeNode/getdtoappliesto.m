function [listselection,  list] = getdtoappliesto(this)
%GETDTOAPPLIESTO Get the dtoappliesto.
%   OUT = GETDTOAPPLIESTO(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.

%get the list of valid settings from the underlying object
if(this.isdominantsystem('DataTypeOverride'))
    
    list = { ...
        fxptui.message('labelAllNumericTypes'), ...
        fxptui.message('labelFloatingPoint'), ...
        fxptui.message('labelFixedPoint')};
    try
        objval = this.DataTypeOverrideAppliesTo;
        %Use a switchyard instead of ismember() to improve performance.
        switch objval
            case 'AllNumericTypes'
                listselection = list{1};
            case 'Floating-point'
                listselection = list{2};
            case 'Fixed-point'
                listselection = list{3};
            otherwise
                listselection = '';
        end
    catch e
        listselection = list{1};
    end
else
    if(isempty(this.DTODominantSystem))
        listselection = fxptui.message('labelDisabledDatatypeOverride');
    else
        dsys_name = fxptui.getPath(this.DTODominantSystem.Name);
        listselection = fxptui.message('labelControlledBy', dsys_name);
    end
    list = {listselection};
end

% [EOF]
