function hdf5write(filename, varargin)
%HDF5WRITE  Write a Hierarchical Data Format version 5 file.
%    HDF5WRITE is not recommended.  Use H5WRITE instead.
%
%    HDF5WRITE(FILENAME, LOCATION, DATASET) adds the data in DATASET to
%    the HDF5 file named FILENAME.  LOCATION defines where to write the
%    DATASET in the file and resembles a Unix-style path.  The data in
%    DATASET is mapped to HDF5 datatypes using the rules below.
%
%    HDF5WRITE(FILENAME, DETAILS, DATASET) adds the DATASET to FILENAME
%    using the values in the DETAILS structure, which can contain the
%    following fields for a dataset:
%
%      Location     The location of the dataset in the file (char array).
%
%      Name         A name to attach to the dataset (char array).
%
%    HDF5WRITE(FILENAME, DETAILS, ATTRIBUTE) adds the metadata ATTRIBUTE
%    to FILENAME using the values in the DETAILS structure.  For
%    attributes the following fields are required:
%
%      AttachedTo   The location of the object this attribute modifies.
%
%      AttachType   A string that identifies what kind of object this
%                   attribute modifies.  Possible values are 'group'
%                   and 'dataset'.
%
%      Name         A name to attach to the dataset (char array).
%
%    HDF5WRITE(FILENAME, DETAILS1, DATASET1, DETAILS2, ATTRIBUTE1, ...)
%    provides a mechanism for writing multiple datasets and/or attributes
%    to FILENAME in one operation.  Each dataset and attribute must have
%    a DETAILS structure.
%
%    HDF5WRITE(FILENAME, ... , 'WriteMode', MODE, ...) specifies whether
%    writing to an existing file overwrites it (the default) or appends
%    datasets and attributes to the existing file.  Possible values for
%    MODE are 'overwrite' and 'append'.
%
%    HDF5WRITE(FILENAME, ... , 'V71Dimensions', BOOL, ...) specifies
%    whether to change the majority of datasets.  If BOOL is true, the
%    first two dimensions of each dataset are permuted.  This behavior
%    may not correctly reflect the intent of the data and may invalidate
%    metadata, but it is consistent with previous versions of HDF5WRITE
%    (MATLAB 7.1 [R14SP3] and earlier).  When BOOL is false (the
%    default), the data dimensions correctly reflect the data ordering as
%    it is written in the file.  Each dimension in the file's datasets
%    matches the same dimension in the corresponding MATLAB variable.
%
%
%    Data translation rules:
%
%    (1) If the data is numeric, the HDF5 dataset contains an appropriate
%        HDF5 native datatype and the size of the dataspace is the same
%        size as the array.
% 
%    (2) If the data is a string, the HDF5 file contains a single element
%        dataset, whose element is a null-terminated string. 
% 
%    (3) If the data is a cell array of strings, the HDF5 datatset or
%        attribute has an HDF5 string datatype.  The dataspace has the
%        same size as the cell array.  The string elements are 
%        null-terminated, but all share the same maximum length.
% 
%    (4) If the data is a cell array and all of the cells contain only
%        numeric data, the HDF5 datatype is an array.  The elements of
%        the array must be all numeric and have the same size and type.
%        The dataspace of the array has the same dimensions as the cell
%        array.  The datatype of the elements has the same dimensions as
%        the first element.
% 
%    (5) If the data is a structure array, the HDF5 datatype will be a
%        compound type.  Individual fields in the structure will employ
%        the same data translation rules for datatypes (e.g., cells
%        relate to strings or arrays, etc.).
% 
%    (6) If the data is composed of HDF5 objects, the HDF5 datatype will
%        correspond to the type of the object.
%        - For H5ENUM objects, the dataspace has the same dimensions
%          as the object's Data field.
%        - For all other objects, the dataspace has the same
%          dimensions as the array of HDF5 objects passed to the
%          function.
%
%
%    Examples:
%
%    % (A) Write a 5-by-5 dataset of UINT8 values to the root group.
%    hdf5write('myfile.h5', '/dataset1', uint8(magic(5)))
%
%    % (B) Write a 2-by-2 string dataset in a subgroup.
%    dataset = {'north', 'south'; 'east', 'west'};
%    hdf5write('myfile2.h5', '/group1/dataset1.1', dataset);
%
%    % (C) Write a dataset and attribute to an existing group.
%    dset = single(rand(10,10));
%    dset_details.Location = '/group1/dataset1.2';
%    dset_details.Name = 'Random';
%
%    attr = 'Some random data';
%    attr_details.Name = 'Description';
%    attr_details.AttachedTo = '/group1/dataset1.2/Random';
%    attr_details.AttachType = 'dataset';
%    
%    hdf5write('myfile2.h5', dset_details, dset, attr_details, attr, ...
%              'WriteMode', 'append');
%
%    % (D) Write a dataset using objects.
%    dset = hdf5.h5array(magic(5));
%    hdf5write('myfile3.h5', '/g1/objects', dset);
%
%    Please read the file hdf5copyright.txt for more information.
%
%    See also H5READ, H5WRITE, H5INFO, HDF5.


