%NC NetCDF object
%
%   THIS CLASS IS MEANT FOR INTERNAL USE. INTERFACE MAY CHANGE IN FUTURE
%   RELEASES.
%
%   OBJ = NC(FILENAME) Create a read-only NetCDF object from FILENAME.
%
%   OBJ = NC(FILENAME, MODE) Create a NetCDF object with specified mode.
%   MODE can be one of:
%
%         'r'   Open FILENAME in read-only mode. (Default).
%         'a'   Open or create FILENAME for writing; keep existing content.
%         'w'   Open FILENAME for writing; discard existing content.
%
%   OBJ = NC(FILENAME, MODE, FORMATSTR) Create a NetCDF object with
%   specified NetCDF format when MODE is either 'a' or 'w' and FILENAME
%   file does not exist. FORMATSTR can be one of:
%
%         'classic'         NetCDF 3.
%         '64BIT'           NetCDF 3 with 64-bit offsets.
%         'netcdf4_classic' NetCDF4 classic model. (Default)
%         'netcdf4'         NetCDF4 model. Use this to enable group
%                           hierarchy.
%
%   NC Properties:
%       Filename         - NetCDF file name.
%       Mode             - Source open mode.
%       Format           - NetCDF format.
%       DisplayMode      - Amount of information displayed by disp().
%
%   NC Methods:
%       read             - Read data and attribute(s).
%       readAttribute    - Read an attribute value.
%       write            - Write data to a variable.
%       writeAttribute   - Write an attribute value.
%       info             - Obtain information structure.
%       setConventions   - Control attribute conventions applied.
%
%       createDimensions - Create NetCDF dimension(s).
%       createVariable   - Create a NetCDF variable.
%       writeSchema      - Add NetCDF definitions to file.
%
%   NC Display methods:
%       disp             - Display the NetCDF source.
%       setDisplayMode   - Control the amount of information displayed.
%

%   Copyright 2010-2017 The MathWorks, Inc.

