classdef ClassBasedTest < matlab.unittest.TestCase
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2015 The MathWorks, Inc.
    
    
    properties(TestParameter)
        p1 =    {[]};
        p2 =    {[]};
        p3 =    {[]};
        p4 =    {[]};
        p5 =    {[]};
        p6 =    {[]};
        p7 =    {[]};
        p8 =    {[]};
        p9 =    {[]};
        p10 =   {[]};
    end
    
    methods(Test)
        function zeroParams     (testCase)
        end
        function oneParam       (testCase, p1)
        end
        function twoParams      (testCase, p1, p2)
        end
        function threeParams    (testCase, p1, p2, p3)
        end
        function fourParams     (testCase, p1, p2, p3, p4)
        end
        function fiveParams     (testCase, p1, p2, p3, p4, p5)
        end
        function sixParams      (testCase, p1, p2, p3, p4, p5, p6)
        end
        function sevenParams    (testCase, p1, p2, p3, p4, p5, p6, p7)
        end
        function eightParams    (testCase, p1, p2, p3, p4, p5, p6, p7, p8)
        end
        function nineParams     (testCase, p1, p2, p3, p4, p5, p6, p7, p8, p9)
        end
        function tenParams      (testCase, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10)
        end
    end
    
end
%#ok<*MANU>
%#ok<*INUSD>