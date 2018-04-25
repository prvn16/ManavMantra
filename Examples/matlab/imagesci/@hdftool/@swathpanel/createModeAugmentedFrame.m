function [panel, api] = createModeAugmentedFrame(this, hParent, frameType)
    %CREATEMODEAUGMENTEDFRAME will create a frame, and add a mode panel.
    %   It is designed to help with the extraction of HDF-EOS SWATH data.
    %
    %   Function arguments
    %   ------------------
    %   THIS: the swathPanel object instance.
    %   HPARENT: The HG parent of this frame.

    %   Copyright 2005-2013 The MathWorks, Inc.

    switch frameType
        case 'DirectIndex'
            [panel, api] = createDirectIndexFrame2(this, hParent);
        case 'GeographicBox'
            [panel, api] = createGeographicBoxFrame2(this, hParent);
        case 'Time'
            [panel, api] = createTimeFrame2(this, hParent);
        case 'UserDefined'
            [panel, api] = createUserDefinedFrame2(this, hParent);
    end

    % We declare the mode API here, so that it can be useed by all
    % subsequest callbacks.  It is set by the addModeCallback.
    modeApi = struct;
    function addModeCallback(middlePanel)
        % Add the swath extraction mode panel
        [modePanel, modeApi, modeSize] = this.createModeGroup(middlePanel);
        prefs = this.fileTree.fileFrame.prefs;
        set(middlePanel, 'WidthLimits', prefs.charPad(1)+[modeSize(1) modeSize(1)] );
        set(middlePanel, 'HeightLimits', prefs.charPad(1)+[modeSize(2) modeSize(2)] );
    end

    function [panel, api] = createDirectIndexFrame2(this, hParent)
        % The direct index frame does not provide for a mode panel.
        [panel, api] = this.createDirectIndexFrame(hParent);
    end

    function [panel, api] = createGeographicBoxFrame2(this, hParent)
        % Create an augmented geographic box frame
        [panel, api] = this.createGeographicBoxFrame(hParent, @addModeCallback);
        % Store the augmented API features
        api.getCTInclusionMode = modeApi.getCTInclusionMode;
        api.getGeolocationMode = modeApi.getGeolocationMode;
    end

    function [panel, api] = createTimeFrame2(this, hParent)
        % Create an augmented time frame
        [panel, api, leftPanel] = this.createTimeFrame(hParent, @addModeCallback);
        prefs = this.fileTree.fileFrame.prefs;
        % Store the augmented API features
        api.getCTInclusionMode = modeApi.getCTInclusionMode;
        api.getGeolocationMode = modeApi.getGeolocationMode;
    end

    function [panel, api] = createUserDefinedFrame2(this, hParent)
        % Create an augmented user-defined frame
        [panel, api, subsetPanelContainer] = createUserDefinedFrame(this, hParent);
        % Add the swath extraction mode panel
        [modePanel, modeApi, modeSize] = this.createModeGroup(subsetPanelContainer);
        api.getCTInclusionMode = modeApi.getCTInclusionMode;
        api.getGeolocationMode = modeApi.getGeolocationMode;
    end

end
