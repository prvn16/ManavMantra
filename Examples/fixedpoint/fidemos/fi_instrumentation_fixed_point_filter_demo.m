%% Set Data Types Using Min/Max Instrumentation
%
% This example shows how to set fixed-point data types by instrumenting
% MATLAB(R) code for min/max logging and using the tools to propose data types.
%
% The functions you will use are:
%
% * <matlab:helpview([docroot,'/fixedpoint/ref/buildinstrumentedmex.html']); |buildInstrumentedMex|> - Build MEX function with instrumentation enabled
% * <matlab:helpview([docroot,'/fixedpoint/ref/showinstrumentationresults.html']); |showInstrumentationResults|> - Show instrumentation results
% * <matlab:helpview([docroot,'/fixedpoint/ref/clearinstrumentationresults.html']); |clearInstrumentationResults|> - Clear instrumentation results
%
% Copyright 2011-2013 The MathWorks, Inc.
%% The Unit Under Test
% The function that you convert to fixed-point in this example is a
% second-order direct-form 2 transposed filter.  You can substitute your own
% function in place of this one to reproduce these steps in your own work.
%
%   function [y,z] = fi_2nd_order_df2t_filter(b,a,x,y,z)
%       for i=1:length(x)
%           y(i) = b(1)*x(i) + z(1);
%           z(1) = b(2)*x(i) + z(2) - a(2) * y(i);
%           z(2) = b(3)*x(i)        - a(3) * y(i);
%       end
%   end
%
% For a MATLAB(R) function to be instrumented, it must be suitable for
% code generation. For information on code generation, see the reference page
% for <matlab:helpview([docroot,'/fixedpoint/ref/buildinstrumentedmex.html']); |buildInstrumentedMex|>.  A MATLAB(R)
% Coder(TM) license is not required to use |buildInstrumentedMex|.
%
% In this function the variables |y| and
% |z| are used as both inputs and outputs.  This is an important pattern
% because:
%
% * You can set the data type of |y| and |z| outside the function, thus
% allowing you to re-use the function for both fixed-point and
% floating-point types.
% * The generated C code will create |y| and |z| as references in the function
% argument list.  For more information about this pattern, see the documentation
% under Code Generation from MATLAB(R) > User's Guide > Generating Efficient
% and Reusable Code > Generating Efficient Code > Eliminating Redundant
% Copies of Function Inputs.
%
% Run the following code to copy the test function
% into a temporary directory so this example doesn't
% interfere with your own work.
tempdirObj = fidemo.fiTempdir('fi_instrumentation_fixed_point_filter_demo');
%%
copyfile(fullfile(matlabroot,'toolbox','fixedpoint','fidemos','+fidemo',...
                  'fi_2nd_order_df2t_filter.m'),'.','f');
%%
% Run the following code to capture current states, and reset the global
% states.
FIPREF_STATE = get(fipref);
reset(fipref)

%% Data Types Determined by the Requirements of the Design
% In this example, the requirements
% of the design determine the data type of input |x|.  
% These requirements are signed, 16-bit, and fractional.
N = 256;
x = fi(zeros(N,1),1,16,15);
%%
% The requirements of the design also determine the fixed-point math
% for a DSP target with a 40-bit accumulator.  This example uses floor rounding
% and wrap overflow to produce efficient generated code.
F = fimath('RoundingMethod','Floor',...
           'OverflowAction','Wrap',...
           'ProductMode','KeepLSB',...
           'ProductWordLength',40,...
           'SumMode','KeepLSB',...
           'SumWordLength',40);
%%       
% The following coefficients correspond to a second-order lowpass filter created
% by
%
%   [num,den] = butter(2,0.125)
%
% The values of the coefficients influence the range of the values that will be
% assigned to the filter output and states.  
num = [0.0299545822080925  0.0599091644161849  0.0299545822080925];
den = [1                  -1.4542435862515900  0.5740619150839550];
%%
% The data type of the coefficients, determined by the requirements of the
% design, are specified as 16-bit word length and scaled to best-precision.
% A pattern for creating |fi| objects from constant coefficients is:
%
% 1. Cast the coefficients to |fi| objects using the default round-to-nearest and
% saturate overflow settings, which gives the coefficients better accuracy.
%
% 2. Attach |fimath| with floor rounding and wrap overflow settings to
% control arithmetic, which leads to more efficient C code.
b = fi(num,1,16); b.fimath = F;
a = fi(den,1,16); a.fimath = F;
%%
% Hard-code the filter coefficients into the implementation of this filter by
% passing them as constants to the |buildInstrumentedMex| command.
B = coder.Constant(b);
A = coder.Constant(a);
      
%% Data Types Determined by the Values of the Coefficients and Inputs
% The values of the coefficients and values of the inputs determine the data
% types of output |y| and state vector |z|.  Create them with a scaled double
% datatype so their values will attain full range and you can identify potential
% overflows and propose data types.
yisd = fi(zeros(N,1),1,16,15,'DataType','ScaledDouble','fimath',F);
zisd = fi(zeros(2,1),1,16,15,'DataType','ScaledDouble','fimath',F);

