%TYPECAST Convert datatypes without changing underlying data.
%   Y = TYPECAST(X, DATATYPE) convert X to DATATYPE.  If DATATYPE has
%   fewer bits than the class of X, Y will have more elements than X.  If
%   DATATYPE has more bits than the class of X, Y will have fewer
%   elements than X.  X must be a scalar or vector.  DATATYPE must be one
%   of 'UINT8', 'INT8', 'UINT16', 'INT16', 'UINT32', 'INT32', 'UINT64',
%   'INT64', 'SINGLE', or 'DOUBLE'.
% 
%   Note: An error is issued if X contains fewer values than are needed
%   to make an output value.
% 
%   Example:
% 
%      X = uint32([1 255 256]);
%      Y = typecast(X, 'uint8');
% 
%   On little-endian architectures Y will be
% 
%      [1   0   0   0   255 0   0   0   0   1   0   0]
% 
%  See also CLASS, CAST, SWAPBYTES.

%   Copyright 1984-2009 The MathWorks, Inc.
%   Built-in function.

