function loadCustomShortcuts(this)
% LOADCUSTOMSHORTCUTS Load the custom shortcuts defined in the model
      
% Copyright 2015-2016 The MathWorks, Inc.

bd = get_param(this.ModelName, 'Object');
% Get the shortcut value string that is stored in the model.
valueString = bd.FPTShortcutValueString;
if isempty(valueString); return; end;
try
    [refMdls,~] = find_mdlrefs(bd.getFullName);
catch mdl_not_found_exception % Model not on path.
    fxptui.showdialog('modelnotfound',mdl_not_found_exception);
    return;
end

% Process the string to get the shortcut information.
try
    %======================================================================
    %                 !!! FORMAT OF THE VALUE STRING !!!
    %======================================================================
    % '{{''ShortcutName1'',ChangeMMO,ChangeDTO,ChangeRunName,''RunName'',...
    %    ''blkSID1'',{''topModelTracePath''},''MMO1'',''DTO1'',''DTOAppliesTo1'',...
    %    ''blkSID2'',{''topModelTracePath''},''MMO2'',''DTO2'',''DTOAppliesTo2'',...},...
    %   {''ShortcutName2'',ChangeMMO,ChangeDTO,ChangeRunName,......},...}
    %
    %======================================================================
    
    %  Evaluate the string to get all the shortcuts.
    shortcutStr = eval(valueString);
    % evaluate the string again to get a cell array of shortcuts.
    shortcutsArray = eval(shortcutStr);
    buttonInfo = shortcutsArray{1};
    if ~isempty(buttonInfo)
        % Factory shortcut names are stored in english
        bName(1:length(buttonInfo)) = {''};
        for i = 1:length(buttonInfo)
            switch buttonInfo{i}
                case {fxptui.message('lblDblOverrideUntranslated'),fxptui.message('lblDblOverrideOldUntranslated')}
                    bName{i} = fxptui.message('lblDblOverride');
                case {fxptui.message('lblFxptOverrideUntranslated'),fxptui.message('lblFxptOverrideOldUntranslated')}
                    bName{i} = fxptui.message('lblFxptOverride');
                case {fxptui.message('lblSglOverrideUntranslated'),fxptui.message('lblSglOverrideOldUntranslated')}
                    bName{i} = fxptui.message('lblSglOverride');
                case {fxptui.message('lblMMOOffUntranslated'),fxptui.message('lblMMOOffOldUntranslated')}
                    bName{i} = fxptui.message('lblMMOOff');
                case fxptui.message('lblDTOMMOOffUntranslated')
                    bName{i} = fxptui.message('lblDTOMMOOff');
                otherwise
                    bName{i} = buttonInfo{i};
            end
        end
        % set the shortcut buttons only if the current buttons for the
        % model are the default. This will prevent new shortcuts being
        % overridden from a previously loaded model in FPT which hasn't
        % been saved yet.
        if this.ShortcutOptionMap.isKey(bd.Handle)
            shortcutButtons = this.ShortcutOptionMap.getDataByKey(bd.Handle);
            if isequal(shortcutButtons, this.DefaultShortcutOptions)
                this.setShortcutButtonListForModel(bName);
            end
        else
            this.setShortcutButtonListForModel(bName);
        end
    end
    for i = 2:length(shortcutsArray)
        shortcutInfo = shortcutsArray{i};
        
        %==================================================================
        % Each shortcutInfo cell array will contain information in the
        % below format:
        % {'ShortcutName1',ChangeMMO,ChangeDTO,ChangeRunName,'RunName',...
        %  'blkSID1','MMO1','DTO1','DTOAppliesTo1',...
        %  'blkSID2','MMO2','DTO2','DTOAppliesTo2',...}
        %==================================================================
        shortcutName = shortcutInfo{1};
        % Factory shortcut names are stored in english
        switch shortcutName
            case {fxptui.message('lblDblOverrideUntranslated'),fxptui.message('lblDblOverrideOldUntranslated')}
                sName = fxptui.message('lblDblOverride');
            case {fxptui.message('lblFxptOverrideUntranslated'),fxptui.message('lblFxptOverrideOldUntranslated')}
                sName = fxptui.message('lblFxptOverride');
            case {fxptui.message('lblSglOverrideUntranslated'),fxptui.message('lblSglOverrideOldUntranslated')}
                sName = fxptui.message('lblSglOverride');
            case {fxptui.message('lblMMOOffUntranslated'),fxptui.message('lblMMOOffOldUntranslated')}
                sName = fxptui.message('lblMMOOff');
            case fxptui.message('lblDTOMMOOffUntranslated')
                sName = fxptui.message('lblDTOMMOOff');
            otherwise
                sName = shortcutName;
        end
        mdlSettingMap = this.getGlobalSettingMapForShortcut(sName);
        
        % Add the global settings to the given shortcut's map.
        mdlSettingMap.insert('DAObject', bd);
        
        % Add rest of the settings to the map only if it is non-empty.
        if ~isempty(shortcutInfo{2})
            mdlSettingMap.insert('CaptureInstrumentation',shortcutInfo{2});
        end
        if ~isempty(shortcutInfo{3})
            mdlSettingMap.insert('CaptureDTO',shortcutInfo{3});
        end
        if ~isempty(shortcutInfo{4})
            mdlSettingMap.insert('ModifyDefaultRun',shortcutInfo{4});
        end
        if ~isempty(shortcutInfo{5})
            switch shortcutInfo{5}
                case fxptui.message('lblDblOverrideRunNameUntranslated')
                    rName = fxptui.message('lblDblOverrideRunName');
                case fxptui.message('lblSglOverrideRunNameUntranslated')
                    rName = fxptui.message('lblSglOverrideRunName');
                case fxptui.message('lblFxptOverrideRunNameUntranslated')
                    rName = fxptui.message('lblFxptOverrideRunName');
                case fxptui.message('lblMMOOffRunNameUntranslated')
                    rName = fxptui.message('lblMMOOffRunName');
                otherwise
                    rName = shortcutInfo{5};
            end
            mdlSettingMap.insert('RunName',rName);
        end
        
        if ~(length(shortcutInfo) > 5); continue; end
        % Now add the individual subsystem settings.
        % For older models that don't have path information stored, index
        % through the array differently.
        if iscell(shortcutInfo{7})
            incrLoopIndex = 5;
        else
            incrLoopIndex = 4;
        end
        
        for m = 6:incrLoopIndex:length(shortcutInfo)
            arrayIncr = 1;
            try
                curBlkSID = shortcutInfo{m};
                if isempty(curBlkSID)
                    % Check if the next field is empty - this might have
                    % the information from the root level that can identify
                    % this model/referenced model.
                    % root-level settings
                    if incrLoopIndex == 5
                        topModelPath = shortcutInfo{m+arrayIncr};
                        if isempty(topModelPath)
                            blkSID = Simulink.ID.getSID(bd);
                        else
                            blkSID = this.createSIDFromPathTrace(topModelPath);
                        end
                        arrayIncr = arrayIncr+1;
                    else
                        blkSID = Simulink.ID.getSID(bd);
                    end
                elseif isempty(strfind(curBlkSID, ':'))
                    % this string is not a id surfix
                    blkSID = curBlkSID;
                else
                    if incrLoopIndex == 5
                        topModelPath = shortcutInfo{m+arrayIncr};
                        if isempty(topModelPath)
                            blkSID = [bd.getFullName curBlkSID];
                        else
                            mdlName = this.createSIDFromPathTrace(topModelPath);
                            blkSID = [mdlName curBlkSID];
                        end
                        arrayIncr = arrayIncr+1;
                    else
                        blkSID = [bd.getFullName curBlkSID];
                    end
                end
                blkObj = get(Simulink.ID.getHandle(blkSID),'Object');
                if isa(blkObj,'Simulink.ModelReference')
                    modelName = blkObj.ModelName;
                    if ~isempty(refMdls)
                        if sum(ismember(refMdls, modelName)) == 0
                            continue;
                        end
                    end
                end
                if isa(blkObj,'Simulink.BlockDiagram')
                    if ~isempty(refMdls)
                        if sum(ismember(refMdls, blkObj.getFullName)) == 0
                            continue;
                        end
                    end
                end
            catch e %#ok
                % If the block object cannot be retreived from the block
                % SID, then something has changed in the model and the
                % settings cannot be mapped back. Continue without saving
                % the shortcut.
                continue;
            end
            blkSettingMap = this.getSystemSettingMapForShortcut(blkSID,shortcutName);
            blkSettingMap.insert('DAObject', blkObj);
            blkSettingMap.insert('SID',blkSID);
            if incrLoopIndex == 5
                % The map value is always saved in the setting
                % block,....,resolve starting path order. The string is
                % always saved in the starting path,....,setting block order.
                blkSettingMap.insert('TopModelTracePath',flip(topModelPath));
            end
            
            % Add rest of the settings to the map only if it is non-empty.
            if ~isempty(shortcutInfo{m+arrayIncr})
                switch shortcutInfo{m+arrayIncr}
                    case 'M'
                        val = 'MinMaxAndOverflow';
                    case 'O'
                        val = 'OverflowOnly';
                    case 'F'
                        val = 'ForceOff';
                    otherwise
                        val = 'UseLocalSettings';
                end
                blkSettingMap.insert('MinMaxOverflowLogging',val);
            end
            arrayIncr = arrayIncr+1;
            
            if ~isempty(shortcutInfo{m+arrayIncr})
                switch shortcutInfo{m+arrayIncr}
                    case 'D'
                        val = 'Double';
                    case 'S'
                        val = 'Single';
                    case 'SD'
                        val = 'ScaledDouble';
                    case 'F'
                        val = 'Off';
                    otherwise
                        val = 'UseLocalSettings';
                end
                blkSettingMap.insert('DataTypeOverride',val);
            end
            arrayIncr = arrayIncr+1;
            
            switch shortcutInfo{m+arrayIncr}
                case 'flt'
                    val = 'Floating-point';
                case 'fix'
                    val = 'Fixed-point';
                otherwise
                    val = 'AllNumericTypes';
            end
            blkSettingMap.insert('DataTypeOverrideAppliesTo',val);
        end
    end
catch e %#ok<NASGU>
    % Error while evaluating the expression. Don't do anything.
end
end
