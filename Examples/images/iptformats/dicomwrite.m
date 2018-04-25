function varargout = dicomwrite(X, varargin)
%DICOMWRITE   Write images as DICOM files.
%   DICOMWRITE(X, FILENAME) writes the binary, grayscale, or truecolor
%   image X to the file named in FILENAME.
%
%   DICOMWRITE(X, MAP, FILENAME) writes the indexed image X with colormap
%   MAP.
%
%   DICOMWRITE(..., PARAM1, VALUE1, PARAM2, VALUE2, ...) specifies
%   optional metadata to write to the DICOM file or parameters that
%   affect how the DICOM file is written.  PARAM1 is a string containing
%   the metadata attribute name or a DICOMWRITE-specific option.  VALUE1
%   is the corresponding value for the attribute or option.
%
%   Acceptable attribute names are listed in the data dictionary
%   dicom-dict.txt.  In addition, the following DICOM-specific options
%   are allowed:
%
%     'Endian'                The byte-ordering for the file: 'big' or
%                             'little' (default).  
%
%     'VR'                    Whether the value representation should be
%                             written to the file: 'explicit' or 'implicit'
%                             (default). 
%
%     'CompressionMode'       The type of compression to use when storing
%                             the image: 'JPEG lossless', 'JPEG lossy',
%                             'JPEG2000 lossy', 'JPEG2000 lossless', 'RLE',
%                             or 'none' (default).
%
%     'TransferSyntax'        A DICOM UID specifying the Endian, VR and
%                             CompressionMode options. 
%
%     'Dictionary'            DICOM data dictionary containing private data
%                             attributes.
%
%     'WritePrivate'          Logical value indicating whether private data
%                             should be written to the file: true or false
%                             (default).
%
%     'CreateMode'            The method for creating the data to put in the
%                             new file. 'create' (default) verifies input
%                             values and makes missing data values. 'copy'
%                             simply copies all values from the input and
%                             does not generate missing values.  See the note
%                             below about file creation.
%
%     'MultiframeSingleFile'  Logical value indicating whether multiframe
%                             imagery should be written to one file. When
%                             true (default) one file is created regardless
%                             how many frames X contains.  When false, one
%                             file is written for each frame in the image.
%
%     'UseMetadataBitDepths'  Logical value indicating whether the metadata
%                             values of 'BitStored', 'BitsAllocated', and
%                             'HighBit' should be preserved. When true,
%                             existing values will be preserved. When false
%                             (default) these values are computed based on
%                             the datatype of the pixel data. When
%                             'CreateMode' is 'Create', this field has no
%                             effect.
%
%   NOTE: FILE ENCODING
%   -------------------
%
%   If the TransferSyntax option is provided, DICOMWRITE ignores the values
%   of the Endian, VR, and CompressionMode options. If TransferSyntax is
%   not provided, DICOMWRITE uses the value of CompressionMode, if
%   specified, and ignores Endian and VR.  If neither TransferSyntax or
%   CompressionMode are provided, DICOMWRITE uses the values of Endian and
%   VR.  Specifying an Endian value of 'big' and a VR value of 'implicit'
%   is not allowed.
%
%
%   DICOMWRITE(..., 'ObjectType', IOD, ...) writes a file containing the
%   necessary metadata for a particular type of DICOM Information Object
%   (IOD).  Supported IODs are:
%
%     'Secondary Capture Image Storage' (default)
%     'CT Image Storage'
%     'MR Image Storage'
%
%   DICOMWRITE(..., 'SOPClassUID', UID, ...) provides an alternate method
%   for specifying the IOD to create.  UID is the DICOM unique identifier
%   corresponding to one of the IODs listed above.
%
%   DICOMWRITE(..., META_STRUCT, ...) specifies optional metadata or
%   options for the file via a structure.  The structure's fieldnames are
%   analogous to the parameter strings in the syntax shown above, and a
%   field's value is that parameter's value.
%
%   DICOMWRITE(..., INFO, ...) uses the metadata structure INFO produced
%   by DICOMINFO.
%
%   STATUS = DICOMWRITE(...) returns information about the metadata and
%   the descriptions used to generate the DICOM file.  STATUS is a
%   structure with the following fields:
%
%     'BadAttribute'      The attribute's internal description is bad.
%                         It may be missing from the data dictionary or
%                         have incorrect data in its description.
%
%     'MissingCondition'  The attribute is conditional but no condition
%                         has been provided about when to use it.
%
%     'MissingData'       No data was provided for an attribute that must
%                         appear in the file.
%
%     'SuspectAttribute'  Data in the attribute does not match a list of
%                         enumerated values in the DICOM spec.
%
%
%   NOTE: FILE CREATION
%   -------------------
% 
%   The DICOM format specification lists several Information Object
%   Definitions (IODs) that can be created.  These IODs correspond to
%   images and metadata produced by different real-world modalities (e.g.,
%   MR, X-ray, Ultrasound, etc.).  For each type of IOD, the DICOM
%   specification defines the set of metadata that must be present and
%   possible values for other metadata.
% 
%   DICOMWRITE fully implements a limited number of these IODs, listed
%   above in the ObjectType syntax.  For these IODs, DICOMWRITE verifies
%   that all required metadata attributes are present, creates missing
%   attributes, if necessary, and specifies default values where possible.
%   Using these supported IODs is the best way to ensure that the files you
%   create conform to the DICOM specification.  This is DICOMWRITE's
%   default behavior and corresponds to a CreateMode option value of
%   'create'.
%
%   To write DICOM files for IODs that DICOMWRITE doesn't implement with
%   verification, use the 'copy' value for the CreateMode option.  In this
%   mode, DICOMWRITE writes the image data to a file including the metadata
%   that you specify as a parameter, shown above in the INFO syntax. The
%   purpose of this option is to take metadata from an existing file of the
%   same modality or IOD and use it to create a new DICOM file with
%   different image pixel data.      
%
%
%   WARNING
%   -------
%
%   Use caution when using the 'copy' CreateMode. Because DICOMWRITE copies
%   metadata to the file without verification in this mode, it is possible
%   to create a DICOM file that may not conform to the DICOM standard. For
%   example, the file may be missing required metadata, contain superfluous
%   metadata, or the metadata may no longer correspond to the modality
%   settings used to generate the original image. When using the 'copy'
%   CreateMode, make sure that the metadata you use is from the same
%   modality and IOD.  If the copy you make is unrelated to the original
%   image, use DICOMUID to create new unique identifiers for series and
%   study metadata.  See the IOD descriptions in part 3 of the DICOM spec
%   for more information on appropriate IOD values.
%
%
%   Examples
%   --------
%
%   % Write a basic "secondary capture" image.
%   X = dicomread('CT-MONO2-16-ankle.dcm');
%   dicomwrite(X, 'sc_file.dcm');
%
%   % Write a CT image with metadata.
%   % In this mode, DICOMWRITE verifies the metadata written
%   % to the file.
%   metadata = dicominfo('CT-MONO2-16-ankle.dcm');
%   dicomwrite(X, 'ct_file.dcm', metadata);
%
%   % Copy all metadata from one file to another.
%   % In this mode, DICOMWRITE does not verify the metadata written
%   % to the file.
%   dicomwrite(X, 'ct_copy.dcm', metadata, 'CreateMode', 'copy');
%
%
%   See also  DICOMDICT, DICOMINFO, DICOMREAD, DICOMUID.

