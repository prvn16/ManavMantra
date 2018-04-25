function out = tsinterp(type,t,T,X,noduptimes)
%TSINTERP Utility used to define the default time series interpolation 
%
% Predefined interpolation function handles must be on the path and not
% local functions so that the time series object can be saved. They have
% been assembled into a single function called with the type of
% interpolation to avoid creating multiple interpolation functions in the
% parent folder. The last optional input argument is a logical which
% asserts that the vector T has no duplications (this is assumed to be
% false by default).

%   Copyright 2004-2012 The MathWorks, Inc.

if (nargin<=4 || ~noduptimes) && length(T)>=2
     % Sort t
    [t, I_] = sort(t(:));
    t = t(:);
    [junk,J] = sort(I_); %#ok<ASGLU>
    
    % Find duplicate times 
    diffT = diff(T);
    Iduplicate = [false,(diffT(:)'==0)];
    if any(Iduplicate)
        Tduplicate = unique(T(Iduplicate));
        s = size(X);
        
        % Interpolate before the first duplicate time
        I = find(Tduplicate(1)==T);
        
        % T(1:I(1)) are all unique and include the first duplicated time
        if t(1)<Tduplicate(1)
            out = localInterpolate(t(t<Tduplicate(1)),T(1:I(1)),...
                reshape(X(1:I(1),:),[I(1) s(2:end)]),type);
        else
            out = zeros([0 s(2:end)]);
        end
        
        
        % Any values of t which overlap the first duplicate interpolant
        % time produce output which is the positionally last value of X at
        % the duplicate interpolant time.  This duplicate value must be
        % repeated for each duplicate value of the interpolate time t.
        out = [out; repmat(reshape(X(I(end),:),[1 s(2:end)]),...
            [sum(t==Tduplicate(1)) 1])];
        
        Iklast = I;
        Ik = I;
        for k=2:length(Tduplicate)
            
            % Add interpolated values between Tduplicate(k-1) and
            % Tduplicate(k)
            Ik = find(Tduplicate(k)==T);
            % T(Iklast(end):Ik(1)) are all unique and include the last duplicated
            % time from the previous interval and the first duplicated time
            % from the current interval
            It = t>Tduplicate(k-1) & t<Tduplicate(k);
            if any(It)
                out = [out;localInterpolate(t(It),T(Iklast(end):Ik(1)),...
                    reshape(X(Iklast(end):Ik(1),:),[Ik(1)-Iklast(end)+1 s(2:end)]),type)]; %#ok<AGROW>
            end

            % Any values of t which overlap the kth duplicate time produce output 
            % which is the positional latest of X at the duplicate times
            
            % Any values of t which overlap the k-th duplicate interpolant
            % time produce output which is the positionally last value of X at
            % the duplicate interpolant time.  This duplicate value must be
            % repeated for each duplicate value of the interpolate time t.
            out = [out; repmat(reshape(X(Ik(end),:),[1 s(2:end)]),...
                [sum(t==Tduplicate(k)) 1])]; %#ok<AGROW>
        
          
            Iklast = Ik;           
        end
        
        % Interpolate after duplicate times. T(I(end):end) are all unique 
        % and include the last duplicate time, 
        if t(end)>Tduplicate(end)
            out = [out;localInterpolate(t(t>Tduplicate(end)),T(Ik(end):end),...
                reshape(X(Ik(end):end,:),[size(X,1)-Ik(end)+1 s(2:end)]),type)]; 
        end
        
        % Unsort t
        out = reshape(out(J,:),size(out));
        return
    end
end

out = localInterpolate(t,T,X,type);

   
function out = zordhold(t,T,X)

% Initialize output to the same data type for builtin types. For other
% types (such as embedded.fi) initialize the output to doubles.
s = size(X);
if isinteger(X) ||  isfloat(X) 
	out = repmat(X(1),[length(t),s(2:end)]);
elseif islogical(X)
    out = false([length(t),s(2:end)]);
else
    out = zeros([length(t),s(2:end)]);
end

% Find NaN values. Note that since the "interpolation" function is always
% called via tsArrayFcn we are guaranteed that if any part of a "row" has 
% NaN value then the entire row is all NaNs  
nanvals = isnan(X);
if length(s)==2 && min(s)==1
    I = find(~nanvals);
else % Find any NaN valued rows
    I = find(~any(nanvals(:,:)'));
end

% Use hisc to allocate the new time vector into bins defined by the 
% valid time vector. The second out argument Iref identifies the 
% indices of the interpolate time vector in the intervals defined by the 
% interpolant time vector. 
Tvalid = T(I);
[~,Iref] = histc(t,Tvalid);
for k=1:length(t)
    if Iref(k)>0
       out(k,:) = X(I(Iref(k)),:);
    else % Outside the range of the valid time vector
        
        % Logical and non-numeric types cannot be replaced with NaNs.  
        % Catch these errors and leave the extrapolated values at zero/false.
        try
            out(k,:) = repmat(cast(NaN,class(out)),size(out(k,:)));  
        catch me
            if ~strcmp(me.identifier,'MATLAB:nologicalnan') && ...
                 ~strcmp(me.identifier,'MATLAB:cast:UnsupportedClass')
                rethrow(me);
            end
        end
    end
end

function out = linearinter(t,T,X)

% Calculation of end-time can introduce machine numerical precision error
% making t(end)>T(end)
tol = sqrt(eps(abs(T(end)))); 
if t(1)<T(1) || t(end)>T(end)+tol
    warning(message('MATLAB:linearinter:noextrap'))
end
% Fix for numerical spill over
if t(end)>T(end) && t(end)<T(end)+tol
    t(end) = T(end);
end   

% Find any observations that would cause interp to return NaNs
% Note that this function is called through tsArrayFcn, so if
% a row has a NaN value, all observations in that row have NaN
% values
s = size(X);
if isvector(X) && length(T)>=2
    I = find(~isnan(X));
else % matrix of multi-dimensional
    I = find(~any(isnan(reshape(X,[s(1) prod(s(2:end))]))'));
end

% Multiple non-NaN samples
if length(I)>1
    if isequal(T(I),t) % t coincides with non-NaN rows so just return them
        out = reshape(X(I,:),[length(I) s(2:end)]);
    else % interp1 on non-NaN rows
        rawData = reshape(X(I,:),[length(I) s(2:end)]);
        dataClass = class(rawData);
        
        % If the data type is single or double just use interp1 for
        % compatibility with MATLAB. Note that interp1 preserves the data
        % type.
        if isa(rawData,'single') || isa(rawData,'double')
            out = interp1(T(I),rawData,t,'linear');
        elseif isinteger(rawData) || islogical(rawData)
            % Linearly interpolate using the same algorithm as Simulink
            % Interpolation.cpp
            ti = T(I);
            yi = linearnonuniform(ti(:),rawData,t(:));
            
            % Round the data using the same algorithm as Interpolation.cpp
            Ipos = (yi>=0);
            Ineg = (yi<0);
            yi(Ipos) = floor(yi(Ipos)+.5);
            yi(Ineg) = ceil(yi(Ineg)-.5);
            
            % Cast the result back to the native type. Note that there is
            % no need to check for overflow or underflow because the
            % interpolated value must have smaller magnitude than its left
            % and right neighbors.
            out = cast(yi,dataClass);
        else % Cast non-builtin types, such as embedded.fi, to double
            out = interp1(T(I),double(rawData),t,'linear');
        end
        
    end
% Single non-NaN sample where scalar t coincides with that row
elseif length(I)==1 && isequal(T(I),t) 
    out = reshape(X(I,:),[length(I) s(2:end)]);
% Other single or no non-NaN sample
else
    % X must be single or double type to support NaN
    out = NaN([length(t), s(2:end)],class(X));
    indInterpolate = (t>=T(1) & t<=T(end));
    if isequal(T(I),t(indInterpolate)) % t coincides with non-NaN rows
        out(indInterpolate,:) = X(I,:);
    end
end

function out = nanhold(t,T,X)

% If time vector is a cell array of datestrs then
% convert to datenum
if iscell(t) || ischar(t)
    t = datenum(t);
end
if iscell(T) || ischar(T)
    T = datenum(T);
end

if ~isa(X,'double') && ~isa(X,'single')
    X = double(X);
end
s = size(X);
out = NaN([length(t),s(2:end)],class(X));
for k=1:length(t)
   [tdelta, I] = min(abs(T-t(k)));
   if tdelta<=eps
       out(k,:) = X(I(1),:);
   end
end

function out = localInterpolate(t,T,X,type)

switch lower(type)
   case 'zoh'
       out = zordhold(t,T,X);
   case 'linear'
       out = linearinter(t,T,X);
   case 'nan'
       out = nanhold(t,T,X);
   otherwise
       error(message('MATLAB:localInterpolate:wrongtype'))     
end


function yi = linearnonuniform(x,y,xi)

% This local function replicates the interpolation numeric algorithm used  
% in Interpolation.cpp for double arrays. Specifically:

% f1 = (t2 - t) / (t2 - t1);
% f2 = 1.0 - f1;
% y = ((v1)==(v2))?v1:(f1*v1+f2*v2);
                          
% where v1 and v2 are the left and right interpolant dependent variables
% and t1 and t2 are the left and right interpolant independent variables
% and t is the interpolated independent variable. linearnonuniform is
% intended to substitute for interp1 for linear interpolation.

% Note the restriction x and xi must be col vectors, min(x)<=xi<=max(x)

% y may be an ND array, but collapse it down to a 2D yMat. If yMat is
% a vector, it is a column vector.
siz_y = size(y);

if isvector(y)
    yMat = y(:);
    n = length(y);
    ds = 1;
    prodDs = 1;
else
    n = siz_y(1);
    ds = siz_y(2:end);
    prodDs = prod(ds);
    yMat = reshape(y,[n prodDs]);
end
siz_xi = size(xi);

% The size of the output YI
if isvector(y)
    % Y is a vector so size(YI) == size(XI)
    siz_yi = siz_xi;
else
    % Y is not a vector but XI is
    siz_yi = [length(xi) ds];
end

% Find the positions of the left side of the interval in x indices for xi 
h = diff(x);
[~,k] = histc(xi,x); % k is the pos of the left side of the interval in x indices for xi 
k(xi>=x(n)) = n-1;

f1 = (x(k+1)-xi)./h(k);
f2 = 1.0 - f1;
p = 1:length(xi);
for j = 1:prodDs
    yk = yMat(k,j); % Left size y vals
    ykstep = yMat(k+1,j); % Right side y vals
    
    % If left and right side yvals are the same there is no need to
    % interpolate ( (v1)==(v2) case)
    Iconst = (yk==ykstep);
    yout = zeros(size(yk));
    if any(Iconst)
        yout(Iconst) = double(yk(Iconst));
    end
    
    % Interpolate intervals where left and right side yvals are the not the 
    % same
    if any(~Iconst)
        yout(~Iconst) = f1(~Iconst).*double(yk(~Iconst)) + ...
            f2(~Iconst).*double(ykstep(~Iconst));
    end
    yiMat(p,j) = yout; %#ok<AGROW>
end


outOfBounds = xi<x(1) | xi>x(n);
try
    yiMat(p(outOfBounds),:) = cast(NaN,class(yiMat));
catch me %#ok<NASGU>
    yiMat(p(outOfBounds),:) = cast(0,class(yiMat));
end
     
yi = reshape(yiMat,siz_yi);