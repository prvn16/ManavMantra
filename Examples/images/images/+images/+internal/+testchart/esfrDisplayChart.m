function esfrDisplayChart(chart, displayEdgeROIs, displayGrayPatches, displayColorPatches, displayRegistrationPoints, parentAxis)
% Displays esfrChart
 
%   Copyright 2017 The MathWorks, Inc.
im = im2double(chart.Image);
X = chart.refinedPoints(:,1);
Y = chart.refinedPoints(:,2);
roi_border = round(max(1,min([chart.ImageRow chart.ImageCol])*0.005));

fig = im;
if displayRegistrationPoints
    % Display The registration points
    points_im = zeros(chart.ImageRow, chart.ImageCol);
    for i=177:180, if(~isnan(Y(i))),points_im(Y(i),X(i)) = 1;end;end
    bb = strel('diamond',max([1 ceil(size(chart.Image,2)/200)]));
    points_im = imdilate(points_im, bb);
    fig = imoverlay(im, points_im,'r');
end

if displayEdgeROIs
    % Display boxes around slanted edges on the chart image
    n = zeros(chart.ImageRow, chart.ImageCol);
    box_text_x = zeros(size(chart.SlantedEdgeROIs,1),1);
    box_text_y = zeros(size(chart.SlantedEdgeROIs,1),1);
    box_num = cell(size(chart.SlantedEdgeROIs,1),1);
    
    for i = 1:size(chart.SlantedEdgeROIs,1)
        sl_edge_box = chart.SlantedEdgeROIs(i).ROI;
        if(all(~isnan(sl_edge_box)))
            n(sl_edge_box(2):sl_edge_box(2)+sl_edge_box(4),sl_edge_box(1):sl_edge_box(1)+sl_edge_box(3)) = 1;
            n(sl_edge_box(2)+roi_border:sl_edge_box(2)+sl_edge_box(4)-roi_border,sl_edge_box(1)+roi_border:sl_edge_box(1)+sl_edge_box(3)-roi_border) = 0;
        end
        box_text_x(i) = round(sl_edge_box(1)+sl_edge_box(3)/2);
        box_text_y(i) = round(sl_edge_box(2)+sl_edge_box(4)/2);
        box_num{i} = num2str(i);
    end
    fig = imoverlay(fig, n,[1 1 0.8]);
end

if displayGrayPatches
    % Display gray patches
    Gray_im = zeros(chart.ImageRow, chart.ImageCol);
    Gray_text_x = zeros(chart.numGrayPatches,1);
    Gray_text_y = zeros(chart.numGrayPatches,1);
    Gray_text = cell(chart.numGrayPatches,1);
    for i=1:chart.numGrayPatches
        ROI = chart.GrayROIs(i).ROI;
        Gray_im(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3)) = 1;
        Gray_im(ROI(2)+roi_border:ROI(2)+ROI(4)-roi_border,ROI(1)+roi_border:ROI(1)+ROI(3)-roi_border) = 0;
        
        Gray_text_x(i) = round(ROI(1)+ROI(3)/2);
        Gray_text_y(i) = round(ROI(2)+ROI(4)/2);
        Gray_text{i} = num2str(i);
    end
    fig = imoverlay(fig, Gray_im,[0 0.5 1]);
end

if displayColorPatches
    % Display color patches
    Color_im = zeros(chart.ImageRow, chart.ImageCol);
    Color_text_x = zeros(chart.numColorPatches,1);
    Color_text_y = zeros(chart.numColorPatches,1);
    Color_text = cell(chart.numColorPatches,1);
    
    for i=1:chart.numColorPatches
        ROI = chart.ColorROIs(i).ROI;
        Color_im(ROI(2):ROI(2)+ROI(4),ROI(1):ROI(1)+ROI(3)) = 1;
        Color_im(ROI(2)+roi_border:ROI(2)+ROI(4)-roi_border,ROI(1)+roi_border:ROI(1)+ROI(3)-roi_border) = 0;
        
        Color_text_x(i) = round(ROI(1)+ROI(3)/2);
        Color_text_y(i) = round(ROI(2)+ROI(4)/2);
        Color_text{i} = num2str(i);
    end
    fig = imoverlay(fig, Color_im,[1 0.8 0.3]);
end

if isempty(parentAxis)
    hIm = imshow(fig, 'Border','tight');
    h = ancestor(hIm,'figure');
    set(h,'Name',getString(message('images:esfrChart:esfrChartFigureName')));
else
    imshow(fig, 'Border','tight','Parent', parentAxis)
end

if displayEdgeROIs
    text(box_text_x,box_text_y,box_num,'FontSize',15,'Fontweight','bold','Color',[0.2 1 0.2]);
end
if displayGrayPatches
    text(Gray_text_x,Gray_text_y,Gray_text,'FontSize',15,'Fontweight','bold','Color',[1 0.2 0.2]);
end
if displayColorPatches
    text(Color_text_x,Color_text_y, Color_text,'FontSize',15,'Fontweight','bold','Color',[1 1 1]);
end

end