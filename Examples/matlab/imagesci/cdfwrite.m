function cdfwrite(filename, varcell, varargin)
%CDFWRITE Write data to a CDF file.
%   CDFWRITE is not recommended.  Use CDFLIB instead.
% 
%   CDFWRITE(FILE, VARIABLELIST) writes out a CDF file whose name
%   is specified by FILE.  VARIABLELIST is a cell array of ordered
%   pairs, which are comprised of a CDF variable name (a string) and
%   the corresponding CDF variable value.  To write out multiple records
%   for a variable, put the variable values in a cell array, where each
%   element in the cell array represents a record.
%
%   CDFWRITE(..., 'PadValues', PADVALS) writes out pad values for given
%   variable names.  PADVALS is a cell array of ordered pairs, which
%   are comprised of a variable name (a string) and a corresponding 
%   pad value.  Pad values are the default value associated with the
%   variable when an out-of-bounds record is accessed.  Variable names
%   that appear in PADVALS must appear in VARIABLELIST.
%
%   CDFWRITE(..., 'GlobalAttributes', GATTRIB) writes the structure
%   GATTRIB as global meta-data for the CDF.  Each field of the
%   struct is the name of a global attribute.  The value of each
%   field contains the value of the attribute.  To write out
%   multiple values for an attribute, the field value should be a
%   cell array.
%
%   In order to specify a global attribute name that is illegal in
%   MATLAB, create a field called "CDFAttributeRename" in the 
%   attribute struct.  The "CDFAttribute Rename" field must have a value
%   which is a cell array of ordered pairs.  The ordered pair consists
%   of the name of the original attribute, as listed in the 
%   GlobalAttributes struct and the corresponding name of the attribute
%   to be written to the CDF.
%
%   CDFWRITE(..., 'VariableAttributes', VATTRIB) writes the
%   structure VATTRIB as variable meta-data for the CDF.  Each
%   field of the struct is the name of a variable attribute.  The
%   value of each field should be an mx2 cell array where m is the
%   number of variables with attributes.  The first element in the
%   cell array should be the name of the variable and the second
%   element should be the value of the attribute for that variable.
%
%   In order to specify a variable attribute name that is illegal in
%   MATLAB, create a field called "CDFAttributeRename" in the 
%   attribute struct.  The "CDFAttribute Rename" field must have a value
%   which is a cell array of ordered pairs.  The ordered pair consists
%   of the name of the original attribute, as listed in the 
%   VariableAttributes struct and the corresponding name of the attribute
%   to be written to the CDF.   If you are specifying a variable attribute
%   of a CDF variable that you are re-naming, the name of the variable in
%   the VariableAttributes struct must be the same as the re-named variable.
%
%   CDFWRITE(..., 'WriteMode', MODE) where MODE is either 'overwrite'
%   or 'append' indicates whether or not the specified variables or 
%   should be appended to the CDF if the file already exists.  The 
%   default is 'overwrite', indicating that CDFWRITE will not append
%   variables and attributes.
%
%   CDFWRITE(..., 'Format', FORMAT) where FORMAT is either 'multifile'
%   or 'singlefile' indicates whether or not the data is written out
%   as a multi-file CDF.  In a multi-file CDF, each variable is stored
%   in a *.vN file where N is the number of the variable that is
%   written out to the CDF.  The default is 'singlefile', which indicates
%   that CDFWRITE will write out a single file CDF.  When the 'WriteMode'
%   is set to 'Append', the 'Format' option is ignored, and the format
%   of the pre-existing CDF is used.
%
%   CDFWRITE(..., 'Version', VERSION) where VERSION is a string which 
%   specifies the version of the CDF library to use in writing the file.
%   The default option is to use the latest version of the library 
%   (which is currently version 3.1), and may be specified '3.0'.  The 
%   other available version is version 2.7 ('2.7').  Note that 
%   versions of MATLAB before R2006b will not be able to read files 
%   which were written with CDF versions greater than 3.0.
%
%
%   Notes:
%
%     CDFWRITE creates temporary files when writing CDF files.  Both the
%     target directory for the file and the current working directory
%     must be writeable.
%
%     CDFWRITE performance can be noticeably influenced by the file 
%     validation done by default by the CDF library.  Please consult
%     the CDFLIB package documentation for information on controlling
%     the validation process.
%
%
%   Examples:
%
%   % Write out a file 'example.cdf' containing a variable 'Longitude'
%   % with the value [0:360]:
%
%   cdfwrite('example', {'Longitude', 0:360});
%
%   % Write out a file 'example.cdf' containing variables 'Longitude'
%   % and 'Latitude' with the variable 'Latitude' having a pad value
%   % of 10 for all out-of-bounds records that are accessed:
%
%   cdfwrite('example', {'Longitude', 0:360, 'Latitude', 10:20}, ...
%            'PadValues', {'Latitude', 10});
%
%   % Write out a file 'example.cdf', containing a variable 'Longitude'
%   % with the value [0:360], and with a variable attribute of
%   % 'validmin' with the value 10:
%
%   varAttribStruct.validmin = {'Longitude' [10]};
%   cdfwrite('example', {'Longitude' 0:360}, ...
%            'VariableAttributes', varAttribStruct);
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also CDFLIB, CDFREAD, CDFINFO, CDFEPOCH.

