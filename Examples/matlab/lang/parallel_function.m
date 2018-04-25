function varargout = parallel_function(range, F, consume, supply, ...
                                       reduce, identity, concat, empty, ...
                                       M, divide, next_divide)
%PARALLEL_FUNCTION
%   This is the basis of parfor, but is not officially supported, either with
%   this name or API.

%   Copyright 1984-2017 The MathWorks, Inc.

% The following is a help-style description of parallel_function.

%PARALLEL_FUNCTION runs a function in parallel and consumes/reduces the results.
%   PARALLEL_FUNCTION(RANGE, F) takes RANGE and a function handle F.  RANGE must
%   be a two-element row vector of integers which we'll call BASE and LIMIT.
%   These specify a semi-open interval (BASE,LIMIT].  If BASE >= LIMIT, nothing
%   happens because the interval is empty.  Otherwise, let N denote LIMIT-BASE,
%   i.e., the interval includes N integers.  PARALLEL_FUNCTION chooses k-1
%   intermediate points BASE < N_1 < ... < N_{k-1} < LIMIT, effectively dividing
%   the interval into k segments.  (Control over choosing k and the N_j will be
%   discussed below.)  We will use the convention that N_0 = BASE and
%   N_k = LIMIT.  Independently of k and the intermediate N_j, (0,N] is the
%   union of the subintervals (N_0,N_1],...,(N_{k-1},N_k].   PARALLEL_FUNCTION's
%   essence:
%
%     * In parallel, evaluate F(N_{j-1},N_j) in "worker" processes, j = 1,...,k.
%
%   The process on which PARALLEL_FUNCTION is called the "client".
%
%   Because the choice of intermediate points is non-deterministic,
%   PARALLEL_FUNCTION will be non-deterministic unless F obeys the rule that the
%   following statement sequences are equivalent:
%
%     * F(N_{j-1}, N_j) % process a subinterval
%       F(N_j, N_{j+1}) % process the next subinterval
%
%     * F(N_{j-1}, N_{j+1}) % process the combined subintervals
%
%   Because the order of processing is non-deterministic, PARALLEL_FUNCTION will
%   be non-deterministic unless F obeys the rule that for any j1 and j2, these
%   are equivalent:
%
%     * F(N_{j1-1}, N_j1); F(N_{j2-1}, N_j2); % process j1 first
%
%     * F(N_{j2-1}, N_j2); F(N_{j1-1}, N_j1); % process j2 first
%
%   Actually, the requirement is stronger than this: the two statements here
%   must not interfere with one another's execution.  For example, if they are
%   both competing to write the same file, there will be trouble.  We will call
%   this the "non-interference" rule.
%
%   Not only N_{j-1} and N_j are sent from the client to the workers, but so is
%   the function handle F.  Handles to nested functions are particularly useful
%   as values of F, because the values in their workspace are sent along with F.
%   This is the standard way to communicate loop-invariant values to workers.
%
%   Note: PARALLEL_FUNCTION is the basis for PARFOR execution, and if PARFOR is
%   sufficient for your purposes, it is a more convenient interface to this
%   functionality.  PARFOR uses the nested function technique to transmit its
%   unsliced input variables.
%
%
%   PARALLEL_FUNCTION(RANGE, F, CONSUME) provides a way for workers to send
%   values back to the client.  If CONSUME is [], the behavior is as above, i.e,
%   F is evaluated with no expected results.  Otherwise, CONSUME must be a
%   function handle, and F must return a result.  Each worker does this:
%
%     * Evaluates O = F(N_{j-1}, N_j).
%
%     * Sends O to the client.
%
%   As each O is received, the client calls CONSUME(N_{j-1},N_j, O).
%
%   Because the choice of intermediate points is non-deterministic,
%   PARALLEL_FUNCTION will be non-deterministic unless F and consume obey the
%   rule that the following statement sequences are equivalent:
%
%     * O1 = F(N_{j-1}, N_j);      % process a subinterval
%       O2 = F(N_j, N_{j+1});      % process the next subinterval
%       CONSUME(N_{j-1}, N_j, O1)  % consume the first output
%       CONSUME(N_j, N_{j+1}, O2)  % consume the second output
%
%     * O = F(N_{j-1}, N_{j+1});     % process the combined subintervals
%       CONSUME(N_{j-1}, N_{j+1}, O) % consume the entire output
%
%   Because the order of processing is non-deterministic, PARALLEL_FUNCTION will
%   be non-deterministic unless F obeys the non-interference rule, extended for
%   outputs: for any distinct j1 and j2, the following may be executed
%   concurrently:
%
%     * O1 = F(N_{j1-1}, N_j1);
%
%     * O2 = F(N_{j2-1}, N_j2)
%
%   Calls on CONSUME occur in the client, and thus are serially executed.  Since
%   the order in which this happens is not guaranteed, PARALLEL_FUNCTION will be
%   non-deterministic unless CONSUME obeys the rule that for any j1 and j2, where
%   O1 and O2 arise as above, these are equivalent:
%
%     * CONSUME(N_{j1-1},N_j1, O1); CONSUME(N_{j2-1},N_j2, O2)
%
%     * CONSUME(N_{j2-1},N_j2, O2); CONSUME(N_{j1-1},N_j1, O1)
%
%   We say that CONSUME is "order-insensitive".
%
%   The final constraint comes from the observation that CONSUME runs on the
%   client and F on a worker, so there is an other form of the non-interference
%   requirement: for any distinct j1 and j2, the following may be executed
%   concurrently:
%
%     * O1 = F(N_{j1-1}, N_j1);
%
%     * CONSUME(N_{j2-1},N_j2, O2)
%
%   Note:  Even more so in this case, PARFOR is a convenient interface to this
%   functionality.  It uses CONSUME to implement its output sliced variables.
%
%
%   PARALLEL_FUNCTION(RANGE, F, CONSUME, SUPPLY) provides a way for the client
%   to send a worker a piece of data relevant only to its subinterval.  If
%   SUPPLY is [], the behavior is as above.  Otherwise, SUPPLY must be a
%   function handle (in practice, almost invariably to a nested function).
%   The client does the following:
%
%     * Evaluates I = SUPPLY(N_{j-1},N_j)
%
%     * Sends I to the worker along with N_{j-1} and N_j.
%
%   A worker evaluates F(N_{j-1}, N_j, I), with a result requested or not,
%   depending upon whether CONSUME is a function handle (as above).
%
%   Note: PARFOR uses SUPPLY for its sliced input variables.
%
%
%   R = PARALLEL_FUNCTION(RANGE, F, CONSUME, SUPPLY, REDUCE, IDENTITY)
%   A value of [] for REDUCE is ignored (same reason as for S), and will cause
%   IDENTITY to be ignored.  Otherwise, REDUCE must be a function handle and
%   IDENTITY must be present.  In this case, PARALLEL_FUNCTION returns a result,
%   computed as follows.  F is called in a worker with a "reduction" argument
%   and result (O is absent if CONSUME is [], and I is absent if SUPPLY is []):
%
%     * [O,Rout] = F(N_{j-1}, N_j, I, Rin);
%
%   For each call on PARALLEL_FUNCTION, the first time F is called in a worker,
%   Rin is IDENTITY.  On subsequent calls, Rin is the value of Rout on the
%   previous call.  As part of the termination of PARALLEL_FUNCTION, the client
%   informs each worker that there are no more subintervals.  In the presence of
%   REDUCE, a worker responds by transmitting its final value of Rout to the
%   client. Let the total number of workers be n, and denote the values of Rout
%   that the client sees be R1,...,Rn.  The client combines these value by
%   REDUCE, pairwise as the results come in, obtaining a final value R that
%   becomes the result of PARALLEL_FUNCTION.
%
%   Evidently, REDUCE must take two arguments and produce one result.  Because
%   the order in which it is called is non-deterministic, REDUCE and IDENTITY
%   should obey these laws:
%
%     * identity:    REDUCE(r, IDENTITY) = REDUCE(IDENTITY, r) = r
%
%     * commutative: REDUCE(r1,r2) = REDUCE(r2,r1)
%
%     * associative: REDUCE(r1,REDUCE(r2,r3)) = REDUCE(REDUCE(r1,r2),r3)
%
%   Further, because of the unpredictability of the particular N_j and how the
%   subintervals are sent to workers, the following statement sequences must
%   produce the same value for r:
%
%     * [O1, r1] = F(N_{j-1}, N_j, I, IDENTITY);  % done in one worker
%       [O2, r2] = F(N_j, N_{j+1}, I2, IDENTITY); % done in another worker
%       r = REDUCE(r1, r2);                       % combined in the client
%
%     * [O, r] = F(N_{j1-1}, N_j1, I1, IDENTITY); % done in one worker
%
%   REDUCE and F must also obey these laws:
%
%     * [O, r2] = F(N_{j-1}, N_j, I, r0); % start from arbitrary r0
%
%     * [O, r1] = F(N_{j-1}, N_j, I, IDENTITY); % start from IDENTITY
%       r2 = REDUCE(r0, r1);                    % combine with r0
%
%   A useful value of REDUCE is @plus, but there are others; see the PARFOR
%   documentation.  Also, note that for floating point numbers, @plus is only
%   approximately associative, so the errors introduced by it might vary from
%   run to run of the identical calls on PARALLEL_FUNCTION.
%
%   The server transmits the value of O to the client, as in the above cases.
%   For the first call on F in a server, the server simply hangs on to the value
%   of R.  In subsequent calls on F in the same server, the two values of R,
%   call them R1 and R2, are combined using REDUCE(R1, R2).  As part of
%   termination of the PARFOR loop in the worker, the final value of R is sent
%   to the client.
%
%   There is nothing you can do with REDUCE that cannot be done with CONSUME
%   alone.  However, the use of REDUCE can dramatically decrease communication
%   costs, because the size of its result may half the size of the sum of the
%   sizes of the inputs.
%
%
%   S = PARALLEL_FUNCTION(RANGE, F, CONSUME, SUPPLY, [], [], CONCAT, EMPTY)
%   [R, S] = PARALLEL_FUNCTION(RANGE, F, CONSUME, SUPPLY, REDUCE, IDENTITY,
%                              CONCAT, EMPTY)
%   CONCAT and EMPTY work in a way that is similar to REDUCE and IDENTITY,
%   except that CONCAT is not required to be commutative.  (The argument takes
%   its name from the fact that ordinary concatenation is associative but not
%   commutative.  Matrix multiply is another such function.)  CONCAT is given
%   arguments that come only from contiguous subintervals (N_{j-1},N_j] and
%   (N_j,N_{j+1}].  If CONCAT is non-empty, F is called in a worker with an
%   expected result, the we'll denote S, but unlike REDUCE, without a
%   corresponding input argument.
%
%     * [O, R, S] = F(N_{j-1}, N_j, I, R);
%
%   O is absent if CONSUME is [], I is absent if SUPPLY is [], and R is absent
%   (in both result and argument lists) if REDUCE is [].
%
%
%   ... = PARALLEL_FUNCTION(RANGE, F, CONSUME, SUPPLY, REDUCE, IDENTITY,
%                           CONCAT, EMPTY, M)
%   (Results are supplied by the whether REDUCE and CONCAT are empty, as above.)
%   The next argument is either a number M specifying the desired number of
%   workers.  The default value of M is inf, meaning "use as many workers as are
%   available, up to N."  If you specify M, it must be a positive integer or
%   inf.  PARALLEL_FUNCTION will try to reserve min(N,M) workers.  In the
%   subsequent discussion W will denote the number of workers actually reserved,
%   so W <= min(N,M) <= N.
%
%   In all cases, this argument, in combination with , determines a set of
%   workers for this invocation of PARALLEL_FUNCTION.  At the end of the
%   computation, all reserved workers are released.
%
%
%   ... = PARALLEL_FUNCTION(RANGE, F, CONSUME, SUPPLY, REDUCE, IDENTITY,
%                           CONCAT, EMPTY, M, DIVIDE)
%   (Results are supplied by the whether REDUCE and CONCAT are empty, as above.)
%   The role of DIVIDE is to choose N_1, N_2,... .  If DIVIDE is numeric, it
%   must be scalar and at least 1; call this value D.  In this case, the N_i
%   are chosen by dividing RANGE into k = min(N,D*W) pieces as uniformly as
%   possible.  (The requirement that D is at least one guarantees that
%   W <= k <= N.)  If the computation time for each call on F is closely
%   proportional to the size of the interval for the call, then the best value
%   of D is 1.  But if the times are uneven, then larger values are better---
%   they keep all the workers busy, at the cost of more communication.
%
%   If DIVIDE is not number, it must be a function handle.  If it takes one
%   argument (as determined by NARGIN), then PARALLEL_FUNCTION calls it as
%   follows:
%
%     * k = min(N, max(W, DIVIDE(N))); % again, note W <= k <= N.
%
%   As before, the N_i are chosen to divide (BASE,LIMIT] as evenly as possible
%   into k subintervals.
%
%   If DIVIDE takes two arguments, it is called as follows:
%
%     * k = min(N, max(W, DIVIDE(N, W))); % again, note W <= k <= N.
%
%   The result k is used as before.
%
%   If DIVIDE does not take one or two arguments, it must take three, in which
%   case PARALLEL_FUNCTION calls it as follows:
%
%     * NN = DIVIDE(BASE, LIMIT, W)
%
%       - NN is a row vector, where NN(j) plays the role of N_j above.  Thus,
%         elements of NN must be positive, strictly increasing, and between
%         BASE and LIMIT.  The length of NN must be at least W.  If
%         NN(end) == LIMIT, then NN completely partitions (BASE,LIMIT], or
%         equivalently, the length of NN is what we have denoted by k.  In this
%         case, DIVIDE is allowed to be the last argument.  Otherwise, the next
%         argument is required; see below.
%
%
%   ... = PARALLEL_FUNCTION(N, F, CONSUME, SUPPLY, REDUCE, IDENTITY,
%                           CONCAT, EMPTY, M, DIVIDE, NEXT_DIVIDE)
%   (Results are supplied by the whether REDUCE and CONCAT are empty, as above.)
%   The purpose of NEXT_DIVIDE is to allow you to write an adaptive scheduler.  It
%   must be a function handle, and is called only when DIVIDE (which is called
%   only once per invocation of PARALLEL_DIVIDE) and all previous calls of
%   NEXT_DIVIDE have not specified the partition all the way to N.  NEXT_DIVIDE
%   takes an argument that supplies a summary of the computation so far, which is
%   what allows it to be adaptive.
% 
%   The details are that PARALLEL_FUNCTION calls this argument as follows:
% 
%     * NN_EXT = NEXT_DIVIDE(PREV_N, N, L_EXT, HISTORY)
% 
%       - PREV_N is the endpoint of the last specified subinterval.
% 
%       - N is the same as usual, so the task is to divide up (PREV_N,N].
% 
%       - L_EXT specifies the minimum length of the result.  It is guaranteed that
%         N - PREV_N >= L_EXT.
% 
%       - HISTORY is a cell of length L (the number of workers), where HISTORY(j)
%         is a 3 column array with one row for each subinterval sent to server j.
%         The first two columns are the endpoints of the interval, and the third
%         column is the time spent processing that subinterval, or zero it has
%         not yet finished.
% 
%       - NN_EXT must be an extension to the partition specified so far.  It must
%         be a non-empty row vector of length at least L_EXT, where
%         PREV_N < NN_EXT(1), elements are strictly increasing, and
%         NN_EXT(end) <= N.  There will be no more calls on NEXT_DIVIDE if and
%         only if NN_EXT(end) == N.
% 
% 
%   [...,HISTORY] = PARALLEL_FUNCTION(N, F, CONSUME, ...)  The HISTORY result has
%   (The "..." results are supplied by the whether REDUCE and CONCAT are empty, as
%   above.)  The same structure as the HISTORY argument to NEXT_DIVIDE, except
%   that none of the time entries (in the third columns) will be zero, because all
%   computations have been finished.

