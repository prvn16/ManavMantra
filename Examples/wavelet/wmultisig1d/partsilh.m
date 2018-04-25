function [silh_VAL,silh_PART,tab_SILH_SIG] = partsilh(signals,ARG)
%PARTSILH Silhouettes indices for partitions.
%   For a matrix of signals SIG which are stored rowwise,
%   and a matrix or a structures array of partitions,
%   SH_VAL = PARTSILH(SIG,PARTS) returns a cell array 
%   SH_VAL. Each cell corresponds to a partition and 
%   contains an array (4 x NbCluster) such that, for each
%   cluster k:
%     	SH_VAL{j}(1,k) is the mean of silhouette indices
%     	SH_VAL{j}(2,k) is the min of silhouette indices
%     	SH_VAL{j}(3,k) is the max of silhouette indices
%     	SH_VAL{j}(4,k) is the std of silhouette indices
%
%   In addition, [SH_VAL,SH_PART] = PARTSILH(SIG,PARTS)
%   returns the array silh_PART which, for each partition,
%   contains the mean value of silhouette indices.
%
%   In addition, [SH_VAL,SH_PART,tab_SH_SIG] = PARTSILH(SIG,PARTS)
%   returns the cell array tab_SH_SIG which, for each partition,
%   contains the value of silhouette indices for each signal. 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 08-Feb-2006.
%   Last Revision: 25-Feb-2006.

[nbSIG,nbVAL] = size(signals);
tab_IdxCLU = part2tab(ARG);
Part       = tab2part(ARG);
nbPART     = length(Part);
silh_VAL   = cell(1,nbPART);
silh_PART  = zeros(1,nbPART);

if nargout>2
    tab_SILH_SIG = cell(1,nbPART); 
end
for j = 1:nbPART
   SILH_SIG = silhouette(signals,tab_IdxCLU(:,j));
   NbCLU = Part(j).NbCLU;
   silh_VAL{j} = zeros(4,NbCLU);
   for k = 1:NbCLU
       IdxInCLU = Part(j).IdxInCLU{k};
       silh_VAL{j}(1,k) = mean(SILH_SIG(IdxInCLU));
       silh_VAL{j}(2,k) = min(SILH_SIG(IdxInCLU));
       silh_VAL{j}(3,k) = max(SILH_SIG(IdxInCLU));
       silh_VAL{j}(4,k) = std(SILH_SIG(IdxInCLU));
   end
   silh_PART(j) = sum(silh_VAL{j}(1,:).*Part(j).NbInCLU)/nbSIG;
   if nargout>2 , tab_SILH_SIG{j} = SILH_SIG; end
end
