%SET    Set System object property values
%   SET(obj,'PropertyName',PropertyValue) sets the value of the specified
%   property for the System object, obj.
%
%   SET(obj,'PropertyName1',Value1,'PropertyName2',Value2,...) sets
%   multiple property values with a single statement.
%
%   Given a structure S, whose field names are object property names,
%   SET(obj,S) sets the properties identified by each field name of S with
%   the values contained in the structure.
%
%   A = SET(obj, 'PropertyName') returns the possible values for the
%   specified property of the System object, obj. The returned array is a
%   cell array of possible value strings or an empty cell array if the
%   property does not have a finite set of possible string values.
%
%   A = SET(obj) returns all property names and their possible values for
%   the System object, obj. The return value is a structure whose field
%   names are the property names of obj, and whose values are cell arrays
%   of possible property value strings or empty cell arrays.
%
%   See also get, disp.
