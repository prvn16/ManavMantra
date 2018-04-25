function editorObj = openAndGoToFunction(filename, functionname)
%matlab.desktop.editor.openAndGoToFunction Open MATLAB file and highlight function.
%   EDITOROBJ = matlab.desktop.editor.openAndGoToFunction(FILENAME,
%   FUNCTION) opens FILENAME in the MATLAB Editor, highlights the first
%   occurrence of FUNCTION, and creates a Document object. FILENAME must
%   include the full path, otherwise MATLAB throws a
%   MATLAB:Editor:Document:PartialPath exception. If FUNCTION does not
%   exist, or if the file does not contain MATLAB code, the Document opens
%   with no selection. If the file is already open, openAndGoToFunction
%   makes the document active and highlights the first occurrence of
%   FUNCTION, if it exists.
%
%   If FILENAME does not exist, MATLAB returns an empty Document array.
%   This function supports scalar arguments only and does not display
%   any dialog boxes.
%
%   Example: Open taxdemo.m, and then highlight the computeTax function.
%
%      taxDoc = matlab.desktop.editor.openAndGoToFunction(...
%                  which('taxdemo.m'), 'computeTax');
%
%   See also matlab.desktop.editor.Document/goToFunction,
%   matlab.desktop.editor.openDocument,
%   matlab.desktop.editor.openAndGoToLine.

%   Copyright 2009-2011 The MathWorks, Inc.

matlab.desktop.editor.EditorUtils.assertChar(filename, 'FILENAME');
matlab.desktop.editor.EditorUtils.assertChar(functionname, 'FUNCTIONNAME');

editorObj = matlab.desktop.editor.openDocument(filename);
if (~isempty(editorObj))
    editorObj.goToFunction(functionname);
end

end