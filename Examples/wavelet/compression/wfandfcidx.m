function varargout = wfandfcidx(option,S)
%WFANDFCIDX TabFATHER and TabFirstCHILD for 
%  [TabFATHER,TabFirstCHILD,Band,row_AND_col_IDX,...
%            idxCFSlevMAX,idxCFSlevMIN] = wfandfcidx(option,S)
%   WFANDFCIDX returns the quadtree structure for compression
%   methods
%   WFANDFCIDX is used by Progressive Coefficients Significance 
%   Methods functions. 

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 07-Sep-2007.
%   Last Revision: 05-Apr-2008.
%   Copyright 1995-2008 The MathWorks, Inc.

level = size(S,1)-2;
sizes = kron(S(1,1:2),2.^(0:level)');
idxBegs = flipud([[1,1];sizes(1:end-1,:)+1]);
rMAX = S(end,1);
cMAX = S(end,2);
nbBAND = 3*level+1;
cfsBAND = zeros(nbBAND,4);
idxROW = 3*level+2;
for k = 1:level
    j = level+2-k;
    idxB = idxBegs(k,:);
    idxE = idxB + S(j,1:2)- 1;
    idxROW = idxROW-1;
    cfsBAND(idxROW,:) = [idxB(1) idxE(1) , idxB(2)  idxE(2)];   % D
    idxROW = idxROW-1;
    cfsBAND(idxROW,:) = [idxB(1) idxE(1) , 1        S(j,2)];    % V      
    idxROW = idxROW-1;
    cfsBAND(idxROW,:) = [1 S(j,1)        , idxB(2) idxE(2)];    % H
end
idxROW = idxROW-1;
cfsBAND(idxROW,:) = [1 S(1,1) , 1 S(1,2)];

if isequal(option,'cfsBAND')
    varargout = {cfsBAND};
    return;
end

Band = cell(1,nbBAND);
AB = 1;
HB = 2:3:nbBAND;
VB = 3:3:nbBAND;
DB = 4:3:nbBAND;

if isequal(option,'scanidx') || isequal(option,'scan_0')
    numOrder = 'scan_0';
else
    numOrder = 'scan_1';
end
    
for j=1:nbBAND
    rows = cfsBAND(j,1):cfsBAND(j,2);    nbr = length(rows);
    cols = (cfsBAND(j,3):cfsBAND(j,4))'; nbc = length(cols);
    rows = rows(ones(1,nbc),:);
    cols = cols(:,ones(1,nbr));
    TMP  = rows + rMAX*(cols-1);
    
    switch numOrder
        case 'scan_0'
            Band{j} = TMP(:);
            
        case 'scan_1'
            if any(AB==j)
                Band{j} = TMP(:);
            elseif any(HB==j)
                Ord = scanorder('V',size(TMP));
                Band{j} = TMP(Ord);
            elseif any(VB==j)
                Ord = scanorder('H',size(TMP));
                Band{j} = TMP(Ord);
            elseif any(DB==j)
                Ord = scanorder('D',size(TMP));
                Band{j} = TMP(Ord);
            end
    end
end

skipFLAG = isequal(option,'band') || isequal(option,'scanidx') || ...
    isequal(option,'scan_0') || isequal(option,'scan_1');

if ~skipFLAG
    idxCFSlevMAX = cat(2,Band{1:4});
    idxCFSlevMIN = cat(2,Band{end-2:end});

    nbNODES = rMAX*cMAX;
    node_IDX = zeros(rMAX,cMAX);
    node_IDX(:) = (1:nbNODES);
    row_IDX = rem(node_IDX-1,rMAX);
    col_IDX = (node_IDX-1-row_IDX)/rMAX;
    idx_PAREN = rMAX*floor(col_IDX/2) + floor(row_IDX/2) + 1;
    idx_PAREN(idxCFSlevMAX(:)) = NaN;           % No father

    % Compute Quadtree MAP.
    TabFATHER = idx_PAREN(:);                   % Node father index

    % Search children
    TabFirstCHILD = 2*node_IDX(:)-1;            % First child index
    TabFirstCHILD([1;idxCFSlevMIN(:)]) = NaN;   % No child
end

switch option
    case 'quadtree'
        row_AND_col_IDX = [row_IDX(:) , col_IDX(:)] +1;
        varargout = {TabFATHER,TabFirstCHILD,idxCFSlevMAX,row_AND_col_IDX}; 
        
    case 'qtFC'     % Quadtree: Father and Children
        varargout = {TabFATHER,TabFirstCHILD};
        
    case 'band'
        scan_IDX = cat(1,Band{:});
        varargout = {Band,scan_IDX};
        
    case {'scanidx','scan_0','scan_1'}
        varargout = {cat(1,Band{:}),Band};
                
end
%--------------------------------------------------------------------------
function [S,M] = scanorder(option,nbR,nbC)

if nargin<3
    nbC = nbR(2); nbR = nbR(1);
end
switch option
    case 'H'
        M = reshape(1:nbR*nbC,nbR,nbC);
        S = M;
        S(2:2:end,:) = fliplr(S(2:2:end,:));
        S = S';
        
    case 'V'
        M = reshape(1:nbR*nbC,nbR,nbC);
        S = M;
        S(:,2:2:end) = flipud(S(:,2:2:end));
        
    case 'D'
        rows = (1:nbR)'; rows = rows(:,ones(1,nbC));
        cols = (1:nbC);  cols = cols(ones(1,nbR),:);
        r_plus_c = rows+cols;
        [II,S] = sort(r_plus_c(:));
        for k = 3:2:(nbR+nbC)
            iBeg = find(II==k,1,'first');
            iEnd = find(II==k,1,'last');
            S(iBeg:iEnd) = S(iEnd:-1:iBeg);
        end
        if nargout>1 , M = reshape(1:nbR*nbC,nbR,nbC); end
end
S = S(:);
%--------------------------------------------------------------------------

