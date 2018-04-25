% This function executes the app
% Usage: runapp(appentrypoint, appinstalldir)
%
%   Copyright 2012-2015 The MathWorks, Inc.
%
function out = runapp(appentrypoint, appinstalldir)
apppath = java.io.File(appinstalldir);
canonicalpathtocodedir = fullfile(char(apppath.getCanonicalPath()), 'code');
allpaths = genpath(canonicalpathtocodedir);
addpath(strrep(allpaths, [canonicalpathtocodedir filesep 'metadata;'], ''));
addonmetadatadir = fullfile(appinstalldir, '.addOnMetadata');
mlappinstallfile = dir([addonmetadatadir filesep '*.mlappinstall']);
switch(size(mlappinstallfile,1))
    case 0
        error(message('MATLAB:apps:runapp:NoMLAPPINSTALLFile', appinstalldir));
    case 1
        appmetadata = appinstall.internal.getappmetadata([addonmetadatadir filesep mlappinstallfile.name]);
        if nargout == 0
            runcorrectversion(appmetadata, appentrypoint, addonmetadatadir);
        else
            out = runcorrectversion(appmetadata, appentrypoint, addonmetadatadir);
        end
    otherwise
        for k = 1:size(mlappinstallfile,1)
            appmetadata = appinstall.internal.getappmetadata([addonmetadatadir filesep mlappinstallfile(k).name]);
            if(strcmp(appmetadata.entryPoint, appentrypoint))
                if nargout == 0
                    runcorrectversion(appmetadata, appentrypoint, addonmetadatadir);
                else
                    out = runcorrectversion(appmetadata, appentrypoint, addonmetadatadir);
                end
                continue;
            end
        end
end
end

function out = runcorrectversion(appmetadata, appentrypoint, appinstalldir)
if(strcmp(appentrypoint, appmetadata.entryPoint) && ...
        ~isempty(strfind(appmetadata.createdByMATLABRelease,'R2012b')) && ...
        findfile(appinstalldir, appentrypoint))
    appobj = runapp12b(appentrypoint, appinstalldir);
else
    appobj = runapp13a(appinstalldir);
end
if(~ishandle(appobj.AppHandle))
    out = appobj.AppHandle;
else
    out = 0;
end
end

function filefound = findfile(appinstalldir, appentrypoint)
filename = which([appentrypoint 'App.m']);
filefound = strcmp(filename, [appinstalldir filesep appentrypoint 'App.m']);

end

function outobj = runapp12b(appentrypoint, appinstalldir)
outobj = execute(fullfile(appinstalldir,[appentrypoint 'App.m']));
end

function outobj = runapp13a(appinstalldir)
wrapperfile = matlab.internal.apputil.AppUtil.genwrapperfilename(appinstalldir);
outobj = execute(fullfile(appinstalldir, [wrapperfile 'App.m']));
end

function out = execute(scriptname)
if ispc
    scriptname=strrep(scriptname,'/','\');
end
[dir,script,~] = fileparts(scriptname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cleaner = onCleanup(@() resetCD());
% startDir = cd;
% dirChanged = false;
% 
% if ~isempty(dir)%There is a directory with SCRIPTNAME; must change folders.
%     dirChanged = true;
%     cd(dir);
% end
% appDir = cd;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

out = evalin('caller', [script ';']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clean-up function is nested to catch the state of the function workspace
% on exit in case of an error.
%     function resetCD()
%         if dirChanged && strcmp(appDir,cd)
%             cd(startDir);
%         end
%     end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end