function mlxfile(file, localfunction) %#ok<INUSD>
% This function is internal and may change in future releases.

% Plug-in for the EDIT function for opening MATLAB MLX files. Note that
% this function, as with EDIT, has a requirment of using Java.

% Copyright 2014-2016, The MathWorks, Inc.

% If swing is not available, then throw an error
if ~usejava('swing')
    error(message('MATLAB:Editor:NotSupported'))
end

import com.mathworks.mde.editor.EditorUtils;

EditorUtils.openFileInAppropriateEditor(java.io.File(file));

end