%   Copyright 1993-2017 The MathWorks, Inc.


%
% Parse input arguments. 
%

if (nargin < 2)
    error(message('images:dicomwrite:tooFewInputs'))
elseif (nargout > 1)
    error(message('images:dicomwrite:tooManyOutputs'))
end

varargin = matlab.images.internal.stringToChar(varargin);

checkDataDimensions(X);
[filename, map, metadata, options] = parse_inputs(varargin{:});
checkOptionConsistency(options, metadata);

%
% Register SOP classes, dictionary, etc.
%

dicomdict('set_current', options.dictionary);
dictionary = dicomdict('get_current');

%
% Write the DICOM file.
%

try
    
    [status, options] = write_message(X, filename, map, metadata, options);

    if (nargout == 1)
        varargout{1} = status;
    end
    
catch ME
    
    dicomdict('reset_current');
    rethrow(ME)
    
end

dicomdict('reset_current');

% If (0028,0008) is set, it's pair (0028,0009) must also be set.
% Warn if it isn't, since we can't make up a value for it.
if (isfield(metadata, dicom_name_lookup('0028', '0008', dictionary)) && ...
    ~isfield(metadata, dicom_name_lookup('0028', '0009', dictionary)) && ...
    requires00280009(options, metadata, dictionary))
  
    warning(message('images:dicomwrite:missingFrameIncrementPointer', dicom_name_lookup( '0028', '0009', dictionary ), dicom_name_lookup( '0028', '0008', dictionary )))
    
