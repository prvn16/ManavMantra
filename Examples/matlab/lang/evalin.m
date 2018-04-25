%EVALIN Evaluate expression in workspace.
%   EVALIN(WS,'expression') evaluates 'expression' in the context of
%   the workspace WS.  WS can be 'caller' or 'base'.  It is similar to EVAL
%   except that you can control which workspace the expression is
%   evaluated in.
%
%   [X,Y,Z,...] = EVALIN(WS,'expression') returns output arguments from
%   the expression.
%
%   See also EVAL, ASSIGNIN.

%   Copyright 1984-2005 The MathWorks, Inc.

%   Built-in function
