function y = localRegression(x, winsz, dim, nanflag, degree, methodName, t)
% LOCALREGRESSION  Weighted or unweighted local polynomial regression

% Copyright 2016-2017 The MathWorks, Inc.

    narginchk(7, 7);
    isRobust = startsWith(methodName, "rlo");
    isWeighted = contains(methodName, "ess");

    % Revert "includenan" to "omitnan" if there are no NaNs
    nanMask = isnan(x);
    omitnanOption = nanflag == "omitnan";
    omitnanOption = omitnanOption && any(nanMask(:));
    if ~omitnanOption
        nanflag = "includenan";
    end

    % Use convolution if there are no sample points or uniform sample
    % points, the window is balanced (same extent on both sides), and there
    % are no NaNs to be omitted
    canUseUniform = (isempty(t) || isuniform(t)) && ...
                     isscalar(winsz) && ~omitnanOption;
    if canUseUniform
        if ~isempty(t)
            % If sample points are uniformly spaced, ignore them and
            % compute the rescaled window size
            winsz = winsz / (t(2) - t(1));
            t = 1:size(x,dim);
        end
    end

    % Robust iterations require sample points always
    if isempty(t)
        t = 1:size(x,dim);
    end

    % If all windows contain a single point or are empty, nothing to do
    if isempty(x) || (size(x, dim) < 2) || checkSinglePointWindow(t, winsz, canUseUniform)
        if ~isfloat(x)
            y = double(x);
        else
            y = x;
        end
        return;
    end

    % Convert datetime/duration sample points
    if ~canUseUniform
        if isa(t, 'datetime')
            t = datetimeToComplex(t);
            winsz = milliseconds(winsz);
        elseif isa(t, 'duration')
            t = milliseconds(t);
            winsz = milliseconds(winsz);
        end
    end

    if canUseUniform
        y = uniformLocalRegression(x, winsz, dim, degree, isWeighted);
    else
        y = builtin('_localRegression', x, dim, t, winsz, ...
            degree, char(nanflag), isWeighted);
    end

    % Robust iterations
    if isRobust
        weightThreshold = max(cast(abs(x), class(y)))*sqrt(eps(class(y)));
        for i = 1:5
            % Compute (squared) robust weights
            if ~isfloat(x)
                rw = abs(double(x)-y);
            else
                rw = abs(x - y);
            end
            rw = min(rw ./ (6*max(weightThreshold,median(rw, dim, 'omitnan'))), 1);
            rw(isnan(rw)) = 0;
            if ~omitnanOption
                rw(isnan(x)) = NaN;
            end
            rw = (1 - rw.^2);
            % Re-regress
            y = builtin('_localRegression', x, dim, t, ...
                winsz, degree, char(nanflag), true, rw);
        end
    end

    % Patch up windows with NaN
    % NaNs that get 0 weight in a window will be ignored, and therefore the
    % output may not have all of the NaNs it should
    if any(nanMask(:)) && (nanflag == "includenan")
        yn = zeros(size(y));
        yn(nanMask) = NaN;
        y = y + movmax(yn, winsz, dim, 'includenan', 'SamplePoints', t);
    end

end

%--------------------------------------------------------------------
function y = uniformLocalRegression(x, winsz, dim, degree, isWeighted)
% UNIFORMLOCALREGRESSION  Apply local regression to uniform data

    winsz = double(winsz);
    winsz = min(fix(winsz), size(x, dim));
    if dim ~= 1
        y = permute(x, [dim, 1:(dim-1), dim:(ndims(x)-1)]);
    else
        y = x;
    end
    if ~isfloat(y)
        y = double(y);
    end

    yfront = y(1:winsz,:);
    yback = y(end:-1:(end-winsz+1),:);

    % Set up the polynomial matrix
    xd = (0:(winsz-1))' - floor(winsz/2);
    dmax = floor(winsz/2); % Maximum distance
    if isWeighted
        weight = (1 - (abs(xd)/dmax).^3).^1.5; % Tricube weight
        V = weight .* power(xd, 0:degree);
    else
        V = power(xd/dmax, 0:degree);
    end

    % Create projection as a filter
    [Q,~] = qr(V,0);
    h = Q(floor(winsz/2)+1,:)*Q';
    if isWeighted
        h = flip(h(:) .* weight);
    else
        h = flip(h(:));
    end
    
    % Compensate for even lengths
    if rem(length(h), 2) == 0
        h = [0; h(:)];
    end
    if ~isWeighted || (winsz ~= size(x,dim))
        y = convn(y, h, 'same');
    end
    sz = size(y);
    y = y(:,:);

    % Compensate for the endpoints
    if isWeighted
        xd = (-floor(winsz/2):(winsz-1))';
        lb = floor(winsz/2)+1;
        ub = length(xd);
        Vbase = power(xd, 0:degree);
        for j = 1:ceil(winsz/2)
            dmax = max(xd(lb), xd(ub));
            weight = (1 - (abs(xd(lb:ub))/dmax).^3).^1.5;
            V = weight .* Vbase(lb:ub,:);
            [Q,~] = qr(V, 0);
            alpha = (Q(j,:)*Q') .* weight';
            y(j,:) = alpha * yfront;
            y(end-j+1,:) = alpha * yback;
            lb = lb - 1;
            ub = ub - 1;
        end
    else
        % Project on the endpoints using the orthogonal polynomial
        % matrix used for the filter
        y(1:floor(winsz/2),:) = Q(1:floor(winsz/2),:)*(Q'*yfront);
        y(end:-1:(end-floor(winsz/2)+1),:) = Q(1:floor(winsz/2),:)*(Q'*yback);
    end
    y = reshape(y, sz);

    if dim ~= 1
        y = ipermute(y, [dim, 1:(dim-1), dim:(ndims(y)-1)]);
    end
    
end

%--------------------------------------------------------------------------
function tf = isuniform(t)
% Determine if sample points are uniformly spaced

    if numel(t) == 1
        tf = false;
    else
        dt = diff(t);
        tf = (max(dt) == min(dt));
    end

end

%--------------------------------------------------------------------------
function a = datetimeToComplex(b)
% Convert datetimes to complex numbers 

    y = year(b);
    m = month(b);
    d = day(b);
    h = hour(b);
    mn = minute(b);
    sc = floor(second(b));

    % Extract milliseconds
    ms = milliseconds(b - datetime(y,m,d,h,mn,sc));
    data = {y, m, d, h, mn, sc, ms};
    a = matlab.internal.datetime.createFromDateVec(data, char([]));

end

%--------------------------------------------------------------------------
function tf = checkSinglePointWindow(t, winsz, uniformData)
% Check whether each window contains only a single point

    % For uniformly spaced sample points, just check the window size
    if uniformData
        if isscalar(winsz)
            tf = winsz < 2;
        else
            tf = max(winsz) < 1;
        end
    else
        td = min(diff(t));
        % The smallest gap between sample points must be larger than the
        % window extent in either direction
        if numel(winsz) == 2
            tf = all(td > winsz);
        else
            tf = (2*td > winsz);
        end
    end

end