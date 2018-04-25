classdef DisplayDiagnostic < matlab.unittest.diagnostics.Diagnostic
    % DisplayDiagnostic - A diagnostic using a value's displayed output.
    %
    %   The DisplayDiagnostic class provides a diagnostic result using the text
    %   displayed at the command prompt displaying the provided value using the
    %   DISPLAY function. It is a means to provide quick and easy diagnostic
    %   information when that information is easily accessible through a
    %   variable accessible from the current workspace.
    %
    %   DisplayDiagnostic properties:
    %       Value - Value which is utilized for diagnostic evaluation through
    %               DISPLAY
    %
    %   DisplayDiagnostic methods:
    %       DisplayDiagnostic - Class constructor
    %       diagnose - Capture displayed output of the value
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.IsEqualTo;
    %       import matlab.unittest.diagnostics.DisplayDiagnostic;
    %       import matlab.unittest.TestCase;
    %
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Provide a DisplayDiagnostic as a Test Diagnostic
    %       testCase.assertThat(1, IsEqualTo(2), DisplayDiagnostic(5) );
    %
    %   See also
    %       FunctionHandleDiagnostic
    %
    
    %  Copyright 2010-2016 The MathWorks, Inc.
    
    properties(SetAccess=immutable)
        % Value - Value whose display is utilized for diagnostic evaluation
        %
        %   The read-only Value property contains the value which the Diagnostic
        %   uses to generate its diagnostic information. The resulting diagnostic
        %   information will be equivalent to displaying this value at the MATLAB
        %   command prompt. The result will not necessarily be shown at the MATLAB
        %   Command Prompt, however, but will be packaged up for consumption by the
        %   testing framework, which may or may not display the information to the
        %   Command Prompt.
        Value
    end
    
    methods
        function diag = DisplayDiagnostic(value)
            % DisplayDiagnostic - Class constructor
            %
            %   DisplayDiagnostic(VALUE) creates a new DisplayDiagnostic
            %   instance using the VALUE provided.
            %
            %   Examples:
            %
            %       import matlab.unittest.diagnostics.DisplayDiagnostic;
            %
            %       DisplayDiagnostic(5)
            %       DisplayDiagnostic(?matlab.unittest.diagnostics.Diagnostic);
            
            diag.Value = value;
        end
        
        function diagnose(diag)
            % diagnose - Capture displayed output of the value
            %
            %   The diagnose method determines the displayed value of the Value
            %   property. This displayed value is then populated into the
            %   DiagnosticText.
            
            import matlab.unittest.internal.diagnostics.getDisplayableString;
            diag.DiagnosticText = getDisplayableString(diag.Value);
        end
    end
end