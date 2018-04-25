classdef (Abstract, AllowedSubclasses = {?timerange, ?vartype, ?withtol}) subscripter < matlab.mixin.internal.Scalar & matlab.internal.datatypes.saveLoadCompatibility
%SUBSCRIPTER Internal class for tabular subscripting.
% This class is for internal use only and will change in a
% future release.  Do not use this class.

%    An abstract class to create subclasses that wrap around subscripts to a table
%    to handle them specially.

    %   Copyright 2016 The MathWorks, Inc.
    
    methods(Abstract, Access={?withtol, ?timerange, ?vartype, ?matlab.internal.tabular.private.tabularDimension})
        % The getSubscripts method is called by table subscripting to get the matches
        % for whatever subscripted are specified in the object's properties. It needs to
        % know (from the table's subscripter for that dimension) the size of the
        % dimension and what (if any) are the "labels" along the dimension.
        subs = getSubscripts(obj,subscripter)
    end
end

