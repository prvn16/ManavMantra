
classdef PlotsTabState < handle
    % This class maintains the state of the Plots Tab
    % The current state of the plots tab is maintained here. This includes the
    % createNewFigure option and the information about which
    % selection(variable editor or workspace browser) is currently
    % reflected in the plots gallery
    
    % Copyright 2013 The MathWorks, Inc.
    
    properties
        % represents the state of the Reuse figure radio button
        createNewFig = false;
        
        % indicates which manager(Variable Editor or Workspace Browser is
        % currently used by the Plots Tab)
        currentManagerForPlotsTab;
    end
    
    methods(Static=true)
        function out = getInstance()
            persistent stateInstance;
            mlock;
            if isempty(stateInstance)
                stateInstance = internal.matlab.plotstab.PlotsTabState;
            end
            out = stateInstance;
        end
    end   
    
    methods
        function resetPlotsGalleryState(this)
            this.createNewFig = false;
        end
    end
end

