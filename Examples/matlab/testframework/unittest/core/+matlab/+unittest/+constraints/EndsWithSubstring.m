classdef EndsWithSubstring < matlab.unittest.internal.constraints.SubstringConstraint
    % EndsWithSubstring - Constraint specifying a string or character vector ending with a given substring
    %
    %   The EndsWithSubstring constraint produces a qualification failure for
    %   any actual value that is not a string scalar or character vector ending
    %   with an expected substring.
    %
    %   EndsWithSubstring methods:
    %       EndsWithSubstring - Class constructor
    %
    %   EndsWithSubstring properties:
    %       Suffix           - Text that the value must end with to satisfy the constraint
    %       IgnoreCase       - Boolean indicating whether this instance is insensitive to case
    %       IgnoreWhitespace - Boolean indicating whether this instance is insensitive to whitespace
    %
    %   Examples:
    %       import matlab.unittest.constraints.EndsWithSubstring;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat('SomeLongText', EndsWithSubstring('Text'));
    %
    %       testCase.assumeThat("SomeLongText", ...
    %           EndsWithSubstring("TEXt", 'IgnoringCase', true));
    %
    %       testCase.assertThat('Some Long Text', ...
    %           EndsWithSubstring("LongText", 'IgnoringWhitespace', true));
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat('SomeLongText', EndsWithSubstring('TEXt'));
    %
    %       testCase.fatalAssertThat("SomeLongText", EndsWithSubstring('OtherText'));
    %
    %       testCase.verifyThat("SomeLongText", EndsWithSubstring("Long"));
    %
    %   See also:
    %       StartsWithSubstring
    %       ContainsSubstring
    %       IsSubstringOf
    %       Matches
    
    %  Copyright 2010-2016 The MathWorks, Inc.
    
    properties (Dependent, SetAccess = immutable)
        % Suffix - Text that the value must end with to satisfy the constraint
        %
        %   The Suffix property can either be a string scalar or character
        %   vector. This property is read only and can be set only through the
        %   constructor.
        Suffix
    end
    
    properties(Hidden,Constant,GetAccess=protected)
        PropertyName = 'Suffix';
    end
    
    methods
        function constraint = EndsWithSubstring(varargin)
            % EndsWithSubstring - Class constructor
            %
            %   EndsWithSubstring(SUFFIX) creates a constraint that is able to
            %   determine whether an actual value is a scalar string or character
            %   vector that ends with the SUFFIX provided.
            %
            %   EndsWithSubstring(SUFFIX, 'IgnoringCase', true) creates a constraint
            %   that is able to determine whether an actual value is a scalar string or
            %   character vector that ends with the SUFFIX provided, while ignoring any
            %   differences in case.
            %
            %   EndsWithSubstring(SUFFIX, 'IgnoringWhitespace', true) creates a
            %   constraint that is able to determine whether an actual value is a
            %   scalar string or character vector that ends with the SUFFIX provided,
            %   while ignoring any whitespace differences.
            
            constraint = constraint@matlab.unittest.internal.constraints.SubstringConstraint(varargin{:});
        end

        function value = get.Suffix(constraint)
            value = constraint.ExpectedValue;
        end
    end
    
    methods (Hidden, Access = protected)
        function catalog = getMessageCatalog(~)
            catalog = matlab.internal.Catalog('MATLAB:unittest:EndsWithSubstring');
        end
        
        function bool = satisfiedByText(constraint, actual)
            suffix = constraint.ExpectedValue;
            
            if constraint.IgnoreWhitespace
                actual = constraint.removeWhitespaceFrom(actual);
                suffix = constraint.removeWhitespaceFrom(suffix);
            end
            
            bool = endsWith(string(actual),suffix,'IgnoreCase',constraint.IgnoreCase);
        end
    end
end

% LocalWords:  Xt ASupported