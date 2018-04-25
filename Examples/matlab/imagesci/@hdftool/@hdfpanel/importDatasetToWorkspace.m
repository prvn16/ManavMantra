function importDatasetToWorkspace(this)
%IMPORTDATASETTOWORKSPACE Import data to the MATLAB workspace.
%   This function relies heavily on the buildImportCommand() method
%   of the active panel.
%
%   Function arguments
%   ------------------
%   THIS: the hdfpanel object instance.

%   Copyright 2005-2013 The MathWorks, Inc.

    set(this.filetree.fileFrame.figureHandle, 'Pointer', 'watch');
    % Turn off warnings so that they won't be displayed in the command window.
    warnState = warning('off'); %#ok<WNOFF>
    try
        doImport(this);
    catch myException
        errMsg = getString(message('MATLAB:imagesci:hdftool:importCommandFailed'));
        errordlg([errMsg ' ' myException.message], errMsg);
    end
    warning(warnState);
    set(this.filetree.fileFrame.figureHandle, 'Pointer', 'arrow');

end


function doImport(this)
% A procedure to import data.
    lastwarn('');
    drawnow;

    prefs = this.filetree.fileFrame.prefs;
    
    % build the import command
    cmd = this.buildImportCommand(true);
    
    % return if cmd is empty
    if isempty(cmd)
        return
    end
    
    % check if we need to import the metadata
    mHandle = get(this.filetree,'hImportMetadata');
    isImportMetadata = get(mHandle,'Value');
    
    % get the data variable name
    varname = get(this.filetree,'wsvarname');
    
    % get all the workspace variable names
    wsVars = evalin('base','whos');
    wsVarnames = {wsVars.name};
    
    % check if data variable exists in the workspace
    varExists = any(strcmp(varname,wsVarnames),2);
    
    importedVariable = false;
    % if variable does not exits in the workspace
    % or the user clicks "Yes" in the overwrite prompt
    if isempty(varExists) || ~varExists || overWriteVar(varname)
        evalin('base',cmd);
        importedVariable = true;
    end
    
    readWarn = lastwarn;
    if ~isempty(readWarn)
        warndlg(readWarn,...
            getString(message('MATLAB:imagesci:hdftool:warningTitle')) );
        return
    end
    
    % initiate the str to empty
    metaStr = '';
    
    % if user wants to import meta data
    if isImportMetadata
        % the info variable name
        infoVarname = sprintf('%s_info',varname);
        infoExists = any(strcmp(infoVarname,wsVarnames),2);
        
        if isempty(infoExists) || ~infoExists || overWriteVar(infoVarname)
            metadata = this.currentNode.nodeinfostruct;
            % Remove NodeType and NodePath, which are not part of the
            % hdfinfo structure.
            if isfield(metadata, 'NodeType')
                metadata = rmfield(metadata, 'NodeType');
            end
            if isfield(metadata, 'NodePath')
                metadata = rmfield(metadata, 'NodePath');
            end
            if isfield(metadata, 'vertical')
                metadata = rmfield(metadata, 'vertical');
            end
			metaStr = getString(message('MATLAB:imagesci:hdftool:importAndMetadata',infoVarname));
            assignin('base', infoVarname, metadata);
            importedVariable = true;
        end
    end
    
    if importedVariable && prefs.confirmImport
        helpdlg(...
            getString(message('MATLAB:imagesci:hdftool:importConfirmation',varname,metaStr)), ...
            getString(message('MATLAB:imagesci:hdftool:importMessage')));
    end
    
    %=========================================================================
    function chk = overWriteVar(var)
        % Determine if we should overwrite a variable in the workspace.
        set(this.filetree.fileFrame.figureHandle, 'Pointer', 'arrow');

        yes = getString(message('MATLAB:imagesci:hdftool:yes'));
        no = getString(message('MATLAB:imagesci:hdftool:no'));
        response = questdlg( ...
            getString(message('MATLAB:imagesci:hdftool:overwriteConfirmation',var)), ...
            getString(message('MATLAB:imagesci:hdftool:warningTitle')), ...
			yes, no, yes);
        switch response
            case yes
                chk = true;
            case no
                chk = false;
            otherwise
                chk = false;
        end
        set(this.filetree.fileFrame.figureHandle, 'Pointer', 'watch');
        drawnow;
    end
end    
    
