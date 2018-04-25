function pvpairs = quiverparseargs(args)
% identify convenience args for QUIVER and return all inputs as a list of PV pairs

%   Copyright 2009-2017 The MathWorks, Inc.

[numericArgs,pvpairs] = parseparams(args);
nargs = length(numericArgs);

if iscell(args{end}) && isempty(args{end})
    error(message('MATLAB:quiver:InvalidCellInput'));
end

% Check number of numeric inputs    
if ~ismember(nargs,[2 3 4 5])
    % too many numeric input args, nargs must be one of [2,3,4,5}
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
    if ~foundLinespec && numel(pvpairs)>=1
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
if nargs == 3 || nargs == 5
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

% Deal with quiver(U,V) syntax
if nargs == 2
    u = datachk(numericArgs{1});
    v = datachk(numericArgs{2});
    
    % argument validation
    if ~isequal(size(u),size(v))
        error(message('MATLAB:quiver:UVSizeMismatch'));
    end    
    pvpairs = [pvpairs,{'UData',u,'VData',v}];
    
% quiver(X,Y,U,V) syntax    
elseif nargs == 4
    x = datachk(numericArgs{1});
    y = datachk(numericArgs{2});
    u = datachk(numericArgs{3});
    v = datachk(numericArgs{4});
    
    if xor(isempty(x), isempty(y))
      error(message('MATLAB:quiver:XYMixedEmpty'));
    end

    su = size(u);
    sv = size(v);
    if isempty(x)
        sx = su;
        sy = su;
    else
        sx = size(x);
        sy = size(y);
    end
    if ~isequal(su,sv)
        error(message('MATLAB:quiver:UVSizeMismatch'));
    elseif ~(isequal(sx,su) || isequal(length(x),su(2)) )
        error(message('MATLAB:quiver:XUSizeMismatch'));
    elseif ~(isequal(sy,su) || isequal(length(y),su(1)) )
        error(message('MATLAB:quiver:YUSizeMismatch'));
    elseif ~(isequal(sx,sy) || (isvector(x) && isvector(y)))
        error(message('MATLAB:quiver:XYMixedFormat', getString( message( 'MATLAB:quiver:XYMixedFormatU' ) )))
    end
    
    pvpairs = [pvpairs,{'XData',x,'YData',y,'UData',u,'VData',v}];    
end