%% Instrument the MATLAB(R) Function as a Scaled-Double MEX Function
% To instrument the MATLAB(R) code, you create a MEX function from the MATLAB(R)
% function using the <matlab:helpview([docroot,'/fixedpoint/ref/buildinstrumentedmex.html']); |buildInstrumentedMex|> command.  The inputs to |buildInstrumentedMex| are the
% same as the inputs to <matlab:helpview([docroot,'/fixedpoint/ref/fiaccel.html']); |fiaccel|>, but
% |buildInstrumentedMex| has no |fi|-object restrictions.  The output of
% |buildInstrumentedMex| is a MEX function with instrumentation inserted, so
% when the MEX function is run, the simulated minimum and maximum values
% are recorded for all named variables and intermediate values.
%
% Use the |'-o'| option to name the MEX function that is generated.  If you
% do not use the |'-o'| option, then the MEX function is the name of the MATLAB(R)
% function with |'_mex'| appended.  You can also name the MEX function the same
% as the MATLAB(R) function, but you need to remember that MEX functions take
% precedence over MATLAB(R) functions and so changes to the MATLAB(R) function
% will not run until either the MEX function is re-generated, or the MEX
% function is deleted and cleared.
buildInstrumentedMex fi_2nd_order_df2t_filter ...
    -o filter_scaled_double ...
    -args {B,A,x,yisd,zisd}


%% Test Bench with Chirp Input
% The test bench for this system is set up to run chirp and step signals.  In
% general, test benches for systems should cover a wide range of input
% signals.
%
% The first test bench uses a chirp input.  A chirp signal is a good
% representative input because it covers a wide range of frequencies.
t = linspace(0,1,N);       % Time vector from 0 to 1 second
f1 = N/2;                  % Target frequency of chirp set to Nyquist
xchirp = sin(pi*f1*t.^2);  % Linear chirp from 0 to Fs/2 Hz in 1 second
x(:) = xchirp;             % Cast the chirp to fixed-point
%% Run the Instrumented MEX Function to Record Min/Max Values
% The instrumented MEX function must be run to record minimum
% and maximum values for that simulation run.  Subsequent runs
% accumulate the instrumentation results until they are cleared with
% |clearInstrumentationResults|.
%
% Note that the numerator and denominator coefficients were compiled as
% constants so they are not provided as input to the generated MEX function.
ychirp = filter_scaled_double(x,yisd,zisd);
%%
% The plot of the filtered chirp signal shows the lowpass behavior of the
% filter with these particular coefficients. Low frequencies are passed
% through and higher frequencies are attenuated.
clf
plot(t,x,'c',t,ychirp,'bo-')
title('Chirp')
legend('Input','Scaled-double output')
figure(gcf); drawnow;
%% Show Instrumentation Results with Proposed Fraction Lengths for Chirp
% The <matlab:helpview([docroot,'/fixedpoint/ref/showinstrumentationresults.html']); |showInstrumentationResults|>
% command displays the code generation report with instrumented values.  The
% input to |showInstrumentationResults| is the name of the instrumented MEX
% function for which you wish to show results.
%
% This is the list of options to the |showInstrumentationResults| command:
%
% * |-defaultDT T| Default data type to propose for doubles, where |T| is a
% |numerictype| object, or one of the strings |{remainFloat, double, single, int8,
% int16, int32, int64, uint8, uint16, uint32, uint64}|.  The default is
% |remainFloat|.
% * |-nocode| Do not show MATLAB code in the printable
% report.  Display only the logged variables
% tables.  This option only has effect in
% combination with the -printable option.
% * |-optimizeWholeNumbers|  Optimize the word length of variables whose
% simulation min/max logs indicate that they were always whole numbers.
% * |-percentSafetyMargin N|  Safety margin for simulation min/max, where |N|
% represents a percent value.
% * |-printable|  Create a printable report and open in the
% system browser.
% * |-proposeFL|  Propose fraction lengths for specified word lengths.
% * |-proposeWL|  Propose word lengths for specified fraction lengths.
%     
% Potential overflows are only displayed for |fi| objects with Scaled Double
% data type.
%
% This particular design is for a DSP, where the word lengths are fixed, so use the
% |proposeFL| flag to propose fraction lengths.
showInstrumentationResults filter_scaled_double -proposeFL
%% 
% Hover over expressions or variables in the instrumented code generation report
% to see the simulation minimum and maximum values.  In this design, the inputs
% fall between -1 and +1, and the values of all variables and intermediate
% results also fall between -1 and +1.  This suggests that the data types can
% all be fractional (fraction length one bit less than the word length).
% However, this will not always be true for this function for other kinds of
% inputs and it is important to test many types of inputs before setting final
% fixed-point data types.
%
% <<fi_instrumentation_fixed_point_filter_demo_code_generation_report_01.png>>

