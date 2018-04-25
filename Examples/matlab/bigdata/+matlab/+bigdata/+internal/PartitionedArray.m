%PartitionedArray
% An array that has been partitioned in the tall dimension.
%
% A PartitionedArray consists of N partitions [p1;p2;...;pN]. Each partition
% can exist within a different MATLAB Context and so provides a way to
% achieve parallelism. Each partition has the same size in non-tall
% dimensions and type. PartitionedArray exposes several methods that allow
% the caller to manipulate the underlying data in these partitions.
%
% PartitionedArray methods:
%   GATHER            - Return the underlying data for one or more PartitionedArray instances.
%
% PartitionedArray basic methods:
%   ELEMENTFUN        - Apply an element-wise function handle that preserves size in all dimensions to the underlying data.
%   SLICEFUN          - Apply a given slice-wise function handle that preserves size in the tall dimension to the underlying data.
%   FILTERSLICES      - Remove slices from one or more PartitionedArray using a PartitionedArray column vector of logical values.
%   VERTCATPARTITIONS - Vertically concatenate the list of partitions for each input.
%
% PartitionedArray reduce methods:
%   REDUCEFUN         - Perform a reduction of the underlying data.
%   REDUCEBYKEYFUN    - For each unique key, perform a reducefun reduction of all of the data associated with that key.
%   AGGREGATEFUN      - Perform a reduction of the underlying data that includes an initial transformation step.
%   AGGREGATEBYKEYFUN - For each unique key, perform a aggregatefun reduction of all of the data associated with that key.
%
% PartitionedArray join methods:
%   JOINBYKEY         - Perform an inner join of two sets of PartitionedArray instances using keys common to both.
%
% PartitionedArray conditional methods:
%   TERNARYFUN        - Select between one of two input arrays based on a deferred logical scalar.
%
% PartitionedArray advanced methods:
%   CHUNKFUN                 - Apply a given chunk-wise function handle to the underlying data.
%   PARTITIONFUN             - For each partition, apply a function handle to all of the underlying data for the partition.
%   ISPARTITIONINDEPENDENT   - Returns true if all underlying data is independent of the partitioning of the array.
%   MARKPARTITIONINDEPENDENT - Mark that the data underlying a PartitionedArray is independent of the partitioning of the PartitionedArray.
%   MARKFORREUSE             - Inform the Lazy Evaluation Framework that the given PartitionedArray will be reused multiple times.
%   ALIGNPARTITIONS          - Align the partitioning of one or more PartitionedArray instances.
%   CLIENTFOREACH            - Stream data back to the client MATLAB Context and
%                              perform an action per chunk inside the client
%                              MATLAB Context.
%
% These methods can opt-in to the following common rules:
%
%%% Chunk-wise function handle rules:
%  This rule dictates how a given function handle will be used to execute
%  the operation. It will be used by elementfun, slicefun, chunkfun,
%  aggregatefun and aggregatebykeyfun.
%
%  The function handle will be called with syntax:
%    [a,b,c,..] = functionHandle(x,y,..)
%
% Where:
%  - Each of inputs [x,y,..] will be a chunk from the respective input
%  PartitionedArray instances [tX,tY,..]. The following guarantees are
%  made:
%    - All of [x,y,..] will have the same size in the tall dimension as
%      each other after any allowed singleton expansion.
%    - Every one of [x,y,] that originates from a PartitionedArray
%    instance that is non-singleton in the tall dimension will originate
%    from the same index in the tall dimension.
%    - If any of [x,y,..] originates from a PartitionedArray instance that
%    is singleton in the tall dimension, it will consist of all of the
%    data from that PartitionedArray instance.
%
%  - Each of outputs [a,b,c,..] are required to be a chunk to be sent to
%  the respective output PartitionedArray instances [tA,tB,tC,..].
%    - All of [a,b,c,..] are required to have the same size in the tall
%    dimension as each other.
%    - All of [a,b,c,..] will be vertical concatenated with the
%    respective results of the previous calls to the function handle.
%    - All of [a,b,c,..] will be sent to the same index in the tall
%    dimension in their respective destination PartitionedArray instances.
%
%  - The function handle must ensure the following rule is satisfied:
%    - F([inputs1;inputs2]) == [F(inputs1);F(inputs2)];
%
% If this function handle is required to obey the same destination index
% as origin rule, there is the following two further requirements:
%    - The output must be the same size in the tall dimension as the input
%    after any allowed singleton expansion in the tall dimension.
%    - Each slice of the output must be generated from the slice of the
%    same index in the tall dimensions in the index.
%
% If a partition of the input PartitionedArray instances has no slices,
% the framework guarantees to call this function at least once for the
% partition. For this call, all input chunks will be an empty of the
% correct type and size in the non-tall dimensions. The output must also
% be the correct size and type as if the function had been given data.
%
%%% Reducing function handle rules
% This rule dictates how a given function handle will be used to execute
% the operation. It will be used by reducefun, aggregatefun,
% reducebykeyfun and aggregatebykeyfun.
%
% The function handle will be called with syntax:
%  [x,y,..] = functionHandle(x,y,..)
%
% Where:
%  - Each of the inputs [x,y,...] will be a chunk that originates either
%  from the respective PartitionedArray instances [tX,tY,..] or some
%  partially reduced output of this function handle. The following
%  guarantees are made:
%    - All of inputs [x,y,..] will have the same size in the tall dimension
%    as each other.
%    - For a given index in the tall dimension, every slice of input
%    [x,y,..] for that index will either all originate from the input
%    PartitionedArray instances, or they will all originate from the same
%    previous call to this function handle.
%    - For a given index in the tall dimension, every slice of input
%    [x,y,..] for that index will originate from the same index in the
%    tall dimension.
%
%  - Each of the outputs [x,y,..] is required to be a chunk that is
%  vertically concatenable with the respective input [x,y,..]. All outputs
%  [x,y,..] must have the same size in the tall dimension as each other.
%
%  - The function handle must follow the rules:
%    - F(in) == F(F(in))
%    - F([in1;in2]) == F([F(in1);F(in2)]) up-to rounding error.
%    - F([in1;in2]) == F([in2;in1]) up-to rounding error.
%
%  If a PartitionedArray is empty, the framework guarantees to call this
%  function at least once overall. For this call, all input chunks will be
%  an empty of the correct type and size in non-tall dimensions.
%
%%% General Input Rule
% For the given PartitionedArray methods that opts-in, this rule states
% that:
%   - All inputs relating to data must be compatible in the tall dimension.
%   - That a customer -visible will be issued if this is not the case.
%
% In detail, given a PartitionedArray method with signature:
% [..] = <..>fun(..,tX,tY,..)
%
% This rule requires that:
%  - Each of the inputs [tX,tY,..] must be either a PartitionedArray or
%  non-tall array.
%  - At least one of [tX,tY,..] must be a PartitionedArray.
%  - All of [tX,tY,..] must have the same size in the tall dimension, after
%  singleton expansion in the tall dimension if it is allowed.
%
%%% Concatenated Output Rule
% For the given PartitionedArray methods that opts-in, this rule states
% that the PartitionedArray outputs will consist of the vertical
% concatenation of all data generated by the action.
%
% Specifically:
%   - Each of the outputs [tA,tB,tC,..] will be a PartitionedArray of the
%   same size in the tall dimension and partitioning.
%   - The outputs [tA,tB,tC,..] will be created by vertical concatenation
%   of all data outputted from the respective function handle.
%
%%% Same destination index as origin rule
% For the given PartitionedArray methods that opts-in, this rule states
% that every slice of the output will correspond with the slice of same
% index in the tall dimension as the input.
%
% In detail, given a PartitionedArray method with syntax:
%   -[tA,tB,tC,..] = <..>fun(..,tX,tY,..);
%
% Then for all ii = 1:numSlices, the rule guarantees that slice tA(ii,:,..)
% has been generated only from [tX(ii,:,..),tY(ii,:,..),..]. The same is
% true for tB and tC.
%

%   Copyright 2015-2017 The MathWorks, Inc.

