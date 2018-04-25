classdef (Abstract, Hidden) UnsuccessfulInteractionMixin
    % This class is undocumented and may change in a future release.
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % Exception - Exception produced by mock object interaction.
        %
        %   The Exception property is a scalar MException object indicating the
        %   exception thrown when interacting with the mock object.
        Exception (1,1) MException = MException("",'');
    end
    
    methods (Hidden, Access=protected)
        function mixin = UnsuccessfulInteractionMixin(exception)
            mixin.Exception = exception;
        end
    end
end
