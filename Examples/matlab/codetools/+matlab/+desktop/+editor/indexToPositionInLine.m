function [line, position] = indexToPositionInLine(editorobj, index)
%matlab.desktop.editor.indexToPositionInLine Convert text array index to position within line.
%   [LINE, POSITION] = matlab.desktop.editor.indexToPositionInLine(EDITOROBJ, INDEX)
%   returns the LINE and POSITION within that line corresponding to the
%   INDEX in the Document text array. All values are 1-based. Tab
%   characters are treated as a single character position. Therefore, a
%   position within a line might differ from the column number displayed in
%   the MATLAB Editor status bar.
%
%   Note: If INDEX is out of range for the Document text array, then MATLAB
%   returns the nearest in-range LINE and POSITION. For instance, if the
%   length of the text array is 50, but INDEX is 60, then MATLAB returns
%   the LINE and POSITION of the 50th text array element.
%
%   Example: Create a new Document containing strings of text, and then
%   find the line and position corresponding to text index 25 within that
%   Document.
%
%      text = matlab.desktop.editor.linesToText({'function myFunc(args)', ...
%             '% MYFUNC helper function'});
%      editorObj = matlab.desktop.editor.newDocument(text);
%      % Get the line and position corresponding to text index 25.
%      [line, position] = matlab.desktop.editor.indexToPositionInLine(editorObj, 25)
%
%   See also matlab.desktop.editor.positionInLineToIndex,
%   matlab.desktop.editor.linesToText, matlab.desktop.editor.textToLines.

%   Copyright 2010-2013 The MathWorks, Inc.

matlab.desktop.editor.EditorUtils.assertOpen(editorobj, 'EDITOROBJ');
index = convertInf(index-1, 'INDEX');
returnArray = editorobj.JavaEditor.positionToLineAndColumn(index);
line = double(returnArray(1));
position = double(returnArray(2));
end
