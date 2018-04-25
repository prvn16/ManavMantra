function [Part,IdxCLU,effectif,percent,scores] = ...
    renumpart(optRENUM,varargin)
%RENUMPART Renumber Partitions.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 20-Oct-2005.
%   Last Revision: 28-Apr-2012.
%   Copyright 1995-2012 The MathWorks, Inc.

% Check input arguments.
nbIN = length(varargin);
switch nbIN
    case 1
        if isnumeric(varargin{1})
            Part = tab2part(varargin{1});
        elseif iscell(varargin{1})
            nbPART = length(varargin{1});
            nbSIG  = size(varargin{1}{1}.IdxCLU,1);
            TMP = zeros(nbSIG,nbPART);
            for k = 1:nbPART , TMP(:,k) = varargin{1}{k}.IdxCLU; end
            Part = tab2part(TMP);
        elseif isstruct(varargin{1})
            Part = varargin{1};
        end
        
    otherwise
        IdxCLU = cat(2,varargin{:});
        Part = tab2part(IdxCLU);
end
nbPART = length(Part);

switch nbPART
    case {1,2}
        [Part,~,effectif,percent,scores] = rentwopart(optRENUM,Part);
        
    otherwise
        if ~isequal(optRENUM,'none') , optRENUM = 'col_mat'; end
        effectif = cell(1,nbPART);
        percent  = zeros(1,nbPART);
        scores   = cell(1,nbPART);
        for j=1:nbPART
            [Part([1,j]),~,effectif{j},percent(j),scores{j}] = ...
                rentwopart(optRENUM,Part([1,j]));
        end
end
IdxCLU = part2tab(Part);

%==========================================================================
function [Part,IdxCLU,effectif,percent,scores] = rentwopart(optRENUM,Part)
%RENTWOPART Renumber two partitions.

nbPART = length(Part);
if nbPART==1 || isequal(Part(1),Part(2))
    effectif = Part(1).NbInCLU;
    IdxCLU = Part(1).IdxCLU;
    if ~isequal(optRENUM,'none')
        [effectif,idxSORT] = sort(effectif,'descend');
        [~,idxSORT] = sort(idxSORT);
        IdxCLU = idxSORT(IdxCLU);
        Part(1) = tab2part(IdxCLU);
    end
    if nbPART==2 
        IdxCLU = [IdxCLU , IdxCLU];
        Part(2) = Part(1); 
    end
    effectif = diag(effectif);
    [percent,scores] = getSCORES(effectif);    
    return;
end

% Check input arguments.
IdxCLU = [Part(1).IdxCLU,Part(2).IdxCLU];
LinkPART = unique(IdxCLU,'rows');
nbLinkPART = size(LinkPART,1);
maxCLU = max(LinkPART);
nbR = maxCLU(2);
nbC = maxCLU(1);
effectif = zeros(nbR,nbC);
idx_1 = Part(1).IdxInCLU;
idx_2 = Part(2).IdxInCLU;
for k=1:nbLinkPART
    iC = LinkPART(k,1);
    iR = LinkPART(k,2);
    inter = intersect(idx_1{iC},idx_2{iR});
    effectif(iR,iC) = length(inter);
end
if isequal(optRENUM,'none')
    [percent,scores] = getSCORES(effectif);
    return; 
end

