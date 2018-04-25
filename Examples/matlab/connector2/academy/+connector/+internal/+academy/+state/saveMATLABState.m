function saveMATLABState(statename)

%Folder for storing saved session
wd = fullfile(tempdir,'.state');
if ~exist(wd,'file')
    mkdir(wd);
end

%Random number generator seed
config_.seed = rng;

%Current folder
config_.pwd = pwd;

%Path
allPaths = path;
if strcmp(filesep,'\')
    allPaths = regexp(allPaths,';','split');
else
    allPaths = regexp(allPaths,':','split');
end
notInMATLABRoot = cellfun(@isempty,strfind(allPaths,matlabroot));
notInMLSEDU = cellfun(@isempty,strfind(allPaths,'opt/mlsedu'));
allPaths = allPaths(notInMATLABRoot & notInMLSEDU);
config_.paths = allPaths;

%Files opened with fopen
config_.openFileIds = fopen('all');
config_.openFileNames = arrayfun(@(x) fopen(x),config_.openFileIds,'UniformOutput',false);
config_.openFilePositions = arrayfun(@(x) ftell(x),config_.openFileIds);

%Workspace variables and figures
figs__ = findobj('Type','figure');
currentFig__ = get(0,'CurrentFigure');
assignin('base','currentFig__',currentFig__);
assignin('base','figs__',figs__);

save([wd filesep 'config_' statename '.mat'],'config_');
evalin('base',['save(''' wd filesep 'workspacevars_' statename '.mat'')']);

evalin('base','clear figs__ currentFig__');
