function out = install(mlappfile, appinstalldir)
%   This method will allow you to install a MATLAB app.
%   Usage: install(mlappfile, appinstalldir)
%
%   Copyright 2012 The MathWorks, Inc.
%
    if(~exist(mlappfile,'file'))   
        error(message('MATLAB:apps:install:AppFileNotFound', mlappfile));
    end
    if(~exist(appinstalldir, 'dir'))    
        [status, msg, messageid] = mkdir(appinstalldir);        
        if(~status)
            unabletocreateinstalldir = MException(messageid, msg);
            throw(unabletocreateinstalldir);
        end
    end
    
    % After error check is complete invoke the method to install and copy the MLAPP
    % file to the specified directory.
    out = extractandcopy(mlappfile, appinstalldir);                                      
end

function appinfo = extractandcopy(mlappfile, appinstalldir)
    appmetadata = appinstall.internal.appinstaller(mlappfile);
    %Clear the wrapper class from MATLAB memory
    clear(appmetadata.EntryPoint, [appmetadata.EntryPoint 'App']);
    [~,allfiles,~] =  cellfun(@(x) fileparts(x), appmetadata.AppInfo.appEntries, 'UniformOutput', false);
    if(iscell(allfiles))
        cellfun(@(x) isbuiltin(x), allfiles);
    end
    
    %extract the package to appinstalldir/code
    codedirunderappinstallroot = fullfile(appinstalldir, 'code');
    appmetadata.extractAppPackage(mlappfile, codedirunderappinstallroot);
    appinfo = appmetadata.AppInfo;    
    appinfo =  appinstall.internal.appinstaller.extractImageContents(mlappfile, appinfo);
    copymlappfiletoappmetadata(mlappfile, appinstalldir);
end

function copymlappfiletoappmetadata(mlappfile, appinstalldir)
    addonmetadatadir = fullfile(appinstalldir, '.addOnMetadata');
    mkdir(addonmetadatadir);
    if (ispc)
        fileattrib(addonmetadatadir, '+h')
    end
    copyfile(mlappfile, addonmetadatadir); 
end
function isbuiltin(filename)
    if(exist(filename,'builtin') ~= 5)
        clear filename;
    end
end