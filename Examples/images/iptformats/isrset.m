function [tf, supported] = isrset(filename)
%ISRSET Check if file is R-Set.
%   [TF, SUPPORTED] = ISRSET(FILENAME) sets TF to true if the file FILENAME
%   is a reduced resolution dataset (R-Set) created by RSETWRITE and false
%   if it is not an R-Set.  The value of SUPPORTED is true if the .rset
%   file is compatible with the R-Set tools (such as IMTOOL) in this
%   version of the Image Processing Toolbox.  If SUPPORTED is false, the
%   R-Set file was probably written by a newer version of RSETWRITE than
%   ships with this version of the Image Processing Toolbox.
%
%   See also RSETWRITE.

%   Copyright 2008-2017 The MathWorks, Inc.

% Test for file existence.

filename = matlab.images.internal.stringToChar(filename);

[fid, msg] = fopen(filename, 'r');
if (fid < 0)
    
       error(message('images:validate:fileOpen', filename, msg));
end
fclose(fid);

% Test that file is HDF5.
try
    fid = H5F.open(filename, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');
catch ME %#ok<*NASGU>
    tf = false;
    supported = false;
    return
end

% Check that the file has the .rset schema.
try
    gid = H5G.open(fid, '/FormatInfo');
catch ME
    H5F.close(fid);
    tf = false;
    supported = false;
    return
end

tf = true;

% Get file format details.
try
    attrID = H5A.open_name(gid, 'BackwardVersion');
    backwardVersion = H5A.read(attrID, 'H5ML_DEFAULT');
    H5A.close(attrID);
    
    supported = (backwardVersion <= iptui.RSet.maxSupportedRSetVersion);
catch ME
    tf = false;
    supported = false;
end

% Clean up.
H5G.close(gid);
H5F.close(fid);
