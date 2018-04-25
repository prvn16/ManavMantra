%WAITFOR Block execution and wait for event.
%   WAITFOR(H) returns when the graphics object identified by H
%   is deleted or when Ctrl-C is typed in the Command Window. If H does 
%   not exist, waitfor returns immediately without processing any events.
%
%   WAITFOR(H,'PropertyName'), in addition to the conditions in the 
%   previous syntax, returns when the value of 'PropertyName' for the 
%   graphics object H changes. If 'PropertyName' is not a valid property 
%   for the object, waitfor returns immediately without processing 
%   any events.
%
%   WAITFOR(H,'PropertyName',PropertyValue), in addition to the
%   conditions in the previous syntax, returns when the value of
%   'PropertyName' for the graphics object H changes to PropertyValue. 
%   If 'PropertyName' is set to PropertyValue, waitfor returns 
%   immediately without processing any events.
%
%   While waitfor blocks an execution stream, it processes events as 
%   would drawnow, allowing callbacks to execute.  Nested calls to 
%   waitfor are supported, and earlier calls to waitfor will not return 
%   until all later calls have returned, even if the condition upon which 
%   the earlier call is blocking has been met.
%
%   Examples:
%       f = warndlg('This is a warning.', 'A Warning Dialog');
%       disp('This prints immediately');
%       waitfor(f);
%       disp('This prints after the warning dialog is closed');
%
%       f = figure('Name', 'My Figure');
%       h = uicontrol('String', 'Change Name', 'Position', [20 20 200 40], ...
%       'Callback', 'h_gcbf = gcbf; h_gcbf.Name = num2str(rand(1))');
%       disp('This prints immediately');
%       waitfor(f, 'Name');
%       disp('This prints after the button is clicked to change the figure''s name');
%       close(f);
%
%       f = figure;
%       textH = text(.5, .5, 'Hello');
%       textH.Editing = 'on';
%       disp('This prints immediately');
%       waitfor(textH,'Editing','off');
%       disp('This prints after text editing is complete');
%       close(f);

%
%   See also DRAWNOW, UIWAIT, UIRESUME.

%   Copyright 1984-2014 The MathWorks, Inc.
%   Built-in function.
