%WAITFORBUTTONPRESS Wait for key/buttonpress over figure.
%   T = WAITFORBUTTONPRESS stops program execution until a key or
%   mouse button is pressed over a figure window.  Returns 0
%   when terminated by a mouse buttonpress, or 1 when terminated
%   by a keypress.  Additional information about the terminating
%   event is available from the current figure.
%
%   Example:
%       f = figure;
%       disp('This will print immediately');
%       keydown = waitforbuttonpress;
%       if (keydown == 0)
%           disp('Mouse button was pressed');
%       else
%           disp('Key was pressed');
%       end
%       close(f);
%         
%       
%   See also GINPUT, GCF.

%   Copyright 1984-2006 The MathWorks, Inc.
%   Built-in function.