%   Copyright 1984-2013 The MathWorks, Inc.

if nargin < 2
    error(message('MATLAB:imagesci:validate:wrongNumberOfInputs'));
end

% parse_inputs sorts out all of the input args.  Its return values:
%
% * args - an array of structs.  args.VarNames contains the names
% of the variables to be written to the CDF.  args.VarVals contains
% the corresponding values.  args.PadVals contains corresponding pad
% values.
% * isAppending - whether or not to delete this file or if we need to
% append to the file
% * isMultifile - whether or not to write out as a multi-file CDF
% * CDFversion - which version of the CDF library to use
% * varAttribStruct - a struct containing the variable attributes
% * globalAttribStruct - a struct containing the global CDF
% attributes
% * msg - an error message from parse_inputs that we pass on to the user.

[args, isAppending, isMultifile, CDFversion, varAttribStruct, globalAttribStruct] = parse_inputs(varcell, varargin{:});


cdfwritem(filename, args.VarNames, args.VarVals, args.PadVals,  ...
          globalAttribStruct, varAttribStruct, isAppending, ...
          isMultifile, CDFversion);

%%%
%%% Function parse_inputs
%%%

function [args, isAppending, isMultifile, CDFversion, varAttribStruct, ...
          globalAttribStruct] = parse_inputs(varcell, varargin)

p = inputParser;
p.addRequired('varcell',@iscell);
p.addOptional('PadValues',{},@iscell);
p.addOptional('GlobalAttributes',struct([]),@isstruct);
p.addOptional('VariableAttributes',struct([]),@isstruct);
p.addOptional('WriteMode','',@ischar);
p.addOptional('Format','',@ischar);
p.addOptional('Version','',@ischar);

p.parse(varcell,varargin{:});

% Set default values
args.PadVals = {};
isAppending = 0;
isMultifile = 0;
varAttribStruct = struct([]);
globalAttribStruct = struct([]);
% The following value indicates no version preference.
CDFversion = -1.0;



% First check that varcell meets all of our requirements
args.VarNames = varcell(1:2:end);
if ~iscellstr(args.VarNames)
    error(message('MATLAB:imagesci:cdf:variableNamesMustBeCellString'));
end

args.VarVals = varcell(2:2:end);
% Wrap the scalars non-empties in cell arrays.
for i = 1:length(args.VarVals)
    if ~isempty(args.VarVals{i}) && (ischar(args.VarVals{i}) || (numel(args.VarVals{i}) == 1))
        args.VarVals{i} = args.VarVals(i);    
    end
end

if length(args.VarNames) ~= length(args.VarVals)
    error(message('MATLAB:imagesci:cdf:variableWithoutValue'));
end

