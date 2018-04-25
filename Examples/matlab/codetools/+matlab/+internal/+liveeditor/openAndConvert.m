function openAndConvert(sourceFileName, destinationFile, varargin)
% openAndConvert - Opens a source MATLAB Rich Code file and convert file
%
%   openAndSave(sourceFileName, destinationFile) - open the source Live Code file
%   and convert to the destination file
%
%   Example:
%
%       matlab.internal.liveeditor.openAndConvert(liveCodeFileName, htmlFileName);

validateattributes(sourceFileName, {'char'}, {'nonempty'}, mfilename, 'sourceFileName', 1)

validateattributes(destinationFile, {'char'}, {'nonempty'}, mfilename, 'destinationFile', 2)

import matlab.internal.liveeditor.LiveEditorUtilities

% Opens the file in a headless mode
[javaRichDocument, cleanupObj] = LiveEditorUtilities.open(sourceFileName); %#ok<ASGLU>

% Saves the contents into the file
LiveEditorUtilities.saveas(javaRichDocument, destinationFile, varargin{:})
end

