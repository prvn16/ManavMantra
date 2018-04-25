function im = multibandread(filename,dims,precision,...
    offset,interleave,byteOrder,varargin)
%MULTIBANDREAD Read band interleaved data from a binary file
%   X = MULTIBANDREAD(FILENAME,SIZE,PRECISION,
%                      OFFSET,INTERLEAVE,BYTEORDER)
%   reads band-sequential (BSQ), band-interleaved-by-line (BIL), or
%   band-interleaved-by-pixel (BIP) data from a binary file, FILENAME.  X is
%   a 2-D array if only one band is read, otherwise it is 3-D. X is returned
%   as an array of data type double by default.  Use the PRECISION argument
%   to map the data to a different data type.
%
%   X = MULTIBANDREAD(FILENAME,SIZE,PRECISION,OFFSET,INTERLEAVE,
%                    BYTEORDER,SUBSET,SUBSET,SUBSET)
%   reads a subset of the data in the file. Up to 3 SUBSET parameters may be
%   used to subset independently along the Row, Column, and Band dimensions.
%
%   In addition to BSQ, BIL, and BIP files, multiband imagery may be stored 
%   using the TIFF file format.  In that case, the data should be imported
%   with IMREAD.
%
%   Parameters:
%
%     FILENAME: A string containing the name of the file to be read.
%
%     DIMS: A 3 element vector of integers consisting of
%     [HEIGHT, WIDTH, N]. HEIGHT is the total number of rows, WIDTH is
%     the total number of elements in each row, and N is the total number
%     of bands. This will be the dimensions of the data if it read in its
%     entirety.
%
%     PRECISION: A string to specify the format of the data to be read. For
%     example, 'uint8', 'double', 'integer*4'. By default X is returned as
%     an array of class double. Use the PRECISION parameter to format the
%     data to a different class.  For example, a precision of
%     'uint8=>uint8' (or '*uint8') will return the data as a UINT8 array.
%     'uint8=>single' will read each 8 bit pixel and store it in MATLAB in
%     single precision.  MULTIBANDREAD will attempt to use the efficient
%     MEMMAPFILE function if the precision string corresponds to a native
%     MATLAB type.  See the help for FREAD for a more complete description
%     of PRECISION.
%
%     OFFSET: The zero-based location of the first data element in the file.
%     This value represents number of bytes from the beginning of the file
%     to where the data begins.
%
%     INTERLEAVE: The format in which the data is stored.  This can be
%     either 'bsq','bil', or 'bip' for Band-Sequential,
%     Band-Interleaved-by-Line or Band-Interleaved-by-Pixel respectively.
%
%     BYTEORDER: The byte ordering (machine format) in which the data is
%     stored. This can be 'ieee-le' for little-endian or 'ieee-be' for
%     big-endian.  All other machine formats described in the help for FOPEN
%     are also valid values for BYTEORDER.
%
%     SUBSET: (optional) A cell array containing either {DIM,INDEX} or
%     {DIM,METHOD,INDEX}. DIM is one of three strings: 'Column', 'Row', or
%     'Band' specifying which dimension to subset along.  METHOD is 'Direct'
%     or 'Range'. If METHOD is omitted, then the default is 'Direct'. If
%     using 'Direct' subsetting, INDEX is a vector specifying the indices to
%     read along the Band dimension.  If METHOD is 'Range', INDEX is a 2 or
%     3 element vector of [START, INCREMENT, STOP] specifying the range and
%     step size to read along the dimension. If INDEX is 2 elements, then
%     INCREMENT is assumed to be one.
%
%   Examples:
%
%   % Setup initial parameters for a dataset.
%   rows=3; cols=3; bands=5;
%   filename = tempname;
%
%   % Define the dataset.
%   fid = fopen(filename, 'w', 'ieee-le');
%   fwrite(fid, 1:rows*cols*bands, 'double');
%   fclose(fid);
%
%   % Read the every other band of the data using the Band-Sequential format.
%   im1 = multibandread(filename, [rows cols bands], ...
%             'double', 0, 'bsq', 'ieee-le', ...
%             {'Band', 'Range', [1 2 bands]} )
%
%   % Read the first two rows and columns of data using
%   % Band-Interleaved-by-Pixel format.
%   im2 = multibandread(filename, [rows cols bands], ...
%             'double', 0, 'bip', 'ieee-le', ...
%             {'Row', 'Range', [1 2]}, ...
%             {'Column', 'Range', [1 2]} )
%
%   % Read the data using Band-Interleaved-by-Line format.
%   im3 = multibandread(filename, [rows cols bands], ...
%             'double', 0, 'bil', 'ieee-le')
%
%   % Delete the file that we created.
%        delete(filename);
%
%   % The FITS file 'tst0012.fits' contains int16 BIL data starting at
%   % byte 74880.
%   im4 = multibandread( 'tst0012.fits', [31 73 5], ...
%             'int16', 74880, 'bil', 'ieee-be', ...
%             {'Band', 'Range', [1 3]} );
%   im5 = double(im4)/max(max(max(im4)));
%   imagesc(im5);
%
%   See also FREAD, FWRITE, IMREAD, MEMMAPFILE, MULTIBANDWRITE.

