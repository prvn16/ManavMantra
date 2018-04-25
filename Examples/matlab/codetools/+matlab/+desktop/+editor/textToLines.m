function lines = textToLines(text)
%matlab.desktop.editor.textToLines Convert character array into cell array of text lines.
%   LINES = matlab.desktop.editor.textToLines(TEXT) converts the given
%   character array into a single-column cell array of individual lines by
%   splitting at all newline characters. The resulting cell array does not
%   include newline characters.
%
%   Example: Specify a character array, and then convert it into a
%   single-column cell array of text lines.
%
%      text = ['line 1' 10 'line 2']; % 10 is the ascii code for newline
%      lines = matlab.desktop.editor.textToLines(text)
%
%   See also matlab.desktop.editor.linesToText,
%   matlab.desktop.editor.indexToPositionInLine,
%   matlab.desktop.editor.positionInLineToIndex.

%   Copyright 2010-2011 The MathWorks, Inc.

if isempty(text)
    if ischar(text)
        lines = {''};
    else
        lines = {};
    end
else
    matlab.desktop.editor.EditorUtils.assertChar(text, 'TEXT');
    % Return as a column cell array.
    lines = regexp(text, '\n', 'split')';
end
