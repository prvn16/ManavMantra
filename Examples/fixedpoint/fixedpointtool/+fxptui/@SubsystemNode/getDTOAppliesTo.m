function [listselection,  list] = getDTOAppliesTo(this)
% GETDTOAPPLIESTO Returns the current selection and list of options

% Copyright 2010-2013 MathWorks, Inc.

% Get the list of valid settings from the underlying object
    if(this.isDominantSystem('DataTypeOverride'))
        
        list = { ...
            fxptui.message('labelAllNumericTypes'), ...
            fxptui.message('labelFloatingPoint'), ...
            fxptui.message('labelFixedPoint')};
        
        % the dominant system is the same as DTO system
        objval = this.getParameterValue('DataTypeOverrideAppliesTo');     
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
    else
        if(isempty(this.DTODominantSystem))
            listselection = fxptui.message('labelDisabledDatatypeOverride');
        else
            dsys_name = fxptui.getPath(this.DTODominantSystem.Name);
            listselection = fxptui.message('labelControlledBy', dsys_name);
        end
        list = {listselection};
    end
end

% [EOF]
