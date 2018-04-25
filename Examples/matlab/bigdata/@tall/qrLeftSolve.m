function [R,x] = qrLeftSolve(A,b)
% Use the economy Q-R decomposition of tall array A to find x and R such
% that [Q,R] = qr(A,0) and x = R\(Q'*b). Note that for each chunk we use
% the economy decomposition so both R and b returned to client are small.

% Copyright 2017 The MathWorks, Inc.

inAdapA = matlab.bigdata.internal.adaptors.getAdaptor(A);
inAdapB = matlab.bigdata.internal.adaptors.getAdaptor(b);

[R,b] = reducefun(@iChunkQR, A, b);

% Solve
x = clientfun(@iSolve, R, b);

% If n=size(A,2), R is nxn and x is nx1.
if isSizeKnown(inAdapA, 2)
    n = getSizeInDim(inAdapA, 2);
    R.Adaptor = setKnownSize(R.Adaptor, [n n]);
    if isSizeKnown(inAdapB, 2)
        m = getSizeInDim(inAdapB, 2);
        x.Adaptor = setKnownSize(x.Adaptor, [n m]);
    else
        x.Adaptor = setTallSize(x.Adaptor, n);
    end
end

end

function [R,b] = iChunkQR(A,b)
% Perform QR on one chunk of A and B, returning the economy R and reduced
% b. We also need to take care if A turns out to be scalar since QR does
% not support integers but divide does.

if isscalar(A)
    % If A is scalar then Q=1 and R=A. b is therefore unmodified.
    R = A;
else
    ws = warning('off','all');
    c = onCleanup( @() warning(ws) );
    [Q,R] = qr(A,0);
    b = Q'*b;
end
end

function x = iSolve(R,b)
% Solve R*x=b for x with warnings off
ws = warning('off','all');
c = onCleanup( @() warning(ws) );
x = mldivide(R,b);
end