% Indicate that we are entering this function
matlab.internal.incrementParallelFunctionDepth(1);
cleanupObject = onCleanup( @() matlab.internal.incrementParallelFunctionDepth(-1) );

if nargin < 2
    error(message('MATLAB:parfor:ArgumentMissing'))
end
% Validate range
if ~isequal(size(range), [1 2]) || ~isnumeric(range)
    error(message('MATLAB:parfor:InvalidArgumentRANGE'))
end
base = range(1)-1;
limit = range(2);
% Validate base and limit
if ~isreal(base) || ~isreal(limit)
    error(message('MATLAB:parfor:InvalidArgumentReal'))
end
if base ~= round(base) || limit ~= round(limit)
    error(message('MATLAB:parfor:InvalidArgumentInteger'))
end
N = double(limit - base); % Allows arbitrary arithmetic functions of N
% Validate F
if ~isa(F, 'function_handle')
    error(message('MATLAB:parfor:InvalidArgumentF'));
end
% The empty/function-handle status of consume, supply, and reduce is encoded in a single
% integer consume_supply_reduce as bit vector with mask bits:
consume_bit = 1;
supply_bit  = 2;
reduce_bit  = 4;
concat_bit  = 8;

consume_supply_reduce_concat = 0;
% Validate consume
if nargin >= 3 && ~isempty(consume)
    if ~isa(consume, 'function_handle')
        error(message('MATLAB:parfor:InvalidArgument', 'CONSUME'));
    end
    consume_supply_reduce_concat = consume_supply_reduce_concat + consume_bit;