% Check and make sure that all variable values are of the same
% datatype, but ignore empties
if ~isempty(args.VarVals)
    for i = 1:length(args.VarVals)
        a = args.VarVals{i};
        if iscell(a)
            nonEmpties = a(~cellfun('isempty',a));
            if iscell(nonEmpties) && ~isempty(nonEmpties)
                dtype = class(nonEmpties{1});
                if ~all(cellfun('isclass',nonEmpties,dtype))
                    error (message('MATLAB:imagesci:cdf:inconsistentRecordTypes'));   
                elseif ~all(cellfun(@rightSize, nonEmpties))
                    error(message('MATLAB:imagesci:cdf:tooMuchData'));
                end
            end
        else
            % If it isn't a cell array, then it is an array and
            % all elements are of the same type.  This is a single
            % record value and must be placed in a cell array.
            if (~rightSize(args.VarVals{i}))
                error(message('MATLAB:imagesci:cdf:tooMuchData'));
            end
            args.VarVals{i} = args.VarVals(i);
        end
    end
end

args.PadVals = cell(1,length(args.VarNames));


% Validate the optional parameters.
% pad values
if ~isempty(p.Results.PadValues)
    
    % If we weren't passed an even pair, then a variable
    % name or value was left out
    if rem(numel(p.Results.PadValues),2)
        error(message('MATLAB:imagesci:cdf:paddingMismatch'));
    end
    vars = p.Results.PadValues(1:2:end);
    padVals = p.Results.PadValues(2:2:end);
    % Check that vars are in the list above.
    if ~iscellstr(vars)
        error(message('MATLAB:imagesci:cdf:varNameNotString'));
    end
    if ~all(ismember(vars, args.VarNames))
        error(message('MATLAB:imagesci:cdf:notSavingVarForPadValue'));
    end
    for i = 1:length(padVals)
        padVal = padVals{i};
        validateattributes(padVal,{'numeric','char','cdfepoch'},{},'','PADVAL');
        args.PadVals{strcmp(args.VarNames,vars{i})} = padVals{i};
    end
end


if ~isempty(p.Results.GlobalAttributes)
      
    globalAttribStruct = p.Results.GlobalAttributes;
    attribs = fieldnames(globalAttribStruct);
    
    % If the global attribute isn't a cell, then stuff it in one.
    for i = 1:length(attribs)
        attribVal = globalAttribStruct.(attribs{i});
        if ~iscell(attribVal)
            globalAttribStruct.(attribs{i}) = {attribVal};
        end
    end
    
end

if ~isempty(p.Results.VariableAttributes)

    varAttribStruct = p.Results.VariableAttributes;
    validateattributes(varAttribStruct,{'struct'},{},'','VATTRIB');
    attribs = fieldnames(varAttribStruct);
    
    % Check the VariableAttributes struct.
    for i = 1:length(attribs)
        % If the variable attribute isn't in a cell (because
        % it is scalar, then put it into a cell.
        attribVal = varAttribStruct.(attribs{i});
        s = size(attribVal);
        if ~iscell(attribVal)
            varAttribStruct.(attribVal) = {attribVal};
        end
        % The variable attribute struct may have more than one
        % variable per attribute.  However, there must only be
        % one associated value of the attribute for each variable,
        % hence the 2.
        if (s(2) == 2)
            % Transpose it because CDFlib reads the arrays column-wise.
            varAttribStruct.(attribs{i}) = attribVal';
        else
            % We have ordered pairs.
            varAttribStruct.(attribs{i}) = reshape(varAttribStruct.(attribs{i})(:),numel(varAttribStruct.(attribs{i})(:))/2, 2);
        end
        
        
    end
end

if ~isempty(p.Results.WriteMode)
    
    isAppending = validatestring(p.Results.WriteMode,{'overwrite','append'});
    if strcmp(isAppending, 'overwrite')
        isAppending = 0;
    else
        isAppending = 1;
    end
end


if ~isempty(p.Results.Format)
    isMultifile = validatestring(p.Results.Format,{'singlefile','multifile'});
    if strcmp(isMultifile, 'singlefile')
        isMultifile = 0;
    else 
        isMultifile = 1;
    end
end

if ~isempty(p.Results.Version)
    version = validatestring(p.Results.Version,{'2.7', '3.0'});
    CDFversion = str2double(version);
end

