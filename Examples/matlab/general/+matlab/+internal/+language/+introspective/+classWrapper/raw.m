classdef raw < handle
    properties (SetAccess=protected, GetAccess=protected)
        isUnspecifiedConstructor = false;
    end

    methods (Abstract)
        classInfo = getConstructor(cw, justChecking);
    end
end

%   Copyright 2007 The MathWorks, Inc.
