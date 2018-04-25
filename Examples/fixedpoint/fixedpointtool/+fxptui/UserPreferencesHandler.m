classdef UserPreferencesHandler < handle
% USERPREFERENCESHANDLER provides basic APIs to manipulate a value in the
% Settings file. These changes can be saved with the user preference or
% model file by providing either the User or Model level flags
    
% Copyright 2014-2015 The MathWorks, Inc.
    
    properties(Constant,GetAccess=private)
        % Stores the class instance as a constant property
        HandlerInstance = fxptui.UserPreferencesHandler;
    end
    
    properties(GetAccess = private, SetAccess = private)
        FPTSettingsNode;
    end
    
    methods (Static)
        function obj = getInstance
            % Returns the stored instance of the repository.
            obj = fxptui.UserPreferencesHandler.HandlerInstance;
        end
    end
    methods (Access=private)
        function this = UserPreferencesHandler
            settingsTree = settings;
            this.FPTSettingsNode =  settingsTree.fixedpoint.fixedpointtool;
            mlock; % Prevents clearing of the class from MATLAB.
        end
    end
    
    methods        
        function val = getPreference(this, parameter)
            % Get the settings node that is defined in the FixedPointTool
            % settings factory file.
            val = [];
            if this.FPTSettingsNode.hasSetting(parameter)
                val = this.FPTSettingsNode.(parameter).ActiveValue;
            end
        end
        
        function setPreference(this, parameter, value)
            % Modify the setting so that it is saved in the user
            % preferences
            if this.FPTSettingsNode.hasSetting(parameter)
                this.FPTSettingsNode.(parameter).PersonalValue = value;
            end
        end
                
        function userSettings = getPreferences(this)
            propNames = properties(this.FPTSettingsNode);
            for i = 1:numel(propNames)
               userSettings.(propNames{i}) = this.FPTSettingsNode.(propNames{i}).ActiveValue;
            end
        end
    end
end
