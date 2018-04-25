function cmd = buildImportCommand(this, bImport)
%BUILDIMPORTCOMMAND Create the command that will be used to import the data.
%
%   Function arguments
%   ------------------
%   THIS: the gridPanel object instance.
%   BIMPORT: THis indicates if the string will be used for import.
%       If this is the case, we will do some extra error checking.

%   Copyright 2005-2013 The MathWorks, Inc.


    % Use the api's to determine a command that will import the data
    infoStruct = this.currentNode.nodeinfostruct;
    varName = get(this.filetree,'wsvarname');
    cmd = sprintf('%s = hdfread(''%s'', ''%s''', ...
        varName, this.filetree.filename, infoStruct.Name);
    
    Fields = this.datafieldApi.getSelectedString();
    cmd = sprintf('%s , ''Fields'', ''%s''', cmd, Fields);

    Level = this.levelApi.getSelectedString();
    if bImport && (str2double(Level) < 1)
        errordlg( ...
            getString(message('MATLAB:imagesci:hdftool:invalidPointLevel')), ...  
            getString(message('MATLAB:imagesci:hdftool:invalidSubsetSelection')));
        cmd = '';
        return
    end
    cmd = sprintf('%s, ''Level'', %d', cmd, Level);

    Box = [this.boxApi.getBoxCorner1Values()';...
           this.boxApi.getBoxCorner2Values()'];
    if ~any(isnan(Box(:))) 
        cmd = sprintf('%s, ''Box'', {[%s] [%s]}', ...
            cmd, num2str(Box(:,1)'), num2str(Box(:,2)') );
    end
    
    RecordString = this.recordApi.getSelectedString();
    if ~isempty(RecordString)
        RecordNumbers = str2num(RecordString);
        cmd = sprintf('%s, ''RecordNumbers'', [%s]', cmd, RecordString);
        if bImport && ...
                (any(RecordNumbers<1) || any(RecordNumbers>infoStruct.NumRecords))
            errordlg(...
                getString(message('MATLAB:imagesci:hdftool:invalidNumberOfRecords',num2str(infoStruct.NumRecords))), ...  
                getString(message('MATLAB:imagesci:hdftool:invalidSubsetSelection')));
            cmd = '';
            return
        end
    end
  
    Time = this.timeApi.getValues();
    if ~any(isnan(Time))
        cmd = sprintf('%s, ''Time'', [%s]', cmd, num2str(Time));
    end
    
    cmd = [cmd ');'];
    set(this.filetree,'matlabCmd',cmd);

end

