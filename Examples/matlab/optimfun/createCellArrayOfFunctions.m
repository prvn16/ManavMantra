function cellArrayOfFcn = createCellArrayOfFunctions(someFunction,property)
%

%createCellArrayOfFunctions creates cell array of functions
%   This function accepts a cell array of functions in 'someFunction' or a 
%   single function (string or function handle). The 'property' is the 
%   name of the optimization option, which is used to create appropriate 
%   error/warning messages. The output 'cellArrayOfFcn' is a 'clean' 
%   cell array of functions (without extra braces, empty brackets).
    
%   Private to the Optimization Toolbox.

%   Copyright 2005-2011 The MathWorks, Inc.

cellArrayOfFcn  = [];
fcnCounter = 1;

% If a string or function handle then convert to a cell array
if ~iscell(someFunction) 
     someFunction = {someFunction};
end

% someFunction is a cell array at this point
for i = 1:numel(someFunction)
    candidate = someFunction(i);
    %If any element is also a cell array
    if iscell(candidate)
        if isempty(candidate{1})
            continue;
        end
        % Sometimes the variable 'candidate' might have nested cell array 
        % e.g. {{@outputfcn, p1,p2}} instead of just
        % {@outputfcn,p1,p2}. The following code gets rid of extra braces,
        % which are typically introduced by GUI import/export options.
        temp = candidate{1};
        while iscell(temp) && isscalar(temp)
            candidate = temp(1);
            temp = candidate{1};
        end
        % args is not used in optim; used in gads for additional parameter syntax        
        [handle,~] = isFcn(candidate{:}); 
    else
        [handle,~] = isFcn(candidate);
    end
    if(~isempty(handle)) && (isa(handle,'inline') || isa(handle,'function_handle'))
        cellArrayOfFcn{fcnCounter} = handle;
        fcnCounter = fcnCounter + 1;
    else
        error('MATLAB:createCellArrayOfFunctions:needFunctionOrCell',...
            getString(message('MATLAB:optimfun:createCellArrayOfFunctions:needFunctionOrCell', property)));
    end
end

%-------------------------------------------------------------------------
% If it's a scalar fcn handle or a cellarray starting with a fcn handle and
% followed by something other than a fcn handle, return handle, else empty.
%
% isFcn separates function handle 'handle' and additional argument 'args'.
% arg is not used in optim; used in gads for additional parameter syntax.        

function [handle,args] =  isFcn(x)
  %If x is a cell array with additional arguments, handle them
  if iscell(x) 
      if ~isempty(x)
          args = x(2:end);
          handle = x{1};
      else  %Cell could be empty too
          args = {};
          handle = [];
      end
  else % Not a cell
      args = {};
      handle = x;
  end
  
  if ~isempty(handle)
      [handle,msg] = fcnchk(handle);
      if ~isempty(msg)
          handle =[];
      end
  end
  
