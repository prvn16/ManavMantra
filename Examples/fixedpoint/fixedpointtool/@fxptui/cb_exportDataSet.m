function cb_exportDataSet(varargin)
%CB_EXPORTDATASET Action callback to export all the runs in FPT to a mat file.

%   Copyright 2014 The MathWorks, Inc.

me = fxptui.getexplorer;
if isempty(me)
    return;
end

matFilter = fxptui.message('matFilter');
matDesc = fxptui.message('matDesc');
title = fxptui.message('exportDialogTitle');

% export file dialog
[filename, pathname] = uiputfile({matFilter , matDesc}, ...
    title,'');
if ~isequal(filename, 0) && ~isequal(pathname, 0)
    boolMatExtension = isMatExtensionPresent(filename);
    
    if (~boolMatExtension)
        errMsg = fxptui.message('errorInvalidFileExtension',filename);
        fxptui.showdialog('exportDataSet',errMsg);
        return;
    end
    fileName = fullfile(pathname, filename);
else
    % Case- If user decides to cancel the export operation on the launch
    % of the dialog
    return;
end

if ~isempty(fileName)
    converter = DataTypeWorkflow.Converter(me.getTopNode.getDAObject.getFullName);
    
    try
        pb = fxptui.createprogressbar(fxptui.message('labelExportingDataSet'));
        % The default mode is overwrite always.
        % The other possible mode is append which is true
        converter.export(fileName,{});
    catch exception
        pb.dispose;
        fxptui.showdialog('exportDataSet',exception.message);
    end
    pb.dispose;    
end

function boolMatExtension = isMatExtensionPresent(filename)
    delimeter = '.';
    splitFileName = strsplit(filename,delimeter,'CollapseDelimiters',false);
    splitFileNameLen = numel(splitFileName);
    boolMatExtension = 0;
    
    if (isequal(splitFileNameLen,2))
        if(~isempty(splitFileName{1}) && isempty(regexp(splitFileName{1},'\W','Once')))
            boolMatExtension = isequal(splitFileName{2},'mat');    
        end
        
    end
