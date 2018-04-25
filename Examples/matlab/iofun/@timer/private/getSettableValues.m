function [propnames,props] = getSettableValues(obj)
%getSettableValues gets all the settable values of a timer object array
%
%    getSettableValues(OBJ) returns the settable values of OBJ as a list of settable
%    property names and a cell array containing the values.
%
%    See Also: TIMER/PRIVATE/RESETVALUES

%    RDD 1-18-2002
%    Copyright 2001-2017 The MathWorks, Inc.

objlen = length(obj);

propnames = [];
props = cell(objlen,1);
% foreach valid timer object...
for objnum=1:objlen
    if isJavaTimer(obj(objnum).getJobjects) % valid java object found
        if isempty(propnames) % if settable propnames are not yet known, get them from set
            propnames = fieldnames(set(obj(objnum).getJobjects));
        end
        % the settable values of the valid timer object
        props{objnum} = get(obj(objnum).getJobjects,propnames);
    end
end
