%% Perform Fixed-Point Arithmetic
% This example shows how to perform basic fixed-point arithmetic operations.
%
% Copyright 2011-2015 The MathWorks, Inc.

%%
% Save warning states before beginning.
warnstate = warning;
%% Addition and Subtraction
% Whenever you add two unsigned fixed-point numbers, you may need a carry
% bit to correctly represent the result. For this reason, when adding two
% B-bit numbers (with the same scaling), the resulting value has an extra
% bit compared to the two operands used.

a = ufi(0.234375,4,6);
c = a + a

%%

a.bin

%%

c.bin

%%
% With signed, two's-complement numbers, a similar scenario occurs because
% of the sign extension required to correctly represent the result.

a = sfi(0.078125,4,6);
b = sfi(-0.125,4,6);
c = a + b

%%

a.bin
%%

b.bin
%%

c.bin

%%
% If you add or subtract two numbers with different precision, the radix
% point first needs to be aligned to perform the operation. The result is
% that there is a difference of more than one bit between the result of the
% operation and the operands (depending on how far apart the radix points
% are).

a = sfi(pi,16,13);
b = sfi(0.1,12,14);
c = a + b

%% Further Considerations for Addition and Subtraction
% Note that the following pattern is *not* recommended. Since scalar
% additions are performed at each iteration in the for-loop, a bit is
% added to temp during each iteration. As a result, instead of a
% ceil(log2(Nadds)) bit-growth, the bit-growth is equal to Nadds.

s = rng; rng('default');
b = sfi(4*rand(16,1)-2,32,30);
rng(s); % restore RNG state
Nadds = length(b) - 1;
temp  = b(1);
for n = 1:Nadds
    temp = temp + b(n+1); % temp has 15 more bits than b
end

%%
% If the |sum| command is used instead, the bit-growth is curbed as
% expected.

c = sum(b) % c has 4 more bits than b

%% Multiplication
% In general, a full precision product requires a word length equal to the
% sum of the word lengths of the operands. In the following example, note
% that the word length of the product |c| is equal to the word length of
% |a| plus the word length of |b|. The fraction length of |c| is also
% equal to the fraction length of |a| plus the fraction length of |b|.

a = sfi(pi,20);
b = sfi(exp(1),16);
c = a * b

%% Assignment
% When you assign a fixed-point value into a pre-defined variable,
% quantization might be involved. In such cases, the right-hand-side of the
% expression is quantized by rounding to nearest and then saturating, if
% necessary, before assigning to the left-hand-side.

N = 10;
a = sfi(2*rand(N,1)-1,16,15);
b = sfi(2*rand(N,1)-1,16,15);
c = sfi(zeros(N,1),16,14);
for n = 1:N
    c(n) = a(n).*b(n);
end

%%
% Note that when the product |a(n).*b(n)| is computed with full precision,
% an intermediate result with wordlength 32 and fraction length 30 is
% generated. That result is then quantized to a wordlength of 16 and a fraction
% length of 14, as explained above. The quantized value is then assigned to
% the element |c(n)|.

%% Quantizing Results Explicitly
% Often, it is not desirable to round to nearest or to saturate when
% quantizing a result because of the extra logic/computation required.
% It also may be undesirable to have to assign to a left-hand-side value to
% perform the quantization. You can use |QUANTIZE| for such purposes. A
% common case is a feedback-loop. If no quantization is introduced,
% un-bounded bit-growth will occur as more input data is provided.

a = sfi(0.1,16,18);
x = sfi(2*rand(128,1)-1,16,15);
y = sfi(zeros(size(x)),16,14);
for n = 1:length(x)
    z    = y(n);
    y(n) = x(n) - quantize(a.*z, true, 16, 14, 'Floor', 'Wrap');
end

%%
% In this example, the product |a.*z| is computed with full precision and
% is subsequently quantized to a wordlength of 16 bits and a fraction
% length of 14. The quantization is done by rounding to floor (truncation)
% and allowing for wrapping if overflow occurs. Quantization still occurs
% at assignment, because the expression |x(n) - quantize(a.*z, ...)|
% produces an intermediate result of 18 bits and y is defined to have 16
% bits. To eliminate the quantization at assignment, you can introduce an
% additional explicit quantization as shown below. The advantage of doing
% this is that no round-to-nearest/saturation logic is used. The
% left-hand-side result has the same 16-bit wordlength and fraction length
% of 14 as |y(n)|, so no quantization is necessary.

a = sfi(0.1,16,18);
x = sfi(2*rand(128,1)-1,16,15);
y = sfi(zeros(size(x)),16,14);
T = numerictype(true, 16, 14);
for n = 1:length(x)
    z    = y(n);
    y(n) = quantize(x(n), T, 'Floor', 'Wrap') - ...
           quantize(a.*z, T, 'Floor', 'Wrap');
end

