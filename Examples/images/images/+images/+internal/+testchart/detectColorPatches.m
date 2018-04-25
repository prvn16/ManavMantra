function ColorROIs = detectColorPatches(chart)
% Find dimensions of the color ROIs in an esfrChart
%     Color Patch order:
%           16         15
%           11 10    9  8
%           12          7
%
%           1           6
%           2  3     4  5
%           13         14

X = chart.modelPoints(:,1);
Y = chart.modelPoints(:,2);

ColorPatch = zeros(chart.numColorPatches,8);
ColorPatch(1,:) = [X(167) Y(167) X(168) Y(168) X(169) Y(169) X(170) Y(170)];
ColorPatch(2,:) = [X(170) Y(170) X(169) Y(169) X(173) Y(173) X(174) Y(174)];
ColorPatch(3,:) = [X(169) Y(169) X(171) Y(171) X(172) Y(172) X(173) Y(173)];
ColorPatch(4,:) = [X(161) Y(161) X(160) Y(160) X(162) Y(162) X(163) Y(163)];
ColorPatch(5,:) = [X(160) Y(160) X(159) Y(159) X(164) Y(164) X(162) Y(162)];
ColorPatch(6,:) = [X(157) Y(157) X(158) Y(158) X(159) Y(159) X(160) Y(160)];
ColorPatch(7,:) = [X(152) Y(152) X(154) Y(154) X(155) Y(155) X(156) Y(156)];
ColorPatch(8,:) = [X(150) Y(150) X(149) Y(149) X(154) Y(154) X(152) Y(152)];
ColorPatch(9,:) = [X(151) Y(151) X(150) Y(150) X(152) Y(152) X(153) Y(153)];
ColorPatch(10,:) = [X(139) Y(139) X(141) Y(141) X(142) Y(142) X(143) Y(143)];
ColorPatch(11,:) = [X(140) Y(140) X(139) Y(139) X(144) Y(144) X(143) Y(143)];
ColorPatch(12,:) = [X(144) Y(144) X(143) Y(143) X(145) Y(145) X(146) Y(146)];
ColorPatch(13,:) = [X(174) Y(174) X(173) Y(173) X(175) Y(175) X(176) Y(176)];
ColorPatch(14,:) = [X(162) Y(162) X(164) Y(164) X(165) Y(165) X(166) Y(166)];
ColorPatch(15,:) = [X(147) Y(147) X(148) Y(148) X(149) Y(149) X(150) Y(150)];
ColorPatch(16,:) = [X(137) Y(137) X(138) Y(138) X(139) Y(139) X(140) Y(140)];

half_ColorPatch_width = round(chart.colorPatch_ratio*abs(ColorPatch(1,1)-ColorPatch(1,3))/2);
half_ColorPatch_height = round(chart.colorPatch_ratio*abs(ColorPatch(1,2)-ColorPatch(1,8))/2);

ColorROIs = repmat(struct('ROI',zeros(1,4),'ROIIntensity',zeros(2*half_ColorPatch_height+1, 2*half_ColorPatch_width+1, size(chart.Image,3))),chart.numColorPatches,1);

for i=1:chart.numColorPatches
    x_cen = round(mean(ColorPatch(i,1:2:7)));
    y_cen = round(mean(ColorPatch(i,2:2:8)));
    ColorROIs(i).ROI = [x_cen-half_ColorPatch_width y_cen-half_ColorPatch_height 2*half_ColorPatch_width+1 2*half_ColorPatch_height+1];
    ColorROIs(i).ROIIntensity = chart.Image(y_cen-half_ColorPatch_height:y_cen+half_ColorPatch_height,x_cen-half_ColorPatch_width:x_cen+half_ColorPatch_width,:);
end

end
