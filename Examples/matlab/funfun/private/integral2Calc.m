function [q,errbnd] = integral2Calc(fun,xmin,xmax,ymin,ymax,optionstruct)
%INTEGRAL2CALC  Perform INTEGRAL2 calculation

%   Copyright 2008-2013 The MathWorks, Inc.

if strcmpi(optionstruct.Method,'iterated')
    [q,errbnd] = integral2i(fun,xmin,xmax,ymin,ymax,optionstruct);
else
    [q,errbnd] = integral2t(fun,xmin,xmax,ymin,ymax,optionstruct);
end
end

%--------------------------------------------------------------------------

function [q,errbnd] = integral2i(fun,xmin,xmax,ymin,ymax,opstruct)
% Iterated integration.
innerintegral = @(x)arrayfun(@(xi,y1i,y2i)integralCalc( ...
    @(y)fun(xi*ones(size(y)),y),y1i,y2i,opstruct.integralOptions), ...
    x,ymin(x),ymax(x));
[q,errbnd] = integralCalc(innerintegral,xmin,xmax,opstruct.integralOptions);
end % integral2i

%==========================================================================

function [Q,ERRBND] = integral2t(FUN,XMIN,XMAX,YMIN,YMAX,opstruct)
%   The 'tiled' method is based on "TwoD" by Lawrence F. Shampine.
%   Ref: L.F. Shampine, "Matlab Program for Quadrature in 2D",
%   Appl. Math. Comp., 202 (2008) 266-274.
%   Variables accessed in nested functions are written in all caps.
ATOL = opstruct.AbsTol;
RTOL = opstruct.RelTol;
defaultMaxFunEvals = 10000;
maxFunEvals = ceil(defaultMaxFunEvals*opstruct.Persistence);
% With singularity-weakening transformation:
thetaL = 0; thetaR = pi; phiB = 0; phiT = pi;
% Without the transform this would have been:
% thetaL = XMIN; thetaR = XMAX; phiB = 0; phiT = 1;
AREA = (thetaR - thetaL)*(phiT - phiB);
% Gauss-Kronrod (3,7) pair with degrees of precision 5 and 11.
rule = Gauss3Kronrod7;
nodes = rule.Nodes;
NNODES = length(nodes);
ONEVEC = ones(2*NNODES,1);
NARRAY = [nodes+1,nodes+3]/4;
WT3 = rule.LowWeights;
WT7 = rule.HighWeights;
% Some indices between 1 and 4*NNODES^2.
VTSTIDX = reshape(1+(1:6)*floor(NNODES*NNODES/2),2,3);
FIRSTFUNEVAL = true;
NFE = 0;
% Compute initial approximations on four subrectangles. Initialize RECTLIST
% of information about subrectangles for which the approximations are not
% sufficiently accurate. NRECTS is the number of subrectangles that remain
% to be processed. ERRBND is a bound on the error.
[Qsub,esub] = tensor(thetaL,thetaR,phiB,phiT);
Q = sum(Qsub);
outcls = class(Q);
EPS100 = 100*eps(outcls);
if RTOL < EPS100
    RTOL = EPS100;
end
if isa(EPS100,'double')
    % Single RTOL or ATOL should not force any single precision
    % computations.
    RTOL = double(RTOL);
    ATOL = double(ATOL);
end
rtold8 = max(RTOL/8,EPS100);
atold8 = ATOL/8;
% Use an artificial value of TOL to force the program to refine.
TOL = EPS100*abs(Q);
ERR_OK = 0;
ADJUST = 1;
% Initialize storage lists before first call to SaveRectInfo.
XREFLIST = [];
QSUBLIST = zeros(0,outcls);
ADJERRLIST = zeros(0,outcls);
RECTLIST = zeros(5,0,outcls);
NRECTS = 0;
minRectWarn = false;
maxNFEWarn = false;
SaveRectInfo(Qsub,esub,thetaL,thetaR,phiB,phiT);
while NRECTS > 0 && ERRBND > TOL
    % Get entries from RECTLIST corresponding to the biggest (adjusted)
    % error.
    [q,e,thetaL,thetaR,phiB,phiT,adjerr] = NextEntry;
    % Approximate integral over four subrectangles.
    [Qsub,esub] = tensor(thetaL,thetaR,phiB,phiT,q,adjerr);
    % Saved in RECTLIST is "e", a conservative estimate of the error in the
    % approximation "q" of the integral over a rectangle. Newq = sum(Qsub)
    % is a much better approximation to the integral. It is used here to
    % estimate the error in "q" and thereby determine that the estimator is
    % conservative by a factor of "ADJUST". This factor is applied to the
    % estimate of the error in "Newq" to get a more realistic estimate.
    % This scheme loses the sign of the error, so a conservative local test
    % is used to decide convergence.
    if isscalar(Qsub)
        % The rectangle was not subdivided because doing so would have
        % forced an evaluation on the boundary of the region of
        % integration.
        minRectWarn = true;
        % Move the contribution of adjerr to ERR_OK. It has already been
        % removed from ADJERRLIST.
        ERR_OK = ERR_OK + adjerr;
        ERRBND = ERR_OK + sum(ADJERRLIST);
    else
        Newq = sum(Qsub);
        ADJUST = min(1,abs(q - Newq)/e);
        Q = Q + (Newq - q);
        TOL = max(atold8,rtold8*abs(Q));
        SaveRectInfo(Qsub,esub,thetaL,thetaR,phiB,phiT);
        if NFE >= maxFunEvals
            maxNFEWarn = true;
            break
        end
    end
