classdef(Sealed) FileArtifact < matlab.unittest.diagnostics.Artifact
    % FileArtifact - Artifact associated with a file on disk
    %
    %   The FileArtifact class provides a means for referencing files on
    %   disk and providing a level of convenience for making copies of
    %   the files to a new location.
    %
    %   FileArtifact properties:
    %       Name     - The name of the artifact
    %       Location - The parent folder where the artifact is located
    %       FullPath - The full path of the artifact
    %
    %   FileArtifact methods:
    %       FileArtifact - Class constructor
    %       copyTo - Copy artifacts to a new location
    
    %  Copyright 2016 The MathWorks, Inc.
    
    properties(Hidden, Dependent, SetAccess=immutable)
        Extension
    end
    
    methods
        function artifact = FileArtifact(file)
            % FileArtifact = Class constructor
            %
            %   artifact = FileArtifact(file) creates a new FileArtifact
            %   instance associated with the file provided. file must be a
            %   charactor vector or string scalar referencing an existing
            %   file on disk.
            %
            %   Example:
            %       import matlab.unittest.diagnostics.FileArtifact;
            %       artifact = FileArtifact("C:\MyFolder\MyFile.txt");
            file = matlab.unittest.internal.fileResolver(file);
            [location,name,ext] = fileparts(file);
            artifact = artifact@matlab.unittest.diagnostics.Artifact(location,...
                [name,ext]);
        end
        
        function ext = get.Extension(artifact)
            [~,~,ext] = fileparts(char(artifact.Name));
            ext = string(ext);
        end
    end
    
    methods(Hidden, Access=protected)
        function newScalarArtifact = copyArtifactTo(scalarArtifact,newLocation)
            import matlab.unittest.diagnostics.FileArtifact;
            oldFile = scalarArtifact.FullPath;
            newFile = newLocation + filesep + scalarArtifact.Name;
            copyfile(char(oldFile),char(newFile),'f');
            newScalarArtifact = FileArtifact(newFile);
        end
    end
end