% Process input arguments.
validateattributes(filename,{'char'},{'nonempty'},'','FILENAME');

[details, dset_idx, args] = parse_inputs(varargin{:});

if (isempty(details))
    error(message('MATLAB:imagesci:deprecatedHDF5:missingData'))
end

% Verify the data.
if (args.verify)
    for p = 1:numel(dset_idx)
        verify_data(varargin{dset_idx(p)})
    end
end

% Call MEX implementation.
file.Filename = filename;
file.WriteMode = args.writemode;
file.V71Dimensions = args.v71dimensions;

hdf5writec(file, details, varargin{dset_idx});



function [details, dset_idx, args] = parse_inputs(varargin)
%PARSE_INPUTS   Parse the inputs.
%
%  Return values:
%  * details  - A cell array of structs containing dataset/attribute
%               info
%
%  * dset_idx - A vector of indices into varargin.  The value of the
%               nth element is the index of the nth dataset in varargin,
%               which corresponds to the nth element in details).
%
%  * args     - A structure of parameter value pairs.  The parameter name
%               is the field name of the structure.

details = {};
dset_idx = [];
dset_count = 0;

args.verify = true;
args.writemode = 'overwrite';
args.v71dimensions = false;

param_names = {'verify'
               'writemode'
               'v71dimensions'};

if (rem(nargin, 2) ~= 0)
    error(message('MATLAB:imagesci:deprecatedHDF5:argCount'))
end

% Look through the pairs
for p = 1:2:nargin
    
    % Is it a details struct?
    if (isstruct(varargin{p}))
        
        dset_count = dset_count + 1;
        details{dset_count} = process_details(varargin{p}); %#ok<AGROW>
        dset_idx(dset_count) = p + 1; %#ok<AGROW>
        
    % Is it a location or a param-value pair?
    elseif (ischar(varargin{p}))
        
        idx = find(strncmpi(varargin{p}, param_names,numel(varargin{p})));
        if (~isempty(idx))
            
            % Param-value pair.
            args(1).(param_names{idx(1)}) = varargin{p + 1};
            
        else
            
            % Location of dataset (not attribute).
            dset_count = dset_count + 1;
            
            tmp = new_dset_details;
            [tmp.Location, tmp.Name] = parse_location(varargin{p});
            details{dset_count} = tmp; %#ok<AGROW>
            
            dset_idx(dset_count) = p + 1; %#ok<AGROW>
            
        end
        
    else
        
        error(message('MATLAB:imagesci:deprecatedHDF5:argType'))
        
    end
    
end



function details = new_dset_details
%NEW_DSET_DETAILS   Create an empty dataset details struct.

details.Location = '';
details.Name = '';



function details = new_attr_details
%NEW_ATTR_DETAILS   Create an empty attribute details struct.

details.AttachedTo = '';
details.AttachType = '';
details.Name = '';



function proc_details = process_details(raw_details)
%PROCESS_DETAILS   Verify details structure and add missing fields.

raw_fields = fieldnames(raw_details);

% Create a new details structure with allowable fields.
if (~isempty(find(strcmpi('location', raw_fields), 1)))

    proc_details = new_dset_details;
    
elseif (~isempty(find(strcmpi(raw_fields,'attachedto'), 1)))

    if (isempty(find(strcmpi('attachtype', raw_fields), 1)))
        
        error(message('MATLAB:imagesci:deprecatedHDF5:missingAttachType'))
        
    end
    
    proc_details = new_attr_details;
    
else
    
    error(message('MATLAB:imagesci:deprecatedHDF5:detailsStruct'))
    
end

