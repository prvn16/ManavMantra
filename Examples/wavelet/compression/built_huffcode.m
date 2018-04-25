function  [HC_Cell,HC_Str,All_Cell,Mean_Len] = built_huffcode(COUNT)
%BUILT_HUFFCODE Huffman coding.
%    [HC_CELL,HC_STR,ALL_CELL,MEAN_LEN] = BUILT_HUFFCODE(COUNT)
%
%    COUNT is an array such that COUNT(I) gives the count for 
%    the Ith symbol to be coded.
%
%    HC_CELL is a cell array such that HC_CELL{I} is a
%    binary string which represants the code of the Ith symbol
%    to be coded.
%
%    HC_STR is a string which contains all the Huffman codes.
%    The binary strings are separated by the symbol '2'.
%
%    ALL_CELL is a cell array such that:
%      ALL_CELL{K,1} contains a symbol number.
%      ALL_CELL{K,2} contains the corresponding binary string code.
%      ALL_CELL{K,3} contains the corresponding count.
%
%    MEAN_LEN gives the mean value of length of the binary
%    strings code. 
%
%    Examples:
%      COUNT = round(100*rand(1,15))
%      [HC_Cell,HC_Str,All_Cell,Mean_Len] = built_huffcode(COUNT)
%
%      COUNT = round(abs(25*randn(1,30)))
%      [HC_Cell,HC_Str,All_Cell,Mean_Len] = built_huffcode(COUNT)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 23-Jul-2001.
%   Last Revision: 05-Apr-2008.
%   Copyright 1995-2008 The MathWorks, Inc.

nb_SYMB = length(COUNT);
B = [ (1:nb_SYMB)', COUNT(:)];
B(COUNT==0,:) = [];
NB_True_CODE = size(B,1);
All_Cell = num2cell(B);
while size(All_Cell,1)>1
    [dum,idx] = sort(cat(1,All_Cell{:,2})); %#ok<ASGLU>
    All_Cell = All_Cell(idx,:);
    All_Cell{2,1} = {All_Cell{1,1} , All_Cell{2,1}};
    All_Cell{2,2} = All_Cell{1,2} + All_Cell{2,2};
    All_Cell(1,:) = [];
end
All_Cell{1,2} = '';
IH = 1;
while IH<NB_True_CODE
    if iscell(All_Cell{IH,1})
        C = All_Cell{IH,2};
        All_Cell(end+1,:) = {All_Cell{IH,1}{1} , [C,'1']}; %#ok<AGROW>
        All_Cell(end+1,:) = {All_Cell{IH,1}{2} , [C,'0']}; %#ok<AGROW>
        All_Cell(IH,:) = [];
    else
        IH = IH+1;
    end
end
[dum,idx] = sortrows(cat(1,All_Cell{:,1}),1); %#ok<ASGLU>
All_Cell_SORTED_C1 = All_Cell(idx,:);
%---------------------------------------------
% Code sorted by length
% All_Cell_SORTED_C2 = sortrows(All_Cell,2);
%---------------------------------------------
I = cat(1,All_Cell_SORTED_C1{:,1});
HC_Cell = cell(nb_SYMB,1);
HC_Cell(I) = All_Cell_SORTED_C1(:,2);
HC_Str = HC_Cell;
for k = 1:length(HC_Str) , HC_Str{k} = [HC_Str{k} , '2']; end
HC_Str = cat(2,HC_Str{:});

if nargout>2
    idx = cat(2,All_Cell{:,1});
    B =  num2cell(COUNT(idx))';
    All_Cell(:,3) = B;
    if nargout>3
        N = 0;
        S = 0;
        for k = 1:size(All_Cell,1)
            N = N + All_Cell{k,3};
            S = S + length(All_Cell{k,2})*All_Cell{k,3};
        end
        Mean_Len = S/N;
    end
end
