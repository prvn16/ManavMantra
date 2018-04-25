%addParameter(PARSEOBJ, PARAMNAME, DEFAULT, VALIDATOR) adds parameter
%   name-value argument PARAMNAME to the input scheme of object PARSEOBJ. 
%   Parameter name-value pair arguments are parsed after required and
%   optional arguments. The PARAMNAME input is a single-quoted string that
%   specifies the parameter name and is the name of the field in the
%   results structure that is created when parsing. The DEFAULT input
%   specifies the value to use when the optional argument PARAMNAME is not
%   present in the actual inputs to the function. The optional VALIDATOR
%   input is the same as for ADDREQUIRED.
%   
%   addParameter(PARSEOBJ,...,'PartialMatchPriority',PRIORITY) adds a 
%   parameter name-value argument to the input scheme of the object 
%   PARSEOBJ.  If another parameter in the input scheme could allow an 
%   ambiguous partial match with this parameter, then if a partial string 
%   is suppled as an input, the parameter with the single lowest 
%   'PartialMatchPriority' value will be selected and a warning will be 
%   issued.  The default value of 'PartialMatchPriority' is 1. 
%   'PartialMatchPriority' must be a positive scalar integer.
%
%   See also inputParser, inputParser/addOptional, inputParser/addRequired, inputParser/parse 

%   Copyright 2013 The MathWorks, Inc.
%   Built-in function