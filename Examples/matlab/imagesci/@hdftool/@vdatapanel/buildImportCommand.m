function cmd = buildImportCommand(this, bImport)
%BUILIMPORTCOMMAND Create the command that will be used to import the data.
%
%   Function arguments
%   ------------------
%   THIS: the gridPanel object instance.
%   BIMPORT: THis indicates if the string will be used for import.
%       If this is the case, we will do some extra error checking.

%   Copyright 2005-2013 The MathWorks, Inc.


infoStruct = this.currentNode.nodeinfostruct;
cmd = '';

baseCmd = ['%s = hdfread(''%s'', ''%s'', ''Fields'', ''%s'', ',...
           '''FirstRecord'',%d ,''NumRecords'',%d);'];

fieldname = this.datafieldApi.getSelectedString();
firstRec  = str2double(this.firstrecordApi.getSelectedString());
numRec    = str2double(this.numrecordsApi.getSelectedString());

availableRec = infoStruct.NumRecords - firstRec + 1;

if bImport
    if (isempty(firstRec) || firstRec < 1 || ...
        firstRec > infoStruct.NumRecords)
        errordlg(...
            getString(message('MATLAB:imagesci:hdftool:invalidRecordNumber', num2str(infoStruct.NumRecords))),...
            getString(message('MATLAB:imagesci:hdftool:invalidSubsetSelection')));
        return
        
    elseif (isempty(numRec) || numRec > availableRec || ...
            numRec < 1 || numRec > infoStruct.NumRecords)
        errordlg(...
            getString(message('MATLAB:imagesci:hdftool:invalidNumberOfRecords',num2str(availableRec))), ...
            getString(message('MATLAB:imagesci:hdftool:invalidSubsetSelection')));
        return
        
    end
end

% Get the variable name as it appears in the edit box.
varname = get(this.filetree,'wsvarname');

% Build the import string.
if numel(infoStruct.Name) == 0
    
    selectFmt = '''Fields'', ''%s'', ''FirstRecord'', %d, ''NumRecords'', %d);';
    cmdSelectStr = sprintf ( selectFmt, fieldname, firstRec, numRec );
    
    cmd = construct_import_command_from_reference(infoStruct, ...
                                                  cmdSelectStr, ...
                                                  varname);
    
else
    cmd = sprintf(baseCmd, ...
                  varname, ...
                  this.filetree.filename, ...
                  infoStruct.NodePath, ...
                  fieldname, ...
                  firstRec, ...
                  numRec);
end

set(this.filetree,'matlabCmd',cmd);


%==========================================================================
% When requesting an anonymous VDATA, we have to build a command that keys
% on the reference number and which uses the info structure output of
% HDFINFO.
function cmd = construct_import_command_from_reference(infoStruct, cmdSelectStr, varname)
cmd = sprintf ('%s_info = hdfinfo(''%s''); %s = hdfread(%s_info', ...
               varname, infoStruct.Filename, varname, varname);
hinfo = hdfinfo ( infoStruct.Filename );

[cmd,foundit] = recursively_build_import_command ( hinfo, infoStruct, cmd );

%
% Tack on the field subselection part.
if foundit
	cmd = [cmd ', ' cmdSelectStr];
end


%==========================================================================
function [cmd_output, foundit] = recursively_build_import_command ( info, vdataStruct, cmd_input )


%
% Go through each VDATA dataset in the current group.  If we find the correct
% reference, then finish building the command and exit back up the call stack.
foundit = false;
if isfield ( info, 'Vdata' )
    numvd = numel(info.Vdata);
    for j = 1:numvd
        if ( info.Vdata(j).Ref == vdataStruct.Ref )
            cmd_output = sprintf ( '%s.Vdata(%d)', cmd_input, j );
            foundit = true;
            return
        end
    end
end

%
% Ok, so none of the VDATA datasets in the current group had the correct Ref 
% number.  So recurse on each child VGROUP of the current VGROUP, and check
% all the VDATAs in each.
if isfield ( info, 'Vgroup' )
    numvg = numel(info.Vgroup);
    for j = 1:numvg
        cmd = sprintf ( '%s.Vgroup(%d)', cmd_input, j );
        [cmd_output, foundit] = recursively_build_import_command ( info.Vgroup(j), vdataStruct, cmd );
        if foundit
            return
        end
    end
end

cmd_output = cmd_input;

return
