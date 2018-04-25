function varargout = wconvimg(option,X,varargin)
%WCONVIMG Image transform for images true color to gray scale 
%   and gray scale  to true color .
%   Y = WCONVIMG('col2idx',X) converts the true color image
%   X to a gray scale image Y.
%
%   Y = WCONVIMG('idx2col',X) converts the gray scale image
%   X to an true color image Y.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 28-Aug-2007.
%   Last Revision: 20-Dec-2010.
%   Copyright 1995-2010 The MathWorks, Inc.

nbIN = length(varargin);
if isequal(option,'col2idx')
    if ndims(X)==3
        X = round(0.299*X(:,:,1) + 0.587*X(:,:,2) + 0.114*X(:,:,3));
    end
end
if nbIN>0
    if isempty(varargin{1}) || ischar(varargin{1})
        map = getMAP(X,varargin{1});
    else
        map = varargin{1};
        sizeMap = size(map);        
        if ~isnumeric(map) ,    err = 1;
        elseif sizeMap(2)~=3 ,  err = 1;
        else                    err = 0;
        end        
        if err ,
            error(message('Wavelet:FunctionArgVal:Invalid_MapVal'));
        end
    end
    flagPLOT = nbIN>1;
else
    map = getMAP(X,[]);
    flagPLOT = false;
end
    
switch option
    case 'idx2col'
        IMAP = 256*map;
        Z = cell(1,3);
        X = max(X,1);
        X = min(X,size(IMAP,1));        
        X = round(X);
        for k = 1:3
            tmp = zeros(size(X));
            tmp(:) = IMAP(X(:),k);
            Z{k} = tmp;
        end
        X = uint8(cat(3,Z{:}));
        if nargout>0 , varargout{1} = X; end
        
    case 'col2idx'
        map = double(map);
        if nargout>0 
            varargout{1} = double(X);
            if nargout>1 , varargout{2} = map; end
        end
end

if flagPLOT
    figure;
    image(X);
    if isequal(option,'col2idx') , colormap(map); end
end

function map  = getMAP(X,mapName)

mini = min(X(:));
if mini<0 ,  X = X-mini+1; end
maxi = double(max(X(:)));
if isempty(mapName) , mapName = 'pink';  end 
map = feval(mapName,maxi);

