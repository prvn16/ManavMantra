function data = fitsread(varargin)
%FITSREAD Read data from FITS file
%
%   DATA = FITSREAD(FILENAME) reads data from the primary data of the FITS
%   (Flexible Image Transport System) file FILENAME.  Undefined data values
%   will be replaced by NaN.  Numeric data will be scaled by the slope and
%   intercept values and is always returned in double precision.
%
%   DATA = FITSREAD(FILENAME,OPTIONS) reads data from a FITS file according
%   to the options specified in OPTIONS.  Valid options are:
%
%   EXTNAME      EXTNAME can be either 'primary', 'asciitable', 'binarytable',
%                'image', or 'unknown' for reading data from the primary
%                data array, ASCII table extension, Binary table extension,
%                Image extension or an unknown extension respectively. Only
%                one extension should be supplied. DATA for ASCII and
%                Binary table extensions is a 1-D cell array. The contents
%                of a FITS file can be located in the Contents field of the
%                structure returned by FITSINFO.
%
%   EXTNAME,IDX  Same as EXTNAME except if there is more than one of the
%                specified extension type, the IDX'th one is read.
%
%   'Raw'        DATA read from the file will not be scaled and undefined
%                values will not be replaced by NaN.  DATA will be the same
%                class as it is stored in the file.
%
%   'Info',INFO  When reading from a FITS file multiple times, passing
%                the output of FITSINFO with the 'Info' parameter helps
%                FITSREAD locate the data in the file more quickly.
%
%   'PixelRegion',{ROWS, COLS, ..., N_DIM}  
%                FITSREAD returns the sub-image specified by the boundaries
%                for an N dimensional image. ROWS, COLS, ..., N_DIM are
%                each vectors of 1-based indices given either as START,
%                [START STOP] or [START INCREMENT STOP] selecting the
%                sub-image region for the corresponding dimension. This
%                parameter is valid only for primary or image extensions.
%
%   'TableColumns',COLUMNS
%                COLUMNS is a vector with 1-based indices selecting the
%                columns to read from the ASCII or Binary table extension.
%                This vector should contain unique and valid indices into
%                the table data specified in increasing order. This
%                parameter is valid only for ASCII or Binary extensions.
%
%   'TableRows',ROWS
%                ROWS is a vector with 1-based indices selecting the rows
%                to read from the ASCII or Binary table extension. This
%                vector should contain unique and valid indices into the
%                table data specified in increasing order. This parameter
%                is valid only for ASCII or Binary extensions.
%                
%            
%   Example: Read primary data from file.
%      data = fitsread('tst0012.fits');
%
%   Example: Inspect available extensions, read 'image' extension using the
%   EXTNAME option.
%      info      = fitsinfo('tst0012.fits');
%      % List of contents, includes any extensions if present.
%      disp(info.Contents);
%      imageData = fitsread('tst0012.fits','image');
%
%   Example: Subsample the fifth plane of 'image' extension by 2.
%      info        = fitsinfo('tst0012.fits');
%      rowend      = info.Image.Size(1);
%      colend      = info.Image.Size(2);
%      primaryData = fitsread('tst0012.fits','image',...
%                     'Info', info,...
%                     'PixelRegion',{[1 2 rowend], [1 2 colend], 5 });
%
%   Example: Read every other row from a ASCII table data.
%      info      = fitsinfo('tst0012.fits');
%      rowend    = info.AsciiTable.Rows; 
%      tableData = fitsread('tst0012.fits','asciitable',...
%                   'Info',info,...
%                   'TableRows',[1:2:rowend]);
%
%   Example: Read all data for the first, second and fifth column of the
%   Binary table.
%      info      = fitsinfo('tst0012.fits');
%      rowend    = info.BinaryTable.Rows;       
%      tableData = fitsread('tst0012.fits','binarytable',...
%                   'Info',info,...
%                   'TableColumns',[1 2 5]);
%
%
%   See also FITSWRITE, FITSINFO, FITSDISP, MATLAB.IO.FITS.

%   Copyright 2001-2017 The MathWorks, Inc.

