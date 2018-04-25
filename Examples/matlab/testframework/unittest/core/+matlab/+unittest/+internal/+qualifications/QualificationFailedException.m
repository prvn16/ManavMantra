classdef(Hidden) QualificationFailedException < MException
    % This class is undocumented and may change in a future release.
    
    % Copyright 2011-2017 The MathWorks, Inc.
    
    properties (Hidden, SetAccess=immutable, GetAccess=?matlab.unittest.TestRunner)
        QualificationFailedExceptionMarker;
    end
    
    methods (Access=protected)
        function me = QualificationFailedException(id, message, marker)
            me = me@MException(id, message);
            me.QualificationFailedExceptionMarker = marker;
        end
        
        function stack = getStack(exception)
            import matlab.unittest.internal.trimStack
            stack = trimStack(exception.getStack@MException);
        end
        
    end
        
end
