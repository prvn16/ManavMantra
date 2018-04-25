function h5writeatt(varargin)
%H5WRITEATT  Write HDF5 attribute.
%   H5WRITEATT(FILENAME,LOCATION,ATTNAME,ATTVALUE, Name1, Value1, ...)
%   writes the attribute named ATTNAME with the value ATTVALUE to the HDF5
%   file FILENAME.  The parent object LOCATION can be either a group or
%   variable.  LOCATION must be a complete pathname.
%
%   Name-Value pairs
%   ----------------
%   'TextEncoding' - Defines the character encoding to be used for the
%                    attribute name. This character encoding also applies
%                    to any text that is being written as the value of the
%                    attribute. It takes values 'system' or 'UTF-8'.
%                    Default value is 'system'. 
%
%   The specified attribute will be created if it does not already exist.  
%   If the specified attribute already exists but does not have a datatype
%   or dataspace consistent with ATTVALUE, the attribute will be deleted 
%   and recreated.
%
%   String attributes will be created with a scalar dataspace.
%
%   Example:  Create a root group attribute whose value is the current
%   time.
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.h5');
%       copyfile(srcFile,'myfile.h5');
%       fileattrib('myfile.h5','+w');
%       h5writeatt('myfile.h5','/','creation_date',datestr(now));
%
%   Example:  Create a double precision data set attribute.
%       srcFile = fullfile(matlabroot,'toolbox','matlab','demos','example.h5');
%       copyfile(srcFile,'myfile.h5');
%       fileattrib('myfile.h5','+w');
%       attData = [0 1 2 3];
%       h5writeatt('myfile.h5','/g4/world','attr',attData);
%       h5disp('myfile.h5','/g4/world');
%
%   See also H5READATT, H5DISP.

%   Copyright 2010-2016 The MathWorks, Inc.

p = inputParser;
p.addRequired('filename', ...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','FILENAME'));
p.addRequired('location', ...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','LOCATION'));
p.addRequired('attname', ...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','LOCATION'));
p.addRequired('attvalue',@(x)true);
p.addParameter('TextEncoding', 'system', ...
    @(x) ismember(lower(x), {'system', 'utf-8'}));
p.parse(varargin{:});

filename = p.Results.filename;
location = p.Results.location;
attname = p.Results.attname;
attvalue = p.Results.attvalue;
useUtf8 = strcmpi(p.Results.TextEncoding, 'UTF-8');

if location(1) ~= '/'
    error(message('MATLAB:imagesci:h5writeatt:notFullPathName'));
end
    

fileId = H5F.open(filename,'H5F_ACC_RDWR','H5P_DEFAULT');
cf     = onCleanup(@()H5F.close(fileId));

objId  = H5O.open(fileId,location,'H5P_DEFAULT');
co     = onCleanup(@()H5O.close(objId));

dataspaceId = createDataspaceId(attvalue);
cdsp        = onCleanup(@()H5S.close(dataspaceId));
datatypeId  = createDatatypeId(attvalue, useUtf8);
cdt         = onCleanup(@()H5T.close(datatypeId));
acpl        = H5P.create('H5P_ATTRIBUTE_CREATE');
cacpl       = onCleanup(@()H5P.close(acpl));

% If the attribute already exists, open it.  If it does not exist, create
% it.
try
    attrId = H5A.open(objId,attname,'H5P_DEFAULT');
catch me
    % If not the error we normally would expect when trying to open an
    % attribute, then something bad happened.
    if ~strcmp(me.identifier,'MATLAB:imagesci:hdf5lib:libraryError')
        rethrow(me);
    end
    % Assume the attribute doesn't exist.
    if useUtf8
        H5P.set_char_encoding(acpl, H5ML.get_constant_value('H5T_CSET_UTF8'));
    end
	attrId = H5A.create(objId,attname,datatypeId,dataspaceId,acpl);
end


% Is the datatype equivalent?  Is the dataspace equivalent?
atype = H5A.get_type(attrId);  catype = onCleanup(@()H5T.close(atype));
space = H5A.get_space(attrId); cspace = onCleanup(@()H5S.close(space));

[~,dims] = H5S.get_simple_extent_dims(space);
if ( ~H5T.equal(atype,datatypeId) ) || (prod(dims) ~= numel(attvalue))
    % Must delete the attribute and recreate it.
    H5A.close(attrId);
    H5A.delete(objId,attname);
    if useUtf8
        H5P.set_char_encoding(acpl, H5ML.get_constant_value('H5T_CSET_UTF8'));
    end
    attrId = H5A.create(objId,attname,datatypeId,dataspaceId,acpl);
end
cattrId = onCleanup(@()H5A.close(attrId));

H5A.write(attrId,datatypeId,attvalue);







%--------------------------------------------------------------------------
function dataspace_id = createDataspaceId(attvalue)
% Setup the dataspace ID.  This just depends on how many elements the 
% attribute actually has.

if isempty(attvalue)
    dataspace_id = H5S.create('H5S_NULL');
    return;
elseif ischar(attvalue)
    if isrow(attvalue)
        dataspace_id = H5S.create('H5S_SCALAR');
        return
    else
        error(message('MATLAB:imagesci:h5writeatt:badStringSize'));
    end
else
    if ismatrix(attvalue) && ( any(size(attvalue) ==1) )
        rank = 1;
        dims = numel(attvalue);
    else
        % attribute is a "real" 2D value.		
        rank = ndims(attvalue);
	    dims = fliplr(size(attvalue));
    end
end
dataspace_id = H5S.create_simple(rank,dims,dims);



%--------------------------------------------------------------------------
function datatype_id = createDatatypeId ( attvalue, useUtf8 )
% We need to choose an appropriate HDF5 datatype based upon the attribute
% data.
switch class(attvalue)
	case 'double'
	    datatype_id = H5T.copy('H5T_NATIVE_DOUBLE');
	case 'single'
	    datatype_id = H5T.copy('H5T_NATIVE_FLOAT');
	case 'int64'
	    datatype_id = H5T.copy('H5T_NATIVE_LLONG');
	case 'uint64'
	    datatype_id = H5T.copy('H5T_NATIVE_ULLONG');
	case 'int32'
	    datatype_id = H5T.copy('H5T_NATIVE_INT');
	case 'uint32'
	    datatype_id = H5T.copy('H5T_NATIVE_UINT');
	case 'int16'
	    datatype_id = H5T.copy('H5T_NATIVE_SHORT');
	case 'uint16'
	    datatype_id = H5T.copy('H5T_NATIVE_USHORT');
	case 'int8'
	    datatype_id = H5T.copy('H5T_NATIVE_SCHAR');
	case 'uint8'
	    datatype_id = H5T.copy('H5T_NATIVE_UCHAR');
	case 'char'
	    datatype_id = H5T.copy('H5T_C_S1');
        if ~isempty(attvalue)
            % Don't do this when working with empty strings.
            H5T.set_size(datatype_id,numel(attvalue));
        end
        if useUtf8
            H5T.set_cset(datatype_id, H5ML.get_constant_value('H5T_CSET_UTF8'));
        end
		H5T.set_strpad(datatype_id,'H5T_STR_NULLTERM');
    otherwise
		error(message('MATLAB:imagesci:h5writeatt:unsupportedAttributeDatatype', class( attvalue )));
end
return