%Parse Inputs
[filename,extension,index,raw, info, pixelRegion, tableColumns, tableRows] =...
    parseInputs(varargin{:});

%Get file info. FITSINFO will check for file existence.
if isempty(info)
    info = fitsinfo(filename);
elseif ~all(isfield(info, {'Filename', 'FileModDate', 'FileSize', ...
                           'Contents', 'PrimaryData'}))
    error(message('MATLAB:imagesci:fitsread:invalidInfoStruct'));
else
    fid = fopen(filename,'r','ieee-be');
    if (fid == -1)
        try
            [~, fullFileName, hasExtSyntax] = matlab.io.fits.internal.resolveExtendedFileName(filename);
        catch 
        end
        
        if hasExtSyntax
            error(message('MATLAB:imagesci:fitsread:fileOpenExtSyntax'));
        end
        [~, fileName, fileExt] = fileparts(fullFileName);
        filename = [fileName, fileExt];
        error(message('MATLAB:imagesci:validate:fileOpen', filename));
    end
    
    d = dir(fopen(fid));
    fclose(fid);
    
    [~, file1, ext1] = fileparts(filename);
    [~, file2, ext2] = fileparts(info.Filename);
        % Check filename, modification date and file size  
    incomp_info = ~strcmpi(file1, file2) || ~strcmpi(ext1, ext2) || ...
                  ~strcmpi(info.FileModDate, datestr(d.datenum)) || ...
                   info.FileSize ~= d.bytes; 
    if incomp_info
        error(message('MATLAB:imagesci:fitsread:incompatibleInfoStruct'));
    end
end


switch lower(extension)
    case 'primary'
        data = read_image_hdu(info,1,raw,pixelRegion);
        
    case 'ascii'
        hdu_index = getHDUindex(info,index,'ascii_table');
        data = read_asciitable_hdu(info,hdu_index,raw,tableColumns,tableRows);
        
    case 'binary'
        hdu_index = getHDUindex(info,index,'binary_table');
        data = read_bintable_hdu(info,hdu_index,raw,tableColumns,tableRows);
        
    case 'image'
        hdu_index = getHDUindex(info,index,'image');
        data = read_image_hdu(info,hdu_index,raw,pixelRegion);
        
    case 'unknown'
        data = readunknown(info,index,raw);
end
%END FITSREAD


%--------------------------------------------------------------------------
function hdu_index = getHDUindex(info, index, hdu_type)
% Determine the HDU index so that the fits package can use it.  Looking at
% the offsets will do this for us.

% Collect all the HDU offsets.
num_images = 0;
num_ascii_tables = 0;
num_binary_tables = 0;
num_unknown = 0;

if isfield(info,'Image')
    num_images = numel(info.Image);
end
if isfield(info,'AsciiTable')
    num_ascii_tables = numel(info.AsciiTable);
end
if isfield(info,'BinaryTable')
    num_binary_tables = numel(info.BinaryTable);
end
if isfield(info,'Unknown')
    num_unknown = numel(info.Unknown);
end

switch(hdu_type)
    case 'image'
        if index > num_images
            error(message('MATLAB:imagesci:fitsread:indexOutOfRange'));
        end
    case 'ascii_table'
        if index > num_ascii_tables
            error(message('MATLAB:imagesci:fitsread:indexOutOfRange'));
        end
    case 'binary_table'
        if index > num_binary_tables
            error(message('MATLAB:imagesci:fitsread:indexOutOfRange'));
        end
    case 'unknown'
        if index > num_unknown
            error(message('MATLAB:imagesci:fitsread:indexOutOfRange'));
        end
end

num_extensions = num_images + num_ascii_tables + num_binary_tables + num_unknown;
offsets = zeros(1, 1 + num_extensions);

offsets(1) = info.PrimaryData.Offset;

for j = 1:num_images
    offsets(j+1) = info.Image(j).Offset;
end
n = 1 + num_images;

for j = 1:num_ascii_tables
    offsets(n+j) = info.AsciiTable(j).Offset; 
end
n = 1 + num_images + num_ascii_tables;

for j = 1:num_binary_tables
    offsets(n+j) = info.BinaryTable(j).Offset;
