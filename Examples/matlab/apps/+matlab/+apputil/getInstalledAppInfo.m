function info = getInstalledAppInfo
% matlab.apputil.getInstalledAppInfo Return information about installed apps.
%
%   APPINFO = matlab.apputil.getInstalledAppInfo returns a struct, APPINFO,
%   containing information about the currently installed apps.  The struct
%   contains the following fields:
%
%           id - The id of the app.  This id is used to run or uninstall 
%                the app.
%         name - The name of the app.  This is the name that is displayed 
%                in the App Gallery in the MATLAB Desktop.
%      status  - The current status of the app.  The getInstalledAppInfo
%                function will always return the status as 'installed'.  
%                The install function will return the status as 'installed' 
%                if a new app is installed or 'updated' if the app 
%                being installed was previously installed.
%     location - The folder where the app is installed.
%
%   matlab.apputil.getInstalledAppInfo displays the id and name of all
%   installed apps.
%
%   See also: matlab.apputil.install, matlab.apputil.uninstall, matlab.apputil.run.

% Copyright 2012 The MathWorks, Inc.

appview = com.mathworks.appmanagement.AppManagementViewSilent;
appAPI = com.mathworks.appmanagement.AppManagementApiBuilder.getAppManagementApiCustomView(appview);

appDir = char(appAPI.getMyAppsLocation);

tempinfo = matlab.internal.apputil.getAllAppInfo(appDir);

if ~isempty(tempinfo)
    tempinfo = rmfield(tempinfo, 'GUID');
end

if nargout == 1
    info = tempinfo;
elseif isempty(tempinfo)
    m = message('MATLAB:apputil:getInstalledAppInfo:noapps');
        fprintf('\n\t%s\n\n', m.getString());
else
    idlength = max(cellfun(@length, {tempinfo.id}));
    namelength = max(cellfun(@length, {tempinfo.name}));
    
    idspaces = repmat(' ', 1, idlength - 3);
    tabstop = '    ';
    header = message('MATLAB:apputil:getInstalledAppInfo:header', idspaces, tabstop);
    fprintf('%s\n', header.getString());
    dashes = sprintf('%s %s%s\n', repmat('-', 1, idlength), tabstop, repmat('-', 1, namelength));
    fprintf(dashes);
    
    for curInfo = tempinfo
        fprintf('%s%s%s %s\n', curInfo.id, repmat(' ', 1, idlength - length(curInfo.id)), tabstop, curInfo.name);
    end
end

end

