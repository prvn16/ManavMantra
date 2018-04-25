function overlayNegBarsIfUnsigned(ntx,negVal,xp,zp)
% If negative values present while unsigned data type selected,
% overlay "overflow" type bars over normal bars, with height equal to
% negative count of the corresponding histogram bin.
%
% The decision to do this for the special case of negative values in the
% underflow region is based on .SmallNegAreOverflow, which depends on
% rounding mode.

%   Copyright 2010 The MathWorks, Inc.

if ~ntx.IsSigned && (ntx.DataNegCnt > 0)
    % Negative values present when using unsigned format
    % Overlay negative histogram data
    if nargin < 2
        % Get bin counts for bar display
        [~,negVal] = getBarData(ntx);
        [xp,zp] = embedded.ntxui.NTX.createXBarData(ntx.BinEdges,ntx.HistBarWidth, ntx.HistBarOffset);
    end
    
    % Setup negative-bars patch data
    N = numel(negVal);
    yp = [zeros(1,N); negVal; negVal; zeros(1,N)];
    % Set zp to be over "total" bar (which is at z=-2),
    % and below signline (which is at z=-1.9), so we set
    % z=-1.95 ... which is zp+.05, where zp=-2.
    set(ntx.hBarNeg,'Visible','on', ...
        'XData',xp,'YData',yp,'ZData',zp+.05);
else
    set(ntx.hBarNeg,'Visible','off');
end
