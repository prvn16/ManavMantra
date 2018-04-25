function  [HC_Struct,varargout] = whuffencode(to_ENCODE,COUNT)
%WHUFFENCODE Huffman coding.
%    HC_Struct = WHUFFENCODE(TO_ENCODE) return a structure such that:
%     HC_Struct = 
%        HC_symb:   array of char containing the coded symbols.
%        HC_codes:  array containing the Huffman codes for each symbol.
%        HC_tabENC: sequence of encoded values.
%
%   [HC_Struct,ALL_CELL,HC_CELL,HC_STR,MEAN_LEN] = WHUFFENCODE(TO_ENCODE)
%
%    ALL_CELL is a cell array such that:
%      ALL_CELL{K,1} contains a symbol number.
%      ALL_CELL{K,2} contains the corresponding binary string code.
%      ALL_CELL{K,3} contains the corresponding count.
%
%    HC_CELL is a cell array such that HC_CELL{I} is a
%    binary string which represants the code of the Ith symbol
%    to be coded.
%
%    HC_STR is a string which contains all the Huffman codes.
%    The binary strings are separated by the symbol '2'.
%
%    MEAN_LEN gives the mean value of length of the binary
%    strings code. 
%
%    Examples:
%      TO_ENCODE = round(100*rand(1,15))
%      [HC_Struct,All_Cell,HC_Cell,HC_Str,Mean_Len] = whuffencode(TO_ENCODE)
%
%      TO_ENCODE = round(abs(25*randn(1,30)))
%      [HC_Struct,All_Cell,HC_Cell,HC_Str,Mean_Len] = whuffencode(TO_ENCODE)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  23-Jul-2001.
%   Last Revision: 04-Sep-2009.
%   Copyright 1995-2009 The MathWorks, Inc.


[HC_Struct.HC_symb,nul,idxCODE] = unique(to_ENCODE); %#ok<NASGU>
if nargin<2
    to_ENCODE = to_ENCODE - min(to_ENCODE) + 1;
    COUNT = histc(to_ENCODE,(1:max(to_ENCODE)));
end
if length(COUNT)==1
    HC_Cell = []; HC_Str = []; All_Cell = []; 
    HC_Struct.HC_tabENC = to_ENCODE;
    HC_Struct.HC_codes  = [];
    Mean_Len = 0;
    if nargout>2
        varargout = {All_Cell,HC_Cell,HC_Str,Mean_Len};
    end
    return
end
if nargout<3
    [HC_Cell,HC_Str] = built_huffcode(COUNT);
else
    [HC_Cell,HC_Str,All_Cell,Mean_Len] = built_huffcode(COUNT);
end
HCTab = double((HC_Str')')-48;

nb_SYMB  = length(HC_Cell);
len_SYMB = zeros(1,nb_SYMB);
for k = 1:nb_SYMB
    len_SYMB(k) = length(HC_Cell{k});
end
Tab_Len = len_SYMB(to_ENCODE);
len_SUM = sum(Tab_Len);

nb_CODED = length(to_ENCODE);
TabCODE = zeros(1,len_SUM);
idxBeg  = 1;
first = 1;
nb    = 150;
while first<=nb_CODED
    last = min([first + nb , nb_CODED]);
    len  = sum(Tab_Len(first:last));
    idxEnd = idxBeg + len-1;
    TabCODE(idxBeg:idxEnd) = cat(2,HC_Cell{to_ENCODE(first:last)});
    idxBeg = idxEnd + 1;
    first  = last  + 1;
end
TabCODE = abs(TabCODE')-48;
HC_Struct.HC_tabENC = TabCODE;
HC_Struct.HC_codes  = HCTab;
if nargout>1
    if nargout>2
        varargout = {All_Cell,HC_Cell,HC_Str,Mean_Len};
    else
        varargout = {HCTab};
    end
end
