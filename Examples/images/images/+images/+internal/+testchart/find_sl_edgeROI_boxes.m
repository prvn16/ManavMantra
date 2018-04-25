function sl_edge_coords = find_sl_edgeROI_boxes(im_gray, sl_sq_coords, box_dim)
% Find the dimensions of the slanted edge ROIs
% sl_edge_coords is a 4x4 matrix with each row containing (X,Y,Width,Height)
% corresponding to the four ROIs for the square and (X,Y) being the
% coordinates of the top left corner of the ROI
% sl_sq_coords is a 4x2 matrix with each point in (X,Y) format


if(all(isnan(sl_sq_coords)))
    sl_edge_coords = nan*ones(4,4);
    return;
end

[row, col] = size(im_gray);
im_gray = imgaussfilt(im_gray,1);

sl_edge_coords = zeros(4,4);
sl_sq_coords = [sl_sq_coords(end,:); sl_sq_coords];


search_len = round(box_dim(2)/2);

for i=1:size(sl_sq_coords,1)-1
    
    isValidCorners = ~isnan(sl_sq_coords(i,1)) && ~isnan(sl_sq_coords(i+1,1));
    if isValidCorners
        x_diff = abs(sl_sq_coords(i,1) - sl_sq_coords(i+1,1));
        y_diff = abs(sl_sq_coords(i,2) - sl_sq_coords(i+1,2));
        
        x_cen = round((sl_sq_coords(i,1) + sl_sq_coords(i+1,1))/2);
        y_cen = round((sl_sq_coords(i,2) + sl_sq_coords(i+1,2))/2);
        
        
        if(x_diff>y_diff)
            
            % Find the gradient peak along the vertical line through the center
            % point
            
            ylimits = y_cen - search_len:y_cen + search_len;
            ylimits(ylimits<1) = [];
            ylimits(ylimits>row) = [];
            pts = im_gray(ylimits,x_cen);
            [mag,~] = imgradient(pts);
            [~,max_ind] = max(mag);
            refined_y_cen = ylimits(max_ind);
            
            isValidROI = (round(x_cen - box_dim(1)/2) > 0) & (round(refined_y_cen - box_dim(2)/2) >0 ) & ...
                (round(x_cen + box_dim(1)/2) < col) & (round(refined_y_cen + box_dim(2)/2) < row );
            if(isValidROI)
                sl_edge_coords(i,1)  = x_cen - box_dim(1)/2;
                sl_edge_coords(i,2)  = refined_y_cen - box_dim(2)/2;
                sl_edge_coords(i,3)  = box_dim(1);
                sl_edge_coords(i,4)  = box_dim(2);
            else
                sl_edge_coords(i,:) = [nan nan nan nan];
            end
        else
            
            % Find the gradient peak along the horizontal line through the center
            % point
            
            xlimits = x_cen - search_len:x_cen + search_len;
            xlimits(xlimits<1) = [];
            xlimits(xlimits>col) = [];
            
            pts = im_gray(y_cen, xlimits);
            [mag,~] = imgradient(pts);
            [~,max_ind] = max(mag);
            refined_x_cen = xlimits(max_ind);
            
            isValidROI = (round(refined_x_cen - box_dim(2)/2) > 0) & (round(y_cen - box_dim(1)/2) >0 ) & ...
                (round(refined_x_cen + box_dim(2)/2) < col) & (round(y_cen + box_dim(1)/2) < row);
            if(isValidROI)
                sl_edge_coords(i,1)  = refined_x_cen - box_dim(2)/2;
                sl_edge_coords(i,2)  = y_cen - box_dim(1)/2;
                sl_edge_coords(i,3)  = box_dim(2);
                sl_edge_coords(i,4)  = box_dim(1);
            else
                sl_edge_coords(i,:) = [nan nan nan nan];
            end
        end
    else
        sl_edge_coords(i,:) = [nan nan nan nan];
    end
end

sl_edge_coords = round(sl_edge_coords);

end

