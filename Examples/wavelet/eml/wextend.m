function y = wextend(type,mode,x,lf,location)
%MATLAB Code Generation Library Function

%  Limitations:
%  * When type is 1, '1', or '1d', the output may be a column vector when
%    MATLAB returns a row vector if the input x is a vector, variable-size,
%    and not a variable-length row vector type (1-by-:). No error or
%    warning is issued. The values in the return vector match MATLAB.
%    To get a row vector instead of column vector in this case, use x(:).'
%    instead of passing in x directly.

%  Copyright 1995-2017 The MathWorks, Inc.
%#codegen

narginchk(4,5);
coder.internal.prefer_const(type,mode,lf);
if nargin == 5
    coder.internal.prefer_const(location);
end
if ischar(type)
    type = lower(type);
end
validateattributes(lf,{'numeric'},{'integer','positive'},'wextend','L');
if isequal(type,1) || isequal(type,'1') || isequal(type,'1d')
    validateattributes(x,{'numeric'},{'vector'},'wextend','X');
    lfi = coder.internal.indexInt(lf(1));
    if nargin < 5 || isempty(location)
        loc = 'b';
    else
        loc = testLoc(location(1));
    end
    if coder.internal.isConst(isvector(x)) && isvector(x)
        y = wextend1d(mode,x,lfi,loc);
    else
        % Nonvector input with 1d extension must be converted to a vector.
        y = wextend1d(mode,x(:),lfi,loc);
    end
elseif isequal(type,2) || isequal(type,'2') || isequal(type,'2d')
    validateattributes(x,{'numeric'},{'nonempty'},'wextend','X');
    if nargin < 5 || isempty(location)
        locRow = 'b';
        locCol = 'b';
    else
        locRow = testLoc(location(1));
        if length(location) < 2
            locCol = testLoc(location(1));
        else
            locCol = testLoc(location(2));
        end
    end
    lfRow = coder.internal.indexInt(lf(1));
    if length(lf) < 2
        lfCol = lfRow;
    else
        lfCol = coder.internal.indexInt(lf(2));
    end
    y = wextend2d(mode,x,lfRow,lfCol,locRow,locCol);
else
    coder.internal.assert(strcmp(type,'ar') || strcmp(type,'ac') || ...
        strcmp(type,'addrow') || strcmp(type,'addcol'), ...
        'Wavelet:FunctionArgVal:Invalid_ArgVal');
    % Construct the equivalent 2-D location vector.
    if nargin < 5
        loc = 'b';
    else
        loc = testLoc(location(1));
    end
    if strcmp(type,'ar') || strcmp(type,'addrow')
        location1 = [loc,'n'];
    else
        location1 = ['n',loc];
    end
    % Call WEXTEND with the new location vector.
    y = wextend('2d',mode,x,lf,location1);
end

%--------------------------------------------------------------------------

function y = wextend1d(mode,x,lf,loc)
% Extend a vector.
coder.internal.prefer_const(mode,lf,loc)
ZERO = coder.internal.indexInt(0);
ROW = coder.internal.isConst(isrow(x)) && isrow(x);
if isequal(loc,'n')
    y = x;
elseif strcmp(mode,'zpd') || isempty(x)
    % Zero Padding.
    if ROW
        y = zeropad(x,ZERO,lf,'n',loc);
    else
        y = zeropad(x,lf,ZERO,loc,'n');
    end
elseif strcmp(mode,'sym') || strcmp(mode,'symh')
    % Half-point Symmetrization .
    if ROW
        y = HP_SymExt(x,ZERO,lf,'n',loc);
    else
        y = HP_SymExt(x,lf,ZERO,loc,'n');
    end
elseif strcmp(mode,'symw')
    % Whole-point Symmetrization.
    if ROW
        y = WP_SymExt(x,ZERO,lf,'n',loc);
    else
        y = WP_SymExt(x,lf,ZERO,loc,'n');
    end
elseif strcmp(mode,'asym') || strcmp(mode,'asymh')
    % Half-point Anti-Symmetrization.
    if ROW
        y = HP_AntiSymExt(x,ZERO,lf,'n',loc);
    else
        y = HP_AntiSymExt(x,lf,ZERO,loc,'n');
    end
elseif strcmp(mode,'asymw')
    % Whole-point Anti-Symmetrization.
    if ROW
        y = WP_AntiSymExt(x,ZERO,lf,'n',loc);
    else
        y = WP_AntiSymExt(x,lf,ZERO,loc,'n');
    end
elseif strcmp(mode,'sp0')
    % Smooth padding of order 0.
    if ROW
        y = SP0Ext(x,ZERO,lf,'n',loc);
    else
        y = SP0Ext(x,lf,ZERO,loc,'n');
    end
elseif strcmp(mode,'spd') || strcmp(mode,'sp1')
    % Smooth padding of order 1.
    if ROW
        y = SP1Ext(x,ZERO,lf,'n',loc);
    else
        y = SP1Ext(x,lf,ZERO,loc,'n');
    end
