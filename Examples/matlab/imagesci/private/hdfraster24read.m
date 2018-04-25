function data = hdfraster24read(hinfo)
%HDFRASTER24READ
%
%   DATA = HDFRASTER24READ(HINFO) returns in the variable DATA the image
%   from the file for the particular 24-bit raster image described by HINFO.
%   HINFO is a structure extracted from the output structure of HDFINFO.

%   Copyright 1984-2013 The MathWorks, Inc.

parseInputs(hinfo);
status = hdfdf24('readref',hinfo.Filename,hinfo.Ref);
hdferrmsg(status,'DF24','readref');
	
[data, status] = hdfdf24('getimage',hinfo.Filename);
hdferrmsg(status,'DF24','getimage');
	
status = hdfdf24('restart');
hdferrmsg(status,'DF24','restart');

%Put the image data in the right order for image display in MATLAB
data = permute(data,[3 2 1]);
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