end
n = 1 + num_images + num_ascii_tables + num_binary_tables;

for j = 1:num_unknown
    offsets(n+j) = info.Unknown(j).Offset;
end

offsets = sort(offsets);

if index > numel(offsets)
    error(message('MATLAB:imagesci:fitsread:extensionNumber',numel(offsets), 'Image'));
end

switch(hdu_type)
    case 'image'
        hdu_index = find(info.Image(index).Offset == offsets);
    case 'ascii_table'
        hdu_index = find(info.AsciiTable(index).Offset == offsets);
    case 'binary_table'
        hdu_index = find(info.BinaryTable(index).Offset == offsets);
    case 'unknown'
        hdu_index = find(info.Unknown(index).Offset == offsets);
end





%--------------------------------------------------------------------------
function [varargin] = identifyNames(varargin)

allStrings = {'primary','image','bintable','binarytable','asciitable',...
    'table','unknown','raw','info','pixelregion', 'tablecolumns', 'tablerows'};
for k = 2:length(varargin)
    if (ischar(varargin{k}))
        param = varargin{k};
        idx = find(strcmpi(param, allStrings));
        switch length(idx)
            case 0
                error(message('MATLAB:imagesci:fitsread:unknownInputArgument', varargin{k}));
            case 1
                varargin{k} = allStrings{idx};
            otherwise
                error(message('MATLAB:imagesci:validate:ambiguousParameterName', varargin{k}));
        end
    end
end




%--------------------------------------------------------------------------
function [i_ret, index] = readIndex(i, varargin)
    index = 1;
    i_ret = i;
    if (i+1)<=nargin-1 && isnumeric(varargin{i+1})
        i_ret = i + 1;
        index  = varargin{i_ret}; 
    end




%--------------------------------------------------------------------------
function [filename,extension,index,raw,info, pixelRegion, tableColumns, tableRows] =...
    parseInputs(varargin)

%Verify inputs are correct
narginchk(1,10);

varargin = identifyNames(varargin{:});

filename    = varargin{1};
extension   = [];
index       = 1;
raw         = 0;
info        = [];
pixelRegion = [];
tableColumns= [];
tableRows   = [];

is_mult_exts = false;
i = 2;
while i <= nargin
    switch varargin{i}
        case 'primary'
            is_mult_exts = ~isempty(extension);
            extension = 'primary';
            [i, index] = readIndex(i, varargin{:});
        case {'bintable', 'binarytable'}
            is_mult_exts = ~isempty(extension);
            extension = 'binary';
            [i, index] = readIndex(i, varargin{:});
        case 'image'
            is_mult_exts = ~isempty(extension);
            extension = 'image';
            [i, index] = readIndex(i, varargin{:});
        case {'table', 'asciitable'}
            is_mult_exts = ~isempty(extension);
            extension = 'ascii';
            [i, index] = readIndex(i, varargin{:});
        case 'unknown'
            is_mult_exts = ~isempty(extension);
            extension = 'unknown';
            [i, index] = readIndex(i, varargin{:});
        case 'raw'
            raw = 1;
        case 'info'
            if (i == nargin)
                error(message('MATLAB:imagesci:fitsread:missingInfoValue'));                
            end
            i = i + 1;
            info = varargin{i};
        case 'pixelregion'
            if (i == nargin)
                error(message('MATLAB:imagesci:fitsread:missingPixelRegionValue'));                
            end
            
            i = i + 1;            
            
            if(iscell(varargin{i}) && ...                    
                    all(cellfun(@(c)isnumeric(c), varargin{i})))
                %'region', {ROWS, COLS, ...}
                pixelRegion = varargin{i};
            else
                error(message('MATLAB:imagesci:fitsread:badPixelRegion'));
            end
            
        case 'tablecolumns'
            if(i == nargin)
                error(message('MATLAB:imagesci:fitsread:missingTableParams','TableColumns'));
            end
            
            i = i + 1;
            
            if(isnumeric(varargin{i}))
                tableColumns = varargin{i};
            else
                error(message('MATLAB:imagesci:fitsread:badTableParams'));
            end

        case 'tablerows'
            if(i == nargin)
                error(message('MATLAB:imagesci:fitsread:missingTableParams','TableRows'));
            end
            
            i = i + 1;
            
            if(isnumeric(varargin{i}))
                tableRows = varargin{i};
            else
                error(message('MATLAB:imagesci:fitsread:badTableParams'));
            end
            
            
        otherwise
            if isnumeric(varargin{i})
                error(message('MATLAB:imagesci:fitsread:extensionIndex'));
            else
                error(message('MATLAB:imagesci:fitsread:expectedStringArgument'));
            end
    end    
    i = i + 1;