end
% Validate supply
if nargin >= 4 && ~isempty(supply)
    if ~isa(supply, 'function_handle')
        error(message('MATLAB:parfor:InvalidArgument', 'SUPPLY'));
    end
    consume_supply_reduce_concat = consume_supply_reduce_concat + supply_bit;
end
% Validate reduce and identity
if nargin >= 5 && ~isempty(reduce)
    if ~isa(reduce, 'function_handle')
        error(message('MATLAB:parfor:InvalidArgument', 'REDUCE'));
    end
    if nargin == 5
        error(message('MATLAB:parfor:ArgumentNotSupplied', 'REDUCE', 'IDENTITY'))
    end
    R = identity;
    consume_supply_reduce_concat = consume_supply_reduce_concat + reduce_bit;
else
    reduce = [];   % solely for the ...
    identity =  0; % ... benefit of ...
    R = identity;  % ... distributed_execution.
end
% Validate concat and empty
if nargin >= 7 && ~isempty(concat)
    if ~isa(concat, 'function_handle')
        error(message('MATLAB:parfor:InvalidArgument', 'CONCAT'));
    end
    if nargin == 7
        error(message('MATLAB:parfor:ArgumentNotSupplied', 'CONCAT', 'EMPTY'))
    end
    S = empty;
    consume_supply_reduce_concat = consume_supply_reduce_concat + concat_bit;
    concatenator = online_concatenator(concat, empty);
