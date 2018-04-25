function nameShadowed = isAppNameShadowedByCWD(fullFileName)
    % Check if the app's name is shadowed by the MATLAB current
    % working directory

    % Copyright 2016 - 2017 The MathWorks, Inc.
    
    % Call CodeTools' mdbfileonpath to check the name shadow status, which
    % will compare path case-sensitively/case-insensitively based on OS, and
    % check file name case-sensitively(with fixing to g1532266)
    [~, shadowStatus] = mdbfileonpath(fullFileName);
    
    nameShadowed = (shadowStatus == com.mathworks.mlwidgets.dialog.PathUpdateDialog.FILE_SHADOWED_BY_PWD);
end