function aggregateTab = calculateAggregateSharpnessTable(sharpnessTable,percentResponse)
% calculateAggregateSharpnessTable computes the aggregate average vertical
%   and horizontal SFRs for a chart. The ROIs considered need to have their
%   confidenceFlags 1 in order to be a part of the aggregate.

validROIs = sharpnessTable.ROI;

horizontalROIs = 2:2:60;
verticalROIs = 1:2:60;

[~, indexHorizontalROIs, ~] = intersect(validROIs,horizontalROIs);
[~, indexVerticalROIs, ~] = intersect(validROIs,verticalROIs);

numValidHorizontalROIs = length(indexHorizontalROIs);
numValidVerticalROIs = length(indexVerticalROIs);

avgHorizontalSFR = zeros(size(sharpnessTable.SFR{1}));
avgVerticalSFR = zeros(size(sharpnessTable.SFR{1}));

if numValidHorizontalROIs > 0
    for i = 1:numValidHorizontalROIs
        ROI = indexHorizontalROIs(i);
        if sharpnessTable.confidenceFlag(ROI) == 1
            avgHorizontalSFR = avgHorizontalSFR + table2array(sharpnessTable.SFR{ROI});
        else
            numValidHorizontalROIs = numValidHorizontalROIs - 1;
        end
    end
    avgHorizontalSFR = avgHorizontalSFR/numValidHorizontalROIs;
else
    avgHorizontalSFR = [];
end

if numValidVerticalROIs > 0
    for i = 1:numValidVerticalROIs
        ROI = indexVerticalROIs(i);
        if sharpnessTable.confidenceFlag(ROI) == 1
            avgVerticalSFR = avgVerticalSFR + table2array(sharpnessTable.SFR{ROI});
        else
            numValidVerticalROIs = numValidVerticalROIs - 1;
        end
    end
    avgVerticalSFR = avgVerticalSFR/numValidVerticalROIs;
else
    avgVerticalSFR = [];
end

if ~isempty(avgVerticalSFR) && ~isempty(avgHorizontalSFR)
    Orientation = {'Vertical';'Horizontal'};
    SFR = cell(2,1);
    SFR{1} = array2table(avgVerticalSFR,'VariableNames',{'F','SFR_R','SFR_G','SFR_B','SFR_Y'});
    SFR{2} = array2table(avgHorizontalSFR,'VariableNames',{'F','SFR_R','SFR_G','SFR_B','SFR_Y'});
    aggregateTab = table(Orientation,SFR);
elseif isempty(avgVerticalSFR) && ~isempty(avgHorizontalSFR)
    Orientation = {'Horizontal'};
    SFR = cell(1,1);
    SFR{1} = array2table(avgHorizontalSFR,'VariableNames',{'F','SFR_R','SFR_G','SFR_B','SFR_Y'});
    aggregateTab = table(Orientation,SFR);
elseif ~isempty(avgVerticalSFR) && isempty(avgHorizontalSFR)
    Orientation = {'Vertical'};
    SFR = cell(1,1);
    SFR{1} = array2table(avgVerticalSFR,'VariableNames',{'F','SFR_R','SFR_G','SFR_B','SFR_Y'});
    aggregateTab = table(Orientation,SFR);
else
    aggregateTab = [];
end

if ~isempty(aggregateTab)
    aggregateTab.Properties.Description = getString(message('images:esfrChart:AggregateSharpnessTableDescription'));
    aggregateTab.Properties.VariableDescriptions = {getString(message('images:esfrChart:ROIOrientationDescription')),...
        getString(message('images:esfrChart:SFRVariableDescription'))};
    
    offsetColumns = size(aggregateTab,2);    
    for i =1:length(percentResponse)
        MTF = images.internal.testchart.calculate_mtf(aggregateTab.SFR, percentResponse(i));
        PMTF = images.internal.testchart.calculate_pmtf(aggregateTab.SFR, percentResponse(i));
        aggregateTab(:,offsetColumns+2*(i-1)+1) = MTF;
        aggregateTab(:,offsetColumns+2*(i-1)+2) = PMTF;        
        aggregateTab.Properties.VariableNames{offsetColumns+2*(i-1)+1} = ['MTF' num2str(percentResponse(i))];
        aggregateTab.Properties.VariableNames{offsetColumns+2*(i-1)+2} = ['MTF' num2str(percentResponse(i)) 'P'];
        aggregateTab.Properties.VariableDescriptions{offsetColumns+2*(i-1)+1} = getString(message('images:esfrChart:MTFVariableDescription',num2str(percentResponse(i))));
        aggregateTab.Properties.VariableDescriptions{offsetColumns+2*(i-1)+2} = getString(message('images:esfrChart:MTFPVariableDescription',num2str(percentResponse(i))));
    end
end
end