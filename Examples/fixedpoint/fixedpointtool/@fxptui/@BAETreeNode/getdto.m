function [listselection, list] = getdto(this)
%GETMMO   Get the mmo.
%   OUT = GETMMO(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.

list = { ...
    fxptui.message('labelUseLocalSettings'), ...
    fxptui.message('labelScaledDoubles'), ...
    fxptui.message('labelTrueDoubles'), ...
    fxptui.message('labelTrueSingles'), ...
    fxptui.message('labelForceOff')}';

baexplr = fxptui.BAExplorer.getBAExplorer;

if ~isempty(baexplr) && ~baexplr.CaptureDTO
    listselection = fxptui.message('labelNotModifyDTO');
    list = {listselection};
    return;
end

%get the list of valid settings from the underlying object
if(this.isdominantsystem('DataTypeOverride'))
    try
        objval = this.DataTypeOverride;
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
    catch e % Does not have a DataTypeOverride parameter.
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
