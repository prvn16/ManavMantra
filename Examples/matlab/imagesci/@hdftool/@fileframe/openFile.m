function errorStruct = openFile(this, filenames)
%OPENFILE A method which is invoked to load a new file.
%   If a filename is not provided to this function,
%   They will be asked to select a file.
%
%   Function arguments
%   ------------------
%   THIS: the fileframe object instance.
%   FILENAME: the name of the file to open.

%   Copyright 2005-2013 The MathWorks, Inc.

    errorStruct = [];
    numOpen = numOpenFiles(this);

    % Select a file if one is not provided.
    if nargin < 2
        title = getString(message('MATLAB:imagesci:hdftool:selectHDF4File'));
        filterspec = {'*.hdf', getString(message('MATLAB:imagesci:hdftool:selectHDF4FilesFilterSpec'));...
                      '*.*', getString(message('MATLAB:imagesci:hdftool:selectAllFilesFilterspec'))};
        
        filenames = getFilenames(this, title, filterspec);
        if isempty(filenames)
            return
        end
    else
        % Convert to a cell array for homogenous processing later on
        filenames = {filenames};
    end
    % Open each selected file
    for i=1:length(filenames)
        filename = filenames{i};
        % Open the file based on its extension
        set(this.figureHandle, 'Pointer', 'watch');
        try
            [path, file, ext] = fileparts(filename);
            if hdftool.validateFile(filename)
                % Open the file
                fileTree = hdftool.hdftree(this, this.treeHandle, filename);
            else
                errorStruct.message = getString(message('MATLAB:imagesci:hdftool:notHDF4Format',filename));
                errorStruct.identifier = 'MATLAB:imagesci:hdftool:incorrectFormat';
                dlgMessage1 = getString(message('MATLAB:imagesci:hdftool:notHDF4Format',filename));
                dlgMessage2 = getString(message('MATLAB:imagesci:hdftool:useTheImportWizardQuestion'));
                yes = getString(message('MATLAB:imagesci:hdftool:yes'));
                no = getString(message('MATLAB:imagesci:hdftool:no'));
                importAnyway = questdlg([dlgMessage1 '  ' dlgMessage2], ...
                    getString(message('MATLAB:imagesci:hdftool:useTheImportWizardTitle')),...
                    yes, no, yes);
                if strcmp(importAnyway, yes)
                    uiimport(filename);
                end
            end
        catch myException
            set(this.figureHandle, 'Pointer', 'arrow');
            errorStruct = myException;
            if nargin < 2
                % We are being called without a filename.
                % Report errors in a dialog
                errordlg(myException.message, ...
                         getString(message('MATLAB:imagesci:hdftool:errorOpeningFileTitle')));
            end
        end
    end

    set(this.figureHandle, 'Pointer', 'arrow');
    if numOpen==0
        this.setDatapanel('default');
    else
        errorStruct = [];
    end
end

function filenames = getFilenames(this, title, filterspec)
    %GETFILENAME gets a filename from the user
    [filenames, pathname] = uigetfile(filterspec, title,'MultiSelect', 'on');
    if isequal(filenames,0)
        filenames = '';
        return;
    end
    if ~iscell(filenames)
        filenames = {filenames};
    end
    for i=1:length(filenames)
        filenames{i} = fullfile(pathname,filenames{i});
    end
end

function num = numOpenFiles(this)
    % A method to determine the number of open files.
    hdfRootNode = get(this.treeHandle,'Root');
    num = get(hdfRootNode, 'ChildCount');
end

