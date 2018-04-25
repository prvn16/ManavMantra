function showInstrumentationResults(varargin)
%showInstrumentationResults   Show instrumentation results
%
%   showInstrumentationResults shows the results from an instrumented MEX
%   function. 
%
%   The general syntax of the showInstrumentationResults command is
%     showInstrumentationResults [MEX_FILE_NAME] [-OPTIONS]
%
%   Options:
%
%     -defaultDT T             Default data type to propose for doubles,
%                              where T is a numerictype object, or one of the
%                              strings {remainFloat, double, single,
%                              int8, int16, int32, int64, uint8,
%                              uint16, uint32, uint64}.  The default is
%                              remainFloat. 
%
%     -log2Display             Display simulation minimum and maximum values
%                              in base-2 scientific notation: F .* 2.^E where
%                              -0.5 <= F <= 0.5, or F==0.  This option is
%                              useful for manually determining the number of
%                              integer bits (not including the sign bit)
%                              necessary to prevent overflow.
%
%     -nocode                  Do not show MATLAB code in the printable
%                              report.  Display only the logged variables
%                              tables.  This option only has effect in
%                              combination with the -printable option.
%
%     -optimizeWholeNumbers    Optimize the word length of variables whose
%                              simulation min/max logs indicate that they
%                              were always whole numbers.
%
%     -percentSafetyMargin N   Safety margin for simulation min/max, where N
%                              represents a percent value.
%
%     -printable               Create a printable report and open in the
%                              system browser.
%
%     -proposeFL               Propose fraction lengths for specified word lengths.
%
%     -proposeWL               Propose word lengths for specified fraction
%                              lengths.
%
%     -proposeForTemps         Propose data types for temporary variables
%                              (e.g. the result of arithmetic operations).
%                              This option is useful for manually determining
%                              product and sum data types.
%
%     -prototypeFimath F       Attaches fimath object F to proposed
%                              types in the prototype table.  Must be
%                              used with the -prototypeTable option to
%                              have an effect.
%
%     -prototypeTable          Creates a column of prototype variables in the
%                              printable report. This option is useful for
%                              cutting-and-pasting the prototype table from the
%                              printable report into a MATLAB function to create
%                              a table of data types.
%
%     -showAttachedFimath      Show attached fimath in prototype table.  Must
%                              be used with the -prototypeTable option to have
%                              an effect.  This option is useful for ensuring
%                              that the prototype in the table can exactly
%                              re-create the fi object of the value,
%                              including its attached fimath.
%
%   Restrictions:
%     
%     Proposed fraction lengths and word lengths are only computed for fi
%     objects with Scaled Double data type.
%
%   To run the following example, copy and paste the entire example into the
%   MATLAB editor and step through it in cell mode.
%
%   Example:
%
%     %% Setup Test Files
%     % Create a temporary directory and copy a demo function from
%     % Fixed-Point Designer into it.
%     %
%     tempdirObj = fidemo.fiTempdir('showInstrumentationResults')
%     %%
%     copyfile(fullfile(matlabroot,'toolbox','fixedpoint','fidemos',...
%         'fi_m_radix2fft_withscaling.m'),'testfft.m','f')
%
%     %% Define Prototype Input Arguments
%     %
%     n = 128;
%     x = complex(ones(n,1));
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
%         x(:) = 2*rand(size(x)) - 1;
%         y = testfft_instrumented(x);
%     end
%
%     %% Show Instrumentation Results
%     % Look at the Variables tab in the Code Generation Report and hover
%     % over variables and expressions in the code to see instrumentation
%     % results.  This report has been generated to propose fraction lengths
%     % with specified word lengths, and a ten percent safety margin.
%     %
%     showInstrumentationResults testfft_instrumented ... 
%                                -defaultDT numerictype(1,16) ...
%                                -proposeFL -percentSafetyMargin 10
%
%     %% Clear the MEX Function and Delete Temporary Files
%     %
%     clear testfft_instrumented;
%     tempdirObj.cleanUp;
%
%   See also FIACCEL, CODEGEN, MEX, buildInstrumentedMex,
%   clearInstrumentationResults

% Copyright 2011-2017 The MathWorks, Inc.
    
    if nargin > 0
        [varargin{:}] = convertStringsToChars(varargin{:});
    end
    
    for i = fixed.internal.evalinShowInstrumentationArgs(varargin)
        try
            varargin{i} = evalin('caller', varargin{i});
        catch  %#ok Errors are handled later
        end
    end

    try
        fixed.internal.showInstrumentationResults(varargin{:});
    catch me
        throw(me)
    end

end
