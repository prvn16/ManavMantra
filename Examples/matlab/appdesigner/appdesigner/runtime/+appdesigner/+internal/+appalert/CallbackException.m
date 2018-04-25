classdef CallbackException < appdesigner.internal.appalert.TrimmedException
    %CALLBACKEXCEPTION Captures App Designer app callback error information
    %
    % Copyright 2015-2016 The MathWorks, Inc.    
    
    properties (Hidden)
       App
    end
   
    
    methods
        function obj = CallbackException(originalException, app)
            
            % Call super constructor to setup and trim the stack
            obj@appdesigner.internal.appalert.TrimmedException(originalException);
            
            obj.App = app;
        end
    end
end

