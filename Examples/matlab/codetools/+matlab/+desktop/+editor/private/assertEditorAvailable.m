function assertEditorAvailable
%assertEditorAvailable Assert that sufficient Java support exists for the MATLAB Editor.

% Copyright 2010 The MathWorks, Inc.
try
    assert(matlab.desktop.editor.isEditorAvailable, ...
        message('MATLAB:Editor:Document:NotAvailable'));
catch ex
    throwAsCaller(ex);
end

end