end

if isempty(extension)
    extension = 'primary';
elseif strcmp(extension, 'primary') && index ~= 1
   index = 1;
   warning(message('MATLAB:imagesci:fitsread:primaryIndex'));
end
if is_mult_exts
    arg_ext = extension;
    if strcmp(extension, 'ascii')
        arg_ext = 'asciitable';
    elseif strcmp(extension, 'binary')
        arg_ext = 'binarytable';
    end
    warning(message('MATLAB:imagesci:fitsread:multipleExtensions', arg_ext));
end

% Ensure that the subsetting parameters (if any) match the extension.

if(~isempty(pixelRegion) && ...
        ~( strcmpi(extension,'primary') || strcmpi(extension,'image') ))
    % pixelRegion is not empty, and extension is neither primary nor
    % image.
    error(message('MATLAB:imagesci:fitsread:pixelRegionNotSupported'));    
end
if( (~isempty(tableColumns) || ~isempty(tableRows) ) && ...
        (~( strcmpi(extension,'ascii') || strcmpi(extension,'binary')) ))
    % table rows/cols is not empty, and extension is neither binary nor
    % ascii table
    error(message('MATLAB:imagesci:fitsread:tableColsRowsNotSupported'));    
end


%END PARSEINPUTS

%--------------------------------------------------------------------------
function data = read_image_hdu(info,hdu_index,raw,pixelRegion)
%Read data from primary data

import matlab.io.*;

data = [];

fptr = fits.openDiskFile(info.Filename);
cfptr = onCleanup(@()fits.closeFile(fptr));

fits.movAbsHDU(fptr,hdu_index);

image_type = fits.getImgType(fptr);
image_size = fits.getImgSize(fptr);
if isempty(image_size) 
    if ((hdu_index == 1) && (fits.getNumHDUs(fptr) > 1))
        warning(message('MATLAB:imagesci:fitsread:emptyPrimaryDataWithOtherExt'));
    end
    return
end


%Data will be scaled by scale values BZERO, BSCALE if they exist
% bscale   = info.PrimaryData.Slope;
% bzero    = info.PrimaryData.Intercept;
nullvals = info.PrimaryData.MissingDataValue;

if raw
    % Turn off scaling.  It may still be read as double precision, though.
    fits.setBscale(fptr,1,0);
end

if isempty(pixelRegion)
    data = fits.readImg(fptr);
else
    [start,stride,stop] = parseRegion(pixelRegion, image_size);
    data = fits.readImg(fptr,start,stop,stride);
end

if raw
    switch(image_type)
        case 'BYTE_IMG'
            data = uint8(data);
        case 'SHORT_IMG'
            data = int16(data);
        case 'LONG_IMG'
            data = int32(data);
        case 'LONGLONG_IMG'
            data = int64(data);
        case 'FLOAT_IMG'
            data = single(data);
        case 'DOUBLE_IMG'
            data = double(data);
    end
else
    % Scale data and replace undefined data with NaN by default
    if ~isempty(nullvals)
        data(data==nullvals) = NaN;
    end
    
    % Scaled data is never to be single precision.
    data = double(data);
 
end


return;




%--------------------------------------------------------------------------
function data = read_asciitable_hdu(info,hdu_index,raw,tableColumns,tableRows)

import matlab.io.*;

fptr = fits.openDiskFile(info.Filename);
cfptr = onCleanup(@()fits.closeFile(fptr));

fits.movAbsHDU(fptr,hdu_index);
[~,nrows,~,~,tform] = fits.readATblHdr(fptr);

