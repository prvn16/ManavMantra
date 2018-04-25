classdef (Sealed) InteractiveTestCase < matlab.mock.TestCase
    % InteractiveTestCase - A TestCase for interactive experimentation.
    %   InteractiveTestCase is a matlab.mock.TestCase that can be used for
    %   interactive experimentation at the MATLAB command prompt. It reacts to
    %   qualification failures and successes by printing messages to standard
    %   output (the screen) for both passing and failing conditions. To
    %   construct an instance, use matlab.mock.TestCase.forInteractiveUse.
    
    %  Copyright 2016 The MathWorks, Inc.
    
    methods (Hidden, Access=?matlab.mock.TestCase)
        function testCase = InteractiveTestCase
            
            % Prohibit access from non-interactive contexts.
            if ~matlab.unittest.internal.isInteractiveContext(dbstack('-completenames'))
                error(message('MATLAB:mock:TestCase:InteractiveUseOnly'));
            end
            
            matlab.unittest.internal.addInteractiveListeners(testCase);
        end
    end
    
    methods (Hidden, Static)
        function testCase = loadobj(testCase)
            matlab.unittest.internal.addInteractiveListeners(testCase);
        end
    end
end

% LocalWords:  completenames
