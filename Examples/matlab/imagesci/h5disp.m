function h5disp(filename,varargin)
%H5DISP  Display HDF5 metadata.
%
%   H5DISP(FILENAME) displays the entire HDF5 file's metadata.
%
%   H5DISP(FILENAME,LOCATION) displays the metadata for the specified
%   location. If LOCATION is a group, all objects below the group will be
%   described.
%
%   H5DISP(FILENAME,LOCATION,MODE) displays metadata according to the value 
%   of MODE.  LOCATION must be given as '/' to print metadata for the
%   entire file.  MODE may be one of the following strings:
%   
%       'min'     - minimal, print only group and dataset names
%       'simple' -  print full dataset metadata and print attribute values
%                   if the attribute is integer, floating point, or a
%                   scalar string.
%
%   H5DISP(__, 'Name', 'Value') displays metadata information about either
%   the entire HD5 file or for a specified location.
%
%   Name-Value Pairs
%   ----------------
%   'TextEncoding'  - Defines the character encoding to be used for
%                     interpreting the names of objects and attributes
%                     present in the HDF5 file. It takes values 'system' or
%                     'UTF-8'. Default value is 'system'. 
%
%   Example:
%       h5disp('example.h5');
%
%   Example:  Print metadata for just one data set.
%       h5disp('example.h5','/g4/world');
%
%   See also H5INFO.

%   Copyright 2010-2016 The MathWorks, Inc.

narginchk(1, 5);

options.Filename = filename;
switch(nargin)
    case 1
        options.Location = '/';
        options.Mode = 'simple';
        options.UseUtf8 = false;
        
    case 2
        options.Location = varargin{1};
        options.Mode = 'simple';
        options.UseUtf8 = false;
        
    case 3
        % This indicates that either of the following calls are possible:
        % h5disp(filename, location, mode) OR
        % h5disp(filename, 'Name', 'Value')
        % This logic needs to be revisited.
        try
            options.Location = '/';
            options.Mode = 'simple';
            options.UseUtf8 = matlab.io.internal.imagesci.h5ParseEncoding(varargin);
        catch ME
            if strcmpi(varargin{1}, 'TextEncoding')
               throw(ME);
            end
            options.Location = varargin{1};
            options.Mode = varargin{2};
            options.UseUtf8 = false;
        end
        
    case 4
        options.Location = varargin{1};
        options.Mode = 'simple';
        varargin = varargin(end-1:end);
        options.UseUtf8 = matlab.io.internal.imagesci.h5ParseEncoding(varargin);
        
    case 5
        options.Location = varargin{1};
        options.Mode = varargin{2};
        varargin = varargin(end-1:end);
        options.UseUtf8 = matlab.io.internal.imagesci.h5ParseEncoding(varargin);
end

if (nargin == 2) && (options.Location(1) ~= '/')
    error(message('MATLAB:imagesci:h5disp:notFullPathName'));
end

options.Mode = validatestring(options.Mode,{'simple','min'});
    
display_hdf5(options);



%--------------------------------------------------------------------------
function display_hdf5(options)

% 'context' has two fields.
%    mode - either 'min' or 'simple'
%    source - this clues a function in as to who called it.  Values include
%        'group', 'dataset', 'datatype', 'derived'.  
%        Behavior may change because of this.
%
% This function displays something like the following:
%
% HDF5 example.h5

context.mode = options.Mode;

if options.UseUtf8
    hinfo = h5info(options.Filename,options.Location, 'TextEncoding', 'UTF-8');
else
    hinfo = h5info(options.Filename,options.Location);
end

file_type_description = getString(message('MATLAB:imagesci:h5disp:fileType'));
% Is it a group?
if isfield(hinfo,'Groups')
    fid = hh5fopen(hinfo.Filename);
    c = onCleanup( @() H5F.close(fid) );
    %%% parse this out
    [~,name,ext] = fileparts(hinfo.Filename);
    fprintf('%s %s \n', file_type_description,[name ext] );
    display_group(hinfo,context,0,fid);
    
elseif isfield(hinfo,'Class')
    % A named datatype can only exist as a member of a group.
    [~,name,ext] = fileparts(hinfo.Filename);
    fprintf('%s %s \n', file_type_description,[name ext] );
    context.source = 'group';
    display_datatype(hinfo,context,0);