if isempty(tableColumns)
    tableColumns = 1:numel(tform);
else
    validateTableIndices(tableColumns,numel(tform));
end

if isempty(tableRows)
    tableRows = 1:nrows;
else
    validateTableIndices(tableRows,nrows);
end

data = cell(1,numel(tableColumns));
for j = 1:numel(tableColumns)
    
    if raw
        % Turn off scaling.
        fits.setTscale(fptr,tableColumns(j),1,0);
    end
    
    [~,~,~,tform,~,~,nulstr]= fits.getAColParms(fptr,tableColumns(j));
    typechar = tform(1);
    
    [coldata,nuldata] = fits.readCol(fptr,tableColumns(j));
    switch(typechar(1))
        case 'A'
            ascii_col = cell(nrows,1);
            for k = 1:size(coldata,1)
                if strncmp(coldata(k,:),nulstr,numel(nulstr))
                    ascii_col{k} = NaN;
                else
                    ascii_col{k} = coldata(k,:);
                end
            end
            datacol = ascii_col;
            
        otherwise
            if raw
                datacol = coldata;
            else
                datacol = double(coldata);
                datacol(nuldata) = NaN;
            end
            
    end
    data{j} = datacol(tableRows,:);
end

%--------------------------------------------------------------------------
function data = read_bintable_hdu(info,hdu_index,raw,tableColumns,tableRows)

import matlab.io.*;

fptr = fits.openDiskFile(info.Filename);
cfptr = onCleanup(@()fits.closeFile(fptr));

fits.movAbsHDU(fptr,hdu_index);
[nrows,~,tform] = fits.readBTblHdr(fptr);

if isempty(tableColumns)
    tableColumns = 1:numel(tform);
else 
    validateTableIndices(tableColumns,numel(tform));
end

if isempty(tableRows)
    tableRows = 1:nrows;
else 
    validateTableIndices(tableRows,nrows);
end

 data = cell(1,numel(tableColumns));
 for j = 1:numel(tableColumns)
     
     if raw
         % Turn off scaling.
         fits.setTscale(fptr,tableColumns(j),1,0);
     end
     
     [~,~,typechar]= fits.getBColParms(fptr,tableColumns(j));
     [coldata,nuldata] = fits.readCol(fptr,tableColumns(j));
     switch(typechar(1))
         case 'A'
             ascii_col = cell(nrows,1);
             for k = 1:size(coldata,1)
                 ascii_col{k} = coldata(k,:);
             end
             datacol = ascii_col;
             
         case 'L'
             % Always post-process.
             % Logical data gets turned into char.
             % True = 'T'
             % False = 'F'
             datacol = repmat(' ',size(coldata,1), size(coldata,2));
             datacol(coldata==1) = 'T';
             datacol(coldata==0) = 'F';
             datacol(nuldata==1) = ' ';
             
         case {'P','Q'}
             % variable length
             processed_data = cell(size(coldata,1),1);
             for k = 1:size(coldata,1)
                 if raw
                     processed_data{k} = coldata{k};
                 else
                     x = double(coldata{k});
                     x(nuldata{k}) = NaN;
                     processed_data{k} = x;
                 end
             end
             datacol = processed_data;
             
         otherwise
             if raw
                 datacol = coldata;
             else
                 datacol = double(coldata);
                 datacol(nuldata) = NaN;
             end

     end
     data{j} = datacol(tableRows,:);
 end



    
%--------------------------------------------------------------------------
function data = readunknown(info,index,raw)
%Read data from unknown data

data = [];


if ~isfield(info,'Unknown')
    error(message('MATLAB:imagesci:fitsread:noUnknownExtensions'));
elseif length(info.Unknown)<index
    error(message('MATLAB:imagesci:fitsread:extensionNumber', length(info.Unknown), 'Unknown'));
end

if info.Unknown(index).DataSize==0
    return;
end

startpoint = info.Unknown(index).Offset;

%Data will be scaled by scale values BZERO, BSCALE if they exist
bscale = info.Unknown(index).Slope;
bzero = info.Unknown(index).Intercept;
nullvals = info.Unknown(index).MissingDataValue;

