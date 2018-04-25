function [keyMatrix, result_xi, result_xr, result_xc] = NonMaxCalc(intImage, t_filter, t_step, ...
                                                        b_responses, m_responses, t_responses) %#codegen

%   Copyright 2017 The MathWorks, Inc.
     
imgDim    = size(intImage);
i_height  = imgDim(1);
i_width   = imgDim(2);  

keyMatrix = zeros(i_height, i_width,'uint8');
result_xi = zeros(i_height, i_width,'single');
result_xr = zeros(i_height, i_width,'single');
result_xc = zeros(i_height, i_width,'single');

% Perform non-maximal suppression
coder.gpu.kernel()
for c = 0:i_width-1
    
    for r = 0:i_height-1
        
        [keyMatrix(r+1,c+1), result_xi(r+1,c+1), result_xr(r+1,c+1), result_xc(r+1,c+1)] = isExtremum(r, c, t_filter, t_step, ...
                                                                                           b_responses, m_responses, t_responses);
    end
    
end

end

function [isext, xi, xr, xc] = isExtremum(r, c, t_filter, t_step, b_responses, m_responses, t_responses)

isext = 1;
xi = single(0);
xr = single(0);
xc = single(0);

thresh = single(0.0004);
layerBorder = floor((t_filter + 1) / (2 * t_step));

size_b    = size(b_responses);
b_width   = size_b(2);

size_m    = size(m_responses);
m_width   = size_m(2);

size_t    = size(t_responses);
t_height  = size_t(1);
t_width   = size_t(2);

% Eliminate border pixels
if (r <= layerBorder || r >= t_height - layerBorder || c <= layerBorder || c >= t_width - layerBorder)
    isext = 0;
else
    
    % Threshold the pixel response
    candidate = getResponse(m_responses, m_width, r, c, t_width);
    if (candidate < thresh)
        isext = 0;
    else
        
        % Compare pixel responses within 3x3x3 neighborhood
        for rr = -1:1
            for cc = -1:1
                if ( getResponse(t_responses, t_width, r+rr, c+cc) >= candidate || ...
                        ((rr ~= 0 || cc ~= 0) && getResponse(m_responses, m_width, r+rr, c+cc, t_width) >= candidate) || ...
                        getResponse(b_responses, b_width, r+rr, c+cc, t_width) >= candidate)
                    isext = 0;
                end
            end
        end
        
    end
    
end


% Perform interpolation to determine exact location of the interest point
if isext
    
    isext = 0;
  
    dx  = (getResponse(m_responses, m_width, r, c + 1, t_width) - getResponse(m_responses, m_width, r, c - 1, t_width)) / 2.0;
    dy  = (getResponse(m_responses, m_width, r + 1, c, t_width) - getResponse(m_responses, m_width, r - 1, c, t_width)) / 2.0;
    ds  = (getResponse(t_responses, t_width, r, c) - getResponse(b_responses, b_width, r, c, t_width)) / 2.0;

    dD = [dx ; dy ; ds];
    
    v   = getResponse(m_responses, m_width, r, c, t_width);

    dxx = getResponse(m_responses, m_width, r, c + 1, t_width) + getResponse(m_responses, m_width, r, c - 1, t_width) - 2 * v;
    dyy = getResponse(m_responses, m_width, r + 1, c, t_width) + getResponse(m_responses, m_width, r - 1, c, t_width) - 2 * v;
    dss = getResponse(t_responses, t_width, r, c) + getResponse(b_responses, b_width, r, c, t_width) - 2 * v;

    dxy = ( getResponse(m_responses, m_width, r + 1, c + 1, t_width) - getResponse(m_responses, m_width, r + 1, c - 1, t_width) - ...
        getResponse(m_responses, m_width, r - 1, c + 1, t_width) + getResponse(m_responses, m_width, r - 1, c - 1, t_width) ) / 4.0;

    dxs = ( getResponse(t_responses, t_width, r, c + 1) - getResponse(t_responses, t_width, r, c - 1) -  ...
        getResponse(b_responses, b_width, r, c + 1, t_width) + getResponse(b_responses, b_width, r, c - 1, t_width) ) / 4.0;

    dys = ( getResponse(t_responses, t_width, r + 1, c) - getResponse(t_responses, t_width, r - 1, c) - ...
        getResponse(b_responses, b_width, r + 1, c, t_width) + getResponse(b_responses, b_width, r - 1, c, t_width) ) / 4.0;
    
     H = [dxx, dxy, dxs; dxy, dyy, dys; dxs, dys, dss];

    xres = -1 * (H\dD);
    
    xi = xres(3);
    xr = xres(2);
    xc = xres(1);
    
    if(abs(xi) < 0.5  &&  abs(xr) < 0.5  &&  abs(xc) < 0.5)
        isext = 1;
    end
      
end

end

function resp = getResponse(obj_resp, obj_width, row, column, src_width)

if nargin < 5
    resp = obj_resp(row + 1, column + 1);
else
    scale = floor(obj_width / src_width);
    resp = obj_resp((scale * row) + 1, (scale * column) + 1);
end

end
