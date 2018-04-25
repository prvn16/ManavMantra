function [varargout] = bwselect(varargin) %#codegen
% Copyright 2013-2015 The MathWorks, Inc.

%% Parse Inputs
narginchk(0,6);

switch nargin

case 3
    % BWSELECT(BW,Xi,Yi)
    BW = varargin{1};
    xi = varargin{2};
    yi = varargin{3};
    coder.varsize('r',[]);
    coder.varsize('c',[]);
    r = round(yi);
    c = round(xi);
    n = coder.internal.const(8);
    
case 4
    % BWSELECT(BW,Xi,Yi,N)
    BW = varargin{1};
    xi = varargin{2};
    yi = varargin{3};
    coder.varsize('r',[]);
    coder.varsize('c',[]);
    r = round(yi);
    c = round(xi);
    
    eml_invariant(eml_is_const(varargin{4}),...
        eml_message('images:validate:connNotConst'), 'IfNotConst','Fail');
    n = varargin{4};
    validateattributes(n, {'numeric'}, {'scalar'}, mfilename); %#ok<EMCA>
    
otherwise
    eml_invariant(false,eml_message('images:bwselect:unsupportedSyntax'));
    
end

validateattributes(BW,{'logical' 'numeric'},{'2d' 'nonsparse'}, mfilename); %#ok<EMCA>

if ~islogical(BW)
    BW = (BW ~= 0); 
else
    BW = BW; %#ok<ASGSL>
end

if ((isequal(size(BW,1),1)) && (size(BW,2)>1))
    column_BW = true;
    BW = BW';
    
    tmp = r;
    r = c;
    c = tmp;
else
    column_BW = false;
    BW = BW; %#ok<ASGSL>
end

badPix = find((r < 1) | (r > size(BW,1)) | ...
              (c < 1) | (c > size(BW,2))); 
          
if (~isempty(badPix))
    eml_warning('images:bwselect:outOfRange'); 
    r(badPix) = [];
    c(badPix) = [];
end

%% Output Processing
seed_indices = sub2ind(size(BW), r(:), c(:));
BW2_temp = imfill(~BW, seed_indices, n);
BW2_temp = BW2_temp & BW;

if (isempty(BW2_temp))
    IDX1 = zeros(double(size(BW2_temp,1)>0), double(size(BW2_temp,2)>0));
else
    IDX1 = find(BW2_temp);
end

if (column_BW)
    IDX = IDX1';
    BW2 = BW2_temp';
else
    IDX = IDX1;
    BW2 = BW2_temp;
end

switch nargout
    
case 1
    % BW2 = BWSELECT(...)
    varargout{1} = BW2;
    
case 2
    % [BW2,IDX] = BWSELECT(...)
    varargout{1} = BW2;
    varargout{2} = IDX;  
    
otherwise
    % [X,Y,BW2,...] = BWSELECT(...)
    eml_invariant(false,eml_message('images:bwselect:unsupportedSyntax'));
end

