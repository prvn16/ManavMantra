function resetDataHist(ntx)
% Reset state values for data histogram
% Does NOT execute any graphical updates of UI

%   Copyright 2010 The MathWorks, Inc.

% Reset histogram states
%
% Instead of empty vectors, we choose to initialize to a single-bin
% histogram with zero count.
%
% xxx this assumption isn't the best approach
%  If the data is not zero-mean, this zero-bin assumption forces the
%  bincenter and bincount vectors to extend all the way down to zero!
%
ntx.NegBinCounts = 0; % # of neg values in this (abs val) bin
ntx.PosBinCounts = 0; % # of pos values in this (abs val) bin
ntx.BinCounts    = 0;  % a bit redundant: combined pos+neg count vector
ntx.BinEdges     = 0;

% xxx The follow initialization values are better,
% in that we're not making assumptions that we have an initial
% data value of zero.  But!  this breaks the code - fix this!
%
% ntx.NegBinCounts = []; % # of neg values in this (abs val) bin
% ntx.PosBinCounts = []; % # of pos values in this (abs val) bin
% ntx.BinCounts  = [];  % a bit redundant: combined pos+neg count vector
% ntx.BinEdges = [];

% Reset counts
% NOTE: These states are part of base NTX, not any particular dialog
%       This rule is followed so that other dialogs could use these values,
%       or other optimization techniques.
%
ntx.DataCount   = 0;  % number of data values (scalars) since last reset
ntx.DataZeroCnt = 0;  % number of zeros in data
ntx.DataPosCnt  = 0;  % number of positive values in data
ntx.DataNegCnt  = 0;  % number of negative values in data

% Reset stats
% See NOTE above...
%
ntx.DataMax    = []; % maximum positive value; must preset to empty
ntx.DataMin    = []; % maximum negative value; must preset to empty
ntx.DataSum    = 0;  % Sum of (possibly signed) data
ntx.SSQ        = 0;  % Sum of Squared Data (for SNR)
ntx.SSQE       = 0;  % Sum of Squared Quantization Error (for SNR)
ntx.NumSSQE    = 0;  % Independent sample count for SSQE/SNR