%   Copyright 2001-2014 The MathWorks, Inc.

narginchk(6,9);
nargoutchk(0,4);

% Get any subsetted dimensions
info = parseInputs(filename, dims,...
    precision, offset, byteOrder, varargin{:});

% Make sure that the file is large enough for the requested operation
fileInfo = dir(info.filename);
fileSize = fileInfo.bytes;
if fileSize < info.offset + info.dataSize
    error(message('MATLAB:imagesci:multibandread:badFileSize'));
end

% Take care of the file ordering
interleave = validatestring(interleave,{'bil','bip','bsq'});
switch lower(interleave)
    case 'bil'
        readOrder = [2 3 1];
        permOrder = [3 1 2];
    case 'bip'
        readOrder = [3 2 1];
        permOrder = readOrder;
    case 'bsq'
        readOrder = [2 1 3];
        permOrder = readOrder;
end

% Create a cell array of the dimension indices
ndx = {info.rowIndex info.colIndex info.bandIndex};

% Decide which reading algorithm to use
if useMemMappedFile(info.inputClass)
    try
        % Read from a memory mapped file
        im = readMemFile(filename, info, ndx, readOrder);
    catch  %#ok<CTCH>
        % We may not have been able to map the file into memory.
        % In this case, try reading the data directly from the disk.
        info = getDefaultIndices(info, false);
        ndx = {info.rowIndex info.colIndex info.bandIndex};
        im = readDiskFile(filename, info, ndx, readOrder);
    end
    im = permute(im, permOrder);
elseif strcmpi(interleave, 'bip') && ...
        (isempty(info.subset) || isequal(info.subset, 'b'))
    % Special optimization for BIP cases
    if isempty(info.subset)
        % Read full dataset
        im = readDiskFileBip(filename, info);
    else
        % Read a subset.
        im = readDiskFileBipSubset(filename, info);
    end
else
    % Use the general-purpose routine.
    im = readDiskFile(filename, info, ndx, readOrder);
    im = permute(im, permOrder);
end


%==========================================================================
function im = readMemFile(filename, info, ndx, readOrder)
% Memory map the file
m = memmapfile(filename, 'offset', info.offset, 'repeat', 1, ...
    'format', {info.inputClass info.dims(readOrder) 'x'});

% Permute the indices so that they are in read order
ndx = ndx(readOrder);

% Do any necessary subsetting.
im = m.data.x(ndx{1}, ndx{2}, ndx{3});

[~, ~,endian] = computer;

% Change the endianness, if necessary
if strcmpi(endian, 'l')
    if strcmpi(info.byteOrder, 'ieee-be') || strcmpi(info.byteOrder, 'b')
        im = swapbytes(im);
    end
else
    if strcmpi(info.byteOrder, 'ieee-le') || strcmpi(info.byteOrder, 'l')
        im = swapbytes(im);
    end
end

% Change the type of the output, if necessary.
if ~strcmp(info.inputClass, info.outputClass)
    im = feval(info.outputClass, im);
end

%==========================================================================
function im = readDiskFile(filename, info, srcNdx, readOrder)
% A general-purpose routine to read from the disk
% We use fread, which will handle non-integral (bit) types.
info.fid = fopen(filename, 'r', info.byteOrder);
lastReadPos = 0;
skip(info,info.offset,lastReadPos);

% Do permutation of sizes and indices
srcNdx = srcNdx(readOrder);
dim = info.dims(readOrder);

% Preallocate image output array
outputSize = [length(srcNdx{1}), length(srcNdx{2}), length(srcNdx{3})];
im = zeros(outputSize(1), outputSize(2), outputSize(3), info.outputClass);

% Determine the start and ending read positions
kStart=srcNdx{1}(1);
kEnd=srcNdx{1}(end);

