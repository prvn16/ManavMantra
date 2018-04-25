%ENUMERATION Display class enumeration member and names.
%   ENUMERATION classname displays the names of the enumeration members  
%   for the MATLAB class with the name 'classname'.  
%
%   Use the functional form of ENUMERATION when classname is a string
%   scalar.
%
%   ENUMERATION(obj) displays the names of the enumeration members for
%   the class of obj.
%
%   M = ENUMERATION(...) returns the enumeration members for the class in  
%   the column vector M.
%
%   [M, S] = ENUMERATION(...) returns the names of the enumeration members
%   in the cell array of character vectors S. The names in S correspond
%   element-wise to the enumeration members in M.
%
%   If an enumeration is derived from a built-in class it may specify more 
%   than one name for a given enumeration member.  When you call the 
%   ENUMERATION function with no output arguments, MATLAB displays only the
%   first name for each member (as specified in the class definition). To 
%   see all available enumeration members and their names, use the two-
%   output form [M, S] = ENUMERATION(...).
%
%   Examples based on the following enumeration class:
%
%   classdef boolean < logical
%       enumeration
%           No(0)
%           Yes(1)
%           Off(0)
%           On(1)
%       end
%    end
%
%   %Example 1: Display the names of the enumeration members for 'boolean'
%   enumeration boolean
%    
%   %Example 2: Use a member of the enumeration as input to obtain all
%   members of the enumeration
%   e = boolean.Yes;
%   members = enumeration(e);
%
%   %Example 3: Get all available enumeration members and their names:
%   [members, names] = enumeration('boolean');
%
%   See also CLASSDEF.

%   Copyright 2007-2017 The MathWorks, Inc.
%   Built-in function.
