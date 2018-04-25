function TabDECODED = whuffdecode(HCTab,TabCODE,nb_CODED)
%WHUFFDECODE Decode an Huffman encoded array.
%   TabDECODED = whuffdecode(HCTab,TabCODE,nb_CODED) or
%   TabDECODED = whuffdecode(HCTab,TabCODE)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  23-Jul-2001.
%   Last Revision: 05-Apr-2008.
%   Copyright 1995-2008 The MathWorks, Inc.

idxHC = find(HCTab==2);
if isempty(idxHC)
    TabDECODED = TabCODE;
    return
end
nb_SYMB = length(idxHC);
HC = cell(1,nb_SYMB);
okSYMB = zeros(1,nb_SYMB);
first = 1;
for k=1:nb_SYMB
    idxK =  idxHC(k);
    last = idxK-1;
    HC{k} = char(HCTab(first:last)+48); 
    HC{k} = HC{k}(:)';
    okSYMB(k) = ~isempty(HC{k});
    first = idxK+1;
end
idx_okSYMB = find(okSYMB==1);
HC_OK = HC(idx_okSYMB);
nb_okSYMB = length(idx_okSYMB);
TH_DEC = char(TabCODE+48)';
nb_CHAR = length(TH_DEC); 
if nargin>2
    TabDECODED = zeros(1,nb_CODED);
else
    TabDECODED = zeros(1,nb_CHAR);
end

nbInter = 0;
ok_idx = cell(nb_okSYMB,5);
for k = 1:nb_okSYMB
    strSYMB = HC_OK{k};
    first = strfind(TH_DEC,strSYMB);
    nbInter = nbInter + length(first);
    lenSYMB = length(strSYMB);
    last  = first + lenSYMB-1;
    ok_idx{k,1} = first';
    ok_idx{k,2} = last';
    ok_idx{k,3} = idx_okSYMB(k)*ones(length(first),1);
end
infoInter = zeros(nbInter,4);
infoInter(:,1) = cat(1,ok_idx{:,1});
infoInter(:,2) = cat(1,ok_idx{:,2});
infoInter(:,3) = cat(1,ok_idx{:,3});
[dummy,sorted_IDX] = sort(infoInter(:,1)); %#ok<ASGLU>
infoInter = infoInter(sorted_IDX,:);
infoInter(:,4) = infoInter(:,1) - (1:nbInter)'; 
idxE  = 0;
first = 1;
while first<=nbInter
    idxE = idxE + 1;
    if infoInter(first,4)==0
        idxFirst = first;
    else
        idxFirst = find(infoInter(:,1)==first);
    end
    TabDECODED(idxE) = infoInter(idxFirst,3);
    first = infoInter(idxFirst,2) + 1;
end
if (nargin>2 && idxE<nb_CODED) || (nargin<3 && infoInter(end,4)>0)
    idxE = idxE + 1;
    TabDECODED(idxE) = infoInter(end,3);    
end
if nargin<3
    TabDECODED(idxE+1:end) = [];
end

%-------------------------------------------------------------------------
% Other algorithm (longer)
%-------------------------------------------------------------------------
% % TabDECODED_SAV = TabDECODED;
% continu = true;
% first = 1;
% idxE  = 0;
% while continu
%     for k=1:nb_okSYMB
%         strSYMB = HC_OK{k};
%         valSYMB = idx_okSYMB(k);
%         lenSYMB = length(strSYMB);
%         last = first + lenSYMB - 1;
%         isHere = (last<=nb_CHAR) && isequal(strSYMB,TH_DEC(first:last));
%         if isHere
%             idxE = idxE + 1;
%             TabDECODED(idxE) = valSYMB;
%             break
%         end
%     end
%     first = last + 1;
%     continu = (first <= nb_CHAR);
% end    
% if nargin<3
%     TabDECODED(idxE+1:end) = [];
% end
%-------------------------------------------------------------------------
