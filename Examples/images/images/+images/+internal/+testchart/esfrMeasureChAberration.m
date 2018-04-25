function chAberrationTable = esfrMeasureChAberration(chart,validROIs)
ROI = zeros(length(validROIs),1);
aberration = zeros(length(validROIs),1);
percentAberration = zeros(length(validROIs),1);
edgeProfile = cell(length(validROIs),1);
normalizedEdgeProfile = cell(length(validROIs),1);
imageCenter  = [chart.ImageCol chart.ImageRow]/2;
for i = 1:length(validROIs)
    ROInum = validROIs(i);
    [~, ~, ~, ~, esf, ~, ~, ~, ~] = images.internal.testchart.sfrmat3(1,1,[],chart.SlantedEdgeROIs(ROInum).ROIIntensity);
    [esf_norm, chAberration] = images.internal.testchart.calculateChAberration(chart.SlantedEdgeROIs(ROInum).ROI,esf);
    corrPercentChAberration = images.internal.testchart.calculateCorrPercentChAberraton( chart.SlantedEdgeROIs(ROInum).ROI, chAberration, imageCenter);
    ROI(i) = ROInum;
    aberration(i) = chAberration;
    percentAberration(i) = corrPercentChAberration;
    edgeProfile_R = esf(:,1);
    edgeProfile_G = esf(:,2);
    edgeProfile_B = esf(:,3);
    edgeProfile_Y = esf(:,4);
    edgeProfile{i} = table(edgeProfile_R,edgeProfile_G,edgeProfile_B,edgeProfile_Y);
    normalizedEdgeProfile_R = esf_norm(:,1);
    normalizedEdgeProfile_G = esf_norm(:,2);
    normalizedEdgeProfile_B = esf_norm(:,3);
    normalizedEdgeProfile_Y = esf_norm(:,4);
    normalizedEdgeProfile{i} = table(normalizedEdgeProfile_R,normalizedEdgeProfile_G,normalizedEdgeProfile_B,normalizedEdgeProfile_Y);
end
chAberrationTable = table(ROI,aberration,percentAberration,edgeProfile,normalizedEdgeProfile);

chAberrationTable.Properties.Description = getString(message('images:esfrChart:ChromaticAberrationTableDescription'));
chAberrationTable.Properties.VariableDescriptions = {getString(message('images:esfrChart:ROIIndexVariableDescription')),...
    getString(message('images:esfrChart:AberrationVariableDescription')),...
    getString(message('images:esfrChart:PercentAberrationVariableDescription')),...
    getString(message('images:esfrChart:EdgeProfileVariableDescription')),...
    getString(message('images:esfrChart:NormalizedEdgeProfileVariableDescription'))};
end