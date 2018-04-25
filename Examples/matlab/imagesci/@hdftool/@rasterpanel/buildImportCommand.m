function cmd = buildImportCommand(this, bImport)
%BUILIMPORTCOMMAND Create the command that will be used to import the data.
%
%   Function arguments
%   ------------------
%   THIS: the gridPanel object instance.
%   BIMPORT: THis indicates if the string will be used for import.
%       If this is the case, we will do some extra error checking.

%   Copyright 2005-2013 The MathWorks, Inc.

    infoStruct    = this.currentNode.nodeinfostruct;
    drawnow;
    imageVarName  = get(this.filetree,'wsvarname');
    fileName      = this.filetree.filename;
    datasetName   = infoStruct.Name;
    rasterType    = infoStruct.Type;

    baseCmd = '%s = hdfread(''%s'', ''%s'');';

    switch (rasterType)
        case '8-Bit Raster Image'
            cmapVarName = get(this.editHandle, 'String');
            rhsStr = sprintf('[%s,%s]', imageVarName, cmapVarName);
            cmd = sprintf(baseCmd,...
                rhsStr,...
                fileName,...
                datasetName);
        case '24-Bit Raster Image'
            cmd = sprintf(baseCmd,...
                imageVarName,...
                fileName,...
                datasetName);
        otherwise
            cmd = '';
    end

    set(this.filetree,'matlabCmd',cmd);

end
