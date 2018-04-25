function metadata = analyze75info(filename,varargin)
%ANALYZE75INFO Read metadata from header file of Mayo Analyze 7.5 data set.
%
%   METADATA = ANALYZE75INFO(FILENAME) reads the HDR file of an Analyze 7.5
%   format data set (a pair of FILENAME.HDR and FILENAME.IMG files) and
%   returns a structure METADATA whose fields contain information about the
%   data set. FILENAME is a string that specifies the name of the Analyze
%   file pair.
%
%   METADATA = ANALYZE75INFO(FILENAME, 'ByteOrder', ENDIAN) attempts to
%   read the HDR file with the byte-ordering specified in the string
%   ENDIAN. If the specified ENDIAN value results in a read error,
%   ANALYZE75INFO generates a warning and attempts to read the HDR file
%   with the opposite ByteOrder format. Valid values for ENDIAN can be
%   'ieee-le' (little endian) or 'ieee-be' (big endian).
%
%   Example 1
%   ---------
%   Use ANALYZE75INFO to read the header file brainMRI.hdr. 
%
%       metadata = analyze75info('brainMRI.hdr');
%
%   Example 2
%   ---------
%   Specify the Byte ordering of the data set. Attempt reading the
%   metadata from the header file using the specified Byte ordering.
%
%       metadata = analyze75info('brainMRI', 'ByteOrder', 'ieee-le');
%
%   See also ANALYZE75READ.

%   Following is a partial list of fields in the METADATA structure:
%
%       Filename          A string containing the name of the file
%
%       FileModDate       A string containing the modification date of
%                         the file
%
%       HdrFileSize       An integer indicating the size of the HDR file in
%                         bytes
%
%       ImgFileSize       An integer indicating the size of the IMG file in
%                         bytes
%
%       Format            A string containing the file format. This value is
%                         set to 'Analyze' for valid Analyze data sets
%
%       FormatVersion     A string or number specifying the file format
%                         version
%
%       Width             An integer indicating the width of the image
%                         in pixels
%
%       Height            An integer indicating the height of the image
%                         in pixels
%
%       BitDepth          An integer indicating the number of bits per
%                         pixel
%
%       ColorType         A string indicating the type of image; either
%                         'truecolor' for a truecolor (RGB) image, or
%                         'grayscale' for a grayscale image,
%
%       ByteOrder         A string containing the byte-ordering used to
%                         successfully read in the HDR file.
%
%       HdrDataType       Data type of the HDR file.
%
%       DatabaseName      Name of the image database.
%
%       Extents           An integer which is a required field in the header
%                         file. This value should be 16384.
%
%       SessionError      An integer indicating session error number.
%
%       Regular           A character indicating whether or not all images
%                         and volumes are of the same size. A value '1'
%                         indicates that the data is regular while '0'
%                         indicates the data is not regular.
%
%       Dimensions        A vector providing information on the image
%                         dimensions. The vector is of the form
%                             [X Y Z T]
%                         X gives the X dimension of the image, i.e. the
%                         number of pixels in an image row.
%                         Y gives the Y dimension of the image, i.e. the
%                         number of pixels in an image column.
%                         Z gives the volume Z dimension, i.e. the number of
%                         slices in a volume.
%                         T indicates the time points, i.e. the number of
%                         volumes in the dataset.
%                         Dimensions vector only returns non-zero entries.
%
%       VoxelUnits        Spatial units of measure for a voxel.
%
%       CalibrationUnits  Name of the calibration unit.
%
%       ImgDataType       Data type of the IMG file.
%
%       PixelDimensions   A vector providing information on the pixel
%                         dimensions. PixelDimensions is parallel to the
%                         Dimensions field, providing real world
%                         measurements in mm. The vector is of the form
%                             [Xp Yp Zp Tp]
%                         Xp provides the voxel width in mm.
%                         Yp provides the voxel height in mm.
%                         Zp provides the slice thickness in mm.
%                         Tp provides the time points in ms.
%                         PixelDimensions vector only returns non-zero
%                         entries.
%
%       VoxelOffset       The byte offset in the image file at which voxels
%                         start. This value may be negative to specify that
%                         the absolute value is applied for every image in
%                         the file.
%
%       CalibrationMax    Maximum Calibration value.
%
%       CalibrationMin    Minimum Calibration value.
%
%       GlobalMax         Global Maximum. The maximum pixel values for the
%                         entire dataset.
%
%       GlobalMin         Global Minimum. The minimum pixel values for the
%                         entire dataset.
%
%       Descriptor        Data description.
%
%       Orientation       Slice orientation for the dataset.
%

