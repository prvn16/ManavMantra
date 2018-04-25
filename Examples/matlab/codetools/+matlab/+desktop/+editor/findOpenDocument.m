function obj = findOpenDocument(filename)
%matlab.desktop.editor.findOpenDocument Create Document object for open document.
%   EDITOROBJ = matlab.desktop.editor.findOpenDocument(FILENAME) returns an
%   Editor Document object for the open file FILENAME. If FILENAME does not
%   include the full path, MATLAB returns the first matching Editor
%   Document it finds.
%
%   If the file is not open, or MATLAB cannot find it, EDITOROBJ is empty.
%   If the input is a cell array of file names and only some of those files
%   are open, MATLAB returns only Editors with open files. Therefore,
%   EDITOROBJ might differ in length from the input cell array.
%
%   Example: Open several files in the Editor. Create an Editor Document
%   object associated with one of them, and then list its properties.
%
%      % Open the files: 
%      edit('fft.m');
%      edit('fftn.m');
%      edit('fftw.m');
%
%      % Find the Editor Document corresponding to fft.m:
%      fftObj = matlab.desktop.editor.findOpenDocument(which('fft.m'))
%
%      % View the Filename property:
%      fftObj.Filename
%
%   See also matlab.desktop.editor.Document,
%   matlab.desktop.editor.openDocument.

%   Copyright 2008-2010 The MathWorks, Inc.

assertEditorAvailable;

assert(nargin > 0, message('MATLAB:Editor:Document:NoFilename'));

if ischar(filename)
    obj = matlab.desktop.editor.Document.findEditor(filename);
elseif iscell(filename)
    obj = matlab.desktop.editor.Document.empty(1,0);
    for i = 1:numel(filename)
        thisEditor = matlab.desktop.editor.findOpenDocument(filename{i});
        if ~isempty(thisEditor)
            %Have to do this check and build in a loop because each input may result in an
            %empty EditorDocument object, which we cannot concatenate to the list and so
            %we don't know for sure what the final size will be.
            obj(end+1) = thisEditor; %#ok<AGROW>
        end
    end
end

end
