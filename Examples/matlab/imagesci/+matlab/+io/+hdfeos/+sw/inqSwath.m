function swaths = inqSwath(filename)
%inqSwath  Retrieve names of swaths in file.
%   SWATHS = inqSwath(filename) returns a cell array containing the 
%   names of all the swaths in a file.
%
%   This function corresponds to the SWinqswath function in the HDF-EOS
%   library C API.
%
%   Example:  
%       import matlab.io.hdfeos.*
%       swaths = sw.inqSwath('swath.hdf');
%
%   See also sw, gd.inqGrid.

%   Copyright 2010-2013 The MathWorks, Inc.

% Get a full path to the file.
fid = fopen(filename,'r');
if fid == -1
    error(message('MATLAB:imagesci:validate:fileOpen',filename));
end
fullfilename = fopen(fid);
fclose(fid);

[nswath,swathlist] = hdf('SW','inqswath',fullfilename);
hdfeos_sw_error(nswath,'SWinqswath');

if nswath == 0
    tf = hdfh('ishdf',fullfilename);
    if ~tf
        error(message('MATLAB:imagesci:hdfeos:notHDF', filename));
    end
    swaths = {};
else
    swaths = regexp(swathlist,',','split');
    swaths = swaths';
end
