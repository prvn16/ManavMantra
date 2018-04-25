function activeEditorFilename = getActiveFilename
%matlab.desktop.editor.getActiveFilename Find file name of active Document.
%   FILENAME = matlab.desktop.editor.getActiveFilename returns the full
%   path of the file associated with the active Document in the MATLAB
%   Editor. For unsaved documents, FILENAME is 'Untitled' or 'UntitledN',
%   where N is an integer. If no documents are open, FILENAME is an empty
%   string.
%
%   Example: Change the current folder to the one containing the active
%   document in the Editor.
%
%      currentFile = matlab.desktop.editor.getActiveFilename;
%      if ~isempty(currentFile)
%          desiredDir = fileparts(currentFile);
%          cd(desiredDir);
%      end
%
%   See also matlab.desktop.editor.Document, matlab.desktop.editor.Document.Filename,
%   matlab.desktop.editor.findOpenDocument, matlab.desktop.editor.getActive.

%   Copyright 2009-2010 The MathWorks, Inc.

activeEditor = matlab.desktop.editor.getActive;
if isempty(activeEditor)
    activeEditorFilename = '';
else
    activeEditorFilename = activeEditor.Filename;
end

end