[nbSTEP,idxDIMmax] = max([nbR,nbC]);
permRC = [1:nbSTEP;1:nbSTEP];
switch optRENUM
    case {'row_mat','col_mat','row','col'}
        wEFF = effectif;
        if isequal(optRENUM(1:3),'row') , Pidx = 2; else Pidx = 1; end
        [~,idx] = sort(sum(wEFF,Pidx),'descend');
        nbREN = length(idx);
        permRC(Pidx,1:nbREN) = idx(:)';
        permRC(:,nbREN+1:end) = [];
        idxPLUS = 0;
        switch optRENUM
            case 'row'
                effectif = effectif(idx,:);
                
            case 'col'
                effectif = effectif(:,idx);
                
            case 'row_mat'
                effectif = effectif(idx,:);
                permPLUS = (1:nbR);
                for k = 1:nbR
                    [~,new] = max(effectif(k,:));
                    if new>k
                        effectif(:,[k,new]) = effectif(:,[new,k]);
                        idxPLUS = idxPLUS+1; permPLUS(k) = new;
                    end
                end
                
            case 'col_mat'
                effectif = effectif(:,idx);
                permPLUS = (1:nbC);
                for k = 1:nbC
                    [~,new] = max(effectif(:,k));
                    if new>k
                        effectif([k,new],:) = effectif([new,k],:);
                        idxPLUS = idxPLUS+1; permPLUS(k) = new;
                    end
                end
        end        
        IdxCLU = Part(Pidx).IdxCLU;
        for k = 1:size(permRC,2)
            num = permRC(Pidx,k);
            if num~=k
                I1 = find(Part(Pidx).IdxCLU==num);
                IdxCLU(I1) = k;
                Part(Pidx).IdxInCLU{k} = I1;
                Part(Pidx).NbInCLU(k)  = length(I1);
            end
        end
        Part(Pidx).IdxCLU = IdxCLU;
        if idxPLUS>0
            Pidx = 3-Pidx;
            IdxCLU = Part(Pidx).IdxCLU;
            for k = 1:length(permPLUS)
                num = permPLUS(k);
                if num~=k
                    I1 = find(IdxCLU==num);
                    I2 = find(IdxCLU==k);
                    IdxCLU(I1) = k;
                    IdxCLU(I2) = num;
                    Part(Pidx).IdxInCLU{k} = I1;
                    Part(Pidx).NbInCLU(k)  = length(I1);
                    Part(Pidx).IdxInCLU{num} = I2;
                    Part(Pidx).NbInCLU(num)  = length(I2);
                end
            end
            Part(Pidx).IdxCLU = IdxCLU;
        end
        
    case 'mat'
        for k=1:nbSTEP-1
            R_first = min([k nbR]);
            C_first = min([k nbC]);
            wEFF = effectif(R_first:end,C_first:end);
            nbREFF = size(wEFF,1);
            [~,idx] = max(wEFF(:));
            idxRMAX = rem(idx,nbREFF);
            idxCMAX = fix(idx/nbREFF);
            if idxRMAX==0 , idxRMAX = nbREFF; else idxCMAX = idxCMAX+1; end
            if idxRMAX~=1
                new = idxRMAX+k-1;
                effectif([k,new],:) = effectif([new,k],:);
                permRC(2,k) = new;
            end
            if idxCMAX~=1
                new = idxCMAX+k-1;
                effectif(:,[k,new]) = effectif(:,[new,k]);
                permRC(1,k) = new;
            end
        end
        for j=1:nbPART
            IdxCLU = Part(j).IdxCLU;
            for k = 1:nbSTEP
                num = permRC(j,k);
                if num~=k
                    I1 = find(IdxCLU==num);
                    I2 = find(IdxCLU==k);
                    IdxCLU(I1) = k;
                    IdxCLU(I2) = num;
                    Part(j).IdxInCLU{k} = I1;
                    Part(j).NbInCLU(k)  = length(I1);
                    Part(j).IdxInCLU{num} = I2;
                    Part(j).NbInCLU(num)  = length(I2);
                end
            end
            Part(j).IdxCLU = IdxCLU;
        end
        
        if nbR~=nbC
            idxPLUS = 0;
            if idxDIMmax==1
                Pidx = 2;
                permPLUS = [];
                for k = nbC+1:nbR
                    wEFF = sum(effectif(k:end,:),2);
                    [~,new] = max(wEFF);
                    new = new+k-1;
                    if new>k
                        effectif([k,new],:) = effectif([new,k],:);
                        idxPLUS = idxPLUS+1; 
                        permPLUS(idxPLUS,:) = [k,new]; %#ok<*AGROW>
                    end
                end
            else
                Pidx = 1;
                permPLUS = [];
                for k = nbR+1:nbC
                    wEFF = sum(effectif(:,k:end),1);
                    [~,new] = max(wEFF);
                    new = new+k-1;
                    if new>k
                        effectif(:,[k,new]) = effectif(:,[new,k]);
                        idxPLUS = idxPLUS+1; 
                        permPLUS(idxPLUS,:) = [k,new];
                    end
                end
            end
            
            if idxPLUS>0
                IdxCLU = Part(Pidx).IdxCLU;
                for k = 1:size(permPLUS,1)
                    old = permPLUS(k,1);
                    new = permPLUS(k,2);
                    I1 = find(IdxCLU==new);
                    I2 = find(IdxCLU==old);
                    IdxCLU(I1) = old;
                    IdxCLU(I2) = new;
                    Part(Pidx).IdxInCLU{old} = I1;
                    Part(Pidx).NbInCLU(old)  = length(I1);
                    Part(Pidx).IdxInCLU{new} = I2;
                    Part(Pidx).NbInCLU(new)  = length(I2);
                end
                Part(Pidx).IdxCLU = IdxCLU;
            end
        end
end
[percent,scores] = getSCORES(effectif);
IdxCLU = [Part(1).IdxCLU,Part(2).IdxCLU];

%--------------------------------------------------------------------------
function [percent,scores] = getSCORES(effectif)

sumTOT    = sum(effectif(:));
scoreLINK = 100*effectif/sumTOT;
scoreCOL  = sum(scoreLINK,1);
scoreROW  = sum(scoreLINK,2);
scoreDIAG = diag(scoreLINK); 
scoreDIAG = scoreDIAG(:)';
scoreTOT  = sum(scoreDIAG);
lastIDX   = min(size(effectif));
perCOL    = 100*scoreDIAG./scoreCOL(1:lastIDX);
perROW    = 100*scoreDIAG./scoreROW(1:lastIDX)';
percent   = scoreTOT;
scores    = {scoreTOT,scoreDIAG,perCOL,perROW};
%--------------------------------------------------------------------------

