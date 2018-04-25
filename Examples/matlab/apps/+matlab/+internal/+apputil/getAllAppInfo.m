function info = getAllAppInfo(appDir)

% INFO = matlab.internal.apputil.getAllAppInfo returns information about
% all app installed.  INFO is a struct with the following fields.
%
%   id       - The id of the app.
%   name     - The name of the app as displayed in the app gallery.
%   status   - Always 'installed'.  Calling functions should modify this if
%              necessary.
%   location - The install location.
%   GUID     - The apps GUID.
 
% Copyright 2012 - 2015 The MathWorks, Inc.

info = [];
apps = dir(appDir);

for app = apps'
    if strcmp(app.name, '.') || strcmp(app.name, '..')
        continue;
    end
    
    dirname = fullfile(appDir, app.name);
    addonmetadatadir = fullfile(dirname, '.addOnMetadata');
    
    appfile = dir(fullfile(addonmetadatadir, ['*' matlab.internal.apputil.AppUtil.FileExtension]));
    if isempty(appfile)
        continue;
    end
    
    appfile = fullfile(addonmetadatadir, appfile.name);
    try
        appinfo = appinstall.internal.getappmetadata(appfile);
    catch %#ok<CTCH>
        continue
    end
    
    info(end+1).id = matlab.internal.apputil.AppUtil.makeAppID(app.name); %#ok<AGROW>
    info(end).name = appinfo.name;
    info(end).status = 'installed';
    info(end).location = dirname;
    info(end).GUID = appinfo.GUID;
end
end
