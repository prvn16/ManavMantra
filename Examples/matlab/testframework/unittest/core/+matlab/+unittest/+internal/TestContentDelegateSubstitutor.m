classdef (Hidden) TestContentDelegateSubstitutor
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    methods (Static)
        function transferTeardownDelegate(supplier, acceptor)
            supplier.transferTeardownDelegate_(acceptor);
        end
    end
end