if nargin > 0    
    % Do a sanity check on the sizes of what we are passing back
    if ~isequal(length(args.VarNames), length(args.VarVals), ...
                length(args.PadVals))
        error(message('MATLAB:imagesci:cdf:sanityCheckMismatch')); 
    end
end  % if (nargin > 1)



function tf = rightSize(record)
% Check that CDF records and/or variables fit within signed 32-bit offsets.

validateattributes(record,{'numeric','char','logical','cdfepoch'},{},'','RECORD');
% How many bytes does each element occupy in memory?
switch (class(record))
    case {'uint8', 'int8', 'logical', 'char'}
        
        elementSize = 1;
        
    case {'uint16', 'int16'}
        
        elementSize = 2;
        
    case {'uint32', 'int32', 'single', 'cdfepoch'}
        
        elementSize = 4;
        
    case {'uint64', 'int64', 'double'}
        
        elementSize = 8;
        
end

% Validate that the dataset/image will fit within 31-bit offsets.
max31 = double(intmax('int32'));

tf = (numel(record) * elementSize) <= max31;



%--------------------------------------------------------------------------
function cdfwritem(filename, VarNames, VarVals, PadVals,  ...
    globalAttribStruct, varAttribStruct, isAppending, ...
    isMultifile, CDFversion)

if isAppending
    cdfid = cdflib.open(filename);
else
    if exist(filename,'file')
        delete(filename);
    end
    if CDFversion == 2.7
        cdflib.setFileBackward('BACKWARDFILEon');
    else
        cdflib.setFileBackward('BACKWARDFILEoff');
    end
    cdfid = cdflib.create(filename);
    cdflib.setMajority(cdfid,'COLUMN_MAJOR');
    if isMultifile
        cdflib.setFormat(cdfid,'MULTI_FILE');
    end
end

cObj = onCleanup(@() cdflib.close(cdfid));

fileVersion = cdflib.getVersion(cdfid);
if ((fileVersion == 3) && (CDFversion == 2.7))
    warning(message('MATLAB:imagesci:cdf:versionDisregarded'));
end
if ((fileVersion == 2) && (CDFversion >= 3))
    warning(message('MATLAB:imagesci:cdf:versionDisregarded'));
end

for j = 1:numel(VarNames)
    
    varname = VarNames{j};
    vardata = VarVals{j};
    padval = PadVals{j};
    
    xtype = guess_cdf_datatype(vardata,padval);
    
    if isAppending
        try
            varNum = cdflib.getVarNum(cdfid,varname);
        catch me
            if strcmp(me.identifier,'MATLAB:imagesci:cdflib:libraryFailure')
                varNum = local_def_var(cdfid,varname,vardata,xtype,padval);
            else
                rethrow(me);
            end
        end
        
    else
        varNum = local_def_var(cdfid,varname,vardata,xtype,padval);
    end
    
    
    for r = 1:numel(vardata)
        recdata = vardata{r};
        if isempty(recdata)
            continue;
        end

        
        switch(xtype)
            case 'cdf_epoch'
                recdata = convert_to_real_cdf_epoch(recdata);
            case 'cdf_uchar'
                sz = size(recdata);
                nr = numel(sz);
                permute_dims = [2 1 3:nr];
                recdata = permute(recdata,permute_dims);
        end
        
        cdflib.putVarRecordData(cdfid,varNum,r-1,recdata);
    end
    
end


% Go through the variable attributes structure.
f = fieldnames(varAttribStruct);
for j = 1:numel(f)
    attname = f{j};
    
    if strcmp(attname,'CDFAttributeRename')
        % special case, skip for now
        continue;
    end
    
    attstruct = varAttribStruct.(attname);
       
    attrNum = local_create_att(cdfid,attname,isAppending,'variable_scope');  
    
    natts = size(attstruct,2);
    for k = 1:natts
        varname = attstruct{1,k};
        attdata = attstruct{2,k};
        entrynum = cdflib.getVarNum(cdfid,varname);
        xtype = guess_cdf_datatype(attstruct{2,k},[]);
        
        if strcmp(xtype,'cdf_epoch')
            attdata = convert_to_real_cdf_epoch(attdata);
        end
        
        cdflib.putAttrEntry(cdfid,attrNum,entrynum,xtype,attdata);
    end
