function resetglobalfimath
% RESETGLOBALFIMATH Resets global fimath to factory setting
%
%   RESETGLOBALFIMATH resets the user configured global fimath to the factory setting:
%    
%           RoundingMethod: Nearest
%           OverflowAction: Saturate
%              ProductMode: FullPrecision
%     MaxProductWordLength: 65535
%                  SumMode: FullPrecision
%         MaxSumWordLength: 65535
%            CastBeforeSum: true
%    
%
%   Example:
%     F = fimath('RoundingMethod','Floor','OverflowAction','Wrap');
%     globalfimath(F);
%     F1 = fimath; % Will be the same as F
%     A = fi(pi); % A's fimath will be the same as F     
%     resetglobalfimath;
%     A = fi(pi); % A's fimath will now be the factory setting    
%
%   See also GLOBALFIMATH, REMOVEGLOBALFIMATHPREF    
    
%   Copyright 2003-2012 The MathWorks, Inc.
    
embedded.fimath.ResetGlobalFimath;
