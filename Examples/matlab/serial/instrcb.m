function instrcb(val,obj,event)
%INSTRCB Wrapper for serial object callback.
%
%  INSTRCB(FCN,OBJ,EVENT) calls the function FCN with parameters
%  OBJ and EVENT.
%

%   Copyright 1999-2016 The MathWorks, Inc. 

% Store the warning state. Note, reset warning to address 
% G309961 which was causing the same last warn to be rethrown.
lastwarn('');
s = warning('backtrace', 'off');

switch (nargin)
case 1
    try
        evalin('base', val);
    catch aException
        eval('warning(s)');
        rethrow(aException);
    end
case 3    
    % Construct the event structure.
    eventStruct = struct(event);
    eventStruct.Data = struct(eventStruct.Data);
  
    if isa(val, 'function_handle')
        val = {val};
    end
    
    % Execute callback function.
    try
        if isempty(val)
            % reset warning state
            eval('warning(s)');
            % We don't have a valid function handle so just return
            % This can happen if there are events queued up and the 
            % first callback is disabling susbsequent callbacks
            return;
        end
        feval(val{1}, obj, eventStruct, val{2:end});
    catch aException
        eval('warning(s)');
        rethrow(aException);
    end
end

% Restore the warning state.
eval('warning(s)');
  
% Report the last warning if it occurred.
if ~isempty(lastwarn)
   warning(message('MATLAB:serial:instrcb:invalidcallback', lastwarn));
end

