function [status, description] = mlappinstallfinfo(filename)
    appinfo = appinstall.internal.getappmetadata(filename);
    description = appinfo.description;
    status = 'NotFound';
end