function savefipref
%SAVEFIPREF Save fixed-point preferences
%   SAVEFIPREF Saves the current fixed-point preferences to the
%   preferences file so that it will be persistent between MATLAB
%   sessions.
%
%
%   Examples:
%     % These display preferences are specific to the fi object.
%     p = fipref;
%     p.NumberDisplay      = 'RealWorldValue';
%     p.NumericTypeDisplay = 'short';
%     p.FimathDisplay      = 'none';
%
%     a = fi(pi)
%       % a = 
%       % 
%       %     3.1416
%       %      s16,13
%
%     % savefipref  % Saves fi display preferences for next MATLAB session
%
%    resetfipref % reset to factory setting
%
%
%   See also FI, FIMATH, FIPREF, NUMERICTYPE, QUANTIZER, FIXEDPOINT

%   Thomas A. Bryan, 5 April 2004
%   Copyright 2003-2013 The MathWorks, Inc.

P = fipref;
P.savefipref;
