function gtable = cmgamdef(c)
%CMGAMDEF Default gamma correction table.
%   CMGAMDEF('computer') returns the default gamma correction 
%   table for the computer in the string or char vector computer.  See the
%   function COMPUTER for possibilities.  CMGAMDEF is called
%   by CMGAMMA.
%
%   CMGAMDEF returns the default gamma correction table for
%   the computer currently running MATLAB.
%
%   See also CMGAMMA, COMPUTER.

%   Copyright 1993-2017 The MathWorks, Inc.

if nargin == 0 
    c = computer; 
end
if ~ischar(matlab.images.internal.stringToChar(c)) 
    error(message('images:cmgamdef:expectedString')); 
end

% Note: the gtable can have any number of rows.  See TABLE1 and
% CMGAMMA for details.
gtable = (0:.05:1)'*ones(1,4);