elseif strcmp(mode,'ppd')
    % Periodization.
    if ROW
        y = PerExt(x,ZERO,lf,'n',loc,false);
    else
        y = PerExt(x,lf,ZERO,loc,'n',false);
    end
else % if strcmp(mode,'per')
    % Periodization.
    coder.internal.assert(strcmp(mode,'per'), ...
        'Wavelet:FunctionArgVal:Invalid_PadMode');
    if ROW
        y = PerExt(x,ZERO,lf,'n',loc,true);
    else
        y = PerExt(x,lf,ZERO,loc,'n',true);
    end
end

%--------------------------------------------------------------------------

function y = wextend2d(mode,x,lfRow,lfCol,locRow,locCol)
% Extend a matrix. If x is N-D with N >= 3, y will be a 3-D output
% constructed with the extensions of each 2-D "page" x(:,:,k).
coder.internal.prefer_const(mode,lfRow,lfCol,locRow,locCol);
mx = coder.internal.indexInt(size(x,1));
nx = coder.internal.indexInt(size(x,2));
if eml_ndims(x) > 2
    % Construct a 3-D output by extending each mx-by-nx page of x.
    % Count the number of pages.
    npages = coder.internal.prodsize(x,'above',2);
    % Make a "dummy" call to wextend with 2-D input to get the size of
    % one page of the output.
    ytmp = wextend2d(mode,zeros(mx,nx,'like',x),lfRow,lfCol,locRow,locCol);
    % Allocate the output.
    y = coder.nullcopy( ...
        zeros(size(ytmp,1),size(ytmp,2),npages,'like',ytmp));
    % Extend each page.
    for k = 1:npages
        y(:,:,k) = wextend2d(mode,x(:,:,k),lfRow,lfCol,locRow,locCol);
    end
elseif strcmp(mode,'zpd') || isempty(x) % Zero Padding.
    y = zeropad(x,lfRow,lfCol,locRow,locCol);
elseif strcmp(mode,'sym') || strcmp(mode,'symh')
    % Symmetrization half-point.
    y = HP_SymExt(x,lfRow,lfCol,locRow,locCol);
elseif strcmp(mode,'symw')
    % Symmetrization whole-point.
    y = WP_SymExt(x,lfRow,lfCol,locRow,locCol);
elseif strcmp(mode,'asym') || strcmp(mode,'asymh')
    % Half-point Anti-Symmetrization.
    y = HP_AntiSymExt(x,lfRow,lfCol,locRow,locCol);
elseif strcmp(mode,'asymw')
    % Whole-point Anti-Symmetrization.
    y = WP_AntiSymExt(x,lfRow,lfCol,locRow,locCol);
elseif strcmp(mode,'sp0')
    % Smooth padding of order 0.
    y = SP0Ext(x,lfRow,lfCol,locRow,locCol);
elseif strcmp(mode,'spd') || strcmp(mode,'sp1')
    % Smooth padding of order 1.
    y = SP1Ext(x,lfRow,lfCol,locRow,locCol);
elseif strcmp(mode,'ppd')
    % Periodization.
    y = PerExt(x,lfRow,lfCol,locRow,locCol,false);
else % if strcmp(mode,'per')
    % Periodization.
    coder.internal.assert(strcmp(mode,'per'), ...
        'Wavelet:FunctionArgVal:Invalid_PadMode');
    y = PerExt(x,lfRow,lfCol,locRow,locCol,true);
end

%--------------------------------------------------------------------------

function location = testLoc(location_input)
coder.inline('always');
coder.internal.prefer_const(location_input);
if ~ischar(location_input)
    location = 'b';
else
    switch location_input
        case {'n','l','u','b','r','d'}
            location = location_input;
        otherwise
            location = 'b';
    end
end

%--------------------------------------------------------------------------

function [nNew,nLeft,nRight,offsetRight] = padSize(n,lf,loc)
coder.inline('always');
coder.internal.prefer_const(n,lf,loc);
ZERO = coder.internal.indexInt(0);
switch loc
    case {'l','u'}
        nLeft = lf;
        nRight = ZERO;
        offsetRight = n + lf;
    case {'r','d'}
        nLeft = ZERO;
        nRight = lf;
        offsetRight = n;
    case {'b'}
        nLeft = lf;
        nRight = lf;
        offsetRight = n + lf;
    otherwise % case {'n'}
        nLeft = ZERO;
        nRight = ZERO;
        offsetRight = n;
end
nNew = nLeft + n + nRight;

%--------------------------------------------------------------------------

function y = zeropad(x,newrows,newcols,locrow,loccol)
coder.internal.prefer_const(newrows,newcols,locrow,loccol);
m = coder.internal.indexInt(size(x,1));
n = coder.internal.prodsize(x,'above',1);
[my,mTop] = padSize(m,newrows,locrow);
[ny,nLeft] = padSize(n,newcols,loccol);
y = zeros(my,ny,'like',x);
for j = 1:n
    for i = 1:m
        y(mTop + i,nLeft + j) = x(i,j);
    end
