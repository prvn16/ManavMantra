classdef(Hidden) ComparatorDiagnostic < matlab.unittest.internal.diagnostics.RequirementDiagnostic
    %

    % ComparatorDiagnostic - Diagnostics specific to matlab.unittest.constraints.Comparator objects.
    %
    %   A comparator diagnostic should not be instantiated directly.
    %   Instead, it will be returned from the getDiagnosticFor method of
    %   matlab.unittest.constraints.Comparator.
    %
    %   See also:
    %       matlab.unittest.constraints.Comparator
    
    %  Copyright 2016-2017 The MathWorks, Inc.
    
    properties(Hidden)
        DisplayValueReference;
        ValueReferenceHeader;
        ValueReference;
        DisplayDescription = false;
        DisplayConditions = true;
        DisplayActVal = false;
        ActValHeader = getString(message('MATLAB:unittest:ComparatorDiagnostic:ActualValue'));
        ActVal = [];
        DisplayExpVal = false;
        ExpValHeader = getString(message('MATLAB:unittest:ComparatorDiagnostic:ExpectedValue'));
        ExpVal = [];
    end
    
    properties (Hidden, Dependent)
        Description;
    end
    
    properties (Hidden, Dependent, SetAccess=private)
        Conditions;
    end
    
    properties (Hidden, SetAccess = {?matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory,...
                                     ?matlab.unittest.internal.diagnostics.RequirementDiagnostic})
        Passed = false;
    end
    
    properties(Constant,Access=private)
        ArgumentParser = generateArgumentParser();
    end
    
    methods(Hidden)
        function diag = ComparatorDiagnostic(varargin)
            import matlab.unittest.diagnostics.Diagnostic;
            
            argParser = matlab.unittest.diagnostics.ComparatorDiagnostic.ArgumentParser;
            argParser.parse(varargin{:});
            
            diag.Passed = argParser.Results.Passed;
            if diag.Passed
                diag.ValueReferenceHeader = ...
                    getString(message('MATLAB:unittest:ComparatorDiagnostic:PathToValue'));
            else
                diag.ValueReferenceHeader = ...
                    getString(message('MATLAB:unittest:ComparatorDiagnostic:PathToFailure'));
            end
            diag.DisplayValueReference = argParser.Results.DisplayValueReference;
            diag.ValueReference = argParser.Results.ValueReference;
            
            if ~ismember('ActVal',argParser.UsingDefaults)
                diag.DisplayActVal = true;
                diag.ActVal = argParser.Results.ActVal;
                diag.ActValHeader = getString(message('MATLAB:unittest:ComparatorDiagnostic:ActualValueWithType',...
                    class(diag.ActVal)));
            end
            
            if ~ismember('ExpVal',argParser.UsingDefaults)
                diag.DisplayExpVal = true;
                diag.ExpVal = argParser.Results.ExpVal;
                diag.ExpValHeader = getString(message('MATLAB:unittest:ComparatorDiagnostic:ExpectedValueWithType',...
                    class(diag.ExpVal)));
            end
            
            diag.ConditionsList = Diagnostic.join(argParser.Results.ConditionsList); %Convert to Diagnostic if needed
        end
    end
    
    methods
        function c = get.Conditions(diag)
            c = char(diag.FormattableConditions);
        end
        
        function set.Description(diag, desc)
            diag.FormattableDescription = diag.trimNewlines(desc);
        end
        
        function desc = get.Description(diag)
            desc = char(diag.FormattableDescription);
        end
        
        function set.ActValHeader(diag, header)
            diag.ActValHeader = diag.trimNewlines(header);
        end
        
        function set.ExpValHeader(diag, header)
            diag.ExpValHeader = diag.trimNewlines(header);
        end
    end
    
    methods (Access=protected)
        function str = getPreDescriptionString(diag)
            if diag.DisplayValueReference
                str = sprintf('%s %s',...
                    diag.ValueReferenceHeader,diag.ValueReference);
            else
                str = '';
            end
        end
    end
end

function argParser = generateArgumentParser()
argParser = matlab.unittest.internal.strictInputParser;
argParser.addParameter('Passed',false);
argParser.addParameter('ValueReference','');
argParser.addParameter('DisplayValueReference',true);
argParser.addParameter('ActVal',[]);
argParser.addParameter('ExpVal',[]);
argParser.addParameter('ConditionsList',...
    matlab.unittest.diagnostics.Diagnostic.empty(1,0));
end

% LocalWords:  Formattable
