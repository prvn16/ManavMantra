function sigMAP = significant_map(option,X,tab_FATHER)
%SIGNIFICANT_MAP Significant map in quadtree of coefficients.
%   SIGNIFICANT_MAP computes the significant map for some
%   compression methods: EZW, STW, SPIHT, SPIHT-3D.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 10-May-2004.
%   Last Revision: 05-Apr-2008.
%   Copyright 1995-2008 The MathWorks, Inc.

sX =  size(X);
if length(sX)<3 , sX(3) = 1; end
nbR = sX(1);
nbNODES = nbR*sX(2);

switch option
    case 'ezw'
        sigMAP = zeros(nbNODES,2*sX(3));
        sigMAP_COL = zeros(sX(3),2);
        for k = 1:sX(3)
            sigMAP_COL(k,:) = (1:2) + (k-1)*2;
        end

        idx_COMPARE = [1 2];
        for j=1:sX(3)
            COL = sigMAP_COL(j,:);
            tmp = X(:,:,j);
            sigMAP(:,COL(1)) = abs(tmp(:));

            idx_PAR = tab_FATHER;
            idx_PAR = idx_PAR(~isnan(idx_PAR));
            idx_PAR = unique(idx_PAR);
            while ~isempty(idx_PAR)
                I = 2*idx_PAR-1;
                lst_CHILD = [I , I+1 , I+nbR, I+1+nbR];
                for k=1:length(idx_PAR)
                    iPar = idx_PAR(k);
                    maxi = max(max(sigMAP(lst_CHILD(k,:),COL(idx_COMPARE))));
                    if sigMAP(iPar,COL(2))<maxi , sigMAP(iPar,COL(2)) = maxi; end
                end
                idx_PAR = tab_FATHER(idx_PAR);
                idx_PAR = idx_PAR(~isnan(idx_PAR));
                idx_PAR = unique(idx_PAR);
            end
        end
        
    case {'spiht','spiht_3d','stw'}
        idx_PAR = tab_FATHER;
        idx_PAR = idx_PAR(~isnan(idx_PAR));
        idx_PAR_INI = unique(idx_PAR);
        idx_COMPARE = [1 2];
        sigMAP = zeros(nbNODES,3*sX(3));
        sigMAP_COL = zeros(sX(3),3);
        for k = 1:sX(3)
            sigMAP_COL(k,:) = (1:3) + (k-1)*3;
        end
        for j=1:sX(3)
            COL = sigMAP_COL(j,:);
            tmp = X(:,:,j);
            sigMAP(:,COL(1)) = abs(tmp(:));
            idx_PAR = idx_PAR_INI;
            while ~isempty(idx_PAR)
                I = 2*idx_PAR-1;
                lst_CHILD = [I , I+1 , I+nbR, I+1+nbR];
                idx_Great_PAR = tab_FATHER(idx_PAR);
                for k=1:length(idx_PAR)
                    iPar = idx_PAR(k);
                    maxi = max(max(sigMAP(lst_CHILD(k,:),COL(idx_COMPARE))));
                    if sigMAP(iPar,COL(2))<maxi , sigMAP(iPar,COL(2)) = maxi; end
                    iGPar = idx_Great_PAR(k);
                    if ~isnan(iGPar) && sigMAP(iGPar,COL(3))<maxi
                        sigMAP(iGPar,COL(3)) = maxi;
                    end
                end
                idx_PAR = idx_Great_PAR;
                idx_PAR = idx_PAR(~isnan(idx_PAR));
                idx_PAR = unique(idx_PAR);
            end
        end
end