end

%--------------------------------------------------------------------------

function y = HP_SymExt(x,lfRow,lfCol,locRow,locCol)
% Symmetrization half-point.
coder.internal.prefer_const(lfRow,lfCol,locRow,locCol);
mx = coder.internal.indexInt(size(x,1));
nx = coder.internal.prodsize(x,'above',1);
locRowN = isequal(locRow,'n');
locColN = isequal(locCol,'n');
if locRowN && locColN
    y = x;
elseif locRowN
    J = getSymIndices(nx,lfCol,locCol);
    y = x(:,J);
elseif locColN
    I = getSymIndices(mx,lfRow,locRow);
    y = x(I,:);
else
    I = getSymIndices(mx,lfRow,locRow);
    J = getSymIndices(nx,lfCol,locCol);
    my = coder.internal.indexInt(length(I));
    ny = coder.internal.indexInt(length(J));
    y = zeros(my,ny,'like',x);
    for j = 1:ny
        for i = 1:my
            y(i,j) = x(I(i),J(j));
        end
    end
end

%--------------------------------------------------------------------------

function y = PerExt(x,lfRow,lfCol,locRow,locCol,forceEven)
% Periodization.
coder.internal.prefer_const(lfRow,lfCol,locRow,locCol,forceEven);
mx = coder.internal.indexInt(size(x,1));
nx = coder.internal.prodsize(x,'above',1);
locRowN = isequal(locRow,'n');
locColN = isequal(locCol,'n');
if locRowN && locColN
    y = x;
elseif locRowN
    J = getPerIndices(nx,lfCol,locCol,forceEven);
    y = x(:,J);
elseif locColN
    I = getPerIndices(mx,lfRow,locRow,forceEven);
    y = x(I,:);
else
    I = getPerIndices(mx,lfRow,locRow,forceEven);
    J = getPerIndices(nx,lfCol,locCol,forceEven);
    my = coder.internal.indexInt(length(I));
    ny = coder.internal.indexInt(length(J));
    y = zeros(my,ny,'like',x);
    for j = 1:ny
        for i = 1:my
            y(i,j) = x(I(i),J(j));
        end
    end
end

%--------------------------------------------------------------------------

function y = SP0Ext(x,lfRow,lfCol,locRow,locCol)
coder.internal.prefer_const(lfRow,lfCol,locRow,locCol);
m = coder.internal.indexInt(size(x,1));
n = coder.internal.prodsize(x,'above',1);
[my,mTop,mBottom,offsetBottom] = padSize(m,lfRow,locRow);
[ny,nLeft,nRight,offsetRight] = padSize(n,lfCol,locCol);
y = coder.nullcopy(zeros(my,ny,'like',x));
% Divide the output into 9 sections.
% [ Y11 Y12 Y13;
%  Y21  X  Y23;
%  Y31 Y32 Y33 ]
% If they are not empty, the peripheral sections will be filled with
% the nearest elements of X.
% Fill Y11, Y21, and Y31.
for j = 1:nLeft
    % Fill Y11.
    for i = 1:mTop
        y(i,j) = x(1,1);
    end
    % Fill Y21.
    for i = 1:m
        y(mTop + i,j) = x(i,1);
    end
    % Fill Y31.
    for i = 1:mBottom
        y(offsetBottom + i,j) = x(m,1);
    end
end
% Fill Y12, copy X, and fill Y32.
for j = 1:n
    % Fill Y12.
    for i = 1:mTop
        y(i,nLeft + j) = x(1,j);
    end
    % Copy X.
    for i = 1:m
        y(mTop + i,nLeft + j) = x(i,j);
    end
    % Fill Y32.
    for i = 1:mBottom
        y(offsetBottom + i,nLeft + j) = x(m,j);
    end
end
% Fill Y13, Y23, and Y33.
for j = 1:nRight
    % Fill Y13.
    for i = 1:mTop
        y(i,offsetRight + j) = x(1,n);
    end
    % Fill Y23.
    for i = 1:m
        y(mTop + i,offsetRight + j) = x(i,n);
    end
    % Fill Y33.
    for i = 1:mBottom
        y(offsetBottom + i,offsetRight + j) = x(m,n);
    end
end

%--------------------------------------------------------------------------

function y = SP1Ext(x,lfRow,lfCol,locRow,locCol,originalType)
coder.internal.prefer_const(lfRow,lfCol,locRow,locCol);
if nargin == 6
    coder.internal.prefer_const(originalType);
else
    originalType = class(x);
