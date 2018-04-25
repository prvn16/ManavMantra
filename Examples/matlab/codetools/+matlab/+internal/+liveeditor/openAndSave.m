function openAndSave(sourceFileName, destinationFile)
% openAndSave - Opens a source MATLAB code file and save as MATLAB Live Code file
%
%   openAndSave(sourceFileName, destinationFile) - open the source Live Code file
%   and saves to the destination Live Code file
%
%   Example:
%
%       matlab.internal.liveeditor.openAndSave(sourceFileName, destinationFile);

validateattributes(sourceFileName, {'char'}, {'nonempty'}, mfilename, 'sourceFileName', 1)

validateattributes(destinationFile, {'char'}, {'nonempty'}, mfilename, 'destinationFile', 2)

import matlab.internal.liveeditor.LiveEditorUtilities

% Opens the file in a headless mode
[javaRichDocument, cleanupObj, browserObj] = LiveEditorUtilities.open(sourceFileName); %#ok<ASGLU>

% Saves the contents into the file
LiveEditorUtilities.save(javaRichDocument, destinationFile)
end