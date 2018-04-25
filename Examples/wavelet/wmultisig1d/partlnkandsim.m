function [PARTS,LNK_SIM_STRUCT,tab_IdxCLU] = partlnkandsim(ARG,option)
%PARTLNKANDSIM Partitions Links and similarity indices.
%   A partition is a structure PART with four fields such that:
%       - NbCLU is the number of clusters.
%       - IdxCLU is a column vector such that IdxCLU(i) is the
%         number of cluster for ith data element.
%       - NbInCLU is a vector such that NbInCLU(j) is the number
%         of elements in jth cluster. 
%       - IdxInCLU is a cell array such that IdxInCLU{j} contains
%         the numbers of element in jth cluster.
%
%   [PARTS,SIM_and_LNK] = PARTLNKANDSIM(ARG) returns a structure 
%   array of partitions PARTS and a structure SIM_and_LNK which
%   contains the similarity indices and the links of partition.
%   
%   SIM_and_LNK is a structure such that:
%       - the field 'Links' is a (nbPART x nbPART x 4) array
%         SIM_and_LNK.Links(j,k,:) contains the four links
%         numbers (R,S,U,V) between the partitions Pj and Pk.
%         R, S, U, V are the number of pairs such that:  
%             R: simultaneously joined in Pj and Pk.
%             S: simultaneously separated in Pj and Pk.
%             U: joined in Pj and separated Pk.
%             V: separated in Pj and joined Pk.
%       - the fields 'Rand', 'Jaccard' , 'HubAra', 'Wallace',
%         'MacNemar' , 'ILN' , 'ICL' are (nbPART x nbPART) 
%         array containing the values of indices.
%         example: SIM_and_LNK.Rand(j,k) is the Rand similarity
%         index between the partitions Pj and Pk.
%
%   [.. ,tab_IdxCLU] = PARTLNKANDSIM(...) is an (nbSIG x nbPART)
%   array such that tab_IdxCLU(j,k) is the number of cluster  
%   for the jth signal in the partition Pk.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 31-Jan-2006.
%   Last Revision: 25-Sep-2006.

PARTS = tab2part(ARG);
if nargout>2 , tab_IdxCLU = part2tab(PARTS); end
nbPART = length(PARTS);
nbROW = nbPART;
if nargin>1 && isequal(option,'one') , nbROW = 1; end 

Z = zeros(nbROW,nbPART);
idx_Attrb = tplnksim;
idx_Names = idx_Attrb(:,1);
LNK_SIM_STRUCT = struct('Links',zeros(nbROW,nbPART,4));
nbIDX = length(idx_Names);
for k = 1:nbIDX
    LNK_SIM_STRUCT.(idx_Names{k}) = Z;
end
for j = 1:nbROW
    for k = 1:nbPART
        [TabIDX,Links] = tplnksim('all',PARTS(j),PARTS(k));
        LNK_SIM_STRUCT.Links(j,k,:)  = Links;
        for p = 1:nbIDX
            LNK_SIM_STRUCT.(idx_Names{p})(j,k) = TabIDX(p);
        end         
    end
end