end
if isinteger(x) && isa(x,originalType)
    % Cast to a larger signed type to do the extension if one is available.
    % For 'int64' and 'uint64', cast to double.
    if isa(x,'uint64') || isa(x,'int64') || ~isreal(x)
        if ~allFitInDouble(x)
            coder.internal.warning( ...
                'Wavelet:FunctionInput:PrecisionLoss',class(x));
        end
        ytmp = SP1Ext(double(x),lfRow,lfCol,locRow,locCol,class(x));
    elseif isa(x,'uint32') || isa(x,'int32')
        ytmp = SP1Ext(int64(x),lfRow,lfCol,locRow,locCol,class(x));
    elseif isa(x,'uint16') || isa(x,'int16')
        ytmp = SP1Ext(int32(x),lfRow,lfCol,locRow,locCol,class(x));
    else
        ytmp = SP1Ext(int16(x),lfRow,lfCol,locRow,locCol,class(x));
    end
    y = cast(ytmp,'like',x);
    return
end
m = coder.internal.indexInt(size(x,1));
n = coder.internal.prodsize(x,'above',1);
[~,mTop,mBottom,offsetBottom] = padSize(m,lfRow,locRow);
[~,nLeft,nRight,offsetRight] = padSize(n,lfCol,locCol);
y = SP0Ext(x,lfRow,lfCol,locRow,locCol);
% The output y is already filled for any cases where m <= 1 or n <= 1. We
% only need to fill in where first order extension is possible.
if m > 1
    DOTOP = mTop > 0;
    DOBOTTOM = mBottom > 0;
else
    DOTOP = false;
    DOBOTTOM = false;
end
if n > 1
    DOLEFT = nLeft > 0;
    DORIGHT = nRight > 0;
else
    DOLEFT = false;
    DORIGHT = false;
end
% Divide the output into 9 sections.
% [ Y11 Y12 Y13;
%  Y21  X  Y23;
%  Y31 Y32 Y33 ]
% If they are not empty, the peripheral sections will be filled.
if DOLEFT
    % Fill Y21.
    for j = 1:nLeft
        dj = cast(nLeft - j + 1,'like',real(x));
        for i = 1:m
            y(mTop + i,j) = x(i,1) + dj*(x(i,1) - x(i,2));
        end
        if DOTOP
            % Fill Y11.
            yj = y(mTop + 1,j);
            delta =  yj - y(mTop + 2,j);
            for i = 1:mTop
                di = cast(mTop - i + 1,'like',real(x));
                y(i,j) = yj + di*delta;
            end
        end
        if DOBOTTOM
            % Fill Y31.
            yj = y(offsetBottom,j);
            delta =  yj - y(offsetBottom - 1,j);
            for i = 1:mBottom
                di = cast(i,'like',real(x));
                y(offsetBottom + i,j) = yj + di*delta;
            end
        end
    end
end
% Fill Y12 and Y32.
for j = 1:n
    if DOTOP
        % Fill Y12.
        delta = x(1,j) - x(2,j);
        for i = 1:mTop
            di = cast(mTop - i + 1,'like',real(x));
            y(i,nLeft + j) = x(1,j) + di*delta;
        end
    end
    if DOBOTTOM
        % Fill Y32.
        delta = x(m,j) - x(m - 1,j);
        for i = 1:mBottom
            di = cast(i,'like',real(x));
            y(offsetBottom + i,nLeft + j) = x(m,j) + di*delta;
        end
    end
end
if DORIGHT
    % Fill Y23.
    for j = 1:nRight
        dj = cast(j,'like',real(x));
        for i = 1:m
            y(mTop + i,offsetRight + j) = ...
                x(i,n) + dj*(x(i,n) - x(i,n - 1));
        end
        if DOTOP
            % Fill Y13.
            yj = y(mTop + 1,offsetRight + j);
            delta =  yj - y(mTop + 2,offsetRight + j);
            for i = 1:mTop
                di = cast(mTop - i + 1,'like',real(x));
                y(i,offsetRight + j) = yj + di*delta;
            end
        end
        if DOBOTTOM
            % Fill Y33.
            yj = y(offsetBottom,offsetRight + j);
            delta =  yj - y(offsetBottom - 1,offsetRight + j);
            for i = 1:mBottom
                di = cast(i,'like',real(x));
                y(offsetBottom + i,offsetRight + j) = yj + di*delta;
            end
        end
    end
end
% There are some special cases we need to consider:
% x is a column vector that has been extended to multiple columns and the
% number of rows has also been extended.  In this case we have not filled
% Y11, Y31, Y13, or Y33. We need to copy the adjacent elements in Y12 and
% Y32.
if ~DOLEFT && nLeft > 0
    for j = 1:nLeft
        for i = 1:mTop
            y(i,j) = y(i,nLeft + 1);
        end
        for i = 1:mBottom
            y(offsetBottom + i,j) = y(offsetBottom + i,nLeft + 1);
        end
    end
end
if ~DORIGHT && nRight > 0
    for j = 1:nRight
        for i = 1:mTop
            y(i,offsetRight + j) = y(i,offsetRight);
        end
        for i = 1:mBottom
            y(offsetBottom + i,offsetRight + j) = ...
                y(offsetBottom + i,offsetRight);
        end
    end
