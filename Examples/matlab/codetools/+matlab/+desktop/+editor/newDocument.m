function obj = newDocument(text)
%matlab.desktop.editor.newDocument Create Document in Editor.
%   EDITOROBJ = matlab.desktop.editor.newDocument returns a Document object
%   associated with a new, empty MATLAB Editor buffer.
%
%   EDITOROBJ = matlab.desktop.editor.newDocument(TEXT) opens a new buffer
%   that contains the specified TEXT.
%
%   Example: Create a document in the Editor.
%
%      newDoc = matlab.desktop.editor.newDocument('% My test document');
%
%   See also matlab.desktop.editor.Document/appendText,
%   matlab.desktop.editor.Document, matlab.desktop.editor.findOpenDocument,
%   matlab.desktop.editor.openDocument,
%   matlab.desktop.editor.Document/insertTextAtPositionInLine.

%   Copyright 2008-2011 The MathWorks, Inc.

assertEditorAvailable;

if nargin < 1
    text = '';
end
matlab.desktop.editor.EditorUtils.assertChar(text, 'TEXT');
obj = matlab.desktop.editor.Document.new(text);

end


