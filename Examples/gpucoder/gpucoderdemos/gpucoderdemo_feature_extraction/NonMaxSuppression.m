function intPoints = NonMaxSuppression(intImage, responseMap) %#codegen

%   Copyright 2017 The MathWorks, Inc.
%
% This function performs non-maximal suppression to filter out the useful
% interest points in the image. For each octave, we examine a set of 3
% layers (bottom, middle, top). A threshold is applied to the response of 
% each pixel and it is subsequently compared to its neighboring pixels in a 
% 3x3x3 neighborhood. If an interest point is detected, interpolation is 
% performed to determine its exact location in scale-space. The output of 
% this step is an array of interest points

% Mapping responses to octaves based on filter sizes used for each octave
filter_map = [1,2,3,4; 2,4,5,6; 4,6,7,8; 6,8,9,10; 8,10,11,12];

% Image dimensions
imgDim    = size(intImage);
i_height  = imgDim(1);
i_width   = imgDim(2);
ipt = struct('x',single(0),'y',single(0),'scale',single(0),'orientation',single(0),'laplacian',int32(0));
coder.varsize( 'intPoints', [1,2000], [false, true]);
intPoints = repmat(ipt, 1, 2000);
ctr = int32(1);

% Iterate over a set of 3 layers within each octave
for o = 1:5
    
    for i = 1:2
        
        b = filter_map(o,i);
        m = filter_map(o,i+1);
        t = filter_map(o,i+2);
        
        b_filter    = responseMap(b).filter;
        m_filter    = responseMap(m).filter;
        t_filter    = responseMap(t).filter;
        t_step      = responseMap(t).step;
        filterStep  = m_filter - b_filter;
        
        b_responses = responseMap(b).responses;
        m_responses = responseMap(m).responses;
        t_responses = responseMap(t).responses;
        
        m_laplacian = responseMap(m).laplacian;
        m_width     = responseMap(m).width;
        t_width     = responseMap(t).width;
        
        % Perform non-maximal suppression
        [keyMatrix, result_xi, result_xr, result_xc]  = NonMaxCalc(intImage, t_filter, t_step, ...
            b_responses, m_responses, t_responses);
              
        % Accumulate interest points
        for c = 0:i_width-1
            for r = 0:i_height-1
                if(keyMatrix(r+1,c+1))
                    if (ctr <= 2000)
                        xi = result_xi(r+1,c+1);
                        xr = result_xr(r+1,c+1);
                        xc = result_xc(r+1,c+1);
                        
                        intPoints(ctr).x = single((c + xc) * t_step);
                        intPoints(ctr).y = single((r + xr) * t_step);
                        intPoints(ctr).scale = single((0.1333) * (m_filter + xi * filterStep));
                        intPoints(ctr).laplacian = int32(getLaplacian(m_laplacian, m_width, r, c, t_width));
                        intPoints(ctr).orientation = single(0);
                        ctr = ctr + 1;
                    end
                end
            end
        end
        
    end
    
end

    % Return the first 2000 interest points detected
    if ctr < 2001
        intPoints = intPoints(1:(ctr-1));
    end

end

function resp = getLaplacian(obj_lapl, obj_width, row, column, src_width)

if nargin < 5
    resp = obj_lapl(row + 1, column + 1);
else
    scale = floor(obj_width / src_width);
    resp = obj_lapl((scale * row) + 1, (scale * column) + 1);
end

end