classdef nc < handle
    
    
    
    %======================================================================
    %Public properties
    properties(SetAccess=protected)
        
        %Filename - Name of the NetCDF source.
        %
        Filename = '';                %The NetCDF data source
        
        %Mode - Read, Append or Write mode.
        Mode     = 'r';               %default source open Mode
        
        %Format - Format of the NetCDF source.
        %
        Format   = '';                %default NetCDF Format
        
        %DisplayMode - Control the amount of information displayed by the
        %disp method. Use setDisplayMode to change this value.
        %
        DisplayMode = 'full';      %defines amount of info to display
        
    end
    
    %======================================================================
    %Hidden properties
    properties(Hidden=true, SetAccess=protected)
        
        ncRootid       = [];     %ncid for '/' of a source.
        defineMode     = [];     %define mode flag.
        
        %Conventions - Control the application of attribute conventions to
        %the data. Use setConventions to change this value.
        Conventions = 'default';
        
    end
    
    %======================================================================
    % Public functions
    methods
        
        % File
        %------------------------------------------------------------------
        function this = nc(varargin)
            %NC(Filename)
            %NC(Filename, MODE)
            %NC(Filename, MODE, FORMAT)
            
            %Parse varagin - Filename, Mode, Format (optional)
            narginchk(1,3);
            
            this.Filename   = varargin{1};
            if(nargin==2)
                this.Mode   = varargin{2};
            elseif(nargin==3)
                this.Mode   = varargin{2};
                this.Format = varargin{3};
            end
            
            %Verify Format values
            if(~any(strcmpi(this.Format, ...
                    {'classic','netcdf4_classic','netcdf4','64bit',''})))
                error(message('MATLAB:imagesci:netcdf:badFormat', this.Format));
            end
            this.Format = lower(this.Format);
            
            %Verify mode and set this.ncRootid
            switch(this.Mode)
                case 'r'
                    this.openToRead();
                case 'a'
                    this.openToAppend();
                case 'w'
                    this.openToWrite();
                otherwise
                    error(message('MATLAB:imagesci:netcdf:badMode'));
            end
            
        end
        %------------------------------------------------------------------
        function delete(this)            
            % This is the object destructor.
            this.close();
        end
        %------------------------------------------------------------------
        function close(this)
            if(this.ncRootid~=-1)
                netcdf.close(this.ncRootid);
                % Prevent the close call from the destructor from
                % attempting to call netcdf.close again in case close is
                % called manually.
                this.ncRootid = -1;
            end
        end
        
        
        % Attributes
        %------------------------------------------------------------------
        function attValue = readAttribute(this, location, attName)
            %readAttribute Read an attribute value from a NetCDF file.
            %
            %    ATTVALUE = readAttribute(LOCATION, ATTNAME) reads the
            %    attribute ATTNAME from the group or variable specified by
            %    the string LOCATION. To read global attributes set
            %    LOCATION to '/'.
            %
            %    Example: Read a global attribute.
            %      ncObj         = nc('example.nc');
            %      creation_date = ncObj.readAttribute('/','creation_date');
            %      disp(creation_date);
            %      ncObj.close();
            %
            %    Example: Read a variable attribute.
            %      ncObj        = nc('example.nc');
            %      scale_factor = ncObj.readAttribute('temperature','scale_factor');
            %      disp(scale_factor);
            %      ncObj.close();
            %
            %    See also disp, writeAttribute
            %
            
            [gid, varid] = this.getGroupAndVarid(location);
            attValue    = netcdf.getAtt(gid, varid, attName);
            
        end
        %------------------------------------------------------------------
        function writeAttribute(this, location, attName, attValue)
            %writeAttribute Write an attribute to a NetCDF file.
            %
            %    writeAttribute(LOCATION, ATTNAME, ATTVALUE) create or
            %    modify an attribute ATTNAME in the group or variable
            %    specified by LOCATION. To specify global attributes, set
            %    LOCATION to '/'. ATTVALUE can be a numeric vector or a
            %    string.
            %
            %
            %    Example: Create a global attribute.
            %      ncObj  = nc('myfile.nc','w');
            %      disp(ncObj);
            %      ncObj.writeAttribute('/','creation_date',datestr(now));
            %      disp(ncObj);
            %      ncObj.close();
            %
            %    Example: Create a variable attribute and then modify it.
            %      ncObj  = nc('myfile.nc','w');
            %      disp(ncObj);
            %      ncObj.write('pi',pi);
            %      ncObj.writeAttribute('pi','description','Value of pi');
            %      disp(ncObj);
            %      ncObj.writeAttribute('pi','description','Three point one four');
            %      disp(ncObj);
            %
            %    See also disp, readAttribute
            %
            
            [gid, varid] = this.getGroupAndVarid(location);
            
            %Enter define mode in case this attribute does not already
            %exist.
            this.setDefineMode(gid, true);
            
            netcdf.putAtt(gid, varid, attName, attValue);
        end
        
        
        % Creation
        %------------------------------------------------------------------
        function createDimensions(this, location, dimensions)
            % createDimensions Create specified dimensions.
            %
            % createDimensions(LOCATION, DIMENSIONS)creates specified
            % dimensions in the specified LOCATION. LOCATION can be '/' or
            % a group name. DIMENSIONS is a cell array specifying the
            % NetCDF dimension name and length in this form {NAMESTR1,
            % LENGTHNUM1, ..., NAMESTRN, LENGTHNUMN}, where N is the number
            % of desired dimensions . 
            %
            % Use inf as the dimension length to create an unlimited
            % dimension.
            %
            % Use a fully qualified dimension name to override location.
            %
            
            %Get the group id. Create intermediate groups if required.
            gid = this.getgid(location,true);            
            
            [dimNames, dimLengths] = ...
                internal.matlab.imagesci.nc.parseDimAndLength(dimensions);
            
            %Create one dimension at a time.
            for dInd = 1:length(dimNames)
                [path, dimName] = internal.matlab.imagesci.nc.parseDimLocation(dimNames{dInd});
                
                if(~isempty(path))
                    % The dimension name contains a path, override location
                    defgid = this.getgid(path, true);
                else
                    defgid = gid;
                end
                this.createDimension(defgid, ...
                    dimName, dimLengths{dInd});
            end
            
            
        end
        %------------------------------------------------------------------
        function createVariable(this, varargin)
            %    CREATE(VARNAME) creates a scalar variable VARNAME. To
            %    create non-scalar variables, use the 'Dimensions'
            %    parameter.
            %
            %    Variable creation options:
            %
            %    'Dimensions' DIMENSIONS is a cell array specifying NetCDF
            %                 dimensions for the variable. DIMENSIONS is a
            %                 cell array which lists the dimension name as
            %                 a string followed by the required numerical
            %                 length. If the dimension exists, the
            %                 corresponding length is optional. Use Inf to
            %                 specify an unlimited dimension.
            %
            %                 Note 1: All formats other than netcdf4 format
            %                 files can have only one unlimited dimension
            %                 per file and it has to be the last in the
            %                 list specified. A netcdf4 format file can
            %                 have any number of unlimited dimensions in
            %                 any order. Note 2: A single dimension
            %                 variable is always treated as a column
            %                 vector.
            %
            %    'Datatype'   TYPE. The datatype of the NetCDF variable.
            %                    TYPE               NetCDF variable type
            %                    'double'           'NC_DOUBLE'
            %                    'single'           'NC_FLOAT'
            %                    'int64'            'NC_INT64'*
            %                    'uint64'           'NC_UINT64'*
            %                    'int32'            'NC_INT'
            %                    'uint32'           'NC_UINT'*
            %                    'int16'            'NC_SHORT'
            %                    'uint16'           'NC_USHORT'*
            %                    'int8'             'NC_BYTE'
            %                    'uint8'            'NC_UBYTE'*
            %                    'char'             'NC_CHAR'
            %                 * These datatypes are only available when the
            %                 file is a netcdf4 format file.
            %
            %
            %    Optional creation parameters (netcdf4 or netcdf4_classic
            %    format only)
            %
            %    'FillValue'    FILLVALUE, A scalar with the same datatype
            %                   as the variable, specifying the fill value
            %                   for unwritten data. If omitted, a default
            %                   value is chosen by the NetCDF library.To
            %                   disable fill values, set FILLVALUE to
            %                   'disable'.
            %
            %    'ChunkSize'    [NUM_ROWS, NUM_COLS, ..., NUM_NDIMS]
            %                   specifies the chunk size along each
            %                   dimension. The default chunk size is set by
            %                   the NetCDF library.
            %
            %    'DeflateLevel' LEVEL, A numeric value specifying the
            %                   compression setting for the deflate filter.
            %                   Value should be between 0 (least) and 9
            %                   (most). Compression is disabled by default.
            %
            %    'Shuffle'      SHUFFLEFLAG, A boolean flag to turn on the
            %                   Shuffle filter. The default is false.
            %
            %
            
            narginchk(1,14);
            
            %This can contain groups (fully qualified path) in netcdf4.
            fullVarName = varargin{1};
            
            %Parse any PV's given for variable creation.
            p = inputParser;
            p.addParamValue('Dimensions',{});
            p.addParamValue('Datatype','double',@(x)ischar(x));
            p.addParamValue('FillValue','NA',...
                @(f) ...
                isempty(f) || ...            % from ncwriteschema
                strcmpi(f,'NA') || ...       % library default.
                strcmpi(f,'disable') || ...  % nofillMode == true.
                isscalar(f) );               % custom fill value.
            p.addParamValue('ChunkSize',[],@(x)isnumeric(x));
            p.addParamValue('DeflateLevel',[],...
                @(x) isempty(x) || ( (x>=0 && x<=9) && isscalar(x) ) );
            p.addParamValue('Shuffle',false,...
                @(x) isempty(x) || ( islogical(x) && isscalar(x) ) );
            
            p.parse(varargin{2:end});
            result = p.Results;
            
            dimensions   = result.Dimensions;
            datatype     = result.Datatype;
            fillValue    = result.FillValue;
            chunkSize    = result.ChunkSize;
            deflateLevel = result.DeflateLevel;
            Shuffle      = result.Shuffle;
            
            
            % If this file is not a netcdf4 file
            if(~strcmpi(this.Format,'netcdf4'))
                % Then we do not support creating some datatypes.
                switch datatype
                    case {'int64','uint64','uint32','uint16','uint8'}
                        error(message('MATLAB:imagesci:netcdf:unSupportedDatatype', datatype, this.Format));
                    otherwise
                        % all ok
                end
            end
            
            
            % Obtain the variable name from given location.
            [groupName, varName] = ...
                internal.matlab.imagesci.nc.parsePath(fullVarName);
            if(isempty(varName))
                error(message('MATLAB:imagesci:netcdf:badVarName', fullVarName));
            end
            
            % Create intermediate groups if required.
            gid = this.getgid(groupName,true);
            
            
            if(this.isVariable(fullVarName))
                %Variable exists. Warn and return.
                warning(message('MATLAB:imagesci:netcdf:varExists', fullVarName));
                return;
            end
            
            % Enter define mode.
            this.setDefineMode(gid, true);
            
            % Create the specified dimensions if required.
            this.createDimensions(groupName, dimensions);
            
            % Obtain the dimension names.
            dimNames = ...
                internal.matlab.imagesci.nc.parseDimAndLength(dimensions);            
            
            % Obtain all the dimids (could be [] if dimNames = {}). All
            % required dimensions have been created at this point.
            dimids = zeros(size(dimNames));
            for dimInd = 1:length(dimNames)
                [~ , dimName] = ...
                    internal.matlab.imagesci.nc.parseDimLocation(dimNames{dimInd});
                dimids(dimInd) = netcdf.inqDimID(gid, dimName);
            end
            
            % Obtain the equivalent NetCDF data type to create.
            xType = internal.matlab.imagesci.nc.dataClasstoxType(datatype);
            
            % Create the variable.
            varid = netcdf.defVar(gid, varName, xType, dimids);
            
            
            if(this.isHDF5Based())
                
                % Set chunkSize if given.
                if(~isempty(chunkSize))
                    
                    varInfo = this.info(fullVarName);
                    
                    % ChunkSize rank should match variable's.
                    if(numel(varInfo.Dimensions) ~= numel(chunkSize))
                        error(message('MATLAB:imagesci:netcdf:invalidChunkParameter',...
                            numel(chunkSize),numel(varInfo.Dimensions)));
                    end
                    
                    % ChunkSize > Variable extents results in corrupted
                    % files.
                    
                    variableExtents = [varInfo.Dimensions.Length];
                    nonZeroDimInd = variableExtents ~=0;                    
                    if(any(chunkSize(nonZeroDimInd)> variableExtents(nonZeroDimInd)))
                        error(message('MATLAB:imagesci:netcdf:badChunkSize'));
                    end
                    netcdf.defVarChunking(gid, varid, 'CHUNKED', chunkSize);
                end
                
                % Set deflate and shuffle if asked to.
                if(isempty(deflateLevel))
                    netcdf.defVarDeflate(gid, varid, Shuffle,...
                        false, []);
                else
                    netcdf.defVarDeflate(gid, varid, Shuffle,...
                        true, deflateLevel);
                end
                
                
                % Disable fill values if explicitly asked 
                if(strcmpi(fillValue, 'disable'))
                    
                    netcdf.defVarFill(gid, varid, true,[]);
                    
                elseif(~(strcmpi(fillValue,'NA') || isempty(fillValue)))
                    % A value was given by the user
                    
                    
                    % fillValue is expected to be the same data type as the
                    % variable. Else, the low-level will error out.
                    netcdf.defVarFill(gid, varid, false,fillValue);
                    
                % else (i.e 'NA' or empty, user did not specify a fill
                % value)
                %
                %   go with library default.
                %
                
                end
                
            else
                % classic or 64 bit format. We do not support these
                % options.
                
                if(~isempty(chunkSize))
                    warning(message('MATLAB:imagesci:netcdf:chunkNotSupported', this.Format));
                end
                if(~(strcmpi(fillValue,'NA') || isempty(fillValue)))
                    warning(message('MATLAB:imagesci:netcdf:fillNotSupported', this.Format));
                end
                if(~isempty(deflateLevel))
                    warning(message('MATLAB:imagesci:netcdf:deflateNotSupported', this.Format));
                end
                if(Shuffle)
                    warning(message('MATLAB:imagesci:netcdf:shuffleNotSupported', this.Format));
                end                
                
            end
            
        end
        
        
        % Schema
        %------------------------------------------------------------------
        function writeSchema(this, schema)
            % writeSchema(SCHEMASTRUCT)
            
            if(~isfield(schema,'Name') || ...
                    all( cellfun(@isempty,{schema.Name})) )
                error(message('MATLAB:imagesci:netcdf:badSchemaStruct'))
            end
            
            
            % Decide what kind of schema was given based on existing field
            % name.
            if(isfield(schema,'Datatype'))
                this.writeVariableSchema(schema);
            elseif(isfield(schema, 'Length'))
                this.writeDimensionSchema(schema);
            else
                this.writeGroupSchema(schema);
            end
        end
        
        
        
        % Variables
        %------------------------------------------------------------------
        function setConventions(this, conventions)
            % setConventions(CONVSTR) Set the data read conventions to
            % CONSTR. Valid values are:
            %
            %     'default' The read and write methods will honor the
            %               '_FillValue', 'scale_factor' and 'add_offset'
            %               attribute if defined for a variable.
            %     'none'    Data will not be modified.
            %
            if(~strcmpi(conventions,'default') && ...
                    ~strcmpi(conventions,'none'))
                error(message('MATLAB:imagesci:netcdf:setConventions', conventions));
            end
            this.Conventions  = conventions;
        end
        %------------------------------------------------------------------
        function data = read(this,location, start, count, stride)
            %READ Read data from a variable in a NetCDF file.
            %
            %    VARDATA = READ(VARNAME) reads data from the variable
            %    VARNAME.
            %
            %    VARDATA = READ(VARNAME, START, COUNT)
            %    VARDATA = READ(VARNAME, START, COUNT, STRIDE) reads part
            %    of the data from variable VARNAME. For an N-dimensional
            %    variable VARNAME, START in an N element vector of 1-based
            %    indices. COUNT is also an N element vector specifying the
            %    number of elements to read along the corresponding
            %    dimension. Use Inf to read data till the end of that
            %    dimension. STRIDE is an N element vector specifying the
            %    inter-element spacing along each dimension. STRIDE
            %    defaults to a vector of ones.
            %
            %    Attribute conventions are applied depending on the
            %    Conventions property. See setConventions for more details.
            %
            
            switch nargin
                
                case 3 % (this, location, start) - count is missing.
                    error(message('MATLAB:imagesci:validate:wrongNumberOfInputs'));
                case 4 % (this, location, start, count)
                    stride = ones(size(start));
                    validateattributes(start,{'numeric'},...
                        {'nonempty','positive','integer','vector'},...
                        'ncread',...
                        'start');
                    % count need not be an integer (can be Inf).
                    validateattributes(count,{'numeric'},...
                        {'nonempty','positive','vector'},...
                        'ncread',...
                        'count');
                    
                    start = start-1; %low-level is zero-based.
                    
                    
                case 5 % (this, location, start, count, stride)
                    validateattributes(start,{'numeric'},...
                        {'nonempty','positive','integer','vector'},...
                        'ncread',...
                        'start');
                    validateattributes(count,{'numeric'},...
                        {'nonempty','positive','vector'},...
                        'ncread',...
                        'count');                    
                    validateattributes(stride,{'numeric'},...
                        {'nonempty','positive','integer','vector'},...
                        'ncread',...
                        'stride');   
                    
                    start = start-1; %low-level is zero-based.
                    
                otherwise
                    start  = [];
                    count  = [];
                    stride = [];
                    
            end
            
            [gid, varid] = getGroupAndVarid(this, location);
            
            if(varid==-1)
                % It is a group.
                error(message('MATLAB:imagesci:netcdf:notAVariable', location));
            end
            
            % It is a variable
            vinfo  = this.varInfo(gid, varid);            
            
            if(isempty(start))
                % Read all data.
                data = netcdf.getVar(gid, varid);
                
            else
                % start, stride (possibly a default) and count have values.

                % Ensure lengths match before we try to replace Inf in
                % count.
                if(length(start) ~= length(vinfo.Size))
                    error(message('MATLAB:imagesci:netcdf:indexElementLength', 'START', length( start ), length( vinfo.Size )));
                end
                if(length(count) ~= length(vinfo.Size))
                    error(message('MATLAB:imagesci:netcdf:indexElementLength', 'COUNT', length( count ), length( vinfo.Size )));
                end
                if(length(stride) ~= length(vinfo.Size))
                    error(message('MATLAB:imagesci:netcdf:indexElementLength', 'STRIDE', length( stride ), length( vinfo.Size )));
                end                
                
                % Replace Inf with max count possible. Start is already
                % zero-based.
                infInd = isinf(count);
                if(any(infInd))
                    count(infInd) = ceil( ...
                        (  vinfo.Size(infInd) - start(infInd)  )...
                        ./ stride(infInd)...
                        );
                end
                
                % Rely on low-level to throw an exception for out of bound
                % indices
                
                data  = netcdf.getVar(gid, varid, ...
                    start, count, stride);
            end
            
            if strcmpi(vinfo.Datatype,'char') 
                % return data as-is, no attribute conventions for char
                % data.
                return;
            end
            
            if(strcmpi(this.Conventions,'default'))
                % Apply advertised attribute conventions.
                
                % Replace fill values with NaNs
                try
                    fillValue = netcdf.getAtt(gid,varid,'_FillValue');
                    data = double(data);
                    % No-op if types of data & fillValue are different
                    if isnumeric(data)==isnumeric(fillValue)
                        % Still try to apply fillValue to variable when
                        % they are different numeric data types
                        data(data==fillValue) = NaN;
                    else
                        warning(message('MATLAB:imagesci:netcdf:fillValueTypeMismatch',location));
                    end
                    
                catch me
                    % Just go on if the attribute is not present.
                    if ~strcmp(me.identifier,'MATLAB:imagesci:netcdf:libraryFailure')
                        rethrow(me);
                    end
                end
                
                % Apply scale factor if present
                try
                    scale_factor = netcdf.getAtt(gid,varid,'scale_factor');
                    data         = double(data) .* double(scale_factor);
                catch me
                    % Just go on if the attribute is not present.
                    if ~strcmp(me.identifier,'MATLAB:imagesci:netcdf:libraryFailure')
                        rethrow(me);
                    end
                end
                
                % Apply add offset if present
                try
                    add_offset = netcdf.getAtt(gid,varid,'add_offset');
                    data = double(data) + double(add_offset);
                catch me
                    % Just go on if the attribute is not present.
                    if ~strcmp(me.identifier,'MATLAB:imagesci:netcdf:libraryFailure')
                        rethrow(me);
                    end
                end
            end          
        end
        
        %------------------------------------------------------------------
        function write(this, fullVarName, varData, start, stride)
            %WRITE Write data to a NetCDF file.
            %
            %    WRITE(VARNAME, VARDATA) write VARDATA to an existing
            %    variable VARNAME.
            %
            %    WRITE supports the following syntax to write partial data
            %    to an existing variable:
            %
            %    WRITE(VARNAME, VARDATA, START)
            %    WRITE(VARNAME, VARDATA, START, STRIDE)            
            %     writes VARDATA to an existing variable VARNAME in file
            %     NCFILENAME beginning at the location given by START. For
            %     an N-dimensional variable START is a vector of 1-based
            %     indices of length N specifying the starting location. The
            %     optional argument STRIDE, also of length N,  specifies
            %     the inter-element spacing. STRIDE defaults to a vector of
            %     ones. Use this syntax to append data to an existing
            %     variable or write partial data.
            %
            %    WRITE also supports all variable creation options of
            %    createVariable.
            %
            %
            
            
            %Obtain the group name and its id from the fully qualified path
            %to varName.
            [groupName, varName] = ...
                internal.matlab.imagesci.nc.parsePath(fullVarName);
            if(isempty(varName))
                error(message('MATLAB:imagesci:netcdf:badVarName', fullVarName));
            end
            
            
            switch nargin
                case 3
                    start  = [];
                    stride = [];
                case 4
                    % low level is zero based.   
                    start  = start - 1;
                    stride = [];
                case 5
                    start  = start -1;
            end
            
            if(~this.isVariable(fullVarName))
                
                error(message('MATLAB:imagesci:netcdf:variableDoesNotExist', fullVarName));
            end
            
            % Variable already exists, get its group id.
            gid = this.getgid(groupName,false);
            
            
            % Variable should now exist.
            varid = netcdf.inqVarID(gid, varName);            
            % Get info about it
            varinfo  = this.varInfo(gid, varid);
            
            
            if ~isempty(varinfo.Attributes) && ... % some attributes are present
                    strcmpi(this.Conventions,'default') &&...
                    ~strcmpi(varinfo.Datatype,'char') % not char var
                                
                
                add_offset = [];
                scale_factor = [];
                
                %Get the add_offset if present
                try
                    add_offset = netcdf.getAtt(gid,varid,'add_offset');
                catch ALL %#ok<NASGU>
                    %do nothing
                end
                
                %Get the scale factor if present
                try
                    scale_factor = netcdf.getAtt(gid,varid,'scale_factor');
                catch ALL %#ok<NASGU>
                    %do nothing
                end
                
                if isempty(scale_factor) && isempty(add_offset)
                    scale_factor = cast(1, class(varData));
                    add_offset = cast(0, class(varData));
                elseif isempty(scale_factor)
                    scale_factor = cast(1, class(add_offset));
                elseif isempty(add_offset)
                    add_offset = cast(0, class(scale_factor));
                end
                
                if ~isequal(class(add_offset), class(scale_factor), class(varData))
                    % If the types are unequal, cast everything to double
                    % for computation
                    add_offset = double(add_offset);
                    scale_factor = double(scale_factor);
                    varData = double(varData);
                end
                % At this point, varData, add_offset and scale_factor
                % must be of the same class
                varData = ( varData-add_offset)./scale_factor;
 
                %Replace NaNs with fillValue
                try
                    fillValue = netcdf.getAtt(gid,varid,'_FillValue');
                    varData(isnan(varData)) = fillValue;
                catch ALL %#ok<NASGU>
                    %do nothing
                end

                varData = cast(varData, varinfo.Datatype);
                
            end
            
            
            %End define mode (if it was set)
            this.setDefineMode(gid, false);
            
            
            if(isempty(varinfo.Dimensions))
                %write scalar
                netcdf.putVar(gid, varid, varData);
                return;
            end
            
            
            % Obtain the count of elements to write.
            count = size(varData);
            
            % Add singleton dimensions from the variable definition if
            % required.
            numVarDims  = length(varinfo.Dimensions);
            numDataDims = length(count);
            if(numVarDims > numDataDims)
                count(numDataDims+1: numVarDims) = 1;
            end
            
            % If variable has a single dimension, then write it as a column
            % vector.
            if(numVarDims==1 && isvector(varData))
                count = max(count);
            end
            
            
            % Write using the low-level interface.
            
            if(isempty(start))
                % This auto-extends the variable if required.
                start = zeros(1, numVarDims);                
                netcdf.putVar(gid, varid,start, count, varData);
                
            elseif(isempty(stride))
                
                netcdf.putVar(gid,varid, start, count, varData);
                
            else
                
                netcdf.putVar(gid,varid, start, count, stride, varData);
                
            end
        end
        %------------------------------------------------------------------
        function [tf, varid] = isVariable(this, fullVarName)
            
            tf = true;
            
            try
                [~, varid] = getGroupAndVarid(this, fullVarName);
            catch ALL %#ok<NASGU>
                varid = -1;
            end
            
            if(varid == -1)
                tf = false;
                return;
            end
        end
        
        
        % Info
        %------------------------------------------------------------------
        function info = info(this, location)
            %INFO = INFO Return a structure with information about the
            %NetCDF object. INFO defines the following fields:
            %    Filename:  NetCDF file name.
            %    Name:      '/', indicating the full file (root level).
            %    Dimensions: An array of structures with these fields:
            %                 Name:            Dimension name.
            %                 Length:          Current length of the dimension.
            %                 Unlimited:       Boolean flag, true for unlimited
            %                                  dimensions
            %    Variables: An array of structures with these fields:
            %                 Filename:        NetCDF file name.
            %                 Name:            Variable name.
            %                 Dimensions:       Associated dimensions.
            %                 Size:            Current variable size.
            %                 Datatype:        MATLAB datatype.
            %                 Attributes:       Associated variable attributes.
            %                 ChunkSize:       Chunk size, if defined. [] otherwise.
            %                 FillValue:       Fill value of the variable.
            %                 DeflateLevel:    Deflate filter level if enabled.
            %                 Shuffle:         Shuffle filter enabled flag.
            %    Attributes:An array of global attributes with these fields:
            %                 Name:            Attribute name.
            %                 Value:           Attribute value.
            %    Groups:    An array of groups present in the file. [] for
            %               non netcdf4 format files. If groups are present, its
            %               structure follows the layout of FINFO.
            %    Format:    The format of the NetCDF file.
            %
            %GINFO = INFO(GROUPNAME) Returns a structure with information
            %about the named group.
            %
            %VINFO = INFO(VARNAME) Returns a structure with information
            %about the named variable.
            %
            %
            %       Note: Use the disp command for visual inspection.
            %
            
            if(nargin==1)
                % assume full file.
                location='/';
            end
            
            if(~ischar(location))
                error(message('MATLAB:imagesci:netcdf:badLocationString'));
            end
            
            [gid, varid] = getGroupAndVarid(this, location);
            
            if(varid==-1)
                info  = this.groupInfo(gid);
            else
                info  = this.varInfo(gid, varid);
            end
            
            % Tag on the source (filename) to the info struct.
            info.Filename = this.Filename;
            % Move filename to the top.
            numFields = length(fieldnames(info));
            info      = orderfields(info,[numFields 1:numFields-1]);
            
            % Tag on the Format towards the end.
            info.Format = this.Format;
        end
        
        
        % Display
        %------------------------------------------------------------------
        function setDisplayMode(this, modeStr)
            %SETDISPLAYMODE(MODESTR)
            %  'full   ' - displays the group hierarchy with all dimensions,
            %              attributes and variable definitions.
            %  'min'     - displays the group hierarchy and variable
            %              definitions.
            
            if(~strcmpi(modeStr,'full') && ...
                    ~strcmpi(modeStr,'min'))
                error(message('MATLAB:imagesci:netcdf:setDisplayMode', modeStr));
            end
            this.DisplayMode = modeStr;
        end
        %------------------------------------------------------------------
        function disp(this, location)
            %DISP Display the contents of the NetCDF source.
            %
            %    DISP Display the contents of the NetCDF file. The amount
            %    of information displayed depends on the display mode
            %    setting. Use setDisplayMode to change the display mode.
            %
            %    DISP(LOCATION) Display the information of the group or
            %    variable at LOCATION.
            %
            
			fmtMsg = getString(message('MATLAB:imagesci:netcdf:formatDisplay'));
			srcMsg = getString(message('MATLAB:imagesci:netcdf:sourceDisplay'));
            if(nargin==1);
                finfo = this.info('/');
                %print the source name and the Format of the source
                fprintf('%s\n           %s\n',srcMsg,this.Filename);
                fprintf('%s\n           %s\n',fmtMsg,this.Format);
                this.dispncGroup(finfo,'');
            else
                [~, varid] = getGroupAndVarid(this, location);
                
                if(varid == -1)
                    % location is a group
                    ginfo = this.info(location);
                    
                    %print the source name and the Format of the source
                    fprintf('%s\n           %s\n',srcMsg,this.Filename);
                    fprintf('%s\n           %s\n',fmtMsg,this.Format);
                    
                    
                    % ginfo names are relative. Update with absolute path.
                    if(~strcmp(location(1),'/'));
                        ginfo.Name = ['/' location];
                    else
                        ginfo.Name = location;
                    end
                    
                    % remove trailing / from non-root groups, if present.
                    if(~strcmp(location,'/') && strcmp(location(end),'/'))
                        ginfo.Name(end)=[];
                    end
                    
                    this.dispncGroup(ginfo,'');
                    
                else
                    
                    % location is a variable
                    vinfo = this.info(location);
                    
                    %print the source name and the Format of the source
                    fprintf('%s\n           %s\n',srcMsg,this.Filename);
                    fprintf('%s\n           %s\n',fmtMsg,this.Format);
		    
		    
                    % Show associated dimensions if it has any and display
                    % mode is 'full'.
                    if(~isempty(vinfo.Dimensions) &&...
                            strcmpi(this.DisplayMode,'full'))
                        this.dispncDims(vinfo.Dimensions, '')
                    end
                    % Show variable info
                    this.dispncVars(vinfo,'');
                    
                end
            end
            
        end
        
    end
    
    %======================================================================
    %Object save and load
    methods (Hidden=true)
        function sobj = saveobj(this)
            sobj.Filename = this.Filename;
            if(this.Mode~='r')
                warning(message('MATLAB:imagesci:netcdf:cannotSaveNonReadObjects'));
            end
        end
    end
    methods (Hidden=true, Static=true)
        function this = loadobj(sobj)
            %open a saved object in read-only mode.
            this = nc(sobj.Filename);
        end
    end
    
    
    %======================================================================
    % Dimension functions
    methods (Access=protected)
        
        function createDimension(this, gid, dimName, dimLength)
            % createDimension Create dimension in named group.
            %
            % createDimension(GID, DIMNAME, DIMLENGTH) creates a dimension
            % DIMNAME with length DIMLENGTH in the group specified by the
            % NetCDF id GID.
            %
            
            
            %Obtain current unlimited dimension names.
            unlimDimids      = netcdf.inqUnlimDims(gid);
            
            if(isempty(unlimDimids))
                unlimDimNames = {};
            else
                unlimDimNames = arrayfun(...
                    @(dimid)netcdf.inqDim(gid,dimid),...
                    unlimDimids,...
                    'UniformOutput',false);
            end
            
            if(ismember(dimName, unlimDimNames))
                %Dimension exists and it is unlimited.
                %Nothing to do.
                return;
            end
            
            %Obtain all existing dimension names
            existingDimids   = netcdf.inqDimIDs(gid);
            [existingDimNames, existingDimLengths] = arrayfun(...
                @(dimid)netcdf.inqDim(gid,dimid),...
                existingDimids,...
                'UniformOutput',false);
            
            %If dimension exists, ensure that the size asked for matches
            %the one in the file.
            if(ismember(dimName, existingDimNames))
                
                dimLengthInFile   = ...
                    existingDimLengths{strcmp(existingDimNames,dimName)};
                
                if(~isempty(dimLength) && ...
                        dimLength ~= dimLengthInFile)
                    
                    error(message('MATLAB:imagesci:netcdf:dimLengthMisMatch', dimName, dimLength, netcdf.inqGrpNameFull( gid ), dimLengthInFile));
                    
                else
                    % Dimension exists, no dimension length was given or if
                    % given, matched existing length. Nothing to do.
                    return;
                end
            else
                % Dimension does not exist. Length has to be given
                if(isempty(dimLength))
                    error(message('MATLAB:imagesci:netcdf:emptyDimLength', dimName));
                end
            end
            
            %Enter define mode.
            this.setDefineMode(gid, true);
            
            %Create the new dimension.
            reqSize = dimLength;
            if(isinf(dimLength))
                reqSize = netcdf.getConstant('UNLIMITED');
            end
            netcdf.defDim(gid, dimName, reqSize);
            
        end
        
    end
    methods (Hidden=true, Static=true)
        
        function [dimNames, dimLengths] = parseDimAndLength(dimensions)
            % parseDimAndLength Parse the DIMENSIONS cell array
            %
            % [NAMES LENGTHS] = parseDimAndLength(DIMENSIONS) parses the cell
            % array DIMENSIONS of the form {NAMESTR1, LENGTHNUM1, ...,
            % NAMESTRN, LENGTHNUMN}. Returns a cell array of NAMES and a
            % cell array of LENGTHS. If a LENGTH is not present for a NAME,
            % that entry in the cell array is set to [].
            
            dimNames   = {};
            dimLengths = {};
            
            if(isempty(dimensions))
                return;
            end
            
            if(~ischar(dimensions{1}))
                error(message('MATLAB:imagesci:netcdf:badFirstentry'));
            end
            
            dimNames{1}   = dimensions{1};
            dimLengths{1} = [];
            
            for ind = 2:length(dimensions)
                
                if(ischar(dimensions{ind}))
                    % we found a name
                    dimNames{end+1}   = dimensions{ind}; %#ok<AGROW>
                    dimLengths{end+1} = []; %#ok<AGROW>
                elseif(isnumeric(dimensions{ind}))
                    % we found a length, associate that to the previous
                    % name
                    dimLengths{end} = dimensions{ind}; 
                    validateattributes(dimensions{ind},{'numeric'},...
                        {'scalar'},...
                        'createDimension',...
                        'DIMLENGTH');
                else
                    error(message('MATLAB:imagesci:netcdf:badDataType'));
                end
                
            end            
            
            
        end
        
    end
    
    
    %======================================================================
    % File open functions
    methods (Access=protected)
        %------------------------------------------------------------------
        %Create a new source with this.Filename and this.Format.
        function openToWrite(this)
            
            if(strcmpi(this.Format,''))
                %by default write in netcdf4_classic
                this.Format = 'netcdf4_classic';
            end
            
            %Get full file name
            fid = fopen(this.Filename,'wb');
            if(fid == -1)
                error(message('MATLAB:imagesci:netcdf:unableToOpenforWrite', this.Filename));
            end
            this.Filename = fopen(fid);
            fclose(fid);
            
            switch this.Format
                
                % netcdf.create will CLOBBER by default.
                
                case 'classic'
                    %Classic - NetCDF 3. CLASSIC is the default format.
                    this.ncRootid = netcdf.create(this.Filename,'CLOBBER');
                    
                case '64bit'
                    %Classic - NetCDF 3 with 64-bit offsets.
                    this.ncRootid = ...
                        netcdf.create(this.Filename,'64BIT_OFFSET');
                    
                case 'netcdf4_classic'
                    %netcdf4_classic model
                    ncmode = netcdf.getConstant('NETCDF4');
                    ncmode = bitor(ncmode,...
                        netcdf.getConstant('CLASSIC_MODEL'));
                    this.ncRootid = netcdf.create(this.Filename,ncmode);
                    
                case 'netcdf4'
                    %netcdf4
                    this.ncRootid = netcdf.create(this.Filename,'NETCDF4');
            end
            
            
            %In define mode when opened to write.
            this.defineMode = true;
        end
        
        %------------------------------------------------------------------
        %Append (modify)  existing this.Filename (verify against
        %this.Format). Create if file does not exist.
        function openToAppend(this)
            
            % Try to open file for reading.
            fid = fopen(this.Filename,'r');
            
            if(fid~=-1)
                % File exists, find its full name.
                this.Filename = fopen(fid);
                fclose(fid);
                
                %open the NetCDF file for appending
                this.ncRootid = netcdf.open(this.Filename,'WRITE');
                
                %verify Format matches.
                actualFormat  = lower(netcdf.inqFormat(this.ncRootid));
                actualFormat  = actualFormat(8:end);
                if(strcmp(this.Format,''))
                    %By default use existing format.
                    this.Format = actualFormat;
                elseif(~strcmpi(this.Format, actualFormat))
                    warning(message('MATLAB:imagesci:netcdf:FormatMismatch', this.Format, actualFormat, actualFormat))
                    this.Format = actualFormat;
                end
                
                %Not in define mode when existing file is opened. (i.e in
                %data mode).
                this.defineMode = false;
            else
                %create the file if it does not exist
                this.openToWrite();
            end
            
            
        end
        
        %------------------------------------------------------------------
        %Open this.Filename for reading
        function openToRead(this)
            if contains(this.Filename, '://')
                % OPeNDAP link
            else
                
                %Make sure file exists, Obtain full name.
                fid = fopen(this.Filename,'r');
                if(fid == -1)
                    error(message('MATLAB:imagesci:netcdf:unableToOpenFileforRead', this.Filename));
                end
                this.Filename = fopen(fid);
                fclose(fid);
            end
            %open NetCDF file
            this.ncRootid = netcdf.open(this.Filename,'NOWRITE');
            
            %Update Format
            this.Format = lower(netcdf.inqFormat(this.ncRootid));
            this.Format = this.Format(8:end); %remove FORMAT_
        end
    end
    
    
    %======================================================================
    % Info reader helper functions
    methods (Access=protected)
        
        %--------------------------------------------------------------------------
        %Get information about this group and its children
        function ginfo = groupInfo(this, gid)
            % ginfo = groupInfo(gid) return a recursive info structure for
            % the group (can be '/''s id ) given the group id.
            
            if(this.isClassic())
                ginfo.Name = '/';
            else
                % This fails on classic files.
                ginfo.Name = netcdf.inqGrpName(gid);
            end
            
            
            % Get group dimensions, do not include parents.
            dimids      = netcdf.inqDimIDs(gid,false);
            unlimdimids = netcdf.inqUnlimDims(gid);
            ginfo.Dimensions = this.dimInfo(gid, dimids, unlimdimids);
            
            
            % Group variables
            varids          = netcdf.inqVarIDs(gid);
            ginfo.Variables = this.varInfo(gid, varids);
            
            % Group attributes
            [~,~,numAtts,~] = netcdf.inq(gid);
            ginfo.Attributes = this.attInfo(gid,-1,numAtts);
            
            ginfo.Groups = [];
            % Child groups if netcdf4
            if(strcmpi(netcdf.inqFormat(gid),'format_netcdf4'))
                childGrps = netcdf.inqGrps(gid);
                if(~isempty(childGrps))
                    % Pre-allocate
                    ginfo.Groups(length(childGrps)).Name      = '';
                    ginfo.Groups(length(childGrps)).Dimensions = [];
                    ginfo.Groups(length(childGrps)).Variables  = [];
                    ginfo.Groups(length(childGrps)).Attributes = '';
                    ginfo.Groups(length(childGrps)).Groups     = [];
                    
                    
                    for cInd = 1: length(childGrps)
                        ginfo.Groups(cInd) = this.groupInfo(childGrps(cInd));
                    end
                end
            end
        end
        
        %--------------------------------------------------------------------------
        %Get vinfo for a specific variable
        function vinfo = varInfo(this, gid, varids)
            %vInfo = varInfo(gid, varids) returns an array of variable info
            %structures, one each for a variable id in varids.
            
            if(isempty(varids))
                vinfo=[];
                return;
            end
            
            % Pre-allocate
            vinfo(length(varids)).Name         = '';
            vinfo(length(varids)).Dimensions   = [];
            vinfo(length(varids)).Size         = [];
            vinfo(length(varids)).Datatype     = '';
            vinfo(length(varids)).Attributes   = '';
            vinfo(length(varids)).ChunkSize    = [];
            vinfo(length(varids)).FillValue    = [];
            vinfo(length(varids)).DeflateLevel = [];
            vinfo(length(varids)).Shuffle      = [];
            
            
            % Read one variable at a time.
            for vInd = 1:length(varids)
                
                % Get the current variable id.
                varid = varids(vInd);
                
                % read variable name and such info.
                [vinfo(vInd).Name, xType, varDimids, numAtts] = ...
                    netcdf.inqVar(gid,varid);
                
                % Read variable dimensions
                if(isempty(varDimids))
                    
                    % Scalar variable
                    vinfo(vInd).Dimensions = [];
                    vinfo(vInd).Size       = 1;
                    
                else
                    % Initialize the current variable size.
                    vinfo(vInd).Size = zeros(1,length(varDimids));
                    
                    % Obtain dimensions for this variable.
                    unlimDimids = netcdf.inqUnlimDims(gid);
                    vinfo(vInd).Dimensions = ...
                        this.dimInfo(gid, varDimids,unlimDimids);
                    
                    % Update the size based on dimension extents.
                    vinfo(vInd).Size = [vinfo(vInd).Dimensions.Length];

                end
                
                % Read ChunkSize and such. These are not defined for non
                % hdf5 based NetCDF files.
                vinfo(vInd).FillValue    = [];
                vinfo(vInd).ChunkSize    = [];
                vinfo(vInd).Shuffle      = false;
                vinfo(vInd).DeflateLevel = [];
                
                if(this.isHDF5Based())
                    
                    % Get Fill value
                    try
                        % Some fill values are not yet supported.
                        [noFillMode,fillValue] = ...
                            netcdf.inqVarFill(gid,varid);
                    catch ALL %#ok<NASGU>
                        noFillMode = 0;
                        fillValue  = [];
                    end
                    
                    if(noFillMode)
                        vinfo(vInd).FillValue = 'disable';
                    else
                        vinfo(vInd).FillValue = fillValue;
                    end
                    
                    % Set ChunkSize if variable is chunked.
                    [storage,chunkSizes] = ...
                        netcdf.inqVarChunking(gid, varid);
                    if(strcmpi(storage,'CHUNKED'))
                        vinfo(vInd).ChunkSize = chunkSizes;
                    end
                    
                    % Get shuffle and deflate levels
                    [shuffle,deflate,deflateLevel] = ...
                        netcdf.inqVarDeflate(gid, varid);
                    vinfo(vInd).Shuffle    = shuffle;
                    if(deflate)
                        vinfo(vInd).DeflateLevel = deflateLevel;
                    end
                end
                
                % Populate the MATLAB data type
                vinfo(vInd).Datatype =...
                    internal.matlab.imagesci.nc.xTypetoDatatype(xType);
                
                % Read attributes, if this variable has any
                vinfo(vInd).Attributes = this.attInfo(gid,varid,numAtts);
                
                
            end
            
        end
        
        %--------------------------------------------------------------------------
        %Get attributes of varid (-1 for global,group).
        function ainfo = attInfo(~, gid,varid, numAtts)
            
            if(numAtts==0)
                ainfo = [];
                return;
            end
            
            % Pre-allocate
            ainfo(numAtts).Name  = '';
            ainfo(numAtts).Value = '';
            
            for attNum = 1:numAtts
                
                % Get the attribute name
                ainfo(attNum).Name  =...
                    netcdf.inqAttName(gid,varid,attNum-1);
                
                try
                    % to read attribute value. This will fail for
                    % unsupported attribute types.
                    ainfo(attNum).Value =...
                        netcdf.getAtt(gid,varid,ainfo(attNum).Name);
                    
                catch ALL %#ok<NASGU>
                    %some attribute values are not yet supported.
                    ainfo(attNum).Value = 'UNSUPPORTED DATATYPE';
                end
                
            end
            
        end
        
        %--------------------------------------------------------------------------
        %Get dimensions given dimension ids
        function dinfo = dimInfo(~, gid, dimids, unlimdimids)
            
            if(isempty(dimids))
                dinfo = [];
                return;
            end
            
            % Pre-allocate
            dinfo(length(dimids)).Name      = '';
            dinfo(length(dimids)).Length    = [];
            dinfo(length(dimids)).Unlimited = false;
            
            % Obtain list of all dimensions defined in this group.
            locallyDefinedDimIds = netcdf.inqDimIDs(gid);            
            
            % Obtain name and length for each dimension.            
            for dInd = 1: length(dimids)
                
                dimid = dimids(dInd);

                [dinfo(dInd).Name, dinfo(dInd).Length] =...
                    netcdf.inqDim(gid,dimid);                
                
                %Replace with gid=getgrpid(dimid)--------------------------
                %NetCDF-C NCF-90 feature request.

                dimIDsDefinedInThisGroup = locallyDefinedDimIds;              
                isDimLocallyDefined      = true;
                % gid of the group where the dimension was defined in.
                dimDefinedGrpID          = gid;
                
                while(~ismember(dimid, dimIDsDefinedInThisGroup))
                    % Look up to the parent.
                    isDimLocallyDefined      = false;
                    dimDefinedGrpID          = netcdf.inqGrpParent(dimDefinedGrpID);
                    dimIDsDefinedInThisGroup = netcdf.inqDimIDs(dimDefinedGrpID);
                end
                
                if(~isDimLocallyDefined)
                    %Add the group name as a prefix to the dimension name
                    dimDefinedGrpName = netcdf.inqGrpNameFull(dimDefinedGrpID);
                    if(dimDefinedGrpName=='/')
                        dinfo(dInd).Name = ['/' dinfo(dInd).Name];
                    else
                        dinfo(dInd).Name = [dimDefinedGrpName '/' dinfo(dInd).Name];
                    end
                end
                %Replace with gid=getgrpid(dimid)--------------------------
                
                % is this an unlimited dimension?
                if(ismember(dimid,unlimdimids))
                    dinfo(dInd).Unlimited = true;
                else
                    dinfo(dInd).Unlimited = false;
                end
                
            end
        end
        
    end
    
    
    %======================================================================
    % Schema writer helper functions
    methods (Access=protected)
        
        %------------------------------------------------------------------
        %Create/add dimensions in the schema struct
        function writeDimensionSchema(this, schema, fullGroupName)
            % writeDimensionSchema Create dimensions based on schema
            % structure. The schema structure has a Name, Length and
            % optional Unlimited field. schema can be an array of
            % structures.
            
            if(nargin<3)
                fullGroupName = '/';
            end
            
            % If we got this far, we already have a name and length field.
            
            % schema could be an array of structures.
            
            dimNames   = {schema.Name};
            dimLengths = {schema.Length};
            
            if(isfield(schema,'Unlimited'))
                unLimFlags = [schema.Unlimited];
            else
                unLimFlags = [];
            end
            
            if(any(unLimFlags))
                [dimLengths{unLimFlags}] = deal(inf);
            end
            
            % Warn about other fields in the structure which we ignore.
            knownFields        = {'Name','Length','Unlimited','Format'};
            allFields          = fieldnames(schema);
            unRecognizedFields = setdiff(allFields, knownFields);
            if(~isempty(unRecognizedFields))
                unRecognizedFieldStrings = ...
                    sprintf('''%s'' ',unRecognizedFields{:});
                warning(message('MATLAB:imagesci:netcdf:unknownFields', unRecognizedFieldStrings, 'Dimension'));
            end
            
           
            dimensions          = cell(1, 2* length(dimNames));
            dimensions(1:2:end) = dimNames;
            dimensions(2:2:end) = dimLengths;
            
            this.createDimensions(fullGroupName, dimensions);
        end
        
        %------------------------------------------------------------------
        %Create/add elements in the schema struct vinfo to the file at root
        %level
        function writeVariableSchema(this, schemaStructs, fullGroupName)
            % writeVariableSchema(variableSchema, fullGroupName) will
            % create variables defined in the variableSchema struct array
            % in the named group.
            
            if(nargin<3)
                fullGroupName = '/';
            end
            
            % This is a variable schema structure, validate it as such
            if(~( isfield(schemaStructs,'Name') ...
                    && isfield(schemaStructs,'Dimensions')...
                    && isfield(schemaStructs,'Datatype')))
                % bad schema
                error(message('MATLAB:imagesci:netcdf:badVariableSchema'));
            end
            
            % Tag on missing fields
            if(~isfield(schemaStructs,'Datatype'))
                [schemaStructs.Datatype] = deal('double');
            end
            if(~isfield(schemaStructs,'Attributes'))
                [schemaStructs.Attributes] = deal([]);
            end
            if(~isfield(schemaStructs,'ChunkSize'))
                [schemaStructs.ChunkSize] = deal([]);
            end
            if(~isfield(schemaStructs,'FillValue'))
                % We use the string 'NA' internally to say that user did
                % not provide a value (default to library chosen values)
                [schemaStructs.FillValue] = deal('NA');
            end
            if(~isfield(schemaStructs,'DeflateLevel'))
                [schemaStructs.DeflateLevel] = deal([]);
            end
            if(~isfield(schemaStructs,'Shuffle'))
                [schemaStructs.Shuffle] = deal(false);
            end
            
            % Warn about other fields in the structure which we ignore.
            knownFields        = {'Name','Dimensions','Size','Datatype',...
                'Attributes','ChunkSize','FillValue','DeflateLevel',...
                'Shuffle','Format','Filename'};
            allFields          = fieldnames(schemaStructs);
            unRecognizedFields = setdiff(allFields, knownFields);
            if(~isempty(unRecognizedFields))
                unRecognizedFieldStrings = ...
                    sprintf('''%s'' ',unRecognizedFields{:});
                warning(message('MATLAB:imagesci:netcdf:unknownFields', unRecognizedFieldStrings, 'Variable'));
            end
            
            for infoInd = 1:length(schemaStructs)
                
                schema = schemaStructs(infoInd);
                
                % Create dimensions.
                
                if(isempty(schema.Dimensions))
                    % Scalar variable
                    dimensions = {};
                    
                else
                    % Create the variable's dimensions. NOOP if it exists
                    % and the lengths match. Will error if lengths don't
                    % match.
                    this.writeDimensionSchema(...
                        schema.Dimensions,fullGroupName);
                    
                    % Prepare the 'Dimensions' value for creating the
                    % variable.
                    dimNames   = {schema.Dimensions.Name};
                    dimLengths = {schema.Dimensions.Length};
                    dimensions = cell(1,2*length(dimNames));
                    dimensions(1:2:end) = dimNames;
                    dimensions(2:2:end) = dimLengths;
            
                end
                
                
                % Create variable if required.                
                this.createVariable([fullGroupName schema.Name],...
                    'Dimensions',   dimensions,...
                    'Datatype',     schema.Datatype,...
                    'FillValue',    schema.FillValue,...
                    'ChunkSize',    schema.ChunkSize,...
                    'DeflateLevel', schema.DeflateLevel,...
                    'Shuffle',      schema.Shuffle);

                                
                % Create its attributes                
                for aInd = 1:length(schema.Attributes)
                    if(this.isHDF5Based() &&...
                            strcmp(schema.Attributes(aInd).Name,'_FillValue'))
                        % we have already honored the fillvalue while
                        % creation.
                        continue;
                    end
                    this.writeAttribute([fullGroupName schema.Name],...
                        schema.Attributes(aInd).Name, ...
                        schema.Attributes(aInd).Value);
                end
                
            end
        end
        
        %------------------------------------------------------------------
        %Create/add elements in the schema struct (finfo/ginfo) to the file
        function writeGroupSchema(this, schemaStructs, parentGroup)
            % writeGroupSchema(schemaStructs, parentGroup) creates groups
            % defined by schemaStructs in the location parentGroup.
            
            if(nargin<3)
                parentGroup = '/';
            end
            
            % Warn about other fields in the structure which we ignore.
            knownFields        = {'Name','Dimensions','Variables',...
                'Attributes','Groups','Filename','Format'};
            allFields          = fieldnames(schemaStructs);
            unRecognizedFields = setdiff(allFields, knownFields);
            if(~isempty(unRecognizedFields))
                unRecognizedFieldStrings = ...
                    sprintf('''%s'' ',unRecognizedFields{:});
                warning(message('MATLAB:imagesci:netcdf:unknownFields', unRecognizedFieldStrings, 'Group'));
            end
            
            for infoInd = 1:length(schemaStructs)
                
                schema = schemaStructs(infoInd);
                
                % Create the group and intermediate groups if required.
                % schema.Name is NOT fully qualified. parentGroup always
                % has a lagging '/'.
                
                % Make the name fully qualified if its not the root group.
                if(~strcmpi(schema.Name,'/'))
                    schema.Name = [ parentGroup schema.Name '/'];
                end
                
                % Create this group if required.
                getgid(this, schema.Name, true);
                
                
                %Create the dimensions.
                if(isfield(schema,'Dimensions') && ...
                        ~isempty(schema.Dimensions))
                    this.writeDimensionSchema(...
                        schema.Dimensions,schema.Name);
                end
                
                
                % Write attributes.
                if(isfield(schema,'Attributes') && ...
                        ~isempty(schema.Attributes))
                    for aInd = 1:length(schema.Attributes)
                        this.writeAttribute(schema.Name,...
                            schema.Attributes(aInd).Name,...
                            schema.Attributes(aInd).Value);
                    end
                end
                
                % Create all the variables.
                if(isfield(schema,'Variables') && ...
                        ~isempty(schema.Variables))
                    this.writeVariableSchema(schema.Variables, schema.Name);
                end
                
                % Create groups recursively.
                if(isfield(schema,'Groups') && ...
                        ~isempty(schema.Groups))
                    this.writeGroupSchema(schema.Groups, schema.Name);
                end
                
            end
        end
        
    end
    
    
    %======================================================================
    % Disp helper functions
    methods(Access=protected)
        
        %--------------------------------------------------------------------------
        %Recursively display information about this group and its children
        function dispncGroup(this, ginfo, indentSpace)            
            
            nextIndentSpace = indentSpace;
            
            if(~strcmp(ginfo.Name,'/'))
                %print name only if its not the root.
                ginfo.Name(end+1) = '/';
                fprintf('%s%s\n',indentSpace,ginfo.Name);
                nextIndentSpace = [indentSpace '    '];
            end
            
            % group attributes
            if(strcmp(this.DisplayMode,'full'))
                
                if(~isempty(ginfo.Attributes))
                    if(strcmp(ginfo.Name,'/'))
						attrMsg = getString(message('MATLAB:imagesci:netcdf:globalAttributeDisplay'));
                    else
						attrMsg = getString(message('MATLAB:imagesci:netcdf:attributeDisplay'));
                    end
                    fprintf('%s%s\n',nextIndentSpace,attrMsg);
                    this.dispncAtts(ginfo.Attributes,nextIndentSpace);
                end
                
            end
            
            % group dimensions
            if(strcmp(this.DisplayMode,'full'))
                if(~isempty(ginfo.Dimensions))
                    this.dispncDims(ginfo.Dimensions,nextIndentSpace );
                end
            end
            
            % group variables
            this.dispncVars(ginfo.Variables, nextIndentSpace);
            
            
            % child groups
            if(~isempty(ginfo.Groups))
			    groupsMsg = getString(message('MATLAB:imagesci:netcdf:groupsDisplay'));
                fprintf('%s%s\n',nextIndentSpace,groupsMsg);
                for cInd = 1:length(ginfo.Groups)
                    ginfo.Groups(cInd).Name = ...
                        [ginfo.Name ginfo.Groups(cInd).Name ];
                    this.dispncGroup(ginfo.Groups(cInd),...
                        [nextIndentSpace '    ']);
                end
            end
            
            
            % done group
            if(~strcmp(ginfo.Name,'/'))
                fprintf('%s\n',indentSpace);
            end
            
        end

        %--------------------------------------------------------------------------
        %Display all variables visible from ncid
        function dispncVars(this, vinfo, indentSpace)
            
            if(isempty(vinfo))
                %nothing to do
                return;
            end
            
		    varsMsg = getString(message('MATLAB:imagesci:netcdf:variablesDisplay'));
            fprintf('%s%s\n',indentSpace,varsMsg);
            
            %pad the variable names with space to make them equal
            vNames = internal.matlab.imagesci.nc.uniformPad({vinfo.Name});
            
            %For all variables
            for vInd = 1:length(vinfo)
                %print the variable name
                fprintf('%s    %s\n',indentSpace, vNames{vInd});
                
                
                if(isempty(vinfo(vInd).Dimensions))
                    %Print 1x1 for a scalar variable
                    ncDimNames = '';
                    matlabDims = '1x1';
                elseif(length(vinfo(vInd).Dimensions)==1)
                    %Print Nx1 for a vector variable
                    ncDimNames = sprintf('%s',...
                        vinfo(vInd).Dimensions(1).Name);
                    if(vinfo(vInd).Size(1))
                        matlabDims = [num2str(vinfo(vInd).Size(1)) 'x1'];
                    else
                        matlabDims = '[]';
                    end
                else
                    dimstr = sprintf('%s,',vinfo(vInd).Dimensions.Name);
                    dimstr = dimstr(1:end-1); %trailing ,
                    ncDimNames = sprintf('%s',dimstr);
                    if(prod(vinfo(vInd).Size))
                        matlabDims = sprintf('%dx',vinfo(vInd).Size);
                        matlabDims = matlabDims(1:end-1);
                    else
                        matlabDims = '[]';
                    end
                end
                
                %Show variable info
				sizeDisplay = getString(message('MATLAB:imagesci:netcdf:sizeDisplay'));
				dimensionsDisplay = getString(message('MATLAB:imagesci:netcdf:dimensionsDisplay'));
				datatypeDisplay = getString(message('MATLAB:imagesci:netcdf:datatypeDisplay'));
                fprintf('%s           %s       %s\n',...
                    indentSpace, sizeDisplay, matlabDims);
                fprintf('%s           %s %s\n',...
                    indentSpace, dimensionsDisplay, ncDimNames);
                fprintf('%s           %s   %s\n',...
                    indentSpace, datatypeDisplay, vinfo(vInd).Datatype);
                
                
                %display the attributes for this variable if
                %this.DisplayMode says so
                if(strcmpi(this.DisplayMode,'full') && ...
                        ~isempty(vinfo(vInd).Attributes))
                    
					attrMsg = getString(message('MATLAB:imagesci:netcdf:attributeDisplay'));
                    fprintf('%s           %s\n',indentSpace,attrMsg);
                    this.dispncAtts(...
                        vinfo(vInd).Attributes,['            ' indentSpace]);
                end
                
            end %loop for variables
            
        end
                
        %--------------------------------------------------------------------------
        %Display dimensions given dimension ids
        function dispncDims(~, dinfo, indentSpace)
            
			dimensionsMsg = getString(message('MATLAB:imagesci:netcdf:dimensionsDisplay'));
            fprintf('%s%s\n',indentSpace,dimensionsMsg);
            
            dimDesc = cell(1,length(dinfo));
            
            % Obtain description for each dimension.
            for dInd = 1:length(dinfo)
                if(dinfo(dInd).Unlimited) % is this an unlimited dimension?
					unlimitedMsg = getString(message('MATLAB:imagesci:netcdf:unlimitedDisplay'));
                    dimDesc{dInd}=sprintf('= %-5d (%s)\n', dinfo(dInd).Length, unlimitedMsg);
                else
                    dimDesc{dInd}=sprintf('= %d\n', dinfo(dInd).Length);
                end
            end
            
            %Pad spaces at the end to make all of them uniform length.
            dimName = internal.matlab.imagesci.nc.uniformPad({dinfo.Name});
            
            %pretty print the dimensions
            for dInd=1:length(dinfo)
                [~, dimName{dInd}] = internal.matlab.imagesci.nc.parseDimLocation(dimName{dInd});
                fprintf('%s           %s %s',indentSpace,dimName{dInd},...
                    dimDesc{dInd});
            end
            
        end

        %--------------------------------------------------------------------------
        %Display attributes
        function dispncAtts(~, ainfo,indentSpace)
            
            attDesc = cell(1,length(ainfo));
            %pad attribute names with spaces to make them of equal length.
            attNames = internal.matlab.imagesci.nc.uniformPad({ainfo.Name});
            
            %extra padding space till the attribute value is printed,
            %useful for multiline string attributes. This is equal to
            %padded length of an attribute name + space for ' = '.
            attValuePadSpace = repmat(' ',[1 ...
                length(attNames{1}) + 3]);
            attValuePadSpace =[attValuePadSpace indentSpace];
            
            %Obtain name and value for each of the attributes
            for aInd = 1:length(ainfo)
                if(isnumeric(ainfo(aInd).Value))
                    if(numel(ainfo(aInd).Value)>1)
                        %Use [] to scope vectors
                        attDesc{aInd} = ...
                            ['[' num2str(ainfo(aInd).Value) ']'];
                    else
                        attDesc{aInd} = num2str(ainfo(aInd).Value);
                    end
                elseif(strcmp(ainfo(aInd).Value,'UNSUPPORTED DATATYPE'))
                    attDesc{aInd} = ainfo(aInd).Value;
                else
                    %Use '' to frame non-numeric (assumed strings).
                    attDesc{aInd} = ['''',ainfo(aInd).Value,''''];
                    %replace any new lines with new lines and indentation
                    %space
                    attDesc{aInd} = strrep(attDesc{aInd},...
                        sprintf('\n'),...
                        sprintf('\n%s           ',attValuePadSpace));
                    
                end
            end
            
            %print each attribute.
            for aInd = 1:length(ainfo)
                fprintf('%s           %s = %s\n',...
                    indentSpace,attNames{aInd},...
                    attDesc{aInd});
            end
        end
        
        
    end
    
    
    %======================================================================
    % is? functions
    methods (Access=protected)
        
        %------------------------------------------------------------------
        function tf = isClassic(this)
            %Anything not 'netcdf4' is considered classic.
            tf = ~strcmp(this.Format, 'netcdf4');
        end
        
        %------------------------------------------------------------------
        function tf = isHDF5Based(this)
            %netcdf4_classic and netcdf4 are based on HDF5.
            tf = strncmpi(this.Format, 'netcdf4',7);
        end
       
    end
    
    
    %======================================================================
    % General functions
    methods (Access=protected)
        %------------------------------------------------------------------
        function setDefineMode(this, gid, tf)
            %mode is mandatory for classic model files.
            
            %required for NetCDF4 files if modifying an attribute with a
            %value larger that existing value.
            
            if(tf ~= this.defineMode)
                try
                    if(tf)
                        netcdf.reDef(gid);
                        this.defineMode = true;
                    else
                        netcdf.endDef(gid);
                        this.defineMode = false;
                    end
                catch setModeFailure %#ok<NASGU>
                    %these calls fail if its already in required mode.
                end
            end
            
        end
        
        %------------------------------------------------------------------
        function gid = getgid(this, fullGroupName, createIntermediate)
            % getgid Return group id for a given group name. Create
            % intermediate groups if asked for.
            
            gid = this.ncRootid;
            
            if(strcmpi(fullGroupName,'/'))
                % return the root group id.
                return;
                
            elseif(this.isClassic())
                
                %Groups are not supported with classic Format
                error(message('MATLAB:imagesci:netcdf:classicFileWithGroups', fullGroupName));
            end
            
            [oneGroup, rest] = strtok(fullGroupName,'/');
            
            while(oneGroup)
                try
                    gid = netcdf.inqNcid(gid, oneGroup);
                catch GRP_INQ_FAIL
                    if(createIntermediate)
                        % create it if asked for.
                        gid = netcdf.defGrp(gid, oneGroup);
                    else
                        rethrow(GRP_INQ_FAIL);
                    end
                end
                [oneGroup, rest] = strtok(rest,'/'); %#ok<STTOK>
            end
        end
        
        %------------------------------------------------------------------
        function [gid, varid] = getGroupAndVarid(this, location)
            %getGroupAndVarid Return group and variable id for given
            %location. If location does not contain a variable, varid = -1.
            
            [groupName, varName] = ...
                internal.matlab.imagesci.nc.parsePath(location);
            
            % If location is /g1/x. varName ('x') could either be a group
            % or a variable. Check.
            
            try
                %Iterpret as varname
                gid   = this.getgid(groupName, false);
                varid = netcdf.inqVarID(gid, varName);
                
            catch ALL %#ok<NASGU>
                try
                    %Try to interpret as one long group name.
                    gid   = this.getgid(location,false);
                    varid = -1;
                catch ALL 
                    error(message('MATLAB:imagesci:netcdf:unknownLocation', location));
                end
            end
            
        end
        
    end
    
    
    %======================================================================
    % Static functions
    methods (Static=true, Hidden=true)
        
        %------------------------------------------------------------------
        function [groupName, varName] = parsePath(locationName)
            % parsePath Return the group name and variable name from the
            % string locationName.
            %     /g1/x  returns '/g1/' and 'x'.
            %     /g1/x/ returns '/g1/x/ and ''.
            % Caller needs to confirm if x is a group/variable in /g1/x.
            
            % Add a leading / if not present.
            if(isempty(locationName) || ~ischar(locationName))
                error(message('MATLAB:imagesci:netcdf:badLocationString'));
            end
            
            if(locationName(1) ~= '/')
                locationName = ['/' locationName];
            end
            
            lastSlash = find(locationName=='/',1,'last');
            groupName = locationName(1:lastSlash);
            
            % This will be '' if locationName ends in a '/'.
            varName   = locationName(lastSlash+1:end);
            
        end
        
        
        %------------------------------------------------------------------
        function [groupName, dimName] = parseDimLocation(fullDimName)
            % parseDimLocation return the group name and dimension name from the
            % string dimName.
            %     /g1/d  returns '/g1/' and 'd'.
            %     d1     return  '' and d1
            %     g1/d/  will error out.
            
            if(fullDimName(1) == '/')
                lastSlash = find(fullDimName=='/',1,'last');
                groupName = fullDimName(1:lastSlash);
                dimName   = fullDimName(lastSlash+1:end);                
            else                
                groupName ='';
                dimName   = fullDimName;
            end
            
            if(isempty(dimName))
                % Only group name given, no dimension name.
                error(message('MATLAB:imagesci:netcdf:badDimensionName',...
                    fullDimName));
            end
            
         
        end
        
        %--------------------------------------------------------------------------
        %Obtain the NetCDF data type from MATLAB data class.
        function xType = dataClasstoxType(dataClass)
            
            switch dataClass
                case 'double'
                    xType = netcdf.getConstant('double');
                case 'int8'
                    xType = netcdf.getConstant('byte');
                case 'uint8'
                    xType = netcdf.getConstant('ubyte');
                case 'int32'
                    xType = netcdf.getConstant('int');
                case 'uint32'
                    xType = netcdf.getConstant('uint');
                case 'int16'
                    xType = netcdf.getConstant('short');
                case 'uint16'
                    xType = netcdf.getConstant('ushort');
                case 'uint64'
                    xType = netcdf.getConstant('uint64');
                case 'int64'
                    xType = netcdf.getConstant('int64');
                case 'char'
                    xType = netcdf.getConstant('char');
                case 'single'
                    xType = netcdf.getConstant('float');
                otherwise
                    error(message('MATLAB:imagesci:netcdf:unsupportedData', dataClass));
            end
            
        end
        
        %------------------------------------------------------------------
        %Obtain the MATLAB data class from the NetCDF data type
        function dataClass = xTypetoDatatype(xType)
            
            switch xType
                case netcdf.getConstant('double')
                    dataClass = 'double';
                case netcdf.getConstant('byte')
                    dataClass = 'int8';
                case netcdf.getConstant('ubyte')
                    dataClass = 'uint8';
                case netcdf.getConstant('int')
                    dataClass = 'int32';
                case netcdf.getConstant('uint')
                    dataClass = 'uint32';
                case netcdf.getConstant('short')
                    dataClass = 'int16';
                case netcdf.getConstant('ushort')
                    dataClass = 'uint16';
                case netcdf.getConstant('char')
                    dataClass = 'char';
                case netcdf.getConstant('float')
                    dataClass = 'single';
                case netcdf.getConstant('uint64')
                    dataClass = 'uint64';
                case netcdf.getConstant('int64')
                    dataClass = 'int64';
                otherwise
                    dataClass = 'UNSUPPORTED DATATYPE';
            end
            
        end
        
        %------------------------------------------------------------------
        % Pad individual strings in cellArray with spaces to make all of
        % them equal length
        function paddedCells = uniformPad(cellArray)
            maxLength = max(cellfun(@length,cellArray));
            
            paddedCells = ...
                cellfun(@(s)[s repmat(' ',...
                [1 maxLength-length(s)])],...
                cellArray,'UniformOutput',false);
            
            
        end
        
        
    end
    
end
