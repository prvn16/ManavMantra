%DISPLAY Display array.
%   DISPLAY(X) is called for the object X when the semicolon is not used
%   to terminate a statement. 
%
%   For example,
%     X = datetime(2014,1:5,1)
%   calls DISPLAY(X) while
%     X = datetime(2014,1:5,1);
%   does not.
%
%   A typical implementation of DISPLAY calls DISP to do most of the work.
%   To customize the display of objects, overload the DISP function.
%   Note that DISP does not display empty arrays.
%   
%   See also DISP, matlab.mixin.CustomDisplay, EVALC, 

%   Copyright 1984-2016 The MathWorks, Inc.
%   Built-in function.
