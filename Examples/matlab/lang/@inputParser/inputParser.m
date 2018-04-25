%inputParser Construct input parser object
%   PARSEOBJ = inputParser constructs an empty inputParser object, PARSEOBJ. 
%   This utility object supports the creation of an input scheme that
%   represents the characteristics of each potential input argument. Once
%   you have defined the input scheme, you can use the inputParser object
%   to parse and validate input arguments to functions.
%
%   The inputParser object follows handle semantics; that is, methods called on
%   it affect the original object, not a copy of it. Also note that inputParser
%   method names begin with a lowercase letter (e.g., addRequired) while
%   inputParser property names begin with an uppercase letter (e.g., Unmatched).
%
%   parse(PARSEOBJ, INPUT1, INPUT2, ...) parses and validates the named inputs
%   INPUT1, INPUT2, etc.
%
%   MATLAB configures inputParser objects to recognize an input scheme.
%   Use any of the following methods to create the scheme for parsing a
%   particular function.
%
%   inputParser methods:
%       addRequired     -   Adds a required argument to the input scheme.
%       addOptional     -   Adds a optional argument to the input scheme.
%       addParameter    -   Adds a name-value argument to the input scheme.
%       addParamValue   -   Not recommended, use addParameter instead.
%       parse           -   Parse and validate input arguments.
%
%   inputParser public fields:
%       FunctionName    -   Name to be used when errors are thrown
%       CaseSensitive   -   If true, inputParser will match parameter names
%                           based on case.
%       KeepUnmatched   -   If true, inputParser will add name-value pairs
%                           to the Unmatched structure.
%       PartialMatching -   If true, inputParser will allow partial names
%                           for parameters.
%       StructExpand    -   If true, inputParser will accept structures 
%                           with fields equal to names of parameters.
%       Parameters      -   List of parameter names in the input scheme.
%                           Read only.
%       Results         -   Set by the inputParser/parse method.  Contains
%                           the validated values of the inputs. Read only.
%       Unmatched       -   If the KeepUnmatched property is true, 
%                           inputParser/parse will contain unmatched 
%                           parameters and their values. Read only.
%       UsingDefaults   -   list of parameter names not explicitly passed 
%                           to the function. Read only.
%
%   Example:
%      p = inputParser; 
%
%      p.addRequired('a'); 
%      p.addOptional('b',1);
%      p.addParameter('c',2);
%
%      p.parse(10, 20, 'c', 30);
%      res = p.Results
%
%   Returns a structure:
%      res = 
%         a: 10
%         b: 20
%         c: 30
%
%   See also validateattributes, validatestring.

%   Copyright 1993-2013 The MathWorks, Inc.

%{
properties
%   FunctionName    -  Char array.  The function name that is used in
%   error messages thrown by the validating functions.
FunctionName

%   CaseSensitive   -  Scalar logical.  If TRUE, parameters are matched
%   case sensitively.  If FALSE (default), matching is case
%   insensitive.  
CaseSensitive

%   KeepUnmatched   -  Scalar logical.  If TRUE, inputs that do not
%   match the input scheme are added to the UNMATCHED property.  If 
%   FALSE (default), MATLAB throws an error if an input that does not
%   match the scheme is found.
% 
%   See also inputParser.Unmatched
KeepUnmatched

%   PartialMatching -  Scalar logical.  If TRUE (default), inputs which
%   are leading substrings of parameter names will be accepted and
%   the value matched to that parameter.  If there are multiple 
%   possible matches to the input, MATLAB throws an error. If FALSE,
%   the input names are required to match a parameter name exactly (with
%   respect to the CaseSensitive property).
PartialMatching

%   StructExpand    -  Scalar logical.  If TRUE (default), the PARSE
%   method accepts a structure as an input in place of param-value
%   pairs (INPUT1, INPUT2, etc.). If FALSE, a structure is treated as a
%   regular, single input.
StructExpand

%   Parameters      -  Cell array of character vectors.  A list of the
%   parameters in the input parser. Each row is a character vector
%   containing the full name of a known parameter.
Parameters 

%   Results         -  Structure array.  The results of the last parse.
%   Each known parameter is represented by a field in the structure.
%   The name of the field is the name of the parameter and the value
%   stored in the field is the value of the input.       
Results

%   Unmatched       -  Structure array in the same format as the
%   Results.  If KeepUnmatched is TRUE, this will contain the list of
%   inputs that did not match any parameters in the input scheme.
%   
%   See also, inputParser.KeepUnmatched
Unmatched

%   UsingDefaults   -  Cell array of character vectors.  A list of the
%   parameters that were not set by the user and, consequently, are using
%   their default values. 
UsingDefaults
end
%}