else
    empty = []; % solely for the benefit of empty loops.
    concatenator = []; % solely for the benefit of distributed_execution
end
% Validate M
if nargin >= 9
    % This still omits the case when M is an MUE vector.
    if isequal(M, 'debug')
        M = max(1, floor(log2(N)));
        debug = true;
    elseif isnumeric(M) && isscalar(M) && M == round(M) &&  M >= 0
        M = double(M);
        debug = false;
    else
        error(message('MATLAB:parfor:InvalidArgumentM'))
    end
else
    M = Inf;
    debug = false;
end
% The number of workers.
W = min(M, N); % no point in having more workers than the range needs
% Validate nargout
if nargout > 3
    error(message('MATLAB:parfor:InvalidOutputArgument'))
elseif nargout > 2 ...
        && (bitand(consume_supply_reduce_concat, reduce_bit) == 0 ...
            || bitand(consume_supply_reduce_concat, concat_bit) == 0)
    error(message('MATLAB:parfor:InvalidArgsForThreeOutputs'));
elseif nargout > 1 ...
        && bitand(consume_supply_reduce_concat, reduce_bit) == 0 ...
        && bitand(consume_supply_reduce_concat, concat_bit) == 0
    error(message('MATLAB:parfor:InvalidArgsForTwoOutputs'))
end

if N <= 0
    S = empty;
    history = cell(1, 0); % needed by the next statement
    varargout = results(nargout);
    return
end
% If the number of workers requested is zero then even if DCT is installed
% and there is a parallel pool running we will still run the loop
% on the client.
runInPool = false;
isPoolAllowed = W > 0 && PCTInstalled;
if isPoolAllowed
    % tryremoteparfor must not move above the PCTInstalled check
    [isPoolRunning, pool] = distcomp.remoteparfor.tryRemoteParfor();
    runInPool = isPoolRunning;
end

if runInPool
    if logical(bitand(consume_supply_reduce_concat, reduce_bit))
        parfor_C = {consume_supply_reduce_concat, F, identity};
    else
        parfor_C = {consume_supply_reduce_concat, F};
    end
    try
        [P, W] = iMakeRemoteParfor(pool, W, parfor_C);
    catch E
        if strcmp( E.identifier, 'parallel:lang:parfor:IllegalComposite' )
            % In this case, we wish to abort parfor execution
            E2 = CatalogException(message('MATLAB:parfor:InvalidComposite'));
            E2 = addCause( E2, E );
            throwAsCaller( E2 );
        else
            % There are circumstances where we try to make a remoteparfor
            % controller and it throws an error (because it fails to acquire
            % the right resources for example). In that case we wish to fall
            % through to running locally
            warning(message('MATLAB:remoteparfor:ParforRunningLocally', E.getReport));
            P = [];
        end
    end
