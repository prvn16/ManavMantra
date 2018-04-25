function [respMatrix, lapMatrix] = FastHessianCalc(intImage, height, width, step, filter) %#codegen

%   Copyright 2017 The MathWorks, Inc.

    respMatrix = zeros(height, width,'single');
    lapMatrix  = zeros(height, width,'uint8');

    bor = (filter - 1) / 2;     % border size for this filter
    l   = filter / 3;           % lobe size for this filter 
    w   = filter;               % filter size
    inverse_area = 1/(w*w);     % normalization factor
    
    coder.gpu.kernel();
    for ac = 0:width-1
        
        for ar = 0:height-1
        
            % get the image coordinates
            r = ar * step;
            c = ac * step;
            
            % Compute elements of the Hessian Matrix
            Dxx = BoxIntegral(intImage, r - l + 1, c - bor, 2*l - 1, w) ...
                - BoxIntegral(intImage, r - l + 1, ceil(c - l / 2), 2*l - 1, l)*3;
            
            Dyy = BoxIntegral(intImage, r - bor, c - l + 1, w, 2*l - 1) ...
                - BoxIntegral(intImage, ceil(r - l / 2), c - l + 1, l, 2*l - 1)*3;
            
            Dxy = BoxIntegral(intImage, r - l, c + 1, l, l) ...
                + BoxIntegral(intImage, r + 1, c - l, l, l) ...
                - BoxIntegral(intImage, r - l, c - l, l, l) ...
                - BoxIntegral(intImage, r + 1, c + 1, l, l);
            
            % Normalize the filter responses with respect to their size
            Dxx = Dxx * inverse_area;
            Dyy = Dyy * inverse_area;
            Dxy = Dxy * inverse_area;
            
            % Get the determinant of hessian response & laplacian sign
            respMatrix(ar+1,ac+1) = (Dxx * Dyy - single(0.81) * Dxy * Dxy);
            
            if Dxx + Dyy >= 0
                lapMatrix(ar+1,ac+1) = uint8(1);
            else
                lapMatrix(ar+1,ac+1) = uint8(0);
            end
            
        end
        
    end
    
end
