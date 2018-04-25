%JSONENCODE Encode structured data as JSON-formatted text.
%
%   TEXT = jsonencode(TYPE) returns a character vector TEXT in JSON format that
%   encodes MATLAB data TYPE as a JSON data type, as shown in the table below.
%
%   TEXT = jsonencode(...,'NAME',VALUE) returns a character vector TEXT in JSON
%   format that encodes TYPE according to the specified name-value pairs.
%   The arguments are as follows:
%
%       Name                 Description                               Data Type
%       ----                 --------------------------                ---------
%      'ConvertInfAndNaN'    Customize the encoding of special         logical scalar
%                            floating point values (NaN, Inf, -Inf)
%                            based on the specified value. Value true
%                            encodes special floating points as null
%                            while value false encodes them as
%                            literals (NaN, Infinity, -Infinity).
%
%
%   MATLAB Data Type          | JSON Data Type
%   --------------------------+-----------------------------
%   array              empty  | Array, empty
%   --------------------------+-----------------------------
%   logical            scalar | Boolean
%                      vector | Array of booleans
%                      array  | Nested array of booleans
%   --------------------------+-----------------------------
%   character          vector | String
%                      array  | Array of strings
%                      empty  | String, empty
%   --------------------------+-----------------------------
%   numeric            scalar | Number
%                      vector | Array of numbers
%                      array  | Nested array of numbers
%   --------------------------+-----------------------------
%   table                     | Array of objects
%   --------------------------+-----------------------------
%   cell                      | Array
%   --------------------------+-----------------------------
%   structure          scalar | Object
%                      vector | Array of objects
%                      array  | Nested array of objects
%   --------------------------+-----------------------------
%   string             scalar | String
%                      vector | Array of strings
%                      array  | Nested array of strings
%                   <missing> | null
%   --------------------------+-----------------------------
%   datetime           scalar | String. (string method used
%                             |  to convert date and time to
%                             |  string format)
%                      vector | Array of strings
%                      array  | Nested array of strings
%   --------------------------+-----------------------------
%   categorical        scalar | String. (string method used
%                             |  to create string format)
%                      vector | Array of strings
%                      array  | Nested array of strings
%   --------------------------+-----------------------------
%   containers.Map            | Object
%   --------------------------+-----------------------------
%   object             scalar | Object. (public properties
%                             |  encoded as name-value pairs)
%                      vector | Array of objects
%                      array  | Nested array of objects
%   --------------------------+-----------------------------
%
%   Examples:
%
%     value = {'one'; 'two'; 'three'};
%     jsonencode(value)
%
%     ans =
%
%     ["one","two","three"]
%
%     s.Width = 800;
%     s.Height = 600;
%     s.Title = 'View from the 15th Floor';
%     s.Animated = false;
%     s.IDs = [116, 943, 234, 38793];
%     jsonencode(s)
%
%     ans =
%
%     {"Width":800,"Height":600,"Title":"View from the 15th Floor","Animated":false,"IDs":[116,943,234,38793]}
%
%    % Customize the encoding of special floating point values (NaN, Inf, -Inf)
%
%     arr = [1, 2, NaN, Inf, -Inf];
%     jsonencode(arr, 'ConvertInfAndNaN', false)
%     ans =
%
%     [1,2,NaN,Infinity,-Infinity]
%
%
%   See also JSONDECODE, WEBWRITE.

% Copyright 2016 The MathWorks, Inc.

