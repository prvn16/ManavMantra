classdef NameParser < handle
    % This class is undocumented and may change in a future release.
    
    %  Copyright 2013-2015 MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % Name - String representing the identifier being parsed
        Name
    end
        
    properties (Constant, Hidden)
        % Suite grammar reserves
        % [, ], (, ) for parameterization
        % = for assignment in parameterization
        % , for multiple parameters
        % / for test delimiting        
        ReservedCharactersRegularExpressionGroup = '\(\)\[\]=,\/'
        
        % Regular expression to parse the Name.
        RegularExpression = ['^(?<ParentName>[^' matlab.unittest.internal.NameParser.ReservedCharactersRegularExpressionGroup ']+)(?<ClassParameters>\[[=,\w]+\])?/(?<MethodParameters>\[[=,\w]+\])?(?<TestName>[^' matlab.unittest.internal.NameParser.ReservedCharactersRegularExpressionGroup ']+)(?<TestParameters>\([=,\w]+\))?$'];
    end
    
    properties (SetAccess=private)
        % Valid - Boolean indicating whether the Name is syntactically valid
        %   This property is true if Name follows the grammar of a test suite
        %   element name. If this property is true, the Name may or may not be
        %   semantically valid, i.e., it may or may not actually represent test
        %   content that exists.
        Valid = false;
        
        % ParentName - String representing the name of the test parent
        ParentName = '';
        
        % TestName - String representing the name of the test
        TestName = '';
        
        % ClassSetupParameters - Structure of ClassSetupParameter information
        ClassSetupParameters = struct('Property',{}, 'Name',{});
        
        % MethodSetupParameters - Structure of MethodSetupParameter information
        MethodSetupParameters = struct('Property',{}, 'Name',{});
        
        % TestMethodParameters - Structure of TestParameter information
        TestMethodParameters = struct('Property',{}, 'Name',{});
    end
    
    methods
        function parser = NameParser(name)
            validateattributes(name, {'char','string'}, {'nonempty','row','scalartext'}, '', 'name');
            if isstring(name)
                matlab.unittest.internal.validateNonemptyText(name);
                name = char(name);
            end
            parser.Name = name;
        end
        
        function parse(parser)
            results = regexp(parser.Name, parser.RegularExpression, 'names');
            
            parser.Valid = ~isempty(results);
            if ~parser.Valid
                return;
            end
            
            parser.ParentName = results.ParentName;
            parser.TestName = results.TestName;
            
            parser.ClassSetupParameters = parser.parseParameters(results.ClassParameters);
            parser.MethodSetupParameters = parser.parseParameters(results.MethodParameters);
            parser.TestMethodParameters = parser.parseParameters(results.TestParameters);
        end
    end
    
    methods (Access=private)
        function parameterStruct = parseParameters(parser, paramStr)
            % Parse strings containing parameter pairs separated by commas, e.g.,
            % '[p1=v1,p2=v2,p3=v3]' or '(p1=v1)' or ''
            
            % Strip off brackets or parens and separate the parameter pairs
            parameters = strsplit(paramStr(2:end-1), ',', 'CollapseDelimiters', false);
            
            parameterCell = regexp(parameters, '^(?<Property>\w+)=(?<Name>\w+)$', 'names');
            parser.Valid = parser.Valid && (isempty(paramStr) || ~any(cellfun(@isempty, parameterCell)));
            
            parameterStruct = [parameterCell{:}];
        end
    end
end

% LocalWords:  parens
