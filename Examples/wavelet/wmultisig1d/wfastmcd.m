function covar = wfastmcd(data,alpha,ntrial)
%WFASTMCD Robust covariance matrix.
%   COVAR = WFASTMCD(DATA,ALPHA,NTRIAL)
%
%   COVAR is the robust covariance matrix, obtained after reweighting
%   and multiplying with a finite sample correction factor and  
%   an asymptotic consistency factor, if the raw MCD is not singular. 
%   Otherwise the raw MCD covariance matrix is given here.
%
%   Rousseeuw, P.J. and Van Driessen, K. (1999)
%   "A Fast Algorithm for the Minimum Covariance Determinant Estimator"
%	Technometrics, 41, pp.212-223.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Jan-2005.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2011 The MathWorks, Inc.

% The maximum value for n (= number of observations)
nmax = 50000;

% The maximum value for p (= number of variables)
pmax = 50;

% To change the number of subdatasets and their size, the values of
% maxgroup and nmini can be changed.
maxgroup = 5;
nmini = 300;

% The number of iteration steps in stages 1,2 and 3 can be changed
% by adapting the parameters csteps1, csteps2, and csteps3.
csteps1 = 2;
csteps2 = 2;
csteps3 = 100;

% The 0.975 quantile of the chi-squared distribution.
chi2q = ...
      [ 5.02389,7.37776,9.34840,11.1433,12.8325,...
       14.4494,16.0128,17.5346,19.0228,20.4831,21.920,23.337,...
       24.736,26.119,27.488,28.845,30.191,31.526,32.852,34.170,...
       35.479,36.781,38.076,39.364,40.646,41.923,43.194,44.461,...
       45.722,46.979,48.232,49.481,50.725,51.966,53.203,54.437,...
       55.668,56.896,58.120,59.342,60.561,61.777,62.990,64.201,...
       65.410,66.617,67.821,69.022,70.222,71.420];

seed = 0;

if size(data,1)==1 , data = data'; end

% Observations with missing or infinite values are omitted.
ok = all(isfinite(data),2);
data  = data(ok,:);
[n,p] = size(data);

% Some checks are now performed.
if n==0
   error(message('Wavelet:FunctionArgVal:Invalid_ObsVal'))
elseif n > nmax
   error(message('Wavelet:FunctionArgVal:Invalid_ObsNum', int2str( nmax )))
end

if p > pmax
   error(message('Wavelet:FunctionArgVal:Invalid_NbVar', int2str( pmax )))
end

if n < 2*p
   error(message('Wavelet:FunctionArgVal:Invalid_NbObsVar'))
end

% hmin is the minimum number of observations whose covariance determinant
% will be minimized.
Knp  = 2*(n - floor((n+p+1)/2));
hmin = floor(n - Knp*(1-0.5));
h    = floor(n - Knp*(1-alpha));

if h < hmin
    error(message('Wavelet:FunctionArgVal:Invalid_MCDVal', int2str( hmin )))
elseif h > n
    % msg = ['quan is greater than the number ' ... 
    %        'of non-missings and non-infinites.'];
    error(message('Wavelet:FunctionArgVal:Invalid_ArgVal'))
end

% weights : 
%      weights of the observations that are not excluded  
%      from the computations. These are the observations 
%      that don't contain missing or infinite values.
% bestobj : best objective value found.
bestobj = inf;

% The classical estimates are computed.
clascov = cov(data);

if p < 5
   eps=1e-12;
elseif p <= 8
   eps=1e-14;
else
   eps=1e-16;
end

% The standardization of the data will now be performed.
med = median(data);
mad = sort(abs(data - med(ones(n,1),:)));
mad = mad(h,:);
ii = find((mad < eps),1,'first');
if ~isempty(ii)
   % The h-th order statistic is zero for the ii-th variable. 
   % The array plane contains all the observations which have
   % the same value for the ii-th variable.
   plane = find(abs(data(:,ii)-med(ii)) < eps)';
   if p==1
      covar = 0;
   else
      covar = cov(data(plane,:));
   end
   return
