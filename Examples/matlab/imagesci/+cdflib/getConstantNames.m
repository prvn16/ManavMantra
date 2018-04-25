function names = getConstantNames()
%cdflib.getConstantNames Return list of constant names
%   names = cdflib.getConstantNames() returns a list of names of constants 
%   known to the CDF library.
%
%   Example:  
%       names = cdflib.getConstantNames();
%
%   Please read the file cdfcopyright.txt for more information.
% 
%   See also cdflib, cdflib.getConstantValue.

% Copyright 2009-2013 The MathWorks, Inc.

names = cdflibmex('getConstantNames');
