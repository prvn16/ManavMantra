function attval = h5readatt(Filename,Location,Attname,varargin)
%H5READATT Read attribute from HDF5 file.
%   ATTVAL = H5READATT(FILENAME,LOCATION,ATTR) retrieves the value for
%   named attribute ATTR from the given location, which can refer to either 
%   a group or a dataset.  LOCATION must be a full pathname.
%
%   Example:  Read a group attribute.
%       attval = h5readatt('example.h5','/','attr2');
%
%   Example:  Read a dataset attribute.
%       h5disp('example.h5','/g4/lon');
%       attval = h5readatt('example.h5','/g4/lon','units');
%
%   See also H5WRITEATT, H5DISP.

%   Copyright 2010-2015 The MathWorks, Inc.

p = inputParser;
p.addRequired('Filename', ...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','FILENAME'));
p.addRequired('Location', ...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','LOCATION'));
p.addRequired('Attname', ...
    @(x) validateattributes(x,{'char'},{'nonempty'},'','ATTR'));
p.parse(Filename,Location,Attname,varargin{:});
options = p.Results;

% Just use the defaults for now?
lapl = 'H5P_DEFAULT';

if Location(1) ~= '/'
    error(message('MATLAB:imagesci:h5readatt:notFullPathName'));
end

file_id = open_file(options.Filename);

try
    obj_id = H5O.open(file_id,options.Location,lapl);
catch me
    if H5L.exists(file_id,options.Location,lapl)
        rethrow(me);
    else
        error(message('MATLAB:imagesci:h5readatt:invalidLocation', options.Location));
    end
end


attr_id = H5A.open_name(obj_id,options.Attname);
raw_att_val = H5A.read(attr_id,'H5ML_DEFAULT');

% Read the datatype information and use that to possibly post-process
% the attribute data.
attr_type = H5A.get_type(attr_id);
attr_class = H5T.get_class(attr_type);

persistent H5T_ENUM H5T_OPAQUE H5T_STRING H5T_INTEGER H5T_FLOAT H5T_BITFIELD H5T_REFERENCE;
if isempty(H5T_ENUM)
    H5T_ENUM = H5ML.get_constant_value('H5T_ENUM');
    H5T_OPAQUE = H5ML.get_constant_value('H5T_OPAQUE');
    H5T_STRING = H5ML.get_constant_value('H5T_STRING');
    H5T_INTEGER = H5ML.get_constant_value('H5T_INTEGER');
    H5T_FLOAT = H5ML.get_constant_value('H5T_FLOAT');
    H5T_BITFIELD = H5ML.get_constant_value('H5T_BITFIELD');
    H5T_REFERENCE = H5ML.get_constant_value('H5T_REFERENCE');
end

if ((attr_class == H5T_INTEGER) || (attr_class == H5T_FLOAT) || (attr_class == H5T_BITFIELD))
    if isvector(raw_att_val)
        attval = reshape(raw_att_val,numel(raw_att_val),1);
    else
        attval = raw_att_val;
    end
    return
end

aspace = H5A.get_space(attr_id);

% Perform any necessary post processing on the attribute value.
switch (attr_class)
    
    case H5T_ENUM
        attval = h5postprocessenums(attr_type,aspace,raw_att_val);
      
    case H5T_OPAQUE
        attval = h5postprocessopaques(attr_type,aspace,raw_att_val);
        
    case H5T_STRING
        attval = h5postprocessstrings(attr_type,aspace,raw_att_val);
        
    case H5T_REFERENCE
        attval = h5postprocessreferences(attr_id,aspace,raw_att_val);
        
    otherwise
        attval = raw_att_val;
        
end



%---------------------------------------------------------------------------
function fid = open_file(filename)

% Try with the default driver, then the family driver, then the multi 
% driver, then the split driver.
try
    fid = H5F.open(filename,'H5F_ACC_RDONLY','H5P_DEFAULT');
catch me
    if filename(end)=='%'
        % If last character of file is the percent character, do not
        % attempt to open with family driver as this will crash MATLAB. 
        % See g1592049 and g1601684 for details
        rethrow(me);
    elseif strcmp(me.identifier,'MATLAB:imagesci:hdf5lib:fileOpenErr')
        fid = open_file_family(filename);
    else
        rethrow(me);
    end

end

return


%---------------------------------------------------------------------------
function fid = open_file_family(filename)

% Try with the family driver, then the multi driver, then the split driver.
fapl = H5P.create('H5P_FILE_ACCESS');
try
    H5P.set_fapl_family(fapl,0,'H5P_DEFAULT');
    fid = H5F.open(filename,'H5F_ACC_RDONLY',fapl);
catch me
    if strcmp(me.identifier,'MATLAB:imagesci:hdf5lib:fileOpenErr')
        % Family driver didn't work either, so try the multi driver.
        fid = open_file_multi(filename);
    else
        % Ran into some other problem using family driver.
        rethrow(me);
    end
end
            
H5P.close(fapl);
            
%---------------------------------------------------------------------------
function fid = open_file_multi(filename)

% Try with the multi driver, then the split driver.
fapl = H5P.create('H5P_FILE_ACCESS');
try
    H5P.set_fapl_multi(fapl,true);
    fid = H5F.open(filename,'H5F_ACC_RDONLY',fapl);
catch me
    if strcmp(me.identifier,'MATLAB:imagesci:hdf5lib:fileOpenErr')
        % Multi driver didn't work either, so try the split driver.
        fid = open_file_split(filename);
    else
        % Ran into some other problem using multi driver.
        rethrow(me);
    end
end
            
H5P.close(fapl);
            
%---------------------------------------------------------------------------
function fid = open_file_split(filename)

% Try with the split driver.  If this fails, we give up.
fapl = H5P.create('H5P_FILE_ACCESS');
try
    H5P.set_fapl_split(fapl,'-m.h5','H5P_DEFAULT','-r.h5','H5P_DEFAULT');
    fid = H5F.open(filename,'H5F_ACC_RDONLY',fapl);
catch me
    if strcmp(me.identifier,'MATLAB:imagesci:hdf5lib:libraryError')
        % Multi driver didn't work either, just trigger the original
        % exception.
        fid = H5F.open(filename,'H5F_ACC_RDONLY','H5P_DEFAULT');
    else
        % Ran into some other problem using split driver.
        rethrow(me);
    end
end
            
H5P.close(fapl);
            
