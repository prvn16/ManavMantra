function saveShortcuts(this)
% SAVESHORTCUTS Save the customized shortcuts defined for the model.

%   Copyright 2015-2016 The MathWorks, Inc.

% Get the custom shortcuts defined by the user for the model. We don't need
% to save the factory shortcuts as they are the same for every model.
% Serialize to model.
%========================================================================
%  !!! SERIALIZE THE SHORTCUTS TO THE MODEL IN THE BELOW FORMAT !!!
%========================================================================
% '{{BtnNames},{''ShortcutName1'',ChangeMMO,ChangeDTO,ChangeRunName,''RunName'',...
%   ''blkSID1'',{''topModelTracePath''},''MMO'',''DTO'',''DTOAppliesTo'',...
%   ''blkSID2'',{''topModelTracePath''},''MMO'',''DTO'',''DTOAppliesTo'',...},...
%  {''ShortcutName2'',ChangeMMO,ChangeDTO,ChangeRunName,......},...}
%
% The string is constructed such that it can be evaluated to return cell
% arrays of shortcuts that are easier to work with rather than parsing
% them as a string. It is important that the string be constructed in such
% a way that all its contents are valid in MATLAB. Special care needs to be
% taken while adding character quotes to strings.
%========================================================================

bd = this.ModelObject;
shortcutNames = this.getCustomShortcutNames;

% Do not save the original system settings shortcut, as this is created only at
% the FPT launch time. Remove it from the custom shortcuts list 
originalSettingsShortcut = fxptui.message('lblOriginalSettings');
shortcutIdx =  strcmp(shortcutNames, originalSettingsShortcut);
shortcutNames(shortcutIdx) = [];

customMap = this.getCustomShortcutMapForModel;

% Get the buttons on the panel and save them if they are different from the
% default.
buttonConfig = this.getShortcutOptions;
defaultConfig = this.DefaultShortcutOptions;

needToSaveBtnConfig = ~isequal(buttonConfig, defaultConfig);
needToSaveCustomShortcuts = customMap.getCount > 0;

if ~needToSaveBtnConfig && ~needToSaveCustomShortcuts
    bd.FPTShortcutValueString = '';
    return;
end

if needToSaveBtnConfig
    btnStr = sprintf('%s','{');
    for i = 1:length(buttonConfig)
        switch buttonConfig{i}
            case fxptui.message('lblDblOverride')
                bName = fxptui.message('lblDblOverrideUntranslated');
            case fxptui.message('lblFxptOverride')
                bName = fxptui.message('lblFxptOverrideUntranslated');
            case fxptui.message('lblSglOverride')
                bName = fxptui.message('lblSglOverrideUntranslated');
            case fxptui.message('lblMMOOff')
                bName = fxptui.message('lblMMOOffUntranslated');
            case fxptui.message('lblDTOMMOOff')
                bName = fxptui.message('lblDTOMMOOffUntranslated');
            otherwise
                bName = buttonConfig{i};
        end
        btnStr = sprintf('%s''''%s''''%s',btnStr,bName,',');
    end
    if strcmp(btnStr(end),',')
        btnStr = btnStr(1:end-1);
    end
    btnStr = sprintf('%s%s',btnStr,'}');
else
    btnStr = sprintf('%s%s%s','{','}');
end

valueString = sprintf('%s',btnStr);

