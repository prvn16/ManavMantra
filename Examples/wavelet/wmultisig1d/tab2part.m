function Part = tab2part(tab_IdxCLU)
%TAB2PART Table of clusters indices to Partition structures.
%	Part = TAB2PART(tab_IdxCLU)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 07-Feb-2006.
%   Last Revision: 02-Oct-2007.

if isstruct(tab_IdxCLU) , Part = tab_IdxCLU; return; end
if isa(tab_IdxCLU,'wpartobj')
    Part = struct(tab_IdxCLU).clu_INFO; 
    return;
end
if iscell(tab_IdxCLU)
    nbPART = length(tab_IdxCLU);
else
    if min(size(tab_IdxCLU))>1
        nbPART = size(tab_IdxCLU,2);
    else
        tab_IdxCLU = tab_IdxCLU(:);
        nbPART = 1;
    end
end

Part(1:nbPART) = struct('NbCLU',[],'IdxCLU',[],'NbInCLU',[],'IdxInCLU',[]);
if iscell(tab_IdxCLU)
    for j=1:nbPART , Part(j) = tab_IdxCLU{j}; end
    return;
end

for j=1:nbPART
    NbCLU    = max(tab_IdxCLU(:,j));
    IdxInCLU = cell(1,NbCLU);
    NbInCLU  = zeros(1,NbCLU);
    for k=1:NbCLU
        IdxInCLU{k} = find(tab_IdxCLU(:,j)==k);
        NbInCLU(k)  = length(IdxInCLU{k});
    end
    Part(j).NbCLU    = NbCLU;
    Part(j).IdxCLU   = tab_IdxCLU(:,j);
    Part(j).IdxInCLU = IdxInCLU;
    Part(j).NbInCLU  = NbInCLU;
end
