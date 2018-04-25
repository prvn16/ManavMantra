function vdinfo = hdfvdatainfo(filename,fileID,anID,dataset)
%VDATAINFO Information about Vdata set
%
%   VDINFO = VDATAINFO(FILENAME,FILEID,DATASET) returns a structure whose fields
%   contain information about an HDF Vdata data set.  FILENAME is a string
%   that specifies the name of the HDF file.  FILEID is the file identifier
%   returned by using fileid = hdfh('open',filename,permission). DATASET is
%   a string specifying the name of the Vdata or a number specifying the
%   zero based reference number of the data set. If DATASET is the name of
%   the data set and multiple data sets with that name exist in the file,
%   the first dataset is used.  
%
%   Assumptions: 
%               1.  The file has been open.  FILEID is a valid file
%                   identifier.
%               2.  The V and AN interfaces have been started.
%               3.  anID may be -1
%               4.  The file, V, and AN interfaces will be closed elsewhere.
%
%   The fields of VDINFO are:
%
%   Filename          A string containing the name of the file
%           
%   Name              A string containing the name of the data set
%           
%   DataAttributes    An array of structures with fields 'Name' and 'Value'
%                     describing the name and value of the attributes of the
%                     entire data set
%
%   Class             A string containing the class name of the data set
%              
%   Fields            An array of structures with fields 'Name' and
%                     'Attributes' describing the fields of the Vdata
%              
%   NumRecords        A number specifying the number of records of the data set   
%              
%   IsAttribute       1 if the Vdata is an attribute, 0 otherwise
%
%   Label             A cell array containing an Annotation label
%
%   Description       A cell array containing an Annotation description
%              
%   Type              A string describing the type of HDF object 
%
%   Ref               The reference number of the Vdata set

%   Copyright 1984-2013 The MathWorks, Inc.

vdinfo = [];

validateattributes(filename,{'char'},{'row'},'','FILENAME');
validateattributes(fileID,{'numeric'},{'scalar'},'','FILEID');
validateattributes(anID,{'numeric'},{'scalar'},'','ANID');
validateattributes(dataset,{'numeric','char'},{'row'},'','DATASET');

if isnumeric(dataset)
    ref = dataset;
elseif ischar(dataset)
    ref = hdfvs('find',fileID,dataset);
    if ref == 0
        warning(message('MATLAB:imagesci:hdfinfo:find', dataset));
        return;
    end
end

vdID = hdfvs('attach',fileID,ref,'r');
if vdID == -1
    warning(message('MATLAB:imagesci:hdfinfo:attachFailure',filename, dataset));
    return;
end

[class, status] = hdfvs('getclass',vdID);
hdfwarn(status)

% Vdata can have attributes attached to "vdata fields" or the vdata
% themselves.  nattrs() returns the count of both.  fnattrs() returns the
% count of one or the other depending on what you ask for.  We ask for the
% number of attributes for fields.

% Furthermore, attribute oriented inquiry uses 0-based indexing.

%Get Vdata information
attrcount = 0;
[records, ~, fieldListLong, ~, vdata_name, status] = hdfvs('inquire',vdID);
if (status == -1)
    [~,name,ext] = fileparts(filename);
    warning (message('MATLAB:imagesci:hdfinfo:inquireFailure', ref, name, ext));
    records = '';
    fields = '';
else
    %Parse field names
    fieldnames = parselist(fieldListLong);
    fields =  cell2struct(fieldnames,'Name',1);
    
    % Get Vdata field attributes.
    for i = 1:length(fieldnames)
        fieldAttrCount = hdfvs('fnattrs', vdID, i-1);
        hdfwarn(fieldAttrCount)
        for j = 1:fieldAttrCount
            [name, ~, ~, ~, status] = hdfvs('attrinfo', vdID, i-1, j-1);
            hdfwarn(status)
            [attrdata, status] = hdfvs('getattr', vdID, i-1, j-1);
            hdfwarn(status)
            fields(i).Attributes(j).Name = name;
            fields(i).Attributes(j).Value = attrdata;
            attrcount = attrcount+1;
        end
        if (fieldAttrCount == 0)
            fields(i).Attributes = [];
        end
    end
end


% Get general Vdata attributes.
nattrs = hdfvs('nattrs',vdID);
vdataAttrCount = nattrs - attrcount;
hdfwarn(nattrs)
if (vdataAttrCount > 0)
    DataAttributes = repmat(struct('Name', '', 'Value', []), [1 vdataAttrCount]);
    for i = 1:(nattrs-attrcount)
        [name, ~, ~, ~, status] = hdfvs('attrinfo', vdID, 'vdata', i-1);
        hdfwarn(status)
        [attrdata, status] = hdfvs('getattr', vdID, 'vdata', i-1);
        hdfwarn(status)
        DataAttributes(i).Name = name;
        DataAttributes(i).Value = attrdata;
    end
else
    DataAttributes = [];
end


isattr = logical(hdfvs('isattr',vdID));

%Get annotations
tag = hdfml('tagnum','DFTAG_VS');
if anID ~= -1
    [label,desc] = hdfannotationinfo(anID,tag,ref);
end

%Detach from data set
status = hdfvs('detach',vdID);
hdfwarn(status)

%Populate output structure
vdinfo.Filename = filename;
vdinfo.Name = vdata_name;
vdinfo.Class = class;
vdinfo.Fields = fields;
vdinfo.NumRecords = records;
vdinfo.IsAttribute = isattr;
vdinfo.DataAttributes = DataAttributes;
vdinfo.Label = label;
vdinfo.Description = desc;
vdinfo.Ref = ref;
vdinfo.Type = 'Vdata set';



