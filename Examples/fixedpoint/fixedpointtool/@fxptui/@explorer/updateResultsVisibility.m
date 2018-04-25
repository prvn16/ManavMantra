function updateResultsVisibility(h,res)
%UPDATERESULTSVISIBILITY  Update visibility property of results
%   Copyright 2013-2014 The MathWorks, Inc.

% We need to process the results from both the model and submodel
% nodes.
if nargin < 2
    res = [h.getBlkDgmResults h.getMdlBlkResults];
end

if ~isempty(res)
    indexFilteringChoice = h.ResultsPaneFilteringChoice;
    switch indexFilteringChoice
      case 0 % ALL SIGNALS
        for i = 1:length(res)
            res(i).updateVisibility;
        end
      case 1 % ALL LOGGED SIGNALS
        for i = 1:length(res)
            res(i).setVisibility(res(i).IsPlottable);
        end
      case 2 % ALL Min/Max data
        for i = 1:length(res)
            res(i).setVisibility(res(i).hasMinMaxInformation);
        end
      case 3 % All results that have overflows
        for i = 1:length(res)
            res(i).setVisibility(res(i).HasOverflowInformation);
        end
      case 4 % All results that require attention
        for i = 1:length(res)
            res(i).setVisibility(res(i).HasAlert);
        end
      case 5 % Results that share the same DT
        for i = 1:length(res)
            curHasDTGroup = ~isempty(res(i).getDTGroup);
            if curHasDTGroup
                res(i).updateVisibility;
            else
                res(i).setVisibility(false);
            end
        end
    end
end

%-------------------------------------------------------
% [EOF]
