function [Gx, Gy, Gz] = imgradientxyz(varargin)%#codegen
%IMGRADIENTXYZ Find the directional gradients of a 3-D image.
%
%   Copyright 2015-2017 The MathWorks, Inc.

narginchk(1,2);

validateattributes(varargin{1},{'numeric','logical'},{'3d','nonsparse','real'}, ...
                       mfilename,'I',1);

% Error out if input image is scalar or 2D
coder.internal.errorIf(numel(size(varargin{1})) < 3,...
        'images:validate:tooFewDimensions', 'I', 3); 


I = varargin{1};

if (nargin > 1)
    methodstrings = {'sobel','prewitt','central', ...
        'intermediate'};
    
    validateattributes(varargin{1},{'numeric','logical'},{'3d','nonsparse','real'}, ...
                       mfilename,'I',1);
   

    coder.internal.errorIf(~ischar(varargin{2}),...
        'images:validate:invalidMethodClass'); 
    
     method = validatestring(varargin{2}, methodstrings, ...
        mfilename, 'Method', 2);
    
else
    method = 'sobel';
end                   
                   

if isa(I,'single')
   classToCast = 'single';
else
    classToCast = 'double';
end

switch method
    case 'sobel'
        hx = coder.nullcopy(zeros(3,3,3));
        % 3-D Kernel for sobel along X, Y and Z direction
        hx(:,:,1) = [-1 0 1; -3 0 3; -1 0 1];
        hx(:,:,2) = [-3 0 3; -6 0 6; -3 0 3];
        hx(:,:,3) = [-1 0 1; -3 0 3; -1 0 1];
        
        hy = coder.nullcopy(zeros(3,3,3));
        hy(:,:,1) = [-1 -3 -1; 0 0 0; 1 3 1];
        hy(:,:,2) = [-3 -6 -3; 0 0 0; 3 6 3];
        hy(:,:,3) = [-1 -3 -1; 0 0 0; 1 3 1];
        
        hz = coder.nullcopy(zeros(3,3,3));
        hz(:,:,1) = [-1 -3 -1; -3 -6 -3; -1 -3 -1];
        hz(:,:,2) = [0 0 0; 0 0 0; 0 0 0];
        hz(:,:,3) = [1 3 1; 3 6 3; 1 3 1];
        
        im = cast(I, classToCast);
        Gx = imfilter(im,hx,'replicate');
        Gy = imfilter(im,hy,'replicate');
        Gz = imfilter(im,hz,'replicate');

        
    case 'prewitt'
        
        % 3-D Kernel for prewitt along X, Y and Z direction
        hx = coder.nullcopy(zeros(3,3,3));
        hx(:,:,1) = [-1 0 1; -1 0 1; -1 0 1];
        hx(:,:,2) = [-1 0 1; -1 0 1; -1 0 1];
        hx(:,:,3) = [-1 0 1; -1 0 1; -1 0 1];
        
        hy = coder.nullcopy(zeros(3,3,3));
        hy(:,:,1) = [-1 -1 -1; 0 0 0; 1 1 1];
        hy(:,:,2) = [-1 -1 -1; 0 0 0; 1 1 1];
        hy(:,:,3) = [-1 -1 -1; 0 0 0; 1 1 1];
            
        hz = coder.nullcopy(zeros(3,3,3));
        hz(:,:,1) = [-1 -1 -1; -1 -1 -1; -1 -1 -1];
        hz(:,:,2) = [0 0 0; 0 0 0; 0 0 0];
        hz(:,:,3) = [1 1 1; 1 1 1; 1 1 1];
        
        im = cast(I, classToCast);
        Gx = imfilter(im,hx,'replicate');
        Gy = imfilter(im,hy,'replicate');
        Gz = imfilter(im,hz,'replicate');      
        
    case 'central' 
        
        im = cast(I, classToCast);
        
        if isrow(im)            
            Gx = gradient(im);
            if nargout > 1
                Gy = zeros(size(im),'like', im);
            end
            if nargout > 2
                Gz = zeros(size(im),'like', im);
            end
            
        elseif iscolumn(im)            
            Gx = zeros(size(im),'like', im);
            if nargout > 1
                Gy = gradient(im);
            end  
            if nargout > 2
                Gz = zeros(size(im),'like', im);
            end
            
        elseif ismatrix(im)
            [Gx, Gy] = gradient(im);
            Gz = zeros(size(im),'like', im);
            
        else            
            [Gx, Gy, Gz] = gradient(im);
        end
   
    case 'intermediate' 

        Gx = cast(zeros(size(I)), classToCast);
        Gy = cast(zeros(size(I)), classToCast);
        Gz = cast(zeros(size(I)), classToCast);
        
        if coder.isColumnMajor
            for k = 1:(size(I,3))
                for j = 1:(size(I,2))
                    for i = 1:(size(I,1))
                        
                        if(j < size(I,2))
                            Gx(i,j,k) = cast(I(i, j+1, k), classToCast) -...
                                cast(I(i, j, k), classToCast);
                        end
                        if(i < size(I,1))
                            Gy(i,j,k) = cast(I(i+1, j, k), classToCast) -...
                                cast(I(i, j, k), classToCast);
                        end
                        if(k < size(I,3))
                            Gz(i,j,k) = cast(I(i, j, k+1), classToCast) -...
                                cast(I(i, j, k), classToCast);
                        end
                    end
                end
            end
        else % coder.isRowMajor
            for i = 1:(size(I,1))
                for j = 1:(size(I,2))
                    for k = 1:(size(I,3))
                        
                        if(j < size(I,2))
                            Gx(i,j,k) = cast(I(i, j+1, k), classToCast) -...
                                cast(I(i, j, k), classToCast);
                        end
                        if(i < size(I,1))
                            Gy(i,j,k) = cast(I(i+1, j, k), classToCast) -...
                                cast(I(i, j, k), classToCast);
                        end
                        if(k < size(I,3))
                            Gz(i,j,k) = cast(I(i, j, k+1), classToCast) -...
                                cast(I(i, j, k), classToCast);
                        end
                    end
                end
            end
        end
                    
    otherwise
        Gx = coder.nullcopy(cast(zeros(size(I)), classToCast));
        Gy = coder.nullcopy(cast(zeros(size(I)), classToCast));
        Gz = coder.nullcopy(cast(zeros(size(I)), classToCast));
        assert(false, 'Unsupported method.');
                
end

end