%   Copyright 2005-2017 The MathWorks, Inc.

% Check the number of input arguments.
narginchk(1,3);

filename = matlab.images.internal.stringToChar(filename);
varargin = matlab.images.internal.stringToChar(varargin);

% Parse input arguments.
[args, userSupplied] = parseInputs(filename, varargin{:});

% Remember if we have already warned the user about truncated header file.
alreadyWarned = false;

% Remember if this is the secondAttempt to open the header file.
secondAttempt = false;

% Open the HDR file.
[fid, metadata] = hdrFileOpen (secondAttempt);

% Read the HeaderKey information from HDR file.
readHeaderKey 

% Read the ImgDimension information from HDR file.
readImgDimension 

% Read the DataHistory information from HDR file.
readDataHistory 

% Close the HDR file.
fclose(fid);


    %%%
    %%% Function hdrFileOpen
    %%%
    function [fid, metadata] = hdrFileOpen(secondAttempt)

    filename = args.filename;
    ByteOrder = args.ByteOrder;

    % Open the file with the specified ByteOrder.
    fid = analyze75open(filename, 'hdr', 'r', ByteOrder);

    % Verify if file was opened with correct byte-ordering.
    paramValues = {'ieee-le','ieee-be'};
    
    % Read headerSize.
    headerSize = freadVerified(fid, 1, 'int32=>int32');
    % Possible extended header size
    extendedRange = int32([348 2000]);
    
    % headerSize should be within the extendedRange. Use that to check
    % if incorrect ByteOrder was used to open and read the file.
    if ~((headerSize >= extendedRange(1)) && ...
         (headerSize < extendedRange(2)))
     
        if (~secondAttempt)
            oldByteOrder = ByteOrder;
            % Using the opposite ByteOrder format to read the file.
            args.ByteOrder = paramValues{~strcmp(ByteOrder, paramValues)};
            % Indicate that this will be the secondAttempt to open the
            % file.
            secondAttempt = true;
        else
            % We have tried reading the file with both ByteOrder
            % formats. Generate error
            fclose(fid);
            error(message('images:analyze75info:hdrFileOpen'))
        end

        % Generate warning if incorrect ByteOrder was provided by user.
        if userSupplied.ByteOrder
            warning(message('images:analyze75info:incorrectByteOrder', oldByteOrder, args.ByteOrder));
        end  % if

        % Close the file and reopen with swapped ByteOrder.
        fclose(fid);
        % Try opening the file again with secondAttempt set
        [fid, metadata] = hdrFileOpen(secondAttempt);
        
    else
        % File has been opened with correct ByteOrder.
        % Reset file position indicator.
        fseek(fid, 0, 'bof');
        
        % Return useful file information in metadata consistent with
        % information returned by IMFINFO.
        metadata.Filename = fopen(fid);
        d = dir(metadata.Filename);
        metadata.FileModDate = d.date;
        
        % Header File Size will be obtained from the header key
        % structure in the header file
        metadata.HdrFileSize = [];
        
        % Image File Size will be obtained below after constructing the
        % Image filename from the header filename.
        metadata.ImgFileSize = [];
        
        metadata.Format = 'Analyze';
        metadata.FormatVersion = '7.5';
        metadata.Width = [];
        metadata.Height = [];
        metadata.BitDepth = [];
        metadata.ColorType = 'unknown';
        
        % Additional field to keep track of ByteOrdering.
        metadata.ByteOrder = ByteOrder;
        
        % Construct Image filename using Filename obtained from
        % Metadata struct.
        [pname, fname, ~] = fileparts(metadata.Filename);
        ImgFilename = fullfile(pname, [fname '.img']);
        
        % Obtain Image file size.
        try
            v = dir(ImgFilename);
            metadata.ImgFileSize = v.bytes;
        catch
            warning(message('images:analyze75info:imgFileSize', ImgFilename));
        end  %  try-catch
        
    end  % if

    end  % hdrFileOpen


    %%%
    %%% Function readHeaderKey
    %%%
    function readHeaderKey

    % Read all information in the HeaderKey structure.
    metadata.HdrFileSize  = freadVerified(fid, 1, 'int32=>int32');
    metadata.HdrDataType  = deblank(freadVerified(fid, 10, 'uchar=>char')');
    metadata.DatabaseName = deblank(freadVerified(fid, 18, 'uchar=>char')');
    metadata.Extents      = freadVerified(fid, 1, 'int32=>int32');
    metadata.SessionError = freadVerified(fid, 1, 'int16=>int16');
    Regular               = freadVerified(fid,1, 'uchar=>char');
    switch Regular
        case 'r'
            metadata.Regular = true;
        otherwise
            metadata.Regular = false;
    end  % switch

    %Advance one position for an unused character.
    fseek(fid,1,'cof');

    end  % readHeaderKey


    %%%
    %%% Function readImgDimension
    %%%
    function readImgDimension

    % Read all information in the ImgDimension structure in the header file.
    Dimensions = freadVerified(fid, 8, 'int16=>int16');
    % Return useful dimension information.
    metadata.Dimensions = Dimensions(find(Dimensions(2:8))+1)';
    metadata.Width = metadata.Dimensions(1);
    metadata.Height= metadata.Dimensions(2);
    metadata.VoxelUnits  = deblank(freadVerified(fid, 4, 'uchar=>char')');
    metadata.CalibrationUnits = deblank(freadVerified(fid, 8, ...
        'uchar=>char')');

    % Advance 2 positions for an unused field.
    fseek(fid,2,'cof');

    ImgDataType = freadVerified(fid, 1, 'int16=>int16');

    switch ImgDataType

        case int16(0)
            metadata.ImgDataType = 'DT_UNKNOWN';
        case int16(1)
            metadata.ImgDataType = 'DT_BINARY';
            metadata.ColorType = 'grayscale';
        case int16(2)
            metadata.ImgDataType = 'DT_UNSIGNED_CHAR';
            metadata.ColorType = 'grayscale';
        case int16(4)
            metadata.ImgDataType = 'DT_SIGNED_SHORT';
            metadata.ColorType = 'grayscale';
        case int16(8)
            metadata.ImgDataType = 'DT_SIGNED_INT';
            metadata.ColorType = 'grayscale';
        case int16(16)
            metadata.ImgDataType = 'DT_FLOAT';
            metadata.ColorType = 'grayscale';
        case int16(32)
            metadata.ImgDataType = 'DT_COMPLEX';
            metadata.ColorType = 'grayscale';
        case int16(64)
            metadata.ImgDataType = 'DT_DOUBLE';
            metadata.ColorType = 'grayscale';
        case int16(128)
            metadata.ImgDataType = 'DT_RGB';
            metadata.ColorType = 'truecolor';
        case int16(255)
            metadata.ImgDataType = 'DT_ALL';

    end  % switch

    metadata.BitDepth   = freadVerified(fid, 1, 'int16=>int16');

    %Advance 2 positions for an unused field.
    fseek(fid,2,'cof');
    PixelDimensions   = freadVerified(fid, 8, 'float32=>float32');
    metadata.PixelDimensions = PixelDimensions(...
        find(PixelDimensions(2:8))+1)';
    metadata.VoxelOffset     = freadVerified(fid, 1, 'float32=>float32');

    %Advance 12 positions for an unused field.
    fseek(fid,12,'cof');
    metadata.CalibrationMax = freadVerified(fid, 1, 'float32=>float32');
    metadata.CalibrationMin = freadVerified(fid, 1, 'float32=>float32');
    metadata.Compressed     = freadVerified(fid, 1, 'float32=>float32');
    metadata.Verified       = freadVerified(fid, 1, 'float32=>float32');
    metadata.GlobalMax      = freadVerified(fid, 1, 'int32=>int32');
    metadata.GlobalMin      = freadVerified(fid, 1, 'int32=>int32');

    end  % readImgDimension


    %%%
    %%% Function readDataHistory
    %%%
    function readDataHistory

    % Read all information for ImgDimension structure.
    metadata.Descriptor   = deblank(freadVerified(fid, 80, 'uchar=>char')');
    metadata.AuxFile      = deblank(freadVerified(fid, 24, 'uchar=>char')');
    Orientation           = freadVerified(fid, 1, 'uint8=>uint8');
    switch Orientation

        case 0
            metadata.Orientation = 'Transverse unflipped';
        case 1
            metadata.Orientation = 'Coronal unflipped';
        case 2
            metadata.Orientation = 'Sagittal unflipped';
        case 3
            metadata.Orientation = 'Transverse flipped';
        case 4
            metadata.Orientation = 'Coronal flipped';
        case 5
            metadata.Orientation = 'Sagittal flipped';
        otherwise
            metadata.Orientation = 'Orientation unavailable';

    end  % switch

    metadata.Originator   = deblank(freadVerified(fid, 10, 'uchar=>char')');
    metadata.Generated    = deblank(freadVerified(fid, 10, 'uchar=>char')');
    metadata.Scannumber   = deblank(freadVerified(fid, 10, 'uchar=>char')');
    metadata.PatientID    = deblank(freadVerified(fid, 10, 'uchar=>char')');
    metadata.ExposureDate = deblank(freadVerified(fid, 10, 'uchar=>char')');
    metadata.ExposureTime = deblank(freadVerified(fid, 10, 'uchar=>char')');

    %Advance 3 positions for an unused field.
    fseek(fid,3,'cof');
    metadata.Views          = freadVerified(fid, 1, 'int32=>int32');
    metadata.VolumesAdded   = freadVerified(fid, 1, 'int32=>int32');
    metadata.StartField     = freadVerified(fid, 1, 'int32=>int32');
    metadata.FieldSkip      = freadVerified(fid, 1, 'int32=>int32');
    metadata.OMax           = freadVerified(fid, 1, 'int32=>int32');
    metadata.OMin           = freadVerified(fid, 1, 'int32=>int32');
    metadata.SMax           = freadVerified(fid, 1, 'int32=>int32');
    metadata.SMin           = freadVerified(fid, 1, 'int32=>int32');

    end  % readDataHistory


    %%%
    %%% Function freadVerified
    %%%
    function out = freadVerified(fid, count, precision)
    % This function reads the specified number of bytes using fread and
    % checks for premature EOF. In that case, a warning is generated the
    % first time this is encountered in the file.

    temp = fread(fid, count, precision);
    if isempty(temp)
        if ~alreadyWarned
            warning(message('images:analyze75info:truncatedHeaderFile'))
                    
            % Set alreadyWarned to true so that we don't warn again.
            alreadyWarned = true;
        end  % if

    end  % if

    out = temp;

    end  % freadVerified

end  % analyze75info


%%%
%%% Function parseInputs
%%%
function [args, userSupplied] = parseInputs(filename, varargin)

% Check if filename is a string.
validateattributes(filename, {'char'}, {}, mfilename, 'FileName', 1);

% Verify that filename is a valid Analyze 7.5 format file.
if ~isanalyze75(filename)
    error(message('images:analyze75info:invalidAnalyze75file', filename));
end

args.filename = filename;

% Parse remaining arguments based on their number.
if (nargin > 1)

    paramStrings = {'byteorder'};

    % Obtain and validate each parameter value pair.
    for k = 1:2:length(varargin)

        % Get Parameter Name.
        param = lower(varargin{k});
        % Check if Parameter Name is a string.
        validateattributes(param ,{'char'},{},mfilename,'Parameter Name', k+1);

        % Compare and validate Parameter Name.
        idx = strmatch(param, paramStrings);
        if (isempty(idx))
            error(message('images:analyze75info:unrecognizedParameterName', param));
        elseif (length(idx) > 1)
            error(message('images:analyze75info:ambiguousParameterName', param));
        end  % if

        % Get Parameter Value.
        switch (paramStrings{idx})
            case 'byteorder'
                if (k == length(varargin))
                    error(message('images:analyze75info:missingByteOrder'))
                else
                    paramValues = {'ieee-le','ieee-be'};
                    value = varargin{k+1};
                end % if

                % Compare and validate Parameter value.
                idx = strmatch(value, paramValues);

                if ( isempty(idx) || (numel(idx) > 1) )
                    error(message('images:analyze75info:badByteOrderValue', value));
                end

                args.ByteOrder = value;
                userSupplied.ByteOrder = true;

        end  % switch

    end   % for
else

    % Assign default values to parameters.
    args.ByteOrder = 'ieee-be';
    % Flag to indicate user did not supply ByteOrder.
    userSupplied.ByteOrder = false;

end  % if

end  % parseInputs
