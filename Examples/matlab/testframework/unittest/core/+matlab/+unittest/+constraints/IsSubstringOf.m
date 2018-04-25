classdef IsSubstringOf < matlab.unittest.internal.constraints.SubstringConstraint
    % IsSubstringOf - Constraint specifying a substring of a given string or character vector
    %
    %   The IsSubstringOf constraint produces a qualification failure for any
    %   actual value that is not a string scalar or character vector that is
    %   found within an expected superstring.
    %
    %   IsSubstringOf methods:
    %      IsSubstringOf - Class constructor
    %
    %   IsSubstringOf properties:
    %      Superstring      - Text a value must be found inside to satisfy the constraint
    %      IgnoreCase       - Boolean indicating whether this instance is insensitive to case
    %      IgnoreWhitespace - Boolean indicating whether this instance is insensitive to whitespace
    %
    %   Examples:
    %       import matlab.unittest.constraints.IsSubstringOf;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat('Long', IsSubstringOf('SomeLongText'));
    %
    %       testCase.fatalAssertThat("lonG", ...
    %           IsSubstringOf("SomeLongText", 'IgnoringCase', true));
    %
    %       testCase.assertThat('LongText', ...
    %           IsSubstringOf("Some Long Text", 'IgnoringWhitespace', true));
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.assertThat("lonG", IsSubstringOf('SomeLongText'));
    %
    %       testCase.verifyThat("OtherText", IsSubstringOf("SomeLongText"));
    %
    %       testCase.assumeThat('SomeLongTextThatIsLonger', IsSubstringOf('SomeLongText'));
    %
    %   See also:
    %       ContainsSubstring
    %       StartsWithSubstring
    %       EndsWithSubstring
    %       Matches
    
    %  Copyright 2010-2016 The MathWorks, Inc.
    
    properties (Dependent, SetAccess = immutable)
        % Superstring - Text that a value must be found inside to satisfy the constraint
        %
        %   The Superstring property can either be a string scalar or character
        %   vector. This property is read only and can be set only through the
        %   constructor.
        Superstring
    end
    
    properties(Hidden,Constant,GetAccess=protected)
        PropertyName = 'Superstring';
    end
    
    methods
        function constraint = IsSubstringOf(varargin)
            % IsSubstringOf - Class constructor
            %
            %   IsSubstringOf(SUPERSTRING) creates a constraint that is able to
            %   determine whether an actual value is a string scalar or character
            %   vector that is found within the SUPERSTRING provided.
            %
            %   IsSubstringOf(SUPERSTRING, 'IgnoringCase', true) creates a constraint
            %   that is able to determine whether an actual value is a string scalar or
            %   character vector found within the SUPERSTRING provided, while ignoring
            %   any differences in case.
            %
            %   IsSubstringOf(SUPERSTRING, 'IgnoringWhitespace', true) creates a
            %   constraint that is able to determine whether an actual value is a
            %   string scalar or character vector found within the SUPERSTRING
            %   provided, while ignoring whitespace differences.
            
            constraint = constraint@matlab.unittest.internal.constraints.SubstringConstraint(varargin{:});
        end
        
        function value = get.Superstring(constraint)
            value = constraint.ExpectedValue;
        end
    end
    
    methods (Hidden, Access = protected)
        function catalog = getMessageCatalog(~)
            catalog = matlab.internal.Catalog('MATLAB:unittest:IsSubstringOf');
        end
        
        function bool = satisfiedByText(constraint, actual)
            superstring = constraint.ExpectedValue;
            
            if constraint.IgnoreWhitespace
                actual = constraint.removeWhitespaceFrom(actual);
                superstring = constraint.removeWhitespaceFrom(superstring);
            end
            
            bool = contains(string(superstring),actual,'IgnoreCase',constraint.IgnoreCase);
        end
    end
end

% LocalWords:  superstring lon ASupported