end % while
if ~(isfinite(Q) && isfinite(ERRBND))
    % Example:
    % integral2(@(x,y)1./(x+y),0,0,0,0)
    warning(message('MATLAB:integral2:nonFiniteResult'));
    if opstruct.ThrowOnFail
        error(message('MATLAB:integral2:unsuccessful'));
    end
elseif maxNFEWarn
    if ERRBND > max(ATOL,RTOL*abs(Q))
        % Example:
        % integral2(@(x,y)single(1./(x+y)),0,1,0,1,'Abstol',1e-4,'MaxFunEvals',3)
        warning(message('MATLAB:integral2:maxFunEvalsFail',maxFunEvals));
        if opstruct.ThrowOnFail
            error(message('MATLAB:integral2:unsuccessful'));
        end
    else
        % Example:
        % integral2(@(x,y)single(1./(x+y)),0,1,0,1,'Abstol',1e-4,'MaxFunEvals',4)
        warning(message('MATLAB:integral2:maxFunEvalsPass',maxFunEvals));
    end
elseif minRectWarn
    if ERRBND > max(ATOL,RTOL*abs(Q))
        % Example:
        % integral2(@(x,y)single(1./(x+y)),0,1,0,single(1),'Abstol',1e-5)
        warning(message('MATLAB:integral2:minRectSizeFail'));
        if opstruct.ThrowOnFail
            error(message('MATLAB:integral2:unsuccessful'));
        end
    else
        % Example:
        % integral2(@(x,y)single(1./(x+y)),0,1,0,1,'Abstol',1e-4)
        warning(message('MATLAB:integral2:minRectSizePass'));
    end
end

