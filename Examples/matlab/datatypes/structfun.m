% STRUCTFUN Apply a function to each field of a scalar structure.
%   A = STRUCTFUN(FUN, B) applies the function specified by FUN to each
%   field of a scalar structure B, and returns the results in array A.  
%   A is a column vector whose size is equal to the number of fields in B. 
%   The Nth element of A is the result of applying FUN to the Nth field 
%   of B, where the order of the fields is the same as that returned by 
%   a call to FIELDNAMES. FUN is a function handle to a function that 
%   takes one input argument and returns a scalar value. FUN must return 
%   values of the same class each time it is called.  
%
%   If FUN represents a set of overloaded functions, then STRUCTFUN follows
%   MATLAB dispatching rules in calling the function.
%
%   [A, B, ...] = STRUCTFUN(FUN, C), returns arrays A, B, ..., each 
%   corresponding to one of the output arguments of FUN.  STRUCTFUN
%   calls FUN each time with as many outputs as there are in the call to
%   STRUCTFUN.  FUN may return output arguments having different classes,
%   but the class of each output must be the same each time FUN is called.
%
%   [A, ...] = STRUCTFUN(FUN, B, 'Param1', val1, ...) enables you to
%   specify optional parameter name/value pairs.  Parameters are:
%
%      'UniformOutput' -- a logical value indicating whether the output 
%      values of FUN are returned without encapsulation in a cell array.
%      If true (the default), FUN must return scalar values that can
%      be concatenated into an array.  If FUN returns objects, then they
%      must satisfy the requirements listed in Note 2. If false, 
%      STRUCTFUN returns a scalar structure (or multiple scalar
%      structures), whose fields are the same as the fields of the input 
%      structure B. The values in the output structure fields are the 
%      results of calling FUN on the corresponding values in the input 
%      structure B.  When 'UniformOutput'is false, then the outputs 
%      returned by FUN can be of any type.
%
%      'ErrorHandler' -- a function handle, specifying the function
%      MATLAB is to call if the call to FUN fails.   The error handling
%      function will be called with the following input arguments:
%        -  a structure, with the fields:  "identifier", "message", and
%           "index", respectively containing the identifier of the error
%           that occurred, the text of the error message, and the number of 
%           the field (in the same order as returned by FIELDNAMES) at 
%           which the error occurred. 
%        -  the input argument at which the call to the function failed.
%
%      The error handling function should either rethrow an error, or
%      return the same number of outputs as FUN.  These outputs are then
%      returned as the outputs of STRUCTFUN.  If 'UniformOutput' is true,
%      the outputs of the error handler must also be scalars of the same
%      type as the outputs of FUN. Example:
%
%      function [A, B] = errorFunc(S, varargin)
%           warning(S.identifier, S.message); A = NaN; B = NaN;
%
%      If an error handler is not specified, the error from the call to 
%      FUN will be rethrown.
%
%   NOTE 1:
%      To concatenate objects into an array with 'UniformOutput', the class 
%      that the objects belong to must satisfy the following conditions:
%       1) Assignment by linear indexing into the object array must be supported.
%       2) Reshape must return an array of the same size as the input.
%
%   Examples
%      To create shortened weekday names from the full names, create a
%      structure with character vectors in several fields.
%
%      s.f1 = 'Sunday'; s.f2 = 'Monday'; s.f3 = 'Tuesday'; 
%      s.f4 = 'Wednesday'; s.f5 = 'Thursday'; s.f6 = 'Friday';
%      s.f7 = 'Saturday';
%      shortNames = structfun(@(x) ( x(1:3) ), s, 'UniformOutput', false);
%
%      See also  CELLFUN, ARRAYFUN, FUNCTION_HANDLE, CELL2MAT, SPFUN

%   Copyright 2005-2017 The MathWorks, Inc.
%   Built-in function.
