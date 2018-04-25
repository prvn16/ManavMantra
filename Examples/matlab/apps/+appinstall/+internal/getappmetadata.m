function appmetadata = getappmetadata(appfilename)
%   This method returns the MATLAB App metadata stored in the appProperties
%   file.
%   Usage: getappmetadata(appfilename)
%
%   Copyright 2012 The MathWorks, Inc.
%
 try
    appinfo = mlappinfo(appfilename);
    
    appinfo =  appinstall.internal.appinstaller.extractImageContents(appfilename, appinfo);
    
    entryFields = {'pathEntries', 'appEntries'};
    for field = entryFields
        if isfield(appinfo, field{:})
            appinfo.(field{:}) = appcreate.internal.appbuilder.denormalizeFileSep(appinfo.(field{:}));
        end
    end
    
    appmetadata = appinfo;

 catch err
     exception = MException(err.identifier, err.message); 
     throw(exception);
 end