% srcNdx is a vector which contains the desired row, column, and band
% subsets of the input.  destNdx contains the destination in the output
% matrix.
destNdx(3) = 1;
for i=srcNdx{3}
    pos(1) = (i-1)*dim(1)*dim(2);
    destNdx(2) = 1;
    for j=srcNdx{2}
        pos(2) = (j-1)*dim(1);

        % Determine what to read
        posStart = pos(1) + pos(2) + kStart;
        posEnd = pos(1) + pos(2) + kEnd;
        readAmt = posEnd - posStart + 1;

        % Read the entire dimension
        skipNum = (posStart-1)-lastReadPos;
        if skipNum
            if info.bitPrecision
                fread(info.fid, skipNum, info.precision);
            else
                fseek(info.fid, skipNum*info.eltsize, 'cof');
            end
        end
        [data, count] = fread(info.fid, readAmt, info.precision);
        if count ~= readAmt
            msg = ferror(info.fid);
            fclose(info.fid);
            error(message('MATLAB:imagesci:multibandread:readProblem', msg));
        end
        lastReadPos = posEnd;


        % Assign the specified subset of what was read to the output matrix
        im(:,destNdx(2),destNdx(3)) = data(srcNdx{1}-kStart+1);
        destNdx(2) = destNdx(2) + 1;
    end
    destNdx(3) = destNdx(3) + 1;
end

fclose(info.fid);

%==========================================================================
function im = readDiskFileBip(filename, info)
% Read a file from disk when no subsetting is requested.  Only a single
% call to FREAD is necessary.
info.fid = fopen(filename, 'r', info.byteOrder);
lastReadPos = 0;
skip(info,info.offset,lastReadPos);

% extract the dims into meaningful terms
height = info.dims(1);
width  = info.dims(2);
bands  = info.dims(3);

% Read all bands at once.
im = fread(info.fid,prod(info.dims),['1*' info.precision]);
im = reshape(im,[bands width height]);
im = permute(im,[3 2 1]);
fclose(info.fid);

%==========================================================================
function im = readDiskFileBipSubset(filename, info)
% Read a file from disk, using optimizations applicable to the BIP case
% when we read bands at a time.
info.fid = fopen(filename, 'r', info.byteOrder);
lastReadPos = 0;
skip(info,info.offset,lastReadPos);

% extract the dims into meaningful terms
height = info.dims(1);
width  = info.dims(2);
bands  = info.dims(3);
im = zeros(width, height, numel(info.bandIndex), info.outputClass);

% Read the file, one band at a time.
plane = 1;
for i=info.bandIndex
    skip(info,info.offset,i-1);
    [data,count] = fread(info.fid, height*width, ...
        ['1*' info.precision], ...
        (bands-1)*info.eltsize);
    if count ~= height*width
        msg = ferror(info.fid);
        fclose(info.fid);
        error(message('MATLAB:imagesci:multibandread:readProblem', msg));
    end
    im(:,:,plane) = reshape(data,size(im(:,:,plane)));
    plane = plane + 1;
end

im = permute(im,[2 1 3]);
fclose(info.fid);



%==========================================================================
function skip(info,offset,skipSize)
% Skip to a specified position in the file
if info.bitPrecision
    fseek(info.fid,offset,'bof');
    fread(info.fid,skipSize,info.precision);
else
    fseek(info.fid,offset+skipSize*info.eltsize,'bof');
end

%==========================================================================
function info = parseInputs(filename, dims, precision, ...
    offset, byteOrder, varargin)
% Open the file. Determine pixel width and input/output classes.
fid = fopen(filename,'r',byteOrder);
if fid == -1
    error(message('MATLAB:imagesci:validate:fileOpen', filename));
end
info = getPixelInfo(fid,precision);
info.filename = fopen(fid);
fclose(fid);

% Assign sizes
validateattributes(offset,{'numeric'},{'nonnegative'});
info.offset = offset;

validateattributes(dims,{'numeric'},{'numel',3});
info.dims = dims;
info.byteOrder  = byteOrder;

% Calculate the size of the data
if info.bitPrecision
    info.dataSize = prod(info.dims) * (info.eltsize/8);
else
    info.dataSize = prod(info.dims) * info.eltsize;
end

info.rowIndex  = ':';
info.colIndex  = ':';
info.bandIndex = ':';
bUseMemMap = useMemMappedFile(info.inputClass);
info = getDefaultIndices(info, bUseMemMap);

% 'subset' is a string with 0-3 characters (r, c, b). The string
% represents which dimension is being subset
info.subset = '';