% Check for inappropriate fields.
proc_fields = fieldnames(proc_details);
if (~isempty(setdiff(lower(raw_fields), lower(proc_fields))))
    
    warning(message('MATLAB:imagesci:deprecatedHDF5:extraDetailFields'))
    
end

% Copy fields.
for p = 1:numel(raw_fields)
    
    idx = find(strncmpi(raw_fields{p}, proc_fields, numel(raw_fields{p})));
    
    if (~isempty(idx))
        proc_details.(proc_fields{idx(1)}) = raw_details.(raw_fields{p});
        
        if (isequal(proc_fields{idx(1)}, 'Location'))
            
            % Convert string Location and attached to cell arrays.
            [location, name] = ...
                parse_location(proc_details.(proc_fields{idx(1)}));
            
            if (~isempty(name))
                location{end + 1} = name; %#ok<AGROW>
            end
               
            proc_details.(proc_fields{idx(1)}) = location;
            
        end
        
    end
    
end



function verify_data(data)
%VERIFY_DATA   Verify that a dataset or attribute is well-formed.

switch ( class(data) )
case { 'uint8', 'int8', 'uint16', 'int16', 'uint32', 'int32', ...
       'uint64', 'int64', 'double', 'single', 'char' }

    % Numeric and char datasets are always okay.
    return

case 'cell'
    verify_cell_data(data);

case 'struct'
    verify_struct_data(data);

case { 'hdf5.h5compound', 'hdf5.h5array', 'hdf5.h5enum', 'hdf5.h5string', ...
       'hdf5.h5vlen' }
    % UDD datatypes are always ok
	return
otherwise
    error(message('MATLAB:imagesci:deprecatedHDF5:unknownDataClass', class( data )));
end



%-----------------------------------------------------------------------
function verify_struct_data(data)

fields = fieldnames(data);

for p = 1:numel(fields)
    
    class1 = class(data(1).(fields{p}));
    size1 = size(data(1).(fields{p}));
    
    for q = 1:numel(data)

		if iscell(data(q).(fields{p}))
            membersChar = cellfun(@validStructCell, data(q).(fields{p}));
            membersChar = membersChar(:);
            if ~all(membersChar);
                error(message('MATLAB:imagesci:deprecatedHDF5:cellInCompound'))
            end
		end
    
        
                  
        % Verify the same class for all members.
        if (~isequal(class(data(q).(fields{p})), class1))
            
            error(message('MATLAB:imagesci:deprecatedHDF5:inconsistentCompound'))
        
        end
    
        % Verify the same shape for all non-string members.
        if ((~ischar(data(q).(fields{p}))) && ...
            (~isequal(size(data(q).(fields{p})), size1)))
            
            error(message('MATLAB:imagesci:deprecatedHDF5:inconsistentCompound'))
        
        end
        
    end
    
end
    
    
%-----------------------------------------------------------------------
function verify_cell_data(data)

% Array datatypes must have the same type in each cell.
class1 = class(data{1});
size1 = size(data{1});

for p = 1:numel(data)

    % TO DO: Use diff id's/messages for shape and type
    
    % Verify the same class for all array elements.
    if (~isequal(class(data{p}), class1))
        error(message('MATLAB:imagesci:deprecatedHDF5:inconsistentArray'))
    end
    
    % Verify the same shape for all non-string arrays.
    if (~ischar(data{p})) && (~isequal(size(data{p}), size1))
        error(message('MATLAB:imagesci:deprecatedHDF5:inconsistentArray'))
    end
    
    % Verify subtypes.
    if (~isnumeric(data{p}))
        verify_data(data{p})
    end
    
end
    
%-----------------------------------------------------------------------
function [location, name] = parse_location(fullname)
%PARSE_LOCATION   Convert a location name into group and dataset parts.

idx = find(fullname == '/');

if (isempty(idx))
    
    location = {};
    name = fullname;

elseif (isequal(idx, 1))
    
    location = {};
    name = fullname(2:end);
    
else

    location = {};
    [T, R] = strtok(fullname, '/');
    while (~isempty(R))
        location{end + 1} = T;
        [T, R] = strtok(R, '/');
    end

    name = T;
    
end



function tf = validStructCell(entry)

% If the user provides a MATLAB structure with a cell array as a field, it
% must contain character arrays.  All other HDF5 datatypes should use HDF5
% objects (@hdf5) directly.
tf = ischar(entry);
