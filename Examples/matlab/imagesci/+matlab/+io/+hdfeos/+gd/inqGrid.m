function grids = inqGrid(filename)
%inqGrid  Retrieve names of grids in file.
%   GRIDS = inqGrid(filename) returns the names of all grids in the
%   given file.  GRIDS will be a cell array.
%
%   This function corresponds to the GDinqgrid function in the HDF-EOS
%   library C API.
%
%   Example:  
%       import matlab.io.hdfeos.*
%       grids = gd.inqGrid('grid.hdf');
%
%   See also gd, gd.create, sw.inqSwath.

%   Copyright 2010-2015 The MathWorks, Inc.

% Get a full path to the file.
fid = fopen(filename,'r');
if fid == -1
    error(message('MATLAB:imagesci:validate:fileOpen',filename));
end
fullfilename = fopen(fid);
fclose(fid);

[ngrid,gridList] = hdf('GD','inqgrid',fullfilename);
hdfeos_gd_error(ngrid,'GDinqgrid');

if ngrid == 0
    tf = hdfh('ishdf',fullfilename);
    if ~tf
        error(message('MATLAB:imagesci:hdfeos:notHDF',filename));
    end
    grids = {};
else
    grids = regexp(gridList,',','split');
    grids = grids';
end    

