function varargout = partstdqual(PART,signals,flagN)
%PARTSTDQUAL Partition STD quality indices.
%   [sdtQ1,sdt_Q2,glb_STD,meanVAL,medianVAL,loc_STD] = ...
%           partstdqual(PART,signals)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 02-Feb-2006.
%   Last Revision: 06-Sep-2006.

if nargin<3 , flagN = 0; end
nbPART = length(PART);
nbVAL  = size(signals,2);
if nbPART>1 , OUT = cell(nbPART,6); end
for j =1:nbPART
    if iscell(PART(j)), curPART = PART{j}; else  curPART  = PART(j); end
    NbCLU    = curPART.NbCLU;
    IdxInCLU = curPART.IdxInCLU;
    meanVAL  = zeros(NbCLU,nbVAL);
    medianVAL = zeros(NbCLU,nbVAL);
    loc_STD  = zeros(NbCLU,nbVAL);
    glb_STD  = zeros(NbCLU,1);
    maxVAL   = zeros(NbCLU,1);
    minVAL   = zeros(NbCLU,1);
    for k = 1:NbCLU
        Sig = signals(IdxInCLU{k},:);
        meanVAL(k,:)   = mean(Sig);
        medianVAL(k,:) = median(Sig);
        loc_STD(k,:)   = std(Sig,flagN);
        glb_STD(k)     = sqrt(sum(loc_STD(k,:).*loc_STD(k,:))/nbVAL);
        maxVAL(k)      = max(max(abs(Sig)));
        minVAL(k)      = min(min(abs(Sig)));
    end
    if maxVAL>0
        sdt_Q1 = 1-glb_STD./maxVAL;
    else
        sdt_Q1 = ones(size(glb_STD));
    end
    if (maxVAL-minVAL)>0
        sdt_Q2 = glb_STD./(maxVAL-minVAL);
    else
        sdt_Q2 = zeros(size(glb_STD));
    end
    if nbPART>1
        OUT(j,:) = {sdt_Q1,sdt_Q2,glb_STD,meanVAL,medianVAL,loc_STD};
    end
end
if nbPART<2
    varargout = {sdt_Q1,sdt_Q2,glb_STD,meanVAL,medianVAL,loc_STD};
else
    for k =1:6 , varargout{k} = OUT(:,k); end
end