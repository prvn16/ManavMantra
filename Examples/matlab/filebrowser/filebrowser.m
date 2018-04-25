function filebrowser
%FILEBROWSER Open Current Folder browser, or select it if already open
%   FILEBROWSER Opens the Current Folder browser or brings the Current
%   Folder browser to the front if it is already open.

%   Copyright 1984-2017 The MathWorks, Inc.

err = javachk('mwt', 'The Current Folder Browser');
if ~isempty(err)
    error(err);
end

try
    % Launch the Current Folder Browser
    desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
    adapter = javaObject('com.mathworks.mde.desk.DesktopExplorerAdapterImpl', desktop);
    %javaMethod('createInstance', 'com.mathworks.mde.explorer.Explorer', adapter);
    
    classLoader = java.lang.ClassLoader.getSystemClassLoader();
    explorerClass = java.lang.Class.forName('com.mathworks.mde.explorer.Explorer', 1, classLoader);
    adapterClass = java.lang.Class.forName('com.mathworks.explorer.DesktopExplorerAdapter', 1, classLoader);
    
    paramtypes = javaArray('java.lang.Class', 1);
    paramtypes(1) = adapterClass;
    
    method = explorerClass.getMethod(java.lang.String('createInstance'), paramtypes);
    arglist = javaArray('java.lang.Object', 1);
    arglist(1) = adapter;
    
    com.mathworks.mwswing.MJUtilities.invokeLater(explorerClass, method, arglist);
    
    com.mathworks.mde.explorer.Explorer.invoke;    
catch
    % Failed. Bail
    error(message('MATLAB:filebrowser:filebrowserFailed'));
end
