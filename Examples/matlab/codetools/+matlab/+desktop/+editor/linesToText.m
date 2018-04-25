function text = linesToText(lines)
%matlab.desktop.editor.linesToText Convert cell array of text lines to single character array.
%   TEXT = matlab.desktop.editor.linesToText(LINES) converts the given
%   single-column cell array of text lines into a character array, with the
%   individual lines separated by newline characters.
%
%   Example: Specify a single-column cell array of text, and then convert
%   it to a character array.
%
%      lines = {'line 1'; 'line 2'};
%      text = matlab.desktop.editor.linesToText(lines)
%
%   See also matlab.desktop.editor.textToLines,
%   matlab.desktop.editor.indexToPositionInLine,
%   matlab.desktop.editor.positionInLineToIndex.

%   Copyright 2010-2011 The MathWorks, Inc.

if isempty(lines)
    text = [];
else
    assert (iscell(lines), message('MATLAB:Editor:Document:NonCellInput'));
    % Algorithm expects a row cell array, so transpose if necessary.
    if iscolumn(lines)
        lines = lines';
    end
    newlineCellArray = repmat({10}, size(lines));
    cellArrayWithNewlines = [lines; newlineCellArray];
    % convert to a char array and leave off the trailing newline
    text = [cellArrayWithNewlines{1:end-1}];
end
