function nentries = nEntries(gridID,enttype) 
%nEntries Return number of specified objects.
%   nentries = nEntries(gridID,ENTTYPE) returns the number of specified 
%   objects in a grid.  ENTTYPE may be either 'dims' or 'fields'.
%
%   This function corresponds to the GDnentries function in the HDF-EOS
%   library C API.
%
%   Example:
%       import matlab.io.hdfeos.*
%       fid = gd.open('grid.hdf');
%       gridID = gd.attach(fid,'PolarGrid');
%       ndims = gd.nEntries(gridID,'dims');
%       nflds = gd.nEntries(gridID,'fields');
%       gd.detach(gridID);
%       gd.close(fid);
%       fprintf('The number of dimensions is %d.\n', ndims);
%       fprintf('The number of fields is %d.\n', nflds);
%
%   See also gd, gd.inqGrid.

%   Copyright 2010-2013 The MathWorks, Inc.

validateattributes(enttype,{'char'},{'nonempty'},'','ENTTYPE');
enttype = validatestring(enttype,{'dims','nentdim','fields','nentfld'});
switch(lower(enttype))
    case {'dims','nentdim'}
        enttype = 'nentdim';
    case {'fields','nentfld'}
        enttype = 'nentdfld';
end

nentries = hdf('GD','nentries',gridID,enttype);
hdfeos_gd_error(nentries,'GDnentries');
