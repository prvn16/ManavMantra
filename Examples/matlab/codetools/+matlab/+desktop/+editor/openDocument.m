function obj = openDocument(filename)
%matlab.desktop.editor.openDocument Open file in Editor.
%   EDITOROBJ = matlab.desktop.editor.openDocument(FILENAME) opens the
%   specified file in the MATLAB Editor and creates an associated Document
%   object. FILENAME must include the full path, otherwise MATLAB throws a
%   MATLAB:Editor:Document:PartialPath exception. If the file is already
%   open, the openDocument function makes it the active document.
%
%   If FILENAME does not exist, MATLAB returns an empty Document array. If
%   a cell array of filenames is specified, but only some of them exist,
%   EDITOROBJ differs in length from the input cell array. MATLAB returns
%   Editor Documents with existing files only. This function does not
%   display a dialog box.
%
%   Example: Open fft.m, and then view the Filename property of the
%   associated Editor Document object.
%
%      fftDoc = matlab.desktop.editor.openDocument(which('fft.m'));
%      fftDoc.Filename
%
%   See also edit, matlab.desktop.editor.Document,
%   matlab.desktop.editor.findOpenDocument, matlab.desktop.editor.isOpen,
%   matlab.desktop.editor.openAndGoToFunction,
%   matlab.desktop.editor.openAndGoToLine,
%   matlab.desktop.editor.Document/makeActive.

%   Copyright 2008-2010 The MathWorks, Inc.

assertEditorAvailable;

assert(nargin > 0, message('MATLAB:Editor:Document:NoFilename'));
if ischar(filename)
    obj = matlab.desktop.editor.Document.openEditorForExistingFile(filename);
elseif iscell(filename)
    obj = matlab.desktop.editor.Document.empty(1,0);
    for i = 1:numel(filename)
        thisEditor = matlab.desktop.editor.openDocument(filename{i});
        %Have to do this check and build in a loop because each input may result in an
        %empty EditorDocument object, which we cannot concatenate to the list.
        if (~isempty(thisEditor))
            obj(end+1) = thisEditor; %#ok<AGROW>
        end
    end
end

end
