function varargout = qr(A, varargin)
%QR   Orthogonal triangular decomposition
%   Refer to the MATLAB QR reference page for more information.
%  
%   See also QR 

%   Copyright 2011-2017 The MathWorks, Inc.

    if nargin > 1
        [varargin{:}] = convertStringsToChars(varargin{:});
    end

    if nargout > 2 || ...                            % [~,~,E] = qr(...)
            nargin > 1 && ischar(varargin{1}) || ... % qr(A,'vector')
            nargin > 2 && ischar(varargin{2})        % qr(A,B,'vector')
        error(message('fixed:fi:qrPivotingNotSupported'));
    end

    if nargin > 1
        if isequal(varargin{1},0)          
            % qr(A,0)
            error(message('fixed:fi:qrEconomyModeNotSupported'));
        else
            % qr(A,B)
            error(message('fixed:fi:qrLeastSquaresNotSupported'));
        end
    end
    
    if ndims(A) > 2 %#ok
        error(message('fixed:fi:inputMustBe2D', 'qr'));
    end
    
    if ~isreal(A) || ~issigned(A)
        error(message('fixed:fi:realAndSigned'));
    end
    
    m=size(A,1);

    if m<=1
        wl = get(A,'WordLength');
        Ta = numerictype(A);
        Tq = numerictype('Signedness','Signed',...
                         'WordLength',wl,...
                         'FractionLength',wl-2,...
                         'DataType',Ta.DataType);
        Q = fi(eye(m),Tq);
        R = A;
    else
        wl=ceil(log2(1.6468 * sqrt(m))) + get(A, 'WordLength');
        niter = wl-1;
        [Q,R] = cordicqr(A, niter, wl);
    end

    if Q.fimathislocal
        Q.fimathislocal = false;
    end

    if R.fimathislocal
        R.fimathislocal = false;
    end

    if nargout == 2
        varargout{1} = Q;
        varargout{2} = R;
    else
        varargout{1} = R;
    end
end
