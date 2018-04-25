classdef FunctionHandleDiagnostic < matlab.unittest.diagnostics.Diagnostic
    % FunctionHandleDiagnostic - A diagnostic using a function's displayed output.
    %
    %   The FunctionHandleDiagnostic class provides a diagnostic result using
    %   the text displayed at the command prompt when executing the provided
    %   function handle. It is a means to provide quick and easy diagnostic
    %   information when that information is easily accessible through the
    %   displayed output of a function handle.
    %
    %   As a convenience (and performance improvement) when using
    %   matlab.unittest qualifications, a function handle can itself be
    %   directly supplied as a test diagnostic, and a FunctionHandleDiagnostic
    %   will be created automatically.
    %
    %   FunctionHandleDiagnostic properties:
    %       Fcn - Function utilized for diagnostic evaluation
    %
    %   FunctionHandleDiagnostic methods:
    %       FunctionHandleDiagnostic - Class constructor
    %       diagnose - Capture displayed output of the function handle
    %
    %   Examples:
    %
    %       import matlab.unittest.constraints.IsEqualTo;
    %       import matlab.unittest.diagnostics.FunctionHandleDiagnostic;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Create a FunctionHandleDiagnostic only upon failure
    %       testCase.assertThat(1, IsEqualTo(2), @() system('ps') );
    %
    %       % Provide a FunctionHandleDiagnostic directly
    %       testCase.assertThat(1, IsEqualTo(2), FunctionHandleDiagnostic(@() system('ps')) );
    %
    %   See also
    %       StringDiagnostic
    %
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    properties(SetAccess=private)
        % Fcn - Function utilized for diagnostic evaluation
        %
        %   The read-only Fcn property contains the function handle which the
        %   Diagnostic uses to generate its diagnostic information. This function
        %   should display to the Command Prompt the diagnostics that are
        %   desired to be utilized by the testing framework. The result will not
        %   necessarily be shown at the Command Prompt, but will be packaged
        %   up for consumption by the testing framework, which may or may not
        %   display the information to the Command Prompt.
        Fcn (1,1) function_handle = @()[];
    end
    
    methods
        function diag = FunctionHandleDiagnostic(fcn)
            % FunctionHandleDiagnostic - Class constructor
            %
            %   FunctionHandleDiagnostic(FCN) creates a new FunctionHandleDiagnostic
            %   instance using the FCN provided.
            %
            %   Examples:
            %
            %       import matlab.unittest.diagnostics.FunctionHandleDiagnostic;
            %
            %       FunctionHandleDiagnostic(@why)
            %       FunctionHandleDiagnostic(@() system('ps'));
            %
            diag.Fcn = fcn;
        end
        
        function diagnose(diag)
            % diagnose - Capture displayed output of the function handle
            %
            %   The diagnose method executes the function handle provided and populates
            %   the DiagnosticText property with the log text that would be produced
            %   by that function handle. This property is then accessed and presented
            %   to the user by the testing framework.
            %
            diag.DiagnosticText = evalc('diag.Fcn();');
        end
    end
end

% LocalWords:  ps