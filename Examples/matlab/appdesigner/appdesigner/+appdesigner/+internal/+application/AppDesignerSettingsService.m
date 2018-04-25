classdef (Sealed) AppDesignerSettingsService < handle
    % This class is a workaround for listening to setting value changes in matlab.
    % The setting watch API will be finished by other team by code freeze of 17a,
    % before that time, App Designer team will provide a workaround which is what
    % this class does. We will clean this class after all the settings API ready to use.
    % In this workaround, we use dynamic property of the setting entry. And add
    % event listener to the "PostSet" event. The pain point is that we need to add
    % event listener to each settings entry one by one and currently there is no way
    % to add listener to settings group.
    
    properties (Access = private)
        
        % listeners to the Preferences being updated.
        PreferencesListeners = {}
    end
    
    properties (Constant)
        
        % setting watch channel for app designer.
        SettingWatchChannel = '/AppDesigner/Preferences/Settings/SettingsChannel';
        
        % setting entires that we want to watch.
        SettingsList = {...
            {'designview', 'ShowGrid'},...
            {'designview', 'GridInterval'},...
            {'designview', 'SnapToGrid'},...
            {'designview', 'ShowAlignmentHints'},...
            {'designview', 'ShowResizingHints'},...
            {'history', 'FileList'},...
            {'history', 'MaxFileListSize'}};
    end
    
    methods (Access = public)
        function obj = AppDesignerSettingsService
            % initialize all the property listener to
            
            % if the preferences listeners are not empty, do nothing.
            % Because it should have alrady been initialized.
            if isempty(obj.PreferencesListeners)
                
                % Find all available settings within the group and add
                % event listener to each settings entry
                obj.PreferencesListeners = cellfun(@(x) obj.addSettingPropListener(x{:}), obj.SettingsList, 'UniformOutput', false);
            end
        end
        
        function delete(obj)
            
            % clear all the listeners for setting entries
            obj.PreferencesListeners = {};
        end
    end
    methods (Access = private)
        function propListener = addSettingPropListener(obj, subGroup, setting)
            % add property listener to setting entry
            
            s = settings;
            node = s.matlab.appdesigner.(subGroup);
            
            % find dynamic property of setting entry
            prop = findprop(node, setting);
            
            % add event listener on 'PostSet' event
            propListener = event.proplistener(node, prop, 'PostSet', @obj.handleSettingChanged);
        end
        
        function handleSettingChanged(~,src,event)
            % event handler for setting entry update
            
            import appdesigner.internal.application.AppDesignerSettingsService;
            settingKey = src.Name;
            settingEntry = event.AffectedObject.(settingKey);
            msgObj = {};
            msgObj.oldValue = settingEntry.ActiveValue;
            msgObj.newValue = settingEntry.ActiveValue;
            msgObj.Message = 'settingChanged';
            msgObj.settingKey = settingKey;
            
            % pulish the setting update message to client.
            message.publish(AppDesignerSettingsService.SettingWatchChannel, msgObj);
        end
    end   
end

