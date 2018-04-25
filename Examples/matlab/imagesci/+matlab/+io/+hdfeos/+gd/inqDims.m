function [dims, dimlens] = inqDims(gridID)
%inqDims  Retrieve information about dimensions defined in a grid.
%   [DIMNAMES,DIMLENS] = inqDims(GRIDID) returns the names of the
%   dimensions DIMNAMES in a cell array and their respective lengths
%   DIMLENS.  This will not include the grid extent dimensions XDim and
%   YDim.
%
%   This function corresponds to the GDinqdims function in the HDF-EOS
%   library C API, but because MATLAB uses FORTRAN-style ordering, the
%   DIMNAMES and DIMLENS parameters are reversed with respect to the C 
%   library API.
%
%   Example:  
%       import matlab.io.hdfeos.*
%       gfid = gd.open('grid.hdf','read');
%       gridID = gd.attach(gfid,'PolarGrid');
%       [dims,dimlens] = gd.inqDims(gridID);
%       gd.detach(gridID);
%       gd.close(gfid);
%
%   See also gd, gd.defDim.

%   Copyright 2010-2013 The MathWorks, Inc.

[ndims,dimlist,dimlens] = hdf('GD','inqdims',gridID);
hdfeos_gd_error(ndims,'GDinqdims');

if ndims == 0
    dims = {};
    dimlens = [];
    return;
end
dims = regexp(dimlist,',','split');

if (numel(dims) == 1) && isempty(dims{1})
    dims = {};
else
    dims = regexp(dimlist,',','split');
    dims = dims';
    dimlens = dimlens';
end
