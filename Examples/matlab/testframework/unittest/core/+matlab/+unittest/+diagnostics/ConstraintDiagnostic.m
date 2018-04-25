classdef ConstraintDiagnostic < matlab.unittest.internal.diagnostics.RequirementDiagnostic & ...
                                matlab.unittest.internal.mixin.ApplyAliasMixin
             
    % ConstraintDiagnostic - Diagnostic with fields common to most constraints
    %
    %   The ConstraintDiagnostic class provides various textual fields that are
    %   common to most constraints. These fields may be turned on or off
    %   depending on applicability.
    %
    %   Constraint diagnostics consist of the following fields, displayed in
    %   the specified order:
    %
    %       * Description    - String containing general diagnostic
    %                          information.
    %       * Conditions     - String consisting of a list of any number of
    %                          conditions describing the causes of the failure.
    %                          Each item in the list is indented and preceded
    %                          by an arrow '--> ' marker.
    %       * Actual Value   - the actual value from the associated constraint.
    %                          The raw value may be specified, and any
    %                          truncation or formatting necessary for display
    %                          will be performed.
    %       * Expected Value - The expected value from the associated
    %                          constraint (if applicable). If the constraint
    %                          does not have an expected value, this field may
    %                          be turned off.
    %
    %   Each of the fields (except for the description) has an associated
    %   header that is displayed directly above the field. The header provides
    %   an opportunity to customize an explanation of the field. Default
    %   headers are provided, but may be overridden.
    %
    %   ConstraintDiagnostic properties:
    %       DisplayDescription - boolean controlling display of description field
    %       Description        - string containing general diagnostic information
    %       DisplayConditions  - boolean controlling display of conditions field
    %       ConditionsCount    - number of conditions in the condition list
    %       Conditions         - string containing formatted condition list
    %       DisplayActVal      - boolean controlling display of actual value field
    %       ActValHeader       - string containing header information for the actual value
    %       ActVal             - the actual value
    %       DisplayExpVal      - boolean controlling display of expected value field
    %       ExpValHeader       - string containing header information for the expected value
    %       ExpVal             - the expected value (if applicable)
    %
    %   ConstraintDiagnostic methods:
    %       addCondition             - method to add a condition to the condition list
    %       addConditionsFrom        - method to add conditions from another ConstraintDiagnostic
    %       diagnose                 - execute diagnostic action for the instance
    %       getDisplayableString     - utility method used to truncate the display of large arrays
    %       getPreDescriptionString  - hook method for adding fields prior to Description field
    %       getPostDescriptionString - hook method for adding fields subsequent to Description field
    %       getPostConditionsString  - hook method for adding fields subsequent to Conditions field
    %       getPostActValString      - hook method for adding fields subsequent to ActVal field
    %       getPostExpValString      - hook method for adding fields subsequent to ExpVal field
    %
    %   The diagnose method utilizes the template method pattern in order to build
    %   the diagnostic result string from its fields. The fields are displayed in the
    %   following order:
    %       * Description
    %       * Conditions
    %       * Actual Value
    %       * Expected Value
    %
    %   Subclasses may add fields in any location by overriding the following
    %   task methods:
    %       * getPreDescriptionString
    %       * getPostDescriptionString
    %       * getPostConditionsString
    %       * getPostActValString
    %       * getPostExpValString
    %
    %   These methods are called by the diagnose method to obtain strings that are
    %   injected into the diagnostic result at the location indicated by the method
    %   name. These methods return an empty string unless overridden.
    %
    %   This pattern may be continued in subclasses, allowing
    %   class developers to add additional fields performing the following steps:
    %
    %   * Override the appropriate task method (and optionally seal the new
    %     implementation)
    %   * Create two new task methods that bracket the overridden task method and
    %     simply return empty strings.
    %   * Call the new task methods in the overridden task method at the appropriate
    %     locations.
    %
    %   An example of creating a new constraint diagnostic class with an additional
    %   field is given below:
    %   (Note, the new field is added after the Conditions field)
    %
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   % Example Subclass
    %   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   classdef MyConstraintDiagnostic < matlab.unittest.diagnostics.ConstraintDiagnostic
    %
    %       properties
    %           DisplayMyNewProp = false;
    %           MyNewProp;
    %           MyNewPropHeader = 'MyNewProp Value:';
    %       end
    %
    %       methods (Access = protected)
    %       % The following protected methods allow subclasses to add additional fields
    %       % before or after the MyNewProp field.
    %           function str = getMyNewPropString(~)
    %               str = '';
    %           end
    %           function str = getPostMyNewPropString(~)
    %               str = '';
    %           end
    %       end
    %
    %       methods
    %           function set.MyNewPropHeader(obj, str)
    %               obj.MyNewPropHeader = obj.trimNewlines(str);
    %           end
    %           function set.MyNewProp(obj, str)
    %               obj.MyNewProp = obj.trimNewlines(str);
    %           end
    %           function s = getPostConditionsString(obj)
    %           % Overriding base class implementation in order to inject new field.
    %
    %               s = obj.trimNewlines(obj.getPreMyNewPropString());
    %               if ~isempty(s)
    %                   s = sprintf('%s\n\n', s);
    %               end
    %
    %               if obj.DisplayMyNewProp
    %                   s = sprintf('%s%s\n%s\n\n', ...
    %                               s, ...
    %                               obj.MyNewPropHeader, ...
    %                               obj.MyNewProp);
    %               end
    %
    %               str = obj.trimNewlines(obj.getPostMyNewPropString());
    %               s = sprintf('%s%s', s, str);
    %           end
    %       end
    %   end
    %
    %   See also
    %       Diagnostic
    %       matlab.unittest.constraints.Constraint
    
    %  Copyright 2010-2017 The MathWorks, Inc.

    properties (Dependent)
        % Description - character vector containing general diagnostic information
        Description;
    end
    
    properties
        % DisplayDescription - boolean controlling display of description field
        %
        %   By default, the description is not displayed and the value of this property
        %   is false.
        DisplayDescription = false;
        
        % DisplayConditions - boolean controlling display of conditions field
        %
        %   By default, the conditions are not displayed and the value of this property
        %   is false. Note that even if DisplayConditions is set to true, if there are
        %   no conditions on the conditions list, neither the conditions header or the
        %   conditions list will be displayed.
        DisplayConditions = false;
    end
    
    properties (Dependent, SetAccess=private)
        % ConditionsCount - number of conditions in the condition list
        %
        %   See also
        %       Conditions
        %       addCondition
        ConditionsCount;
        
        % Conditions - string containing formatted condition list
        %
        %   The string consists of a list of conditions from the conditions list.
        %   Each condition starts on a new line and begins with an arrow '--> '
        %   delimiter.
        %
        %   See also
        %       addCondition
        Conditions;
    end
    
    properties
        % DisplayActVal - boolean controlling display of actual value field
        %
        %   By default, the actual value is not displayed and the value of this property
        %   is false.
        DisplayActVal = false;
        
        % ActValHeader - string containing header information for the actual value
        %
        %   Contains the following default header:
        %   'Actual Value:'
        ActValHeader = getString(message('MATLAB:unittest:ConstraintDiagnostic:ActualValue'));
        
        % ActVal - the actual value
        ActVal = [];
        
        % DisplayExpVal - boolean controlling display of expected value field
        %
        %   By default, the expected value is not displayed and the value of this
        %   property is false.
        DisplayExpVal = false;
        
        % ExpValHeader - string containing header information for the expected value
        %
        %   Contains the following default header:
        %   'Expected Value:'
        ExpValHeader = getString(message('MATLAB:unittest:ConstraintDiagnostic:ExpectedValue'));
        
        % ExpVal - the expected value (if applicable)
        %
        %   This field my be turned off if the associated constraint does not
        %   contain an expected value.
        ExpVal = [];
    end
    
    properties (Hidden, SetAccess = {?matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory,...
                                     ?matlab.unittest.internal.diagnostics.RequirementDiagnostic})
        % This property is undocumented and may change in a future release.
        
        % Passed - logical value indicating the type of diagnosis
        %
        %   Passed is set to true when a ConstraintDiagnostic is
        %   constructed for a passing condition.
        %
        %   Passed is false by default.
        Passed = false;
    end
    
    methods (Hidden)
        function diag = ConstraintDiagnostic()
            % Hidden constructor because ConstraintDiagnosticFactory should generally
            % be used for creation of ConstraintDiagnostics.
        end
        
        function applyAlias(diag,alias)
            % Used with casual qualification API to convert the description from
            % something like "Negated IsEqualTo failed" to "verifyNotEqual failed".
            import matlab.unittest.internal.diagnostics.createClassNameForCommandWindow;
            import matlab.unittest.internal.diagnostics.MessageString;
            
            env = diag.suppressWarnOnUse(); %#ok<NASGU>
            
            if diag.Passed
                msgKey = 'RequirementCompletelySatisfied';
            else
                msgKey = 'RequirementNotCompletelySatisfied';
            end
            
            msgID = sprintf('MATLAB:unittest:ConstraintDiagnosticFactory:%s', msgKey);
            diag.Description = MessageString(msgID, createClassNameForCommandWindow(alias));
        end
    end

    methods
        function addConditionsFrom(diag, otherDiag)
            % addConditionsFrom - add conditions from another ConstraintDiagnostic
            %
            % DIAG.addConditionsFrom(OTHER) takes all of the conditions from the
            % ConstraintDiagnostic OTHER and adds them to the condition list of DIAG.
            % This is primarily useful when a Constraint composes another constraint,
            % and would like to use the conditions produced in the diagnostics of the
            % composed constraint.

            env = diag.warnIfNeeded(); %#ok<NASGU>
            
            if isa(otherDiag,'matlab.unittest.internal.diagnostics.GetConditionsSupplierMixin') && isscalar(otherDiag)
                supplier = otherDiag.getConditionsSupplier();
            else
                validateattributes(otherDiag, ...
                    {'matlab.unittest.diagnostics.ConstraintDiagnostic'}, ...
                    {'scalar'},'', 'otherDiag');
            end
            
            diag.ConditionsSupplier = diag.ConditionsSupplier.append(...
                supplier);
        end
        
        function addCondition(diag, condition)
            % addCondition - Method to add a condition to the condition list.
            %
            % A condition is a string containing information specific to the cause of
            % the constraint failure. It can also be a diagnostic instance. When the
            % condition list is displayed, each condition is preceded by an arrow '-->'
            % and indented. Any number of conditions may be specified.
            import matlab.unittest.internal.diagnostics.DirectConditionsSupplier;
            import matlab.unittest.internal.diagnostics.MessageDiagnostic;
            
            env = diag.warnIfNeeded(); %#ok<NASGU>
            
            if isa(condition,'message')
                condition = MessageDiagnostic(condition);
            end
            validateattributes(condition,{'char','string','matlab.unittest.diagnostics.Diagnostic'},...
                {},'','condition');
            
            diag.ConditionsSupplier = diag.ConditionsSupplier.append(...
                DirectConditionsSupplier(condition));
        end
    end
       
    methods %Getters and Setters
        function value = get.DisplayDescription(diag)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            value = diag.DisplayDescription;
        end
        
        function set.DisplayDescription(diag,value)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            diag.DisplayDescription = value;
        end
        
        function value = get.Description(diag)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            value = char(diag.FormattableDescription);
        end
        
        function set.Description(diag,value)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            diag.FormattableDescription = diag.trimNewlines(value);
        end
        
        function value = get.DisplayConditions(diag)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            value = diag.DisplayConditions;
        end
        
        function set.DisplayConditions(diag,value)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            diag.DisplayConditions = value;
        end
        
        function value = get.ConditionsCount(diag)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            value = numel(diag.ConditionsList);
        end
        
        function value = get.Conditions(diag)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            value = char(diag.FormattableConditions);
        end
        
        function value = get.DisplayActVal(diag)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            value = diag.DisplayActVal;
        end
        
        function set.DisplayActVal(diag,value)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            diag.DisplayActVal = value;
        end
        
        function value = get.ActValHeader(diag)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            value = diag.ActValHeader;
        end
        
        function set.ActValHeader(diag, value)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            diag.ActValHeader = diag.trimNewlines(value);
        end
        
        function value = get.ActVal(diag)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            value = diag.ActVal;
        end
        
        function set.ActVal(diag,value)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            diag.ActVal = value;
        end
        
        function value = get.DisplayExpVal(diag)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            value = diag.DisplayExpVal;
        end
        
        function set.DisplayExpVal(diag,value)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            diag.DisplayExpVal = value;
        end
        
        function value = get.ExpValHeader(diag)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            value = diag.ExpValHeader;
        end
        
        function set.ExpValHeader(diag, value)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            diag.ExpValHeader = diag.trimNewlines(value);
        end
        
        function value = get.ExpVal(diag)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            value = diag.ExpVal;
        end
        
        function set.ExpVal(diag,value)
            env = diag.warnIfNeeded(); %#ok<NASGU>
            diag.ExpVal = value;
        end
    end
    
    methods (Static)
        function str = getDisplayableString(value)
            % getDisplayableString - Utility method for converting any object to a string in displayable format
            %
            %   This method is used to prepare any arbitrary object for display in a
            %   diagnostic result. This includes dealing with hotlinks and any truncation
            %   necessary for large numeric or cell arrays.
            %
            %   It provides a consistent method for truncating large arrays. The method is
            %   utilized internally when displaying the actual and expected value fields,
            %   but may also provide value externally when displaying failed indices, for
            %   example. Array truncation is performed by calling evalc on the displayed
            %   value, and returning some maximum number of characters.
            str = char(matlab.unittest.internal.diagnostics.getDisplayableString(value));
        end
    end
end

% LocalWords:  Formattable
