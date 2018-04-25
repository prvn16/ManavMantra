%RECYCLE   Set option to move deleted files to recycle folder.
%   The purpose of the RECYCLE function is to help the DELETE
%   function determine whether the deleted files should be 
%   moved to the recycle bin on the PC and Macintosh, moved
%   to a temporary folder on Unix, or deleted.
%
%   OLDSTATE = RECYCLE(STATE) sets the recycle option to the one
%   specified by STATE.  STATE can be either 'on' or 'off'. The 
%   default value of STATE is 'off'. OLDSTATE is the state of 
%   recycle prior to being set to STATE.  
%
%   STATUS = RECYCLE returns the current state of the RECYCLE 
%   function.  It can be either 'on' or 'off'.  
%
%   You can recycle files that are stored on your local computer system,
%   but not files that you access over a network connection.  On Windows 
%   systems, when you use the DELETE function on files accessed over a 
%   network, MATLAB removes the file entirely.
%
%   See also DELETE.

%   Copyright 1984-2005 The MathWorks, Inc.
%   Built-in function.
