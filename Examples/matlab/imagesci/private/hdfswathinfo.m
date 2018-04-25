function swathinfo = hdfswathinfo(filename,fileID,swathname)
%HDFSWATHINFO Information about HDF-EOS Swath data.
%
%   SWATHINFO = HDFSWATHINFO(FILENAME,SWATHNAME) returns a structure whose
%   fields contain information about a Swath data set in an HDF-EOS
%   file. FILENAME is a string that specifies the name of the HDF-EOS file
%   and SWATHNAME is a string that specifies the name of the Swath data set.
%
%   The fields of SWATHINFO are:
%
%   Filename           A string containing the name of the file
%		       
%   Name               A string containing the name of the data set
%		       
%   DataFields         An array of structures with fields 'Name', 'Rank', 'Dims',
%                      'NumberType', and 'FillValue'.  Each structure
%                      describes a Data field in the Swath 
%
%   GeolocationFields  An array of structures with fields 'Name', 'Rank', 'Dims',
%                      'NumberType', and 'FillValue'.  Each structure
%                      describes a Geolocation field in the Swath 
%
%   MapInfo            A structure with fields 'Map', 'Offset', and
%                      'Increment' describing the relationship between the
%                      data and geolocation fields. 
%
%   IdxMapInfo         A structure with 'Map' and 'Size' describing the
%                      relationship between the indexed elements of the
%                      geolocation mapping
%
%   Attributes         An array of structures with fields 'Name' and 'Value'
%                      describing the name and value of the swath attributes 
%                      
%   Type               A string describing the type of HDF/HDF-EOS object.
%                     'HDF-EOS Swath' for Swath data sets

%   Copyright 1984-2013 The MathWorks, Inc.

swathinfo = [];

validateattributes(filename,{'char'},{'row'},'','FILENAME');
validateattributes(fileID,{'numeric'},{'scalar'},'','FILEID');
validateattributes(swathname,{'char'},{'row'},'','SWATHNAME');

%Open Swath interfaces
try
    swathID = matlab.io.hdfeos.sw.attach(fileID,swathname);
catch %#ok<CTCH>
    warning(message('MATLAB:imagesci:hdfinfo:attachFailure','SWATH',swathname));
    return;
end

%Get Data Field information
fieldList = matlab.io.hdfeos.sw.inqDataFields(swathID);
nfields = numel(fieldList);
if nfields>0
    
    rank = cell(1, nfields);
    numberType = cell(1, nfields);
    Dims = cell(1, nfields);
    FillValue = cell(1, nfields);
    
    for i=1:nfields
        try
            fill = matlab.io.hdfeos.sw.getFillValue(swathID,fieldList{i});
        catch %#ok<CTCH>
            fill = [];
        end
        [dimSizes,numberType{i},dimList] = matlab.io.hdfeos.sw.fieldInfo(swathID,fieldList{i});
        
        % Must post process the datatype.
        switch numberType{i}
            case 'single'
                numberType{i} = 'float';
        end
        
        rank{i} = numel(dimSizes);
        Dims{i} = struct('Name',flipud(dimList(:)),'Size',num2cell(flipud(dimSizes(:))));
        FillValue{i} = fill;
    end
    DataFields = struct('Name',fieldList(:),'Rank',rank(:),'Dims',Dims(:),...
        'NumberType',numberType(:),'FillValue', FillValue(:));
else
    DataFields = [];
end

%Get Geolocation information
[fieldList, ~, numbertype] = matlab.io.hdfeos.sw.inqGeoFields(swathID);
ngeofields = numel(fieldList);

Dims = cell(1, ngeofields);
FillValue = cell(1, ngeofields);
rank = cell(1, ngeofields);

if ngeofields>0
    for i=1:ngeofields
        try
            fill = matlab.io.hdfeos.sw.getFillValue(swathID,fieldList{i});
        catch %#ok<CTCH>
            fill = [];
        end
        
        % Must post process the datatype.
        switch numbertype{i}
            case 'single'
                numbertype{i} = 'float';
        end
        
        [dimSizes,~,dimList] = matlab.io.hdfeos.sw.fieldInfo(swathID,fieldList{i});
        rank{i} = numel(dimSizes);
        Dims{i} = struct('Name',flipud(dimList(:)),'Size',num2cell(flipud(dimSizes(:))));
        FillValue{i} = fill;
    end
    GeolocationFields = struct('Name',fieldList(:),'Rank',rank(:),'Dims',Dims(:),'NumberType',numbertype(:),'FillValue',FillValue(:));
else
    GeolocationFields = [];
end

%Get Geolocation relations
[dimMap, offset, increment] = matlab.io.hdfeos.sw.inqMaps(swathID);
nmaps = numel(dimMap);
if nmaps>0
    MapInfo = struct('Map',dimMap(:),'Offset',num2cell(offset(:)),'Increment',num2cell(increment(:)));
else
    MapInfo = [];
end

%Get index mapping relations
[idxMap, idxSizes] = matlab.io.hdfeos.sw.inqIdxMaps(swathID);
nmaps = numel(idxMap);
if nmaps>0
    IdxMapInfo = struct('Map',idxMap(:),'Size',num2cell(flipud(idxSizes(:))));
else
    IdxMapInfo = [];
end

%Retrieve attribute information.  If there are no attributes, then the
%return value is {''}
attrList = matlab.io.hdfeos.sw.inqAttrs(swathID);
if (numel(attrList) == 1) && isempty(attrList{1})
    nattr = 0;
else
    nattr = numel(attrList);
end
if nattr > 0
    Attributes = cell2struct(attrList,'Name',2);
    for i=1:nattr
        Attributes(i).Value = matlab.io.hdfeos.sw.readAttr(swathID,attrList{i});
    end
else
    Attributes = [];
end

%Close interfaces
matlab.io.hdfeos.sw.detach(swathID);

%Populate output structure
swathinfo.Filename         = filename;
swathinfo.Name             = swathname;
swathinfo.DataFields       = DataFields;
swathinfo.GeolocationFields= GeolocationFields;
swathinfo.MapInfo          = MapInfo;
swathinfo.IdxMapInfo       = IdxMapInfo;
swathinfo.Attributes       = Attributes;
swathinfo.Type             = 'HDF-EOS Swath';
return;