end
data = (data-med(ones(1,n),:))./mad(ones(1,n),:);

% The univariate non-classical case is now handled.
if p==1 && h~=n
    % The exact MCD algorithm for the univariate case.
    y = sort(data);
    ay = zeros(1,n-h+1);
    sq = zeros(1,n-h+1);
    ay(1) = sum(y(1:h));
    for idx=2:n-h+1
        ay(idx) = ay(idx-1)-y(idx-1)+y(idx+h-1);
    end
    ay2 = ay.^2/h;
    sq(1) = sum(y(1:h).^2)-ay2(1);
    for idx=2:n-h+1
        sq(idx) = sq(idx-1)-y(idx-1)^2+y(idx+h-1)^2-ay2(idx)+ay2(idx-1);
    end
    sqmin = min(sq);
    ii = find(sq==sqmin);
    ndup = length(ii);
    slutn(1:ndup) = ay(ii);
    center = slutn(floor((ndup+1)/2))/h;
    tmp  = (rawfactor(n,1,h,alpha)*sqmin)/h;
    scale  = tmp./sqrt(rawfactor(n,p,h,alpha));
    quantile = chi2q(p);
    weights = ((data-center)/scale).^2<quantile;
    factor  = rewfactor(n,p,weights,alpha);
    covar = weightmecov(data,weights,n,p);
    covar = factor*covar.*mad(ones(1,p),:).*mad(ones(1,p),:)';
    return
end

% The standardized classical estimates are now computed.
clcov = cov(data);

if det(clascov) < exp(-50*p)
   covar = clcov.*mad(ones(1,p),:).*mad(ones(1,p),:)';
   return
end

% The classical case is now handled.
if h==n
    clmean = mean(data);
    mah = mahalanobis(data,clmean,clcov,n,p);
    weights = mah <= chi2q(p);
    covar = weightmecov(data,weights,n,p);
    covar = covar.*mad(ones(1,p),:).*mad(ones(1,p),:)';
    return
end
percent = h/n;

%  If n >= 2*nmini the dataset will be divided into subdatasets.  
%  For n < 2*nmini the set will be treated as a whole.
if n >= 2*nmini
    maxobs = maxgroup*nmini;
    if n >= maxobs
        ngroup = maxgroup;
        group(1:maxgroup) = nmini;
    else
        ngroup = floor(n/nmini);
        minquan = floor(n/ngroup);
        group(1) = minquan;
        for s=2:ngroup
            group(s)=minquan+double(rem(n,ngroup)>=s-1); %#ok<AGROW>
        end
    end
    part = 1;
    adjh = floor(group(1)*percent);
    nsamp = floor(ntrial/ngroup);
    minigr = sum(group);
    
    % Creates the subdatasets.
    obsingroup = cell(1,ngroup+1);
    jndex = 0;
    index = zeros(2,1);
    for k=1:ngroup
        for m=1:group(k)
            [random,seed] = uniran(seed);
            ran = floor(random*(n-jndex)+1);
            jndex = jndex+1;
            if jndex==1
                index(1:2,jndex) = [ran ; k];
            else
                index(1:2,jndex) = [ran+jndex-1 ; k];
                ii = find(index(1,1:jndex-1) > ran-1+(1:jndex-1),1,'first');
                if ~isempty(ii)
                    index(1:2,jndex:-1:ii+1) = index(1:2,jndex-1:-1:ii);
                    index(1:2,ii) = [ran+ii-1;k];
                end
            end
        end
        obsingroup{k} = index(1,index(2,:)==k);
        obsingroup{ngroup+1} = [obsingroup{ngroup+1},obsingroup{k}];
    end
    % obsingroup : i-th row contains the observations of the i-th group.
    % The last row (ngroup+1-th) contains the observations for the 2nd 
    % stage of the algorithm.
    
