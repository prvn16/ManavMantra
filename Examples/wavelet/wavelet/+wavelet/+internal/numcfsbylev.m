function numcfsbylevel = numcfsbylev(N,wname)
% This function is for internal use only and may change in a future release
[~,HiD] = wfilters(wname);
filterlength = numel(HiD);
mode = dwtmode('status','nodisp');
if ~strcmp(mode,'per')
    LF = filterlength-1;
    LenExt = 2*LF;
else
    LenExt = filterlength/2;
    LF = LenExt-1;
end
lev = 1;
diffLevel = Inf;
Norig = N;
while (diffLevel > 0 && lev<= floor(log2(Norig)))
    validConvLength =  N+LenExt-LF;
    numcfsbylevel(lev) = floor(validConvLength/2); %#ok<AGROW>
    N = numcfsbylevel(lev);
    if lev > 1
        diffLevel = numcfsbylevel(lev-1)-numcfsbylevel(lev);
    end
    lev = lev+1;
    
end




