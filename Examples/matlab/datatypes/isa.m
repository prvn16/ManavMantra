%ISA    Determine if input is object of specified class.
%   ISA(obj,'ClassName') returns true if obj is an instance of the
%   class specified by ClassName, and false otherwise. isa also returns
%   true if obj is an instance of a class that is derived from ClassName.
%   Classname must be a character vector or string scalar.
%
%   Some possibilities for 'ClassName' are:
%     double          -- Double precision floating point numeric array
%                        (this is the traditional MATLAB matrix or array)
%     single          -- Single precision floating-point numeric array
%     logical         -- Logical array
%     char            -- Character array
%     int8            -- 8-bit signed integer array
%     uint8           -- 8-bit unsigned integer array
%     int16           -- 16-bit signed integer array
%     uint16          -- 16-bit unsigned integer array
%     int32           -- 32-bit signed integer array
%     uint32          -- 32-bit unsigned integer array
%     int64           -- 64-bit signed integer array
%     uint64          -- 64-bit unsigned integer array
%     cell            -- Cell array
%     struct          -- Structure array
%     function_handle -- Function Handle
%     <classname>     -- Any MATLAB, Java or .NET class
%
%   ISA(obj,'classCategory') returns true if obj is an instance of
%   any of the classes in the specified classCategory, and false otherwise.
%   isa also returns true if obj is an instance of a class that is derived 
%   from any of the classes in classCategory.
%
%   classCategory can be 'numeric', 'float', or 'integer', representing
%   a category of classes:
%   numeric -- Integer or floating-point array (double, single,
%              int8, uint8, int16, uint16, int32, uint32,
%              int64, uint64)
%   float   -- Single- or double-precision floating-point array
%              (double, single)
%   integer -- Signed or unsigned integer array (int8, uint8,
%              int16, uint16, int32, uint32, int64, uint64)
%
%   See also ISNUMERIC, ISLOGICAL, ISCHAR, ISCELL, ISSTRUCT, ISFLOAT,
%            ISINTEGER, ISOBJECT, ISJAVA, ISSPARSE, ISREAL, CLASS.

%   Copyright 1984-2017 The MathWorks, Inc. 
%   Built-in function.
