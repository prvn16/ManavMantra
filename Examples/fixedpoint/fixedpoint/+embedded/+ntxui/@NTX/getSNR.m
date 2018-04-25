function [snr,snrVar] = getSNR(ntx)
% Compute SQNR (signal to quantized noise) estimate

%   Copyright 2010 The MathWorks, Inc.

if ntx.NumSSQE==0
    % No quantization data recorded, or data type changed
    % We cannot determine the SQNR
    snr = NaN;
    snrVar = 0;
elseif ntx.SSQE==0
    % No quantization error recorded
    snr = inf;
    snrVar = 0;
else
    snr = 10*log10(ntx.SSQ/ntx.SSQE);
    snrVar = 0; % xxx
    % ud.NumSSQE
end
