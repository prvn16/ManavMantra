
%   Copyright 2015-2017 The MathWorks, Inc.

 classdef (Sealed) JavaScriptSettings < handle
    %JAVASCRIPTSETTINGS Summary of this class goes here
    %   Detailed explanation goes here
    %web(fullfile(docroot, 'matlab/matlab_oop/controlling-the-number-of-instances.html'))
    properties
        s = settings;
        settingsSubscription
    end
    properties(Access = 'private', Constant = true)
        channel = '/JavaScript/Preferences/Settings/SettingsChannel';
        SETTINGS_WATCH_CHANNEL = '/JavaScript/Preferences/Settings/SettingsWatchChannel';
    end
    methods (Access = private)
        function obj = JavaScriptSettings
        end
    end
    
    
    methods(Static)
        % This function ensures that the state of the listeners is a
        % singleton.
        function out = getInstance
            import internal.matlab.desktop.preferences.JavaScriptSettings;
            persistent sInstance;
            if isempty(sInstance)|| ~isvalid(sInstance)
                sInstance = JavaScriptSettings;
                sInstance.addSettingsListeners();
            end
            out = sInstance;
        end
        
        function destroyInstance
          persistent sInstance;
          if isempty(sInstance)|| ~isvalid(sInstance)  
            delete(sInstance);
          end
          import internal.matlab.desktop.preferences.JavaScriptSettings;
          message.unsubscribe(JavaScriptSettings.channel)
        end
    end
    
    
    methods
        
          function addSettingsListeners(this)
            import internal.matlab.desktop.preferences.JavaScriptSettings;
            this.settingsSubscription = message.subscribe(JavaScriptSettings.channel,  @(es)this.setSetting(es));
            if isempty(this.settingsSubscription)
                delete(sInstance);
            end
        end
        
        
        function setSetting(this,es)
            orig_state = warning;
            warning('off','all');
            import internal.matlab.desktop.preferences.JavaScriptSettings;
            % for Set Setting
            % http://www.mathworks.com/help/matlab/matlab_prog/string-evaluation.html
            try
                settingPath = this.s.(es.SettingPath{1});
                for idx = 2:numel(es.SettingPath)
                    settingPath = settingPath.(es.SettingPath{idx});
                end
            catch ex
              
                message.publish(JavaScriptSettings.channel, {es.uuid ex});
            end
             if(strcmp(es.eventType, 'setSetting'))
                try
                    msgObj = {};
                    msgObj.oldValue = settingPath.(es.settingKey).ActiveValue;
                    
                    % check if the datatype of setting value in settings
                    % file is int32.
                    if(isa(msgObj.oldValue, 'int32'))
                        settingPath.(es.settingKey).PersonalValue = int32(es.SettingValue);
                        
                    % check if the datatype of setting value in settings
                    % file is cell.
                    elseif(isa(msgObj.oldValue, 'cell'))
                        
                        if(isempty(es.SettingValue))
                            settingPath.(es.settingKey).PersonalValue = {};
                        else
                            settingPath.(es.settingKey).PersonalValue = es.SettingValue;
                        end
                        
                    % for other cases, no casting needed.
                    else
                        settingPath.(es.settingKey).PersonalValue = es.SettingValue;
                    end
              
                    msgObj.newValue = settingPath.(es.settingKey).ActiveValue;
                    msgObj.Message = 'settingChanged';
                    msgObj.uuid = es.uuid;
                    msgObj.settingKey = es.settingKey;
                    msgObj.settingPath = es.SettingPath;
                    message.publish(JavaScriptSettings.channel, msgObj);
                    message.publish(JavaScriptSettings.SETTINGS_WATCH_CHANNEL, msgObj);
                catch ex
                  
                    message.publish(JavaScriptSettings.channel, {es.uuid ex});
                end
                % for get Setting
            else
                try
                    value = settingPath.(es.settingKey).ActiveValue;
                    %Try Struct
                    msgObj = {};
                    msgObj.uuid = es.uuid;
                    msgObj.value = value;
                    msgObj.Message = 'getSetting';
                    msgObj.settingKey = es.settingKey;
                  
                    message.publish(JavaScriptSettings.channel, msgObj);
                catch ex
                 
                    message.publish(JavaScriptSettings.channel, {es.uuid ex});
                end
             end
             warning(orig_state);
            
        end
    end
    
    
end

