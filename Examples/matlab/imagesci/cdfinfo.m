function info = cdfinfo(filename)
%CDFINFO Get details about a CDF file.
%   INFO = CDFINFO(FILE) gives information about a Common Data Format
%   (CDF) file.  INFO is a structure containing the following fields:
%
%     Filename             A string containing the name of the file
%
%     FileModDate          A string containing the modification date of
%                          the file
%
%     FileSize             An integer indicating the size of the file in
%                          bytes
%
%     Format               A string containing the file format (CDF)
%
%     FormatVersion        A string containing the version of the CDF
%                          library used to create the file
%
%     FileSettings         A structure containing library settings used
%                          to create the file
%
%     Subfiles             A cell array of filenames which contain the
%                          CDF file's data if it is a multifile CDF
%
%     Variables            A cell array containing details about the
%                          variables in the file (see below)
%
%     GlobalAttributes     A structure containing the global metadata
%
%     VariableAttributes   A structure containing metadata for the
%                          variables
%
%   The "Variables" field contains a cell array of details about the
%   variables in the CDF file.  Each row represents a variable in the
%   file.  The columns are:
%
%     (1) The variable's name as a string.
%
%     (2) The dimensions of the variable according to MATLAB's SIZE
%         function. 
%
%     (3) The number of records assigned for this variable.
%
%     (4) The variable's data type as it is stored in the CDF file.
%
%     (5) The record and dimension variance settings for the variable.
%         The value to the left of the slash designates whether values
%         vary by record; the values to the right designate whether
%         values vary at each dimension.
%
%     (6) The sparsity of the variables records.  Allowable values are
%         'Full', 'Sparse (padded)', and 'Sparse (nearest)'.
%
%   The "GlobalAttributes" and "VariableAttributes" structures contain a
%   field for each attribute.  Each field's name corresponds to the name
%   of the attribute, and the field contains a cell array containing the
%   entry values for the attribute.  For variable attributes, the first
%   column of the cell array contains the Variable names associated with
%   the entries, and the second contains the entry values.
%
%   NOTE: Attribute names which CDFINFO uses for field names in
%   "GlobalAttributes" and "VariableAttributes" may not match the names
%   of the attributes in the CDF file exactly.  Because attribute names
%   can contain characters which are illegal in MATLAB field names, they
%   may be translated into legal field names.  Illegal characters which
%   appear at the beginning of attributes are removed; other illegal
%   characters are replaced with underscores ('_').  If an attribute's
%   name is modified, the attribute's internal number is appended to the
%   end of the field name.  For example, '  Variable%Attribute ' might
%   become 'Variable_Attribute_013'.
%
%   Notes:
%
%     CDFINFO creates temporary files when accessing CDF files.  The
%     current working directory must be writeable.
%
%     CDFINFO performance can be noticeably influenced by the file 
%     validation done by default by the CDF library.  Please consult
%     the CDFLIB package documentation for information on controlling
%     the validation process.
%
%   Example:
%
%     info = cdfinfo('example.cdf');
%
%   Please read the file cdfcopyright.txt for more information.
%
%   See also CDFEPOCH, CDFREAD, CDFWRITE, CDFLIB.GETVALIDATE, 
%   CDFLIB.SETVALIDATE.

%   Copyright 1984-2015 The MathWorks, Inc.


% Verify existence of filename.

% Get full filename.
fid = fopen(filename);

if (fid == -1)
  
    % Look for filename with extensions.
    fid = fopen([filename '.cdf']);
    
    if (fid == -1)
        fid = fopen([filename '.CDF']);
    end
    
end

if (fid == -1)
    error(message('MATLAB:imagesci:cdflib:fileOpenError'));
else
    original_filename = filename;
    filename = fopen(fid);
    fclose(fid);
end


d = dir(filename);

% Record filesystem details and set default values.
info.Filename = d.name;
info.FileModDate = datestr(d.datenum);
info.FileSize = d.bytes;
info.Format = 'CDF';
info.FormatVersion = '';
info.FileSettings = [];
info.Subfiles = {};
info.Variables = {};
info.GlobalAttributes = [];
info.VariableAttributes = [];


% Check that we did not get handed a netCDF file instead.
try
    cdfid = cdflib.open(filename);
