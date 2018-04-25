%WINQUERYREG Get an item from the Microsoft Windows registry.
%   VALUE = WINQUERYREG(ROOTKEY, SUBKEY, VALNAME) 
%   returns the value of the specified key.
%
%   VALUE = WINQUERYREG(ROOTKEY, SUBKEY)
%   returns value that has no value name property.
% 
%   VALNAMES = WINQUERYREG('name',...)
%   returns all value names in ROOTKEY\SUBKEY in a cell array.
% 
%   Examples:
%
%       winqueryreg HKEY_CURRENT_USER Environment USER
%       winqueryreg HKEY_LOCAL_MACHINE SOFTWARE\Classes\.zip
%       winqueryreg HKEY_CURRENT_USER Environment path
%       winqueryreg name HKEY_CURRENT_USER Environment
%
%   
%   This function works only for the following registry
%   value types:
%
%      strings (REG_SZ)
%      expanded strings (REG_EXPAND_SZ)
%      32-bit integer (REG_DWORD)
%
%   If the specified value is a character vector, this function returns a
%   character vector. If the value is a 32-bit integer, this function
%   returns the value as an integer of MATLAB type int32.
%
%   WINQUERYREG is available only on Microsoft Windows.
%
%   See also ACTXSERVER, REGISTEREVENT.

%   Copyright 1984-2015 The MathWorks, Inc. 

