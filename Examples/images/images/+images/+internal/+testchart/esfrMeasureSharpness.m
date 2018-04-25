function sharpnessTable = esfrMeasureSharpness(chart,validROIs,percentResponse)
% Function to measure sharpness using an esfrChart object

% Copyright 2017 The MathWorks, Inc.

numROIs = length(validROIs);
ROI = validROIs';
slopeAngle = zeros(numROIs,1);
confidenceFlag = false(numROIs,1);
SFR = cell(numROIs,1);
comment = cell(numROIs,1);

for i = 1:numROIs
    ROInum = validROIs(i);
    SFR_confidence_flg = true;
    [~, dat, ~, ~, ~, ~, ~, contrast_test, slope_deg] = images.internal.testchart.sfrmat3(1,1,[],chart.SlantedEdgeROIs(ROInum).ROIIntensity);
    if(contrast_test<0.2)
        SFR_confidence_flg = false;
        comment{i} = getString(message('images:esfrChart:ROIContrastSharpnessComment'));
    end
    if (slope_deg<3.5)||(slope_deg>15)
        SFR_confidence_flg = false;
        comment{i} = getString(message('images:esfrChart:SlopeAngleSharpnessComment'));
    end
    slopeAngle(i) = slope_deg;
    confidenceFlag(i) = SFR_confidence_flg;
    F = dat(:,1);
    SFR_R = dat(:,2);
    SFR_G = dat(:,3);
    SFR_B = dat(:,4);
    SFR_Y = dat(:,5);
    SFR{i} = table(F,SFR_R,SFR_G,SFR_B,SFR_Y);
end

sharpnessTable = table(ROI,slopeAngle,confidenceFlag,SFR, comment);
sharpnessTable.Properties.Description = getString(message('images:esfrChart:SharpnessTableDescription'));
sharpnessTable.Properties.VariableDescriptions = {getString(message('images:esfrChart:ROIIndexVariableDescription')),...
    getString(message('images:esfrChart:SlopeAngleVariableDescription')), ...
    getString(message('images:esfrChart:ConfidenceFlagVariableDescription')),...
    getString(message('images:esfrChart:SFRVariableDescription')),...
    getString(message('images:esfrChart:CommentVariableDescription'))};

offsetColumns = size(sharpnessTable,2);
for i =1:length(percentResponse)
    MTF = images.internal.testchart.calculate_mtf(sharpnessTable.SFR, percentResponse(i));
    PMTF = images.internal.testchart.calculate_pmtf(sharpnessTable.SFR, percentResponse(i));
    sharpnessTable(:,offsetColumns+2*(i-1)+1) = MTF;
    sharpnessTable(:,offsetColumns+2*(i-1)+2) = PMTF;
    sharpnessTable.Properties.VariableNames{offsetColumns+2*(i-1)+1} = ['MTF' num2str(percentResponse(i))];
    sharpnessTable.Properties.VariableNames{offsetColumns+2*(i-1)+2} = ['MTF' num2str(percentResponse(i)) 'P'];
    sharpnessTable.Properties.VariableDescriptions{offsetColumns+2*(i-1)+1} = getString(message('images:esfrChart:MTFVariableDescription',num2str(percentResponse(i))));
    sharpnessTable.Properties.VariableDescriptions{offsetColumns+2*(i-1)+2} = getString(message('images:esfrChart:MTFPVariableDescription',num2str(percentResponse(i))));
end

end
