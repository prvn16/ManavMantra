function niftiwrite(V, filename, varargin)
%NIFTIWRITE Write images as NIfTI files.
%   NIFTIWRITE(V, FILENAME) writes a '.nii' file using the image data from
%   V. By default, NIFTIWRITE creates a 'combined' NIfTI file that contains
%   both metadata and volumetric data, giving it the '.nii' file extension.
%   NIFTIWRITE populates the file metadata using appropriate default values
%   and volume properties like size and data type.
%
%   NIFTIWRITE(V, FILENAME, METADATA) writes a '.nii' file using the image
%   data from V and metadata from METADATA. NIFTIWRITE creates a 'combined'
%   NIFTI file, giving it the file extension '.nii'.  If the metadata does
%   not match the image contents and size, NIFTIWRITE returns an error.
%
%   NIFTIWRITE(____, Name, Value) writes a '.nii' file using options
%   specified in the Name Value pairs, described below.
%
%   Optional Name-Value parameters include:
%
%   'Combined'           - true (default) or false. If true, NIFTIWRITE
%                          creates one file with the file extension '.nii'.
%                          If false, NIFTIWRITE creates two files. One file
%                          contains metadata and has the file extension
%                          '.hdr'. The other files contains the volumetric
%                          data and has the file extension '.img'.
%                          NIFTIWRITE uses the file name you specified in
%                          FILENAME for both files.
%
%   'Compressed'         - false(default) or true. If true, NIFTIWRITE
%                          compresses the generated file (or files) using
%                          gzip encoding, giving the file the .gz file
%                          extension as well as the NIFTI file extension.
%
%   'Endian'             - 'little' (default) or 'big'.
%                          Controls the endianness of the data NIFTIWRITE
%                          writes to the file.
%
%   References:
%   -----------
%   [1] Cox, R.W., Ashburner, J., Breman, H., Fissell, K., Haselgrove, C.,
%   Holmes, C.J., Lancaster, J.L., Rex, D.E., Smith, S.M., Woodward, J.B.
%   and Strother, S.C., 2004. A (sort of) new image data format standard:
%   Nifti-1. Neuroimage, 22, p.e1440.
%
%   Example 1
%   ---------
%   This example illustrates writing a median filtered volume to a .nii
%   file.
%
%   % Load a NIfTI image using its .nii file name.
%   V = niftiread('brain.nii');
% 
%   % Filter the image in 3D using a 3x3 median filter.
%   V = medfilt3(V);
%
%   % Visualize the volume
%   volumeViewer(V)
% 
%   % Write the image to a .nii file. This uses default header values.
%   niftiwrite(V, 'outbrain.nii');
%
%   Example 2
%   ---------
%   % This example illustrates modifying the header structure and re-saving
%   % a .nii file.
%
%   % Load a NIfTI image using its .nii file name.
%   info = niftiinfo('brain.nii');
%   V = niftiread(info);
% 
%   % Edit the description of the file.
%   info.Description = 'Modified using MATLAB R2017b';
% 
%   % Write the image to a .nii file.
%   niftiwrite(V, 'outbrain.nii', info);
%
%   See also NIFTIINFO, NIFTIREAD.

%   Copyright 2016-2017 The MathWorks, Inc.

[V, path, filename, params] = parseInputs(V, filename, varargin{:});

if strcmp(params.Endian, 'little')
    machineFmt = 'ieee-le';
else
    machineFmt = 'ieee-be';
end

headerStruct = params.Info;

if params.Combined
    NV = images.internal.nifti.niftiImage(headerStruct);
    fid = fopen([filename '.nii'], 'w', machineFmt);
    % write header.
    [fid, headerBytes] = NV.writeHeader(fid, machineFmt);
    assert(headerBytes == 348);
    % Write empty data until vox_offset.
    skipBytes = double(headerStruct.vox_offset) - 348;
    fwrite(fid, zeros(1,skipBytes), 'uint8');
    % write image data.
    fid = NV.writeImage(V, fid, machineFmt);
    fclose(fid);
    
    if params.Compressed
        gzip([filename '.nii'], path);
        delete([filename '.nii']);
    end
else
    
    headerStruct.vox_offset = 0; % pixels start from first byte.
    NV = images.internal.nifti.niftiImage(headerStruct);
    
    headerfid = fopen([filename '.hdr'], 'w', machineFmt);
    % write header.
    [headerfid, headerBytes] = NV.writeHeader(headerfid, machineFmt);
    assert(headerBytes == 348);
    fclose(headerfid);
    
    % write image data.
    imagefid = fopen([filename '.img'], 'w', machineFmt);
    imagefid = NV.writeImage(V, imagefid, machineFmt);
    fclose(imagefid);
    
    if params.Compressed
        gzip([filename '.hdr'], path);
        gzip([filename '.img'], path);
        delete([filename '.hdr']);
        delete([filename '.img']);
    end
end

end

%--------------------------------------------------------------------------
% Input Parsing
%--------------------------------------------------------------------------
function [V, fPath, fName, params] = parseInputs(V, fName, varargin)

varargin = matlab.images.internal.stringToChar(varargin);

% V has to be numeric, and of specific data types.
if ~isnumeric(V)
   error(message('images:nifti:volumeMustBeNumeric'))
end
    
% filename needs to be a string or a character vector.
fName = matlab.images.internal.stringToChar(fName);
if ~ischar(fName)
   error(message('images:nifti:filenameMustBeStringOrChar'))
end

[fPath, filenameOnly] = fileparts(fName);
if ~isempty(fPath)
    fName = [fPath, filesep, filenameOnly];
else
    fName = filenameOnly;
end

% Parse the PV pairs
parser = inputParser;
parser.addParameter('Combined', true, @(x)canBeLogical(x));
parser.addParameter('Compressed', false, @(x)canBeLogical(x));
parser.addParameter('Endian', 'little', @(x)ischar(x));
parser.addOptional('Info', [], @(x)validateHeader(V,x));

parser.parse(varargin{:});

params.Combined = parser.Results.Combined ~= 0;
params.Compressed = parser.Results.Compressed ~= 0;
params.Endian = validatestring(parser.Results.Endian, {'little', 'big'});

if isempty(parser.Results.Info)
    params.Info = images.internal.nifti.niftiImage.niftiDefaultHeader(...
                  V, params.Combined);
else
    params.Info = images.internal.nifti.niftiImage.toRawStruct(...
                  parser.Results.Info, params.Combined);
end

end

function TF = canBeLogical(input)
    if isnumeric(input) || islogical(input)
        TF = true;
    else
        TF = false;
    end
end

function isHeader = validateHeader(V, simpleStruct)
    if isstruct(simpleStruct)
        if ~(isequal(simpleStruct.Datatype, class(V)))
           error(message('images:nifti:volumeClassMustMatchHeader'))
        end
        if ~(isequal(simpleStruct.ImageSize, size(V)))
            error(message('images:nifti:volumeSizeMustMatchHeader'))
        end

        if ~(length(simpleStruct.Description) <= 80)
            error(message('images:nifti:descriptionLessThan80'))
        end

        if isfield(simpleStruct, 'AuxiliaryFile') && ...
                ~(length(simpleStruct.AuxiliaryFile) <= 24)
            error(message('images:nifti:auxiliaryFileLessThan24'))
        end

        if isfield(simpleStruct, 'IntentDescription') && ...
                ~(length(simpleStruct.IntentDescription) <= 16)
            error(message('images:nifti:intentMustBeLessThan16'))
        end

        isHeader = true;
    else
        isHeader = false;
    end
end