catch me
    % Is this a netcdf file?
    try 
        ncid = netcdf.open(original_filename);
    catch me2
        % No, it was not.
        rethrow(me);
    end
                                                
    % Yes it was a netCDF file.
    netcdf.close(ncid);
    error(message('MATLAB:imagesci:cdf:isNetCDF'));
end


[fver,release,increment] = cdflib.getVersion(cdfid);
info.FormatVersion = sprintf('%d.%d.%d', fver,release,increment);

info.FileSettings = getFileSettings(cdfid);
info.Subfiles = getSubFiles(cdfid);
[info.Variables, vinfo] = get_variable_info(cdfid);
[info.GlobalAttributes, info.VariableAttributes] = get_attributes(cdfid, vinfo);


cdflib.close(cdfid);

return

%--------------------------------------------------------------------------
function subfiles = getSubFiles(cdfid)
% record r subfiles.

fmt = cdflib.getFormat(cdfid);
if strcmp(fmt,'MULTI_FILE')
    name = cdflib.getName(cdfid);
    [pathstr,name] = fileparts(name);
    d = dir([pathstr filesep name '.v*']);
    if numel(d) == 0
        subfiles = {};
    else
        subfiles = cell(1,numel(d));
        for p = 1:numel(d)
            subfiles{p} = d(p).name;
        end
    end
else
    subfiles = {};
end


%--------------------------------------------------------------------------
function [gstruct, vstruct] = get_attributes(cdfid,all_var_info)
% Collect global and variable level attribute information.

gstruct = [];
vstruct = [];

info = cdflib.inquire(cdfid);
for attrNum = 0:(info.numvAttrs + info.numgAttrs-1)

	attrinfo = cdflib.inquireAttr(cdfid,attrNum);

    % some attribute names might not be valid MATLAB field names.
    attrname = genvarname(attrinfo.name);
    
	switch(attrinfo.scope)
		case 'GLOBAL_SCOPE'
            gstruct.(attrname) = get_global_entries(cdfid,attrNum,attrinfo);

		case 'VARIABLE_SCOPE'
            vstruct.(attrname) = get_variable_entries(cdfid,attrNum,attrinfo,all_var_info);
            
	end
end

if isempty(gstruct)
    gstruct = struct([]);
end
if isempty(vstruct)
    vstruct = struct([]);
end
return


%--------------------------------------------------------------------------
function entryInfo = get_variable_entries(cdfid,attrNum,attrinfo,all_var_info)
% Collect attribute information for the specified attribute across all
% variables.

