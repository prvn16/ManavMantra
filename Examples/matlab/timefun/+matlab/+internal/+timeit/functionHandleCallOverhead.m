function [t, functionCallTimeDetails] = functionHandleCallOverhead(f)
% FUNCTIONHANDLECALLOVERHEAD estimate overhead time of function handle call. 
%   T = FUNCTIONHANDLECALLOVERHEAD(F) measures the overhead time (in seconds) 
%   required to call the function handle, F, versus a normal function.  
%
%   [T, FUNCTIONCALLTIMEDETAILS] = FUNCTIONHANDLECALLOVERHEAD(F) returns
%   the measurement details that are used to compute T, including call 
%   times of an empty function, a simple and an anonymous function handle.
%
%   Copyright 2013 The MathWorks, Inc.

functionCallTimeDetails.EmptyFunctionCallTime = emptyFunctionCallTime();
functionCallTimeDetails.SimpleFunctionHandleCallTime = simpleFunctionHandleCallTime();
functionCallTimeDetails.AnonymousFunctionHandleCallTime = anonFunctionHandleCallTime();

fcns = functions(f);
if strcmp(fcns.type, 'anonymous')
    t = anonFunctionHandleCallTime();
else
    t = simpleFunctionHandleCallTime();
end

t = max(t - emptyFunctionCallTime(), 0);

function emptyFunction()

function t = simpleFunctionHandleCallTime
% SIMPLEFUNCTIONHANDLECALLTIME Return the estimated time required to call 
% a simple function handle to a function with an empty body.
%
% A simple function handle fh has the form @foo.

persistent sfhct
if ~isempty(sfhct)
    t = sfhct;
    return
end

num_repeats = 101;
% num_repeats chosen to take about 100 ms, assuming that
% timeFunctionHandleCall() takes about 1 ms.
times = zeros(1, num_repeats);

fh = @emptyFunction;

% Warm up fh().
fh();
fh();
fh();

for k = 1:num_repeats
   times(k) = functionHandleTimeExperiment(fh);
end

t = min(times);
sfhct = t;

function t = anonFunctionHandleCallTime
% Return the estimated time required to call an anonymous function handle that
% calls a function with an empty body.
%
% An anonymous function handle fh has the form @(arg_list) expression. For
% example:
%
%       fh = @(thetad) sin(thetad * pi / 180)

persistent afhct
if ~isempty(afhct)
    t = afhct;
    return
end

num_repeats = 101;
% num_repeats chosen to take about 100 ms, assuming that timeFunctionCall()
% takes about 1 ms.
times = zeros(1, num_repeats);

fh = @() emptyFunction();

% Warm up fh().
fh();
fh();
fh();

for k = 1:num_repeats
   times(k) = functionHandleTimeExperiment(fh);
end

t = min(times);
afhct = t;

function t = functionHandleTimeExperiment(fh)
% Call the function handle fh 2000 times and return the average time required.

% Record starting time.
tic();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();
fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh(); fh();

t = toc() / 2000;

function t = emptyFunctionCallTime()
% Return the estimated time required to call a function with an empty body.

persistent efct
if ~isempty(efct)
    t = efct;
    return
end

% Warm up emptyFunction.
emptyFunction();
emptyFunction();
emptyFunction();

num_repeats = 101;
% num_repeats chosen to take about 100 ms, assuming that timeFunctionCall()
% takes about 1 ms.
times = zeros(1, num_repeats);

for k = 1:num_repeats
   times(k) = emptyFunctionTimeExperiment();
end

t = min(times);
efct = t;

function t = emptyFunctionTimeExperiment()
% Call emptyFunction() 2000 times and return the average time required.

% Record starting time.
tic();

% 1-100
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 101-200
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 201-300
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 301-400
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 401-500
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 501-600
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 601-700
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 701-800
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 801-900
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 901-1000
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 1001-1100
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 1101-1200
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 1201-1300
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 1301-1400
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 1401-1500
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 1501-1600
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 1601-1700
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 1701-1800
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 1801-1900
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

% 1901-2000
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();
emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction(); emptyFunction();

t = toc() / 2000;