%% Test Bench with Step Input
% The next test bench is run with a step input.  A step input is a good
% representative input because it is often used to characterize the behavior
% of a system.
xstep = [ones(N/2,1);-ones(N/2,1)];
x(:) = xstep;
%% Run the Instrumented MEX Function with Step Input
% The instrumentation results are accumulated until they are cleared with
% |clearInstrumentationResults|.
ystep = filter_scaled_double(x,yisd,zisd);

clf
plot(t,x,'c',t,ystep,'bo-')
title('Step')
legend('Input','Scaled-double output')
figure(gcf); drawnow;
%% Show Accumulated Instrumentation Results
% Even though the inputs for step and chirp inputs are both full range as
% indicated by |x| at 100 percent current range in the instrumented code
% generation report, the step input causes overflow while the chirp input did
% not.  This is an illustration of the necessity to have many different inputs
% for your test bench.  For the purposes of this example, only two inputs were
% used, but real test benches should be more thorough.
showInstrumentationResults filter_scaled_double -proposeFL
%%
% <<fi_instrumentation_fixed_point_filter_demo_code_generation_report_02.png>>


%% Apply Proposed Fixed-Point Properties
% To prevent overflow, set proposed fixed-point properties based on the proposed
% fraction lengths of 14-bits for |y| and |z| from the instrumented code
% generation report.
%
% At this point in the workflow, you use true fixed-point types (as opposed to
% the scaled double types that were used in the earlier step of determining data
% types).
yi = fi(zeros(N,1),1,16,14,'fimath',F);
zi = fi(zeros(2,1),1,16,14,'fimath',F);

%% Instrument the MATLAB(R) Function as a Fixed-Point MEX Function
% Create an instrumented fixed-point MEX function by using fixed-point inputs
% and the |buildInstrumentedMex| command.  
buildInstrumentedMex fi_2nd_order_df2t_filter ...
    -o filter_fixed_point ...
    -args {B,A,x,yi,zi}

%% Validate the Fixed-Point Algorithm
% After converting to fixed-point, run the test bench again with
% fixed-point inputs to validate the design.

%% Validate with Chirp Input
% Run the fixed-point algorithm with a chirp input to validate the design.
x(:) = xchirp;
[y,z] = filter_fixed_point(x,yi,zi);
[ysd,zsd] = filter_scaled_double(x,yisd,zisd);
err = double(y) - double(ysd);
%%
% Compare the fixed-point outputs to the scaled-double outputs to verify that
% they meet your design criteria.
clf
subplot(211);plot(t,x,'c',t,ysd,'bo-',t,y,'mx')
xlabel('Time (s)');
ylabel('Amplitude')
legend('Input','Scaled-double output','Fixed-point output');
title('Fixed-Point Chirp')
subplot(212);plot(t,err,'r');title('Error');xlabel('t'); ylabel('err');
figure(gcf); drawnow;
%%
% Inspect the variables and intermediate results to ensure that the min/max
% values are within range.
showInstrumentationResults filter_fixed_point
%%
% <<fi_instrumentation_fixed_point_filter_demo_code_generation_report_03.png>>


%% Validate with Step Inputs
% Run the fixed-point algorithm with a step input to validate the design.
%
% Run the following code to clear the previous instrumentation results to see
% only the effects of running the step input.
clearInstrumentationResults filter_fixed_point
%%
% Run the step input through the fixed-point filter and compare with the
% output of the scaled double filter.
x(:) = xstep;
[y,z] = filter_fixed_point(x,yi,zi);
[ysd,zsd] = filter_scaled_double(x,yisd,zisd);
err = double(y) - double(ysd);
%%
% Plot the fixed-point outputs against the scaled-double outputs to verify that
% they meet your design criteria.
clf
subplot(211);plot(t,x,'c',t,ysd,'bo-',t,y,'mx')
title('Fixed-Point Step');
legend('Input','Scaled-double output','Fixed-point output')
subplot(212);plot(t,err,'r');title('Error');xlabel('t'); ylabel('err');
figure(gcf); drawnow;
%%
% Inspect the variables and intermediate results to ensure that the min/max
% values are within range.
showInstrumentationResults filter_fixed_point
%%
% <<fi_instrumentation_fixed_point_filter_demo_code_generation_report_04.png>>

%% 
% Run the following code to restore the global states.
fipref(FIPREF_STATE);
clearInstrumentationResults filter_fixed_point
clearInstrumentationResults filter_scaled_double
clear fi_2nd_order_df2t_filter_fixed_instrumented
clear fi_2nd_order_df2t_filter_float_instrumented
%%
% Run the following code to delete the temporary directory.
tempdirObj.cleanUp;

displayEndOfDemoMessage(mfilename)