% Only record those attributes that actually have an entry.
entryInfo = cell(attrinfo.maxEntry,2); 
count = 0;
for entryNum = 0:(attrinfo.maxEntry)
    try     
        vinfo = all_var_info(entryNum+1);
        entryVal = cdflib.getAttrEntry(cdfid,attrNum,entryNum);
        datatype = cdflib.inquireAttrEntry(cdfid,attrNum,entryNum);
        switch(datatype)
            case 'cdf_epoch'
                t = cdflib.epochBreakdown(entryVal);
                s = datestr(datenum(t(1:6)'),0);
                entryVal = sprintf('%s.%03d',s,t(7));
            case 'cdf_epoch16'
                warning(message('MATLAB:imagesci:cdf:epoch16VariableAttUnsupported', ...
                    attrinfo.name, vinfo.name));
                entryVal = [];
        end
        count = count + 1;
        entryInfo{count,1} = vinfo.name;
        entryInfo{count,2} = entryVal;
        
        
    catch me
        if strcmp(me.identifier,'MATLAB:imagesci:cdflib:libraryFailure')
            continue
        else
            rethrow(me);
        end
    end

end

% Resize the cell array to what was actually used.
entryInfo = entryInfo(1:count,:);

%--------------------------------------------------------------------------
function global_atts = get_global_entries(cdfid,attrNum,attrinfo)
% Collect attribute information for the specified attribute, but just for
% global variables.

numEntries = cdflib.getNumAttrgEntries(cdfid,attrNum);

global_atts = cell(numEntries,1);
count = 0;
for entryNum = 0:(attrinfo.maxgEntry)
    try
        entryVal = cdflib.getAttrgEntry(cdfid,attrNum,entryNum);
        datatype = cdflib.inquireAttrgEntry(cdfid,attrNum,entryNum);
        count = count + 1;
        switch(datatype)
            case 'cdf_epoch'
                t = cdflib.epochBreakdown(entryVal);
                s = datestr(datenum(t(1:6)'),0);
                entryVal = sprintf('%s.%03d',s,t(7));
            case 'cdf_epoch16'
                t = cdflib.epoch16Breakdown(entryVal);
                s = datestr(datenum(t(1:6)'),0);
                entryVal = sprintf('%s.%03d.%03d.%03d.%03d',s,t(7),t(8),t(9),t(10));
        end
        global_atts{count} = entryVal;
                
    catch me
        if strcmp(me.identifier,'MATLAB:imagesci:cdflib:libraryFailure')
            continue
        else
            rethrow(me);
        end
    end
end

%--------------------------------------------------------------------------
function [vcell, vinfo_out] = get_variable_info(cdfid)
% Colllect information about all the variables.

info = cdflib.inquire(cdfid);
majority = cdflib.getMajority(cdfid);

% the cell array is mx6, where m is the number of variables in the file
vcell = cell(info.numVars,6);

vinfo_out = struct('name','','datatype','','numElements',0, ...
    'dims',[], 'recVariance',[],'dimVariance',[]);
vinfo_out = repmat(vinfo_out,info.numVars,1);

for varnum = 0:info.numVars-1
	vinfo = cdflib.inquireVar(cdfid,varnum);
    
    % column one is the name of the variable
	vcell{varnum+1,1} = vinfo.name;
    
    % column two is the dimensions according to MATLAB's SIZE
    % function.  
    if isempty(vinfo.dims)
        theDims = [1 1];
    elseif numel(vinfo.dims) == 1
        theDims = [vinfo.dims 1];
    else
        theDims = fliplr(vinfo.dims);
    end
    if strcmp(majority,'COLUMN_MAJOR') && (numel(vinfo.dims) > 1)
        theDims = fliplr(theDims);
    end
    vcell{varnum+1,2} = theDims;
    
    
    % column three is the number of records written
    sp = cdflib.getVarSparseRecords(cdfid,varnum);
    if strcmp(sp,'NO_SPARSERECORDS')
        vcell{varnum+1,3} = cdflib.getVarNumRecsWritten(cdfid,varnum);
    else
        vcell{varnum+1,3} = cdflib.getVarMaxWrittenRecNum(cdfid,varnum) + 1;
    end

    % column four is the variable's datatype as it is stored
    % in the CDF file.  
    switch(vinfo.datatype)
        case {'cdf_byte', 'cdf_int1'}
            vcell{varnum+1,4} = 'int8';
        case {'cdf_char', 'cdf_uchar'}
            vcell{varnum+1,4} = 'char';
        case {'cdf_int2'}
            vcell{varnum+1,4} = 'int16';
        case {'cdf_uint2'}
            vcell{varnum+1,4} = 'uint16';
        case {'cdf_int4'}
            vcell{varnum+1,4} = 'int32';
        case {'cdf_uint4'}
            vcell{varnum+1,4} = 'uint32';
        case {'cdf_real4', 'cdf_float'}
            vcell{varnum+1,4} = 'single';
        case {'cdf_real8', 'cdf_double'}
            vcell{varnum+1,4} = 'double';
        case 'cdf_uint1'
            vcell{varnum+1,4} = 'uint8';
        case {'cdf_epoch'}
            vcell{varnum+1,4} = 'epoch';
        case {'cdf_epoch16'}
            vcell{varnum+1,4} = 'epoch16';
		otherwise
    		error(message('MATLAB:imagesci:cdf:unsupportedValue', ...
                'datatype', uppoer(vinfo.datatype)));
    end
    
	% 5th column is record variance / dim variance
	% This is 'T' or 'F' instead of true/false
    % This is in row-major order.
	if vinfo.recVariance
		rvariance = 'T';
	else
		rvariance = 'F';
	end

	if isempty(vinfo.dims)
		vcell{varnum+1,5} = sprintf('%s/', rvariance);
	else
		dvariance = repmat('F', 1,numel(vinfo.dimVariance));
		dvariance( vinfo.dimVariance ) = 'T';
		vcell{varnum+1,5} = sprintf('%s/%s', rvariance, fliplr(dvariance));
	end


	% column six is the sparsity of the records
	sp = cdflib.getVarSparseRecords(cdfid,varnum);
    validatestring(sp,{'NO_SPARSERECORDS','PAD_SPARSERECORDS','PREV_SPARSERECORDS'});
    switch ( sp )
        case 'NO_SPARSERECORDS'
            vcell{varnum+1,6} = 'Full';
        case 'PAD_SPARSERECORDS'
            vcell{varnum+1,6} = 'Sparse (padded)';
        case 'PREV_SPARSERECORDS'
            vcell{varnum+1,6} = 'Sparse (previous)';
    end
    
    vinfo_out(varnum+1) = vinfo;
end


return

%--------------------------------------------------------------------------
function info = getFileSettings(cdfid)

format = cdflib.getFormat(cdfid);
validatestring(format,{'SINGLE_FILE','MULTI_FILE'});
if strcmp(format,'SINGLE_FILE')
    info.Format = 'Single-file';
else
    info.Format = 'Multifile';
end


[ctype,cparms,cpct] = cdflib.getCompression(cdfid);
comps = {'GZIP_COMPRESSION','NO_COMPRESSION','RLE_COMPRESSION', ...
    'HUFF_COMPRESSION','AHUFF_COMPRESSION'};
validatestring(ctype,comps);
switch(ctype)
	case 'GZIP_COMPRESSION'
		info.Compression = 'Gzip';
		info.CompressionParam = cparms;
	case 'NO_COMPRESSION'
		info.Compression = 'Uncompressed';
		info.CompressionParam = '';
	case 'RLE_COMPRESSION'
		info.Compression = 'Run-length encoding';
		info.CompressionParam = 'Encoding of zeros';
	case 'HUFF_COMPRESSION'
		info.Compression = 'Huffman';
		info.CompressionParam = 'Optimal encoding trees';
	case 'AHUFF_COMPRESSION'
		info.Compression = 'Adaptive Huffman';
		info.CompressionParam = 'Optimal encoding trees';
end

% CDFINFOC thinks that [] is more informative than 100.
if strcmp(info.Compression,'Uncompressed')
    info.CompressionPercent = [];
else
    info.CompressionPercent = cpct;
end


% Encoding
pairs = { ...
	'NETWORK_ENCODING',    'Network';     ...
	'SUN_ENCODING',        'Sun';         ...
	'VAX_ENCODING',        'Vax';         ...
	'DECSTATION_ENCODING', 'DECStation';  ...
	'SGi_ENCODING',        'SGI';         ...
	'IBMPC_ENCODING',      'IBM-PC';      ...
	'IBMRS_ENCODING',      'IBM-RS';      ...
	'HOST_ENCODING',       'Host';        ...
	'MAC_ENCODING',        'Macintosh';   ...
	'HP_ENCODING',         'HP';          ...
	'NeXT_ENCODING',       'NeXT';        ...
	'ALPHAOSF1_ENCODING',  'Alpha OSF1';  ...
	'ALPHAVMSd_ENCODING',  'Alpha VMS g'; ...
	'ALPHAVMSg_ENCODING',  'Alpha VMS g'; ...
	'ALPHAVMSi_ENCODING',  'Alpha VMS i'};
m = containers.Map(pairs(:,1),pairs(:,2));

tmp = cdflib.inquire(cdfid);
try
    info.Encoding = m(tmp.encoding);
catch me
    if strcmp(me.identifier,'MATLAB:Containers:Map:NoKey')
    	error(message('MATLAB:imagesci:cdf:unsupportedValue', ...
            'encoding', upper(tmp.encoding)));
    else
        rethrow(me);
    end
end


validatestring(tmp.majority,{'ROW_MAJOR','COLUMN_MAJOR'});
if strcmp(tmp.majority,'ROW_MAJOR')
    info.Majority = 'Row';
else
    info.Majority = 'Column';
end

info.Copyright = cdflib.getCopyright(cdfid);

return

