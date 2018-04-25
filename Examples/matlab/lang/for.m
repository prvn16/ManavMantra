%FOR    Repeat statements a specific number of times.
%   The general form of a FOR statement is:
% 
%      FOR variable = expr, statement, ..., statement END
% 
%   The columns of the expression are stored one at a time in
%   the variable and then the following statements, up to the
%   END, are executed. The expression is often of the form X:Y,
%   in which case its columns are simply scalars. Some examples
%   (assume N has already been assigned a value).
% 
%        for R = 1:N
%            for C = 1:N
%                A(R,C) = 1/(R+C-1);
%            end
%        end
% 
%   Step S with increments of -0.1
%        for S = 1.0: -0.1: 0.0, do_some_task(S), end
%
%   Set E to the unit N-vectors
%        for E = eye(N), do_some_task(E), end
%
%   Long loops are more memory efficient when the colon expression appears
%   in the FOR statement since the index vector is never created.
%
%   The BREAK statement can be used to terminate the loop prematurely.
%
%   See also PARFOR, IF, WHILE, SWITCH, BREAK, CONTINUE, END, COLON.

%   Copyright 1984-2008 The MathWorks, Inc.
%   Built-in function.
