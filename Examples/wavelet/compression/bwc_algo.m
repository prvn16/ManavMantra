function varargout = bwc_algo(option,varargin)
%BWC_ALGO Burrows-Wheeler Compression Algorithm.

%   M. Misiti, Y. Apr, G. Oppenheim, J.M. Poggi 22-Apr-2004.
%   Last Revision: 06-May-2009.
%   Copyright 1995-2009 The MathWorks, Inc.

switch lower(option(1))
    case 'e'
        bwt_OPTION = varargin{1};
        mtf_OPTION = varargin{2};
        alphabet   = varargin{3};
        BitStream  = varargin{4};
        if isequal(bwt_OPTION,'on')
            [BitStream,bwt_IDX] = bwtencode(BitStream);
        else
            bwt_IDX = 0;
        end
        switch mtf_OPTION
            case 'on'          , mtf_VAL =  2;
            case 'idx'         , mtf_VAL = -2;                
            case 'bin'         , mtf_VAL = -1;
            case {-2,-1,0,1,2} , mtf_VAL = mtf_OPTION;
            otherwise          , mtf_VAL = -100;
        end
        if mtf_VAL>-10
            BitStream = move_to_front('e',mtf_OPTION,alphabet,BitStream);
        end
        HC_Struct = whuffencode(BitStream);
        varargout = {bwt_IDX,mtf_OPTION,HC_Struct};
        
    case 'd'
        bwt_IDX  = varargin{1};
        mtf_VAL  = varargin{2};
        alphabet = varargin{3};
        LenOfBitStream = varargin{4};
        HCTab = varargin{5};
        TabCODE = varargin{6};
        TabCODE = whuffdecode(HCTab,TabCODE,LenOfBitStream);
        if mtf_VAL>-10
            BitStream = move_to_front('d',mtf_VAL,alphabet,TabCODE);
        end
        if bwt_IDX>0
            BitStream = bwtdecode(BitStream,bwt_IDX);
        end
        varargout{1} = BitStream;
end
%--------------------------------------------------------------------------
function [OUT,idx] = bwtencode(IN)
%BWTENCODE

len = length(IN);
mat = zeros(len,len);
for k = 1:len
    mat(k,:) = IN([k:len,1:k-1]);
end
w = mat(1,:);
mat = sortrows(mat);
ok = false;
k  = 0;
while ~ok
    k = k+1;
    ok = sum(mat(k,:)==w)==len;
    if ok , break; end
end
OUT = mat(:,len)';
idx = k;
%--------------------------------------------------------------------------
function OUT = bwtdecode(Last,idx)
%BWTDECODE

len   = length(Last);
First = sort(Last);
T     = zeros(1,len);
oneVAL = unique(Last);
for k = 1:length(oneVAL)
    ch = oneVAL(k);
    idx_First = find(First==ch);
    idx_Last  = find(Last==ch);
    for j = 1:length(idx_Last)
        T(idx_Last(j)) = idx_First(j);
    end
end

OUT = zeros(1,len);
for k = 0:len-1
    OUT(len-k) = Last(idx);
    idx = T(idx);
end
%--------------------------------------------------------------------------
function OUT = move_to_front(option,type,alpha,ENC_or_DEC)
%MOVE_TO_FRONT Move to front algorithm.
%   OUT = MOVE_TO_FRONT('e',TYPE,ALPHABET,TO_ENCODE) or
%   MOVE_TO_FRONT('d',TYPE,ALPHABET,TO_DECODE)

option = lower(option(1));
OUT = zeros(size(ENC_or_DEC));
switch option
    case 'e'
        switch type
            case {'idx',-2}
                for k=1:length(alpha)
                    OUT(ENC_or_DEC==alpha(k)) = k;
                end

            case {'bin',-1}
                OUT(1) = ENC_or_DEC(1);
                OUT(2:end) = diff(ENC_or_DEC)~=0;

            case 0
                for k = 1:length(ENC_or_DEC)
                    idx = find(ENC_or_DEC(k)==alpha);
                    OUT(k) = idx;
                    if idx>1
                        alpha = alpha([idx,1:idx-1,idx+1:end]);
                    end
                end

            case 1
                for k = 1:length(ENC_or_DEC)
                    idx = find(ENC_or_DEC(k)==alpha);
                    OUT(k) = idx;
                    if idx>2
                        alpha = alpha([1,idx,2:idx-1,idx+1:end]);
                    elseif idx==2
                        alpha = alpha([2,1,3:end]);
                    end
                end

            case 2
                %----------------------------------------------------------
                % % ENC_or_DEC = double(ENC_or_DEC);
                % % alpha = double(alpha);
                % for k = 1:length(ENC_or_DEC)
                %     idx = find(ENC_or_DEC(k)==alpha);
                %     OUT(k) = idx;
                %     if idx>2
                %         alpha = alpha([1,idx,2:idx-1,idx+1:end]);
                %     elseif idx==2
                %         if OUT(k-1)>1
                %             alpha = alpha([2,1,3:end]);
                %         end
                %     end
                % end
                %----------------------------------------------------------
                len_alpha = length(alpha);
                alpha_idx = (1:len_alpha);
                ENC_or_DEC_BIS = ENC_or_DEC;
                for k = 1:len_alpha
                    ENC_or_DEC_BIS((ENC_or_DEC==alpha(k))) = alpha_idx(k);
                end
                for k = 1:length(ENC_or_DEC_BIS)
                    numSYMB = ENC_or_DEC_BIS(k);
                    idx     = alpha_idx(numSYMB);
                    OUT(k)  = idx;
                    if idx>2
                        idx_To_Change = find(1<alpha_idx & alpha_idx<idx);
                        alpha_idx(numSYMB) = 2;
                        alpha_idx(idx_To_Change) = alpha_idx(idx_To_Change)+1;
                    elseif idx==2 && k>1
                        if OUT(k-1)>1
                            alpha_idx(alpha_idx==1) = 2;
                            alpha_idx(numSYMB) = 1;
                        end
                    end
                end
        end

    case 'd'
        switch type
            case {'idx',-2}
                for k=1:length(alpha)
                    OUT(ENC_or_DEC==k) = alpha(k);
                end

            case {'bin',-1}
                OUT = rem(cumsum(ENC_or_DEC),2);

            case 0 ,
                for k = 1:length(ENC_or_DEC)
                    idx = ENC_or_DEC(k);
                    OUT(k) = alpha(idx);
                    if idx>1
                        alpha = alpha([idx,1:idx-1,idx+1:end]);
                    end
                end
                if ischar(alpha) , OUT = char(OUT); end

            case 1 ,
                for k = 1:length(ENC_or_DEC)
                    idx = ENC_or_DEC(k);
                    OUT(k) = alpha(idx);
                    if idx>2
                        alpha = alpha([1,idx,2:idx-1,idx+1:end]);
                    elseif idx==2
                        alpha = alpha([2,1,3:end]);
                    end
                end
                if ischar(alpha) , OUT = char(OUT); end

            case 2 ,
                for k = 1:length(ENC_or_DEC)
                    idx = ENC_or_DEC(k);
                    if idx>0
                        OUT(k) = alpha(idx);  %%%%%  A VERIFIER
                    end
                    if idx>2
                        alpha = alpha([1,idx,2:idx-1,idx+1:end]);
                    elseif idx==2 && k>1
                        if ENC_or_DEC(k-1)>1
                            alpha = alpha([2,1,3:end]);
                        end
                    end
                end
                if ischar(alpha) , OUT = char(OUT); end
        end
end
%--------------------------------------------------------------------------