end



function varargout = write_message(X, filename, map, metadata, options)
%WRITE_MESSAGES  Write the DICOM message.

%
% Abstract syntax negotiation.
% (SOP class and transfer syntax)
%

if (isequal(options.createmode, 'create'))
    SOP_UID = determine_IOD(options, metadata, X);
    options.sopclassuid = SOP_UID;
else
    SOP_UID = '';
end

options.txfr = determine_txfr_syntax(options, metadata);

checkArgConsistency(options, SOP_UID, X);

specificCharacterSet = dicom_get_SpecificCharacterSet(metadata, options.dictionary);

%
% Construct, encode, and write SOP instance.
%

if (~isequal(options.createmode, 'create') && ...
    ~isequal(options.createmode, 'copy'))
  
    error(message('images:dicomwrite:badCreateMode'));
  
end

if (options.multiframesinglefile)
  
    % All frames will go into one file.
    if (isequal(options.createmode, 'create'))

        [attrs, status] = dicom_create_IOD(SOP_UID, X, map, ...
                                           metadata, options, specificCharacterSet);
        
    else
        
        [attrs, status] = dicom_copy_IOD(X, map, ...
                                         metadata, options, specificCharacterSet);
        
    end
    
    encodeAndWriteAttrs(attrs, options, filename, specificCharacterSet);
    
else

    % Each file will contain only one frame.
    num_frames = size(X, 4);
    for p = 1:num_frames
      
        % Construct the SOP instance's IOD.
        if (isequal(options.createmode, 'create'))
        
            [attrs, status] = dicom_create_IOD(SOP_UID, X(:,:,:,p), map, ...
                                                    metadata, options, specificCharacterSet);
        
        else
        
            [attrs, status] = dicom_copy_IOD(X(:,:,:,p), map, ...
                                                  metadata, options, specificCharacterSet);
        
        end
    
        encodeAndWriteAttrs(attrs, options, get_filename(filename, p, num_frames), specificCharacterSet);
    
    end
    
end

varargout{1} = status;
varargout{2} = options;



function encodeAndWriteAttrs(attrs, options, filename, specificCharacterSet)
%encodeAndWriteAttrs   Convert attributes to DICOM representation and write them.
    
attrs = sort_attrs(attrs);
attrs = remove_duplicates(attrs);

% Encode the attributes.
data_stream = dicom_encode_attrs(attrs, options.txfr, dicom_uid_decode(options.txfr), specificCharacterSet);

% Write the SOP instance.
destination = filename;
msg = write_stream(destination, data_stream);
if (~isempty(msg))
    %msg is already translated at source.
    error(message('images:dicomwrite:streamWritingError', msg));
end



function [filename, map, metadata, options] = parse_inputs(varargin)
%PARSE_INPUTS   Obtain filename, colormap, and metadata values from input.

