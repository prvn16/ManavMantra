function openExample(varargin)
%openExample Open an example for modification and execution.
%   openExample(E) opens an example, identified by E, in a new folder. If
%   the folder already exists, it opens the existing version.
%   openExample(E,WD) opens an example, identified by E, in a folder, identified by WD. If
%   the folder already exists, it opens the existing version.

%   Copyright 2015-2017 The MathWorks, Inc. 

[workDir,metadata] = setupExample(varargin{:});

% Change folder for runnability and such.
cd(workDir)

% Reset workDir to account for symbolic links in user's $HOME path
workDir = pwd;

% This flag is unsupported and for internal use only.
if (getappdata(0,'demo_publishing_temp_directory'))
    cd(workDir)
    return
end

% Open.
default = true;
for iFiles = 1:numel(metadata.files)
    f = metadata.files{iFiles};
    if f.open
        open(fullfile(workDir,f.filename))
        default = false;
    end
end

if isfield(metadata,'callback')
    eval(metadata.callback)
    default = false;
end

if default
    mainFile = exampleUtils.getMainFile(metadata);
    edit(fullfile(workDir, mainFile))
end

