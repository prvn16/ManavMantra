% ARRAYFUN Apply a function to each element of an array.
%   A = ARRAYFUN(FUN, B) applies the function specified by FUN to each
%   element of array B, and returns the results in array A.  A is the same
%   size as B, and the (I,J,...)th element of A is equal to
%   FUN(B(I,J,...)). FUN is a function handle to a function that takes one
%   input argument and returns a scalar value. FUN must return values of
%   the same class each time it is called.  The inputs can be arrays of any
%   type.  Object arrays are supported, subject to the requirements in Note
%   1.  The order in which ARRAYFUN computes elements of A is not specified
%   and should not be relied on.
%
%   If FUN represents a set of overloaded functions, then ARRAYFUN follows
%   MATLAB dispatching rules in calling the function.
%
%   A = ARRAYFUN(FUN, B, C,  ...) evaluates FUN using elements of arrays B,
%   C,  ... as input arguments.  The (I,J,...)th element of A is equal to 
%   FUN(B(I,J,...), C(I,J,...), ...).  B, C, ... must all have the same size.
%
%   [A, B, ...] = ARRAYFUN(FUN, C, ...), where FUN is a function handle to
%   a function that returns multiple outputs, returns arrays A, B, ...,
%   each corresponding to one of the output arguments of FUN.  ARRAYFUN
%   calls FUN each time with as many outputs as there are in the call to
%   ARRAYFUN.  FUN may return output arguments having different classes,
%   but the class of each output must be the same each time FUN is called.
%
%   [A, ...] = ARRAYFUN(FUN, B,  ..., 'Param1', val1, ...) enables you to
%   specify optional parameter name/value pairs.  Parameters are:
%
%      'UniformOutput' -- a logical value indicating whether the output 
%      values of FUN are returned without encapsulation in a cell array.
%      If true (the default), FUN must return scalar values that can
%      be concatenated into an array.  If FUN returns objects, then they
%      must satisfy the requirements listed in Note 2. If false, 
%      ARRAYFUN returns a cell array (or multiple cell arrays), where the
%      (I,J,...)th cell contains the value FUN(B(I,J,...), ...).  If 
%      'UniformOutput' is false, then the outputs returned by FUN can be 
%      of any type.
%
%      'ErrorHandler' -- a function handle, specifying the function
%      MATLAB is to call if the call to FUN fails.   The error handling
%      function will be called with the following input arguments:
%        -  a structure, with the fields:  "identifier", "message", and
%           "index", respectively containing the identifier of the error
%           that occurred, the text of the error message, and the linear 
%           index into the input array(s) at which the error occurred. 
%        -  the set of input arguments at which the call to the function
%           failed.
%
%      The error handling function should either rethrow an error, or
%      return the same number of outputs as FUN.  These outputs are then
%      returned as the outputs of ARRAYFUN.  If 'UniformOutput' is true,
%      the outputs of the error handler must also be scalars of the same
%      type as the outputs of FUN. Example:
%
%      function [A, B] = errorFunc(S, varargin)
%          warning(S.identifier, S.message); A = NaN; B = NaN;
%
%      If an error handler is not specified, the error from the call to 
%      FUN will be rethrown.
%
%   NOTE 1:
%      If the input object arrays have either the subsref or size method
%      overloaded, then the following conditions have to be met for 
%      ARRAYFUN to work as expected:
%       1) The size method must return an array of doubles as its output.
%       2) Linear indexing into the object array must be supported.
%       3) The product of the sizes returned from size must not exceed the
%       limit of the array, as defined by linearly indexing into the array.
%
%   NOTE 2:
%      To concatenate objects into an array with 'UniformOutput', the class 
%      that the objects belong to must satisfy the following conditions:
%       1) Assignment by linear indexing into the object array must be supported.
%       2) Reshape must return an array of the same size as the input.
%
%   Examples
%      Create a structure array with random matrices in the field f1.
%      s(1).f1 = rand(7,4) * 10;
%      s(2).f1 = rand(3,8) * 10;
%      s(3).f1 = rand(5,5) * 10;
%
%      Now compute the max and mean of each row of each matrix.
%      sMax = arrayfun(@(x)(max(x.f1)), s, 'UniformOutput', false)
%      sMax = 
%              [1x4 double]  [1x8 double] [1x5 double]
%      sMean = arrayfun(@(x)(mean(x.f1)), s, 'UniformOutput', false)
%      sMean = 
%              [1x4 double]    [1x8 double]    [1x5 double]
%
%      See also  CELLFUN, STRUCTFUN, FUNCTION_HANDLE, CELL2MAT, SPFUN

%   Copyright 2005-2017 The MathWorks, Inc.
%   Built-in function.