end

if isfield(varAttribStruct,'CDFAttributeRename')
    x = varAttribStruct.CDFAttributeRename;
    for j = 1:2:numel(x)
        attrNum = cdflib.getAttrNum(cdfid,x{1});
        cdflib.renameAttr(cdfid,attrNum,x{2});
    end
end




% Go through the variable attributes structure.
f = fieldnames(globalAttribStruct);
for j = 1:numel(f)
    attname = f{j};
    
    if strcmp(attname,'CDFAttributeRename')
        % special case, skip for now
        continue;
    end
    
    attrNum = local_create_att(cdfid,attname,isAppending,'global_scope');
   
    attrvals = globalAttribStruct.(attname);

    for k = 1:numel(attrvals)
        attdata = attrvals{k};
        xtype = guess_cdf_datatype(attdata,[]);
        
        if strcmp(xtype,'cdf_epoch')
            attdata = convert_to_real_cdf_epoch(attdata);
        end
        cdflib.putAttrgEntry(cdfid,attrNum,k-1,xtype,attdata);
    end
end


if isfield(globalAttribStruct,'CDFAttributeRename')
    x = globalAttribStruct.CDFAttributeRename;
    for j = 1:2:numel(x)
        attrNum = cdflib.getAttrNum(cdfid,x{1});
        cdflib.renameAttr(cdfid,attrNum,x{2});
    end
end


%--------------------------------------------------------------------------
function attrNum = local_create_att(cdfid,attname,isAppending,scope)
if isAppending
    try
        attrNum = cdflib.getAttrNum(cdfid,attname);
    catch me %#ok<NASGU>
        attrNum = cdflib.createAttr(cdfid,attname,scope);
    end
else
    attrNum = cdflib.createAttr(cdfid,attname,scope);
end
    
    
%--------------------------------------------------------------------------
function varNum = local_def_var(cdfid,varname,vardata,xtype,padval)

nElts = 1;


% find the first non-empty datum.
C = cellfun(@isempty,vardata);
idx = find(C==0);
if ~isempty(idx)
    x = vardata{idx(1)};
elseif ~isempty(padval)
    x = padval;
else
    % Fake a datum to use to figure out the dimensions.
    if ischar(vardata{1})
        x = '0';
    else
        x = 0;
    end
end
if ischar(x)
    n = ndims(x);
    nElts = size(x,2);
    if n == 2
        dims = size(x,1);
    else
        sz = size(x);
        dims = [sz(1) sz(3:end)];
    end
    
    
else
    if isvector(x)
        dims = numel(x);
    else
        dims = size(x);
    end
end
    


recVariance = true;
dimVariance = true([1 numel(dims)]);
    
varNum = cdflib.createVar(cdfid,varname,xtype, nElts, ...
    dims, recVariance, dimVariance);

if ~isempty(padval)
    if strcmp(xtype,'cdf_epoch')
        padval = convert_to_real_cdf_epoch(padval);
    end
    cdflib.setVarPadValue(cdfid,varNum,padval);
end
        



%--------------------------------------------------------------------------
function y = convert_to_real_cdf_epoch(x)

y = todatenum(x);
y = y * 86400000 - 86400000;

%--------------------------------------------------------------------------
function xtype = guess_cdf_datatype(data,padval)

% Must find the first non-empty datum.
if iscell(data)
    C = cellfun(@isempty,data);
    idx = find(C==0);
    if isempty(idx)
        datum = padval;
    else
        datum = data{idx};
    end
else
    datum = data(1);
end

switch(class(datum))
    case 'char'
        xtype = 'cdf_uchar';
    case 'int8'
        xtype = 'cdf_int1';
    case 'uint8'
        xtype = 'cdf_uint1';
    case 'int16'
        xtype = 'cdf_int2';
    case 'uint16'
        xtype = 'cdf_uint2';
    case 'uint32'
        xtype = 'cdf_uint4';
    case 'int32'
        xtype = 'cdf_int4';
    case 'single'
        xtype = 'cdf_float';
    case 'double'
        xtype = 'cdf_double';
    case 'cdfepoch'
        xtype = 'cdf_epoch';
end
