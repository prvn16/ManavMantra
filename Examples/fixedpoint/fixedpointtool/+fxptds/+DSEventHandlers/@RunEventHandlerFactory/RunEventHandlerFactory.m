classdef RunEventHandlerFactory < handle 
%% RUNEVENTHANDLERFACTORY handles creation of RunEventHandler for handling FPTRun based events

%   Copyright 2016 The MathWorks, Inc.

    methods(Static)
        function runEventHandlerObj = getInstance()
        %% GETRUNEVENTHANDLER function is a factory method which generates appropriate instance of 
        % RunEventHandler depending upon whether FPTWeb feature is featured
        % on or not. 
            if slfeature('FPTWeb')
                runEventHandlerObj = fxptds.DSEventHandlers.RunEventHandler();
            else 
                runEventHandlerObj = fxptds.DSEventHandlers.MERunEventHandler();
            end
        end
    end
end