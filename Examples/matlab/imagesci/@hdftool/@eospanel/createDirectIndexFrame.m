function [hFrame, api] = createDirectIndexFrame(this, hParentPanel)
%CREATEDIRECTINDEXFRAME Create a UITABLE in a panel.
%
%   Function arguments
%   ------------------
%   THIS: the eospanel object instance.
%   HPARENTPANEL: the HG parent for the frame.

%   Copyright 2005-2013 The MathWorks, Inc.

    % Create the components.
    hFrame = uipanel('Parent', hParentPanel);

    colNames = {getString(message('MATLAB:imagesci:hdftool:indexStart')), ...
        getString(message('MATLAB:imagesci:hdftool:indexIncrement')), ...
        getString(message('MATLAB:imagesci:hdftool:indexLength'))};
    parentFigure = ancestor(hFrame, 'Figure');

    [htable, tableApi] = this.createDirectIndexGroup( parentFigure, colNames);

    set(htable,'Parent', hFrame,...
        'Visible','on',...
        'Units', 'normalized',...
        'Position', [0 .2 .9 .7]);

    listener(1) = addlistener(hFrame,          'Visible', 'PostSet', @settablevisibility );
    listener(2) = addlistener(this.subsetPanel,'Visible', 'PostSet', @settablevisibility );


    % Create the API
    api.updateTableData = tableApi.initializeData;
    api.getTableData    = tableApi.getTableData;
    api.reset           = @reset;

    %===================================================
    function reset(istruct)
        api.updateTableData([istruct.Dims.Size]);
    end

    %===================================================
    function settablevisibility(src, event)
        if ~ishghandle(htable)
            delete(listener);
            return
        end

        isMainpanelOff = strcmp(get(this.subsetPanel,'Visible'), 'off');
        isParentOff    = strcmp(get(htable,'Visible'), 'off');
        if isParentOff || isMainpanelOff
            set(hFrame,'Visible','off');
        else
            set(hFrame,'Visible','on');
        end
    end

end
