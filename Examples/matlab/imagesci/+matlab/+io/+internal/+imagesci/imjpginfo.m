function info = imjpginfo(filename,baseline_only)
%IMJPGINFO Information about a JPEG file.
%   INFO = IMJPGINFO(FILENAME) returns a structure containing
%   information about the JPEG file specified by the string
%   FILENAME.  
%
%   INFO = IMJPGINFO(FILENAME,BASELINE_ONLY=true) returns a structure with
%   only metadata as provided directly by the JPEG file.  Any Exif
%   or directory metadata is omitted.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Steven L. Eddins, August 1996
%   Copyright 1984-2015 The MathWorks, Inc.

if nargin < 2
    baseline_only = false;
end

fid = fopen(filename,'r','ieee-be');
assert(fid ~= -1,message('MATLAB:imagesci:validate:fileOpen',filename));

% Ensure we clean up when finished
cfid = onCleanup(@()fclose(fid));

% Invoke fopen on the file id to resolve the full path name
filename = fopen(fid);

% Look for the JPEG signature and error if not a JPEG file
sig = fread(fid,2,'uint8');
assert(isequal(sig,[255; 216]),message('MATLAB:imagesci:imjpginfo:notAJPEGFile',filename));

% Retrieve the baseline JPEG information
[info,exif_offset, idx] = matlab.io.internal.imagesci.imjpgbaselineinfo(fid);

if baseline_only
    return;
end

info.Filename = filename;
d = dir(filename);
info.FileModDate = [];
info.FileSize = [];
info.FileModDate = datestr(d.datenum);
info.FileSize = d.bytes;

% We use try/catch here because tiff tags are really optional,
% unlike the case with TIFF.
if exif_offset > 0  
    try
        info = incorporate_exif_metadata(info, filename, exif_offset, idx);
    catch me
        warning(message('MATLAB:imagesci:imjpginfo:exif', me.message));
        return
    end
end




%---------------------------------------------------------------------------
function info = incorporate_exif_metadata(info,filename,offset,idx)
% INFO contains baseline metadata alread read.  RAW_TAGS contains the Exif 
% metadata as read by TIFFTAGSREAD and may have length of two if there was
% an Exif thumbnail, which does describe a physical image as opposed to 
% the Exif IFD itself.

raw_tags = matlab.io.internal.imagesci.tifftagsread(filename, offset, 0, 1);

exif = matlab.io.internal.imagesci.tifftagsprocess ( raw_tags );
if isempty(exif)
    return;
end



% Certain fields should be removed from the first IFD structure because
% they are already supplied by the main JPEG metadata processing.
% Sometimes Exif reports them inacurately as well.
exif = rmfield(exif, { 'Filename', 'FileModDate', 'FileSize', 'Format', ...
    'FormatVersion', 'Width', 'Height', 'BitDepth',  'ColorType', ...
    'FormatSignature' });



% Fold the remaining Exif tags into the main structure.
exif_fields = fieldnames(exif);
for j = 1:numel(exif_fields)
    info.(exif_fields{j}) = exif.(exif_fields{j});
end


% Was there a thumbnail?
if numel(idx) > 1
    raw_tags = matlab.io.internal.imagesci.tifftagsread(filename, offset, 1, 1);
    thumbnail = matlab.io.internal.imagesci.tifftagsprocess(raw_tags);
else
    thumbnail = [];
end


if ~isempty(thumbnail)
    % Hang any thumbnail metadata off of the main struct, but remove
    % certain fields that don't make a lot of sense in this context.
    thumbnail = rmfield(thumbnail, { 'Filename', 'FileModDate', ...
        'FileSize', 'Format', 'FormatVersion',  ...
        'FormatSignature' });
    
    % These fields may or may not be present.  If they were not actually
    % present, then TIFFTAGSREAD provides them with default values, by
    % which we can identify and remove them.
    if thumbnail.ColorType == -1
        thumbnail = rmfield(thumbnail,'ColorType');
    end
    if thumbnail.Height == 0
        thumbnail = rmfield(thumbnail,'Height');
    end
    if thumbnail.Width == 0
        thumbnail = rmfield(thumbnail,'Width');
    end    
    if thumbnail.BitDepth == 0
        thumbnail = rmfield(thumbnail,'BitDepth');
    end
    
    info.ExifThumbnail = thumbnail;
end
