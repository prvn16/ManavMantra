function colorTable = esfrMeasureColor(chart)
%eSFRMeasureColor Perform color measurements on an esfrChart
%
%   colorTable = images.internal.testchart.measureColor(CHART) measures color values of
%   the color ROIs in a esfrChart image.
%
%   The rows of the colorTable correspond to individual color
%   ROIs sequentially numbered as displayed when using the
%   displayChart function. Variables or columns of the colorTable
%   correspond to the following:
%
%       1. ROI          : Index of an ROI
%       2. Measured_R   : Mean of R channel pixels in a ROI
%       3. Measured_G   : Mean of G channel pixels in a ROI
%       4. Measured_B   : Mean of B channel pixels in a ROI
%       5. Reference_L  : Reference L values
%       6. Reference_a  : Reference a values
%       7. Reference_b  : Reference b values
%       8. Delta_E      : Euclidean color distance between measured and
%                           reference color values as outlined
%                           in CIE76
%
%   NOTE
%   ----
%   Use of this function is discouraged as it might change in future
%   releases. Use esfrChart/measureColor instead.
%
%   I = imread('eSFRTestImage.jpg');
%   chart = esfrChart(I);
%   displayChart(chart);
%   colorTable = images.internal.testchart.eSFRMeasureColor(chart);

%   Copyright 2017 The MathWorks, Inc.

numPatches = chart.numColorPatches;
measured_R = zeros(chart.numColorPatches,1,'like',chart.Image);
measured_G = zeros(chart.numColorPatches,1,'like',chart.Image);
measured_B = zeros(chart.numColorPatches,1,'like',chart.Image);

for i = 1:chart.numColorPatches
    measured_R(i) = mean2(chart.ColorROIs(i).ROIIntensity(:,:,1));
    measured_G(i) = mean2(chart.ColorROIs(i).ROIIntensity(:,:,2));
    measured_B(i) = mean2(chart.ColorROIs(i).ROIIntensity(:,:,3));
end
measured_Lab = rgb2lab([measured_R measured_G measured_B]);

delta_E = sqrt(sum((chart.ReferenceColorLab-measured_Lab).^2,2));

ROI = 1:numPatches;
ROI = ROI';

columnNames = {'ROI',...
    'Measured_R',...
    'Measured_G',...
    'Measured_B',...
    'Reference_L',...
    'Reference_a',...
    'Reference_b',...
    'Delta_E'};

colorTable = table(ROI, measured_R, measured_G, measured_B, chart.ReferenceColorLab(:,1), chart.ReferenceColorLab(:,2), chart.ReferenceColorLab(:,3), delta_E, 'VariableNames',columnNames);

colorTable.Properties.Description = getString(message('images:esfrChart:ColorTableDescription'));
colorTable.Properties.VariableDescriptions = {getString(message('images:esfrChart:ROIIndexVariableDescription')),...
    getString(message('images:esfrChart:Measured_RVariableDescription')), ...
    getString(message('images:esfrChart:Measured_GVariableDescription')), ...
    getString(message('images:esfrChart:Measured_BVariableDescription')), ...
    getString(message('images:esfrChart:Reference_LVariableDescription')), ...
    getString(message('images:esfrChart:Reference_aVariableDescription')), ...
    getString(message('images:esfrChart:Reference_bVariableDescription')), ...
    getString(message('images:esfrChart:Delta_EVariableDescription'))};
end