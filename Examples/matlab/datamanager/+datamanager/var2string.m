function selectionString = var2string(selectedData)

% Create an array of strings based on the selectedData array.

%   Copyright 2007-2015 The MathWorks, Inc.

selectionString = '';
% Use a tab separated list to ensure paste-ability to Variable Editor
if ~isempty(selectedData)
    
    if isnumeric(selectedData)
        selectionString = mat2str(selectedData);        
        selectionString(selectionString == ' ') = sprintf('\t');
        selectionString(selectionString == ';') = sprintf('\n');
        % Remove the square brackets
        selectionString(1)='';
        selectionString(end)='';
    else
        selectionString = cellstr(char(selectedData));
        selectionString = strjoin(selectionString,'\t');
    end
end