if needToSaveCustomShortcuts
    for i = 1:length(shortcutNames)
        tempStr = '';
        if customMap.isKey(shortcutNames{i})
            % Save only english string in model for factory defaults
            switch shortcutNames{i}
                case fxptui.message('lblDblOverride')
                    sName = fxptui.message('lblDblOverrideUntranslated');
                case fxptui.message('lblFxptOverride')
                    sName = fxptui.message('lblFxptOverrideUntranslated');
                case fxptui.message('lblSglOverride')
                    sName = fxptui.message('lblSglOverrideUntranslated');
                case fxptui.message('lblMMOOff')
                    sName = fxptui.message('lblMMOOffUntranslated');
                case fxptui.message('lblDTOMMOOff')
                    sName = fxptui.message('lblDTOMMOOffUntranslated');
                otherwise
                    sName = shortcutNames{i};
            end
            % Begin each cell array with the shortcut name.
            tempStr = sprintf('%s%s''''%s''''%s',tempStr,'{',sName,',');
            % Get the settings map for a given shortcutName
            settingsMap = customMap.getDataByKey(shortcutNames{i});
            %====================================================
            % !!! SAVE THE SETTINGS IN THE FOLLOWNG ORDER !!!
            % {..,ChangeMMO,ChangeDTO,ChangeRunName,RunName,..}
            %====================================================
            % First process the global settings for the shortcut
            if settingsMap.isKey('GlobalModelSettings')
                globalMap = settingsMap.getDataByKey('GlobalModelSettings');
                for p = {'CaptureInstrumentation','CaptureDTO','ModifyDefaultRun','RunName'}
                    param = p{:};
                    switch lower(param)
                        case 'runname'
                            if globalMap.isKey(param)
                                % Save english strings for default run names
                                switch globalMap.getDataByKey(param)
                                    case fxptui.message('lblDblOverrideRunName')
                                        rName = fxptui.message('lblDblOverrideRunNameUntranslated');
                                    case fxptui.message('lblSglOverrideRunName')
                                        rName = fxptui.message('lblSglOverrideRunNameUntranslated');
                                    case fxptui.message('lblFxptOverrideRunName')
                                        rName = fxptui.message('lblFxptOverrideRunNameUntranslated');
                                    case fxptui.message('lblMMOOffRunName')
                                        rName = fxptui.message('lblMMOOffRunNameUntranslated');
                                    otherwise
                                        rName = globalMap.getDataByKey(param);
                                end
                                tempStr = sprintf('%s''''%s''''%s',tempStr,rName,',');
                            else
                                tempStr = sprintf('%s''''%s''''%s',tempStr,'',',');
                            end
                        otherwise
                            if globalMap.isKey(param)
                                tempStr = sprintf('%s%s%s',tempStr,num2str(globalMap.getDataByKey(param)),',');
                            else
                                tempStr = sprintf('%s''''%s''''%s',tempStr,'',',');
                            end
                    end
                end
            end
            if settingsMap.isKey('SystemSettingMap')
                blksettingsMap = settingsMap.getDataByKey('SystemSettingMap');
                for k = 1:blksettingsMap.getCount
                    map = blksettingsMap.getDataByIndex(k);
                    % get the settings map for each saved system handle.
                    if map.getCount > 0
                        hasValidBlock = false;
                        if map.isKey('SID')
                            blkSID = map.getDataByKey('SID');
                            hasValidBlock = true;
                        end
                        if ~hasValidBlock
                            map.Clear;
                        else
                            if ~isempty(blkSID)
                                % Find the first delimimiter of the
                                % SID. Thje first part is always the model
                                % name. We don't want to store the SID with
                                % the model name since it is not robust to
                                % model name changes.
                                indx = regexp(blkSID,':','start');
                                if ~isempty(indx)
                                    blkSID = blkSID(indx:end);
                                else
                                    blkSID = '';
                                end
                                tempStr = sprintf('%s''''%s''''%s',tempStr,blkSID,',');
                                if map.isKey('TopModelTracePath')
                                    tempStr = sprintf('%s%s',tempStr,'{');
                                    tracePath = map.getDataByKey('TopModelTracePath');
                                    for indx = length(tracePath):-1:1
                                        sid = tracePath{indx};
                                        % Remove the model name from the SID to protect against model re-name
                                        idx = regexp(sid,':','start');
                                        sid = sid(idx:end);
                                        tempStr = sprintf('%s''''%s''''%s',tempStr,sid,',');
                                    end
                                    %Remove the trailing comma from the string.
                                    if strcmpi(tempStr(end),',')
                                        tempStr = tempStr(1:end-1);
                                    end
                                    tempStr = sprintf('%s%s%s',tempStr,'}',',');
                                else
                                    tempStr = sprintf('%s%s%s%s',tempStr,'{','}',',');
                                end
                                for m = {'MinMaxOverflowLogging','DataTypeOverride','DataTypeOverrideAppliesTo'}
                                    param = m{:};
                                    if map.isKey(param)
                                        switch param
                                            case 'MinMaxOverflowLogging'
                                                val = map.getDataByKey(param);
                                                switch val
                                                    case 'MinMaxAndOverflow'
                                                        str = 'M';
                                                    case 'OverflowOnly'
                                                        str = 'O';
                                                    case 'ForceOff'
                                                        str = 'F';
                                                    otherwise
                                                        str = '';
                                                end
                                                tempStr = sprintf('%s''''%s''''%s',tempStr,str,',');
                                            case 'DataTypeOverride'
                                                val = map.getDataByKey(param);
                                                switch val
                                                    case {'TrueDoubles', 'Double'}
                                                        str = 'D';
                                                    case {'TrueSingles', 'Single'}
                                                        str = 'S';
                                                    case {'ScaledDoubles', 'ScaledDouble'}
                                                        str = 'SD';
                                                    case {'ForceOff', 'Off'}
                                                        str = 'F';
                                                    otherwise
                                                        str = '';
                                                end
                                                tempStr = sprintf('%s''''%s''''%s',tempStr,str,',');
                                            case 'DataTypeOverrideAppliesTo'
                                                val = map.getDataByKey(param);
                                                switch val
                                                    case 'Floating-point'
                                                        str = 'flt';
                                                    case 'Fixed-point'
                                                        str = 'fix';
                                                    otherwise
                                                        str = '';
                                                end
                                                tempStr = sprintf('%s''''%s''''%s',tempStr,str,',');
                                        end
                                    else
                                        tempStr = sprintf('%s''''%s''''%s',tempStr,'',',');
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        % Remove trailing ',' from the string so that it can be evaluated.
        if ~isempty(tempStr)
            tempStr = tempStr(1:end-1);
            tempStr = sprintf('%s%s',tempStr,'}');
        end
        if ~isempty(valueString)
            valueString = sprintf('%s%s%s',valueString,',',tempStr);
        end
    end
end
% Make it a string so that it can be saved as a model parameter.
valueString = sprintf('''%s%s%s''','{',valueString,'}');
bd.FPTShortcutValueString = valueString;
end