metadata = struct([]);
options.writeprivate = false;  % Don't write private data by default.
options.createmode = 'create';  % Create/verify data by default.
options.dictionary = dicomdict('get_current');
options.multiframesinglefile = true;  % Put multiframe images into one file
options.usemetadatabitdepths = false;  % Compute bit depths based on datatype

[filename, map, currentArg] = getFilenameAndColormap(varargin{:});

% Process metadata.
%
% Structures containing multiple values can occur anywhere in the
% metadata information as long as they don't split a parameter-value
% pair.  Any number of structures can appear.

while (currentArg <= nargin)

    if (ischar(varargin{currentArg}))
        
        % Parameter-value pair.
        
        if (currentArg ~= nargin)  % Make sure it's part of a pair.

            [metadata, options] = processPair(metadata, options, ...
                                      varargin{currentArg:(currentArg + 1)});
            
        else

            error(message('images:dicomwrite:missingValue', varargin{ currentArg }))
            
        end
        
        currentArg = currentArg + 2;
        
    elseif (isstruct(varargin{currentArg}))
        
        % Structure of parameters and values.

        str = varargin{currentArg};
        fields = fieldnames(str);
        
        for p = 1:numel(fields)
            
            [metadata, options] = processPair(metadata, options, ...
                                              fields{p}, str.(fields{p}));
        end
        
        currentArg = currentArg + 1;
        
    else
        
        error(message('images:dicomwrite:expectedFilenameOrColormapOrMetadata'))
        
    end

end

% make sure options.createmode is lower case (see g320584) so the code works
% regardless of the casing.
options.createmode = lower(options.createmode);


function SOP_UID = determine_IOD(options, metadata, X)
%DETERMINE_IOD   Pick the DICOM information object to create.
  
if (options.multiframesinglefile)
  nFrames = size(X,4);
  nSamples = size(X,3);
  needsFix = false;
else
  nFrames = 1;
  nSamples = size(X,3);
  needsFix = true;
end

if (isfield(options, 'objecttype'))
  
    switch (lower(options.objecttype))
    case 'ct image storage'
      
        SOP_UID = '1.2.840.10008.5.1.4.1.1.2';

    case 'mr image storage'
      
        SOP_UID = determineMRStorage(nFrames, options.multiframesinglefile);
     
    case 'secondary capture image storage'

        SOP_UID = determineSCStorage(nFrames, nSamples, X);
        
    otherwise
        
        error(message('images:dicomwrite:unsupportedObjectType', num2str( options.objecttype )))
     
    end
    
elseif (isfield(options, 'sopclassuid'))

    if (ischar(options.sopclassuid))
      
        SOP_UID = options.sopclassuid;
        
    else
      
        error(message('images:dicomwrite:InvalidSOPClassUID'))
        
    end
    
    if (needsFix)
        SOP_UID = fixForMultiFile(SOP_UID);
    end
    
elseif (isfield(metadata, 'SOPClassUID'))

    if (ischar(options.SOPClassUID))
      
        SOP_UID = options.SOPClassUID;
        
    else
      
        error(message('images:dicomwrite:InvalidSOPClassUID'))
        
    end
    
    if (needsFix)
        SOP_UID = fixForMultiFile(SOP_UID);
    end
  
elseif ((isfield(metadata, 'Modality')) && (isequal(metadata.Modality, 'CT')))
      
    SOP_UID = '1.2.840.10008.5.1.4.1.1.2';
    
elseif ((isfield(metadata, 'Modality')) && (isequal(metadata.Modality, 'MR')))
      
    SOP_UID = '1.2.840.10008.5.1.4.1.1.4';
    
else
  
    % Create SC Storage objects by default.
    SOP_UID = determineSCStorage(nFrames, nSamples, X);
    
end




