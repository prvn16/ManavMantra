function [out] = hgfeval(fcn,varargin)
% This undocumented helper function is for internal use.

% HGFEVAL Utility for executing callbacks similar to HG.
%   HGFEVAL(FCN) evaluates the expression specified by FCN.
%   
%   If FCN is a string, it is evaluated in the base workspace.
%   Equivalent to "evalin('base', FCN)".
%
%   If FCN is a function handle, it is evaluated using feval in the
%   functions workspace. Equivalent to "feval(FCN)"
%             
%   If FCN is a cell array whose first element is a string or a function
%   handle, it is evaluated using feval with the first element as the
%   function name or handle and the subsequent elements as arguments.
%   Equivalent to "feval(FCN{1}, FCN{2:end})".
%
%   HGFEVAL(FCN, ARG1, ARG2,...) is similar to the previous syntax, except
%   that the additional input arguments are pre-appended to the
%   argument list. Equivalent to feval(FCN{1}, ARG1, ARG2,..., FCN{2:end}).
%
%   OUT = HGFEVAL(...) Gets function outputs.
%
%  See also FEVAL.

%   Copyright 2003-2006 The MathWorks, Inc.

if nargout>0
  doout = true;
else
  doout = false;
end

if isempty(fcn)
    if doout
        out = [];
    end
    return;
end

if isa(fcn,'function_handle')
   fcn = {fcn};
end

cellFunction = iscell(fcn);

if cellFunction && ~isa(fcn{1},'function_handle') && ~ischar(fcn{1})
   error(message('MATLAB:hgfeval:invalidInput'));
end
if ~cellFunction && ~ischar(fcn)
    error(message('MATLAB:hgfeval:invalidInput'));
end

if doout
    if cellFunction
        out = feval(fcn{1},varargin{:},fcn{2:end});
    else
        out = evalin('base', fcn);
    end
else
    if cellFunction
        feval(fcn{1},varargin{:},fcn{2:end});
    else
        evalin('base', fcn);
    end
end