else
    P = [];
end
% The code below is the short-circuit code to run the parfor on the local
% machine as fast as possible. The range is not divided up, it is simply
% run as a single interval.
if isempty(P) && (~debug || W <= 1) % do everything on the client
    feval('_workspace_transparency',1)
    try
        time1 = tic;
        switch consume_supply_reduce_concat
          case 0
            F(base, limit);
          case 1
            consume(base, limit, F(base, limit));
          case 2
            F(base, limit, supply(base, limit));
          case 3
            consume(base, limit, F(base, limit, supply(base, limit)));
          case 4
            R = F(base, limit, identity);
          case 5
            [O, R] = F(base, limit, identity);
            consume(base, limit, O);
          case 6
            R = F(base, limit, supply(base, limit), identity);
          case 7
            [O, R] = F(base, limit, supply(base, limit), identity);
            consume(base, limit, O);
          case 8
            S = F(base, limit);
          case 9
            [O, S] = F(base, limit);
            consume(base, limit, O);
          case 10
            S = F(base, limit, supply(base, limit));
          case 11
            [O, S] = F(base, limit, supply(base, limit));
            consume(base, limit, O);
          case 12
            [R, S] = F(base, limit, identity);
          case 13
            [O, R, S] = F(base, limit, identity);
            consume(base, limit, O);
          case 14
            [R, S] = F(base, limit, supply(base, limit), identity);
          case 15
            [O, R, S] = F(base, limit, supply(base, limit), identity);
            consume(base, limit, O);
        end
        % Without the following, destroying this workspace asserts.
        feval('_workspace_transparency',0)
        history =  {[base, limit, toc(time1)]}; % need by the next statement
    catch E % work around bug in cleaning up this workspace
        feval('_workspace_transparency',0)
        throwAsCaller(iBuildLocalParallelException(E));
    end
    varargout = results(nargout);
    return
end

% If we get here without something to run our parfor on (P) then we will
% make a localparfor "object" to run on (NOTE this is actually a struct to 
% nested function handles)
if isempty(P)
    if logical(bitand(consume_supply_reduce_concat, reduce_bit))
        parfor_C = {consume_supply_reduce_concat, F, identity};
    else
        parfor_C = {consume_supply_reduce_concat, F};
    end
    P = localparfor(W, @make_channel, parfor_C);
end

% Validate divide and next_divide after call to run locally as this isn't used in the local case
if nargin >= 10 && ~isempty(divide)
    if isequal(divide, 'debug')
        divide = divide_uniform(@(N, W) max(W, round(N/floor(sqrt(N)))));
    elseif isnumeric(divide)
        if ~isscalar(divide) || divide < 1 || isnan(divide)
            error(message('MATLAB:parfor:InvalidArgumentNumericDIVIDE'))
        end
        divide = divide_uniform(@(N, W) min(N, double(divide)*W));
    elseif isa(divide, 'function_handle')
        switch nargin(divide)
          case 1
            divide = divide_uniform_min_max(@(N, W) divide(N));
          case 2
            divide = divide_uniform_min_max(divide);
          case 3
            % Use divide as it came in.
          otherwise
            error(message('MATLAB:parfor:InvalidArgumentFHandleDIVIDE'))
        end
    else
        error(message('MATLAB:parfor:InvalidArgumentDIVIDE'));
    end
else
    % Defer to the remote implementation to choose the division strategy.
    divide = P.getDivisionFcn();
end
% Validate next_divide
if nargin >= 11 && ~isempty(next_divide)
    if ~isa(next_divide, 'function_handle')
        error(message('MATLAB:parfor:InvalidArgument', 'NEXT_DIVIDE'));
    end
end

% The partition:
NN = divide(base, limit, W); % index by j to get the jth limit
k =  length(NN);
if k < W
    error(message('MATLAB:parfor:DivideLengthIncorrect'))
end
NN0 = [base, NN(1:k-1)];     % index by j to get the jth base
if ~all(NN0 < NN) || NN(k) > limit
    error(message('MATLAB:parfor:DivideNotIncreasing'))
end

% The history:
history = cell(1,W);
for j = 1:W
    history{j} = zeros(0,3); % initialize to correct size
end

% If we are using a pool, then we should try to do dependency analysis
% on the function if it can't be found on the worker and then re-run
% the code.
attachFilesAndRetryOnError = runInPool;
while true
    try
        R = distributed_execution(...
            P, base, limit, W, k, NN, NN0, consume, supply, ...
            reduce, R, concatenator, ...
            consume_supply_reduce_concat, ...
            consume_bit, supply_bit, reduce_bit, concat_bit);
        break;
    catch err
        if isequal(err.identifier, 'parallel:lang:pool:WorkerAborted')
            % Lost a worker - warn, and try again
            warning(message('MATLAB:remoteparfor:ParforWorkerAborted'));
            % Create a new remoteparfor to rerun the parfor
            try
                [P, W] = iMakeRemoteParfor(pool, W, parfor_C);
                E = [];
            catch E
            end
            if ~isempty(E) || W == 0
                error(message('MATLAB:remoteparfor:AllParforWorkersAborted'));
            end

            dctSchedulerMessage(6, 'Rerunning distributed_execution after worker crash.');
        else
            if ~isa(err, 'ParallelException')
                err = iBuildLocalParallelException(err);
            end
            [err, possibleSourceFiles] = iMaybeTransformMissingSourceException(err, F);
            if isempty(possibleSourceFiles) || ~attachFilesAndRetryOnError
                throwAsCaller(err);
            end
            
            % Only try to do the dependency analysis once
            attachFilesAndRetryOnError = false;
            try
                filesAttached = parallel.internal.pool.attachDependentFilesToPool(pool, possibleSourceFiles);
                if ~filesAttached
                    throw(err);
                end
                % Create a new remoteparfor to rerun the parfor
                [P, W] = iMakeRemoteParfor(pool, W, parfor_C);
                dctSchedulerMessage(6, 'Rerunning distributed_execution after attaching files.');
            catch attachErr
                % We'll just throw the exceptions that we built above if the
                % dependency analysis goes wrong.
                throwAsCaller(err);
            end
        end
    end
