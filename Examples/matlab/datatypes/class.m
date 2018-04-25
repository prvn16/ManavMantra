%CLASS  Return class name of object.
%   S = CLASS(OBJ) returns the name of the class of object OBJ.
% 
%   Possibilities are:
%     double          -- Double precision floating point number array
%                        (this is the traditional MATLAB matrix or array)
%     single          -- Single precision floating point number array
%     logical         -- Logical array
%     char            -- Character array
%     cell            -- Cell array
%     struct          -- Structure array
%     function_handle -- Function Handle
%     int8            -- 8-bit signed integer array
%     uint8           -- 8-bit unsigned integer array
%     int16           -- 16-bit signed integer array
%     uint16          -- 16-bit unsigned integer array
%     int32           -- 32-bit signed integer array
%     uint32          -- 32-bit unsigned integer array
%     int64           -- 64-bit signed integer array
%     uint64          -- 64-bit unsigned integer array
%     <class_name>    -- MATLAB class name for MATLAB objects
%     <java_class>    -- Java class name for java objects
%
%   %Example 1: Obtain the name of the class of value pi
%   name = class(pi);
%
%   %Example 2: Obtain the full name of a package-based java class
%   obj = java.lang.String('mystring');
%   class(obj)
%
%   For classes created without a classdef statement (pre-MATLAB version
%   7.6 syntax), CLASS invoked within a constructor method creates an
%   object of type 'class_name'.  Constructor methods are functions saved
%   in a file named <class_name>.m and placed in a directory named
%   @<class_name>.  Note that 'class_name' must be the second argument to
%   CLASS.  Uses of CLASS for this purpose are shown below.
%
%   O = CLASS(S,'class_name') creates an object of class 'class_name'
%   from the structure S.
%
%   O = CLASS(S,'class_name',PARENT1,PARENT2,...) also inherits the
%   methods and fields of the parent objects PARENT1, PARENT2, ...
%
%   O = CLASS(struct([]),'class_name',PARENT1,PARENT2,...), specifying
%   an empty structure S, creates an object that inherits the methods and
%   fields from one or more parent classes, but does not have any 
%   additional fields beyond those inherited from the parents.
%
%   See also ISA, CLASSDEF, STRUCT, SUPERIORTO, INFERIORTO.

%   Copyright 1984-2017 The MathWorks, Inc. 
%   Built-in function.