else
    % Dataset
    [~,name,ext] = fileparts(hinfo.Filename);
    fprintf('%s %s \n', file_type_description,[name ext] );
    context.source = 'dataset';
    display_dataset(hinfo,context,0);
end

return


    
%--------------------------------------------------------------------------
function display_group(group,context,level,loc_id)
%
% This function would display something like the following:
%
% Group '/g4'
%     Dataset 'lat'
%         Size:  19
%         MaxSize:  19
%         Datatype:   H5T_IEEE_F64LE (double)
%         ChunkSize:  []
%         Filters:  none
%         FillValue:  0.000000
%     Dataset 'lon'
%         Size:  36
%         MaxSize:  36
%         Datatype:   H5T_IEEE_F64LE (double)
%         ChunkSize:  []
%         Filters:  none
%         FillValue:  0.000000
%     Attributes: 


context.source = 'group';

group_type_label = getString(message('MATLAB:imagesci:h5disp:group'));
fprintf ('%s%s ''%s'' \n', hindent(level), group_type_label, group.Name);

if ~strcmp(context.mode,'min')
    display_attributes(group.Attributes,context,level+1)
end

gid = H5G.open(loc_id,group.Name);
c = onCleanup( @() H5G.close(gid) );

display_links(group.Links,context,level+1,gid);
display_named_datatypes(group.Datatypes,context,level+1);
display_datasets(group.Datasets,context,level+1);

display_child_groups(group.Groups,context,level+1,gid);



%--------------------------------------------------------------------------
function display_child_groups(groups,context,level,loc_id)

for j = 1:numel(groups)
    display_group(groups(j),context,level,loc_id);
end

%--------------------------------------------------------------------------
function display_links(links,context,level,loc_id)

for j = 1:numel(links)
    display_link(links(j),context,level,loc_id);
end

%--------------------------------------------------------------------------
function display_attributes(attributes,context,level)
%
% This function displays something like

% Attributes:
%     'units':  'degrees_east'
%     'CLASS':  'DIMENSION_SCALE'
%     'NAME':  'lon'


attr_type_label = getString(message('MATLAB:imagesci:h5disp:attribute'));
if numel(attributes) > 0
	fprintf('%s%s:\n', hindent(level), attr_type_label);
	for j = 1:numel(attributes)
	    display_attribute(attributes(j),context,level+1);
	end
end

%--------------------------------------------------------------------------
function display_named_datatypes(named_datatypes,context,level)

for j = 1:numel(named_datatypes)
    display_datatype(named_datatypes(j),context,level);
end

%--------------------------------------------------------------------------
function display_datasets(datasets,context,level)

for j = 1:numel(datasets)
    display_dataset(datasets(j),context,level);
end

%--------------------------------------------------------------------------
function display_link(link,context,level,loc_id)
%
% This function displays something like:
%
% Dataset 'dset3'
%     Type:      'hard link'
%     Target:    '/dset1'

link_label = getString(message('MATLAB:imagesci:h5disp:link'));
if strcmp(context.mode,'min')
    fprintf('%s%s ''%s''\n', hindent(level), link_label, link.Name);
    % We're done, the link name is sufficient.
    return;
end

type_label = getString(message('MATLAB:imagesci:h5disp:type'));
target_label = getString(message('MATLAB:imagesci:h5disp:target'));