end

history = {}; % no timing in distributed land for now.
if bitand(consume_supply_reduce_concat, concat_bit) ~= 0
    S = concatenator.final();
end
varargout = results(nargout);

    % Provides the varargout value for parallel_function
    function C = results(nresults)
    if bitand(consume_supply_reduce_concat, reduce_bit) ~= 0 % always result R in this case
        if bitand(consume_supply_reduce_concat, concat_bit) ~= 0
            if nresults == 3
                C = {R, S, history};
            elseif nresults == 2
                C = {R, S};
            else
                C = {R};
            end
        elseif nresults == 2
            C = {R, history};
        else
            C = {R};
        end
    elseif bitand(consume_supply_reduce_concat, concat_bit) ~= 0 % always result S in this case
        if nresults == 2
            C = {S, history};
        else
            C = {S};
        end
    elseif nresults == 1
        C = {history};
    else
        C = {};
    end
    end

end

%----------------------------------------------------------------------------
%
%----------------------------------------------------------------------------
function d = divide_uniform(f)
    d = @div;
    function NN = div(base, limit, W)
        N = limit - base;
        k = f(N, W);
        NN = base + round((1:k)*N/k);
    end
end

function d = divide_uniform_min_max(f)
    d = divide_uniform(@(N, W) min(N, max(W, f(N, W))));
end

function d = divide_harmonic(f)
    function NN = div(base, limit, W)
        N = limit - base;
        W = f(N, W);
        % Iterate for the while loop
        i = 0;
        % Minimum chunk size such that there are no more than 10*W iterates.
        minChunk = max(ceil(N/(10*W)), 1);
        maxChunk = max(ceil(N/(1.5*W)), 1);
        curr = 0;
        % Output size guess - heuristic - assert that N>0 & W>0
        outputSize = ceil(10*W);
        % Allocate output array - ensure that it is the correct class
        NN = zeros(1, outputSize, 'like', base);
        while curr < N
            i = i+1;
            curr = curr + min(max(ceil((N - curr)/W), minChunk), maxChunk);
            NN(i) = curr;
        end
        % Force end point to be N as required - NOTE NN(i-1) is
        % necessarily less than N by the loop condition so we are able to
        % guarantee that NN is monotonically increasing.
        NN(i) = N;
        % And trim to expected output
        NN = base + NN(1:i);
    end
d = @div;
end

%----------------------------------------------------------------------------
%
%----------------------------------------------------------------------------
function R = distributed_execution(...
               P, base, limit, W, k, NN, NN0, consume, supply, ...
               reduce, R, concatenator, ...
               consume_supply_reduce_concat, ...
               consume_bit, supply_bit, reduce_bit, concat_bit)

% It is important that we make these logical as we are going to cast to
% double later an assume they are zero or one (bit of a hack but makes the
% code a little cleaner)
doConsume = logical(bitand(consume_supply_reduce_concat, consume_bit));
doSupply  = logical(bitand(consume_supply_reduce_concat, supply_bit));
doReduce  = logical(bitand(consume_supply_reduce_concat, reduce_bit));
doConcat  = logical(bitand(consume_supply_reduce_concat, concat_bit));

% As we will see, a channel here is a function handle, which is called
% as follows:
%   channel(distcompserialize({base, limit, I})) -- send the next subinterval
%     * I is omitted if supply is [].
%     * Unless consume is [], channel responds by yielding distcompserialize(O).
%   channel(distcompserialize({}))               -- tell the worker to close
%     * This yields no results.

totalReceived = 0; % total intervals received
% How many intervals to dispatch in one go - and receive in one go
normalDispatchSize  = W;
% Set up the first dispatch to be bigger to prime the queues, but don't
% exceed the number of intervals.
thisDispatchSize    = P.getInitialDispatchSize(k, W);

