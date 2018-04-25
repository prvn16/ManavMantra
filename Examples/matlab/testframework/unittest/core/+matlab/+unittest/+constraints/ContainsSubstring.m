classdef ContainsSubstring < matlab.unittest.internal.constraints.SubstringConstraint
    % ContainsSubstring - Constraint specifying a string or character vector containing a given substring
    %
    %   The ContainsSubstring constraint produces a qualification failure for
    %   any actual value that is not a string scalar or character vector that
    %   contains an expected substring.
    %
    %   ContainsSubstring methods:
    %       ContainsSubstring - Class constructor
    %
    %   ContainsSubstring properties:
    %       Substring        - Text that a value must contain to satisfy the constraint
    %       IgnoreCase       - Boolean indicating whether this instance is insensitive to case
    %       IgnoreWhitespace - Boolean indicating whether this instance is insensitive to whitespace
    %
    %   Examples:
    %       import matlab.unittest.constraints.ContainsSubstring;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat('SomeLongText', ContainsSubstring('Long'));
    %
    %       testCase.fatalAssertThat("SomeLongText", ...
    %           ContainsSubstring("lonG",'IgnoringCase', true));
    %
    %       testCase.assumeThat("SomeLongText", ...
    %           ContainsSubstring('Some Long Text','IgnoringWhitespace', true));
    %
    %       % Failing scenarios %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat('SomeLongText', ContainsSubstring("lonG"));
    %
    %       testCase.assertThat("SomeLongText", ContainsSubstring("OtherText"));
    %
    %       testCase.verifyThat('SomeLongText', ContainsSubstring('SomeLongTextThatIsLonger'));
    %
    %   See also:
    %       IsSubstringOf
    %       StartsWithSubstring
    %       EndsWithSubstring
    %       Matches
    
    %  Copyright 2010-2016 The MathWorks, Inc.
   
    properties (Dependent, SetAccess = immutable)
        % Substring - Text that a value must contain to satisfy the constraint
        %
        %   The Substring property can either be a string scalar or character
        %   vector. This property is read only and can be set only through the
        %   constructor.
        Substring
    end
    
    properties(Hidden,Constant,GetAccess=protected)
        PropertyName = 'Substring';
    end
    
    methods
        function constraint = ContainsSubstring(varargin)
            % ContainsSubstring - Class constructor
            %
            %   ContainsSubstring(SUBSTRING) creates a constraint that is able to
            %   determine whether an actual value is a string scalar or character
            %   vector that contains the SUBSTRING provided.
            %
            %   ContainsSubstring(SUBSTRING, 'IgnoringCase', true) creates a constraint
            %   that is able to determine whether an actual value is a string scalar or
            %   character vector that contains the SUBSTRING provided, while ignoring
            %   any differences in case.
            %
            %   ContainsSubstring(SUBSTRING, 'IgnoringWhitespace', true) creates a
            %   constraint that is able to determine whether an actual value is a
            %   string scalar or character vector that contains the SUBSTRING provided,
            %   while ignoring any whitespace differences.
            
            constraint = constraint@matlab.unittest.internal.constraints.SubstringConstraint(varargin{:});
        end
        
        function value = get.Substring(constraint)
            value = constraint.ExpectedValue;
        end
    end
    
    methods (Hidden, Access=protected)
        function catalog = getMessageCatalog(~)
            catalog = matlab.internal.Catalog('MATLAB:unittest:ContainsSubstring');
        end
        
        function bool = satisfiedByText(constraint, actual)
            substring = constraint.ExpectedValue;
            
            if constraint.IgnoreWhitespace
                actual = constraint.removeWhitespaceFrom(actual);
                substring = constraint.removeWhitespaceFrom(substring);
            end
            
            bool = contains(string(actual),substring,'IgnoreCase',constraint.IgnoreCase);
        end
    end
end

% LocalWords:  lon ASupported