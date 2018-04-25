function S = rats(X,lens)
%RATS   Rational output.
%   RATS(X,LEN) uses RAT to display rational approximations to
%   the elements of X.  The string length for each element is LEN.
%   The default is LEN = 13, which allows 6 elements in 78 spaces.
%   For complex X, the string length for each element is 2*LEN+2.
%   Asterisks are used for elements which can't be printed in the
%   allotted space, but which are not negligible compared to the other
%   elements in X.
%
%   The same algorithm, with the default LEN, is used internally
%   by MATLAB for FORMAT RAT.
%
%   Class support for input X:
%      float: double, single
%
%   See also FORMAT, RAT.

%   Copyright 1984-2013 The MathWorks, Inc.

if nargin < 2, lens = 13; end
if isempty(X)
    S = '';
    return
end
if isnan(lens) || ~isfinite(lens)
    error(message('MATLAB:nonaninf'));
end
lhalf = (lens-1)/2;
[m,n] = size(X);
nform = ['%' num2str(floor(lhalf)) '.0f'];
dform = ['%-' num2str(ceil(lhalf)) '.0f'];
S = [];
if isreal(X)
    tol = min(10^(-lhalf) * norm(X(isfinite(X)),1),.1);
    [N,D] = rat(X,tol);
    for i = 1:m
        s = '';
        for j = 1:n
            if D(i,j) ~= 1
                sj = [sprintf(nform,N(i,j)) '/' sprintf(dform,D(i,j))];
            else
                sj = cpad(sprintf('%1.0f',N(i,j)),lens);
            end
            if length(sj) > lens
                sj = cpad('*',lens);
            end
            s = [s ' ' sj];
        end
        S(i,:) = s;
    end
else
    realX = real(X);
    imagX = imag(X);
    tolR = min(10^(-lhalf) * norm(realX(isfinite(realX)),1),.1);
    tolI = min(10^(-lhalf) * norm(imagX(isfinite(imagX)),1),.1);
    [NR,DR] = rat(realX,tolR);
    [NI,DI] = rat(imagX,tolI);
    for i = 1:m
        s = '';
        for j = 1:n
            % real part
            if DR(i,j) ~= 1
                sjR = [sprintf(nform,NR(i,j)) '/' sprintf(dform,DR(i,j))];
            else
                sjR = cpad(sprintf('%1.0f',NR(i,j)),lens);
            end
            if length(sjR) > lens
                sjR = cpad('*',lens);
            end
            % imaginary part
            if DI(i,j) ~= 1
                if NI(i,j) >= 0
                    sjI = ['+' sprintf(nform, NI(i,j)) '/' ...
                        rpad([sprintf('%1.0f',DI(i,j)) 'i'],ceil(lhalf)+1)];
                else
                    sjI = ['-' sprintf(nform,-NI(i,j)) '/' ...
                        rpad([sprintf('%1.0f',DI(i,j)) 'i'],ceil(lhalf)+1)];
                end
            else
                if NI(i,j) >= 0
                    sjI = ['+' cpad([sprintf('%1.0f', NI(i,j)) 'i'],lens+1)];
                else
                    sjI = ['-' cpad([sprintf('%1.0f',-NI(i,j)) 'i'],lens+1)];
                end
            end
            if length(sjI) > lens+2
                if NI(i,j) >= 0
                    sjI = ['+' cpad('*i',lens+1)];
                else
                    sjI = ['-' cpad('*i',lens+1)];
                end
            end
            s = [s ' ' sjR sjI];
        end
        S(i,:) = s;
    end
end
S = char(S);


%-----------------------------
function t = rpad(s,len)
%RPAD Right pad with blanks.

t = [s blanks(len-length(s))];


%----------------------------
function t = cpad(s,len)
%CPAD Pad and center string with blanks.

padding = len-length(s);
t = [blanks(floor(padding/2)) s blanks(ceil(padding/2))];