noLoopErrorDetected = true;
j = 0; % this indexes the subinterval
prev = base;
try
    % Loop whilst there is work to be done
    while prev < limit
        if noLoopErrorDetected
            for i = 1:thisDispatchSize
                j = j+1; % index of the next subinterval.
                next = NN(j);
                %             if j > k % ran out of subintervals
                %                 L_EXT = min(thisDispatchSize, limit - prev);
                %                 NN_EXT = next_divide(prev, limit, L_EXT, history);
                %                 k_ext = length(NN_EXT);
                %                 if k_ext < L_EXT
                %                     error('The result of NEXT_DIVIDE must have length at least L_EXT.')
                %                 end
                %                 NN0_EXT = [prev, NN_EXT(1:k_ext-1)];
                %                 if ~all(NN0_EXT < NN_EXT) || NN_EXT(k_ext) > limit
                %                     error('The result of NEXT_DIVIDE must be strictly increasing and between PREV_N and LIMIT.')
                %                 end
                %                 NN = [NN, NN_EXT];
                %                 NN0 = [NN0, NN0_EXT];
                %                 k = k + k_ext;
                %             end
                if doSupply
                    subinterval_C = {prev, next, supply(prev, next)};
                else
                    subinterval_C = {prev, next};
                end
                noLoopErrorDetected = P.addInterval(j, subinterval_C);
                prev = next;
                % Did we successfully add the interval - an error
                % might have occurred on a remote machine. Don't add
                % any more as there is an error that will be
                % thrown during getCompleteIntervals
                if ~noLoopErrorDetected, break, end
            end
        end
        % Setup for the next loop before getting the results
        thisDispatchSize = min(k-j, normalDispatchSize);
        % Get the results from the computation - remember that tag is an index
        % into the allLimits array
        [tags, out] = P.getCompleteIntervals(min(thisDispatchSize, j));
        totalReceived = totalReceived + numel(tags);
        % Now consume and/or concat the latest results.
        if doConsume || doConcat
            for i = 1:numel(tags)
                consume_reduce(tags(i), out{i});
            end
        end
    end
    % Number of intervals that need to be picked up for reduction
    numToReduce = 0;
    % Add the right number of final intervals
    for i = 1:W
        noLoopErrorDetected = P.addFinalInterval(j+i, {});
        if ~noLoopErrorDetected, break, end
        numToReduce = numToReduce + 1;
    end
    % Always drain the normal intervals but only wait for the reduce if needed
    numToReduce = numToReduce * double(doReduce);
    % Number of intervals that need to be picked up for consumption
    numToConsume = (j - totalReceived);
    % Define a maximum number to consume or reduce
    maxSize = round(W/floor(sqrt(W)));
    while numToConsume > 0 || numToReduce > 0
        % What chunk size should we take this time
        chunkSize = min(maxSize, max(numToConsume, numToReduce));
        % Get some of the remaining intervals
        [tags, out] = P.getCompleteIntervals(chunkSize);
        % Loop over these intervals doing the right thing
        for i = 1:numel(tags)
            thisTag = tags(i);
            % If we are consuming and this tag is a normal dispatch tag
            % then consume this interval and decrement the number to
            % consume
            if thisTag <= j
                if doConsume || doConcat
                    consume_reduce(thisTag, out{i});
                end
                numToConsume = numToConsume - 1;
            else
                % If we are reducing and this tag is a reduction then do the
                % reduction and decrement the number to reduce
                if doReduce
                    R = reduce(R, out{i});
                    numToReduce = numToReduce - 1;
                end
            end
        end
    end
catch err
    P.CaughtError = true;
    rethrow(err);
end
% Tell this remoteparfor that we have completed
P.complete();

    function consume_reduce(j, out)
        % Called only when doConsume || doConcat is true
        if doConsume
            if doConcat
                concatenator.concat(j, out{2})
                out = out{1};
            end
            consume(NN0(j), NN(j), out);
        else
            concatenator.concat(j, out)
        end
    end

end

%----------------------------------------------------------------------------
%
%----------------------------------------------------------------------------
function channel = make_channel(C)

consume_bit = 1;
reduce_bit  = 4;
concat_bit  = 8;

consume_supply_reduce_concat = C{1};
F = C{2};

% Need to know if we are doing consume or reduce to deal with the 
% number of output arguments from the channel function.
doConsume = bitand(consume_supply_reduce_concat, consume_bit);
doReduce  = bitand(consume_supply_reduce_concat, reduce_bit);
doConcat  = bitand(consume_supply_reduce_concat, concat_bit);

if numel(C) < 3
    R = [];
else
    R = C{3};
end
channel = make_general_channel(F, R, doConsume, doReduce, doConcat);

end

function channel = make_general_channel(F, R, doConsume, doReduce, doConcat)
    function O = channel_general(C)
        % Exit condition that sends back the reduce variable if requested
        if isempty(C) 
            O = R;
            return
        end
        % Otherwise we are calling F with the appropriate input and output
        % arguments
        feval('_workspace_transparency',1)
        if doConsume
            if doReduce
                if doConcat
                    [O, R, S] = F(C{:}, R);
                    O = {O, S}; % bundle S with O for shipping to client
                else
                    [O, R] = F(C{:}, R);
                end
            else
                if doConcat
                    [O, S] = F(C{:});
                    O = {O, S}; % bundle S with O for shipping to client
                else
                    O = F(C{:});
                end
            end
        else
            O = [];
            if doReduce
                if doConcat
                    [R, O] = F(C{:}, R); % ship "S" to client, so call it O
                else
                    R = F(C{:}, R);
                end
            else
                if doConcat
                    O = F(C{:}); % ship "S" to client, so call it O
                else
                    F(C{:});
                end
            end
        end
    end
    channel = @channel_general;
end

%----------------------------------------------------------------------------
% Function to check whether or not PCT is installed
%----------------------------------------------------------------------------
function OK = PCTInstalled
persistent PCT_INSTALLED
if isempty(PCT_INSTALLED)
    % See if we have the correct code to try this
    PCT_INSTALLED = logical(exist('com.mathworks.toolbox.distcomp.pmode.SessionFactory', 'class')) && ...
        exist('distcompserialize', 'file') == 3; % 3 == MEX
end
OK = PCT_INSTALLED;
end

function OK = PCTLicensed
% See if we are able to checkout a PCT license - otherwise calling the mex
% serialization and deserialization functions will error. Also wrap this is
% an evalc so that a license checkout failure is NOT seen
OK = license('test', 'Distrib_Computing_Toolbox');
end


