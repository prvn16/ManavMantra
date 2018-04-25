function cb_importDataSet(varargin)
%CB_IMPORTDATASET Action callback to import dataset from a mat file into FPT.

%   Copyright 2014-2017 The MathWorks, Inc.

me = fxptui.getexplorer;
if isempty(me)
    return;
end

matFilter = fxptui.message('matFilter');
matDesc = fxptui.message('matDesc');
title = fxptui.message('importDialogTitle');

% Display dialog
[filename, pathname] = uigetfile({matFilter, matDesc}, ...
    title);


if ~isequal(filename, 0) && ~isequal(pathname, 0)
    
    % Form full name of file
    fullFileName = fullfile(pathname, filename);
    converter = DataTypeWorkflow.Converter(me.getTopNode.getDAObject.getFullName);
    
    % check if there are any common runNames between the mat file and FPT
    % dataset. Returns the list of commonRunNames.
    % If commonRunNames is empty, merge is performed else user is prompted
    % to enter the choice while loadingRuns
    
    [commonRunNames,isExceptionCaught] = checkIfRunExists(me,converter,fullFileName);
    userChoice = 'merge';
    if(~isExceptionCaught)
        if ~isempty(commonRunNames)
            % function for question dialog
            userChoice = getUserChoice(filename);
        end
        % This is for cases when user wants to cancel the operation
        if ~isempty(userChoice)
            
            try
                pb = fxptui.createprogressbar(fxptui.message('labelImportingDataSet'));
                loadFPTDataSet(converter,fullFileName,userChoice);
            catch exception
                pb.dispose;
                fxptui.showdialog('importDataSet',exception.message);
            end
            me.getFPTRoot.fireHierarchyChanged;
            fxptui.cb_togglehighlight
            me.updateactions
            pb.dispose;
        end
    end
end

function loadFPTDataSet(converter, fullFileName,userChoice)
% Always load 'All' runs
converter.import(fullFileName,{},userChoice);

function [commonRunNames,isExceptionCaught] = checkIfRunExists(me,converter,fullFileName)
% loadRunNames - present in the MAT file
commonRunNames = '';
try
    loadRunNames = converter.loadRunNames(fullFileName);
    isExceptionCaught = false;
catch exception
    fxptui.showdialog('importDataSet',exception.message);
    isExceptionCaught = true;
    return;
end

runNameLen = numel(loadRunNames);
if(runNameLen > 0)
    DataLayer = fxptds.DataLayerInterface.getInstance();
    fptRunNames = DataLayer.getAllRunNamesUsingModelSource(me.getTopNode.getDAObject.getFullName);
    [commonRunNames,~] = intersect(loadRunNames, fptRunNames,'stable');
end

function userChoice = getUserChoice(filename)
choice = questdlg(fxptui.message('labelImportDataSetOptions',filename), ... % Text
    fxptui.message('labelImportDataSetOptionsQuestDlg'), ...% Title
    fxptui.message('labelMergeData'),...
    fxptui.message('labelKeepExistingData'),...
    fxptui.message('labelOverwriteData'),... 
    fxptui.message('labelMergeData') ...% Default Selection for keyboard use
    );
% handle response
switch choice
    case fxptui.message('labelMergeData')
        userChoice = 'merge';
    case fxptui.message('labelOverwriteData')
        userChoice = 'overwrite';
    case fxptui.message('labelKeepExistingData')
        userChoice = 'keepExisting';
    otherwise
        % This is for cases when user wants to cancel the operation. This
        % can be done by either pressing close button on top right corner
        % or by pressing Esc key.
        userChoice = '';
end