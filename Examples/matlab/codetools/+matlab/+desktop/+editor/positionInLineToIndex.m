function index = positionInLineToIndex(editorobj, line, position)
%matlab.desktop.editor.positionInLineToIndex Convert position within line to text array index.
%   INDEX = matlab.desktop.editor.indexToPositionInLine(EDITOROBJ, LINE,
%   POSITION) returns the INDEX into the Document text array that
%   corresponds to the given LINE and POSITION (including newline
%   characters). All values are 1-based. Tab characters are treated as a
%   single character position. Therefore, a position within a line may
%   differ from its column number as displayed in the MATLAB Editor status
%   bar.
%
%   Note: If either LINE or POSITION is out of range for the Document text
%   array, then MATLAB returns the nearest in-range INDEX value. MATLAB
%   first adjusts for an out-of-range LINE, and then for an out-of-range
%   POSITION. For instance, if the last line and position of the text array
%   are 50 and 10 (respectively), and you specify line 60 and position 5,
%   then MATLAB returns the INDEX value for line 50 and position 5. For the
%   same text array, if you specify line 50 and position 20, then MATLAB
%   returns the INDEX value for line 50 and position 10.
%
%   Example: Create a Document containing lines of text, and then get the
%   text index corresponding to the beginning of the H1 line.
%
%      text = matlab.desktop.editor.linesToText({'function myFunc(args)', ...
%             '% MYFUNC helper function'});
%      editorObj = matlab.desktop.editor.newDocument(text);
% 
%      % Get the text index corresponding to the beginning of the H1 line:
%      index = matlab.desktop.editor.positionInLineToIndex(editorObj, 2, 3)
%
%   See also matlab.desktop.editor.indexToPositionInLine,
%   matlab.desktop.editor.linesToText, matlab.desktop.editor.textToLines.

%   Copyright 2010-2011 The MathWorks, Inc.

matlab.desktop.editor.EditorUtils.assertOpen(editorobj, 'EDITOROBJ');
line = convertInf(line, 'LINE');
position_in_line = convertInf(position, 'POSITION');
index = editorobj.JavaEditor.lineAndColumnToPosition(line, position_in_line) + 1;
end