%% Non-Full-Precision Sums
% Full-precision sums are not always desirable. For example, the 18-bit
% wordlength corresponding to the intermediate result |x(n) - quantize(...)|
% above may result in complicated and inefficient code, if C code is
% generated. Instead, it may be desirable to keep all results of
% addition/subtraction to 16 bits. You can use the |accumpos| and
% |accumneg| functions for this purpose.

a = sfi(0.1,16,18);
x = sfi(2*rand(128,1)-1,16,15);
y = sfi(zeros(size(x)),16,14);
T = numerictype(true, 16, 14);
for n = 1:length(x)
    z    = y(n);
    y(n) = quantize(x(n), T);                 % defaults: 'Floor','Wrap'
    y(n) = accumneg(y(n), quantize(a.*z, T)); % defaults: 'Floor','Wrap'
end

%% Modeling Accumulators
% |accumpos| and |accumneg| are well-suited to model
% accumulators. The behavior corresponds to the += and -= operators in C. A
% common example is an FIR filter in which the coefficients and input data
% are represented with 16 bits. The multiplication is performed in
% full-precision, yielding 32 bits, and an accumulator with 8 guard-bits,
% i.e. 40-bits total is used to enable up to 256 accumulations without the
% possibility of overflow.

b = sfi(1/256*[1:128,128:-1:1],16); % Filter coefficients
x = sfi(2*rand(300,1)-1,16,15);     % Input data
z = sfi(zeros(256,1),16,15);        % Used to store the states
y = sfi(zeros(size(x)),40,31);      % Initialize Output data
for n = 1:length(x)
    acc = sfi(0,40,31); % Reset accumulator 
    z(1) = x(n);        % Load input sample
    for k = 1:length(b)        
        acc = accumpos(acc,b(k).*z(k)); % Multiply and accumulate
    end
    z(2:end) = z(1:end-1); % Update states
    y(n) = acc;            % Assign output
end

%% Matrix Arithmetic
% To simplify syntax and shorten simulation time, you can use matrix
% arithmetic. For the FIR filter example, you can replace the inner loop
% with an inner product.

z = sfi(zeros(256,1),16,15); % Used to store the states
y = sfi(zeros(size(x)),40,31);
for n = 1:length(x)
    z(1) = x(n);
    y(n) = b*z;
    z(2:end) = z(1:end-1);    
end

%%
% The inner product |b*z| is performed with full precision. Because this is
% a matrix operation, the bit growth is due to both the multiplication
% involved and the addition of the resulting products. Therefore, the bit
% growth depends on the length of the operands. Since |b| and |z| have
% length 256, that accounts for an 8-bit growth due to the additions.
% This is why the inner product results in 32 + 8 = 40 bits (with fraction
% length 31). Since this is the format |y| is initialized to, no
% quantization occurs in the assignment |y(n) = b*z|.

%%
% If you had to perform an inner product for more than 256 coefficients,
% the bit growth would be more than 8 bits beyond the 32 needed for the
% product. If you only had a 40-bit accumulator, you could model the
% behavior by either introducing a quantizer, as in |y(n) =
% quantize(Q,b*z)|, or you could use the |accumpos| function as has
% been shown.

%% Modeling a Counter
% |accumpos| can be used to model a simple counter which naturally
% wraps after reaching its maximum value. For example, you can model a
% 3-bit counter as follows.

c = ufi(0,3,0);
Ncounts = 20; % Number of times to count
for n = 1:Ncounts
    c = accumpos(c,1);
end

%%
% Since the 3-bit counter naturally wraps back to 0 after reaching 7, the
% final value of the counter is mod(20,8) = 4.

%% Math With Other Built-In Data Types
%% FI * DOUBLE
% When doing multiplication between |fi| and |double|, the |double| is cast to a
% |fi| with the same word length and signedness of the |fi|, and
% best-precision fraction length. The result of the operation is a |fi|.
a = fi(pi);
b = 0.5 * a
%% FI + DOUBLE or FI - DOUBLE
% When doing addition or subtraction between |fi| and |double|, the
% double is cast to a |fi| with the same |numerictype| as the |fi|.
% The result of the operation is a |fi|.
%
% This behavior of |fi| + |double| changed in R2012b.  You can turn off the
% incompatibility warning by entering the following warning command.
warning off fixed:incompatibility:fi:behaviorChangeHeterogeneousMathOperationRules
a = fi(pi);
b = a + 1

%% Some Differences Between MATLAB(R) and C
% Note that in C, the result of an operation between an integer data type
% and a double data type promotes to a double.
%
% However, in MATLAB, the result of an operation between a built-in
% integer data type and a double data type is an integer. In this respect,
% the |fi| object behaves like the built-in integer data types in MATLAB.
% The result of an operation between a |fi| and a double is a |fi|.

%% FI * INT8
% When doing arithmetic between fi and one of the built-in integer data
% types [u]int[8,16,32], the word length and signedness of the integer are
% preserved. The result of the operation is a fi.
a = fi(pi);
b = int8(2) * a

%%
% Restore warning states.
warning(warnstate);
displayEndOfDemoMessage(mfilename)
