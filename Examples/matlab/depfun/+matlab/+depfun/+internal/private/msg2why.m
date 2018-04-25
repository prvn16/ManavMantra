function w = msg2why(msg, varargin)
% msg2why Convert a message object to a why structure.
%
% The use of this intermediate structure allows for more flexibility in RDL
% explanations -- they may be either character strings or MATLAB message 
% objects.
%
% If msg is a message object, both the string message and the string identifier
% are extracted from the message object. If msg is a string, the user may 
% provide an optional id input, which msg2why copies to the id field without
% interpretation (meaning id can be of any type -- but string is suggested).

    w.identifier = '';
    w.message = '';
    w.rule = '';

    if isa(msg, 'message')
        w.identifier = msg.Identifier;
        w.message = getString(msg);
        if nargin == 2
            w.rule = varargin{1};
        end
    elseif isa(msg, 'char')
        w.message = msg;
        if nargin > 1
            w.identifier = varargin{1};
        end
        if nargin > 2
            w.rule = varargin{2};
        end
    end
    