end
% x is a row vector that has been extended to multiple rows, and the number
% of columns has also been extended. In this case we have also have not
% filled Y11, Y31, Y13, or Y33.  We need to copy the adjacent elements in
% Y21 and Y23.
if ~DOTOP && mTop > 0
    for i = 1:mTop
        for j = 1:nLeft
            y(i,j) = y(mTop + 1,j);
        end
        for j = 1:nRight
            y(i,offsetRight + j) = y(mTop + 1,offsetRight + j);
        end
    end
end
if ~DOBOTTOM && mBottom > 0
    for i = 1:mBottom
        for j = 1:nLeft
            y(offsetBottom + i,j) = y(offsetBottom,j);
        end
        for j = 1:nRight
            y(offsetBottom + i, offsetRight + j) = ...
                y(offsetBottom, offsetRight + j);
        end
    end
end

%--------------------------------------------------------------------------

function I = getPerIndices(lx,lf,loc,forceEven)
coder.internal.prefer_const(lx,lf,loc,forceEven);
ZERO = coder.internal.indexInt(0);
ONE = coder.internal.indexInt(1);
if nargin < 4
    forceEven = false;
end
ghostEntry = forceEven && eml_bitand(lx,ONE);
if ghostEntry
    lx = lx + 1;
end
if lx < lf
    nwrap = lf - lx;
else
    nwrap = ZERO;
end
if loc == 'l' || loc == 'u'
    DOLEFT = true;
    DORIGHT = false;
    n = lf + lx;
    centerOffset = lf;
    rightOffset = coder.internal.indexInt(0);
elseif loc == 'b'
    DOLEFT = true;
    DORIGHT = true;
    n = 2*lf + lx;
    centerOffset = lf;
    rightOffset = lf + lx;
elseif loc == 'r' || loc == 'd'
    DOLEFT = false;
    DORIGHT = true;
    n = lf + lx;
    centerOffset = ZERO;
    rightOffset = lx;
else
    DOLEFT = false;
    DORIGHT = false;
    n = lx;
    centerOffset = ZERO;
    rightOffset = ZERO;
end
I = zeros(1,n,coder.internal.indexIntClass);
if DOLEFT
    % Left portion of I is lx-lf+1:lx followed by I = mod(I,lx) and
    % I(I==0) = lx.
    if lx < lf
        for k = 1:nwrap
            I(k) = lx - mod(lf - k,lx);
        end
        for k = (nwrap + 1):lf
            I(k) = k - nwrap;
        end
    else
        for k = 1:lf
            I(k) = lx - lf + k;
        end
    end
end
% Middle portion of I is 1:lx.
for k = 1:lx
    I(centerOffset + k) = k;
end
if DORIGHT
    % Right portion of I is 1:lf followed by I = mod(I,lx) and
    % I(I==0) = lx.
    for k = 1:lf
        I(rightOffset + k) = 1 + mod(k - 1,lx);
    end
end
if ghostEntry
    for k = 1:n
        if I(k) == lx
            I(k) = lx - 1;
        end
    end
end

%--------------------------------------------------------------------------

function I = getSymIndices(lx,lf,loc)
coder.internal.prefer_const(lx,lf,loc);
ZERO = coder.internal.indexInt(0);
if loc == 'l' || loc == 'u'
    DOLEFT = true;
    DORIGHT = false;
    n = lf + lx;
    centerOffset = lf;
    rightOffset = ZERO;
elseif loc == 'b'
    DOLEFT = true;
    DORIGHT = true;
    n = 2*lf + lx;
    centerOffset = lf;
    rightOffset = lf + lx;
elseif loc == 'r' || loc == 'd'
    DOLEFT = false;
    DORIGHT = true;
    n = lf + lx;
    centerOffset = ZERO;
    rightOffset = lx;
else
    DOLEFT = false;
    DORIGHT = false;
    n = lx;
    centerOffset = ZERO;
    rightOffset = ZERO;
end
lx2 = 2*lx;
I = zeros(1,n,coder.internal.indexIntClass);
% Left portion
if DOLEFT
    if lx < lf
        nwrap = lf - lx;
        % These values must be modified, as they would otherwise be greater
        % than lx.
        for k = 1:nwrap
            ik = 1 + rem(lf - k,lx2);
            if ik > lx
                ik = lx2 - ik + 1;
            end
            I(k) = ik;
        end
        for k = (nwrap + 1):lf
            I(k) = lf - (k - 1);
        end
    else
        for k = 1:lf
            I(k) = lf - (k - 1);
        end
    end
end
% Middle portion
for k = 1:lx
    I(centerOffset + k) = k;
end
% Right portion
if DORIGHT
    % lx:-1:lx-lf+1
    if lx < lf
        for k = 1:lx
            I(rightOffset + k) = lx - (k - 1);
        end
        % These values must be modified, as they would otherwise be less
        % than 1.
        for k = (lx + 1):lf
            ik = k - lx; % 1 - (lx - (k - 1));
            if ik > lx
                ik = 1 + rem(ik - 1,lx2);
                if ik > lx
                    ik = lx2 - ik + 1;
                end
            end
            I(rightOffset + k) = ik;
        end
    else
        for k = 1:lf
            I(rightOffset + k) = lx - (k - 1);
        end
    end
