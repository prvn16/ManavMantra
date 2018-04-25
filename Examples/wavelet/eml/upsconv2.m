function y = upsconv2(x,f,s,dwtARG1,dwtARG2)
% MATLAB Code Generation Library Function
%
%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

narginchk(2,5);
coder.varsize('y');
ONE = coder.internal.indexInt(1);

% Check arguments for Extension and Shift.
switch nargin
    case 3
        perFLAG  = false;  
        dwtSHIFT = [false,false];
    case 4 % Arg4 is a STRUCT
        coder.internal.prefer_const(dwtARG1);
        perFLAG  = isequal(dwtARG1.extMode,'per');
        shiftInput = coder.internal.indexInt(dwtARG1.shift2D);
        dwtSHIFT = eml_bitand(shiftInput,ONE) == ONE;
    case 5 
        coder.internal.prefer_const(dwtARG1,dwtARG2);
        perFLAG  = isequal(dwtARG1,'per');
        shiftInput = coder.internal.indexInt(dwtARG2);
        dwtSHIFT = eml_bitand(shiftInput,ONE) == ONE;
end

% Special case.
if isempty(x)
    ytype = coder.internal.scalarEg(x,f{:});
    y = zeros('like',ytype); 
    return 
end

% Define Size.
ndimX = coder.internal.indexInt(eml_ndims(x));
if ndimX > 2
    sx = 2*coder.internal.indexInt([size(x,1),size(x,2)]); 
else
    sx = 2*coder.internal.indexInt(size(x));
end
if coder.internal.isConst(isempty(s)) && isempty(s)
    if perFLAG
        s1 = sx; 
    else
        lf = coder.internal.indexInt(length(f{1}));
        s1 = sx - lf + 2; 
    end
else
    s1 = coder.internal.indexInt(s);
end
if ndimX < 3
    y = upsconv2ONE(x,f,s1,dwtSHIFT,perFLAG);
else
    y1 = upsconv2ONE(x(:,:,1),f,s1,dwtSHIFT,perFLAG);
    y = coder.nullcopy(zeros([size(y1,1),size(y1,2),3],'like',y1));
    y(:,:,1) = y1;
    y(:,:,2) = upsconv2ONE(x(:,:,2),f,s1,dwtSHIFT,perFLAG);
    y(:,:,3) = upsconv2ONE(x(:,:,3),f,s1,dwtSHIFT,perFLAG);
end

%--------------------------------------------------------------------------

function y = upsconv2ONE(z,f,s,dwtSHIFT,perFLAG)
% Compute Upsampling and Convolution.
coder.internal.prefer_const(dwtSHIFT,perFLAG);
ONE = coder.internal.indexInt(1);
if perFLAG
    lf = coder.internal.indexInt(length(f{1}));
    lfd2 = eml_rshift(lf,ONE);
    y1 = dyadup(z,'row',false,true); % undocumented "force even" syntax
    y1 = wextend('addrow','per',y1,lfd2);
    y1 = conv2(y1,f{1}(:),'full');
    y2 = coder.nullcopy(zeros(s(1),size(y1,2),'like',y1));
    lfm1 = lf - 1;
    % y = y(lf:lf+s(1)-1,:);
    for j = ONE:size(y1,2)
        for i = ONE:s(1)
            y2(i,j) = y1(lfm1 + i,j);
        end
    end
    %-------------------------------------------
    y1 = dyadup(y2,'col',false,true); % undocumented "force even" syntax
    y1 = wextend('addcol','per',y1,lfd2);
    y1 = conv2(y1,f{2}(:)','full');
    % y = y(:,lf:lf+s(2)-1);
    y = coder.nullcopy(zeros(s(1),s(2),'like',y1));
    for j = ONE:s(2)
        for i = ONE:s(1)
            y(i,j) = y1(i,lfm1 + j);
        end
    end
    %-------------------------------------------
    if dwtSHIFT(1) == 1 && dwtSHIFT(2) == 1
        y = circshift(y,int32([-1,-1]));
    elseif dwtSHIFT(1) == 1
        y = circshift(y,int32([-1,0]));
    elseif dwtSHIFT(2) == 1
        y = circshift(y,int32([0,-1]));
    end
    %-------------------------------------------
else
    y = dyadup(z,'row',false);
    y = conv2(y,f{1}(:),'full');
    y = dyadup(y,'col',false);
    y = conv2(y,f{2}(:)','full');
    y = wkeep2(y,s,'c',dwtSHIFT);
end

%--------------------------------------------------------------------------
