function [sdinfo, IsScale] = hdfsdsinfo(filename, sdID, anID, dataset)
%HDFSDSINFO Information about HDF Scientific Data Set. 
%
%   [SDINFO, ISSCALE] = HDFSDSINFO(FILENAME,SDID,ANID,DATASET) returns a
%   structure SDINFO whose fields contain information about an HDF Scientific Data
%   Set(SDS). IsScale is a true (1) if the SDS is a dimension scale, false
%   (0) otherwise. FILENAME is a string that specifies the name of the HDF
%   file.  SDID is the sds identifier returned by matlab.io.hdf4.sd.start(FILENAME,... 
%   ANID is the annotation identifier returned by hdfan('start',... DATASET is a
%   string specifying the name of the SDS or a number specifying the zero
%   based index of the data set. If DATASET is the name of the data set and
%   multiple data sets with that name exist in the file, the first dataset
%   is used.
%
%   Assumptions: 
%               1.  The file has been open.
%               2.  The SD and AN interfaces have been started.  
%               3.  anID may be -1
%               3.  The SD and AN interfaces and file will be closed elsewhere.
%
%   The fields of SDINFO are:
%
%   Filename          A string containing the name of the file
%		   
%   Type              A string describing the type of HDF object 
%
%   Name              A string containing the name of the data set
%		   
%   Rank              A number specifying the number of dimensions of the
%                     data set
%		   
%   DataType          A string specifying the precision of the data
%
%   Attributes        An array of structures with fields 'Name' and 'Value'
%                     describing the name and value of the attributes of the
%                     data set
%              
%   Dims              An array of structures with fields 'Name', 'DataType',
%                     'Size', 'Scale', and 'Attributes', describing the 
%                     dimensions of the data set.  'Scale' is an array of 
%                     numbers to place along the dimension and demarcate 
%                     intervals in the data set.
%
%   Label             A cell array containing an Annotation label
%
%   Description       A cell array containing an Annotation description
%		   
%   Index             Number indicating the index of the SDS

%   Copyright 1984-2015 The MathWorks, Inc.

sdinfo = struct('Filename',[],'Type',[],'Name',[],'Rank',[],'DataType',[], ...
    'Attributes',[],'Dims',[],'Label',[],'Description',[],'Index',[]);

validateattributes(filename,{'char'},{'row'},'','FILENAME');
validateattributes(sdID,{'numeric'},{'row'},'','SDID');
validateattributes(anID,{'numeric'},{'row'},'','ANID');
validateattributes(dataset,{'numeric','char'},{'row'},'','DATASET');


%User may input name or index to the SDS
if isnumeric(dataset)
    index = dataset;
elseif ischar(dataset)
    try
        index = matlab.io.hdf4.sd.nameToIndex(sdID,dataset);
    catch me %#ok<NASGU>
        warning(message('MATLAB:imagesci:hdfinfo:nametoindex', dataset));
        return;
    end
end

try
    sdsID = matlab.io.hdf4.sd.select(sdID,index);
catch me %#ok<NASGU>
    warning(message('MATLAB:imagesci:hdfinfo:select'));
    return;
end


%Convert index to reference number
ref = matlab.io.hdf4.sd.idToRef(sdsID);

%Get lots of info
[sdsName, dimSizes, sddataType, nattrs] = matlab.io.hdf4.sd.getInfo(sdsID);
rank = numel(dimSizes);

%Get SD attribute information. The index for readattr is zero based.
if nattrs>0
    arrayAttribute = repmat(struct('Name', '', 'Value', []), [1 nattrs]);
    for i = 1:nattrs
        arrayAttribute(i).Name = matlab.io.hdf4.sd.attrInfo(sdsID,i-1);
        arrayAttribute(i).Value = matlab.io.hdf4.sd.readAttr(sdsID,i-1);
    end
else
    arrayAttribute = [];
end

IsScale = matlab.io.hdf4.sd.isCoordVar(sdsID);

%If it is not a dimension scale, get dimension information
%Dimension numbers are 0 based (?)
if ~IsScale
    
    Scale = cell(1, rank);
    dimName = cell(1, rank);
    DataType = cell(1, rank);
    Size = cell(1, rank);
    Name = cell(1, rank);
    Value = cell(1, rank);
    Attributes = cell(1, rank);
    
    for i=1:rank
        dimID = matlab.io.hdf4.sd.getDimID(sdsID,rank-i);
        %Use sizes from SDgetinfo because this size may be Inf
        [dimName{i}, sizeDim,DataType{i}, nattrs] = matlab.io.hdf4.sd.dimInfo(dimID);
        if strcmp(DataType{i},'none')
            Scale{i} = 'none';
        elseif isinf(sizeDim)
            Scale{i} = 'unknown';
        else
            try
                Scale{i} = matlab.io.hdf4.sd.getDimScale(dimID);
            catch me %#ok<NASGU>
                Scale{i} = 'none';
            end
        end
        Size{i} = dimSizes(rank-i+1);
        if nattrs>0
            for j=1:nattrs
                Name{j} = matlab.io.hdf4.sd.attrInfo(dimID,j-1);
                Value{j} = matlab.io.hdf4.sd.readAttr(dimID,j-1);
            end
            Attributes{i} = struct('Name',Name(:),'Value',Value(:));
        else
            Attributes{i} = [];
        end
    end
    dims = struct('Name',dimName(:),'DataType',DataType(:),'Size',Size(:),'Scale',Scale(:),'Attributes',Attributes(:));
else
    dims = [];
end

%Get any associated annotations
tag = hdfml('tagnum','DFTAG_NDG');
if anID ~= -1
    [label,desc] = hdfannotationinfo(anID,tag,ref);
    if isempty(label) || isempty(desc)
        tag = hdfml('tagnum','DFTAG_SD');
        [label,desc] = hdfannotationinfo(anID,tag,ref);
    end
end

%Close interfaces
matlab.io.hdf4.sd.endAccess(sdsID);

%Populate output structure
sdinfo.Filename = filename;
sdinfo.Name = sdsName;
sdinfo.Index = index;
sdinfo.Rank = rank;
sdinfo.DataType = sddataType;
if ~isempty(arrayAttribute)
    sdinfo.Attributes = arrayAttribute;
end
if ~isempty(dims)
    sdinfo.Dims = dims;
end
sdinfo.Label = label;
sdinfo.Description = desc;
sdinfo.Type = 'Scientific Data Set';