switch(link.Type)
    case 'soft link'
        % Soft links can point to anything, even something that really
        % isn't there. 
        fprintf('%s%s:  ''%s''\n', hindent(level), link_label, link.Name);
        fprintf('%s%s:  ''%s''\n', hindent(level+1), type_label, link.Type);
        fprintf('%s%s:  ''%s''\n', hindent(level+1), target_label, link.Value{1});
        
    case 'external link'
        % External links point outside of the file.
        fprintf('%s%s:  ''%s''\n', hindent(level), link_label, link.Name);
        fprintf('%s%s:  ''%s''\n', hindent(level+1), type_label, link.Type);
        target_file_label = getString(message('MATLAB:imagesci:h5disp:targetFile'));
        target_object_label = getString(message('MATLAB:imagesci:h5disp:targetObject'));
        fprintf('%s%s:  ''%s''\n', hindent(level+1), target_file_label, link.Value{1});
        fprintf('%s%s:  ''%s''\n', hindent(level+1), target_object_label, link.Value{2});
        
    case 'hard link'
        % Hard links are always valid.
        obj_id = H5O.open(loc_id, link.Name, 'H5P_DEFAULT');
        c = onCleanup( @() H5O.close(obj_id) );
        info = H5O.get_info(obj_id);

        % info.type is an enum defined as follows
        % H5O_TYPE_UNKNOWN = -1,      Unknown object type                      
        % H5O_TYPE_GROUP,             Object is a group                        
        % H5O_TYPE_DATASET,           Object is a dataset                      
        % H5O_TYPE_NAMED_DATATYPE,    Object is a committed (named) datatype   
        % H5O_TYPE_NTYPES             Number of different object types 
        switch info.type
            case 0      % Object is a group
                obj_label = getString(message('MATLAB:imagesci:h5disp:group'));
            case 1      % Object is a dataset
                obj_label = getString(message('MATLAB:imagesci:h5disp:dataset'));
            case 2      % Object is a committed (named) datatype
                obj_label = getString(message('MATLAB:imagesci:h5disp:datatype'));
            otherwise   % Label it as simply an object
                obj_label = getString(message('MATLAB:imagesci:h5disp:object'));
        end
        fprintf('%s%s ''%s''\n', hindent(level), obj_label, link.Name);
        fprintf('%s%s:  ''%s''\n', hindent(level+1), type_label, link.Type);
        fprintf('%s%s:  ''%s''\n', hindent(level+1), target_label, link.Value{1});
        
    case 'user-defined link'
        % Do nothing.
end



%--------------------------------------------------------------------------
function display_attribute(attribute,~,level)
%%% use [] for null
fprintf('%s''%s'':  ', hindent(level), attribute.Name );

