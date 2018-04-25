function out = uninstall(mlappfile, appinstallationcodedir)
%   This method will allow to uninstall a MATLAB App. 
%   Usage: uninstall(mlappfile, appinstallationcodedir)
%
%   Copyright 2012 - 2015 The MathWorks, Inc.
%
%     mlappfileloc = [appinstallationcodedir filesep mlappfile];      
    if(~exist(appinstallationcodedir, 'dir'))
        error(message('MATLAB:apps:uninstall:DirectoryNotFound', appinstallationcodedir));
    end
    if(~exist(mlappfile,'file'))            
        error(message('MATLAB:apps:uninstall:MLAPPFileNotFound',mlappfile));
    end
    [~, allmexinmem] = inmem('-completenames');
    tbxmexfiles = strfind(allmexinmem, [matlabroot filesep 'toolbox']);
    tbfiles = cellfun(@(x)isempty(x),tbxmexfiles);
    usermexfile = allmexinmem(tbfiles);        
    [~, mexfilenames, ~] = cellfun(@(x) fileparts(x), usermexfile, 'UniformOutput',false);
    if(numel(mexfilenames))
        clear mex;
    end                            
    appmetadata = appinstall.internal.getappmetadata(mlappfile);
    entryPointPath = cellfun(@(x) strcmp(appmetadata.entryPoint, x), appmetadata.appEntries);
    allpaths = appmetadata.appEntries(~entryPointPath);
    cellfun(@(x) delete([appinstallationcodedir filesep x]), appmetadata.appEntries, 'UniformOutput', false);
    wrapperfile = matlab.internal.apputil.AppUtil.genwrapperfilename(appinstallationcodedir);
    if(exist([appinstallationcodedir filesep wrapperfile 'App.m'], 'file') == 2)
        delete([appinstallationcodedir filesep wrapperfile 'App.m']);
    end
    if (exist([appinstallationcodedir filesep 'metadata'], 'dir') == 7)
        rmdir([appinstallationcodedir filesep 'metadata'], 's');
    end
    if (exist(mlappfile, 'file') == 2)       
        addonmetadatadir = fileparts(mlappfile);
        removedir(addonmetadatadir);
    end
    trulyallpaths = cell(0);
    for i = 1:numel(allpaths)
        trulyallpaths = fileancestors(allpaths{i}, trulyallpaths);
    end
    trulyallpaths = unique(trulyallpaths, 'sorted');
    dirstoremove = trulyallpaths(end:-1:1);
    for i = 1:numel(dirstoremove)        
        if numel(dir([appinstallationcodedir dirstoremove{i}])) > 2
            folders = dir([appinstallationcodedir dirstoremove{i}]);                  
            warning(message('MATLAB:apps:uninstall:UnknownDirFound', folders(numel(dir([appinstallationcodedir dirstoremove{i}]))).name));
        else
            if(exist([appinstallationcodedir dirstoremove{i}], 'dir') == 7)
                rmdir([appinstallationcodedir dirstoremove{i}], 's');
            end
        end
    end       
    if numel(dir(appinstallationcodedir)) > 2
        folders = dir(appinstallationcodedir);       
        warning((message('MATLAB:apps:uninstall:UnknownDirFound',folders(numel(dir(appinstallationcodedir))).name)));
        status = 2;
    else
        if(exist(appinstallationcodedir, 'dir') == 7)
            [status, msg, messageid] = rmdir(appinstallationcodedir, 's');
            removedir(fileparts(fileparts(mlappfile)));
        else
            status = 1;
        end
    end    
    if(status)
        out = status;
    else
        exception = MException(messageid, msg);
        throw(exception);
    end  
    
end
function ancestors = fileancestors( file, ancestors )
% FILEANCESTORS enumerates all directory ancestors for given input file 
% parameter and adds them to the input/output ancestors parameter 
    assert(file(1) == filesep, '<appFile> must start with filesep');
    while 1
        [pathstr, ~, ~] = fileparts(file);
        if pathstr == filesep
            break;
        end
        ancestors = [ancestors pathstr];
        file = pathstr;
    end 
end
 
function removedir(dirtoberemoved)
    if(exist(dirtoberemoved, 'dir'))
        s = beep('off');
        rmdir(dirtoberemoved, 's');
        beep(s);
    end
end
