function [tf, eid, msg] = isNitfSupported(filename)
%isNitfSupported  Determine if IMTOOL can display NITF file.
%   [TF, EID, MSG] = isNitfSupported(FILENAME) examines the NITF metadata
%   in FILENAME to determine whether IMTOOL, IMSHOW, or RSETWRITE will
%   support it.  TF is true if the file is usable by those tools, and EID
%   and MSG will be empty.  Otherwise, TF is false, EID contains a
%   suitable error ID, and MSG contains a descriptive message about why
%   the NITF file is not usable.

%   Copyright 2009-2010 The MathWorks, Inc.  


[nitfFormat, nitfVer] = isnitf(filename);

% Make sure the file is in the NITF format before continuing.
if (~nitfFormat)
    
    tf = false;
    eid = 'images:isNitfSupported:notNitf';
    msg = getString(message('images:isNitfSupported:notNitf'));
    return
    
end

% NITF files must have a version of at least 2.0.
nitfVerFloat = sscanf(nitfVer, '%f');
if (isempty(nitfVerFloat) || ...
    (nitfVerFloat < 2.0))
    
    tf = false;
    eid = 'images:isNitfSupported:nitfVersion';
    msg = getString(message('images:isNitfSupported:nitfVersion',nitfVer));
    return
    
end

% Determine suitability for display functions by examining the file
% metadata.
meta = nitfinfo(filename);

if (meta.NumberOfImages < 1)
    
    tf = false;
    eid = 'images:isNitfSupported:nitfNoImages';
    msg = getString(message('images:isNitfSupported:nitfNoImages'));
    
elseif (~strncmpi(meta.ImageSubheaderMetadata.ImageSubheader001.ImageCompression, ...
                  'NC', 2) && ...
        ~strncmpi(meta.ImageSubheaderMetadata.ImageSubheader001.ImageCompression, ...
                  'NM', 2))
    
    tf = false;
    eid = 'images:isNitfSupported:nitfCompressed';
    msg = getString(message('images:isNitfSupported:nitfCompressed'));
    
elseif (isequal(meta.ImageSubheaderMetadata.ImageSubheader001.PixelValueType, 'R'))
    
    tf = false;
    eid = 'images:isNitfSupported:nitfSingle';
    msg = getString(message('images:isNitfSupported:nitfSingle'));
    
elseif (~isequal(meta.ImageSubheaderMetadata.ImageSubheader001.PixelValueType, 'INT') && ...
        (computeNumberOfNitfBands(meta) > 1))

    tf = false;
    eid = 'images:isNitfSupported:nitfRgbType';
    msg = getString(message('images:isNitfSupported:nitfRgbType'));
    
elseif (computeNumberOfNitfBands(meta) > 3)

    tf = false;
    eid = 'images:isNitfSupported:nitfNumberOfBands';
    msg = getString(message('images:isNitfSupported:nitfNumberOfBands'));
    
else

    % Success.
    tf = true;
    eid = '';
    msg = '';
    
end


function numBands = computeNumberOfNitfBands(meta)

if (isfield(meta.ImageSubheaderMetadata.ImageSubheader001, ...
            'NumberOfMultiSpectralBands'))
    
    numBands = meta.ImageSubheaderMetadata.ImageSubheader001.NumberOfMultiSpectralBands;

else
    
    numBands = meta.ImageSubheaderMetadata.ImageSubheader001.NumberOfBands;
    
end