switch(attribute.Dataspace.Type)
    case 'null'
        switch(attribute.Datatype.Class)
            case 'H5T_STRING'
                fprintf('''''\n');
            otherwise
                fprintf('[]\n');
        end
        return
        
    case 'scalar'
        display_scalar_attribute_value(attribute);
                
    case 'simple'
        display_simple_attribute_value(attribute);
        
end
        
  



return


%--------------------------------------------------------------------------
function display_scalar_attribute_value(attribute)

switch(attribute.Datatype.Class)
    
    case {'H5T_BITFIELD', 'H5T_INTEGER'}
        fprintf('%d\n', attribute.Value);
        
    case 'H5T_ENUM'
        fprintf('%s\n', attribute.Value{1});
        
    case 'H5T_FLOAT'
        fprintf('%f\n', attribute.Value);
        
    case 'H5T_OPAQUE'
        
        % Just a 'single' opaque element means a vector of data,
        % which we can print.
        for j = 1:numel(attribute.Value{1})
            fprintf('%d ', attribute.Value(j));
        end
        fprintf('\n');
        
    case 'H5T_STRING'
        switch(class(attribute.Value))
            case 'char'
                fprintf('''%s''\n', attribute.Value);
            case 'cell'
                % Variable length string.  OK to print each value.
                fprintf('''%s''', attribute.Value{1});
                for j = 2:numel(attribute.Value)
                    fprintf(', ''%s''', attribute.Value{j});
                end
                fprintf('\n');
        end
        
    otherwise
        % Compound, reference, array, vlen
        if isempty(attribute.Datatype.Name)
            fprintf('''%s''\n', attribute.Datatype.Class);
        else
			desc = getString(message('MATLAB:imagesci:h5disp:userDefinedDatatype'));
            fprintf('%s ''%s''\n', desc, attribute.Datatype.Name);
        end
end

%--------------------------------------------------------------------------
function display_simple_attribute_value(attribute)

% The attribute dataspace has at least one extent, possibly more.
switch(attribute.Datatype.Class)
    case {'H5T_BITFIELD', 'H5T_INTEGER'}
        if isvector(attribute.Value)
            for j = 1:numel(attribute.Value)
                fprintf('%d ', attribute.Value(j));
            end
            fprintf('\n');
        else
            display_ndimensional_attribute(attribute);
        end
        
    case 'H5T_ENUM'
        if isvector(attribute.Value)
            fprintf('''%s''', attribute.Value{1});
            for j = 2:numel(attribute.Value)
                fprintf(', ''%s''', attribute.Value{j});
            end
            fprintf('\n');
        else
            display_ndimensional_attribute(attribute);
        end
        
        
    case 'H5T_FLOAT'
        if isvector(attribute.Value)
            for j = 1:numel(attribute.Value)
                fprintf('%f ', attribute.Value(j));
            end
            fprintf('\n');
        else
            display_ndimensional_attribute(attribute);
        end
        
        
    case 'H5T_OPAQUE'
        if numel(attribute.Value) == 1
            for j = 1:numel(attribute.Value{1})
                fprintf('%d ', attribute.Value(j));
            end
            fprintf('\n');
        elseif isvector(size(attribute.Value))
            % This means that the opaque attribute is mx1 or 1xm
            display_ndimensional_attribute(attribute,size(attribute.Value));
        else
            display_ndimensional_attribute(attribute);
        end
        
    case 'H5T_STRING'
         if (numel(attribute.Value) == 1) || isvector(attribute.Value)
             % We can print single value strings or string vectors.
             fprintf('''%s''', attribute.Value{1});
             for j = 2:numel(attribute.Value)
                 fprintf(', ''%s''', attribute.Value{j});
             end
             fprintf('\n');
         else
            display_ndimensional_attribute(attribute);
        end       
        
        
    otherwise
        % arrays, vlens, compounds, references
        if isempty(attribute.Datatype.Name)
            fprintf('%s\n', attribute.Datatype.Class);
        else
            fprintf('%s\n', attribute.Datatype.Name);
        end
        
end


%--------------------------------------------------------------------------
function display_ndimensional_attribute(attribute,sz)
% HDF5 allows for multi-dimensional attributes.  Rather than try to print
% these out in their entirety, we just print their matlab size and hdf5
% class.

if nargin == 1
    sz = size(attribute.Value);
end

fprintf('%d', size(attribute.Value,1));
for j = 2:ndims(attribute.Value)
    fprintf('x%d', sz(j));
end

fprintf(' %s\n', attribute.Datatype.Class);

%--------------------------------------------------------------------------
function display_bitfield_datatype(datatype,~,~)

desc = getString(message('MATLAB:imagesci:h5disp:uint',datatype.Size*8));
switch(datatype.Size)
    case {1, 2, 4, 8}
        fprintf('%s (%s)\n', datatype.Type, desc);
    otherwise
	    desc = getString(message('MATLAB:imagesci:h5disp:oddSizeBitfield',datatype.Size));
        fprintf('%s (%s)\n', datatype.Type, desc);
end

%--------------------------------------------------------------------------
function display_datatype(datatype,context,level) 


datatype_label = getString(message('MATLAB:imagesci:h5disp:datatype'));
if isempty(datatype.Name)   
    fprintf('%s%s:   ',hindent(level), datatype_label);
else
    switch(context.source)
        case 'group'
            % We have a named datatype object, so we should describe it in
            % full.  But first, remove the leading path from the name of 
            % the datatype.
            sep = strfind(datatype.Name,'/');
            fprintf('%s%s ''%s''', ...
                hindent(level), datatype_label, datatype.Name(sep(end)+1:end));
            
            if strcmp(context.mode,'min')
                % In minimal mode, we just display the name of the object.
                fprintf('\n');
                return;
            end
            
            % Not in minimal mode.  Prepare for the rest of the datatype
            % description.
            fprintf(':  ');
            
        case 'dataset'
            % The named datatype is described elsewhere in full, so just
            % refer to it by name. and we are done.
            fprintf('%s%s:  ''%s''\n', hindent(level), datatype_label, datatype.Name);
            return
    end

end

context.source = 'datatype';

display_datatype_by_class(datatype,context,level);

if numel(datatype.Attributes) > 0
    % Named datatype with attributes.
    display_attributes(datatype.Attributes,context,level+1);
end

return

%--------------------------------------------------------------------------
function display_datatype_by_class(datatype,context,level) 

switch(datatype.Class)
    case 'H5T_ARRAY'
        display_array_datatype(datatype,context,level+1);
        
    case 'H5T_BITFIELD'
        display_bitfield_datatype(datatype,context,level+1);
        
    case 'H5T_COMPOUND'
        display_datatype_compound(datatype,context,level+1);  
        
    case 'H5T_ENUM'
        display_datatype_enum(datatype,context,level+1);

    case 'H5T_FLOAT'
        display_floating_point_datatype(datatype); 
        
    case 'H5T_INTEGER'
        display_integer_datatype(datatype);         

    case 'H5T_OPAQUE'
        display_datatype_opaque(datatype,context,level+1);  
        
    case 'H5T_REFERENCE'
        display_datatype_reference(datatype,context,level+1);
        
    case 'H5T_STRING'
        display_datatype_string(datatype,context,level+1);

    case 'H5T_TIME'
        fprintf('H5T_TIME (unsupported)\n');
        
    case 'H5T_VLEN'
        display_datatype_vlen(datatype,context,level+1);
        
    otherwise
        error(message('MATLAB:imagesci:h5disp:unhandledClass', datatype.Class));

end

%--------------------------------------------------------------------------
function display_integer_datatype(datatype)
%
% This function displays something like the following:
%
%         Datatype:   H5T_STD_I32BE (int32)


switch(datatype.Type)
    case { 'H5T_STD_U64LE', 'H5T_STD_U64BE', ...
            'H5T_STD_U32LE', 'H5T_STD_U32BE', ...
            'H5T_STD_U16LE', 'H5T_STD_U16BE', ...
            'H5T_STD_U8LE', 'H5T_STD_U8BE' }
		uint_desc = getString(message('MATLAB:imagesci:h5disp:uint',datatype.Size*8));
        fprintf('%s (%s)\n', datatype.Type, uint_desc);
        
    case { 'H5T_STD_I64LE', 'H5T_STD_I64BE', ...
            'H5T_STD_I32LE', 'H5T_STD_I32BE', ...
            'H5T_STD_I16LE', 'H5T_STD_I16BE', ...
            'H5T_STD_I8LE', 'H5T_STD_I8BE' }
		int_desc = getString(message('MATLAB:imagesci:h5disp:int',datatype.Size*8));
        fprintf('%s (%s)\n', datatype.Type, int_desc);
        
    otherwise
        fprintf('%s\n', datatype.Type);
        
end
        
        
%--------------------------------------------------------------------------
function display_floating_point_datatype(datatype)
%
% This function displays something like the following:
%
%     Datatype:   H5T_IEEE_F64LE (double)


switch(datatype.Type)
    case { 'H5T_IEEE_F32BE', 'H5T_IEEE_F32LE' }
		desc = getString(message('MATLAB:imagesci:h5disp:single'));
        fprintf('%s (%s)\n', datatype.Type, desc);
        
    case { 'H5T_IEEE_F64BE', 'H5T_IEEE_F64LE' }
		desc = getString(message('MATLAB:imagesci:h5disp:double'));
        fprintf('%s (%s)\n', datatype.Type, desc);
        
    otherwise
        fprintf('%s\n', datatype.Type);
end
    
%--------------------------------------------------------------------------
function display_datatype_vlen(hinfo,context,level)
%
% This function displays something like the following:
%
%         Datatype:   H5T_VLEN
%            Base Type: H5T_IEEE_F32LE (single)



switch(context.source)
    case {'dataset', 'datatype', 'derived'}
        % We are in the middle of a line, no need to indent.
        
    otherwise
        fprintf('%s', hindent(level-1));
end

fprintf('%s\n', hinfo.Class);

desc = getString(message('MATLAB:imagesci:h5disp:baseType'));
fprintf('%s%s: ', hindent(level), desc);

context.source = 'derived';

display_datatype_by_class(hinfo.Type,context,level) 


%--------------------------------------------------------------------------
function display_datatype_opaque(hinfo,~,level)
%
% This function displays something like the following:
%
%     Datatype:   H5T_OPAQUE
%         Length: 1
%         Tag:  1-byte opaque type


fprintf('%s\n', hinfo.Class);

desc = getString(message('MATLAB:imagesci:h5disp:length'));
fprintf('%s%s: %d\n', hindent(level), desc, hinfo.Type.Length);

desc = getString(message('MATLAB:imagesci:h5disp:tag'));
fprintf('%s%s:  %s\n', hindent(level), desc, hinfo.Type.Tag);



%--------------------------------------------------------------------------
function display_datatype_enum(hinfo,~,level)
%
% This function displays something like the following:
%
%     Datatype:   H5T_ENUM
%         Base Type:  H5T_STD_I32LE
%         Member 'RED':  0
%         Member 'GREEN':  1


fprintf('%s\n', hinfo.Class);

desc = getString(message('MATLAB:imagesci:h5disp:baseType'));
fprintf('%s%s:  %s\n', hindent(level), desc, hinfo.Type.Type);

desc = getString(message('MATLAB:imagesci:h5disp:member'));
for j = 1:numel(hinfo.Type.Member)
    fprintf('%s%s ''%s'':  %d\n', ...
        hindent(level), desc, hinfo.Type.Member(j).Name, ...
        hinfo.Type.Member(j).Value);
end

return


%--------------------------------------------------------------------------
function display_datatype_compound(hinfo,context,level)
%
% This function displays something like the following:
%
%     Datatype:   H5T_COMPOUND
%         Member 'a':  H5T_STD_I8LE (int8)
%         Member 'b':  H5T_IEEE_F64LE (double)



switch(context.source)
    case {'dataset', 'datatype', 'derived'}
        % We are in the middle of a line, no need to indent.
        
    otherwise
        fprintf('%s', hindent(level-1));
end

desc = getString(message('MATLAB:imagesci:h5disp:h5tcompound'));
fprintf('%s\n', desc);
display_datatype_compound_members(hinfo.Type.Member,context,level);


%--------------------------------------------------------------------------
function display_datatype_compound_members(member,context,level)

context.source = 'derived';
member_desc = getString(message('MATLAB:imagesci:h5disp:member'));

for j = 1:numel(member)
    fprintf('%s%s ''%s'':  ', hindent(level), member_desc, member(j).Name);
    display_datatype_by_class(member(j).Datatype,context,level) 
end
    

%--------------------------------------------------------------------------
function display_datatype_reference(hinfo,~,~)
%
% This function displays something like the following:
%
%     Datatype:   H5T_REFERENCE


fprintf('%s\n', hinfo.Class);      

%--------------------------------------------------------------------------
function display_array_datatype(hinfo,context,level)
% This function displays something like the following:
%
%     Datatype:   H5T_ARRAY
%         Size: 3
%         Base Type:  H5T_STD_I32LE (int32)


switch(context.source)
    case {'dataset', 'datatype', 'derived'}
        % We are in the middle of a line, no need to indent.
        
    otherwise
        fprintf('%s', hindent(level-1));
end

desc = getString(message('MATLAB:imagesci:h5disp:h5tarray'));
fprintf('%s\n',desc);

desc = getString(message('MATLAB:imagesci:h5disp:size'));
fprintf('%s%s: ', hindent(level), desc);
fprintf('%d', hinfo.Type.Dims(1));
for j = 2:numel(hinfo.Type.Dims)
    fprintf('x%d',hinfo.Type.Dims(j));
end
fprintf('\n');

label = getString(message('MATLAB:imagesci:h5disp:baseType'));
fprintf('%s%s:  ', hindent(level), label);
switch(hinfo.Type.Datatype.Class)
    case 'H5T_ARRAY'
        display_array_datatype(hinfo.Type.Datatype,context,level+1);
        
    case 'H5T_BITFIELD'
        display_bitfield_datatype(hinfo.Type.Datatype,context,level+1);

    case 'H5T_COMPOUND'
        display_datatype_compound(hinfo.Type.Datatype,context,level+1); 
        
    case 'H5T_ENUM'
        display_datatype_enum(hinfo.Type.Datatype,context,level+1);     
        
    case 'H5T_INTEGER'
        display_integer_datatype(hinfo.Type.Datatype);
        
    case 'H5T_FLOAT'
        display_floating_point_datatype(hinfo.Type.Datatype);
        
    case 'H5T_REFERENCE'
        display_reference_datatype(hinfo.Type.Datatype,context,level+1);

    case 'H5T_OPAQUE'
        display_opaque_datatype(hinfo.Type.Datatype,context,level+1);
        
    case 'H5T_STRING'
        display_datatype_string(hinfo.Type.Datatype,context,level+1);

    case 'H5T_VLEN'
        display_datatype_vlen(hinfo.Type.Datatype,context,level+1);
        
    otherwise
        error(message('MATLAB:imagesci:h5disp:unhandledClass', hinfo.Type.Class));

        
end


%--------------------------------------------------------------------------
function display_datatype_string(hinfo,~,level)
% This function will display something like the example below:
%
%     Datatype:   H5T_STRING
%         String Length: 3
%         Padding: H5T_STR_NULLTERM
%         Character Set: H5T_CSET_ASCII
%         Character Type: H5T_C_S1


fprintf('%s\n', hinfo.Class);

% Variable length strings should be clearly designated.
if ischar(hinfo.Type.Length) && strcmp(hinfo.Type.Length,'H5T_VARIABLE')
	label = getString(message('MATLAB:imagesci:h5disp:stringLength', 'variable'));
else
	label = getString(message('MATLAB:imagesci:h5disp:stringLength', num2str(hinfo.Type.Length)));
end
fprintf('%s%s\n', hindent(level), label);

label = getString(message('MATLAB:imagesci:h5disp:padding'));
fprintf('%s%s: %s\n', hindent(level), label, hinfo.Type.Padding);

label = getString(message('MATLAB:imagesci:h5disp:characterSet'));
fprintf('%s%s: %s\n', hindent(level), label, hinfo.Type.CharacterSet);

label = getString(message('MATLAB:imagesci:h5disp:characterType'));
fprintf('%s%s: %s\n', hindent(level), label, hinfo.Type.CharacterType);



return


%--------------------------------------------------------------------------
function display_dataset(dataset,context,level)
% This function will display something like the example that follows below.
%
% Dataset 'lon'
%     Size:  36
%     MaxSize:  36
%     Datatype:   H5T_IEEE_F64LE (double)
%     ChunkSize:  []
%     Filters:  none
%     FillValue:  0.000000
%     Attributes:
%         'units':  'degrees_east'
%         'CLASS':  'DIMENSION_SCALE'
%         'NAME':  'lon'


context.source = 'dataset';

label = getString(message('MATLAB:imagesci:h5disp:dataset'));
fprintf('%s%s ''%s'' ', hindent(level), label, dataset.Name);

if strcmp(context.mode,'min')
    % We're done, the dataset name is sufficient.
    fprintf('\n');
    return
end

fprintf('\n');

display_dataspace(dataset.Dataspace,level+1);
display_datatype(dataset.Datatype,context,level+1);
display_chunking(dataset.ChunkSize,level+1);
display_filters(dataset.Filters,context,level+1);
display_fillvalue(dataset,context,level+1);

display_attributes(dataset.Attributes,context,level+1);


%--------------------------------------------------------------------------
function display_fillvalue(dinfo,~,level)
% Don't display anything if a fill value does not exist.  If it does exist
% and is numeric, display in full.  If it exists and is non-numeric, just
% indicate its presence.

if isempty(dinfo.FillValue)
    return
end

desc = getString(message('MATLAB:imagesci:h5disp:fillValue'));
fprintf('%s%s:  ', hindent(level), desc);
switch dinfo.Datatype.Class
    case {'H5T_ARRAY', 'H5T_COMPOUND', 'H5T_REFERENCE', 'H5T_VLEN'}
        fprintf('%s\n', dinfo.Datatype.Class);
        
    case 'H5T_ENUM'
        fprintf('''%s''\n', dinfo.FillValue);
        
    case 'H5T_FLOAT'
        fprintf('%f\n', dinfo.FillValue);
        
    case {'H5T_OPAQUE', 'H5T_BITFIELD', 'H5T_INTEGER'}
        fprintf('%d', dinfo.FillValue(1));
        for j = 2:numel(dinfo.FillValue)
            fprintf(' %d', dinfo.FillValue(j));
        end
        fprintf('\n');
        
    case 'H5T_STRING'
        if iscell(dinfo.FillValue)
            % It's a variable length string
            if numel(dinfo.FillValue) == 1
                fprintf('''%s''\n', dinfo.FillValue{1});
            else
                fprintf('%s\n', dinfo.Datatype.Class);
            end
        else
            fprintf('''%s''\n', dinfo.FillValue);
        end
        
    otherwise
        error(message('MATLAB:imagesci:h5disp:unhandledClass', dinfo.Datatype.Class));        

        
end
%--------------------------------------------------------------------------
function display_filters(Filters,~,level)
% This function will display something like the example that follows below.
%
%         Filters:  deflate(6)

    
desc = getString(message('MATLAB:imagesci:h5disp:filters'));
fprintf('%s%s:  ', hindent(level), desc);
if isempty(Filters)
    fprintf('none');
else
display_filter(Filters(1));
    for j = 2:numel(Filters)
        fprintf(', ');
        display_filter(Filters(j));
    end
end
fprintf('\n');


%--------------------------------------------------------------------------
function display_filter(Filter)

switch(Filter.Name)
    case 'deflate'
		deflate_desc = getString(message('MATLAB:imagesci:h5disp:deflate',Filter.Data));
        fprintf(deflate_desc)
    case {'shuffle', 'fletcher32', 'nbit', 'szip'}
        fprintf('%s', Filter.Name)
    case 'scaleoffset'
		scaleoffset_desc = getString(message('MATLAB:imagesci:h5disp:scaleOffset',Filter.Data(1)));
        fprintf(scaleoffset_desc);
    otherwise
		unrecognized_filter = getString(message('MATLAB:imagesci:h5disp:unrecognizedFilter',Filter.Name));
        fprintf(unrecognized_filter);
end

%--------------------------------------------------------------------------
function display_chunking(ChunkSize,level)
% This function will display something like the example that follows below.
%
%         ChunkSize:  5000x1


label = getString(message('MATLAB:imagesci:h5disp:chunkSize'));
fprintf('%s%s:  ', hindent(level), label);
if isempty(ChunkSize)
    fprintf('[]');
else
    fprintf('%d', ChunkSize(1));
    for j = 2:numel(ChunkSize)
        fprintf('x%d',ChunkSize(j));
    end
end
fprintf('\n');


%--------------------------------------------------------------------------
function display_dataspace(dataspace,level)
% This function will display something like the example that follows below.
%
%        Size:  4x1
%        MaxSize:  InfxInf

size_label = getString(message('MATLAB:imagesci:h5disp:size'));
maxsize_label = getString(message('MATLAB:imagesci:h5disp:maxSize'));
validatestring(dataspace.Type,{'scalar','null','simple'});
if strcmp(dataspace.Type,'simple')
    fprintf('%s%s:  ', hindent(level), size_label);
    display_size(dataspace.Size);
    fprintf('\n');
    fprintf('%s%s:  ', hindent(level), maxsize_label);
    display_size(dataspace.MaxSize);
    fprintf('\n');
else
    fprintf('%s%s:  %s\n', hindent(level), size_label, dataspace.Type);
end

%--------------------------------------------------------------------------
function display_size(Size)

fprintf('%d', Size(1));
for j = 2:numel(Size)
    fprintf('x%d',Size(j));
end



%--------------------------------------------------------------------------
function indent = hindent(level)
% Create an indentation amount specific to the depth level.
indent = blanks(level*4);
return;

%--------------------------------------------------------------------------
function fid = hh5fopen(filename)
% Performs a more resilient attempt to open a file. If the default fapl
% does not work, try the others. This routine is almost identical to the
% ones used by h5infoc and h5readc

% First try the default
try
    fid = H5F.open(filename);
    % If this works, then return
    return;
catch ME
end

% Try the family file driver
try 
    fapl = H5P.create('H5P_FILE_ACCESS');
    H5P.set_fapl_family(fapl, 0, 'H5P_DEFAULT');
    fid = H5F.open(filename, 'H5F_ACC_RDONLY', fapl);
    
    % If it works, then the family driver is good enough
    H5P.close(fapl);
    return;
catch 
end

% Try the multi file driver
try 
    H5P.close(fapl);
    fapl = H5P.create('H5P_FILE_ACCESS');
    H5P.set_fapl_multi(fapl, true);
    fid = H5F.open(filename, 'H5F_ACC_RDONLY', fapl);
    
    H5P.close(fapl);
    return;
catch
end

rethrow(ME);

