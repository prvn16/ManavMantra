%NET.enableAutoRelease unlocks a .NET object representing a RunTime Callable 
% Wrapper (COM Wrapper) so that MATLAB releases the COM object. Call this 
% function only if the object was locked using NET.disableAutoRelease.
%
% A = NET.enableAutoRelease(OBJ) 
%
% OBJ - .NET object representing a COM Wrapper.
%
% If you locked a .NET object representing a COM Wrapper using 
% NET.disableAutoRelease, call this function so that MATLAB releases 
% the COM wrapper when the object goes out of scope.
%
%   See also: NET.disableAutoRelease
 
% Copyright 2009-2010 The MathWorks, Inc.
%  $Date $
