function tc = norm(ta,opt)
%NORM tall matrix or vector norm.
%   Supported matrix X syntaxes:
%   C = NORM(X) 
%   C = NORM(X,2)
%   C = NORM(X,1)
%   C = NORM(X,Inf)
%   C = NORM(X,'fro')
%
%   Supported vector V syntaxes:
%   C = NORM(V,P)
%   C = NORM(V,Inf)
%   C = NORM(V,-Inf) 
%
%   See also NORM.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(1,2);
if nargin < 2
    opt = 2;
else
    tall.checkNotTall(upper(mfilename), 1, opt);
    if strcmp(opt, 'inf')
        opt = inf;
    end
    if ~isNumericScalar(opt) && ~strcmp(opt, 'fro')
        error(message('MATLAB:norm:unknownNorm'));
    end
end
ta = tall.validateMatrix(ta, 'MATLAB:norm:inputMustBe2D');
ta = tall.validateType(ta, mfilename, {'double','single'}, 1);

if strcmp(opt, 'fro')
    tc = reducefun(@(x)norm(x,'fro'),ta);
elseif opt == 1
    tc = max(sum(abs(ta)),[],'includenan');
    tc = clientfun(@handleEmpty, tc);
elseif opt == inf
    tc = tall(reduceInDefaultDim(@infNorm, ta));
elseif opt == 2 
    % tc can be a scalar or the R factor from TSQR.
    tc = tall(reduceInDefaultDim(@twoNorm, ta));
    % Compute the two norm.
    tc = clientfun(@(x)norm(x,2),tc);
else
    tc = reducefun(@(x)norm(x(:),opt),ta);
    % Error out if the input is not a vector.
    func = @(x,y)checkSize(x,y,'MATLAB:norm:unknownNorm');
    tc = clientfun(func,tc,size(ta));
end
% start with an unsized copy of ta's Adaptor
tmp = resetSizeInformation(ta.Adaptor);
% and then apply the known size.
tc.Adaptor = setKnownSize(tmp, [1 1]);
end

function x = handleEmpty(x)
if isempty(x)
    x(1) = 0;
end
end

function tf = isNumericScalar(opt)
tf = isscalar(opt) && (isnumeric(opt) || islogical(opt)) && isreal(opt);
end
 
function x = checkSize(x, sz, eid)
% Check if the input is a vector.
if length(sz)~=2 || (sz(1)~=1 && sz(2)~=1)
     error(message(eid));
end
end

function y = infNorm(x, dim)
if dim == 1
    % Compute maximum row sum
    if isrow(x)
        y = sum(abs(x));
    else
        y = norm(x,inf);
    end
else
    % tall row vector.
    y = norm(x,inf);
end
end

function y = twoNorm(x, dim)
if dim == 1
    if iscolumn(x)
        y = norm(x,2);
    else
        % Compute R factor using TSQR.
        y = qr(x);
        if any(isnan(y(:))) % nans in QR factors.
            if ~any(isnan(x(:))) % no nans in x
                if any(isinf(x(:))) % just infs in x
                    y(:) = inf;
                end
            end
        end
        if size(y,1) > size(y,2)
            y = y(1:size(y,2),:);
        end        
        y = triu(y); 
    end
else
   y = norm(x,2); 
end
end

