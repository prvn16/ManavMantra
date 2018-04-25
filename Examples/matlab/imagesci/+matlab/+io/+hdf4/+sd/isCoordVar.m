function tf = isCoordVar(sdsID)
%isCoordVar Determine if data set is a coordinate variable.
%   TF = isCoordVar(sdsID) returns true if a data set is a coordinate
%   variable and returns false otherwise.
%
%   This function corresponds to the SDiscoordvar function in the HDF
%   library C API.
% 
%   Example:
%       import matlab.io.hdf4.*
%       sdID = sd.start('sd.hdf');
%       ndataset = sd.fileInfo(sdID);
%       for idx = 0:ndataset-1
%           sdsID = sd.select(sdID,idx);
%           sdsName = sd.getInfo(sdsID);
%           fprintf('%s (index %d) ', sdsName, idx);
%           if ( sd.isCoordVar(sdsID) )
%               fprintf('is a coordinate variable.\n');
%           else
%               fprintf('is not a coordinate variable.\n');
%           end
%           sd.endAccess(sdsID);
%       end
%       sd.close(sdID);
%
%   See also sd, sd.isRecord.

%   Copyright 2010-2013 The MathWorks, Inc.

x = hdf('SD','iscoordvar',sdsID);
if x > 0
    tf = true;
else
    tf = false;
end

