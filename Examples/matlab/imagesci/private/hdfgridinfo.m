function gridinfo = hdfgridinfo(filename,fileID,gridname)
%HDFGRIDINFO Information about HDF-EOS Grid data.
%
%   GRIDINFO = HDFGRIDINFO(FILENAME,GRIDNAME) returns a structure whose
%   fields contain information about a Grid data set in an HDF-EOS
%   file. FILENAME is a string that specifies the name of the HDF-EOS file
%   and GRIDNAME is a string that specifies the name of the Grid data set
%   in the file.
%
%   The fields of GRIDINFO are:
%
%   Filename       A string containing the name of the file
%
%   Name           A string containing the name of the Grid
%  
%   UpperLeft      A number specifying the upper left corner location
%                  in meters
%
%   LowerRight     A number specifying the lower right corner location
%                  in meters
%
%   Rows           An integer specifying the number of rows in the Grid
%   
%   Columns        An integer specifying the number of columns in the Grid
%
%   DataFields     An array of structures with fields 'Name', 'Rank', 'Dims',
%                  'NumberType', 'FillValue', and 'TileDims'. Each structure
%                  describes a data field in the Grid 
%
%   Attributes     An array of structures with fields 'Name' and 'Value'
%                  describing the name and value of the attributes of the
%                  Grid
%
%   Projection     A structure with fields 'ProjCode', 'ZoneCode',
%                  'SphereCode', and 'ProjParam' describing the Projection
%                  Code, Zone Code, Sphere Code and projection parameters of
%                  the Grid
%
%   Origin Code    A number specifying the origin code for the Grid
%
%   PixRegCode     A number specifying the pixel registration code
%
%   Type           A string describing the type of HDF/HDF-EOS
%                  object. 'HDF-EOS Grid' for Grid data sets
%

%   Copyright 1984-2013 The MathWorks, Inc.

%Return empty for data set not found 
gridinfo = [];

validateattributes(filename,{'char'},{'row'},'','FILENAME');
validateattributes(fileID,{'numeric'},{'scalar'},'','FILEID');
validateattributes(gridname,{'char'},{'row'},'','GRIDNAME');

[~,name,ext] = fileparts(filename);

%Open interfaces, return early if opening the file or attaching to the grid
%fails
try
    gridID = matlab.io.hdfeos.gd.attach(fileID,gridname);

    
    %Get upper left and lower right grid corners, # of rows and cols
    [Columns,Rows,UpperLeft,LowerRight] = matlab.io.hdfeos.gd.gridInfo(gridID);
    
    %Get info on data fields. fieldListLong is a comma separated list and
    %numberType is a cell array of strings
    [fieldList,fldRank] = matlab.io.hdfeos.gd.inqFields(gridID);
    nfields = numel(fieldList);
    if nfields > 0
        rank = cell(1,nfields);
        Dims = cell(1,nfields);
        FillValue = cell(1,nfields);
        tiledims = cell(1,nfields);
        numberType = cell(1,nfields);
        for i=1:nfields
            try
                fill = matlab.io.hdfeos.gd.getFillValue(gridID,fieldList{i});
            catch me %#ok<NASGU>
                fill = [];
            end
            [dimSizes,ntype,dimList] = matlab.io.hdfeos.gd.fieldInfo(gridID,fieldList{i});
            
            % Must post-process the datatype
            switch(ntype)
                case 'single'
                    numberType{i} = 'float';
                otherwise
                    numberType{i} = ntype;
            end
            
            rank{i} = fldRank(i);
            Dims{i} = struct('Name',flipud(dimList(:)),'Size',num2cell(flipud(dimSizes(:))));
            FillValue{i} = fill;
            %Get tile info
            try
                % adjust the tile size for row-major order
                tilesize = matlab.io.hdfeos.gd.tileInfo(gridID,fieldList{i});
                tiledims{i} = fliplr(tilesize);
            catch me %#ok<NASGU>
                tiledims{i} = [];
            end

        end
        DataFields = struct('Name',fieldList(:),'Rank',rank(:),'Dims',Dims(:),...
            'NumberType',numberType(:), 'FillValue', FillValue(:),...
            'TileDims',tiledims(:));
    else
        DataFields = [];
    end
    
    %Get attribute information
    attrList = matlab.io.hdfeos.gd.inqAttrs(gridID);
    nattrs = numel(attrList);
    if nattrs>0
        Attributes = cell2struct(attrList,'Name',2);
        for i=1:nattrs
            Attributes(i).Value = matlab.io.hdfeos.gd.readAttr(gridID,attrList{i});
        end
    else
        Attributes = [];
    end
    
    % Retrieve projection parameters.
    try
        [projcode,zonecode,spherecode,projparm] = matlab.io.hdfeos.gd.projInfo(gridID);
    catch me %#ok<NASGU>
        warning(message('MATLAB:imagesci:hdfinfo:couldNotRetrieveProjection', gridname, name, ext))
        projcode = [];
        zonecode = [];
        spherecode = [];
        projparm = [];
    end
    Projection.ProjCode = projcode;
    Projection.ZoneCode = zonecode;
    if isempty(spherecode) 
        Projection.SphereCode = [];
    else
        Projection.SphereCode = matlab.io.hdfeos.gd.sphereNameToCode(spherecode);
    end
    Projection.ProjParam = projparm;
    
    OriginCode = matlab.io.hdfeos.gd.originInfo(gridID);
    PixRegCode = matlab.io.hdfeos.gd.pixRegInfo(gridID);

    matlab.io.hdfeos.gd.detach(gridID);
    
    %Assign output structure
    gridinfo.Filename     =	 filename;
    gridinfo.Name         =	 gridname;
    gridinfo.UpperLeft    =	 UpperLeft;
    gridinfo.LowerRight   =	 LowerRight;
    gridinfo.Rows         =	 Rows;
    gridinfo.Columns      =	 Columns;
    gridinfo.DataFields   =	 DataFields;
    gridinfo.Attributes   =	 Attributes;
    gridinfo.Projection   =	 Projection;
    gridinfo.OriginCode   =  OriginCode;
    gridinfo.PixRegCode   =	 PixRegCode;
    gridinfo.Type         =  'HDF-EOS Grid';
    
    
catch me
    warning(message('MATLAB:imagesci:hdfinfo:mexError', me.message));
    gridinfo = [];
end
return;










