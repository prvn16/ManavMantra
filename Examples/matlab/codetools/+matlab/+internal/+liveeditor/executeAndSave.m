function executionTime = executeAndSave(fileName)
% executeAndSave - executes and saves the file
%
%   executeAndSave(fileName) - executes the Live Code file and saves the results into
%   the Live Code file 
%
%   Example:
%
%       matlab.internal.liveeditor.executeAndSave(liveCodeFileName);

validateattributes(fileName, {'char'}, {'nonempty'}, mfilename, 'FileName', 1)

import com.mathworks.services.mlx.MlxFileUtils
if ~(MlxFileUtils.isMlxFile(fileName))
    error('matlab:internal:liveeditor:executeAndSave', 'FileName must be a MLX file.');
end

import matlab.internal.liveeditor.LiveEditorUtilities
% Opens and executes the file in a headless mode
[javaRichDocument, cleanupObj, executionTime]= LiveEditorUtilities.openAndExecute(fileName); %#ok<ASGLU>

% Workaround. Need to determine why this is needed by the test suite
pause(0.5)

% Saves the contents into the file
LiveEditorUtilities.save(javaRichDocument, fileName)
end
