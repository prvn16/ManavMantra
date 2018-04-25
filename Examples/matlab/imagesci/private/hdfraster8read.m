function [data,map] = hdfraster8read(hinfo)
%HDFRASTER8READ
%
%   [DATA,MAP] = HDFRASTER8READ(HINFO) returns in the variable DATA the
%   image from the file for the particular 8-bit raster image described by
%   HINFO.  MAP contains the colormap if one exists for the image.  HINFO is
%   A structure extracted from the output structure of HDFINFO.

%   Copyright 1984-2013 The MathWorks, Inc.

parseInputs(hinfo);

status = hdfdfr8('readref',hinfo.Filename,hinfo.Ref);
hdferrmsg(status,'DFR8','readref');

[data,map,status]  = hdfdfr8('getimage',hinfo.Filename);
hdferrmsg(status,'DFR8','getimage');

status = hdfdfr8('restart');
hdferrmsg(status,'DFR8','restart');

%Put the image data and colormap in the right order for image display in
%MATLAB
data = data';
map = double(map')/255;
return;

%=======================================================================
function parseInputs(hinfo)

%Verify required fields

fNames = fieldnames(hinfo);
numFields = length(fNames);
reqFields = {'Filename','Ref'};
numReqFields = length(reqFields);
if numFields >= numReqFields
    for i=1:numReqFields
        if ~isfield(hinfo,reqFields{i})
          error(message('MATLAB:imagesci:hdfread:invalidRasterStructInput'));
        end
    end
else 
    error(message('MATLAB:imagesci:hdfread:invalidRasterStructInput'));
end
return;





