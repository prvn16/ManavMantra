function iri = iriFullfile(iri, varargin)
%IRIFULLFILE Perform the IRI equivalent of fullfile.
%
%   IRI = iriFullfile(IRI,SUBPATH1,SUBPATH2,..) returns the IRI that
%   represents the subfolder specified by the subpaths. All inputs can
%   either be a character vector, or cell array of character vectors.

%   Copyright 2017 The MathWorks, Inc.

isOutputChar = ischar(iri);
iri = cellstr(iri);

for ii = 1:numel(varargin)
    isOutputChar = isOutputChar  && ischar(varargin{ii});
    varargin{ii} = cellstr(varargin{ii});

    iri = cellfun(@iEnsureEndsWithSlash, iri, 'UniformOutput', false);
    iri = matlab.io.datastore.internal.iriResolve(iri, varargin{ii});
end

if isOutputChar
    iri = iri{1};
end

function x = iEnsureEndsWithSlash(x)
% Ensure the given string ends with a slash.
if ~endsWith(x, '/')
    x = [x, '/'];
end
