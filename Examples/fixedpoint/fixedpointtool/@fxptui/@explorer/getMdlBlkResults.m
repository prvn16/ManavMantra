function results = getMdlBlkResults(h, varargin)
% GETMDLBLKRESULTS Gets the results from the model block nodes from the entire hierarchy.

% Copyright 2012 MathWorks Inc

blkDgms = h.getBlkDgmNodes;
results = [];
for i = 1:length(blkDgms)
    curBlkDgm = blkDgms(i); 
    results = [results curBlkDgm.getModelReferenceResults(varargin)];
end

