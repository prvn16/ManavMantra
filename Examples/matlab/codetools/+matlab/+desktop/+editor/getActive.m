function activeEditor = getActive
%matlab.desktop.editor.getActive Find active Editor Document.
%   EDITOROBJ = matlab.desktop.editor.getActive returns a Document object
%   associated with the active document in the MATLAB Editor. The active
%   document is not always associated with a saved file.
%
%   Example: Determine which open document in the Editor is active.
%
%      allDocs = matlab.desktop.editor.getAll;
%      if ~isempty(allDocs)
%          activeDoc = matlab.desktop.editor.getActive
%      end
%
%   See also matlab.desktop.editor.Document,
%   matlab.desktop.editor.findOpenDocument, matlab.desktop.editor.getAll,
%   matlab.desktop.editor.openDocument.

%   Copyright 2009-2010 The MathWorks, Inc.

assertEditorAvailable;

activeEditor = matlab.desktop.editor.Document.getActiveEditor;

end