classdef (Abstract, InferiorClasses = { ...
        ?matlab.bigdata.internal.BroadcastArray, ...
        ?matlab.bigdata.internal.FunctionHandle, ...
        ?matlab.bigdata.internal.LocalArray, ...
        ?matlab.bigdata.internal.PartitionedArrayOptions}) ...
        PartitionedArray < handle
    
    properties (Constant)
        % The dimension that corresponds with the tallness property of the
        % underlying data.
        TallDimension = 1;
    end
    
    methods (Abstract)
        %GATHER Return the underlying data for one or more PartitionedArray instances.
        %
        % This will launch all remaining necessary evaluations and block
        % until this is done.
        %
        % Syntax:
        %  [X,Y,..] = gather(tX,tY,..)
        %
        % Inputs:
        %  - Each of [tX,tY,..] must be a PartitionedArray instance.
        %
        % Outputs:
        %  - Each of [X,Y,..] is the underlying data of [tX,tY,..]
        %  respectively.
        %
        % Error Conditions:
        %  - If an error occurs during the evaluation of any of [tX,tY,..],
        %  a user visible error will be issued. This will consist of the
        %  debug information necessary for the user to know where the error
        %  originates from.
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %
        %  X = rand(1000,4,1);
        %  tX = LazyPartitionedArray.createFromConstant(X);
        %
        %  % gX is equal to X.
        %  gX = gather(tX);
        %
        varargout = gather(varargin)
        
        %ELEMENTFUN Apply an element-wise function handle that preserves size in all dimensions to the underlying data.
        %
        % Syntax:
        %  [tA,tB,tC,..] = elementfun(functionHandle,tX,tY,..)
        %  [tA,tB,tC,..] = elementfun(options,functionHandle,tX,tY,..)
        %
        % Inputs:
        %  - functionHandle must be an element-wise function handle of type
        %  function_handle or matlab.bigdata.internal.FunctionHandle. It
        %  will be applied to the inputs [tX,tY,..] as per the chunk-wise
        %  function handle rules.
        %
        %  - Inputs [tX,tY,..] follow the general input rules with
        %  singleton expansion in all dimensions. In addition, all of
        %  [tX,tY,..] must have the same size in all dimensions after
        %  singleton expansion.
        %
        %  - options (optional) must be a PartitionedArrayOptions object.
        %  This can be used to specify RNG state and more.
        %
        % Outputs:
        %  - Outputs [tA,tB,tC,..] will be PartitionedArray instances that
        %  consist of the vertical concatenation of the outputs of
        %  functionHandle in accordance to the concatenated output rule.
        %  The outputs will also follow the same destination index as
        %  original rule, meaning all outputs will be co-partitioned and
        %  co-indexed in all dimensions with the inputs [tX,tY,..]. A
        %  consequence of these rules is that the output will be the same
        %  size as the input after singleton expansion. Every element of
        %  the output element is calculated only from the corresponding
        %  input element input.
        %
        % Error Conditions:
        %  - As part of the general input rules, if the inputs [tX,tY,..]
        %  do not have the same size in the tall dimension after singleton
        %  expansion, a customer visible error will be issued at the point
        %  this is known. This will either be immediate or at the time when
        %  evaluation occurs.
        %
        %  - Any error issued by the function handle will be returned back
        %  to the user from the function that triggered evaluation. This is
        %  likely to be the following gather.
        %
        % This method is conceptually equivalent to:
        %   [tA,tB,tC,..] = functionHandle(tX,tY,..)
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %
        %  % tX and tY have the same size in the tall dimension but require
        %  % singleton expansion in non-tall dimensions:
        %  tX = LazyPartitionedArray.createFromConstant(rand(1000,1,2));
        %  tY = LazyPartitionedArray.createFromConstant(rand(1000,3,1));
        %
        %  fun = @(a,b,c) cos(a + b + c) .^ 2;
        %
        %  % tA will have size 1000x3x2
        %  tA = elementfun(fun,tX,tY,pi/4);
        %
        varargout = elementfun(options, functionHandle, varargin);
        
        %SLICEFUN Apply a given slice-wise function handle that preserves size in the tall dimension to the underlying data.
        %
        % Syntax:
        %  [tA,tB,tC,..] = slicefun(functionHandle,tX,tY,..)
        %  [tA,tB,tC,..] = slicefun(options,functionHandle,tX,tY,..)
        %
        % Inputs:
        %  - functionHandle must be a slice-wise function handle of type
        %  function_handle or matlab.bigdata.internal.FunctionHandle. It
        %  will be applied to the inputs [tX,tY,..] as per the chunk-wise
        %  function handle rules.
        %
        %  - Inputs [tX,tY,..] follow the general input rules with
        %  singleton expansion in the tall dimension.
        %
        %  - options (optional) must be a PartitionedArrayOptions object.
        %  This can be used to specify RNG state and more.
        %
        % Outputs:
        %  - Outputs [tA,tB,tC,..] will be PartitionArray instances that
        %  consist of the vertical concatenation of the outputs of
        %  functionHandle in accordance to the concatenated output rule.
        %  The output will also follow the same destination index as
        %  origin rule, meaning all outputs will be co-partitioned and
        %  co-indexed in the tall dimensions with the inputs [tX,tY,..]].
        %
        % Error Conditions:
        %  - As part of the general input rules, if the inputs [tX,tY,..]
        %  do not have the same size in the tall dimension after singleton
        %  expansion, a customer visible error will be issued at the point
        %  this is known. This will either be immediate or the time when
        %  evaluation occurs.
        %
        %  - Any error issued by the function handle will be returned back
        %  to the user from the function that triggered evaluation. This is
        %  likely to be the following gather.
        %
        % This is conceptually equivalent to:
        %  [tA,tB,tC,..] = functionHandle(tX,tY,..)
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %
        %  % tX is a PartitionedArray of size 1000x10
        %  tX = LazyPartitionedArray.createFromConstant(rand(1000,10));
        %
        %  fun = @(x,c) sum(x.^c,2);
        %
        %  % tA will have size 1000x1
        %  tA = slicefun(fun,tX,4);
        %
        varargout = slicefun(options, functionHandle, varargin);
        
        %FILTERSLICES Remove slices from one or more PartitionedArray using a PartitionedArray column vector of logical values.
        %
        % Syntax:
        %  [tX2,tY2,..] = filterslices(tSubs,tX,tY,..)
        %
        % Inputs:
        %  - tSubs is a PartitionedArray column vector of logical values.
        %
        %  - Each of [tX,tY,..] is a PartitionedArray of the same size in
        %  the tall dimension as tSubs. All of [tSubs,tX,tY,..] follow the
        %  general input rules.
        %
        % Outputs:
        %  - Each of [tX2,tY2,..] is a PartitionedArray of the same size in
        %  the tall dimension and same partitioning as each other. Each
        %  consists of all the slices of [tX,tY,..] respectively for which
        %  the corresponding element of tSubs is true.
        %
        % Error Conditions:
        %  - If tSubs is not logical or a column vector, a customer visible
        %  error will be issued at the point this is known. This will
        %  either be immediate or at the time when the operation is
        %  actually evaluated.
        %
        %  - As part of the general input rules, if the inputs
        %  [tSubs,tX,tY,..] do not have the same size in the tall dimension
        %  after singleton expansion, a customer visible error will be
        %  issued at the point this is known. This will either be immediate
        %  or the time when evaluation occurs.
        %
        % This is conceptually equivalent to:
        %  tX2 = tX(tSubs,:,..)
        %  tY2 = tY(tSubs,:,..)
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %
        %  % tX and tY have size 1000x1 and 1000x10 respectively.
        %  tX = LazyPartitionedArray.createFromConstant((1:1000)');
        %  tY = LazyPartitionedArray.createFromConstant(rand(1000,10));
        %
        %  % tSubs is equivalent to [false(500,1); true(500,1)]
        %  tSubs = tX > 500;
        %
        %  % tX2 is equivalent to tX(501:1000)
        %  % tY2 is equivalent to tY(501:1000,:)
        %  [tX2,tY2] = filterslices(tSubs,tX,tY);
        %
        varargout = filterslices(subs, varargin);
        
        %VERTCATPARTITIONS Vertically concatenate the list of partitions for each input.
        %
        % Syntax:
        %  tOut = vertcatpartitions(tX,tY,..)
        %
        % Inputs:
        %  - Each of [tX,tY,..] is a PartitionedArray of the same type and
        %  size in non-tall dimension as each other.
        %
        % Outputs:
        %  - tOut is a PartitionedArray consisting of all the data from
        %  [tX,tY,..]. It will have the same size in non-tall dimension as
        %  each of [tX,tY,..]. It will contain exactly one partition for
        %  each partition across all of [tX,tY,..].
        %
        % Error Conditions:
        %  - If any of [tX,tY,..] do not have the same size in non-tall
        %  dimension as each other, a customer visible error will be issued
        %  at the point this is known. This will either be immediate or at
        %  the time when evaluation occurs.
        %
        % This is conceptually equivalent to:
        %  tOut = [tX;tY;..]
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %
        %  X = rand(200,10);
        %  tX = LazyPartitionedArray.createFromConstant(X);
        %
        %  Y = rand(200,10);
        %  tY = LazyPartitionedArray.createFromConstant(Y);
        %
        %  % tOut is equivalent to PartitionedArray([X;Y]) up-to
        %  partitioning.
        %  tOut = vertcatpartitions(tX,tY);
        %
        out = vertcatpartitions(varargin);
        
        %REDUCEFUN Perform a reduction of the underlying data.
        %
        % This will repeatedly call a given hierarchical reduce function
        % handle to eventually generate a single final chunk.
        %
        % Syntax:
        %  [rX,rY,..] = reducefun(functionHandle,tX,tY,..);
        %  [rX,rY,..] = reducefun(options,functionHandle,tX,tY,..);
        %
        % Inputs:
        %  - functionHandle must be a function handle of type
        %  function_handle or matlab.bigdata.internal.FunctionHandle. It
        %  will be applied to the inputs [tX,tY,..] as per the reducing
        %  function handle rules to generate [rX,rY,..].
        %
        %  - Inputs [tX,tY,..] follow the general input rules with
        %  no allowed singleton expansion.
        %
        %  - options (optional) must be a PartitionedArrayOptions object.
        %  This can be used to specify RNG state and more.
        %
        % Outputs:
        %  - Each of [rX,rY,..] is a PartitionedArray that corresponds with
        %  [tX,tY,..] respectively. All of [rX,rY,..] will be the output of
        %  the final call to functionHandle. This means each output will
        %  consist of only a single partition.
        %
        % Error Conditions:
        %  - As part of the general input rules, if the inputs [tX,tY,..]
        %  do not have the same size, a customer visible error will be
        %  issued at the point this is known. This will either be immediate
        %  or at the time when evaluation occurs.
        %
        %  - Any error issued by the function handle will be returned back
        %  to the user from the function that triggered evaluation. This is
        %  likely to be the following gather.
        %
        % This method is conceptually equivalent to the following, where
        % all final output fits in memory:
        %   [rX,rY,..] = functionHandle(tX,tY,..)
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %
        %  % tX is a PartitionedArray of size 1000x10
        %  tX = LazyPartitionedArray.createFromConstant(rand(1000,10));
        %
        %  fun = @(x) sum(x,1);
        %
        %  % rX will have size 1x10
        %  rX = reducefun(fun,tX);
        %
        varargout = reducefun(options, functionHandle, varargin);
        
        %AGGREGATEFUN Perform a reduction of the underlying data that includes an initial transformation step.
        %
        % This is equivalent to calling chunkfun followed by reducefun.
        %
        % Syntax:
        %  [rA,rB,rC,..] = aggregatefun(initialFunctionHandle,reduceFunctionHandle,tX,tY,..)
        %  [rA,rB,rC,..] = aggregatefun(options,initialFunctionHandle,reduceFunctionHandle,tX,tY,..)
        %
        % Inputs:
        %  - initialFunctionHandle must be a chunk-wise function handle of
        %  type function_handle or matlab.bigdata.internal.FunctionHandle.
        %  It will be applied to the inputs [tX,tY,..] as per the
        %  chunk-wise function handle rules to generate intermediate data.
        %
        %  - reduceFunctionHandle must be a function handle of type
        %  function_handle or matlab.bigdata.internal.FunctionHandle. It
        %  will be applied to the intermediate data as per the reducing
        %  function handle rules to generate [rX,rY,..].
        %
        %  - Inputs [tX,tY,..] follow the general input rules with
        %  singleton expansion in the tall dimension.
        %
        %  - options (optional) must be a PartitionedArrayOptions object.
        %  This can be used to specify RNG state and more.
        %
        % Outputs:
        %  - Each of [rA,rB,rC..] is a PartitionedArray. All of
        %  [rA,rB,rC,..] will be the output of the final call to reduceFun.
        %  This means each output will consist of only a single partition.
        %
        % Error Conditions:
        %  - As part of the general input rules, if the inputs [tX,tY,..]
        %  do not have the same size in the tall dimension after singleton
        %  expansion, a customer visible error will be issued at the point
        %  this is known. This will either be immediate or the time when
        %  evaluation occurs.
        %
        %  - Any error issued by the function handle will be returned back
        %  to the user from the function that triggered evaluation. This is
        %  likely to be the following gather.
        %
        % This method is conceptually equivalent to:
        %   [tA,tB,tC,..] = initialFunctionHandle(tX,tY,..)
        %   [rA,rB,rC,..] = reduceFunctionHandle(tA,tB,tC,..)
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %
        %  % tX is a PartitionedArray of size 1000x10
        %  tX = LazyPartitionedArray.createFromConstant(rand(1000,10));
        %
        %  initialFun = @(x) numel(x);
        %  reduceFun = @(x) sum(x,1);
        %
        %  % rX will have size 1x1
        %  rX = aggregatefun(initialFun,reduceFun,tX);
        %
        varargout = aggregatefun(options, initialFunctionHandle, reduceFunctionHandle, varargin);
        
        %REDUCEBYKEYFUN For each unique key, perform a reducefun reduction of all of the data associated with that key.
        %
        % Syntax:
        %  [rKeys,rX,rY,..] = reducebykeyfun(functionHandle,tKeys,tX,tY,..)
        %  [rKeys,rX,rY,..] = reducebykeyfun(options,functionHandle,tKeys,tX,tY,..)
        %
        % Inputs:
        %  - functionHandle must be a function handle of type
        %  function_handle or matlab.bigdata.internal.FunctionHandle. For
        %  each unique key in tKeys, this will be applied as per the
        %  reducing function handle rules to all slices of [tX,tY,..]
        %  associated with that key to generate one chunk of [rX,rY,..].
        %
        %  - tKeys is a column vector PartitionedArray.
        %
        %  - Each of [tX,tY,..] is a PartitionedArray of the same size in
        %  the tall dimension as tKeys. All of [tKeys,tX,tY,..] must follow
        %  the general input rules with no allowed singleton expansion.
        %
        %  - options (optional) must be a PartitionedArrayOptions object.
        %  This can be used to specify RNG state and more.
        %
        % Outputs:
        %  - rKeys will be a PartitionedArray column vector that consists
        %  of values from tKeys. The order of rKeys depends on the execution
        %  environment.
        %
        %  - Each of [rX,rY,..] will be a PartitionedArray that corresponds
        %  with [tX,tY,..] respectively. All of [rX,rY,..] will have the
        %  same size in the tall dimension and same partitioning as rKeys.
        %  The slices of each of [rX,rY,..] correspond with the slices of
        %  rKeys.
        %
        % Error Conditions:
        % - If tKeys is not a column vector, a customer visible error will
        %  be issued at the point this is known. This will either be
        %  immediate or at the time when evaluation occurs.
        %
        %  - As part of the general input rules, if the inputs [tX,tY,..]
        %  do not have the same size, a customer visible error will be
        %  issued at the point this is known. This will either be immediate
        %  or at the time when evaluation occurs.
        %
        %  - Any error issued by the function handle will be returned back
        %  to the user from the function that triggered evaluation. This is
        %  likely to be the following gather.
        %
        % This method is conceptually equivalent to:
        %   for key = unique(tKeys)
        %      idx = (key == tKeys)
        %      [tmpX,tmpY,..] = functionHandle(tX(idx,..), tY(idx,..),..);
        %      rX = [rX;tmpX];
        %      rY = [rY;tmpY];
        %   end
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %
        %  % tX is a PartitionedArray of size 1000x10
        %  tX = LazyPartitionedArray.createFromConstant(rand(1000,10));
        %
        %  % tBinIndices is a PartitionedArray of size 1000x1 consisting
        %  % of values 0,1,2,3
        %  numBins = 4;
        %  tBinIndices = LazyPartitionedArray.createFromConstant(mod(1:1000,4)');
        %
        %  fun = @(x) sum(x,1);
        %
        %  % rBinIndices will have size 4x1
        %  % rX will have size 4x10
        %  [rBinIndices,rX] = reducebykeyfun(fun,tBinIndices,tX);
        %
        [keys, varargout] = reducebykeyfun(options, functionHandle, keys, varargin);
        
        %AGGREGATEBYKEYFUN For each unique key, perform a aggregatefun reduction of all of the data associated with that key.
        %
        % Syntax:
        %  [rKeys,rA,rB,rC,..] = aggregatebykeyfun(initialFunctionHandle,...
        %                                          reduceFunctionHandle,...
        %                                          tKeys,tX,tY,..)
        %  [rKeys,rA,rB,rC,..] = aggregatebykeyfun(options,...
        %                                          initialFunctionHandle,...
        %                                          reduceFunctionHandle,...
        %                                          tKeys,tX,tY,..)
        %
        % Inputs:
        %  - initialFunctionHandle must be a chunk-wise function handle of
        %  type function_handle or matlab.bigdata.internal.FunctionHandle.
        %  For each unique key in tKeys, this will be applied as per the
        %  chunk-wise function handle rules to all slices of [tX,tY,..]
        %  associated with that key to generate intermediate data.
        %
        %  - reduceFunctionHandle must be a function handle of type
        %  function_handle or matlab.bigdata.internal.FunctionHandle. For
        %  each unique key in tKeys, this will be applied as per the
        %  reducing function handle rules to all slices of intermediate
        %  data associated with that key to generate one chunk of
        %  [rA,rB,rC,..].
        %
        %  - tKeys is a column vector PartitionedArray.
        %
        %  - Each of [tX,tY,..] is a PartitionedArray of the same size in
        %  the tall dimension as tKeys. All of [tKeys,tX,tY,..] must follow
        %  the general input rules with no allowed singleton expansion.
        %
        %  - options (optional) must be a PartitionedArrayOptions object.
        %  This can be used to specify RNG state and more.
        %
        % Outputs:
        %  - rKeys will be a PartitionedArray column vector that consists
        %  of values from tKeys. The order of rKeys depends on the execution
        %  environment.
        %
        %  - Each of [rA,rB,rC,..] will be a PartitionedArray. All of
        %  [rA,rB,rC,..] will have the same size in the tall dimension and
        %  same partitioning as rKeys. The slices of each of [rA,rB,rC,..]
        %  correspond with the slices of rKeys.
        %
        % Error Conditions:
        % - If tKeys is not a column vector, a customer visible error will
        %  be issued at the point this is known. This will either be
        %  immediate or at the time when evaluation occurs.
        %
        %  - As part of the general input rules, if the inputs [tX,tY,..]
        %  do not have the same size, a customer visible error will be
        %  issued at the point this is known. This will either be immediate
        %  or at the time when evaluation occurs.
        %
        %  - Any error issued by the function handle will be returned back
        %  to the user from the function that triggered evaluation. This is
        %  likely to be the following gather.
        %
        % This method is conceptually equivalent to:
        %   for key = unique(tKeys)
        %      idx = (key == tKeys)
        %      [tmpA,tmpB,tmpC,..] = initialFunctionHandle(tX(idx,..), tY(idx,..),..);
        %      [tmpA,tmpB,tmpC,..] = reduceFunctionHandle(tmpA,tmpB,tmpC,..);
        %      rA = [rA;tmpA];
        %      rB = [rB;tmpB];
        %      rC = [rC;tmpC];
        %   end
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %
        %  % tX is a PartitionedArray of size 1000x10
        %  tX = LazyPartitionedArray.createFromConstant(rand(1000,10));
        %
        %  % tBinIndices is a PartitionedArray of size 1000x1 consisting
        %  % of values 0,1,2,3
        %  numBins = 4;
        %  tBinIndices = LazyPartitionedArray.createFromConstant(mod(1:1000,4)');
        %
        %  initialFun = @(x) numel(x);
        %  reduceFun = @(x) sum(x,1);
        %
        %  % rBinIndices will have size 4x1
        %  % rX will have size 4x1
        %  [rBinIndices,rX] = aggregatebykeyfun(initialFun,reduceFun,tBinIndices,tX);
        %
        [keys, varargout] = aggregatebykeyfun(options, initialFunctionHandle, reduceFunctionHandle, keys, varargin);
        
        %JOINBYKEY Perform an inner join of two sets of PartitionedArray instances using keys common to both.
        %
        % Syntax:
        %  [tKeys,tX1,tY1] = joinbykey(tXKeys,tX1,tYKeys,tY1);
        %
        %  [tKeys,tX1,tY1,..] = joinbykey(tXKeys,{tX1,tX2,..},tYKeys,{tY1,tY2,..})
        %
        % Inputs:
        %  - tXKeys is a column vector PartitionedArray instance.
        %
        %  - Each of [tX1,tX2,..] is a PartitionedArray of the same size in
        %  the tall dimension as tXKeys. All of [tXKeys,tX1,tX2,..] must
        %  follow the general input rules with singleton expansion in the
        %  tall dimension.
        %
        %  - tYKeys is a column vector PartitionedArray instance. This is
        %  required to have no duplicate slices.
        %
        %  - Each of [tY1,tY2,..] is a PartitionedArray of the same size in
        %  the tall dimension as tXKeys. All of [tYKeys,tY1,tY2,..] must
        %  follow the general input rules with singleton expansion in the
        %  tall dimension.
        %
        % Outputs:
        %  - tKeys is a PartitionedArray column vector that consists of all
        %  slices from tXKeys. The order of tKeys depends on the execution
        %  environment.
        %
        %  - [tX1,tX2,..] each will be a PartitionedArray instance of the
        %  same size in the tall dimension and same partitioning as tKeys.
        %  Each slice of [tX1,tX2,..] corresponds with the slice of tKeys
        %  of the same index in the tall dimension.
        %
        %  - [tY1,tY2,..] each will be a PartitionedArray instance of the
        %  same size in the tall dimension and same partitioning as tKeys.
        %  Each slice of [tY1,tY2,..] corresponds with the slice of tKeys
        %  of the same index in the tall dimension.
        %
        % Error Conditions:
        %  - As part of the general input rules, if the inputs
        %  [tXKeys,tX1,tX2..] do not have the same size in the tall
        %  dimension after singleton expansion, a customer visible error
        %  will be issued at the point this is known. This will either be
        %  immediate or at the time when evaluation occurs.
        %
        %  - As part of the general input rules, if the inputs
        %  [tYKeys,tY1,tY2..] do not have the same size in the tall
        %  dimension after singleton expansion, a customer visible error
        %  will be issued at the point this is known. This will either be
        %  immediate or at the time when evaluation occurs.
        %
        %  - If any of tYKeys is not unique, a customer visible error will
        %  be issued at the point this is known. This will either be
        %  immediate or at the time when evaluation occurs.
        %
        [keys, varargout] = joinbykey(xKeys, x, yKeys, y);
        
        %TERNARYFUN Select between one of two input arrays based on a deferred scalar logical input.
        %
        % Syntax:
        %  tOut = ternaryfun(tLogicalFlag,tIfTrue,tIfFalse)
        %
        % Inputs:
        %  - tLogicalFlag must be a partitioned array containing a logical
        %  scalar.
        %
        %  - tIfTrue must be a partitioned array or constant. This is the
        %  output if tLogicalFlag is true.
        %
        %  - tIfFalse must be a partitioned array or constant. This is the
        %  output if tLogicalFlag is false.
        %
        % Outputs:
        %  - tOut will be a partitioned array that is equivalent to tIfTrue
        %  or tIfFalse if tLogicalFlag is true or false respectively.
        %
        % Error Conditions:
        %  - 'MATLAB:bigdata:array:InvalidTernaryLogical' will be issued at
        %  evaluation if tLogicalFlag is not a scalar logical.
        %
        % This method is conceptually equivalent to:
        %   if tLogicalFlag
        %      tOut = tIfTrue;
        %   else
        %      tOut = tIfFalse;
        %   end
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %
        %  % tX and tY is a PartitionedArray of size 1000x10
        %  tCondition = LazyPartitionedArray.createFromConstant(true);
        %  tX = LazyPartitionedArray.createFromConstant(rand(1000,10));
        %  tY = LazyPartitionedArray.createFromConstant(rand(1000,10));
        %
        %  % tZ is equivalent to tX because tCondition is true
        %  tZ = ternaryfun(tCondition,tX,tY)
        %
        [out] = ternaryfun(condition, ifTrue, ifFalse);
        
        %CHUNKFUN Apply a given chunk-wise function handle to the underlying data.
        %
        % Be aware this is an advanced API. It is possible to generate
        % undefined behavior if the values in the output PartitionArray
        % depend on the chunking of the input data.
        %
        % Syntax:
        %  [tA,tB,tC,..] = chunkfun(functionHandle,tX,tY,..)
        %  [tA,tB,tC,..] = chunkfun(options,functionHandle,tX,tY,..)
        %
        % Inputs:
        %  - functionHandle must be a chunk-wise function handle of type
        %  function_handle or matlab.bigdata.internal.FunctionHandle. It
        %  will be applied to the inputs [tX,tY,..] as per the chunk-wise
        %  function handle rules.
        %
        %  - Inputs [tX,tY,..] follow the general input rules with
        %  singleton expansion in the tall dimension.
        %
        %  - options (optional) must be a PartitionedArrayOptions object.
        %  This can be used to specify RNG state and more.
        %
        % Outputs:
        %  - Outputs [tA,tB,tC,..] will be PartitionArray instances that
        %  consist of the vertical concatenation of the outputs of
        %  functionHandle in accordance to the concatenated output rule.
        %
        % Error Conditions:
        %  - As part of the general input rules, if the inputs [tX,tY,..]
        %  do not have the same size in the tall dimension after singleton
        %  expansion, a customer visible error will be issued at the point
        %  this is known. This will either be immediate or the time when
        %  evaluation occurs.
        %
        %  - Any error issued by the function handle will be returned back
        %  to the user from the function that triggered evaluation. This is
        %  likely to be the following gather.
        %
        % This is conceptually equivalent to:
        %  [tA,tB,tC,..] = functionHandle(tX,tY,..)
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %
        %  % tX is a PartitionedArray of size 1000x10
        %  tX = LazyPartitionedArray.createFromConstant(rand(1000,10));
        %
        %  fun = @(x) reshape(x',1, []);
        %
        %  % tA will have size 10000x1
        %  tA = chunkfun(fun,tX);
        %
        varargout = chunkfun(options, functionHandle, varargin);
        
        % FIXEDCHUNKFUN Perform a chunkfun operation that ensures all
        % chunks of a partition except the last are of a required size.
        %
        % Every chunk of input will be of size numSlicesPerChunk, except
        % for the very last chunk of each and every partition.
        %
        % As opposed to chunkfun, the values in the output is allowed to
        % depend on the chunking given that the chunking is determined only
        % by the partitioning and numSlicesPerChunk.
        %
        % Syntax:
        %  [tA,tB,tC,..] = fixedchunkfun(numSlicesPerChunk,functionHandle,tX,tY,..)
        %  [tA,tB,tC,..] = fixedchunkfun(options,numSlicesPerChunk,functionHandle,tX,tY,..)
        %
        % Inputs:
        %  - numSlicesPerChunk must be a scalar positive integer that
        %  represents the desired number of slices for each chunk of input.
        %  - functionHandle must be a chunk-wise function handle of type
        %  function_handle or matlab.bigdata.internal.FunctionHandle. It
        %  will be applied to the inputs [tX,tY,..] as per the chunk-wise
        %  function handle rules.
        %
        %  - Inputs [tX,tY,..] follow the general input rules with
        %  singleton expansion in the tall dimension.
        %
        %  - options (optional) must be a PartitionedArrayOptions object.
        %  This can be used to specify RNG state and more.
        %
        % Outputs:
        %  - Outputs [tA,tB,tC,..] will be PartitionArray instances that
        %  consist of the vertical concatenation of the outputs of
        %  functionHandle in accordance to the concatenated output rule.
        %
        % Error Conditions:
        %  - As part of the general input rules, if the inputs [tX,tY,..]
        %  do not have the same size in the tall dimension after singleton
        %  expansion, a customer visible error will be issued at the point
        %  this is known. This will either be immediate or the time when
        %  evaluation occurs.
        %
        %  - Any error issued by the function handle will be returned back
        %  to the user from the function that triggered evaluation. This is
        %  likely to be the following gather.
        %
        % This is conceptually equivalent to:
        %  for partitionIndex = 1:numPartitions
        %     for ii = 1:numSlicesPerChunk:sizeInPartition(partitionIndex)
        %        idx = (ii-1)*numSlicesPerChunk+1:ii*numSlicesPerChunk;
        %        [a,b,c,..] = functionHandle(tX(idx),tY(idx),..);
        %        tA = [tA;a]; tB = [tB;b]; tC = [tC;c];...
        %     end
        %  end
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %
        %  % tX is a PartitionedArray of size 1000x10
        %  tX = LazyPartitionedArray.createFromConstant(rand(1000,10));
        %
        %  fun = @(x) size(x,1);
        %
        %  % tA will consist of elements in the range 0:100 with the
        %  % majority equal to 100.
        %  tA = fixedchunkfun(100,fun,tX);
        %
        varargout = fixedchunkfun(options, numSlicesPerChunk, functionHandle, varargin);
        
        %PARTITIONFUN For each partition, apply a function handle to all of the underlying data for the partition.
        %
        % This will call the function handle repeatedly on each chunk from
        % a given partition.
        %
        % WARNING: This is an advanced API. To use it, you MUST both:
        %
        %  1. Ensure that behavior does not depend on the chunking of the
        %  input. The chunking is arbitrary and can change from one gather
        %  to the next. Failure to do this results in output that is not
        %  well defined.
        %
        %  2. Invoke markPartitionIndependent at some point between a usage of
        %  partitionfun and returning output to a user of tall arrays.
        %  Failure to do this will trigger internal errors at gather time.
        %
        % Syntax:
        %  [tA,tB,tC,..] = partitionfun(functionHandle,tX,tY,..)
        %  [tA,tB,tC,..] = partitionfun(options,functionHandle,tX,tY,..)
        %
        % Inputs:
        %  - functionHandle must be a function handle of type
        %  function_handle or matlab.bigdata.internal.FunctionHandle with
        %   signature as described below. It will be applied to the inputs
        %  [tX,tY,..] as per a variant of the chunk-wise function handle
        %  rules also described below.
        %
        %  - Inputs [tX,tY,..] follow the general input rules with
        %  singleton expansion in the tall dimension.
        %
        %  - options (optional) must be a PartitionedArrayOptions object.
        %  This can be used to specify RNG state and more.
        %
        % Outputs:
        %  - Outputs [tA,tB,tC,..] will be PartitionArray instances that
        %  consist of the vertical concatenation of the outputs of
        %  functionHandle in accordance to the concatenated output rule.
        %
        % Error Conditions:
        %  - As part of the general input rules, if the inputs [tX,tY,..]
        %  do not have the same size in the tall dimension after singleton
        %  expansion, a customer visible error will be issued at the point
        %  this is known. This will either be immediate or the time when
        %  evaluation occurs.
        %
        %  - Any error issued by the function handle will be returned back
        %  to the user from the function that triggered evaluation. This is
        %  likely to be the following gather.
        %
        % Function Handle Syntax:
        %  [hasFinished,a,b,c,..] = functionHandle(info,x,y,..)
        %
        %  Inputs:
        %   - info is a struct-like object that holds onto the following
        %   properties:
        %     - PartitionIndex - The index of the partition the current
        %     input originates from.
        %     - RelativeIndexInPartition - The index of the first slice of
        %     the inputs relative to the start of the partition.
        %     - IsLastChunkOfPartition - A logical scalar that is true if
        %     and only if the input data is the last of the data from the
        %     current partition.
        %
        %   - Each of [x,y,..] is a chunk from the corresponding
        %   partitionfun inputs [tX,tY,..]. These exactly follow the
        %   chunk-wise function handle rules.
        %
        %  Outputs:
        %   - hasFinished must be a logical scalar. If set to true, the
        %   framework can assume no more results will be emitted from this
        %   function handle.
        %
        %   - Each of [a,b,c,..] must follow the chunk-wise function handle
        %   rules.
        %
        %  Other Information:
        %   - For each partition, the framework will guarantee to use the
        %   same copy of functionHandle on the same MATLAB context for all
        %   data in the partition.
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %  import matlab.bigdata.internal.MatlabFunctionHandle;
        %
        %  % tX is a PartitionedArray of size 1000x10
        %  tX = LazyPartitionedArray.createFromConstant(rand(1000,10));
        %
        %  fun = FunctionHandle(PartitionNumelFunctor());
        %
        %  % tID and tNumel will both have size N x 1.
        %  % - Each element of tID is a partition ID
        %  % - Each element of tNumel is the number of elements in the
        %  % corresponding partition.
        %  [tId,tNumel] = partitionfun(fun,tX);
        %
        %  % A function handle that counts the number of elements per partition
        %  % of TallVariable tX. This is intended to be used with partitionfun.
        %  classdef PartitionNumelFunctor < handle & matlab.mixin.Copyable
        %      properties
        %          % The count of elements so far. As this functor is copied before use
        %          % once per partition, this becomes the count per partition.
        %          Count = 0;
        %      end
        %      methods
        %          function [hasFinished,partitionId,partitionNumel] = feval(obj,info,x)
        %              obj.Count = obj.Count + numel(x);
        %
        %            % We only want to emit the result when we have counted all the
        %            % elements of tX for the current partition.
        %            hasFinished = info.IsLastChunkOfPartition;
        %              if hasFinished
        %                  partitionId = info.PartitionId;
        %                  partitionNumel = obj.Count;
        %              else
        %                  partitionId = [];
        %                  partitionNumel = [];
        %              end
        %          end
        %      end
        %  end
        %
        varargout = partitionfun(options, functionHandle, varargin);
        
        %GENERALPARTITIONFUN For each partition, apply a function handle to
        % all of the underlying data for the partition where each input
        % might have a different number of slices. This API is very easy to
        % be used incorrectly and each usage requires review from the tall
        % array team.
        %
        % This will call the function handle repeatedly on each chunk from
        % a given partition. This will also provide a way for the function
        % handle to return unused input.
        %
        % WARNING: This is an advanced API. To use it, you MUST both:
        %
        %  1. Ensure that behavior does not depend on the chunking of the
        %  input. The chunking is arbitrary and can change from one gather
        %  to the next. Failure to do this results in output that is not
        %  well defined.
        %
        %  2. Invoke markPartitionIndependent at some point between a usage of
        %  partitionfun and returning output to a user of tall arrays.
        %  Failure to do this will trigger internal errors at gather time.
        %
        % Syntax:
        %  [tA,tB,tC,..] = generalpartitionfun(functionHandle,tX,tY,..)
        %  [tA,tB,tC,..] = generalpartitionfun(options,functionHandle,tX,tY,..)
        %
        % Inputs:
        %  - functionHandle must be a function handle of type
        %  function_handle or matlab.bigdata.internal.FunctionHandle with
        %   signature as described below. It will be applied to the inputs
        %  [tX,tY,..] as per a variant of the chunk-wise function handle
        %  rules also described below. All non-broadcast inputs of
        %  [tX,tY,..] must have the same partition strategy. I.e. all must
        %  have the same number of partitions or all be partitioned by the
        %  same datastore. Note, each input is allowed to have a different
        %  number of slices per partition.
        %
        %  - Inputs [tX,tY,..] follow the general input rules with
        %  singleton expansion in the tall dimension.
        %
        %  - options (optional) must be a PartitionedArrayOptions object.
        %  This can be used to specify RNG state and more.
        %
        % Outputs:
        %  - Outputs [tA,tB,tC,..] will be PartitionArray instances that
        %  consist of the vertical concatenation of the outputs of
        %  functionHandle in accordance to the concatenated output rule.
        %
        % Error Conditions:
        %  - Any error issued by the function handle will be returned back
        %  to the user when evaluation is triggered, i.e. the subsequent
        %  gather.
        %
        % Function Handle Syntax:
        %  [hasFinished,unusedInputs,a,b,c,..] = functionHandle(info,x,y,..)
        %
        %  Inputs:
        %   - info is a struct-like object that holds onto the following
        %   properties:
        %     - PartitionId - The index of the partition
        %     - NumPartitions - The number of partitions
        %     - RelativeIndexInPartition - A vector of indices, each being
        %     the index of the respective input [x,y,..] relative to the
        %     start of the current partition of [tX,tY,..].
        %     - IsBroadcast - A logical vector, that each are true iff the
        %     respective input is a scalar or a broadcast.
        %     - IsLastChunk - A logical vector, that each are true iff the
        %     data from the respective input is the last.
        %
        %   - [x,y,..] each is one chunk from the corresponding [tX,tY,..].
        %     Note, these are allowed to be empty chunks.
        %
        % Outputs:
        %   - hasFinished must be a logical scalar. If set to true, the
        %   framework can assume no more results will be emitted from this
        %   function handle.
        %
        %   - unusedInputs is allowed to be one of two things:
        %       a. A cell array of unused slices of [x,y,..]. All unused
        %       slices will be prepended onto the inputs of the next call.
        %       Note, the framework will use the number of unused slices to
        %       decide which of the inputs you require for the next call.
        %       For example, if you return empty for the first input and
        %       non-empty for the second input, the framework will try to
        %       only give you slices of the first input on the next call.
        %
        %       b. A logical array specifying which of inputs [x,y,..] are
        %       not currently needed. For example, if the algorithm doesn't
        %       need any more of the third input for now, it should return
        %       true for the third input. If it can, the framework will
        %       then pass in an empty chunk for the third input on the next
        %       call.
        %     In both cases, the array must be the same length as number of
        %     inputs [x,y,..].
        %
        %   - Outputs [a,b,c,..] each is a chunk to be appended onto the
        %   respective outputs [tA,tB,..].
        %
        %  Other Information:
        %   - For each partition, the framework will guarantee to use the
        %   same copy of functionHandle within the same MATLAB context for
        %   all data in the partition.
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %  % Total number of elements
        %  N = 3e5;
        %  % Ratio of elements that are placed in tX1 over tX2
        %  skew = 0.7;
        %
        %  expected = (1:N)';
        %  idx = rand(size(expected)) < skew;
        %
        %  data = table(expected,idx);
        %  ds = qeGenerateTallDatastore(2,'tempdir','mat',data);
        %  tData = LazyPartitionedArray.createFromDatastore(ds);
        %
        %  tX1 = chunkfun(@(t) t.expected(t.idx), tData);
        %  tX2 = chunkfun(@(t) t.expected(~t.idx), tData);
        %
        %  tActual = generalpartitionfun(@myMergeFcn, tX1, tX2);
        %
        %  % The output of myMergeFcn does not depend on partitioning
        %  % despite the usage of the generalpartitionfun primitive.
        %  tActual = markPartitionIndependent(tActual);
        %
        %  actual = gather(tActual);
        %
        %  isMergedCorrectly = isequal(actual, expected);
        %  display(isMergedCorrectly)
        %
        %
        %  function [isFinished, varargin, output] = myMergeFcn(info, varargin) %#ok<VALST>
        %  % General Partitionwise function that merges multiple streams of inputs
        %  % into one assuming that all data in each input is already sorted.
        %
        %  % We cannot do anything if we don't have at least one element per unfinished input.
        %  isInputEmptyVector = cellfun(@isempty, varargin);
        %  if any(isInputEmptyVector & ~info.IsLastChunk)
        %      isFinished = false;
        %      output = zeros(0, 1);
        %      return;
        %  end
        %
        %  % This algorithm ends when there is no more data.
        %  isFinished = all(info.IsLastChunk);
        %
        %  if isFinished
        %      % Can consume all input because there is no future input.
        %      data = varargin;
        %      varargin = [];
        %  else
        %      % Can only consume elements up until the maximum value that we can
        %      % guarantee that all future input is not less than the value. All
        %      % remaining elements are left in inputs so that the framework passes
        %      % them back to us alongside new input on the next call.
        %      lastKnownValues = cellfun(@max, varargin(~info.IsLastChunk));
        %      lastAllowedValueToEmit = min(lastKnownValues);
        %
        %      data = cellfun(@(x) x(x <= lastAllowedValueToEmit), varargin, 'UniformOutput', false);
        %      varargin = cellfun(@(x) x(x > lastAllowedValueToEmit), varargin, 'UniformOutput', false);
        %  end
        %
        %  output = sort(vertcat(data{:}));
        %  end
        varargout = generalpartitionfun(options, functionHandle, varargin);
        
        %ISPARTITIONINDEPENDENT Returns true if all underlying data is independent
        % of the partitioning of the array.
        %
        % The output of partitionfun / generalpartitionfun and everything
        % derived from them will be marked as partition dependent, that the
        % data underlying the array depends on the partitioning of the
        % array. This will return true in such instances.
        %
        % Syntax:
        %  tf = isPartitionIndependent(tX,tY,..)
        %
        % Inputs:
        %  - Each of [tX,tY,..] must be a PartitionedArray
        %
        % Outputs:
        %  - tf is a logical scalar that is true if and only if all inputs
        %  are partition independent.
        %
        % Example:
        %  % Most usages of isPartitionIndependent should follow the workflow:
        %  function tOut = myFcn(tIn)
        %      % Apply an algorithm with some partition dependent intermediate
        %      % arrays, but a partition independent output.
        %      tTmp = partitionfun(@myFcn1,tIn);
        %      tOut = reducefun(@myFcn2,tTmp);
        %      % The output is partition independent as long as the input
        %      % was.
        %      if isPartitionIndependent(tIn)
        %          tOut = markPartitionIndependent(tOut);
        %      end
        %  end
        tf = isPartitionIndependent(varargin);
        
        %MARKPARTITIONINDEPENDENT Mark that the data underlying a PartitionedArray
        % is independent of the partitioning of the PartitionedArray.
        %
        % Both partitionfun and generalpartitionfun can generate output
        % whose underlying data is dependent on the partitioning used by
        % PartitionedArray. This method must be invoked to mark the place
        % where results derived from partitionfun or generalpartitionfun
        % have become independent of the partitioning. Failing to do this
        % will result in errors at gather time, we do not allow partition
        % dependent results to be gathered to the user.
        %
        % Syntax:
        %  [tX,tY,..] = markPartitionIndependent(tX,tY,..)
        %
        % Inputs:
        %  - Each of [tX,tY,..] must be a PartitionedArray.
        %
        % Outputs:
        %  - Each of [tX,tY,..] will be equal to the corresponding input
        %  argument. These will have the partition independent flag set.
        %
        % Error Conditions:
        %  - None
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %
        %  % tX is a PartitionedArray of size 1000x10
        %  tX = LazyPartitionedArray.createFromConstant(rand(1000,10));
        %
        %  assert(isPartitionIndependent(tX));
        %
        %  % tY is dependent on partitioning, it contains one value per
        %  partition.
        %  tY = partitionfun(@(x) deal(true, size(x, 2)), tX);
        %
        %  assert(~isPartitionIndependent(tY));
        %
        %  % tz is no longer dependent on partitioning, it is the same
        %  % regardless of how many partitions existed in tX so we can mark
        %  % it as such.
        %  tZ = clientfun(@(y) y(1), tY);
        %  tZ = markPartitionIndependent(tZ);
        %  assert(isPartitionIndependent(tZ));
        varargout = markPartitionIndependent(varargin);
        
        %MARKFORREUSE Inform the Lazy Evaluation Framework that the given
        % PartitionedArray will be reused multiple times.
        %
        % This is an advanced operation that allows the caller to guide the
        % optimization with respect to reuse and caching.
        %
        % Syntax:
        %  markforreuse(tX,tY,..)
        %
        % Inputs:
        %  - Each of [tX,tY,..] must be a PartitionedArray.
        %
        % Error Conditions:
        %  - None
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %
        %  % tX is a PartitionedArray of size 1000x10
        %  tX = LazyPartitionedArray.createFromConstant(rand(1000,10));
        %
        %  markforreuse(tX);
        %  parameter = 0;
        %  for ii = 1:10
        %     parameter = gather(parameter);
        %     parameter = reducefun(@(x) var(x - parameter),tX);
        %  end
        %
        markforreuse(varargin);
        
        %UPDATEFORREUSE Inform the Lazy Evaluation Framework that a
        % PartitionedArray should replace all cache entries of another.
        %
        % This is an advanced operation that allows the caller to guide the
        % optimization with respect to reuse and caching.
        %
        % Syntax:
        %  updateforreuse(tOld,tNew)
        %
        % Inputs:
        %  - tOld must be a PartitionedArray that is already marked for
        %  reuse. This will be modified to no longer be marked for reuse.
        %  - tNew must be a PartitionedArray.
        %
        % Error Conditions:
        %  - An internal error will be issued if tOld is not the exact
        %  PartitionedArray object that was passed to markforreuse.
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %
        %  % tX is a PartitionedArray of size 1000x10
        %  tX = LazyPartitionedArray.createFromConstant(rand(1000,10));
        %
        %  markforreuse(tX);
        %  parameter = 0;
        %  for ii = 1:10
        %     parameter = gather(parameter);
        %     parameter = reducefun(@(x) var(x),tX);
        %     tX = updateforreuse(tX,tX - parameter);
        %  end
        %
        updateforreuse(tOld, tNew);
        
        %ALIGNPARTITIONS Align the partitioning of one or more PartitionedArray instances.
        %
        % This will repartition the PartitionArray instances such that they
        % have the same partition as a reference PartitionArray instance.
        %
        % Note, this is done implicitly by the Lazy Evaluation Framework.
        % This is an advanced operation in case the algorithm knows it is
        % more optimal to do this at a different point in the calculation
        % compared to the default.
        %
        % Syntax:
        %  [tRef,tX2,tY2,..] = alignpartitions(tRef,tX,tY,..)
        %
        % Inputs:
        %  - tRef is a PartitionedArray instance that acts as a reference
        %  to how the other inputs should be repartitioned.
        %
        %  - Each of [tX,tY,..] is a PartitionedArray of the same size in
        %  the tall dimension as tRef. All of [tRef,tX,tY,..] must follow the
        %  general input rules.
        %
        % Outputs:
        %  - tRef is a PartitionedArray instance that consists of the same
        %  underlying data and partitioning as the input tRef.
        %
        %  - Each of [tX2,tY2,..] will be a PartitionedArray consisting of
        %  the same underlying data as each of [tX,tY,..] respectively. All
        %  outputs will have the same partitioning as the output tRef.
        %
        % Error Conditions:
        %  - As part of the general input rules, if the inputs
        %  [tRef,tX,tY,..] do not have the same size in the tall dimension
        %  after singleton expansion, a customer visible error will be
        %  issued at the point this is known. This will either be immediate
        %  or the time when evaluation occurs.
        %
        % This is conceptually equivalent to:
        %  tX2 = tX(tSubs,:,..)
        %  tY2 = tY(tSubs,:,..)
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %
        %  % tX has size 1000x1 and 1000x10.
        %  tX = LazyPartitionedArray.createFromConstant(rand(1000,10));
        %
        %  % tY is a partition of size 10000x1 filtered to 1000x1.
        %  tY = LazyPartitionedArray.createFromConstant(rand(10000,10));
        %  tY = filterslices(elementfun(@(y)mod(y,10)==0,tY),tY);
        %
        %  [tX,tY] = alignpartitions(tX,tY);
        %  parameter = reducefun(@myReduceFcn,tX,tY);
        %
        [ref, varargout] = alignpartitions(ref, varargin);
        
        %REPARTITION Repartition one or more PartitionedArray instances to a new partition strategy.
        %
        %
        % This will repartition the PartitionArray instances such that they
        % have the given partitioning, mapping the slices using a key
        % input.
        %
        % Syntax:
        %  [tX2,tY2,..] = repartition(partitionMetadata,tPartitionIndices,tX,tY,..)
        %
        % Inputs:
        %  - partitionMetadata must be a matlab.bigdata.internal.PartitionMetadata
        %  object. This will control the number of partitions in the
        %  output. Two partitioned arrays with the same partitionMetadata are
        %  compatible.
        %
        %  - tPartitionIndices A partitioned array of target partition
        %  indices. Each value must be the target partition index that the
        %  corresponding slice of other inputs will be sent.
        %
        %  - Each of [tX,tY,..] is a PartitionedArray of the same size in
        %  the tall dimension as tPartitionIndices. All of [tPartitionIndices,tX,tY,..]
        %  must follow the general input rules without singleton expansion.
        %
        % Outputs:
        %  - Each of [tX2,tY2,..] will be a PartitionedArray consisting of
        %  the same underlying data as each of [tX,tY,..] respectively
        %  up-to ordering. Each partition K of tX,tY,.. will consist of all
        %  of the slices where the corresponding value of tPartitionedArray
        %  is equal to K.
        %
        % Error Conditions:
        %  - As part of the general input rules, if the inputs
        %  [tPartitionIndices,tX,tY,..] do not have the same size in the tall
        %  dimension after singleton expansion, a customer visible error will
        %  be issued at the point this is known. This will either be immediate
        %  or the time when evaluation occurs.
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %  import matlab.bigdata.internal.PartitionMetadata;
        %
        %  % tX is a 1000x1 random array consisting of values 1:10.
        %  tX = LazyPartitionedArray.createFromConstant(randi(10,1000,1));
        %
        %  % tY will be an array of 10 partitions where partition N
        %  % consists of all the values of tX equal to N
        %  partitionMetadata = PartitionMetadata(10);
        %  tY = repartition(numOutputPartitions,tX,tX);
        %
        varargout = repartition(partitionMetadata, partitionIndices, varargin);
        
        %CLIENTFOREACH Stream data back to the client MATLAB Context and
        % perform an action per chunk inside the client MATLAB Context.
        %
        % This will do three things:
        %  1. Call a worker-side function handle on the inputs in exactly
        %     the same way as partitionfun with a single data output.
        %  2. Stream the output of this partitionfun back to the client.
        %  3. Pass every value of this output to a client-side function
        %  handle.
        %
        % Note:
        %  1. This operation will block and evaluate immediately.
        %  2. Every call of the client-side function will correspond with
        %  exactly one call to the worker-side function.
        %  3. The input of the client-side function call will be exactly
        %  the output of the corresponding worker-side function call.
        %
        % Syntax:
        %  clientforeach(workerFcn,clientFcn,tX,tY,..)
        %
        % Inputs:
        %  - workerFcn must be a function handle. It will be applied to
        %  inputs [tX,tY,..] as per the partitionfun contract, with a
        %  single data output.
        %  - clientFcn must be a function handle of signature as described
        %  below. The result of a single invocation of workerFcn will be
        %  passed as the input to a single invocation of clientFcn. All
        %  calls are guaranteed to be with the MATLAB client context.
        %  - Inputs [tX,tY,..] are partitioned inputs or non-partitioned
        %  inputs that follow the general input rule with singleton
        %  expansion. I.e. they must have the exact same partitioning
        %  or have size 1 in the tall dimension.
        %
        % Error Conditions:
        %  - Any error issued by the function handle will be returned back
        %  to the user.
        %
        % Function Handle Syntax for workerFcn:
        %  [hasFinished,value] = workerFcn(info,x,y,..)
        %
        %  Where both [info,x,y,..] and hasFinished have the same
        %  definition as for the partitionfun function handle.
        %
        %  The output parameter, value, can be anything that is serializable.
        %  It does not need to be vertically concatenable with previous
        %  values. Each value will be passed into one call of clientFcn.
        %
        % Function Handle Syntax for clientFcn:
        %  hasFinished = clientFcn(info,value)
        %
        % Inputs:
        %   - info is a struct with fields:
        %     - PartitionId, a number in the range 1:NumPartitions that
        %     corresponds to the partition which value originated from.
        %     - NumPartitions, the number of partitions that workerFcn
        %     evaluated over.
        %     - IsLastChunk A logical scalar that is true if and only if
        %     this is the last chunk from partition corresponding to
        %     PartitionId.
        %     - CompletedPartitions A logical vector, each value being true
        %     if and only if there is no more values from the corresponding
        %     partition.
        %   - value is the output of one call to workerFcn. Values from a
        %     single partition will be in order of calls of workerFcn.
        %     Values from different partitions are NOT guaranteed to be in
        %     order. For parallel environments, it is possible to receive
        %     values from partition 2 before partition 1.
        %
        % Outputs:
        %   - isFinished is a logical scalar specifying if the entire
        %   calculation is finished. Returning true will end the
        %   clientforeach.
        %
        % Example:
        %  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
        %  % Total number of elements
        %  N = 3e5;
        %  ds = qeGenerateTallDatastore(2,'tempdir','mat',rand(N, 1));
        %  tX = LazyPartitionedArray.createFromDatastore(ds);
        %
        %  clientforeach(@workerFcn,@clientFcn,tX);
        %
        %  function [isFinished, s] = workerFcn(info,x)
        %      isFinished = info.IsLastChunk;
        %      s.Min = min(x);
        %      s.Max = max(x);
        %      s.Mean = mean(x);
        %  end
        %
        %  function isFinished = clientFcn(info,s)
        %     isFinished = all(info.CompletedPartitions);
        %     fprintf([...
        %         'Chunk from partition %i:\n', ...
        %         '  IsLastChunk: %i\n', ...
        %         '  Min: %f\n', ...
        %         '  Max: %f\n', ...
        %         '  Mean: %f\n'], ...
        %         info.PartitionId,info.IsLastChunk,...
        %         s.Min, s.Max, s.Mean);
        %  end
        %
        clientforeach(workerFcn, clientFcn, varargin);
    end
    
    methods (Abstract, Hidden)
        %RESIZECHUNKS Resizes the chunks of a partitioned array to be a
        % reasonable size for vectorization. This will remove empty chunks
        % and coalesce chunks that are too small for vectorization.
        %
        % This functionality is exposed for tall/write and not for general
        % use.
        %
        % Syntax:
        %  [tX2,tY2,..] = resizechunks(tX,tY,..)
        %
        % Inputs:
        %  - Each of [tX,tY,..] must be a PartitionedArray with the same
        %  partition strategy.
        %
        % Outputs:
        %  - Each of [tX2,tY2,..] will be a PartitionedArray consisting of
        %  the same underlying data as each of [tX,tY,..] respectively.
        %  All outputs will all have same number of chunks as each other.
        %
        %  A subsequent chunk-wise operations that uses all of [tX2,tY2,..]
        %  is guaranteed to get enough data to get reasonable vectorization
        %  per invocation.
        %
        varargout = resizechunks(varargin);
    end
end
