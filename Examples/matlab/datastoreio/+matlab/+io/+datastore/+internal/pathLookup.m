function [f, s] = pathLookup(pths, includeSubfolders, noSuggestionInErr, forCompression)
%PATHLOOKUP Get resolved file names and file sizes for input paths.
%   FILES = pathLookup(PATHS) returns the fully resolved file names for the
%   paths or IRIs specified in PATHS. This happens non-recursively by
%   default i.e. we do not look under subfolders while resolving. PATHS can
%   be a single string or a cell array of strings denoting paths to files
%   or folders. The path can include wildcards.
%
%   FILES = pathLookup(PATHS, INCLUDESUBFOLDERS) returns the fully resolved
%   file names for the paths or IRIs specified in PATHS taking
%   INCLUDESUBFOLDERS into account.
%   1) If a path refers to a single file, that file is added to the output.
%   2) If a path refers to a folder
%          i) all files in the specified folder are added to the output.
%         ii) if INCLUDESUBFOLDERS is false, subfolders are ignored.
%        iii) if INCLUDESUBFOLDERS is true, all files in all subfolders are
%             added.
%   3) If path refers to a wild card:
%          i) all files matching the pattern are added.
%         ii) if INCLUDESUBFOLDERS is false, folders that match the pattern
%              are looked up just for files.
%        iii) if INCLUDESUBFOLDERS is true, an error is thrown.
%
%   FILES = pathLookup(PATHS, INCLUDESUBFOLDERS, NOSUGGESTIONINERR) errors
%   with the suggestion to use pathLookup with IncludeSubfolders if
%   NOSUGGESTIONINERR is false (default).
%
%   FILES = pathLookup(PATHS, INCLUDESUBFOLDERS, NOSUGGESTIONINERR, FORCOMPRESSION)
%   provides files in a compressed form separated by folders and a list of files
%   each corresponding to each of the folders.
%
%   [FILES,FILESIZES] = pathLookup(__) also returns the file sizes for
%   the resolved paths as an array of double values.
%
%   For more information on IRIs, please refer to
%   http://en.wikipedia.org/wiki/Internationalized_resource_identifier
%

%   Copyright 2014-2017, The MathWorks, Inc.

    narginchk(1,4);
    nargoutchk(0,2);

    % imports
    import matlab.io.datastore.internal.isIRI;
    import matlab.io.datastore.internal.pathLookupNative;
    import matlab.io.datastore.internal.pathLookupLocal;
    import matlab.io.datastore.internal.pathLookupLocalForDsFileSet;
    import matlab.io.datastore.internal.validators.validatePaths;

    % returns {} for {}
    pths = validatePaths(pths);

    % empty case
    if nargout > 0
        f = {};
        s = [];
    end

    if isempty(pths)
        try
            if exist('includeSubfolders','var')
                isIncludeSubfoldersLogical(includeSubfolders);
            end
        catch ME
            throw(ME);
        end
        return;
    end

    % validate recursive lookup option.
    switch nargin
        case 1
            includeSubfolders = false;
            noSuggestionInErr = false;
            forCompression = false;
        case 2
            noSuggestionInErr = false;
            forCompression = false;
        case 3
            forCompression = false;
            % do not break, so we check next case
        case {2, 3, 4}
            includeSubfolders = isIncludeSubfoldersLogical(includeSubfolders);
    end

    if forCompression
        localLookupFcn = @pathLookupLocalForDsFileSet;
    else
        localLookupFcn = @pathLookupLocal;
    end

    % call to underlying builtin which does the actual lookup
    switch nargout
        case 0
            pathLookupNative(pths, includeSubfolders);
        case 1
            np = numel(pths);
            f = cell(np, 1);
            for ii = 1:np
                pth = pths{ii};
                try
                    if isIRI(pth)
                        f{ii} = pathLookupNative(pth, includeSubfolders, forCompression);
                        continue;
                    end
                    f{ii} = localLookupFcn(pth, includeSubfolders);
                catch e
                    iHandleEmptyFolderError(e, pth, noSuggestionInErr);
                end
            end
            f = vertcat(f{:});
        case 2
            np = numel(pths);
            f = cell(np, 1);
            s = cell(np, 1);
            for ii = 1:np
                pth = pths{ii};
                try
                    if isIRI(pth)
                        [f{ii}, s{ii}] = pathLookupNative(pth, includeSubfolders, forCompression);
                        continue;
                    end
                    [f{ii}, s{ii}] = localLookupFcn(pth, includeSubfolders);
                catch e
                    iHandleEmptyFolderError(e, pth, noSuggestionInErr);
                end
            end
            f = vertcat(f{:});
            s = vertcat(s{:});
    end
end

function iHandleEmptyFolderError(e, pth, noSuggestionInErr)
    % Throw emptyFolderNoSuggestion error message if noSuggestionInErr is true
    % which does not have a suggestion to use IncludeSubfolders.
    % This is required for datastores when they do not support IncludeSubfolders,
    % for example, in TallDatastore.
    if noSuggestionInErr && strcmp(e.identifier, 'MATLAB:datastoreio:pathlookup:emptyFolder')
        error(message('MATLAB:datastoreio:pathlookup:emptyFolderNoSuggestion', pth));
    end
    throw(e);
end

function includeSubfolders = isIncludeSubfoldersLogical(includeSubfolders)
% Check if the given includeSubfolders option is logical or not
import matlab.io.datastore.internal.validators.validateLogicalOption;
includeSubfolders = validateLogicalOption(includeSubfolders,...
    'MATLAB:datastoreio:pathlookup:invalidIncludeSubfolders');
end