end

%--------------------------------------------------------------------------
% Whole-point Symmetrization.

function y = WP_SymExt(x,lfRow,lfCol,locRow,locCol)
coder.internal.prefer_const(lfRow,lfCol,locRow,locCol);
mx = coder.internal.indexInt(size(x,1));
nx = coder.internal.prodsize(x,'above',1);
locRowN = locRow == 'n';
locColN = locCol == 'n';
if locRowN && locColN
    y = x;
elseif locColN
    I = WPSymExtIndexVector(mx,lfRow,locRow);
    y = x(I,:);
elseif locRowN
    J = WPSymExtIndexVector(nx,lfCol,locCol);
    y = x(:,J);
else
    I = WPSymExtIndexVector(mx,lfRow,locRow);
    J = WPSymExtIndexVector(nx,lfCol,locCol);
    y = x(I,J);
end

%--------------------------------------------------------------------------

function I = WPSymExtIndexVector(nx,lf,loc)
coder.internal.prefer_const(nx,lf,loc);
ONE = coder.internal.indexInt(1);
if loc == 'n'
    nc = nx;
elseif loc == 'b'
    nc = nx + 2*lf;
else
    nc = nx + lf;
end
I = zeros(1,nc,coder.internal.indexIntClass);
if nx >= 2
    for k = 1:nx
        I(k) = k;
    end
    lfNew = lf;
    while lfNew >= nx
        [I,nx] = WP_SymExtIdx(I,nx,nx - 1,loc);
        if loc == 'b'
            lfNew = eml_rshift(nc - nx,ONE);
        else
            lfNew = nc - nx;
        end
    end
    I = WP_SymExtIdx(I,nx,lfNew,loc);
else
    I(:) = 1;
end

%--------------------------------------------------------------------------

function [I,cnew] = WP_SymExtIdx(I,c,lf,loc)
coder.internal.prefer_const(lf,loc);
Itmp = coder.nullcopy(I);
for k = 1:c
    Itmp(k) = I(k);
end
ZERO = coder.internal.indexInt(0);
if loc == 'l' || loc == 'u'
    DOLEFT = true;
    DORIGHT = false;
    centerOffset = lf;
    rightOffset = ZERO;
    cnew = lf + c;
elseif loc == 'b'
    DOLEFT = true;
    DORIGHT = true;
    centerOffset = lf;
    rightOffset = lf + c;
    cnew = 2*lf + c;
elseif loc == 'r' || loc == 'd'
    DOLEFT = false;
    DORIGHT = true;
    centerOffset = ZERO;
    rightOffset = c;
    cnew = c + lf;
else
    DOLEFT = false;
    DORIGHT = false;
    centerOffset = ZERO;
    rightOffset = ZERO;
    cnew = c;
end
if DOLEFT
    for k = 1:lf
        I(k) = Itmp(lf - k + 2);
    end
end
for k = 1:c
    I(centerOffset + k) = Itmp(k);
end
if DORIGHT
    for k = 1:lf
        I(rightOffset + k) = Itmp(c - k);
    end
end

%--------------------------------------------------------------------------
% Half-point Anti-Symmetrization.

function y = HP_AntiSymExt(x,lfRow,lfCol,locRow,locCol,originalType)
coder.internal.prefer_const(lfRow,lfCol,locRow,locCol);
if nargin == 6
    coder.internal.prefer_const(originalType);
else
    originalType = class(x);
end
if isinteger(x) && isa(x,originalType) && ~isa(x,'int64')
    % Cast to a larger signed type to do the extension if one is available.
    % For 'uint64', cast to double. The only benefit to casting for signed
    % integer types is getting saturation right. Casting 'int64' to double
    % offers no advantages, which is why it has been excluded above.
    if isa(x,'uint64') || ~isreal(x)
        if ~allFitInDouble(x)
            coder.internal.warning( ...
                'Wavelet:FunctionInput:PrecisionLoss',class(x));
        end
        ytmp = HP_AntiSymExt(double(x),lfRow,lfCol,locRow,locCol,class(x));
    elseif isa(x,'uint32') || isa(x,'int32')
        ytmp = HP_AntiSymExt(int64(x),lfRow,lfCol,locRow,locCol,class(x));
    elseif isa(x,'uint16') || isa(x,'int16')
        ytmp = HP_AntiSymExt(int32(x),lfRow,lfCol,locRow,locCol,class(x));
    else
        ytmp = HP_AntiSymExt(int16(x),lfRow,lfCol,locRow,locCol,class(x));
    end
    y = cast(ytmp,'like',x);
    return
end
mx = coder.internal.indexInt(size(x,1));
nx = coder.internal.prodsize(x,'above',1);
locRowN = locRow == 'n';
locColN = locCol == 'n';
if locRowN && locColN
    y = x;
