classdef FileBasedStaticAnalysisSuiteCreationService < matlab.unittest.internal.services.suitecreation.SuiteCreationService
    % This class is undocumented and will change in a future release.
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    methods (Abstract, Access=protected)
        % parse - Construct parse tree.
        %   Subclasses must implement the parse method to return a parse tree
        %   given the full path to a file. If a parse tree can not be created for
        %   the given file, parse should thrown an exception.
        parseTree = getParseTree(service, liaison)
        
        % selectFactoryUsingParseTree - Construct a TestSuiteFactory.
        %   Subclasses must implement the selectFactoryUsingParseTree method to
        %   select a valid TestSuiteFactory for the given parse tree.
        selectFactoryUsingParseTree(service, liaison, parseTree)
    end
    
    methods (Sealed, Access=protected)
        function selectFactory(service, liaison)
            import matlab.unittest.internal.InvalidTestFactory;
            
            if isempty(liaison.Filename) || ~liaison.ParentNameMeetsNamingConvention
                return;
            end
            
            if ~isvarname(liaison.SimpleParentName)
                liaison.Factory = InvalidTestFactory(liaison.ParentName, ....
                    MException(message('MATLAB:unittest:TestSuite:InvalidMATLABFilename', ...
                    liaison.Filename)));
                return;
            end
            
            try
                parseTree = service.getParseTree(liaison);
                if ~liaison.SkipMCheck
                    builtin('_mcheck', liaison.Filename);
                end
            catch me
                % Any file which can't be parsed is not a valid test
                liaison.Factory = InvalidTestFactory(liaison.ParentName, me);
                return;
            end
            
            service.selectFactoryUsingParseTree(liaison, parseTree);
        end
    end
end

% LocalWords:  suitecreation mtfind isnull mcheck unittest
