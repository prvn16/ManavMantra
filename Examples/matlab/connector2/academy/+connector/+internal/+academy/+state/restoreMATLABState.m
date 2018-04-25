function restoreMATLABState(statename)

%Folder where states are stored
wd = fullfile(tempdir,'.state');

%Clean up
evalin('base','close all hidden; fclose all; builtin(''clear'')');

%Workspace variables and figures
try
    evalin('base',['load(''' wd filesep 'workspacevars_' statename '.mat'')']);
    evalin('base','try, figure(currentFig__), end;');
    evalin('base','clear figs__ currentFig__');
catch
    %No variables to load
end

%Stored config params
load([wd filesep 'config_' statename '.mat']);

%Path
pathsToEnsure = config_.paths;
currentPaths = path;
currentPaths = regexp(currentPaths,';','split');
notInMATLABRoot = cellfun(@isempty,strfind(currentPaths,matlabroot));
notInMLSEDU = cellfun(@isempty,strfind(currentPaths,'opt/mlsedu'));
currentPaths = currentPaths(notInMATLABRoot & notInMLSEDU);
pathsToAdd = setdiff(pathsToEnsure,currentPaths);
pathsToRemove = setdiff(currentPaths,pathsToEnsure);
if ~isempty(pathsToAdd)
    addpath(pathsToAdd{:},'-end');
end
if ~isempty(pathsToRemove)
    rmpath(pathsToRemove{:});
end

%Random number seed
rng(config_.seed);

%Current folder
cd(config_.pwd);

%Files opened with fopen
for i = 1:numel(config_.openFileNames)
    tmpfid_ = fopen(config_.openFileNames{i});
    fseek(tmpfid_,config_.openFilePositions(i),'bof');
end
clear('tmpfid_');
