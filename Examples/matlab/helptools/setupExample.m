function varargout = setupExample(arg,workDir)
% 
%   Copyright 2017 The MathWorks, Inc. 

metadata = findExample(arg);
if nargin < 2
    examplesDir = exampleUtils.getExamplesDir();
    workDir = fullfile(examplesDir, metadata.component, metadata.main);
else
    % Verify dir input
    if isstring(workDir)
        workDir = char(workDir);
    end
    if isempty(workDir)
        error(em('EmptyDirectory'));
    elseif ~ischar(workDir)
        error(em('InvalidDirectory'));
    end
end

% Setup workdir 
exampleUtils.setupWorkDir(workDir);

% Main file.
exampleUtils.setupMainFile(metadata, workDir);

% Supporting files.
exampleUtils.setupSupportingFiles(metadata, workDir);

if nargout
	varargout{1} = workDir;
    varargout{2} = metadata;
end
end

function m = em(id,varargin)
m = message(['MATLAB:examples:' id],varargin{:});
end