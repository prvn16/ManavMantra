function [dimnames, dimlens] = inqDims(swathID)
%inqDims  Retrieve information about dimensions defined in a swath.
%   [DIMNAMES,DIMLENS] = inqDims(SWATHID) returns the names of the 
%   dimensions DIMNAMES as a cell array.  The length of each respective
%   dimension is returned in DIMLENS.
%
%   This function corresponds to the SWinqdims routine in the HDF-EOS 
%   library.
%
%   Example:  
%       import matlab.io.hdfeos.*
%       swfid = sw.open('swath.hdf');
%       swathID = sw.attach(swfid,'Example Swath');
%       [dimnames,dimlens] = sw.inqDims(swathID);
%       sw.detach(swathID);
%       sw.close(swfid);
%
%   See also sw, sw.defDim.

%   Copyright 2010-2013 The MathWorks, Inc.

[ndims,dimlist,dimlens] = hdf('SW','inqdims',swathID);
hdfeos_sw_error(ndims,'SWinqdims');

if ndims == 0
    dimnames = {};
    dimlens = [];
else
    dimnames = regexp(dimlist,',','split');
    dimnames = dimnames';
    dimlens = dimlens';
end
