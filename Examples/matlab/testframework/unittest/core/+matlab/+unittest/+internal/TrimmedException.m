classdef TrimmedException < MException
    % This class is undocumented.
    
    %  Copyright 2015-2016 MathWorks, Inc.
    
    properties(SetAccess=immutable, GetAccess=protected)
        OriginalException;
    end
    
    methods
        function trimmed = TrimmedException(other)
            import matlab.unittest.internal.TrimmedException;
            
            trimmed = trimmed@MException(other.identifier, '%s', other.message);
            trimmed.OriginalException = other;
            trimmed.type = other.type;
            for idx = 1:numel(other.cause)
                trimmed = trimmed.addCause(TrimmedException(other.cause{idx}));
            end
        end
    end
    
    methods(Access=protected)
        function stack = getStack(trimmed)
            import matlab.unittest.internal.trimStackEnd;
            stack = trimStackEnd(trimmed.OriginalException.getStack);
        end
    end
    
end
