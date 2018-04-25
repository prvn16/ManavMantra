%INPUT  Prompt for user input. 
%   RESULT = INPUT(PROMPT) displays the PROMPT string on the screen, waits
%   for input from the keyboard, evaluates any expressions in the input,
%   and returns the value in RESULT. To evaluate expressions, INPUT accesses
%   variables in the current workspace. If you press the return key without
%   entering anything, INPUT returns an empty matrix.
%
%   STR = INPUT(PROMPT,'s') returns the entered text as a MATLAB string,
%   without evaluating expressions.
%
%   To create a prompt that spans several lines, use '\n' to indicate each
%   new line. To include a backslash ('\') in the prompt, use '\\'.
%
%   Example:
%
%      reply = input('Do you want more? Y/N [Y]:','s');
%      if isempty(reply)
%         reply = 'Y';
%      end
%
%   See also KEYBOARD.

%   Copyright 1984-2011 The MathWorks, Inc.
%   Built-in function.