fid = fopen(info.Filename,'r','ieee-be');
if fid==-1
    error(message('MATLAB:imagesci:validate:fileOpen',info.Filename));
end
status = fseek(fid,startpoint,'bof');
if status==-1
    msg = ferrror(fid);
    fclose(fid);
    error(message('MATLAB:imagesci:fitsread:fseekFailed',msg))
end
[data, count] = fread(fid,prod(info.Unknown(index).Size),['*' info.Unknown(index).DataType]);
fclose(fid);
if count<prod(info.Unknown(index).Size)
    warning(message('MATLAB:imagesci:fitsread:truncatedUnknownExtensionData'));
else
    reshapeDims = info.Unknown(index).Size;
    numDims     = length(reshapeDims);
    if(numDims>=2)
        %take care of the default flipping of first two dims in
        %FITSINFO.
        reshapeDims = [reshapeDims(2) reshapeDims(1) reshapeDims(3:end)];
    end
    data = permute(reshape(data,reshapeDims),...
        [2 1 3:length(reshapeDims)]);

    if ~raw && ~isempty(nullvals)
        data(data==nullvals) = NaN;
    end
    %Scale data
    if ~raw
        data = double(data)*bscale+bzero;
    end
end
%END READUNKNOWN







%--------------------------------------------------------------------------
function [start,stride,stop] = parseRegion(pixelRegion,dataDims)
% Convert {ROWS, COLS..} to {START STRIDE STOP} for the region parameter
% given for image or primary data subsetting. Validate extents.

numDims = numel(dataDims);

if(length(pixelRegion) ~= numDims)
    error(message('MATLAB:imagesci:fitsread:pixelRegionIncomplete', length( pixelRegion ), numel( dataDims )));
end

%numDims will at least be 2.
start  = ones(1,numDims);
stride = ones(1,numDims);
stop   = ones(1,numDims);

for dimInd = 1: numDims
    
    indices = pixelRegion{dimInd};
    
    switch length(indices)
        case 1 
            start(dimInd) = indices(1);
            stop(dimInd)  = indices(1);
        case 2
            start(dimInd) = indices(1);            
            stop(dimInd)  = indices(2);
        case 3
            start(dimInd)  = indices(1);
            stride(dimInd) = indices(2);
            stop(dimInd)   = indices(3);            
            
            if(indices(2)<=0)
                error(message('MATLAB:imagesci:fitsread:badIncrement', dimInd));
            end
            
        otherwise
            error(message('MATLAB:imagesci:fitsread:badIndex', dimInd));
    end
    
    if( (start(dimInd) ~= round(start(dimInd))) || ...
            (stride(dimInd) ~= round(stride(dimInd))) || ...
            (stop(dimInd) ~= round(stop(dimInd))) )
        error(message('MATLAB:imagesci:fitsread:wholeNumbersExpected', dimInd));
    end
    
    if(start(dimInd)<=0 || start(dimInd)>dataDims(dimInd))
        error(message('MATLAB:imagesci:fitsread:badStart', dimInd, dataDims( dimInd )));
    end
    if(stop(dimInd)<start(dimInd) || stop(dimInd)>dataDims(dimInd))
        error(message('MATLAB:imagesci:fitsread:badStop', dimInd, start( dimInd ), dataDims( dimInd )));
    end
    
    
end




%--------------------------------------------------------------------------
function validateTableIndices(indices, dataLength)
% Ensure that the indices for a table dimension are valid for give data
% dimension length


if(any(indices<1))
    error(message('MATLAB:imagesci:fitsread:indexLessThan1'));
end

if(any(indices>dataLength))
    error(message('MATLAB:imagesci:fitsread:indexGreaterThanData', dataLength));
    
end

%Should be unique
if(length(indices) ~= length(unique(indices)))
    error(message('MATLAB:imagesci:fitsread:nonUniqueIndices'));
end

%Should be increasing
if(~issorted(indices))
    error(message('MATLAB:imagesci:fitsread:nonIncreasingIndices'));
end

%Should be whole numbers
if(any(indices~=round(indices)))
    error(message('MATLAB:imagesci:fitsread:nonIntegerIndices'));
end

