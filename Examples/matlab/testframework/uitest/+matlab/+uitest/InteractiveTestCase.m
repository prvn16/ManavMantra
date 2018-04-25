classdef (Sealed) InteractiveTestCase < matlab.uitest.TestCase
    %INTERACTIVETESTCASE - A TestCase for interactive experimentation
    %
    %   InteractiveTestCase is a matlab.uitest.TestCase that is used for
    %   interactive experimentation at the MATLAB command prompt. It reacts
    %   to qualification failures and successes by printing messages to
    %   standard output (the screen). To construct an instance, use
    %   matlab.uitest.TestCase.forInteractiveUse.
    %
    % See also matlab.uitest.TestCase.
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods (Hidden, Access=?matlab.uitest.TestCase)
        function testCase = InteractiveTestCase
            
            % Prohibit access from non-interactive contexts.
            if ~matlab.unittest.internal.isInteractiveContext(dbstack('-completenames'))
                error(message('MATLAB:uitest:TestCase:InteractiveUseOnly'));
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