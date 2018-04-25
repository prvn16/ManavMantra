classdef FileExtensionLiaison < handle    
    % This class is undocumented and will change in a future release.
    
    % FileExtensionLiaison - Class to handle communication between FileExtensionServices.
    %
    % See Also: FileExtensionService, Service, ServiceLocator, ServiceFactory
    
    % Copyright 2016 The MathWorks, Inc.    
    
    properties (SetAccess = immutable)
        TestFile;
        ContainingFolder;
        ShortFilename;
        Extension;
    end
    
    methods
        function liaison = FileExtensionLiaison(testFile)
            import matlab.unittest.internal.fileResolver;            
            
            liaison.TestFile = testFile;            
            [liaison.ContainingFolder, ...
                liaison.ShortFilename, ...
                liaison.Extension] = fileparts(fileResolver(testFile));            
        end
        
    end
   
end

