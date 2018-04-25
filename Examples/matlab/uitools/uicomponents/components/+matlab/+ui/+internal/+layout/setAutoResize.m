function setAutoResize(appwindow, value)
    % SETAUTORESIZE Enable or disable auto-resize of the app for runtime
    %
    % This method must be kept for backwards compatibility reasons.
    % Apps created before 17a use this method in their generated code to
    % enable/disable auto resize on the uifigure and all descendent
    % containers in it.
    %    
    % Copyright 2014-2016 The MathWorks, Inc.

    % AutoResizeChildren is an on/off property
    if(value)
        convertedValue = 'on';
    else
        convertedValue = 'off';
    end

    % Set the property on the uifigure
    appwindow.AutoResizeChildren = convertedValue;

    % Set all containers parented to this uifigure to the same
    % setting for auto resize
    set(appwindow, ...
        'DefaultUipanelAutoresizechildren', convertedValue,...
        'DefaultUitabgroupAutoresizechildren', convertedValue,...
        'DefaultUitabAutoresizechildren', convertedValue,...
        'DefaultUibuttongroupAutoresizechildren', convertedValue);