elseif locRowN
    [J,SJ] = HP_AntiSymExtIndexVector(nx,lfCol,locCol);
    my = mx;
    ny = coder.internal.indexInt(length(J));
    y = coder.nullcopy(zeros(my,ny,'like',x));
    for j = 1:ny
        if SJ(j)
            y(:,j) = -x(:,J(j));
        else
            y(:,j) = x(:,J(j));
        end
    end
elseif locColN
    [I,SI] = HP_AntiSymExtIndexVector(mx,lfRow,locRow);
    my = coder.internal.indexInt(length(I));
    ny = nx;
    y = coder.nullcopy(zeros(my,ny,'like',x));
    for j = 1:ny
        for i = 1:my
            if SI(i)
                y(i,j) = -x(I(i),j);
            else
                y(i,j) = x(I(i),j);
            end
        end
    end
else
    [I,SI] = HP_AntiSymExtIndexVector(mx,lfRow,locRow);
    [J,SJ] = HP_AntiSymExtIndexVector(nx,lfCol,locCol);
    my = coder.internal.indexInt(length(I));
    ny = coder.internal.indexInt(length(J));
    y = coder.nullcopy(zeros(my,ny,'like',x));
    for j = 1:ny
        for i = 1:my
            if xor(SI(i),SJ(j))
                y(i,j) = -x(I(i),J(j));
            else
                y(i,j) = x(I(i),J(j));
            end
        end
    end
end

function [I,S] = HP_AntiSymExtIndexVector(nx,lf,loc)
coder.internal.prefer_const(lf,loc);
ONE = coder.internal.indexInt(1);
if loc == 'n'
    nc = nx;
elseif loc == 'b'
    nc = nx + 2*lf;
else
    nc = nx + lf;
end
I = zeros(1,nc,coder.internal.indexIntClass);
S = false(1,nc); % sign vector
if nx >= 2
    for k = 1:nx
        I(k) = k;
    end
    if loc ~= 'n'
        while lf > nx
            [I,S,nx] = HPAntiSymExtIdx(I,S,nx,nx,loc);
            if loc == 'b'
                lf = eml_rshift(nc - nx,ONE);
            else
                lf = nc - nx;
            end
        end
        [I,S,~] = HPAntiSymExtIdx(I,S,nx,lf,loc);
    end
else
    I(:) = 1;
end

function [I,S,nxnew] = HPAntiSymExtIdx(I,S,nx,lf,loc)
coder.internal.prefer_const(lf,loc);
Itmp = coder.nullcopy(I);
Stmp = coder.nullcopy(S);
for k = 1:nx
    Itmp(k) = I(k);
    Stmp(k) = S(k);
end
ZERO = coder.internal.indexInt(0);
if loc == 'l' || loc == 'u'
    DOLEFT = true;
    DORIGHT = false;
    centerOffset = lf;
    rightOffset = ZERO;
    nxnew = lf + nx;
elseif loc == 'b'
    DOLEFT = true;
    DORIGHT = true;
    centerOffset = lf;
    rightOffset = lf + nx;
    nxnew = 2*lf + nx;
elseif loc == 'r' || loc == 'd'
    DOLEFT = false;
    DORIGHT = true;
    centerOffset = ZERO;
    rightOffset = nx;
    nxnew = nx + lf;
else
    DOLEFT = false;
    DORIGHT = false;
    centerOffset = ZERO;
    rightOffset = ZERO;
    nxnew = nx;
end
if DOLEFT
    for k = 1:lf
        I(k) = Itmp(lf - k + 1);
        S(k) = ~Stmp(lf - k + 1);
    end
end
for k = 1:nx
    I(centerOffset + k) = Itmp(k);
    S(centerOffset + k) = Stmp(k);
end
if DORIGHT
    for k = 1:lf
        I(rightOffset + k) = Itmp(nx - k + 1);
        S(rightOffset + k) = ~Stmp(nx - k + 1);
    end
end

%--------------------------------------------------------------------------
% Whole-point Anti-Symmetrization.

function y = WP_AntiSymExt(x,lfRow,lfCol,locRow,locCol,originalType)
coder.internal.prefer_const(lfRow,lfCol,locRow,locCol);
if nargin == 6
    coder.internal.prefer_const(originalType);
else
    originalType = class(x);
end
if isinteger(x) && isa(x,originalType)
    % We need 2*a not to saturate if cancellation in 2*a - b would bring
    % the result in range, so cast to a larger signed integer type to do
    % the extension if one is available. For 'int64' and 'uint64', cast to
    % double.
    if isa(x,'uint64') || isa(x,'int64') || ~isreal(x)
        if ~allFitInDouble(x)
            coder.internal.warning( ...
                'Wavelet:FunctionInput:PrecisionLoss',class(x));
        end
        ytmp = WP_AntiSymExt(double(x),lfRow,lfCol,locRow,locCol,class(x));
    elseif isa(x,'uint32') || isa(x,'int32')
        ytmp = WP_AntiSymExt(int64(x),lfRow,lfCol,locRow,locCol,class(x));
    elseif isa(x,'uint16') || isa(x,'int16')
        ytmp = WP_AntiSymExt(int32(x),lfRow,lfCol,locRow,locCol,class(x));
    else
        ytmp = WP_AntiSymExt(int16(x),lfRow,lfCol,locRow,locCol,class(x));
    end
    y = cast(ytmp,'like',x);
    return
