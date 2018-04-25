classdef RespectingCountCheck < matlab.unittest.internal.constraints.AlertDescriptionCheck
    % This class is undocumented.
    
    % RespectingCountCheck - Used in IssuesWarnings to help examine the
    % warnings
    %
    %   See also
    %       matlab.unittest.internal.constraints.AlertDescriptionCheck
    
    % Copyright 2015 The MathWorks, Inc.
    properties(SetAccess=private)
        ExpectedAlertSpecifications;
        ExpectedAlertCounts;
        ActualAlertCounts;
    end
    
    methods
        function countCheck = RespectingCountCheck(expectedAlertSpecifications)
            [countCheck.ExpectedAlertSpecifications, countCheck.ExpectedAlertCounts] = ...
                                    localUniqueWithCount(expectedAlertSpecifications);
                                            
            countCheck.ActualAlertCounts = zeros(size(countCheck.ExpectedAlertCounts));
        end
        
        function check(countCheck,actAlert)
            
            for ct = 1:numel(countCheck.ExpectedAlertSpecifications)
                if countCheck.ExpectedAlertSpecifications(ct).accepts(actAlert)
                    countCheck.ActualAlertCounts(ct) = countCheck.ActualAlertCounts(ct) + 1;
                    break;
                end
            end
            
        end
        
        function tf = isDone(countCheck)
            tf = any(countCheck.ActualAlertCounts > countCheck.ExpectedAlertCounts);
        end
        
        function tf = isSatisfied(countCheck)
            tf = all(countCheck.ActualAlertCounts == countCheck.ExpectedAlertCounts);
        end
    end
end

function [uniqueDesc, count] = localUniqueWithCount(desc)
uniqueDesc = desc.empty(1, 0);
count = [];
while ~isempty(desc)
    indices = desc == desc(1);
    uniqueDesc(end+1) = desc(1); %#ok<AGROW>
    count(end+1) = nnz(indices); %#ok<AGROW>
    desc(indices) = [];
end
end