function txfr = determine_txfr_syntax(options, metadata)
%DETERMINE_TXFR_SYNTAX   Find the transfer syntax from user-provided options.
%
% The rules for determining transfer syntax are followed in this order:
%
% (1) Use the command line option 'TransferSyntax'.
%
% (2) Use the command line option 'CompressionMode'.
%
% (3) Use a combination of the command line options 'VR' and 'Endian'.
%
% (4) Use the metadata's 'TransferSyntaxUID' field.
%
% (5) Use the default implicit VR, little-endian transfer syntax.


% Rule (1): 'TransferSyntax' option.
if (isfield(options, 'transfersyntax'))

    txfrStruct = dicom_uid_decode(options.transfersyntax);
    
    if (~isempty(txfrStruct) && ...
        isequal(txfrStruct.Type, 'Transfer Syntax'))
      
        txfr = options.transfersyntax;
        
    else
      
        error(message('images:dicomwrite:unsupportedTransferSyntax', num2str( options.transfersyntax )))
        
    end
    
    return
    
end

% Rule (2): 'CompressionMode' option.
if (isfield(options, 'compressionmode'))
    
    switch (lower(options.compressionmode))
    case 'none'
        
        % Pick transfer syntax below.
        
    case 'rle'
        
        txfr = '1.2.840.10008.1.2.5';
        return
    
    case 'jpeg lossless'
        
        txfr = '1.2.840.10008.1.2.4.70';
        return
        
    case 'jpeg lossy'

        txfr = '1.2.840.10008.1.2.4.50';
        return
    
    case 'jpeg2000 lossless'
        
        txfr = '1.2.840.10008.1.2.4.90';
        return
        
    case 'jpeg2000 lossy'

        txfr = '1.2.840.10008.1.2.4.91';
        return
    
    otherwise
        
        error(message('images:dicomwrite:unrecognizedCompressionMode', num2str( options.compressionmode )));
        
    end
    
end

% Handle rules (3), (4), and (5) together.
if ((isfield(options, 'vr')) || (isfield(options, 'endian')))
    
    override_txfr = true;
    
else
    
    override_txfr = false;
    
end

if (~isfield(options, 'vr'))
    options(1).vr = 'implicit';
end

    
if (~isfield(options, 'endian'))
    options(1).endian = 'ieee-le';
end
        
switch (options.vr)
case 'explicit'
    
    switch (lower(options.endian))
    case 'ieee-be'
        txfr = '1.2.840.10008.1.2.2';
    case 'ieee-le'
        txfr = '1.2.840.10008.1.2.1';
    otherwise
        error(message('images:dicomwrite:invalidEndianValue'));
    end
    
case 'implicit'
    
    switch (lower(options.endian))
    case 'ieee-be'
        error(message('images:dicomwrite:invalidVREndianCombination'))
    case 'ieee-le'
        txfr = '1.2.840.10008.1.2';
    otherwise
        error(message('images:dicomwrite:invalidEndianValue'));
    end

otherwise

    error(message('images:dicomwrite:invalidVRValue'))
    
end

if (override_txfr)
    
    % Rule (3): 'VR' and/or 'Endian' options provided.
    return
    
else
    
    if (isfield(metadata, 'TransferSyntaxUID'))
        
        % Rule (4): 'TransferSyntaxUID' metadata field.
        txfr = metadata.TransferSyntaxUID;
        return
        
    else
        
        % Rule (5): Default transfer syntax.
        return
        
    end
    
end



function out = sort_attrs(in)
%SORT_ATTRS   Sort the attributes by group and element.

attr_pairs = [[in(:).Group]', [in(:).Element]'];
[~, idx_elt] = sort(attr_pairs(:, 2));
[~, idx_grp] = sort(attr_pairs(idx_elt, 1));

out = in(idx_elt(idx_grp));



function out = remove_duplicates(in)
%REMOVE_DUPLICATES   Remove duplicate attributes.
  
attr_pairs = [[in(:).Group]', [in(:).Element]'];
delta = sum(abs(diff(attr_pairs, 1)), 2);

out = [in(1), in(find(delta ~= 0) + 1)];