else
    part = 0; group = n; ngroup = 1; adjh = h; minigr =n; obsingroup = n;
    replow = [50,22,17,15,14,zeros(1,45)];
    if n < replow(p)
        % All (p+1)-subsets will be considered.
        all_FLAG = 1;
        perm = [1:p,p];
        nsamp = nchoosek(n,p+1);
    else
        all_FLAG=0;
        nsamp = ntrial;
    end
end

% some further initialisations.

csteps = csteps1;
% tottimes : the total number of iteration steps.
% fine     : becomes 1 when the subdatasets are merged.
% final    : becomes 1 for the final stage of the algorithm.
tottimes = 0; fine = 0; final = 0; prevdet = 0;
if part
    coeff1 = NaN; coeff1 = coeff1(ones(p,ngroup));
    bobj1  = Inf; bobj1 = bobj1(ones(ngroup,10));
    bmean1 = cell(ngroup,10); bmean1(:)= {NaN};
    bcov1  = cell(ngroup,10); bcov1(:) = {NaN};
end
coeff = NaN; coeff = coeff(ones(p,1));
bobj  = Inf; bobj = bobj(ones(1,10));
bmean = cell(1,10); bmean(:)= {NaN};
bcov  = cell(1,10); bcov(:) = {NaN};

seed = 0;
while final~=2
   if fine || (~part && final)
      nsamp = 10;
      if final
          adjh = h;
          ngroup = 1;
          np = n*p;
          if np <= 1e+5
              csteps = csteps3;
          elseif np <=1E6
              csteps = 10-(ceil(np/1E5)-2);
          else
              csteps = 1;
          end
          if n > 5000 , nsamp = 1; end
      else
          adjh = floor(minigr*percent);
          csteps = csteps2;
      end
   end
   
   % found : becomes 1 if we have a singular intermediate MCD estimate. 
   found = 0;
   for k=1:ngroup
      if ~fine , found = 0; end
      for i = 1:nsamp
          tottimes = tottimes+1;
          adj = 1;
          ns = 0;
          if final
              if ~isinf(bobj(i))
                  meanvct = bmean{i};
                  covmat = bcov{i};
                  if bobj(i)==0
                      onesIDX = ones(1,n);
                      dist = abs(sum((data - ...
                              meanvct(onesIDX,:))'.*coeff(:,onesIDX)));
                      [~,sortdist]= sort(dist);
                  else
                      sortdist = ...
                          mahal(data,meanvct,covmat,part,fine,final,k, ...
                          obsingroup,group,minigr,n,p);
                  end
              else
                  break;
              end
          elseif fine
              if ~isinf(bobj1(k,i))
                  meanvct = bmean1{k,i};
                  covmat  = bcov1{k,i};
                  if bobj1(k,i)==0
                      onesIDX = ones(1,minigr);
                      cf1 = coeff1(:,k);
                      [dis,ind] = sort(abs(sum((data(obsingroup{end},:) ...
                                - meanvct(onesIDX,:))'.*cf1(:,onesIDX))));
                      sortdist = obsingroup{end}(ind);
                      if dis(adjh) < 1E-8
                          if found==0
                              obj = 0;
                              coeff = coeff1(:,k);
                              found = 1;
                          else
                              adj=0;
                          end
                          ns=1;
                      end
                  else
                      sortdist = ...
                          mahal(data,meanvct,covmat,part,fine,final,k, ...
                          obsingroup,group,minigr,n,p);
                  end
              else
                  break;
              end
          else
              % The first stage of the algorithm.
              % index : contains trial subsample.
              if ~part
                  if all_FLAG
                      k = p+1; %#ok<FXSET>
                      perm(k) = perm(k)+1;
                      while ~(k==1 || perm(k) <=(n-(p+1-k)))
                          k = k-1; %#ok<FXSET>
                          perm(k)=perm(k)+1;
                          for j = (k+1):p+1
                              perm(j) = perm(j-1)+1;
                          end
                      end
                      index = perm;
                  else
                      [index,seed] = randomset(n,p+1,seed);
                  end
              else
                  [index,seed] = randomset(group(k),p+1,seed);
                  index = obsingroup{k}(index);
              end
              meanvct = mean(data(index,:));
              covmat  = cov(data(index,:));

              if det(covmat) < exp(-50*p)
                  % eigvct : contains the coefficients of the hyperplane.
                  eigvct = eigs(covmat,1,0,struct('disp',0));
                  if ~part , nbONES = n; else nbONES = group(k); end
                  onesIDX = ones(1,nbONES);
                  dist = ...
                    abs(sum((data - meanvct(onesIDX,:))'.*eigvct(:,onesIDX)));
                  obsinplane = find(dist < 1E-8);
                  if length(obsinplane) >= adjh
                      if ~part
                          madTMP = mad(ones(1,p),:);
                          covar = cov(data(obsinplane,:)).*madTMP.*madTMP';
                          return
                      elseif found==0
                          onesIDX = ones(1,n);
                          dist = abs(sum((data - ...
                              meanvct(onesIDX,:))'.*eigvct(1,onesIDX)));
                          obsinplane = find(dist < 1e-8);
                          if length(obsinplane)>=h
                              madTMP = mad(ones(1,p),:);
                              covar = cov(data(obsinplane,:)).*madTMP.*madTMP';
                              return
                          end
                          obj = 0;
                          coeff1(:,k) = eigvct;
                          found = 1;
                      else
                          adj = 0;
                      end
                      ns = 1;
                  else
                      while det(covmat) < exp(-50*p)
                          % Extends a trial subsample with one observation.
                          jndex = length(index);
                          [random,seed] = uniran(seed);
                          ran = floor(random*(n-jndex)+1);
                          jndex = jndex + 1;
                          index(jndex) = ran + jndex - 1;
                          kIDX = 1:jndex-1;
                          ii = find(index(kIDX)>ran-1+kIDX,1,'first');
                          if ~isempty(ii)
                              index(jndex:-1:ii+1) = index(jndex-1:-1:ii);
                              index(ii) = ran+ii-1;
                          end
                          covmat = cov(data(index,:));
                      end
                      meanvct = mean(data(index,:));
                  end
              end
              if ~ns
                  sortdist = ...
                      mahal(data,meanvct,covmat,part,fine,final,k, ...
                      obsingroup,group,minigr,n,p);
              end
          end

          if ~ns
              for j=1:csteps
                  tottimes=tottimes+1;
                  if j > 1
                      sortdist = ...
                          mahal(data,meanvct,covmat,part,fine,final,k, ...
                          obsingroup,group,minigr,n,p);
                  end
                  obs_in_set = sort(sortdist(1:adjh));
                  meanvct = mean(data(obs_in_set,:));
                  covmat = cov(data(obs_in_set,:));
                  obj = det(covmat);
                  if obj < exp(-50*p)
                      if ~part || final || (fine && n==minigr)
                          onesIDX = ones(1,n);
                          z = eigs(covmat,1,0,struct('disp',0));
                          z = z(:,onesIDX);
                          dist = abs(sum((dat - meanvct(onesIDX,:))'.*z));
                          madTMP = mad(ones(1,p),:);
                          covar = cov(data(dist<1e-8,:)).*madTMP.*madTMP';                          
                          return
                      elseif found==0
                          eigvct = eigs(covmat,1,0,struct('disp',0));
                          onesIDX = ones(1,n);
                          dist = abs(sum((data - ...
                                  meanvct(onesIDX,:))'.*eigvct(:,onesIDX)));
                          obsinplane = find(dist<1e-8);
                          if length(obsinplane) >= h
                              madTMP = mad(ones(1,p),:);
                              covar = cov(data(obsinplane,:)).*madTMP.*madTMP';
                              return
                          end
                          obj = 0;
                          found = 1;
                          if ~fine
                              coeff1(:,k) = eigvct;
                          else
                              coeff = eigvct;
                          end
                          break;
                      else
                          adj = 0;
                          break;
                      end
                  end

                  % We stop taking C-steps when two subsequent determinants 
                  % become equal. We have then reached convergence.
                  if j >= 2 && obj == prevdet , break; end
                  prevdet = obj;

              end % C-steps
          end

          if ~final && adj
              if fine || ~part
                  if obj < max(bobj)
                      [bmean,bcov,bobj] = ...
                        insertion(bmean,bcov,bobj,meanvct,covmat,obj,1);
                  end
              else
                  if obj < max(bobj1(k,:))
                      [bmean1,bcov1,bobj1] = ...
                        insertion(bmean1,bcov1,bobj1,meanvct,covmat,obj,k);
                  end
              end
          end
          if final && obj< bestobj
              % bestset : the best subset for the whole data.
              % bestobj : objective value for this set.
              % initmean , initcov : 
              %   resp. the mean and covariance matrix of this set.
              bestobj = obj;
              initmean = meanvct;
              initcov = covmat;
          end
      end % nsamp
   end % ngroup
   if part && ~fine
       fine = 1;
   elseif (part && fine && ~final) || (~part && ~final)
       final = 1;
   else
       final = 2;
   end
end % while loop

% factor : 
% if we multiply the raw MCD covariance matrix with factor, we obtain 
% consistency when the data come from a multivariate normal distribution.
factor = rawfactor(n,p,h,alpha);

%The reweighted robust estimates are now computed.
mah = mahalanobis(data,initmean,initcov*factor,n,p);
quantile = chi2q(p);
weights = mah<quantile;
factor  = rewfactor(n,p,weights,alpha);
covar = weightmecov(data,weights,n,p);
madTMP = mad(ones(1,p),:);
covar = factor*covar.*madTMP.*madTMP';
%--------------------------------------------------------------------------
function wcov = weightmecov(dat,weights,n,nvar)

% Computes the reweighted estimates.
if size(weights,1)==1 , weights = weights'; end
onesIDX = ones(1,nvar);
wmean = sum(dat.*weights(:,onesIDX))/sum(weights);
wcov = zeros(nvar,nvar);
for obs=1:n
   hlp = dat(obs,:) - wmean;
   wcov = wcov + weights(obs)*(hlp'*hlp);
end
wcov = wcov/(sum(weights)-1);
%--------------------------------------------------------------------------
function [ranset,seed] = randomset(tot,nel,seed)

% This function is called if not all (p+1)-subsets out of n will be  
% considered. It randomly draws a subsample of nel cases out of tot.      

ranset = zeros(1,nel);
for j=1:nel
   [random,seed] = uniran(seed);       
   num = floor(random*tot)+1;
   if j > 1
      while any(ranset==num)
         [random,seed] = uniran(seed);       
         num = floor(random*tot)+1;
      end   
   end
   ranset(j) = num;
end
%--------------------------------------------------------------------------
function mahsort = ...
 mahal(dat,meanvct,covmat,part,fine,final,k,obsingroup,group,minigr,n,nvar)

% Orders the observations according to the mahalanobis distances.
if ~part || final
   tmp = mahalanobis(dat,meanvct,covmat,n,nvar);
   [~,mahsort] = sort(tmp);
elseif fine
   [~,ind] = ...
      sort(mahalanobis(dat(obsingroup{end},:),meanvct,covmat,minigr,nvar));
   mahsort = obsingroup{end}(ind);   
else
   [~,ind] = ...
      sort(mahalanobis(dat(obsingroup{k},:),meanvct,covmat,group(k),nvar));
   mahsort = obsingroup{k}(ind);
end
%--------------------------------------------------------------------------
function [bestmean,bestcov,bobj] = ...
    insertion(bestmean,bestcov,bobj,meanvct,covmat,obj,row)

% Stores, for the first and second stage of the algorithm, the results 
% in the appropriate  arrays if it belongs to the 10 best results.
insert = 1;
equ = find(obj==bobj(row,:));
for j = equ
   if (meanvct==bestmean{row,j}) & all(covmat==bestcov{row,j}) %#ok<AND2>
      insert = 0; break
   end
end
if insert
    ins = find(obj<bobj(row,:),1,'first');
    if ins~=10
        bestmean(row,ins+1:10) = bestmean(row,ins:9);
        bestcov(row,ins+1:10) = bestcov(row,ins:9);
        bobj(row,ins+1:10) = bobj(row,ins:9);
    end
    bestmean{row,ins} = meanvct;
    bestcov{row,ins} = covmat;
    bobj(row,ins) = obj;
end
%--------------------------------------------------------------------------
function mah = mahalanobis(dat,meanvct,covmat,n,p)

% Computes the mahalanobis distances.
for k=1:p
   d = covmat(k,k);
   covmat(k,:) = covmat(k,:)/d;
   rows = [1:k-1,k+1:p];
   b = covmat(rows,k);
   covmat(rows,:) = covmat(rows,:)-b*covmat(k,:);
   covmat(rows,k) = -b/d;   
   covmat(k,k) = 1/d;
end
hlp = dat - meanvct(ones(1,n),:);
mah = sum(hlp*covmat.*hlp,2)';
%--------------------------------------------------------------------------
function [random,seed] = uniran(seed)

% The random generator.
seed = floor(seed*5761)+999;
seed = floor(seed)-floor(floor(seed/65536)*65536);
random = seed/65536;
%--------------------------------------------------------------------------
function factor = rewfactor(n,p,weights,alpha)

if sum(weights)==n
    factor = 1;
else
    qdelta = qchisq(sum(weights)/n,p)/2;
    g = gammainc(qdelta,p/2+1);
    g(qdelta<0) = 0;
    factor = sum(weights)/(n*g);
end

if p > 2
    coeffrewqpkwad500 = ...
        [-1.02842572724793 , 1.67659883081926,2;
         -0.26800273450853 , 1.35968562893582,3]';
    y_500 = [log(-(coeffrewqpkwad500(1,1)*1)/p^coeffrewqpkwad500(2,1));
             log(-(coeffrewqpkwad500(1,2)*1)/p^coeffrewqpkwad500(2,2))];
    A_500 = [1 , log(1/(coeffrewqpkwad500(3,1)*p^2));...
             1 , log(1/(coeffrewqpkwad500(3,2)*p^2))];
    coeffic_500 = A_500\y_500;
    fp_500_n = 1-(exp(coeffic_500(1))*1)/n^coeffic_500(2);

    coeffrewqpkwad875 = ...
        [-0.544482443573914 , 1.25994483222292,2;
         -0.343791072183285 , 1.25159004257133,3]';
    y_875 = [log(-(coeffrewqpkwad875(1,1)*1)/p^coeffrewqpkwad875(2,1));
             log(-(coeffrewqpkwad875(1,2)*1)/p^coeffrewqpkwad875(2,2))];
    A_875 = [1 , log(1/(coeffrewqpkwad875(3,1)*p^2)); ...
             1 , log(1/(coeffrewqpkwad875(3,2)*p^2))];
    coeffic_875 = A_875\y_875;
    fp_875_n = 1-(exp(coeffic_875(1))*1)/n^coeffic_875(2);

elseif p == 2
    fp_500_n = 1-(exp(3.11101712909049)*1)/n^1.91401056721863;
    fp_875_n = 1-(exp(0.79473550581058)*1)/n^1.10081930350091;    
    
elseif p == 1
    fp_500_n = 1-(exp(1.11098143415027)*1)/n^1.5182890270453;
    fp_875_n = 1-(exp(-0.66046776772861)*1)/n^0.88939595831888;
end
if 0.5 <= alpha && alpha <= 0.875
   fp_alpha_n = fp_500_n + (fp_875_n-fp_500_n)/0.375*(alpha-0.5);
elseif 0.875 < alpha && alpha < 1 
   fp_alpha_n = fp_875_n + (1-fp_875_n)/0.125*(alpha-0.875);
end            
factor = factor/fp_alpha_n;
%--------------------------------------------------------------------------
function factor = rawfactor(n,p,quan,alpha)

qalpha = qchisq(quan/n,p)/2;
g = gammainc(qalpha,p/2+1);
g(qalpha<0) = 0;
factor = quan/(n*g);

if p > 2
    coeffqpkwad500 = ...
        [-1.42764571687802 , 1.26263336932151,2; ...
         -1.06141115981725 , 1.28907991440387,3]';
    y_500 = [log(-(coeffqpkwad500(1,1)*1)/p^coeffqpkwad500(2,1));
             log(-(coeffqpkwad500(1,2)*1)/p^coeffqpkwad500(2,2))];
    A_500 = [1 , log(1/(coeffqpkwad500(3,1)*p^2));...
             1 , log(1/(coeffqpkwad500(3,2)*p^2))];
    coeffic_500 = A_500\y_500;
    fp_500_n = 1-(exp(coeffic_500(1))*1)/n^coeffic_500(2);
    
    coeffqpkwad875 = ...
        [-0.455179464070565 , 1.11192541278794,2;
         -0.294241208320834 , 1.09649329149811,3]';
    y_875 = [log(-(coeffqpkwad875(1,1)*1)/p^coeffqpkwad875(2,1)); 
             log(-(coeffqpkwad875(1,2)*1)/p^coeffqpkwad875(2,2))];
    A_875 = [1 , log(1/(coeffqpkwad875(3,1)*p^2)); ...
             1 , log(1/(coeffqpkwad875(3,2)*p^2))];
    coeffic_875 = A_875\y_875;
    fp_875_n = 1-(exp(coeffic_875(1))*1)/n^coeffic_875(2);

elseif p == 2
    fp_500_n = 1-(exp(0.673292623522027)*1)/n^0.691365864961895;
    fp_875_n = 1-(exp(0.446537815635445)*1)/n^1.06690782995919;

elseif p == 1
    fp_500_n = 1-(exp(0.262024211897096)*1)/n^0.604756680630497;
    fp_875_n = 1-(exp(-0.351584646688712)*1)/n^1.01646567502486;
end
if 0.5 <= alpha && alpha <= 0.875
    fp_alpha_n = fp_500_n + (fp_875_n-fp_500_n)/0.375*(alpha-0.5);
elseif 0.875 < alpha && alpha < 1
    fp_alpha_n = fp_875_n + (1-fp_875_n)/0.125*(alpha-0.875);
end
factor = factor/fp_alpha_n;
%--------------------------------------------------------------------------
function x = qchisq(p,a)
%QCHISQ The chisquare inverse distribution function
%       x = qchisq(p,DegreesOfFreedom)

if any(any(abs(2*p-1)>1))
   error(message('Wavelet:FunctionArgVal:Invalid_ProbVal'))
elseif any(any(a<=0))
   error(message('Wavelet:FunctionArgVal:Invalid_FreeDeg'))
end

a = 0.5*a;
x = max(a-1,0.1);
dx = 1;
while any(any(abs(dx)>256*eps*max(x,1)))
    f = x .^ (a-1) .* exp(-x) ./ gamma(a);
    g = gammainc(x,a);
    neg = x<0;
    f(neg) = 0;
    g(neg) = 0;
    dx = (g - p) ./ f;
    x = x - dx;
    x = x + (dx - x) / 2 .* (x<0);
end
x(p==0) = 0;
x(p==1) = Inf;
x = 2*x;
%--------------------------------------------------------------------------
function xy = cov(x)
%COV Covariance matrix.

if length(x)==numel(x) , x = x(:); end
m = size(x,1);

if m==0
    xy = [];
elseif m==1
    xy = 0;
else
    tmp = sum(x)/m;
    xc = x - tmp(ones(1,m),:);
    xy = xc' * xc;
    xy = 0.5*(xy+xy')/(m-1);
end
%--------------------------------------------------------------------------
