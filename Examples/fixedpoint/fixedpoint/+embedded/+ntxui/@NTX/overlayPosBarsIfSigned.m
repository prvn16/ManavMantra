function overlayPosBarsIfSigned(ntx,posVal,xp,zp)
%Positive values that lie on the MSB of the data type will overflow for
%signed types. 

%   Copyright 2012 MathWorks, Inc.

if ntx.IsSigned
    if any(ntx.BinEdges >= ntx.LastOver)
        idx = ntx.BinEdges >= ntx.LastOver;
        % Positive values present on MSB when using signed format
        % Overlay positive histogram data
        if nargin < 2
            % Get bin counts for bar display
            [posVal, negVal] = getBarData(ntx);
            [xp,zp] = embedded.ntxui.NTX.createXBarData(ntx.BinEdges(idx),ntx.HistBarWidth, ntx.HistBarOffset);
        end
        
        % Setup positive-bars patch data
        N = numel(posVal(:,idx));
        yp = [negVal(:,idx); posVal(:,idx)+negVal(:,idx); posVal(:,idx)+negVal(:,idx); negVal(:,idx)];
        % Set zp to be over "total" bar (which is at z=-2),
        % and above signline (which is at z=-1.9), so we set
        % z=-1.85 ... which is zp+.15, where zp=-2.
        set(ntx.hBarPos,'Visible','on', ...
            'XData',xp,'YData',yp,'ZData',zp+.15);
    else
        set(ntx.hBarPos,'Visible','off');
    end
else
    set(ntx.hBarPos,'Visible','off');
end
