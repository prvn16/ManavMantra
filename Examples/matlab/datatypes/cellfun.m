% CELLFUN Apply a function to each cell of a cell array.
%   A = CELLFUN(FUN, C) applies the function specified by FUN to the
%   contents of each cell of cell array C, and returns the results in
%   the array A.  A is the same size as C, and the (I,J,...)th element of A
%   is equal to FUN(C{I,J,...}). FUN is a function handle to a function
%   that takes one input argument and returns a scalar value. FUN must
%   return values of the same class each time it is called.  The 
%   order in which CELLFUN computes elements of A is not specified and 
%   should not be relied on. 
%
%   If FUN represents a set of overloaded functions, then CELLFUN follows
%   MATLAB dispatching rules in calling the function.
%
%   A = CELLFUN(FUN, B, C, ...) evaluates FUN using the contents of the
%   cells of cell arrays B, C, ... as input arguments.  The (I,J,...)th
%   element of A is equal to FUN(B{I,J,...}, C{I,J,...}, ...).  B, C, ...
%   must all have the same size.
%
%   [A, B, ...] = CELLFUN(FUN, C, ...), where FUN is a function handle to a
%   function that returns multiple outputs, returns arrays A, B, ...,
%   each corresponding to one of the output arguments of FUN.  CELLFUN
%   calls FUN each time with as many outputs as there are in the call to
%   CELLFUN.  FUN may return output arguments having different classes, but
%   the class of each output must be the same each time FUN is called.
%
%   [A, ...] = CELLFUN(FUN, C,  ..., 'Param1', val1, ...) enables you to
%   specify optional parameter name/value pairs.  Parameters are:
%
%      'UniformOutput' -- a logical value indicating whether the output 
%      values of FUN are returned without encapsulation in a cell array.
%      If true (the default), FUN must return scalar values that can
%      be concatenated into an array.  If FUN returns objects, then they
%      must satisfy the requirements listed in Note 2. If false, 
%      CELLFUN returns a cell array (or multiple cell arrays), where the
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
%        -  the set of input arguments at which the call to the 
%           function failed.
%
%      The error handling function should either rethrow an error, or
%      return the same number of outputs as FUN.  These outputs are then 
%      returned as the outputs of CELLFUN.  If 'UniformOutput' is true,
%      the outputs of the error handler must also be scalars of the same
%      type as the outputs of FUN. Example:
%
%      function [A, B] = errorFunc(S, varargin)
%           warning(S.identifier, S.message); A = NaN; B = NaN;
%
%      If an error handler is not specified, the error from the call to 
%      FUN is rethrown.
%
%   The following syntaxes are also accepted for backward compatibility:
%
%   A = CELLFUN('fun', C), where 'fun' is one of the following function
%   names, returns a logical or double array A the elements of which are
%   computed from those of C as follows:
%
%      'isreal'     -- true for cells containing a real array, false
%                      otherwise 
%      'isempty'    -- true for cells containing an empty array, false 
%                      otherwise 
%      'islogical'  -- true for cells containing a logical array, false 
%                      otherwise 
%      'length'     -- the length of the contents of each cell 
%      'ndims'      -- the number of dimensions of the contents of each cell
%      'prodofsize' -- the number of elements of the contents of each cell
%
%   A = CELLFUN('size', C, K) returns the size along the K-th dimension of
%   the contents of each cell of C.
%
%   A = CELLFUN('isclass', C, CLASSNAME) returns true for each cell of C
%   that contains an array of class CLASSNAME.  Unlike the ISA function, 
%   'isclass' of a subclass of CLASSNAME returns false.
%
%   Note: For the previous three syntaxes, if C contains objects, CELLFUN
%   does not call any overloaded versions of MATLAB functions corresponding
%   to the above function names.
%
%   [A, ...] = CELLFUN(FUN, S, ...) Instead of an input cell array C, cellfun
%   also accepts a string array S. Cellfun indexes into the string array using curly
%   brace subscripting ({}) to access the characters of each element of the string
%   array.
%
%   NOTE 1:
%      To concatenate objects into an array with 'UniformOutput', the class 
%      that the objects belong to must satisfy the following conditions:
%       1) Assignment by linear indexing into the object array must be supported.
%       2) Reshape must return an array of the same size as the input.
%
%   Examples
%      % Compute the mean and the size of several datasets. 
%      C = {1:10, [2; 4; 6], []}; 
%      Cmeans = cellfun(@mean, C); 
%      [Cnrows,Cncols] = cellfun(@size, C);
%      Csize = cellfun(@size, C, 'UniformOutput', false);
%
%      % Find the positive values in several datasets. 
%      C = {randn(10,1), randn(20,1), randn(30,1)}; 
%      Cpositives = cellfun(@(x) x(x>0), C, 'UniformOutput',false);
%
%      % Compute the covariance between several pairs of datasets. 
%      C = {randn(10,1), randn(20,1), randn(30,1)};
%      D = {randn(10,1), randn(20,1), randn(30,1)};
%      CDcovs = cellfun(@cov, C, D, 'UniformOutput', false);
%      
%   See also  ARRAYFUN, STRUCTFUN, FUNCTION_HANDLE, CELL2MAT, SPFUN

%   Copyright 1998-2017 The MathWorks, Inc.
%   Built-in function.
