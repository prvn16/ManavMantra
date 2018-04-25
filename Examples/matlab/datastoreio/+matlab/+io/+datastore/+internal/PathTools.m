%PathTools
% Several tools to convert between local file paths and IRIs.

%   Copyright 2014 The MathWorks, Inc.

classdef (AllowedSubclasses = {?parallel.internal.mapreduce.PathTools}, Hidden) PathTools < handle
    methods (Static)
        
        % Check if the given path should be considered as a IRI.
        % Specifically, this will return true if the path is of the
        % form 'scheme:..' where scheme is not a single letter.
        function result = isIri(path)
            result = ~isempty(regexp(path, '^[a-zA-Z][a-zA-Z0-9+-]+:', 'once'));
        end
        
        % Ensure the given path is a local path usable by MATLAB.
        function value = ensureIsLocalPath(value)
            import matlab.io.datastore.internal.PathTools;
            if PathTools.isIri(value)
                value = PathTools.parseIRI(value);
                value = PathTools.convertIriToLocalPath(value);
            end
        end
        
        % Ensure the given path is an IRI usable by Hadoop.
        function value = ensureIsIri(value)
            import matlab.io.datastore.internal.PathTools;
            if PathTools.isIri(value)
                value = PathTools.parseIRI(value);
            else
                value = PathTools.convertLocalPathToIri(value);
            end
        end
        
        % Get the scheme of the given IRI.
        function scheme = getIriScheme(iri)
            jUri = java.net.URI(iri);
            scheme = char(jUri.getScheme());
        end
        
        % Convert a local path to an IRI.
        function iri = convertLocalPathToIri(localPath)
            iri = matlab.io.datastore.internal.localPathToIRI(localPath);
            iri = iri{1};
        end
        
        % Extract the path and authority of the given IRI. This will be
        % either /path/to/folder or //authority/path/to/folder.
        function localPath = convertIriToLocalPath(iri)
            if matlab.io.datastore.internal.isIRI(iri)
                [localPath, isLocal] = matlab.io.datastore.internal.localPathFromIRI(iri);
                localPath = localPath{1};
                if ~isLocal(1) % non-file scheme, so unchanged
                    error(message('MATLAB:datastoreio:pathlookup:unsupportedIRIScheme', iri));
                end
            else % not a valid IRI
                error(message('MATLAB:datastoreio:pathlookup:invalidIRI', iri));
            end
            if ispc
                localPath = strrep(localPath, '\', '/');
            end
        end
    end
    
    methods (Access = private, Static)
        % Helper function that parses the input as if it were an IRI. This
        % is currently only a validity check.
        function iri = parseIRI(iri)
            import matlab.io.datastore.internal.PathTools;
            import matlab.io.datastore.internal.isIRI;
            if isIRI(iri) && PathTools.isCompatibleWithJavaURI(iri)
                return;
            end
            
            error(message('MATLAB:datastoreio:pathlookup:invalidIRI', iri));
        end
        
        % Helper function that ensures the location is compatible with
        % 'java.net.URI'.
        function result = isCompatibleWithJavaURI(iri)
            result = true;
            try
                java.net.URI(iri);
            catch
                result = false;
            end 
        end
    end
    
    methods (Access = private)
        % Not instantiable
        function obj = PathTools(); end
    end
end
