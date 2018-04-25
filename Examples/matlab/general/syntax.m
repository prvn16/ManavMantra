%   You can enter MATLAB commands using either a FUNCTION format or a
%   COMMAND format, as described below.
%
%
% FUNCTION FORMAT
%
%   A command in this format consists of the function name followed by 
%   one or more arguments separated by commas and enclosed in parentheses.
%
%      functionname(arg1, arg2, ..., argn)
%
%   You may assign the output of the function to one or more output values
%   separated by commas and enclosed in square brackets ([]).
%
%      [out1, out2, ..., outn] = functionname(arg1, arg2, ..., argn)
%
%   For example,
%
%      copyfile(srcfile, '..\mytests', 'writable')
%      [x1, x2, x3, x4] = deal(A{:})
%
%
%   Arguments are passed to the function by value.  See the examples below,
%   under ARGUMENT PASSING.
%
%
% COMMAND FORMAT
%
%   A command in this format consists of the function name followed by 
%   one or more arguments separated by spaces.
%
%      functionname arg1 arg2 ... argn
%
%   Unlike the function format, you may not assign the output of the function
%   to a variable.  Attempting to do so generates an error.
%
%   For example
%
%      save mydata.mat x y z
%      import java.awt.Button java.lang.String
%
%
%   Arguments are treated as character vectors.  See the examples
%   below, under ARGUMENT PASSING.
%
%
% ARGUMENT PASSING
%
%   In the FUNCTION format, arguments are passed by value.
%   In the COMMAND format, arguments are treated as character vectors.
%
%
%   In the following example, 
%
%      disp(A) - passes the value of variable A to the disp function
%      disp A  - passes the variable name, 'A'
%
%         A = pi;
%
%         disp(A)                    % Function format
%             3.1416
%
%         disp A                     % Command format
%             A
%
%
%   In the next example,
%
%      strcmp(txt1, txt2) - compares the character vectors 'one' and 'one'
%      strcmp txt1 txt2   - compares the character vectors 'txt1' and 'txt2'
%
%         txt1 = 'one';    txt2 = 'one';
%
%         strcmp(txt1, txt2)         % Function format
%         ans =
%              1        (equal)
%
%         strcmp txt1 txt2           % Command format
%         ans =
%              0        (unequal)
%
%
% PASSING CHARACTER VECTORS
%
%   When using the FUNCTION format to pass a character vector to a
%   function, you must enclose the text in single quotes, ('my_text').
%
%   For example, to create a new directory called MYAPPTESTS, use
%
%      mkdir('myapptests')
%
%   On the other hand, variables that contain character vectors do not need
%   to be enclosed in quotes.
%
%      dirname = 'myapptests';
%      mkdir(dirname)
%
%   See also CHECKCODE.

%   Copyright 1984-2016 The MathWorks, Inc. 
%   Date:
