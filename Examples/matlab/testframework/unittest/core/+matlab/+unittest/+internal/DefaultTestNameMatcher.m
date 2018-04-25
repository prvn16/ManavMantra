classdef(Hidden) DefaultTestNameMatcher 
    
    properties(Access=private,Constant)
        MatchingConstraint = createConstraint;
    end
    
    methods(Hidden, Static)
        function tf = isTest(string)
            import matlab.unittest.internal.DefaultTestNameMatcher;
            constraint = matlab.unittest.internal.DefaultTestNameMatcher.MatchingConstraint;
            tf = constraint.satisfiedBy(string);
        end
    end
end
        

function constraint = createConstraint
import matlab.unittest.constraints.StartsWithSubstring;
import matlab.unittest.constraints.EndsWithSubstring;

constraint = ...
    StartsWithSubstring('test', 'IgnoringCase', true) | ...
    EndsWithSubstring(  'test', 'IgnoringCase', true);

end
