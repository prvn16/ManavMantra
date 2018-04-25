function clearInstrumentationResults(mex_file_name)
%clearInstrumentationResults  Clear instrumentation results
%
%   clearInstrumentationResults MEX_FUNCTION_NAME clears the
%   results from the specified instrumented MEX function.
%
%   clearInstrumentationResults ALL clears the results from all
%   instrumented MEX functions.
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
%     tempdirObj = fidemo.fiTempdir('clearInstrumentationResults')
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
%     % we do here.
%     %
%     buildInstrumentedMex testfft -o testfft_instrumented -args {x,W}
%
%     %% Run Test Bench
%     % Run a test bench with the instrumentated MEX function to record
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
%   See also FIACCEL, CODEGEN, MEX, buildInstrumentedMex, 
%   showInstrumentationResults

% Copyright 2011-2017 The MathWorks, Inc.

    if nargin > 0
        mex_file_name = convertStringsToChars(mex_file_name);
    end
    
    try
        fixed.internal.InstrumentationManager.clearResults(mex_file_name);
    catch me
        throw(me)
    end

end
