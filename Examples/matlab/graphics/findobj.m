%FINDOBJ Find objects with specified property values.
%   H = FINDOBJ('P1Name',P1Value,...) returns the handles of the
%   objects at the root level and below whose property values
%   match those passed as param-value pairs to the FINDOBJ
%   command.
%
%   H = FINDOBJ(ObjectHandles, 'P1Name', P1Value,...) restricts
%   the search to the objects listed in ObjectHandles and their
%   descendents.
%
%   H = FINDOBJ(ObjectHandles, 'flat', 'P1Name', P1Value,...)
%   restricts the search only to the objects listed in
%   ObjectHandles.  Their descendents are not searched.
%
%   H = FINDOBJ(ObjectHandles, '-depth', d,...) specifies the
%   depth of the search.  It controls how many levels under the
%   handles in ObjectHandles are traversed.  Specifying d=0 gets
%   the same behavior as using the 'flat' argument.  Specifying
%   d=inf gets the default behavior of all levels.
%
%   H = FINDOBJ returns the handles of the root object and all its
%   descendents.
%
%   H = FINDOBJ(ObjectHandles) returns the handles listed in
%   ObjectHandles, and the handles of all their descendents.
%
%   H = FINDOBJ('P1Name', P1Value, '-logicaloperator', ...)
%   applies the logical operator to the property value matching.
%   Possible values for -logicaloperator are -and, -or, -xor, -not.
%
%   H = FINDOBJ('-regexp', 'P1Name', 'regexp',...) matches objects 
%   using regular expressions as if the value of the property P1Name
%   is passed to REGEXP as:
%   regexp('P1Name', 'regexp').
%   FINDOBJ returns the object's handle if a match occurs.
%
%   H = FINDOBJ('-property', 'P1Name') finds all objects having
%   the specified property.
%
%   See also SET, GET, GCF, GCA.

%   Copyright 1984-2009 The MathWorks, Inc.