% Analyze the parameters that specify the subset of interest
if numel(varargin) > 0
    for i=1:length(varargin)
        % Determine the subsetting method
        methods = {'direct', 'range'};
        if length(varargin{i})==2
            %Default to 'Direct'
            method = 'direct';
            n = 2;
        else
            param = varargin{i}{2};
            match = find(strncmpi(param,methods,numel(param)));
            if ~isempty(match)
                method = methods{match};
            else
                error(message('MATLAB:imagesci:multibandread:badSubset', param));
            end
            n = 3;
        end
        % Determine the orientation of the subset
        dimensions = {'row', 'column', 'band'};
        param = varargin{i}{1};
        match = find(strncmpi(param,dimensions,numel(param)));
        if ~isempty(match)
            dim = dimensions{match};
        else
            error(message('MATLAB:imagesci:multibandread:unrecognizedDimSubsetString', varargin{ i }{ 1 }));
        end
        % Get the indices for the subset
        info.subset(i) = dimensions{match}(1); %build a string 'rcb'
        switch dim
            case 'row'
                info.rowIndex = getIndices(method, i, n, varargin{:});
            case 'column'
                info.colIndex = getIndices(method, i, n, varargin{:});
            case 'band'
                info.bandIndex = getIndices(method, i, n, varargin{:});
        end
    end
end

%==========================================================================
function ndx = getIndices(method, i, n, varargin)
% Use a subsetting method
if strcmp(method,'direct')
    ndx = varargin{i}{n};
else
    switch length(varargin{i}{n})
        case 2
            ndx = feval('colon',varargin{i}{n}(1),varargin{i}{n}(2));
        case 3
            ndx = feval('colon',varargin{i}{n}(1), ...
                varargin{i}{n}(2), varargin{i}{n}(3));
        otherwise
            error(message('MATLAB:imagesci:multibandread:badSubsetRange'))
    end
end

%==========================================================================
function info = getPixelInfo(fid, precision)
% Returns size of each pixel.  Size is in bytes unless precision is
% bitN or ubitN, in which case width is in bits.

% Determine if precision is bitN or ubitN
info.bitPrecision = ~isempty(strfind(precision,'bit'));

% Reformat the precision string and determine if bit precision is in the
% shorthand notation
bitPrecisionWithShorthand = false;
info.precision = precision(~isspace(precision));
if strncmp(info.precision(1),'*',1)
    % For bit precision with *source shorthand, set precision to the input
    % precision.  fread will know how to determine the output class, which
    % is the smallest class that can contain the input.
    if info.bitPrecision
        info.precision = precision;
        bitPrecisionWithShorthand = true;
    else
        info.precision(1) = [];
        info.precision = [info.precision '=>' info.precision];
    end
end

% Determine the input and output types (classes)
lastInputChar = strfind(info.precision,'=>')-1;
if isempty(lastInputChar)
    lastInputChar=length(info.precision);
end
if bitPrecisionWithShorthand
    info.inputClass = info.precision(2:lastInputChar);
else
    info.inputClass = precision(1:lastInputChar);
end
p = ftell(fid);
tmp = fread(fid, 1, info.precision);
info.eltsize = ftell(fid)-p;
info.outputClass = class(tmp);

% If bit precision with shorthand, set the final precision to the longhand 
% notation, then parse the precision string to determine eltsize
if info.bitPrecision
    if bitPrecisionWithShorthand
        info.precision = [info.inputClass '=>' info.outputClass];
    end
    info.eltsize = sscanf(info.inputClass(~isletter(info.inputClass)), '%d');
    if isempty(info.eltsize)
        error(message('MATLAB:imagesci:multibandread:badPrecision', info.precision));
    end
end

%==========================================================================
function info = getDefaultIndices(info, bUseMemMap)
if ~bUseMemMap
    if ischar(info.rowIndex) && info.rowIndex  == ':'
        info.rowIndex  = 1:info.dims(1);
    end
    if ischar(info.colIndex) && info.colIndex  == ':'
        info.colIndex  = 1:info.dims(2);
    end
    if ischar(info.bandIndex) && info.bandIndex  == ':'
        info.bandIndex  = 1:info.dims(3);
    end
end

%==========================================================================
function rslt = useMemMappedFile(type)
switch(type)
    case {'int8' 'uint8' 'int16' 'uint16' 'int32' 'uint32' ...
            'int64' 'uint64' 'single' 'double'}
        rslt = true;
    otherwise
        rslt = false;
end
