function [listselection, list] = getmmo(this)
%GETDTO   Get the dto.
%   OUT = GETDTO(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.

list = { ...
    fxptui.message('labelUseLocalSettings'), ...
    fxptui.message('labelMinimumsMaximumsAndOverflows'), ...
    fxptui.message('labelOverflowsOnly'), ...
    fxptui.message('labelMMOForceOff')}';
    
baexplr = fxptui.BAExplorer.getBAExplorer;
if ~isempty(baexplr) && ~baexplr.CaptureInstrumentation
    listselection = fxptui.message('labelNotModifyMMO');
    list = {listselection};
    return;
end

%get the list of valid settings from the underlying object
if(this.isdominantsystem('MinMaxOverflowLogging'))
    try
        objval = this.MinMaxOverflowLogging;
        % Use a switchyard instead of ismember() to improve performance.
        switch objval
            case 'UseLocalSettings'
                listselection = list{1};
            case 'MinMaxAndOverflow'
                listselection = list{2};
            case 'OverflowOnly'
                listselection = list{3};
            case 'ForceOff'
                listselection = list{4};
            otherwise
                listselection = '';
        end
    catch e % Does not have a MinMaxOverflowLogging parameter.
        listselection = list{1};
    end
else
    if(isempty(this.MMODominantSystem))
        listselection = fxptui.message('labelNoControl');
    else
        dsys_name = fxptui.getPath(this.MMODominantSystem.Name);
        listselection = fxptui.message('labelControlledBy', dsys_name);
    end
    list = {listselection};
end
% [EOF]
