function tab_IdxCLU = part2tab(Part)
%PART2TAB Partitions to table of clusters indices.
%   tab_IdxCLU = PART2TAB(Part)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 07-Feb-2006.
%   Last Revision: 27-Sep-2006.

if isnumeric(Part) , tab_IdxCLU = Part; return; end
nbPART = length(Part);
if iscell(Part);
    nbSIG  = length(Part{1}.IdxCLU);
    tab_IdxCLU = zeros(nbSIG,nbPART);
    for j=1:nbPART , tab_IdxCLU(:,j) = Part{j}.IdxCLU; end
elseif isstruct(Part)
    nbSIG  = length(Part(1).IdxCLU);
    tab_IdxCLU = zeros(nbSIG,nbPART);
    for j=1:nbPART , tab_IdxCLU(:,j) = Part(j).IdxCLU; end
elseif isobject(Part)
    nbSIG  = length(get(Part(1),'IdxCLU'));
    tab_IdxCLU = zeros(nbSIG,nbPART);
    for j=1:nbPART , tab_IdxCLU(:,j) = get(Part(j),'IdxCLU'); end
end
