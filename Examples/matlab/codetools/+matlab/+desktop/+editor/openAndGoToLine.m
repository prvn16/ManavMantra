function editorObj = openAndGoToLine(filename, linenum)
%matlab.desktop.editor.openAndGoToLine Open file and highlight specified line.
%   EDITOROBJ = matlab.desktop.editor.openAndGoToLine(FILENAME, LINENUM)
%   opens FILENAME in the MATLAB Editor, highlights LINENUM, and creates a
%   Document object. FILENAME must include the full path, otherwise a
%   MATLAB:Editor:Document:PartialPath exception is thrown. If LINENUM is
%   past the end of the document, openAndGoToLine places the cursor at the
%   last line. If the file is already open, openAndGoToLine makes the
%   document active and selects LINENUM.
%
%   If FILENAME does not exist, MATLAB returns an empty Document array.
%   This function supports scalar arguments only, and does not display
%   any dialog boxes.
%
%   Example: Open Contents.m and highlight line 50.
%
%      contents = matlab.desktop.editor.openAndGoToLine( ...
%                    which('Contents.m'), 50);
%
%   See also matlab.desktop.editor.openDocument,
%   matlab.desktop.editor.openAndGoToFunction,
%   matlab.desktop.editor.Document/goToLine.

%   Copyright 2009-2015 The MathWorks, Inc.

matlab.desktop.editor.EditorUtils.assertChar(filename, 'FILENAME');
matlab.desktop.editor.EditorUtils.assertNumericScalar(linenum, 'LINENUM');
matlab.desktop.editor.EditorUtils.assertLessEqualInt32Max(linenum, 'LINENUM');

editorObj = matlab.desktop.editor.openDocument(filename);
if (~isempty(editorObj))
    editorObj.goToLine(linenum);
end
end