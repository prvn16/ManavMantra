function t = timeit(f, num_outputs)
%TIMEIT Measures time required to run function.
%   T = TIMEIT(F) measures the typical time (in seconds) required to run
%   the function specified by the function handle F that takes no input
%   argument.
%
%   T = TIMEIT(F,N) calls F with N output arguments. By default, TIMEIT
%   calls the function F with one output (or no output, if the function
%   does not return any output).
%
%   Examples
%   --------
%   How much time does it take to compute sum(A.' .* B, 1), where A is
%   12000-by-400 and B is 400-by-12000?
%
%       A = rand(12000, 400);
%       B = rand(400, 12000);
%       f = @() sum(A.' .* B, 1);
%       timeit(f)
%
%   How much time does it take to call svd with three output arguments?
%
%       X = [1 2; 3 4; 5 6; 7 8];
%       f = @() svd(X);
%       timeit(f, 3)
%
%   See also CPUTIME, TIC, TOC

%   Copyright 2008-2013 The MathWorks, Inc.

%   For detailed discussion on MATLAB Performance Measurement:
%   http://www.mathworks.com/matlabcentral/fileexchange/18510-matlab-performance-measurement

narginchk(1,2);

% Check f is zero-input function handle
if ~isa(f,'function_handle') || ~ismember(nargin(f), [0 -1])
    error(message('MATLAB:timeit:InvalidFunctionHandle'));
end

try
    nargin(f());
catch exception
    if strcmp(exception.identifier,'MATLAB:scriptNotAFunction')
        error(message('MATLAB:timeit:HandleToScript'));
    end
end

if nargin < 2
    num_outputs = min(numOutputs(f), 1);
else
    try
        % Check if num_outputs is a non-negative integer
        validateattributes(num_outputs,{'numeric'},{'integer','nonnegative'})
    catch
        % Error if num_outputs is NOT a non-negative integer
        error(message('MATLAB:timeit:InvalidNumberOfOutputs'));
    end
end

t_rough = roughEstimate(f, num_outputs);

% Cap minimum of t_rough to functionHandleCallOverhead or 1ns, whichever 
% bigger, in case in rare circustances when t_rough equals zero.
if t_rough == 0
    t_rough = max(matlab.internal.timeit.functionHandleCallOverhead(f), 1e-9);
end

% Calculate the number of inner-loop repetitions so that the inner for-loop
% takes at least about 1ms to execute (this particular choice of time 
% period is related to the granularity of the timing functions - refer to 
% whitepaper link on top for details)
desired_inner_loop_time = 0.001;
num_inner_iterations = max(ceil(desired_inner_loop_time / t_rough), 1);

% Run the outer loop enough times to give a reasonable set of inputs to median.
num_outer_iterations = 11;

% Heuristic to avoid excessing running time If the estimated running time 
% for the timing loops is too long,reduce the number of outer loop iterations.
estimated_running_time = num_outer_iterations * num_inner_iterations * t_rough;
long_time = 15;
min_outer_iterations = 3;
if estimated_running_time > long_time
    num_outer_iterations = ceil(long_time / (num_inner_iterations * t_rough));
    num_outer_iterations = max(num_outer_iterations, min_outer_iterations);
end

runtimes = zeros(num_outer_iterations, 1);

% Two-loop timing strategy: inner loop, within a single tic-toc pair, is
% intended to repeat f() enough to get good tic-toc measurements; outer loop 
% repeats  the tic-toc measurement several times to collect multiple results
% for median time.
for k = 1:num_outer_iterations
    % Coding note: An earlier version of this code constructed an "outputs"
    % cell array (e.g. varargout), which was used in comma-separated form 
    % for  the left-hand side of the call to f().  It turned out, though, 
    % that the comma-separated output argument added significant measurement 
    % overhead.  Therefore, the cases for different numbers of output 
    % arguments are hard-coded into the switch statement below.
    switch num_outputs
        case 0
            tic(); % t1 = tic();...t = toc(t1) NOT used because not JIT-ed
            for p = 1:num_inner_iterations
                f();
            end
            runtimes(k) = toc();
            
        case 1
            tic();
            for p = 1:num_inner_iterations
                output = f(); %#ok<NASGU>
            end
            runtimes(k) = toc();
            
        case 2
            tic();
            for p = 1:num_inner_iterations
                [~, ~] = f();
            end
            runtimes(k) = toc();
            
        case 3
            tic();
            for p = 1:num_inner_iterations
                [~, ~, ~] = f();
            end
            runtimes(k) = toc();
            
        case 4
            tic();
            for p = 1:num_inner_iterations
                [~, ~, ~, ~] = f();
            end
            runtimes(k) = toc();
            
        otherwise
            tic();
            for p = 1:num_inner_iterations
                [varargout{1:num_outputs}] = f(); %#ok<NASGU>
            end
            runtimes(k) = toc();
    end
    
end

% median instead of min because the former better represents regular
% running time
t = median(runtimes) / num_inner_iterations;

measurement_overhead = (matlab.internal.timeit.tictocCallTime() / num_inner_iterations) + ...
    matlab.internal.timeit.functionHandleCallOverhead(f);

t = max(t - measurement_overhead, 0);

if t < (5 * measurement_overhead)
    warning(message('MATLAB:timeit:HighOverhead'));
end

function t = roughEstimate(f, num_f_outputs)
%   Return rough estimate of time required for one execution of
%   f().  Basic warmups are done, but no fancy looping, medians,
%   etc.

% Warm up tic/toc.
tic();
elapsed = toc(); %#ok<NASGU>
tic();
elapsed = toc(); %#ok<NASGU>

% Call f() in a loop for at least a millisecond.
runtimes = [];
time_threshold = 3;
iter_count = 0;
while sum(runtimes) < 0.001
    iter_count = iter_count + 1;
    
    switch num_f_outputs
        case 0
            tic();
            f();
            runtimes(end+1) = toc(); %#ok<AGROW>
            
        case 1
            tic();
            output1 = f(); %#ok<NASGU>
            runtimes(end+1) = toc(); %#ok<AGROW>
            
        case 2
            tic();
            [~, ~] = f();
            runtimes(end+1) = toc(); %#ok<AGROW>
            
        case 3
            tic();
            [~, ~, ~] = f(); 
            runtimes(end+1) = toc(); %#ok<AGROW>
            
        case 4
            tic();
            [~, ~, ~, ~] = f();
            runtimes(end+1) = toc(); %#ok<AGROW>
            
        otherwise
            tic();
            [varargout{1:num_f_outputs}] = f(); %#ok<NASGU>
            runtimes(end+1) = toc(); %#ok<AGROW>
    end
    
    if iter_count == 1
        if runtimes > time_threshold
            % If the first call to f() takes more than time_threshold to run,
            % then just use the result from that call.  The assumption is that
            % first-time effects are negligible compared to the running time for
            % f().
            break;
        else
            % Discard first timing.
            runtimes = [];
        end
    end
end

t = median(runtimes);
        
function n = numOutputs(f)
%   Return the number of output arguments to be used when calling the function
%   handle f.  
%   * If nargout(f) > 0, return 1.
%   * If nargout(f) == 0, return 0.
%   * If nargout(f) < 0, use try/catch to determine whether to call f with one
%     or zero output arguments.
%     Note: It is not documented (as of R2008b) that nargout can return -1.
%     However, it appears to do so for functions that use varargout and for
%     anonymous function handles.  

n = nargout(f);
if n < 0
   try
      a = f(); %#ok<NASGU>
      % If the line above doesn't throw an error, then it's OK to call f() with
      % one output argument.
      n = 1;
      
   catch exception
       % Check errorIDS for too many outputs and for scripts
       if any(strcmp(exception.identifier,{'MATLAB:TooManyOutputs','MATLAB:maxlhs'}))          
           % If we get here, assume it's because f() has zero output arguments.
           n = 0;
       else
           rethrow(exception);
       end
   end
end