function [listselection, list] = getDTO(this)
% GETDTO Gets the current DTO selection and the list of options.

% Copyright 2013 MathWorks, Inc
    
% Get the list of valid settings from the underlying object
    if(this.isDominantSystem('DataTypeOverride'))
        list = { ...
            fxptui.message('labelUseLocalSettings'), ...
            fxptui.message('labelScaledDoubles'), ...
            fxptui.message('labelTrueDoubles'), ...
            fxptui.message('labelTrueSingles'), ...
            fxptui.message('labelForceOff')}';  
        
        objval = this.getParameterValue('DataTypeOverride');     
        % Use a switchyard instead of ismember() to improve performance.
        switch objval
          case 'UseLocalSettings'
            listselection = list{1};
          case {'ScaledDoubles', 'ScaledDouble'}
            listselection = list{2};
          case {'TrueDoubles', 'Double'}
            listselection = list{3};
          case {'TrueSingles', 'Single'}
            listselection = list{4};
          case {'ForceOff', 'Off'}
            listselection = list{5};
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
