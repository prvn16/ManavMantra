function yinterp = ntrp45split(tinterp,t,y,h,f1,f3,f4,f5,f6,f7,idxNonNegative)
%NTRP45SPLIT  Interpolation helper function for ODE45.
%   YINTERP = NTRP45SPLIT(TINTERP,T,Y,H,F1,F3,F4,F5,F6,F7,IDX) uses data 
%   computed in ODE45 to approximate the solution at time TINTERP.  TINTERP  
%   may be a scalar or a row vector. 
%
%   IDX has indices of solution components that must be non-negative. 
%   Negative YINTERP(IDX) are replaced with zeros.

%   Mark W. Reichelt and Lawrence F. Shampine, 6-13-94
%   Copyright 1984-2017 The MathWorks, Inc.

% Define constants as scalars
bi12 = -183/64;   bi13 = 37/12;     bi14 = -145/128;
bi32 = 1500/371;  bi33 = -1000/159; bi34 = 1000/371;
bi42 = -125/32;   bi43 = 125/12;    bi44 = -375/64;
bi52 = 9477/3392; bi53 = -729/106;  bi54 = 25515/6784;
bi62 = -11/7;     bi63 = 11/3;      bi64 = -55/28;
bi72 = 3/2;       bi73 = -4;        bi74 = 5/2;

s = (tinterp - t)/h;  

% Preallocate array then use for loop to iterate
yinterp = zeros(size(y, 1), size(s, 2));
for jj=1:size(s, 2)
    sj = s(jj);
    sj2 = sj.*sj;
    bs1 = (sj + sj2.*(bi12 + sj.*(bi13 + bi14*sj)));
    bs3 = (     sj2.*(bi32 + sj.*(bi33 + bi34*sj)));
    bs4 = (     sj2.*(bi42 + sj.*(bi43 + bi44*sj)));
    bs5 = (     sj2.*(bi52 + sj.*(bi53 + bi54*sj)));
    bs6 = (     sj2.*(bi62 + sj.*(bi63 + bi64*sj)));
    bs7 = (     sj2.*(bi72 + sj.*(bi73 + bi74*sj)));
    
    for ii=1:size(f1, 1)
        yinterp(ii, jj) = y(ii) + h*( f1(ii).*bs1 + f3(ii).*bs3 +  ...
                          f4(ii).*bs4 + f5(ii).*bs5 + f6(ii).*bs6 + f7(ii).*bs7);
    end
end

% Non-negative solution
if ~isempty(idxNonNegative)
  idx = find(yinterp(idxNonNegative,:)<0); % vectorized
  if ~isempty(idx)
    w = yinterp(idxNonNegative,:);
    w(idx) = 0;
    yinterp(idxNonNegative,:) = w;
  end
end  

