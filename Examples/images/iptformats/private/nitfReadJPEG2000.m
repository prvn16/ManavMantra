function X = nitfReadJPEG2000(details, region)
%nitfReadJPEG2000   Extract JPEG-2000-compressed image from NITF file.
%   X = nitfReadJPEG2000(DETAILS, REGION) returns the image X from the NITF
%   file described in the DETAILS structure.  The REGION argument is
%   currently not used.
%
%   See STDI-0006-NCDRD for details of this scheme.

% Copyright 2016 The MathWorks, Inc.

% Currently there's no pixel subsetting for NITF I/O.
if (~isempty(region))
    error(message('images:nitfread:jpegSubsetting'))
end

% Get the JPEG2000 data from the file.
compData = getJpegStream(details);

X = getImageDataFromFrame(compData);

end


function compData = getJpegStream(details)

% Open the NITF file.
fid = fopen(details.filename, 'rb');
if (fid == 0)
    error(message('images:nitfread:jpegFileOpen', details.filename))
else
    c = onCleanup(@() fclose(fid));
end

% Move to the location in the file where the JPEG 2000 stream begins.
details.offsetStart = convertOffsetType(details.offsetStart);

status = fseek(fid, details.offsetStart, 'bof');
if (status ~= 0)
    error(message('images:nitfread:jpegFseek'));
end

% Read the JPEG 2000 data, which comprises the rest of the NITF file.
% if isempty(details.nextImageOffsetStart)
%     compData = fread(fid, inf, 'uint8=>uint8');
% else
details.imageLength = convertOffsetType(details.imageLength);
compData = fread(fid, details.imageLength, 'uint8=>uint8');
% end

% Find SOC (0xFF4F) and EOC (0xFFD9) markers in data stream
SOCidx = findpattern(compData', sscanf('ff 4f', '%x')');
EOCidx = findpattern(compData', sscanf('ff d9', '%x')');
    
% Validate the codestream.
if isempty(SOCidx)
    error(message('images:nitfread:jpeg2000BadSOC'))
end

if isempty(EOCidx)
    error(message('images:nitfread:jpeg2000BadEOC'))
end

% Trim any leading values from codestream
if SOCidx(1) ~= 1
    compData(1:SOCidx(1)-1) = [];
end

end


function img = getImageDataFromFrame(frameData)

% Write codestream to jp2 file
name = [tempname '.j2k'];

fid = fopen(name, 'wb');
if (fid == 0)
    error(message('images:nitfread:tmpJpegFileOpen', name))
else
    c = onCleanup(@() fclose(fid));
    cleaner = onCleanup(@() delete(name));
end

fwrite(fid, frameData, 'uint8');
delete(c);

img = imread(name);

end


function idx = findpattern(array, pattern)
%FINDPATTERN  Find a pattern in an array.

% Despite its name, "strfind" is very good at finding numeric patterns in
% numeric vectors.
idx = strfind(array, pattern);

end


function out = convertOffsetType(in)

if (in > intmax('uint32'))
    error(message('images:nitfread:offsetTooBigForJPEG'))
end

out = double(in);

end
