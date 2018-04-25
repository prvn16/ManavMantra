function [output_block fun_nargout] = blockprocFunDispatcher(fun,...
    block_struct,trim_border)
% Executes user function FUN on the given block struct.  If an exception is
% thrown, additional diagnostics are added to the error message while
% preserving the stack trace.

%   Copyright 2010-2012 The MathWorks, Inc.

try
    % support "nargout == 0" user functions that do things like gather
    % statistics on image blocks but need not return anything
    try
        output_block = fun(block_struct);
        fun_nargout = 1;
    catch some_exception
        if strcmpi(some_exception.identifier,'MATLAB:maxlhs') || ...
                strcmpi(some_exception.identifier,'MATLAB:TooManyOutputs')
            % user FUN has nargout == 0, recover and return empty
            output_block = [];
            fun(block_struct);
            fun_nargout = 0;
            
        else
            % some other legit error, rethrow it
            rethrow(some_exception);
        end
    end
    
catch userfun_exception
    % the user function has errored, rethrow the error with some additional
    % information as the "cause".
    
    new_ex = images.internal.BlockprocUserfunException();
    new_ex = new_ex.addCause(userfun_exception);
    throw(new_ex);
    
end


% trim output if necessary
if trim_border
    
    % get border size from struct
    bdr = block_struct.border;
    
    % trim the border
    output_block = output_block(bdr(1)+1:end-bdr(1),bdr(2)+1:end-bdr(2),:);
    
end

