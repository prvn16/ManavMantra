function helpCommand = documentationAvailable(docCommandFromFile, i)
% Used on each row of check table to create documentation commands.
% The documentation commands use an anchor id of the form CA_Identifier,
% where Identifier is the Code Analyzer message tag.
% If the documentation map or the corresponding anchor id does not exist
% the documentation command will not be created.
% The documentation command example is
% helpview('matlab', 'CA_Identifier')

%   Copyright 2017 The MathWorks, Inc.

    persistent previousComponent cshMap
    % Now, we only have one map per component,
    % therefore we only need to check for the component.
    helpCommand = [];
    component = docCommandFromFile.Component{i};
    if ~strcmp(previousComponent, component)
        cshMap = com.mathworks.mlwidgets.help.CSHelpTopicMap(component, docCommandFromFile.Map{i});
        previousComponent = component;
    end
    if cshMap.exists && ~isempty(cshMap.mapID(['CA_' docCommandFromFile.Id{i}]))
        helpCommand = [ 'helpview(''', component, ''',''CA_', docCommandFromFile.Id{i}, ''')' ];
    end
end
