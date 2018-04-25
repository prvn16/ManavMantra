function objs = getAll
%matlab.desktop.editor.getAll Find all open Editor Documents.
%   EDITOROBJS = matlab.desktop.editor.getAll returns an array of Document
%   objects corresponding to all open documents in the MATLAB Editor.
%
%   Example: List the file names of all open documents.
%
%      allDocs = matlab.desktop.editor.getAll;
%      allDocs.Filename
%
%   See also matlab.desktop.editor.Document, matlab.desktop.editor.findOpenDocument,
%   matlab.desktop.editor.getActive, matlab.desktop.editor.openDocument.

%   Copyright 2008-2010 The MathWorks, Inc.

assertEditorAvailable;

objs = matlab.desktop.editor.Document.getAllOpenEditors;

% Attempt to verify that the Editor is "settled" (for closing Editors, not
% newly opening ones).
pause(1)
drawnow
reget = false;
if ~isempty(objs)
    for i = 1:length(objs)
        if ~objs(i).Opened
            reget = true;
        end
    end
end

if reget
    objs = matlab.desktop.editor.Document.getAllOpenEditors;
end

end