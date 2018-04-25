function buildInstrumentedMex(varargin)
%buildInstrumentedMex  Build instrumented MEX function
%
%   buildInstrumentedMex builds a MEX function with logging instrumentation
%   enabled. By default, the name of the generated MEX function is the name
%   of the top-level MATLAB function being compiled with '_mex' appended.  To
%   generate a MEX function with a different name, use the '-o' option.
%
%   The general syntax and options of the buildInstrumentedMex and FIACCEL
%   are the same, except buildInstrumentedMex has no fi object restrictions
%   and supports '-coder' option. The '-coder' option requires a MATLAB Coder 
%   license and provides full code generation support.
%    
%   Copy and paste the entire example into the MATLAB editor and step through
%   it in cell mode.
%
%   Example:
%
%     %% Setup Test Files
%     % Create a temporary directory and copy a demo function from
%     % Fixed-Point Designer into it.
%     %
%     tempdirObj = fidemo.fiTempdir('buildInstrumentedMex')
%     %%
%     copyfile(fullfile(matlabroot,'toolbox','fixedpoint','fidemos',...
%         'fi_m_radix2fft_withscaling.m'),'testfft.m','f')
%
%     %% Define Prototype Input Arguments
%     %
%     n = 128;
%     x = complex(zeros(n,1));
%     W = coder.Constant(fidemo.fi_radix2twiddles(n));
%
%     %% Generate Instrumented MEX Function
%     % By default, a MEX function with suffix '_mex' is created.  To
%     % choose your own name for the MEX function, use the '-o' option as
%     % we do here. You can also use the '-coder' option if the MATLAB 
%     % Coder license is available.
%     %
%     buildInstrumentedMex testfft -o testfft_instrumented -args {x,W}
%     % or
%     % buildInstrumentedMex testfft -coder -o testfft_instrumented -args {x,W}
%
%     %% Run Test Bench
%     % Run a test bench with the instrumented MEX function to record
%     % instrumentation results.
%     %
%     for i=1:20
%         y = testfft_instrumented(complex(randn(size(x))));
%     end
%
%     %% Show Instrumentation Results
%     % Look at the Variables tab in the Code Generation Report and hover
%     % over variables and expressions in the code to see instrumentation
%     % results.
%     %
%     showInstrumentationResults testfft_instrumented
%
%     %% Clear Instrumentation Results
%     % The instrumentation results are accumulated every time the
%     % instrumented MEX function is called.  Clear the instrumentation
%     % results to start a new test bench without the previous results in the
%     % logs. 
%     %
%     clearInstrumentationResults testfft_instrumented
%
%     %% Run a Different Test Bench
%     %
%     for i=1:20
%         y = testfft_instrumented(complex(1000*randn(size(x))));
%     end
%
%     %% Show New Instrumentation Results
%     %
%     showInstrumentationResults testfft_instrumented
%
%     %% Clear the MEX Function and Delete Temporary Files
%     %
%     clear testfft_instrumented;
%     tempdirObj.cleanUp;
%
%   See also FIACCEL, CODEGEN, MEX, clearInstrumentationResults,
%   showInstrumentationResults

% Copyright 2011-2017 The MathWorks, Inc.

    if nargin > 0
        [varargin{:}] = convertStringsToChars(varargin{:});
    end
    
    for i = coder.internal.evalinArgs(varargin)
        try
            varargin{i} = evalin('caller', varargin{i});
        catch  %#ok Errors are handled later
        end
    end

    fixed.internal.buildInstrumentedMex(varargin{:});

end
