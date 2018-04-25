classdef StartsWithSubstring < matlab.unittest.internal.constraints.SubstringConstraint
    % StartsWithSubstring - Constraint specifying a string or character vector starting with a given substring
    %
    %   The StartsWithSubstring constraint produces a qualification failure for
    %   any actual value that is not a string scalar or character vector
    %   starting with an expected string.
    %
    %   StartsWithSubstring methods:
    %       StartsWithSubstring - Class constructor
    %
    %   StartsWithSubstring properties:
    %       Prefix           - Text that the value must start with to satisfy the constraint
    %       IgnoreCase       - Boolean indicating whether this instance is insensitive to case
    %       IgnoreWhitespace - Boolean indicating whether this instance is insensitive to whitespace
    %
    %   Examples:
    %       import matlab.unittest.constraints.StartsWithSubstring;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat('SomeLongText', StartsWithSubstring('Some'));
    %
    %       testCase.fatalAssertThat("SomeLongText", ...
    %           StartsWithSubstring("sOME", 'IgnoringCase', true));
    %
    %       testCase.assertThat('Some Long Text', ...
    %           StartsWithSubstring("SomeLong", 'IgnoringWhitespace', true));
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.assertThat("SomeLongText", StartsWithSubstring('sOME'));
    %
    %       testCase.verifyThat('SomeLongText', StartsWithSubstring('OtherText'));
    %
    %       testCase.fatalAssertThat("SomeLongText", StartsWithSubstring("Long"));
    %
    %   See also:
    %       EndsWithSubstring
    %       ContainsSubstring
    %       IsSubstringOf
    %       Matches
    
    %  Copyright 2010-2016 The MathWorks, Inc.
    
    properties (Dependent, SetAccess = immutable)
        % Prefix - Text that the value must start with to satisfy the constraint
        %
        %   The Prefix property can either be a string scalar or character
        %   vector. This property is read only and can be set only through the
        %   constructor.
        Prefix
    end
    
    properties(Hidden,Constant,GetAccess=protected)
        PropertyName = 'Prefix';
    end
    
    methods
        function constraint = StartsWithSubstring(varargin)
            % StartsWithSubstring - Class constructor
            %
            %   StartsWithSubstring(PREFIX) creates a constraint that is able to
            %   determine whether an actual value is a string scalar or character
            %   vector that starts with the PREFIX provided.
            %
            %   StartsWithSubstring(PREFIX, 'IgnoringCase', true) creates a constraint
            %   that is able to determine whether an actual value is a string scalar or
            %   character vector that starts with the PREFIX provided, while ignoring
            %   any differences in case.
            %
            %   StartsWithSubstring(PREFIX, 'IgnoringWhitespace', true) creates a
            %   constraint that is able to determine whether an actual value is a
            %   string scalar or character vector that starts with the PREFIX provided,
            %   while ignoring any whitespace differences.
            
            constraint = constraint@matlab.unittest.internal.constraints.SubstringConstraint(varargin{:});
        end

        function value = get.Prefix(constraint)
            value = constraint.ExpectedValue;
        end
    end
    
    methods (Hidden, Access = protected)
        function catalog = getMessageCatalog(~)
            catalog = matlab.internal.Catalog('MATLAB:unittest:StartsWithSubstring');
        end
        
        function bool = satisfiedByText(constraint, actual)
            prefix = constraint.ExpectedValue;
            
            if constraint.IgnoreWhitespace
                actual = constraint.removeWhitespaceFrom(actual);
                prefix = constraint.removeWhitespaceFrom(prefix);
            end
            
            bool = startsWith(string(actual),prefix,'IgnoreCase',constraint.IgnoreCase);
        end
    end
end

% LocalWords:  OME ASupported