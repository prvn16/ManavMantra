classdef SettingsModifier < matlab.unittest.internal.Teardownable
    % This class is undocumented.
    
    % This is a simple class that allows safe setting of session level
    % settings without modifying anything persistent, such as settings files in
    % prefdir. Upon destruction it restores the state.
    
    %  Copyright 2014-2015 The MathWorks, Inc.
    
    properties(SetAccess=immutable)
        Setting
    end
    
    methods
        
        function modifier = SettingsModifier(setting)
            modifier.Setting = setting;
        end
        
        
        function applySessionSetting(modifier, name, value)
            setting = modifier.Setting;
            if (setting.(name).hasTemporaryValue)
                originalValue = setting.(name).TemporaryValue;
                modifier.addTeardown(@setOriginalValue, setting.(name), originalValue);
            else
                  modifier.addTeardown(@clearTemporaryValue, setting.(name));
            end
              setting.(name).TemporaryValue = value;
        end
    end
end
function setOriginalValue(setting,value)
    setting.TemporaryValue = value;
end
% LocalWords:  Teardownable
