function [javaRichDocument, cleanupObj, executionTime] = openAndExecute(fileName)
% openAndExecute - opens and executes a Live Code file

validateattributes(fileName, {'char'}, {'nonempty'}, mfilename, 'fileName', 1)

import matlab.internal.liveeditor.LiveEditorUtilities

% Opens the file in a headless mode
[javaRichDocument, cleanupObj] = LiveEditorUtilities.open(fileName);

% Executes the file
executionTime = LiveEditorUtilities.execute(javaRichDocument, fileName);
end