end
ONE = coder.internal.indexInt(1);
TWO = coder.internal.indexInt(2);
mx = coder.internal.indexInt(size(x,1));
nx = coder.internal.prodsize(x,'above',1);
locRowN = locRow == 'n';
locRowB = locRow == 'b';
locColN = locCol == 'n';
locColB = locCol == 'b';
if locRowN
    my = mx;
elseif locRowB
    my = mx + 2*lfRow;
else
    my = mx + lfRow;
end
if locColN
    ny = nx;
elseif locColB
    ny = nx + 2*lfCol;
else
    ny = nx + lfCol;
end
y = zeros(my,ny,'like',x);
y(1:mx,1:nx) = x;
if ~locColN
    if nx >= 2
        ncx = nx;
        nnew = lfCol;
        while nnew >= ncx
            [y,ncx] = WPAntiSymExtKernel(TWO,y,mx,ncx,ncx - 1,locCol);
            if locColB
                nnew = eml_rshift(ny - ncx,ONE);
            else
                nnew = ny - ncx;
            end
        end
        y = WPAntiSymExtKernel(TWO,y,mx,ncx,nnew,locCol);
    else
        % Replicate the first column.
        for j = 2:ny
            for i = 1:mx
                y(i,j) = y(i,1);
            end
        end
    end
end
if ~locRowN
    if mx >= 2
        nrx = mx;
        nnew = lfRow;
        while nnew >= nrx
            [y,nrx] = WPAntiSymExtKernel(ONE,y,nrx,ny,nrx - 1,locRow);
            if locRowB
                nnew = eml_rshift(my - nrx,ONE);
            else
                nnew = my - nrx;
            end
        end
        y = WPAntiSymExtKernel(ONE,y,nrx,ny,nnew,locRow);
    else
        % Replicate the first row.
        for j = 1:ny
            for i = 2:my
                y(i,j) = y(1,j);
            end
        end
    end
end

function [x,cnew] = WPAntiSymExtKernel(dim,x,mx,nx,lf,loc)
% We assume nnew < nx.
coder.internal.prefer_const(dim,mx,nx,lf,loc);
ZERO = coder.internal.indexInt(0);
xtmp = coder.nullcopy(x);
xtmp(1:mx,1:nx) = x(1:mx,1:nx);
if dim == 1
    n = mx;
else
    n = nx;
end
if loc == 'l' || loc == 'u'
    DOLEFT = true;
    DORIGHT = false;
    centerOffset = lf;
    rightOffset = ZERO;
    cnew = n + lf;
elseif loc == 'b'
    DOLEFT = true;
    DORIGHT = true;
    centerOffset = lf;
    rightOffset = centerOffset + n;
    cnew = n + 2*lf;
elseif loc == 'r' || loc == 'd'
    DOLEFT = false;
    DORIGHT = true;
    centerOffset = ZERO;
    rightOffset = n;
    cnew = n + lf;
else
    DOLEFT = false;
    DORIGHT = false;
    centerOffset = ZERO;
    rightOffset = ZERO;
    cnew = n;
end
if dim == 1
    % Adding new rows.
    if DOLEFT
        for i = 1:lf
            for j = 1:nx
                x(i,j) = 2*xtmp(1,j) - xtmp(lf - i + 2,j);
            end
        end
    end
    for i = 1:n
        for j = 1:nx
            x(centerOffset + i,j) = xtmp(i,j);
        end
    end
    if DORIGHT
        for i = 1:lf
            for j = 1:nx
                x(rightOffset + i,j) = 2*xtmp(mx,j) - xtmp(mx - i,j);
            end
        end
    end
else
    % Adding new columns.
    if DOLEFT
        for j = 1:lf
            for i = 1:mx
                x(i,j) = 2*xtmp(i,1) - xtmp(i,lf - j + 2);
            end
        end
    end
    for j = 1:n
        for i = 1:mx
            x(i,centerOffset + j) = xtmp(i,j);
        end
    end
    if DORIGHT
        for j = 1:lf
            for i = 1:mx
                x(i,rightOffset + j) = 2*xtmp(i,nx) - xtmp(i,nx - j);
            end
        end
    end
end

%--------------------------------------------------------------------------

function p = allFitInDouble(x)
p = true;
if isinteger(x) && (isa(x,'uint64') || isa(x,'int64'))
    if isreal(x)
        for k = 1:numel(x)
            p = p && x(k) >= -flintmax && x(k) <= flintmax;
        end
    else
        for k = 1:numel(x)
            p = p && ...
                real(x(k)) >= -flintmax && real(x(k)) <= flintmax && ...
                imag(x(k)) >= -flintmax && imag(x(k)) <= flintmax;
        end
    end
end

%--------------------------------------------------------------------------
