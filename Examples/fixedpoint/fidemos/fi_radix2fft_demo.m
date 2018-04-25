%% Convert Fast Fourier Transform (FFT) to Fixed Point
%
% This example shows how to convert a textbook version of the Fast Fourier
% Transform (FFT) algorithm into fixed-point MATLAB(R) code.

% Copyright 2004-2015 The MathWorks, Inc.

%%
% Run the following code to copy functions from the Fixed-Point
% Designer(TM) examples directory into a temporary directory so this
% example doesn't interfere with your own work.
tempdirObj = fidemo.fiTempdir('fi_radix2fft_demo');

% Copying important functions to the temporary directory
copyfile(fullfile(matlabroot,'toolbox','fixedpoint','fidemos','+fidemo',...
    'fi_m_radix2fft_algorithm1_6_2.m'),'.','f');
copyfile(fullfile(matlabroot,'toolbox','fixedpoint','fidemos','+fidemo',...
    'fi_m_radix2fft_algorithm1_6_2_typed.m'),'.','f');
copyfile(fullfile(matlabroot,'toolbox','fixedpoint','fidemos','+fidemo',...
    'fi_m_radix2fft_withscaling_typed.m'),'.','f');
%%
% Run the following code to capture current states, and reset the global
% states.
FIPREF_STATE = get(fipref);
reset(fipref)

%% Textbook FFT Algorithm
% FFT is a complex-valued linear transformation from the time domain to the
% frequency domain.  For example, if you construct a vector as the sum of
% two sinusoids and transform it with the FFT, you can see the peaks of the
% frequencies in the FFT magnitude plot.
n = 64;                                     % Number of points
Fs = 4;                                     % Sampling frequency in Hz
t  = (0:(n-1))/Fs;                          % Time vector
f  = linspace(0,Fs,n);                      % Frequency vector
f0 = .2; f1 = .5;                           % Frequencies, in Hz
x0 = cos(2*pi*f0*t) + 0.55*cos(2*pi*f1*t);  % Time-domain signal
x0 = complex(x0);                           % The textbook algorithm requires
                                            % the input to be complex
y0  = fft(x0);                              % Frequency-domain transformation
                                            % fft() is a MATLAB built-in
                                            % function

fidemo.fi_fft_demo_ini_plot(t,x0,f,y0);     % Plotting the results from fft
                                            % and time-domain signal

%%
% The peaks at 0.2 and 0.5 Hz in the frequency plot correspond to the two
% sinusoids of the time-domain signal at those frequencies.
%
% Note the reflected peaks at 3.5 and 3.8 Hz.  When the input to an FFT is
% real-valued, as it is in this case, then the output $y$ is
% conjugate-symmetric:
%
% $$y(k) = \mbox{conj}(y(n-k))$$
%
% There are many different implementations of the FFT, each having its own
% costs and benefits.  You may find that a different algorithm is better
% for your application than the one given here.  This algorithm
% provides you with an example of how you can begin your own exploration.
%
% This example uses the decimation-in-time unit-stride FFT shown in
% Algorithm 1.6.2 on page 45 of the book _Computational Frameworks for the
% Fast Fourier Transform_ by Charles Van Loan.
%
% In pseudo-code, the algorithm in the textbook is as follows:
%
% Algorithm 1.6.2.  If $x$ is a complex vector of length $n$ and $n = 2^t$,
% then the following algorithm overwrites $x$ with $F_nx$.
%
% $$\begin{array}{llll}
%    \multicolumn{4}{l}{x = P_nx}\\
%    \multicolumn{4}{l}{w = w_n^{(long)}\mbox{\hspace*{3em}(See Van Loan \S 1.4.11.)}}\\
%    \mbox{for}\ q\ & \multicolumn{3}{l}{ = 1:t}\\
%        & \multicolumn{3}{l}{L=2^q;\ r=n/L;\ L_\ast=L/2;}\\
%        & \mbox{for}\ k\ & \multicolumn{2}{l}{=0:r-1}\\
%        & & \mbox{for}\ j\ & =0:L_\ast-1\\
%        & &                & \tau  = w(L_\ast-1+j) \cdot x(kL+j+L_\ast)\\
%        & &                & x(kL+j+L_\ast) = x(kL+j)  - \tau\\
%        & &                & x(kL+j)    = x(kL+j)  + \tau\\
%        & & \mbox{end}\\
%        & \mbox{end}\\
%   \mbox{end}\\
% \end{array}$$
%
% The textbook algorithm uses zero-based indexing. $F_n$ is an n-by-n
% Fourier-transform matrix, $P_n$ is an n-by-n bit-reversal permutation
% matrix, and $w$ is a complex vector of twiddle factors.  The twiddle
% factors, $w$, are complex roots of unity computed by the following
% algorithm:
%
% <include>+fidemo/fi_radix2twiddles.m</include>
%
%%
figure(gcf)
clf
w0 = fidemo.fi_radix2twiddles(n);
polar(angle(w0),abs(w0),'o')
title('Twiddle Factors: Complex roots of unity')
%% Verify Floating-Point Code
% To implement the algorithm in MATLAB, you can use the
% |fidemo.fi_bitreverse| function to bit-reverse the input sequence.
% You must add one to the indices to convert them from zero-based to
% one-based.
%
% <include>+fidemo/fi_m_radix2fft_algorithm1_6_2.m</include>
%
% *Visualization*
%
% To verify that you correctly implemented the algorithm in MATLAB, run a
% known signal through it and compare the results to the results produced
% by the MATLAB FFT function.
%
% As seen in the plot below, the error is within tolerance of the MATLAB
% built-in FFT function, verifying that you have correctly implemented the
% algorithm.

