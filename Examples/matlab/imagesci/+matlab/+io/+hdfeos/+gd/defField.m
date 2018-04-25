function defField(gridID,name,idimlist,dtype,mergeCode)
%defField Define new data field within grid.
%   defField(gridID,FIELDNAME,DIMLIST,DTYPE) defines data fields for a 
%   grid specified by gridID.  FIELDNAME is the name of the new field.  
%   DIMLIST is a cell array of geolocation dimensions and should be 
%   listed in fortran-style order, that is, the fastest varying dimension 
%   should be listed first.  DIMLIST may also be a string if there is only
%   one dimension.  DTYPE is the datatype of the field.  
%
%   gd.defField(gridID,FIELDNAME,DIMLIST,DTYPE,MERGECODE) defines a
%   datafield with a specific merge code.  MERGECODE can be either
%   'nomerge' or 'automerge'.  MERGECODE defaults to 'nomerge' if not
%   provided.  
%  
%   This function corresponds to the GDdeffield function in the HDF
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   dimlist parameter is reversed with respect to the C library API.
%
%   Example:  Define a single precision grid field 'Temperature' with 
%   dimensions 'XDim' and 'YDim'.  Then define a single precision field 
%   'Spectra' with dimensions 'XDim', 'YDim', and 'Bands'.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('myfile.hdf','create');
%       xdim = 120; ydim = 200;
%       gridID = gd.create(gfid,'geo',xdim,ydim,[],[]);
%       gd.defProj(gridID,'geo',[],[],[]);
%       dimlist = {'XDim','YDim'};
%       gd.defField(gridID,'Temperature',dimlist,'single'); 
%       gd.defDim(gridID,'Bands',3);
%       dimlist = {'XDim','YDim','Bands'};
%       gd.defField(gridID,'Spectra',dimlist,'uint8'); 
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.create, gd.defDim. 

%   Copyright 2010-2013 The MathWorks, Inc.

if nargin < 5
    mergeCode = 'nomerge';
end

% We can take a single name as the dimlist as well as a cell array.
if ischar(idimlist)
    if strfind(idimlist,',')
        error(message('MATLAB:imagesci:hdfeos:illegalDimensionName', idimlist));
    end
    dimlist = idimlist;
else
    idimlist = fliplr(idimlist);
	% Construct the comma-delimited list for HDF-EOS2
	dimlist = idimlist{1} ;
	for j = 2:numel(idimlist);
		dimlist = [dimlist ',' idimlist{j}]; %#ok<AGROW>
	end
end

% If the user gave us matlab datatype names, convert to HDF-EOS.
switch(dtype)
    case 'single'
        dtype = 'float';
    case 'double'
        dtype = 'float64';
end

status = hdf('GD','deffield',gridID,name,dimlist,dtype,mergeCode);
hdfeos_gd_error(status,'GDdeffield');