%--------------------------------------------------------------------------

    function [Qsub,esub] = tensor(thetaL,thetaR,phiB,phiT,Qsub,esub)
        % Compute the integral with respect to theta from thetaL to thetaR
        % of the integral with respect to phi from phiB to phiT of F in
        % four blocks.
        % On the first call:
        %     The Qsub and esub input arguments are ignored. The input
        %     rectangle is subdivided into 4 subrectangles. The Qsub and
        %     esub output arguments are 4-element vectors of integral and
        %     error estimates, respectively. The first call also carries
        %     out some one-time error checking on the vectorization of F,
        %     YMIN, and YMAX functions.
        % On subsequent calls:
        %     Input Qsub should be the integral estimate for the input
        %     rectangle from RECTLIST, and esub should be the adjusted
        %     error estimate for this rectangle from ADJERRLIST. Normally
        %     the rectangle is subdivided, and Qsub and esub will be
        %     4-element vectors of integral and error estimates,
        %     respectively. However, if, due to roundoff error, subdividing
        %     the interval would force an evaluation on the boundary of the
        %     region, the rectangle is not subdivided, and scalars Qsub and
        %     esub are returned unchanged.
        dtheta = thetaR - thetaL;
        theta = thetaL + NARRAY*dtheta;
        % With singularity-weakening transformation:
        x = 0.5*(XMAX + XMIN) + 0.5*(XMAX - XMIN)*cos(theta);
        if ~FIRSTFUNEVAL && (x(1) == XMAX || x(end) == XMIN)
            return
        end
        % Without the transform this would have been:
        % x = theta;
        % if ~FIRSTFUNEVAL && (x(1) == XMIN || x(end) == XMAX)
        %     return
        % end
        X = x(ONEVEC,:);
        bottom = YMIN(x);
        top = YMAX(x);
        if FIRSTFUNEVAL
            % Validate ymin(x) and ymax(x).
            if ~isfloat(bottom)
                error(message('MATLAB:integral2:UnsupportedClass',class(bottom)));
            end
            if ~isfloat(top)
                error(message('MATLAB:integral2:UnsupportedClass',class(top)));
            end
            if ~isequal(size(bottom),size(x))
                % Example:
                % integral2(@(x,y)x+y,0,1,@(x)0,1)
                error(message('MATLAB:integral2:yMinSizeMismatch'));
            end
            if ~isequal(size(top),size(x))
                % Example:
                % integral2(@(x,y)x+y,0,1,0,@(x)1)
                error(message('MATLAB:integral2:yMaxSizeMismatch'));
            end
            if any(~isfinite(bottom) | ~isfinite(top))
                % Example:
                % integral2(@(x,y)x+y,0,1,@(x)-inf(size(x)),1)
                error(message('MATLAB:integral2:nonFiniteLimit'));
            end
        end
        dydt = top - bottom;
        dphi = phiT - phiB;
        phi = phiB + NARRAY(:)*dphi;
        % With singularity-weakening transformation:
        Y = bottom(ONEVEC,:) + (0.5 + 0.5*cos(phi))*dydt;
        if ~FIRSTFUNEVAL && any(Y(1,:) == top | Y(end,:) == bottom)
            return
        end
        % Without the transform this would have been:
        % Y = bottom(ONEVEC,:) + phi*dydt;
        % if ~FIRSTFUNEVAL && any(Y(1,:) == bottom | Y(end,:) == top)
        %     return
        % end
        Z = FUN(X,Y);  NFE = NFE + 1;
        if FIRSTFUNEVAL
            if ~isfloat(Z)
                error(message('MATLAB:integral2:UnsupportedClass',class(Z)));
            end
            % Check that FUN is properly vectorized. This is important here
            % because we (otherwise) always pass in square matrices, which
            % reduces the probability of the user generating an error by
            % using matrix functions instead of elementwise functions.
            Z1 = FUN(X(VTSTIDX),Y(VTSTIDX)); NFE = NFE + 1;
            if ~isequal(size(Z),size(X)) || ~isequal(size(Z1),size(VTSTIDX))
                % Example:
                % integral2(@(x,y)1,0,1,0,1)
                error(message('MATLAB:integral2:funSizeMismatch'));
            end
            Z0 = Z(VTSTIDX);
            if any(any(abs(Z1-Z0) > max(ATOL,RTOL*max(abs(Z1),abs(Z0)))))
                % Example:
                % integral2(@(x,y)x+y(1),0,1,0,1)
                warning(message('MATLAB:integral2:funVectorization'));
            end
            FIRSTFUNEVAL = false; % First evaluation only.
        end
        % Full matrix formed as outer product.
        % With singularity-weakening transformation:
        temp = 0.25*(XMAX - XMIN)*sin(phi)*(dydt .* sin(theta));
        % Without the transform this would have been:
        % temp = dydt(ONEVEC,:);
        Z = Z .* temp;
        Z = [Z(1:NNODES,:),Z(NNODES+1:end,:)];
        r = (dtheta/4)*(dphi/4);
        % Kronrod 7 point formula tensor product.
        Qsub = (WT7 * reshape(WT7*Z,NNODES,4))*r;
        % Gauss 3 point formula tensor product and difference with Qsub.
        esub = abs((WT3*reshape(WT3*Z,NNODES,4))*r - Qsub);
    end % tensor