y = fi_m_radix2fft_algorithm1_6_2(x0, w0);

fidemo.fi_fft_demo_plot(real(x0),y,y0,Fs,'Double data', ...
    {'FFT Algorithm 1.6.2','Built-in FFT'});

%% Convert Functions to use Types Tables
% To separate data types from the algorithm:
%
% # Create a table of data type definitions.
% # Modify the algorithm code to use data types from that table.
%
% This example shows the iterative steps by creating different files. In
% practice, you can make the iterative changes to the same file.
%
% *Original types table*
%
% Create a types table using a structure with prototypes for the variables
% set to their original types.  Use the baseline types to validate that you
% made the initial conversion correctly, and to programmatically
% toggle your function between floating point and fixed point types.  The
% index variables are automatically converted to integers by MATLAB
% Coder(TM), so you don't need to specify their types in the table.
%
% Specify the prototype values as empty ([ ]) since the data types are
% used, but not the values.
%
% <include>+fidemo/fi_m_radix2fft_original_types.m</include>
%
%%
% *Type-aware algorithm function*
%
% Add types table T as an input to the function and use it to cast
% variables to a particular type, while keeping the body of the algorithm
% unchanged.
%
% <include>+fidemo/fi_m_radix2fft_algorithm1_6_2_typed.m</include>
%
%%
% *Type-aware bitreversal function*
%
% Add types table T as an input to the function and use it to cast
% variables to a particular type, while keeping the body of the algorithm
% unchanged.
%
% <include>+fidemo/fi_bitreverse_typed.m</include>
%
%%
% *Validate modified function*
%
% Every time you modify your function, validate that the results still
% match your baseline.  Since you used the original types in the types
% table, the outputs should be identical.  This validates that you made the
% conversion to separate the types from the algorithm correctly.

T1 = fidemo.fi_m_radix2fft_original_types(); % Getting original data types declared in table

x = cast(x0,'like',T1.x);
w = cast(w0,'like',T1.w);

y = fi_m_radix2fft_algorithm1_6_2_typed(x, w, T1);

fidemo.fi_fft_demo_plot(real(x),y,y0,Fs,'Double data', ...
    {'FFT Algorithm 1.6.2','Built-in FFT'});

%% Create a fixed-point types table
% Create a fixed-point types table using a structure with prototypes for
% the variables. Specify the prototype values as empty ([ ]) since the data
% types are used, but not the values.
%
% <include>+fidemo/fi_m_radix2fft_fixed_types.m</include>
%
%% Identify Fixed-Point Issues
%
% Now, try converting the input data to fixed-point and see if the
% algorithm still looks good.  In this first pass, you use all the defaults
% for signed fixed-point data by using the |fi| constructor.

T2 = fidemo.fi_m_radix2fft_fixed_types(); % Getting fixed point data types declared in table

x = cast(x0,'like',T2.x);
w = cast(w0,'like',T2.w);

%%
% Re-run the same algorithm with the fixed-point inputs
y  = fi_m_radix2fft_algorithm1_6_2_typed(x,w,T2);
fidemo.fi_fft_demo_plot(real(x),y,y0,Fs,'Fixed-point data', ...
    {'Fixed-point FFT Algorithm 1.6.2','Built-in FFT'});
%%
% Note that the magnitude plot (center) of the fixed-point FFT does not
% resemble the plot of the built-in FFT.  The error (bottom plot) is much
% larger than what you would expect to see for round off error, so it is
% likely that overflow has occurred.