function status = write_stream(destination, data_stream)
%WRITE_STREAM   Write an encoded data stream to the output device.

% NOTE: Currently local only.
file = dicom_create_file_struct;
file.Filename = destination;
    
file = dicom_open_msg(file, 'w');
    
[file, status] = dicom_write_stream(file, data_stream);

dicom_close_msg(file);



function filename = get_filename(file_base, frame_number, max_frame)
%GET_FILENAME   Create the filename for this frame.

if (max_frame == 1)
    filename = file_base;
    return
end

% Create the file number.
num_length = ceil(log10(max_frame + 1));
format_string = sprintf('%%0%dd', num_length);
number_string = sprintf(format_string, frame_number);

% Look for an extension.
idx = max(strfind(file_base, '.'));

if (~isempty(idx))
    
    base = file_base(1:(idx - 1));
    ext  = file_base(idx:end);  % Includes '.'
    
else
    
    base = file_base;
    ext  = '';
    
end

% Put it all together.
filename = sprintf('%s_%s%s', base, number_string, ext);



function [filename, map, currentArg] = getFilenameAndColormap(varargin)
% Filename and colormap.
if (ischar(varargin{1}))
    
    filename = varargin{1};
    map = [];
    currentArg = 2;
    
elseif (isnumeric(varargin{1}))
    
    map = varargin{1};
    
    if ((nargin > 1) && (ischar(varargin{2})))
        filename = varargin{2};
    else
        error(message('images:dicomwrite:filenameMustBeString'))
    end
    
    currentArg = 3;
    
else
    
    % varargin{1} is second argument to DICOMWRITE.
    error(message('images:dicomwrite:expectedFilenameOrColormap'))
    
end



function [metadata, options] = processPair(metadata, options, param, value)

dicomwrite_fields = {'colorspace'
                     'vr'
                     'endian'
                     'compressionmode'
                     'transfersyntax'
                     'objecttype'
                     'sopclassuid'
                     'dictionary'
                     'writeprivate'
                     'createmode'
                     'multiframesinglefile'
                     'usemetadatabitdepths'};

%idx = strmatch(lower(param), dicomwrite_fields);
idx = find(strncmpi(param, dicomwrite_fields, numel(param)));
            
if (numel(idx) > 1)
    error(message('images:dicomwrite:ambiguousParameter', param));
end
            
if (~isempty(idx))
  
    % It's a DICOMWRITE option.
    options(1).(dicomwrite_fields{idx}) = value;
  
    if (isequal(dicomwrite_fields{idx}, 'transfersyntax'))
      
        % Store TransferSyntax in both options and metadata.
        metadata(1).TransferSyntax = value;
                    
    end
    
else
  
    % It's a DICOM metadata attribute.
    metadata(1).(param) = value;
    
end
            


function checkDataDimensions(data)

% How many bytes does each element occupy in the file?  This assumes
% pixels span the datatype.
switch (class(data))
case {'uint8', 'int8', 'logical'}

    elementSize = 1;
    
case {'uint16', 'int16', 'double'}

    elementSize = 2;
    
case {'uint32', 'int32'}

    elementSize = 4;
    
otherwise

    % Let a later function error about unsupported datatype.
    elementSize = 1;
    
end

% Validate that the dataset/image will fit within 32-bit offsets.
max32 = double(intmax('uint32'));

if (any(size(data) > max32))
    
    error(message('images:dicomwrite:sideTooLong'))
    
elseif ((numel(data) * elementSize) > max32)
    
    error(message('images:dicomwrite:tooMuchData'))
    
end



function uid = determineSCStorage(nFrames, nSamples, X)

if (nFrames == 1)
  
    % Single frame.
    uid = '1.2.840.10008.5.1.4.1.1.7';
    
elseif (nSamples == 3)
  
    % RGB.
    uid = '1.2.840.10008.5.1.4.1.1.7.4';
    
