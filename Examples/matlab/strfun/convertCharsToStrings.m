%convertCharsToStrings Convert character arrays to string arrays and leave others unaltered.
%   B = convertCharsToStrings(A) converts A to a string array if A is a
%   character array. If A is a character vector, then B is a string scalar.
%   If A is a cell array of character vectors, then B is a string array.
%   If A is any other data type, then convertCharsToStrings returns A
%   unaltered.
%
%   [A,B,C,...] = convertCharsToStrings(X,Y,Z,...) operates on multiple
%   inputs and outputs. This is especially useful when functions use
%   varargin, for example functions that have name-value parameter
%   arguments specified by varargin.
%
%   NOTE: The primary purpose of convertCharsToStrings is to make code that
%   accepts string inputs also accept character vector or cell array of
%   character vectors inputs. A common way to use convertCharsToStrings is
%   to pass the entire input argument list in and out of
%   convertCharsToStrings. After calling convertCharsToStrings, no other
%   changes need to be made to support character vector and cell array of
%   character vector inputs.
%
%   Examples:
%       a = convertCharsToStrings('Luggage combination')
%
%       a =                     
%           "Luggage combination"
%
%
%       % A common way to use this is:
%       [varargin{:}] = convertCharsToStrings(varargin{:})
%
%       [a,s,d,f] = convertCharsToStrings('one', 2, "three", {'four','five'})
%
%       a =                     
%           "one"               
%       s =                     
%            2                  
%       d =                     
%           "three"               
%       f =                     
%         1x2 string array        
%           "four"    "five"      
%
%   See also STRING, convertStringsToChars, ISCHAR, ISCELLSTR,
%   ISSTRING, isStringScalar, VARARGIN.

%   Copyright 2017 The MathWorks, Inc.