%--------------------------------------------------------------------------

    function SaveRectInfo(Qsub,esub,thetaL,thetaR,phiB,phiT)
        % Save information about subrectangles for which the integral is
        % not sufficiently accurate. The information is stored in four
        % arrays:
        %   RECTLIST   The columns of the RECTLIST matrix are [e;L;R;B;T],
        %              corresponding to the last 5 inputs of this function.
        %   QSUBLIST   List of Qsub values kept in the same order as
        %              RECTLIST.  This array may be complex.
        % ADJERRLIST   A list of adjusted errors kept in ascending order.
        %   XREFLIST   a cross-reference list: ADJERRLIST(idx) corresponds
        %              to RECTLIST(XREFLIST(idx)).
        %
        % NRECTS is the number of active entries in each of these lists.
        % This may be less than what is allocated. Unused entries are at
        % the end. Unused entries of ADJERRLIST and XREFLIST are zero.
        % Unused rows of RECTLIST may contain old data.
        dthetad2 = (thetaR - thetaL)/2;
        thetaM = thetaL + dthetad2;
        dphid2 = (phiT - phiB)/2;
        phiM = phiB + dphid2;
        localtol = TOL*dthetad2*dphid2/AREA;
        localtol = max(abs(localtol),EPS100*abs(sum(Qsub)));
        adjer = ADJUST*esub;
        % Process each subrectangle, either adding it to the lists for
        % further subdivision or adding its adjusted error to ERR_OK.
        % Process subrectangle 1.
        if adjer(1) > localtol
            AddToLists(Qsub(1),esub(1),thetaL,thetaM,phiB,phiM,adjer(1));
        else
            ERR_OK = ERR_OK + adjer(1);
        end
        % Process subrectangle 2.
        if adjer(2) > localtol
            AddToLists(Qsub(2),esub(2),thetaM,thetaR,phiB,phiM,adjer(2));
        else
            ERR_OK = ERR_OK + adjer(2);
        end
        % Process subrectangle 3.
        if adjer(3) > localtol
            AddToLists(Qsub(3),esub(3),thetaL,thetaM,phiM,phiT,adjer(3));
        else
            ERR_OK = ERR_OK + adjer(3);
        end
        % Process subrectangle 4.
        if adjer(4) > localtol
            AddToLists(Qsub(4),esub(4),thetaM,thetaR,phiM,phiT,adjer(4));
        else
            ERR_OK = ERR_OK + adjer(4);
        end
        % Compute updated ERRBND.
        ERRBND = ERR_OK + sum(ADJERRLIST);
    end % SaveRectInfo

%--------------------------------------------------------------------------

    function AddToLists(q,e,L,R,B,T,adjerr)
        % Add [e,L,R,B,T] to RECTLIST, q to QSUBLIST, adjerr to the
        % ascending array ADJERRLIST, and cross reference index to
        % XREFLIST.
        if NRECTS >= numel(XREFLIST)
            growby = 64;
            XREFLIST(NRECTS+growby) = 0;
            RECTLIST(5,NRECTS+growby) = 0;
            ADJERRLIST(NRECTS+growby) = 0;
            QSUBLIST(NRECTS+growby) = 0;
        end
        NRECTS = NRECTS + 1;
        idx = find(adjerr<ADJERRLIST,1);
        if isempty(idx)
            idx = NRECTS;
        end
        % Insert sorted adjerr ascending into ADJERRLIST.
        ADJERRLIST(idx+1:NRECTS) = ADJERRLIST(idx:NRECTS-1);
        ADJERRLIST(idx) = adjerr;
        % Insert the cross-reference index into XREFLIST.
        XREFLIST(idx+1:NRECTS) = XREFLIST(idx:NRECTS-1);
        XREFLIST(idx) = NRECTS;
        % Save the data in RECTLIST.
        RECTLIST(:,NRECTS) = [e;L;R;B;T];
        QSUBLIST(NRECTS) = q;
    end % AddToLists

%--------------------------------------------------------------------------

    function [q,e,L,R,B,T,adjerr] = NextEntry
        % Return the next entry of RECTLIST and associated information.
        % This is normally the rectangle with the largest adjusted error,
        % but if the number of rectangles is greater than 2000 it will be
        % the one with the smallest adjusted error. This strategy tends to
        % arrest growth of the RECTLIST array.
        smallestFirst = NRECTS > 2000;
        if smallestFirst
            idx = XREFLIST(1);
            adjerr = ADJERRLIST(1);
        else
            idx = XREFLIST(NRECTS);
            adjerr = ADJERRLIST(NRECTS);
        end
        temp = RECTLIST(:,idx);
        e = temp(1); L = temp(2); R = temp(3); B = temp(4); T = temp(5);
        q = QSUBLIST(idx);
        if idx ~= NRECTS
            % If idx doesn't correspond to the last active row of RECTLIST,
            % the idx row is overwritten by the last active row.
            RECTLIST(:,idx) = RECTLIST(:,NRECTS);
            QSUBLIST(idx) = QSUBLIST(NRECTS);
            XREFLIST(find(XREFLIST==NRECTS,1)) = idx;
        end
        if smallestFirst
            % We removed the first element of the sorted lists, so we must
            % shift the others.
            XREFLIST(1:NRECTS-1) = XREFLIST(2:NRECTS);
            ADJERRLIST(1:NRECTS-1) = ADJERRLIST(2:NRECTS);
        end
        XREFLIST(NRECTS) = 0;
        ADJERRLIST(NRECTS) = 0;
        NRECTS = NRECTS - 1;
    end

end % integral2t
