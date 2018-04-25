function displayScalarObject(obj)
% DISPLAYSCALAROBJECT    Display a scalar SettingsGroup object

%   Copyright 2015-2018 The MathWorks, Inc.

    allSubgroupsSettingsList = properties(obj);
    groupNames               = {};
    settingNames             = {};
    % Properties under this settings group include direct child settings and
    % settings groups that are 'visible'
    % Create separate cell-arrays including settings and settings groups name
    % lists in format {'SettingName1' , 'SettingName2', 'SettingName3'}
    if (~isempty(allSubgroupsSettingsList))
        for i = 1:numel(allSubgroupsSettingsList)
            currentChildProp = obj.(allSubgroupsSettingsList{i});
            if strcmpi(class(currentChildProp), 'matlab.settings.SettingsGroup')
                groupNames = [groupNames, {allSubgroupsSettingsList(i)}]; %#ok<AGROW>
            elseif strcmpi(class(currentChildProp), 'matlab.settings.Setting')
                settingNames = [settingNames, {allSubgroupsSettingsList(i)}]; %#ok<AGROW>
            end
        end
    end

    hasGroupToDisplay       = ~isempty(groupNames);
    hasSettingToDisplay     = ~isempty(settingNames);

    % Store string representing full path of settings group from root
    % getGroupFullName always returns full path with 'root.' prefix
    groupFullName = obj.SettingsGroupFullName;

    % 'root' is not displayed in display header for settings groups
    if (length(groupFullName) > 4) && strcmp(groupFullName(1:5), 'root.')
        groupFullName(1:5) = [];
    end

    sp = matlab.internal.display.formatSpacing;

    if strcmp(sp,'loose')
        cr = newline;
    else
        cr = '';
    end

    settingsGroupHeader = matlab.mixin.CustomDisplay.getClassNameForHeader(obj);

    if ~hasGroupToDisplay && ~hasSettingToDisplay
        % display header for a settings group that does not contain any subgroups and/or settings
        if isempty(groupFullName)
            m = message('MATLAB:ObjectText:DISPLAY_SCALAR_WITH_NO_PROPS', settingsGroupHeader);
            fprintf('%s%c%c', getString(m), cr, newline);
        else
            m = message('MATLAB:ObjectText:DISPLAY_SCALAR_WITH_NO_PROPS', [settingsGroupHeader, ' ','''' groupFullName '''']);
            fprintf('%s%c%c', getString(m), cr, newline);
        end
    else
        % display header for a settings group that contains subgroups and/or settings
        if isempty(groupFullName)
            % Display for root of the main settings tree - Do not
            % display full path for root of the main settings tree
            m = message('MATLAB:ObjectText:DISPLAY_AND_DETAILS_SCALAR_WITH_PROPS', settingsGroupHeader);
            fprintf('%s%c%c', getString(m), cr, newline);
        else
            % Display header with full path for settings groups
            m = message('MATLAB:ObjectText:DISPLAY_AND_DETAILS_SCALAR_WITH_PROPS', [settingsGroupHeader, ' ','''' groupFullName '''']);
            fprintf('%s%c%c', getString(m), cr, newline);
        end

        % Obtain a list of all settings and settings groups to display
        % with all settings sub-list followed by settings groups sub-list
        allSettingsAndGroupsList = [];
        if hasSettingToDisplay
            allSettingsAndGroupsList = [settingNames{:}];
        end
        if hasGroupToDisplay
            allSettingsAndGroupsList = [allSettingsAndGroupsList, [groupNames{:}]];
        end

        % Display represents string values representing class name and dimensions
        % ['1x1 Setting'] or ['1x1 SettingsGroup']
        ClassTypeAndDimensionValues = {};
        % Assign depending on number of settings and settings groups
        if hasSettingToDisplay
            ClassTypeAndDimensionValues =  repmat([{['[1' char(215) '1 Setting]']}] , 1 , numel(settingNames)); %#ok<NBRAK>
        end
        if hasGroupToDisplay
            ClassTypeAndDimensionValues = [ClassTypeAndDimensionValues, repmat([{['[1' char(215) '1 SettingsGroup]']}],1,numel(groupNames))]; %#ok<NBRAK>
        end

        % Create a struct with settings/group names and classinfo
        propValues = cell2struct(ClassTypeAndDimensionValues,allSettingsAndGroupsList,2); %#ok<NASGU>
        strToDisplay = regexprep(evalc('disp(propValues)'), '''' , '');
        fprintf(strToDisplay);
    end
end
