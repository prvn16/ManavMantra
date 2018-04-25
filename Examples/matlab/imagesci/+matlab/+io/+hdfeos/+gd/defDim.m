function defDim(gid,dimname,dimlen)
%defDim Define new dimension within grid.
%   defDim(gridID,DIMNAME,DIMLEN) defines a new dimension named DIMNAME
%   with length DIMLEN in the grid structure identified by gridID.
%
%   To specify an unlimited dimension, you may use either 0 or 'unlimited' 
%   for DIMLEN.
%  
%   This function corresponds to the GDdefdim function in the HDF-EOS 
%   library C API.
%
%   Example:  Define a dimension 'Band' with length of 15 and an unlimited
%   dimension 'Time'.
%       import matlab.io.hdfeos.*
%       gfid = gd.open('myfile.hdf','create');
%       gridID = gd.create(gfid,'PolarGrid',100,100,[],[]);
%       gd.defDim(gridID,'Band',15);
%       gd.defDim(gridID,'Time',0);
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.defField, gd.dimInfo.

%   Copyright 2010-2013 The MathWorks, Inc.

if ischar(dimlen) && strcmp(dimlen,'unlimited')
    dimlen = 0;
end

status = hdf('GD','defdim',gid,dimname,dimlen);
hdfeos_gd_error(status,'GDdefdim');
