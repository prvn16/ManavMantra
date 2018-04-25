%convertStringsToChars Convert string arrays to character arrays and leave others unaltered.
%   B = convertStringsToChars(A) converts A to a character array if A is a
%   string array. If A is a string scalar, then B is a character vector. If
%   A is a string array, then B is a cell array of character vectors.  If A
%   has any other data type, then convertStringsToChars returns A
%   unaltered.
%
%   [A,B,C,...] = convertStringsToChars(X,Y,Z,...) supports multiple inputs
%   and outputs. This is especially useful when functions use varargin, for
%   example functions that have name-value parameter arguments specified by
%   varargin.
%
%   NOTE: The primary purpose of convertStringsToChars is to make existing
%   code accept string inputs. A common way to use convertStringsToChars is
%   to pass the entire input argument list in and out of
%   convertStringsToChars. After calling convertStringsToChars, no other
%   changes need to be made to support string inputs.
%
%   NOTE: <missing> string inputs are converted into 0x0 char, i.e. ''.
%
%   Examples:
%       a = convertStringsToChars("Luggage combination")
%
%       a =                     
%           'Luggage combination'               
%
%
%       % A common way to use this is:
%       [varargin{:}] = convertStringsToChars(varargin{:})
%
%
%       [a,b,c,d] = convertStringsToChars('one',2,"three",["four","five"])
%
%       a =                     
%           'one'               
%       b =                     
%            2                  
%       c =                     
%           'three'               
%       d =                     
%         1x2 cell array        
%           'four'    'five'      
%
%   See also STRING, convertCharsToStrings, ISCHAR, ISCELLSTR, 
%   ISSTRING, isStringScalar, ISMISSING, VARARGIN.

%   Copyright 2017 The MathWorks, Inc.
