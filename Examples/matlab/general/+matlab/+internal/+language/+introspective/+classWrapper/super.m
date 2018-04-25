classdef super < handle
    methods (Abstract)
        b = hasClassHelp(cw);
        classInfo = getSimpleElementHelpFile(cw);
    end

    methods (Abstract, Access=protected)
        classInfo = getClassHelpFile(cw);
    end
end

%   Copyright 2007 The MathWorks, Inc.
