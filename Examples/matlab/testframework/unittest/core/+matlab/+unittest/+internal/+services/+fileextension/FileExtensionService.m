classdef FileExtensionService < matlab.unittest.internal.services.Service
    % This class is undocumented and will change in a future release.
    
    % FileExtensionService - Interface for file extension services.
    %
    % See Also: FileExtensionLiaison, Service, ServiceLocator, ServiceFactory
    
    % Copyright 2016 The MathWorks, Inc.
    
    properties (Abstract, Constant)
        Extension string;
    end
    
    methods (Sealed)
        function fulfill(services, liaison)
            % fulfill - Fulfill an array of file extension services
            %
            %   fulfill(SERVICES) validates if the given test file has a
            %   supported file extension and resolves precedence.
            %
            %   The folder containing the test file is assumed to be on
            %   path at fullfill time.
            
            import matlab.unittest.internal.whichFile
            
            if ~services.supportsExtension(liaison.Extension)            
                error(message('MATLAB:unittest:TestSuite:UnsupportedFile', liaison.TestFile));
            end
            
            file = whichFile(liaison.ShortFilename);
            [~, ~, resolvedExtension] = fileparts(file);                        
            
            % When which() doesn't recognize the file, there is no conflict
            % in terms of precedence.
            if isempty(resolvedExtension)
                return
            end
            
            if ~strcmp(liaison.Extension, resolvedExtension)
                error(message('MATLAB:unittest:TestSuite:ShadowedFile', liaison.TestFile, resolvedExtension));
            end
            
        end
        
        function bool = supportsExtension(services, extension)
            bool = any(strcmp(extension, [services.Extension]));
        end
    end
end

