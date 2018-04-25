function mlxfile(fileName, linenumber, column, ~) 
% This function is internal and may change in future releases.

% Plug-in for the opentoline function for MATLAB mlx files.

% Copyright 2014, The MathWorks, Inc.

    ea = com.mathworks.mde.liveeditor.LiveEditorApplication.getInstance();
    javaFile = java.io.File(fileName);
    client = ea.openLiveEditorClient(javaFile);
    client.getRichTextComponent().goToLine(linenumber, column);
end 