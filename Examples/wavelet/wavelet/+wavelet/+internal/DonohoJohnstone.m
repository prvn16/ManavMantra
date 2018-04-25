function [xden,denoisedcfs,origcfs,sigmahat,thr] = DonohoJohnstone(x,level,wavelet,denoisemethod,threshrule,noisestimate)
% This function is for internal use only. It may change in a future release
% [xden,denoisedcfs,origcfs,sigmahat,thr] = ...
% DonohoJohnstone(x,level,wavelet,denoisemethod,threshrule,noisestimate);
% Obtain the wavelet transform
xdec = mdwtdec('c',x,level,wavelet);


% Original CFS.
origcfs = [xdec.cd {xdec.ca}];
M = sum(cell2mat(cellfun(@(x)size(x,1),origcfs,'uni',0)));
N = size(x,2);

% Noise estimates
sigmahat = varest(xdec.cd,N,noisestimate);
% Thresholds obtained from noise estimates and denoising method
threst = threshest(xdec.cd,[M N],sigmahat,denoisemethod);
thr = sigmahat.*threst;
for jj = 1:length(xdec.cd)
    % Thresholds rescaled for application to actual coefficients
    xdec.cd{jj} = wthresh(xdec.cd{jj},threshrule,thr(jj,:));
end


% Package denoised coefficients
denoisedcfs = [xdec.cd {xdec.ca}];
% Invert transform
xden = mdwtrec(xdec);



%-------------------------------------------------------------------------
function sigmahat = varest(wavecfs,numsignals,levelmethod)
% Noise estimates: either level independent where we use just the finest
% scale wavelet coefficients or level dependent where each scale is used
numlevels = numel(wavecfs);

% The following is equivalent to norminv(0.75,0,1) the population MAD
% for a N(0,1) RV
normfac = -sqrt(2)*erfcinv(2*0.75);
sigmahat = NaN(numlevels,numsignals);
if strcmpi(levelmethod,'LevelIndependent')
    sigmaest = median(abs(wavecfs{1}))*(1/normfac);
    % Guard against edge case where the variance of the coefficients is
    % zero so if we denoise ones(16,1) we obtain ones(16,1)
    sigmaest(sigmaest<realmin('double')) = realmin('double');
    sigmahat = repmat(sigmaest,numlevels,1);
elseif strcmpi(levelmethod,'LevelDependent')
    
    for lev = 1:numlevels
        sigmaest = median(abs(wavecfs{lev}))*(1/normfac);
        % Guard against edge case where the variance of the coefficients is
        % zero
        sigmaest(sigmaest<realmin('double')) = realmin('double');
        sigmahat(lev,:) = sigmaest;
    end
    
end


%--------------------------------------------------------------------------
function thr = threshest(wavecfs,sz,sigmahat,denoisemethod)
M = numel(wavecfs);
if strcmpi(denoisemethod,'sqtwolog') || strcmpi(denoisemethod,'minimaxi')
    thr = thselect(ones(sz(1),sz(2)),denoisemethod);
    thr = repmat(thr,M,1);
else
    thr = zeros(M,sz(2));
    for jj = 1:numel(wavecfs)
        thr(jj,:) = thselect(wavecfs{jj}./sigmahat(jj,:),denoisemethod);
    end
end



