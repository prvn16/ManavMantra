function stopFlag = sspause(figNumber)
%SSPAUSE Pause function for the Slide Show format.
%   The SSPAUSE function allows a Slide Show demo to interact
%   properly with the buttons in the Slide Show GUI shell.
%   If there is no GUI shell being used, SSPAUSE will pause
%   and display a prompt to continue by pressing a key.
%
%   See the template file SSTMPLT for an example of how to use
%   the SSPAUSE function.

%   Ned Gulley, 6-21-93
%   Copyright 1984-2014 The MathWorks, Inc.

if figNumber == 0,
   stopFlag = 0;
   disp(' ');
   disp([' ',getString(message('MATLAB:playshow:PressAnyKeyToContinue'))]);
   disp(' ');
   pause;
   
else
   wait = 0;
   stop = -1;
   
   figure(figNumber);
   axHndl = gca;
   hndlList = get(figNumber,'UserData');
   
   startHndl = hndlList(2);
   contHndl = hndlList(3);
   stopHndl = hndlList(4);
   autoHndl = hndlList(5);
   helpHndl = hndlList(6);
   closeHndl = hndlList(7);
   
   % ====== Start Wait Loop
   % Strangely enough, we want to turn off the watch pointer
   set(figNumber,'Pointer','arrow');
   if get(autoHndl,'Value'),
      % If the autoHndl flag is set, don't wait for the user, just
      % pause a little and then continue.
      pause(2);
   else
      set(axHndl,'Userdata',wait);
      while get(axHndl,'Userdata') == wait,
         % holding loop can be exited w/Cont or Stop button.
         drawnow
      end;
   end;
   
   if get(axHndl,'Userdata') == stop,
      set([startHndl helpHndl closeHndl],'Enable','on');
      set([stopHndl contHndl],'Enable','off');
      stopFlag = 1;
   else
      stopFlag = 0;
   end;
   
   % Now turn the watch back on
   set(figNumber,'Pointer','watch');
   % ====== End Wait Loop
   
end     % if figNumber==0 ...
