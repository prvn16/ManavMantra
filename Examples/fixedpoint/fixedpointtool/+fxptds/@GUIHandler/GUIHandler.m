classdef GUIHandler < handle
%% GUIHANDLER class used to handle dialogs in FPT GUI
% responding to different events in fxptds.AbstractResult

%   Copyright 2016 The MathWorks, Inc.
    properties(Constant, GetAccess=private)
	GUIHandlerInstance = fxptds.GUIHandler();
    end
    methods (Static)
        function obj = getInstance
        % Returns the stored instance of the repository.
            persistent localObj
            if isempty(localObj) || ~isvalid(localObj)
                 localObj = fxptds.GUIHandler.GUIHandlerInstance;
            end
            obj = localObj;
        end
    end
    methods
        % NOTE: these methods donot need the object instance 
        % However, these methods are not made static function 
        % as GUIHandler is designed to be the interface which can be 
        % interchanged with the new GUI client 
        retValue = promptChangeGroupDialog(~);
        updateUI(~,result);
        handleInvalidProposedDT(~,proposedDT);
        appData = getApplicationData(~);
        allDatasets = getAllDatasets(~);
    end
    methods(Access = private)
        function  this = GUIHandler
        end
    end
    
end