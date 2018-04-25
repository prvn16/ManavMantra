%PARFOR Execute for loop in parallel on workers in parallel pool
%   The general form of a PARFOR statement is:  
%
%       PARFOR loopvar = initval:endval
%           <statements>
%       END 
% 
%   MATLAB executes the loop body denoted by STATEMENTS for a vector of 
%   iterations specified by INITVAL and ENDVAL.  If you have Parallel 
%   Computing Toolbox, the iterations of STATEMENTS can execute on a parallel
%   pool of workers on your multi-core computer or computer cluster.  
%   PARFOR differs from a traditional FOR loop in the following ways:
%
%     Iterations must be monotonically increasing integer values
%     Order in which the loop iterations are executed is not guaranteed  
%     Restrictions apply to the STATEMENTS in the loop body   
%   
%   PARFOR (loopvar = initval:endval, M); <statements>; END uses M to
%   specify the maximum number of workers in the parallel pool that will
%   evaluate STATEMENTS in the loop body.  M must be a nonnegative integer.
%   By default, MATLAB uses as many workers as it finds available.  When 
%   there are no workers available in the pool or M is zero, MATLAB will 
%   still execute the loop body in an iteration independent order but not
%   in parallel.  
%
%   In order to execute the iterations in parallel, a parallel pool of 
%   workers must exist. A parallel pool will be created automatically when 
%   PARFOR is executed (by default; this can be changed in Settings). A 
%   parallel pool can also be created manually using PARPOOL. PARPOOL is 
%   available with Parallel Computing Toolbox.  
%   
%   EXAMPLE
% 
%   Break three large eigenvalue computations across three computers or
%   cores:
% 	 
%       parfor i = 1:3
%           c(:,i) = eig(rand(1000));
%       end
%     
%   See also for, parpool, parallel.Pool, gcp

% Copyright 2008-2013 The MathWorks, Inc.
% Built-in function.
