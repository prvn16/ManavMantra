function [hGroup, api, minSize] = createBoxCornerGroup(this, hParent, defaultValue, prefs)
%CREATEBOXCORNERGROUP Creates a panel for box corner entry.
%
%   Function arguments
%   ------------------
%   THIS: the eospanel object instance.
%   HPARENT: the HG parent.
%   PREFS: the preferences structure.

%   Copyright 2005-2013 The MathWorks, Inc.

    title1 = getString(message('MATLAB:imagesci:hdftool:Corner1'));
    title2 = getString(message('MATLAB:imagesci:hdftool:Corner2'));
    if isempty(defaultValue) %The box must be optional
        title1 = getString(message('MATLAB:imagesci:hdftool:Optional',title1));
        title2 = getString(message('MATLAB:imagesci:hdftool:Optional',title2));
    end

    % Create the components
	labelStrings = { getString(message('MATLAB:imagesci:hdftool:labelStrLongitude')), ...
	                 getString(message('MATLAB:imagesci:hdftool:labelStrLatitude'))};
    [corner1Panel, corner1Api, corner1Minsize] = ...
        this.createEntryFieldGroup(hParent, [1 2], defaultValue, labelStrings, ...
        title1, prefs);

    [corner2Panel, corner2Api, corner2Minsize] = ...
        this.createEntryFieldGroup(hParent, [1 2], defaultValue, labelStrings, ...
        title2, prefs);

    boxMinWidth = corner1Minsize(1) + 2*prefs.charPad(1);
    boxMinHeight = 2*corner1Minsize(2) + 2*prefs.charPad(2);

    hGroup = [corner1Panel corner2Panel]; 
    minSize = [boxMinWidth boxMinHeight];

    % Create the API.
    api.getBoxCorner1Values = @getBoxCorner1Values;
    api.getBoxCorner2Values = @getBoxCorner2Values;
    api.reset               = @reset;

    %===========================================================
    function out = getBoxCorner1Values()
        out = corner1Api.getValues();
    end

    %===========================================================
    function out = getBoxCorner2Values()
        out = corner2Api.getValues();
    end

    %===========================================================
    function reset()
        corner1Api.reset();
        corner2Api.reset();
    end

end
