function wthrcoef = blockJS(wcoef,lambda,L,sigma)
% This function is for internal use only. It implements the blockJS
% method
% blockJS:   Group the empirical wavelet coefficients into disjoint blocks of
%            length l, and extract the wavelet coefficients using a James-Stein
%            rule
%
%
if isvector(wcoef)
    wcoef = wcoef(:);
end

N = size(wcoef,1);
% Number of time series
NumSig = size(wcoef,2);



% Augment data to get full blocks
% Append beginning coefficients on end of matrix -- this is periodizing
% We may want this symmetric replication at the boundary

wcoefnew = [wcoef ; wcoef(1:L-(rem(N-1,L)+1),:)];

Nnew = size(wcoefnew,1);
NumBlocks = Nnew/L;


% return blocks and block energy
[blocks,S2] = bufferData(wcoefnew,L,NumBlocks);
penalty = lambda*L*sigma.^2;


wthrcoef = zeros(size(blocks));
for nb = 1:NumBlocks
    JSfactor = max(0,1-penalty./S2(nb,:)); 
    %JSfactor = 1;
    JSfactor = repmat(JSfactor',1,L);
    wthrcoef(:,:,nb) = JSfactor.*blocks(:,:,nb);
    
    
end

if isvector(wcoef)
    wthrcoef = reshape(wthrcoef,Nnew,1);
else
    wthrcoef = reshape(permute(wthrcoef,[2 3 1]),Nnew,NumSig);
end
wthrcoef = wthrcoef(1:N,:);


%-------------------------------------------------------------------------
function [blocks,S2] = bufferData(wcoefnew,L,NumBlocks)
% Input is a column vector or matrix
% Each row is a block
N = size(wcoefnew,2);
% Each slice of the matrix will be block
blocks = zeros(L,NumBlocks,N);
for ii = 1:N
    blocks(:,:,ii) = signalwavelet.buffer(wcoefnew(:,ii),L,0);
    
end
blocks = permute(blocks,[3 1 2]);
S2 = zeros(size(blocks,3),size(blocks,1));
for jj = 1:size(blocks,3)
    S2(jj,:) = sum(abs(blocks(:,:,jj)').^2); 
end

%--------------------------------------------------------------------------