%----------------------------------------------------------------------------
% Implementation of localparfor - this is intended to be a local
% approximation to the job of distcomp.remoteparfor, ParforControllerImpl
% and remoteParallelFunction. Most of the code here is stolen from the
% distcomp.remoteparfor and remoteParallelFunction.
%----------------------------------------------------------------------------
function P = localparfor(W, varargin)
P = struct('addInterval', @nAddInterval, ...
    'addFinalInterval', @nAddFinalInterval, ...
    'getCompleteIntervals', @nGetCompleteIntervals, ...
    'getDivisionFcn', @() divide_harmonic(@(N, W) W), ...
    'getInitialDispatchSize', @(k, W) k, ...
    'complete', @()[]); % 'complete' does nothing for local execution.
% Hold the channels in a cell array
channels = cell(W, 1);
% Define the current channel index to use;
currentChannelIndex = 1;
% Do we want to try serialization
if PCTInstalled && PCTLicensed
    send = @serialize;
else
    send = @noserialize;
end
% Hold the input arguments that will be used to construct the channel
init = varargin;
% This queue will hold the list of intervals to do - we will fill it up
% from the addInterval and addFinalInterval methods
pendingQueue = cell(0, 2);
% How many final intervals have been added
numFinalIntervals = 0;

    function OK = nAddInterval(tag, varargin)
        OK = true;
        % Add this interval to the queue
        pendingQueue(end+1, :) = {tag varargin};
    end

    function OK = nAddFinalInterval(tag, varargin)
        % test we don't get more than W final intervals.
        numFinalIntervals = numFinalIntervals + 1;
        if numFinalIntervals > W
            error(message('MATLAB:localparfor:TooManyFinalIntervals', numFinalIntervals, W));  
        end
        OK = nAddInterval(tag, varargin{:});
    end

    function [tags, results] = nGetCompleteIntervals(numIntervals)
        % Pre-allocate the output from the function        
        results = cell(numIntervals, 1);
        tags = ones(numIntervals, 1);
        % Loop over the requested intervals
        for i = 1:numIntervals
            % First make the channel if it doesn't exists - this ensures
            % that any error during channel construction is thrown in
            % getCompleteIntervals as it would do in a true distributed
            % parfor.
            if isempty(channels{currentChannelIndex})
                C = send(init);
                channels{currentChannelIndex} = feval(C{1}, C{2:end});
            end
            % Get the first item from the stack of pending intervals
            [tags(i), data] = deal(pendingQueue{1, :});
            % Remove it
            pendingQueue(1, :) = [];            
            % Send to the channel, evaluate and send back
            channelArg = send(data);
            try
                channelOut = feval(channels{currentChannelIndex}, channelArg{:});
            catch err
                ex = iBuildLocalParallelException(send(err));
                throw(ex);
            end
            results{i} = send(channelOut);
            % Make sure we use the next available channel for the next
            % interval
            currentChannelIndex = mod(currentChannelIndex, W) + 1;
        end
    end
end

function x = noserialize(x)
end

function x = serialize(x)
bufH = distcompMakeByteBufferHandle( distcompserialize( x ) );
x = distcompdeserialize(distcompByteBuffer2MxArray( bufH.get ));
bufH.free;
end

% ------------------------------------------------
function me = CatalogException(message)
% Helper function for MException

me = MException(message.Identifier, '%s', message.getString);

end

function newEx = iBuildLocalParallelException(originalErr)
% Create a new exception that stitches together the client and worker stack
% but that doesn't include this file in the stack.
newEx = ParallelException.hBuildLocalParallelException(originalErr, mfilename);
end

function [P, W] = iMakeRemoteParfor(pool, W, parfor_C)
P = distcomp.remoteparfor(pool, W, @make_channel, parfor_C);
W = P.NumWorkers; % revise for actual number obtained
end


function [err, possibleSourceFiles] = iMaybeTransformMissingSourceException(oldErr, evaluatedFcn)
possibleSourceFiles = {};
% Get the function that was actually run in the parfor
info = functions(evaluatedFcn);
dctSchedulerMessage(6, 'About to analyze the evaluated function');
if isdeployed
    % We cannot use info.file when deployed because this
    % refers to a file in the ctfroot that is not
    % recognized by 'requirements'. Instead, we strip the
    % path back to just the filename which will be
    % recognized. See g1139560 and g1103807.
    [~, filename] = fileparts( info.file );
    fhFile = filename;
else
    fhFile = info.file;
end
dctSchedulerMessage(6, 'File for evaluated function: %s', fhFile);
if strcmp(oldErr.identifier, 'parallel:lang:parfor:SourceCodeNotAvailable');
    err = ParallelException.hCloneWithNewMessage(oldErr, ...
            'MATLAB:parfor:SourceCodeNotAvailable', fhFile);
    err = err.addCause(oldErr.remotecause{1});
    possibleSourceFiles = fhFile;
elseif strcmp(oldErr.identifier, 'MATLAB:UndefinedFunction')
    if isempty(oldErr.remotecause{1}.arguments)
        possibleSourceFiles = fhFile;
        err = oldErr;
    else
        undefinedFunction = oldErr.remotecause{1}.arguments{1};
        err = ParallelException.hCloneWithNewMessage(oldErr, ...
                'MATLAB:parfor:UndefinedFunctionOnWorker', undefinedFunction, undefinedFunction);
        err = err.addCause(oldErr.remotecause{1});    
        possibleSourceFiles = {fhFile, undefinedFunction};
    end
else
        err = oldErr;
end
end
