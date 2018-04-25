%addRequired(PARSEOBJ, ARGNAME, VALIDATOR) adds required argument
%   ARGNAME to the input scheme of object PARSEOBJ.  ARGNAME is a single-
%   quoted string that specifies the name of the required argument.
%   The optional VALIDATOR is a handle to a function that you write, used
%   during parsing to validate the input arguments.  If the VALIDATOR
%   throws an error or returns logical 0 (FALSE), the parsing fails and
%   MATLAB throws an error.
%
%   See also inputParser, inputParser/addOptional, inputParser/addParameter,inputParser/parse 

%   Copyright 2013 The MathWorks, Inc.
%   Built-in function
