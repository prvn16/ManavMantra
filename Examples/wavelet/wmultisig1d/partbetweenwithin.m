function [inter_SUR_intra,inter_SUR_intra_N,tBETWEEN,tWITHIN] = ...
    partbetweenwithin(X,groupe)
%PARTBETWEENWITHIN Variance between and within clusters
%   [inter_SUR_intra,inter_SUR_intra_N,TBETWEEN,TWITHIN] = ...
%                  partbetweenwithin(X,G)
%
%   For a matrix X (n x p) and a vector of cluster G of length n,
%   PARTBETWEENWITHIN computes the variances within classes 
%   WITHIN and beetween classes BETWEEN, and then the 
%   associated scalar values TWITHIN and tBETWEEN.
%
%   The quality and the normalized quality indices are: 
%       inter_SUR_intra   = TBETWEEN./TWITHIN
%       inter_SUR_intra_N = TBETWEEN./(nbCLU*TWITHIN)
%
%   G can be a matrix of size (n x nbpart)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-Nov-2005.
%   Last Revision: 27-Sep-2006.
%   Copyright 1995-2006 The MathWorks, Inc.

[n,p]   = size(X);
TabPART = tab2part(groupe);
nbPART  = length(TabPART);
Inertia_INI = (norm(X,'fro')^2)-n*(norm(mean(X,1))^2);

tWITHIN  = zeros(1,nbPART);
tBETWEEN = zeros(1,nbPART);
NbCLU = cat(2,TabPART(:).NbCLU);

for j = 1:nbPART
    nbgroupe  = NbCLU(j);
    effectif  = TabPART(j).NbInCLU;
    
    % Compute WITHIN.
    %----------------
    tSSWITHIN = 0;
    meank = zeros(nbgroupe,p);
    for k = 1:nbgroupe
        xk = X(TabPART(j).IdxInCLU{k},:);
        nbIN = size(xk,1);
        if nbIN>1
            g = mean(xk);
            I = (norm(xk,'fro')^2)-nbIN*(norm(g)^2); % Compute inertia
        else
            g = xk;
            I = 0;   % inertia
        end
        meank(k,:) = g;
        tSSWITHIN = tSSWITHIN + I;
    end
    tWITHIN(j) = tSSWITHIN/(n-nbgroupe);
    
    
    % Compute BETWEEN (Inertie Ponderee G et normalisation).
    %-------------------------------------------------------
    % gravity center and inertia
    tSSBETWEEN = 0;
    G = zeros(1,p);
    
    % Compute gravity center
    for k=1:nbgroupe      
        G = G + effectif(k)*meank(k,:);
    end
    G = G/n;
    
    % Compute inertia with respect to  0
    for k=1:nbgroupe      
        tSSBETWEEN = tSSBETWEEN + effectif(k)*norm(meank(k,:),2)^2;
    end
    
    % Compute inertia with respect to G
    tSSBETWEEN = tSSBETWEEN - n * norm(G,2)^2;

    % Normalize.
    tBETWEEN(j) = tSSBETWEEN/(n-1);

    % Controle.
    if (abs(Inertia_INI - (tSSWITHIN + tSSBETWEEN))/Inertia_INI >0.001)
        disp('the difference in BW is too large')
    end    
end

% Compute performances.
inter_SUR_intra = tBETWEEN./tWITHIN;
inter_SUR_intra_N = inter_SUR_intra./NbCLU;
