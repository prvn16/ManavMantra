function [errid,errwl,errmaxwl] = validate_power_output_type(a, k, ismpower)
%VALIDATE_POWER_OUTPUT_TYPE Internal use only: compute and check output type

%   Copyright 2009-2012 The MathWorks, Inc.

k = double(k);
awl = a.WordLength;
isipreal = isreal(a);
fm = fimath(a);
pmode = fm.ProductMode;
smode = fm.SumMode;
isprodwlconst = strcmpi(pmode,'KeepMSB')||strcmpi(pmode,'KeepLSB')||strcmpi(pmode,'SpecifyPrecision');
issumwlconst = strcmpi(smode,'KeepMSB')||strcmpi(smode,'KeepLSB')||strcmpi(smode,'SpecifyPrecision');

maxpwlen = fm.MaxProductWordLength;
maxswlen = fm.MaxSumWordLength;

prodwlenexceeded = false;
sumwlenexceeded = false;

if ~ismpower
    % Element-by-element Power
    if ~isprodwlconst && ~issumwlconst
        
        % both product and sum modes are full precision
        if isipreal
            
            prodwlen = k*awl;
        else
            
            prodwlen = k*awl + (k-2);
            sumwlen = k*awl + (k-1);
            sumwlenexceeded = (sumwlen > maxswlen);
        end
        prodwlenexceeded = (prodwlen > maxpwlen);
        
    elseif ~isprodwlconst
        
        % prod mode is full precision; sum mode is not
        if isipreal
            
            prodwlen = k*awl;
        else
            
            prodwlen = (a.SumWordLength+awl);
        end
        prodwlenexceeded = (prodwlen > maxpwlen);
        
    elseif ~issumwlconst
        
        % sum mode is full precision, product mode is not
        if ~isipreal
            
            sumwlen = (a.ProductWordLength+1);
            sumwlenexceeded = (sumwlen > maxswlen);
        end
    end
else
    % Matrix Power
    n = size(a,1);
    nb = ceil(log2(n));
    if ~isipreal
        nbcplx = ceil(log2(n+1));
    end
    % Matrix-power algorithm
    if ~isprodwlconst && ~issumwlconst
        
        % both product and sum modes are full precision
        if isipreal
            
            prodwlen = k*awl + (k-2)*nb;
            sumwlen = k*awl + (k-1)*nb;
        else
            
            prodwlen = k*awl + (k-2)*nbcplx;
            sumwlen = k*awl + (k-1)*nbcplx;
        end
        prodwlenexceeded = (prodwlen > maxpwlen);
        sumwlenexceeded = (sumwlen > maxswlen);
    elseif ~issumwlconst
        
        if isipreal
            
            sumwlen = a.ProductWordLength + nb;
        else
            
            sumwlen = a.ProductWordLength + nbcplx;
        end
        sumwlenexceeded = (sumwlen > maxswlen);
    elseif ~isprodwlconst
        if (k > 2)
            if isipreal 

                pwlen = a.SumWordLength + a.WordLength;
            else

                pwlen = a.SumWordLength + a.WordLength + 1;
            end
            prodwlenexceeded = (pwlen > maxpwlen);            
        end
    end
end
if prodwlenexceeded
    errid = 'fixed:fi:maxProductWordLengthExceeded';
    errwl = prodwlen;
    errmaxwl = maxpwlen;
elseif sumwlenexceeded
    errid = 'fixed:fi:maxSumWordLengthExceeded';
    errwl = sumwlen;
    errmaxwl = maxswlen;
else
    errid = '';
    errwl = [];
    errmaxwl = [];
end    
