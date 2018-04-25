function pvpairs = quiver3parseargs(args)
% identify convenience args for QUIVER3 and return all inputs as a list of PV pairs

%   Copyright 2009-2017 The MathWorks, Inc.

[numericArgs,pvpairs] = parseparams(args);
nargs = length(numericArgs);

if iscell(args{end}) && isempty(args{end})
    error(message('MATLAB:quiver:InvalidCellInput'));
end

% Check number of numeric inputs    
if ~ismember(nargs,[4 5 6 7])
    % too many numeric input args, nargs must be one of [4,5,6,7]
    error(message('MATLAB:quiver:InvalidNumInputs', num2str( nargs )));    
end

% separate 'filled' or LINESPEC from pvpairs 
n = 1;
extrapv = {};
foundFilled = false;
foundLinespec = false;
while length(pvpairs) >= 1 && n < 3 && matlab.graphics.internal.isCharOrString(pvpairs{1})
    pvpairs = matlab.graphics.internal.convertStringToCharArgs(pvpairs);
    arg = lower(pvpairs{1});
    
    % check for 'filled'
    if ~foundFilled
        if arg(1) == 'f'
            foundFilled = true;
            pvpairs(1) = [];
            extrapv = [{'MarkerFaceColor','auto'},extrapv];
        end
    end

    % check for linespec
    if ~foundLinespec
        [l,c,m,msg]=colstyle(pvpairs{1});
        if isempty(msg)
            foundLinespec = true;
            pvpairs(1) = [];
            if ~isempty(l)
                extrapv = [{'LineStyle',l},extrapv];
            end
            if ~isempty(c)
                extrapv = [{'Color',c},extrapv];
            end
            if ~isempty(m)
                extrapv = [{'ShowArrowHead','off'},extrapv];
                if ~isequal(m,'.')
                    extrapv = [{'Marker',m},extrapv];
                end
            end
        end
    end
    
    if ~(foundFilled || foundLinespec)
        break
    end
    n = n+1;
end

% check for unbalanced pvpairs list
if rem(length(pvpairs),2) ~= 0
    error(message('MATLAB:quiver:UnevenPvPairsCount'));
end

pvpairs = [extrapv pvpairs];

% Deal witth quiver(..., AutoScaleFactor) syntax
if nargs == 5 || nargs == 7
    if isa(numericArgs{nargs},'double') && (length(numericArgs{nargs}) == 1) 
        if args{nargs} > 0
            pvpairs = [pvpairs,{'AutoScale','on',...
                'AutoScaleFactor',numericArgs{nargs}}];
        else
            pvpairs = [pvpairs,{'AutoScale','off'}];
        end
        numericArgs = numericArgs(1:end-1);
        nargs = length(numericArgs);
    else
        error(message('MATLAB:quiver:InvalidAutoScaleFactor'));
    end
end

numericArgs = getRealData(numericArgs); % get the real component if data is complex

% Deal with quiver(Z,U,V,W) syntax
if nargs == 4
    z = datachk(numericArgs{1});
    u = datachk(numericArgs{2});
    v = datachk(numericArgs{3});
    w = datachk(numericArgs{4});
    
    % argument validation
    if ~isequal(size(z),size(u))
        error(message('MATLAB:quiver:ZUSizeMismatch'));
    elseif ~isequal(size(u),size(v))
        error(message('MATLAB:quiver:UVSizeMismatch'));
    elseif ~isequal(size(v),size(w))
        error(message('MATLAB:quiver:VWSizeMismatch'));
    end    
    pvpairs = [pvpairs,{'ZData',z,'UData',u,'VData',v,'WData',w}];
    
% quiver(X,Y,Z,U,V,W) syntax   
elseif (nargs == 6)
    x = datachk(numericArgs{1});
    y = datachk(numericArgs{2});
    z = datachk(numericArgs{3});
    u = datachk(numericArgs{4});
    v = datachk(numericArgs{5});
    w = datachk(numericArgs{6});
    
    % argument validation
    if xor(isempty(x), isempty(y))
        error(message('MATLAB:quiver:XYMixedEmpty'));
    end
    
    sz = size(z);
    su = size(u);
    sv = size(v);
    sw = size(w);
    if isempty(x)
        sx = sz;
        sy = sz;
    else
        sx = size(x);
        sy = size(y);
    end
    if ~isequal(sz,su)
        error(message('MATLAB:quiver:ZUSizeMismatch'));
    elseif ~isequal(su,sv)
        error(message('MATLAB:quiver:UVSizeMismatch'));
    elseif ~isequal(sv,sw)
        error(message('MATLAB:quiver:VWSizeMismatch'));
    elseif ~(isequal(sx,sz) || isequal(length(x),sz(2)) )
        error(message('MATLAB:quiver:XZSizeMismatch'));
    elseif ~(isequal(sy,sz) || isequal(length(y),sz(1)) )
        error(message('MATLAB:quiver:YZSizeMismatch'));
    elseif ~(isequal(sx,sy) || (isvector(x) && isvector(y)))
        error(message('MATLAB:quiver:XYMixedFormat', getString( message( 'MATLAB:quiver:XYMixedFormatZ' ) )))
    end
    
    pvpairs = [pvpairs,{'XData',x,'YData',y,'ZData',z,'UData',u,'VData',v,'WData',w}];
end


