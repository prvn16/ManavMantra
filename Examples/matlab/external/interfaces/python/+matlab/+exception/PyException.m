%matlab.exception.PyException represents an exception thrown from Python
%  matlab.exception.PyException(MSGID, ERRMSG, EXCOBJ) captures 
%  information about the exception.  It is derived from 
%  matlab.exception.ExternalException.
%
%  MSGID is the MException message identifier (a character string).
%  ERRMSG is the MException error message (a character string).
%  EXCOBJ is the exception object from Python. 
%
%  Example:
%    try
%      py.list(1,2,3,4);
%    catch e
%      e.message
%    end

%   Copyright 2014-2015 The MathWorks, Inc.
classdef PyException < matlab.exception.ExternalException
    properties (GetAccess = private, SetAccess = immutable)
        OriginalMStack;
    end
    methods
        function ct = PyException(id, msg, excObj)
            %call the base class constructor
            ct@matlab.exception.ExternalException(id, msg, excObj);
            ct.OriginalMStack = dbstack(2, '-completenames');
        end
    end
    methods (Hidden, Access = protected)
        function stack = getStack(obj)
            %getStack get stack trace information
            %
            %  Syntax
            %
            %    stack = getStack(exception)
            %
            %  Description
            %
            %    stack = getStack(exception) get stack trace information
            %    stack for exception object of class 
            %    matlab.exception.PyException.
            %
            %  Input Argument
            %
            %    exception - exception object of class 
            %    matlab.exception.PyException.
            %
            %  Output Argument  
            %
            %    stack - N-1 struct array with fields file, name and line.
            %
            stack = getStack@matlab.exception.ExternalException(obj);
            % only add the Python stack if the MATLAB stack hasn't changed
            if isequal(stack, obj.OriginalMStack)
                try %#ok<TRYNC>
                    % get python traceback (tb) object
                    tb = obj.ExceptionObject{3};
                    % extract the traceback data
                    data = py.traceback.extract_tb(tb);
                    % stack is an Nx1 struct with fields file, name and line
                    n = length(data); 
                    pstack = struct('file', cell(n,1),...
                                    'name', cell(n,1),...
                                    'line', cell(n,1));
                    % for each element of data add file, name and line
                    % information to the stack
                    for index = 1:n
                        file = char(py.operator.getitem(data{index}, int32(0)));
                        name = char(py.operator.getitem(data{index}, int32(2)));
                        line = double(py.operator.getitem(data{index}, int32(1)));
                        pstack(index, 1) = struct('file', file,...
                                                  'name', name,...
                                                  'line', line);
                    end
                    % add pstack (Python stack) to top of mstack (MATLAB stack)
                    stack = [flipud(pstack); stack];
                end
            end
        end
    end
end
