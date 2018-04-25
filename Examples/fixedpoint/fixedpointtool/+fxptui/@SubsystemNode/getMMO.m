function [selection, list] = getMMO(this)
% GETMMO Gets the current selection and list of options

% Copyright 2006-2013 MathWorks, Inc

%get the list of valid settings from the underlying object
    if(this.isDominantSystem('MinMaxOverflowLogging'))
        list = { ...
            fxptui.message('labelUseLocalSettings'), ...
            fxptui.message('labelMinimumsMaximumsAndOverflows'), ...
        fxptui.message('labelOverflowsOnly'), ...
            fxptui.message('labelMMOForceOff')}';
        objval = this.getParameterValue('MinMaxOverflowLogging'); 
        % Use a switchyard instead of ismember() to improve performance.
        switch objval
          case 'UseLocalSettings'
            selection = list{1};
          case 'MinMaxAndOverflow'
            selection = list{2};
          case 'OverflowOnly'
            selection = list{3};
          case 'ForceOff'
            selection = list{4};
          otherwise
            selection = '';
        end
    else
        if(isempty(this.MMODominantSystem))
            selection = fxptui.message('labelNoControl');
        else
            dsys_name = fxptui.getPath(this.MMODominantSystem.Name);
            selection = fxptui.message('labelControlledBy', dsys_name);
        end
        list = {selection};
    end
end

