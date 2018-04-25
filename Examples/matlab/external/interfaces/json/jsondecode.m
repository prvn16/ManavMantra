%JSONDECODE Decode JSON-formatted text.
%
%   VALUE = jsondecode(TEXT) decodes a character vector TEXT in JSON format.
%   VALUE depends on the data encoded in the JSON-formatted text. jsondecode
%   decodes JSON data types as the MATLAB data types shown in the table.
%
%                             |
%   JSON Data Type            | MATLAB Data Type
%   --------------------------+------------------
%   null                      | empty double, []
%   --------------------------+------------------
%   Boolean                   | scalar logical
%   --------------------------+------------------
%   Number                    | scalar double
%   --------------------------+------------------
%   String                    | character vector
%   --------------------------+------------------
%   Object (In JSON, object   | scalar structure
%    means an unordered set   |  (Names are made
%    of name-value pairs.)    |  valid.)
%   --------------------------+------------------
%   Array, when elements are  | cell array
%    of different data types  |
%   --------------------------+------------------
%   Array of booleans         | logical array
%   --------------------------+------------------
%   Array of numbers          | double array
%   --------------------------+------------------
%   Array of strings          | cellstr 
%   --------------------------+------------------
%   Array of objects, when    | structure array
%    all objects have the     |
%    same set of names        |
%   --------------------------+------------------
%   Array of objects, when    | cell array of
%    objects have different   | scalar structures
%    names                    |
%   --------------------------+------------------
%
%   Examples:
%
%     jsondecode('["one", "two", "three"]')
%
%     ans =
%
%         'one'
%         'two'
%         'three'
%
%     json = '{"Width":800,"Height":600,"Title":"View from the 15th Floor","Animated":false,"IDs":[116,943,234,38793]}';
%     jsondecode(json)
%
%     ans = 
%
%            Width: 800
%           Height: 600
%            Title: 'View from the 15th Floor'
%         Animated: 0
%              IDs: [4x1 double]
%
%   See also JSONENCODE, WEBREAD, WEBWRITE.

% Copyright 2016 The MathWorks, Inc.