%% Use Min/Max Instrumentation to Identify Overflows
% To instrument the MATLAB(R) code, create a MEX function from the
% MATLAB(R) function using the
% <matlab:helpview([docroot,'/fixedpoint/ref/buildinstrumentedmex.html']);
% |buildInstrumentedMex|> command.  The inputs to |buildInstrumentedMex|
% are the same as the inputs to
% <matlab:helpview([docroot,'/fixedpoint/ref/fiaccel.html']); |fiaccel|>,
% but |buildInstrumentedMex| has no |fi|-object restrictions.  The output
% of |buildInstrumentedMex| is a MEX function with instrumentation
% inserted, so when the MEX function is run, the simulated minimum and
% maximum values are recorded for all named variables and intermediate
% values.
%
% The |'-o'| option is used to name the MEX function that is generated.  If
% the |'-o'| option is not used, then the MEX function is the name of the
% MATLAB(R) function with |'_mex'| appended.  You can also name the MEX
% function the same as the MATLAB(R) function, but you need to remember
% that MEX functions take precedence over MATLAB(R) functions and so
% changes to the MATLAB(R) function will not run until either the MEX
% function is re-generated, or the MEX function is deleted and cleared.
%
% Create the input with a scaled double datatype so its values will attain
% full range and you can identify potential overflows.
%
% <include>+fidemo/fi_m_radix2fft_scaled_fixed_types.m</include>
%

T3 = fidemo.fi_m_radix2fft_scaled_fixed_types(); % Getting fixed point data types declared in table

x_scaled_double = cast(x0,'like',T3.x);
w_scaled_double = cast(w0,'like',T3.w);

buildInstrumentedMex fi_m_radix2fft_algorithm1_6_2_typed ...
    -o fft_instrumented -args {x_scaled_double w_scaled_double T3}

%%
% Run the instrumented MEX function to record min/max values.
y_scaled_double = fft_instrumented(x_scaled_double,w_scaled_double,T3);
%%
% Show the instrumentation results.
showInstrumentationResults fft_instrumented
%%
% You can see from the instrumentation results that there were overflows
% when assigning into the variable |x|.
%
% <<fi_radix2fft_demo_codegen_report.png>>


%% Modify the Algorithm to Address Fixed-Point Issues
% The magnitude of an individual bin in the FFT grows, at most, by a factor
% of n, where n is the length of the FFT.  Hence, by scaling your data by
% 1/n, you can prevent overflow from occurring for any input.
% When you scale only the input to the first stage of a length-n FFT by
% 1/n, you obtain a noise-to-signal ratio proportional to n^2 [Oppenheim &
% Schafer 1989, equation 9.101], [Welch 1969].
% However, if you scale the input to each of the stages of the FFT by 1/2,
% you can obtain an overall scaling of 1/n and produce a noise-to-signal
% ratio proportional to n [Oppenheim & Schafer 1989, equation 9.105],
% [Welch 1969].
%
% An efficient way to scale by 1/2 in fixed-point is to right-shift the
% data. To do this, you use the bit shift right arithmetic function
% |bitsra|. After scaling each stage of the FFT, and optimizing the index
% variable computation, your algorithm becomes:
%
% <include>+fidemo/fi_m_radix2fft_withscaling_typed.m</include>
%
%%
% Run the scaled algorithm with fixed-point data.
x = cast(x0,'like',T3.x);
w = cast(w0,'like',T3.w);

y = fi_m_radix2fft_withscaling_typed(x,w,T3);

fidemo.fi_fft_demo_plot(real(x), y, y0/n, Fs, 'Fixed-point data', ...
    {'Fixed-point FFT with scaling','Built-in FFT'});
%%
% You can see that the scaled fixed-point FFT algorithm now matches the
% built-in FFT to a tolerance that is expected for 16-bit fixed-point data.

%% References
% Charles Van Loan, _Computational Frameworks for the Fast Fourier
% Transform,_ SIAM, 1992.
%
% Cleve Moler, _Numerical Computing with MATLAB,_ SIAM, 2004, Chapter 8
% Fourier Analysis.
%
% Alan V. Oppenheim and Ronald W. Schafer, _Discrete-Time Signal
% Processing,_ Prentice Hall, 1989.
%
% Peter D. Welch, "A Fixed-Point Fast Fourier Transform Error Analysis,"
% IEEE(R) Transactions on Audio and Electroacoustics, Vol. AU-17, No. 2,
% June 1969, pp. 151-157.

%%
% Run the following code to restore the global states.
fipref(FIPREF_STATE);
clearInstrumentationResults fft_instrumented
clear fft_instrumented
%%
% Run the following code to delete the temporary directory.
cleanUp(tempdirObj);

displayEndOfDemoMessage(mfilename)
