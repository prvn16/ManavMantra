function docColumn = documentationColumn(caChecks)
%documentationColumn gets a column of documentation commands used by the Code Compatibility Report.

%   Copyright 2017 The MathWorks, Inc.

    docColumn = arrayfun(@documentationCommand, caChecks);
end

function docCommand = documentationCommand(id)
% Use Identifier of check table to create documentation commands.
    persistent docCommandMap
    if isempty(docCommandMap)
        [filePath, ~, ~] = fileparts(mfilename('fullpath'));
        fileName = fullfile(filePath, 'documentationCommandTable.csv');
        docCommandFromFile = readtable(fileName,'Delimiter',',');
        docCommandMap = containers.Map;
        for i = 1:height(docCommandFromFile)
            helpCommand = matlab.internal.codecompatibilityreport.documentationAvailable(docCommandFromFile, i);
            if ~isempty(helpCommand)
                docCommandMap(docCommandFromFile.Id{i}) = helpCommand;
            end
        end
    end
    if isKey(docCommandMap, {char(id)})
        docCommand = string(values(docCommandMap, {char(id)}));
    else
        docCommand = string("");
    end
end
