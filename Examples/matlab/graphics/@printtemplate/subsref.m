function result = subsref(this, Struct)
%SUBSREF Method to overload the . notation.
%   Publicize subscripted reference to private fields of object.
%
%   Copyright 1984-2002 The MathWorks, Inc.

result = builtin('subsref', this, Struct );
