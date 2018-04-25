function opentoline(fileName, lineNumber, columnNumber)
%OPENTOLINE Open to specified line in function file in Editor
%   This function is unsupported and might change or be removed without
%   notice in a future version.
%
%   OPENTOLINE(FILENAME, LINENUMBER, COLUMN)
%   LINENUMBER the line to scroll to in the Editor. The absolute value of
%   this argument will be used.
%   COLUMN argument is optional.  If it is not present, the whole line 
%   will be selected.
%
%   See also matlab.desktop.editor.openAndGoToLine, matlab.desktop.editor.openAndGoToFunction.

%   Copyright 1984-2014 The MathWorks, Inc.

lineNumber = abs(lineNumber); % dbstack uses negative numbers for "after"

selectLine = (nargin == 2);

if selectLine
    columnNumber = 1;
end
    
%% First check if there is for an editor that is open (supports unsaved
%buffers)
foundEditor = matlab.codetools.internal.gotoLineOfOpenEditor(fileName, lineNumber, columnNumber, selectLine);
if ~isempty(foundEditor)
    return;
end

%% Otherwise, try and open a new editor for this file

javaFile = java.io.File(fileName);
% complete the path if it is not absolute
if ~javaFile.isAbsolute
    %resolve the filename if a partial path is provided.
    fileName = fullfile(pwd, fileName);
end

javaFile = java.io.File(fileName);
if ~javaFile.exists()
    return;
end

%% Determine if there are any file type specific handlers
openAction = matlab.codetools.internal.getActionForFileType(fileName, 'opentoline');

if ~isempty(openAction)
    feval(openAction, fileName, lineNumber, columnNumber, selectLine);
    return
end
    
%% No specific handlers found - open the editor

%go to a line and a column, if fileName exists
editorObj = matlab.desktop.editor.openDocument(fileName);
if (~isempty(editorObj))
    editorObj.goToPositionInLine(lineNumber, columnNumber);
    if selectLine
        editorObj.Selection = [lineNumber 1 lineNumber Inf];
    end
end
end  