else
  
    % Grayscale.
    switch (class(X))
    case 'logical'
        uid = '1.2.840.10008.5.1.4.1.1.7.1';
    case {'uint8', 'int8'}
        uid = '1.2.840.10008.5.1.4.1.1.7.2';
    case {'uint16', 'int16'}
        uid = '1.2.840.10008.5.1.4.1.1.7.3';
    otherwise
        error(message('images:dicomwrite:badSCBitDepth'))
    end
    
end


function uid = determineMRStorage(nFrames, singleFile)

% Only Single-frame is currently supported from scratch
if (nFrames > 1) && (singleFile)
    uid = '1.2.840.10008.5.1.4.1.1.4.1';
else
    uid = '1.2.840.10008.5.1.4.1.1.4';
end


function checkArgConsistency(options, SOPClassUID, X)

if (isequal(options.createmode, 'create') && ...
    options.multiframesinglefile && ...
    (size(X,4) > 1) && ...
    ~isSC(SOPClassUID))
  
    error(message('images:dicomwrite:multiFrameCreateMode'))

end


function tf = isSC(UID)

scUID = '1.2.840.10008.5.1.4.1.1.7';
tf = strncmp(UID, scUID, length(scUID));



function tf = requires00280009(options, metadata, dictionary)

% See PS 3.3 A.1.1 for IODs that require the Multi-Frame module.

if (isequal(options.createmode, 'create') && isfield(options, 'sopclassuid'))
    
    UID = options.sopclassuid;
    
elseif (isfield(metadata, dicom_name_lookup('0002','0002', dictionary)))

    UID = metadata.(dicom_name_lookup('0002','0002', dictionary));
  
elseif (isfield(metadata, dicom_name_lookup('0008','0016', dictionary)))

    UID = metadata.(dicom_name_lookup('0008','0016', dictionary));
  
else
  
    UID = '';
  
end


switch (UID)
case {'1.2.840.10008.5.1.4.1.1.3.1'
      '1.2.840.10008.5.1.4.1.1.7.1'
      '1.2.840.10008.5.1.4.1.1.7.2'
      '1.2.840.10008.5.1.4.1.1.7.3'
      '1.2.840.10008.5.1.4.1.1.7.4'
      '1.2.840.10008.5.1.4.1.1.12.1'
      '1.2.840.10008.5.1.4.1.1.12.2'
      '1.2.840.10008.5.1.4.1.1.20'
      '1.2.840.10008.5.1.4.1.1.77.1.1.1'
      '1.2.840.10008.5.1.4.1.1.77.1.2.1'
      '1.2.840.10008.5.1.4.1.1.77.1.4.1'
      '1.2.840.10008.5.1.4.1.1.77.1.5.1'
      '1.2.840.10008.5.1.4.1.1.77.1.5.2'
      '1.2.840.10008.5.1.4.1.1.481.1'}
  
    tf = true;
  
otherwise
  
    tf = false;
  
end


function SOP_UID = fixForMultiFile(SOP_UID)
% When the option to write to multiple files is present, switch to the
% explicitly single-frame versions of supported "creatable" SOP classes.

switch (SOP_UID)
case '1.2.840.10008.5.1.4.1.1.4.1'
    
    SOP_UID = '1.2.840.10008.5.1.4.1.1.4';
    
case '1.2.840.10008.5.1.4.1.1.2.1'
    
    SOP_UID = '1.2.840.10008.5.1.4.1.1.2';

end


function checkOptionConsistency(options, metadata)

if (~isequal(options.createmode, 'copy'))
    return;
end

if (isfield(options, 'sopclassuid') && ...
    (~isfield(metadata, 'SOPClassUID') && ~isfield(metadata, 'MediaStorageSOPClassUID')))
    
    warning(message('images:dicomwrite:inconsistentIODAndCreateModeOptions'))
        
elseif (isfield(options, 'objecttype'))
    
    warning(message('images:dicomwrite:inconsistentIODAndCreateModeOptions'))
        
end
