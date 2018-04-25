function A = sim2fi(IntArray, varargin)
%SIM2FI Simulink integer array to FI object
%   A = SIM2FI(IntArray, NumericType)
%   A = SIM2FI(IntArray, Signed, WordLength, FractionLength)
%   A = SIM2FI(IntArray, Signed, WordLength, Slope, Bias)
%   A = SIM2FI(IntArray, Signed, WordLength, SlopeAdjustmentFactor, FixedExponent, Bias)
%
%   Returns FI object A with the stored-integer data from integer array
%   IntArray and the given numeric type attributes.  
%
%   If a Fixed-Point Designer license is not available, then return double.
%
%   SIM2FI is the inverse of FI2SIM.
%
%   See also FI, FIMATH, FIPREF, NUMERICTYPE, QUANTIZER, SAVEFIPREF, FIXEDPOINT

%   Thomas A. Bryan, 5 April 2004
%   Copyright 2003-2016 The MathWorks, Inc.


[doRobust,numerictype_args] = robustRequest(varargin{:});

T = getNumericType(numerictype_args{:});

if checkoutFiLicense(T)

        A = embedded.fi.simfi(T,IntArray);

elseif doRobust
    warning(message('fixed:sim2fi:licenseResortToDoubles'));
    A = localConvert(IntArray,T);
else
    error(message('fixed:sim2fi:licenseFixPtTbxRequired'));
end

%---------------------------------------------------------------
function [doRobust,numerictype_args] = robustRequest(varargin)
%---------------------------------------------------------------
% If last argument is 'robust'
% then the caller is requesting that the results
% be 'robust' to the lack of a Fixed-Point Designer
% license.  A cruder algorithm using doubles will 
% be employed if necessary

% Default is robust = true
if (nargin > 1) && ischar( varargin{end} ) 
    % If the last argument is a string, then it's robust if the string is 'robust'.
    doRobust = strncmpi('robust',varargin{end},6);
    numerictype_args = varargin(1:end-1);
else
    doRobust = true;
    numerictype_args = varargin;
end

%---------------------------------------------------------------
function gotIt = checkoutFiLicense(T)
%---------------------------------------------------------------

needLicense = fixed.internal.isFxdNeeded(T);

if ~needLicense
    gotIt = true;
    return
end

gotIt = false;

if license('test','Fixed_Point_Toolbox')

    try
        gotIt = 0 ~= license('checkout','Fixed_Point_Toolbox');
    catch
    end
end

%---------------------------------------------------------------
function outdata = localConvert(indata,dt)
%---------------------------------------------------------------

loggedToSingleWord = true;

if  dt.isfixed
    
    if ( isa(indata,'int64' )  || ...
         isa(indata,'uint64')   )

        bitLimit = 64;
    else
        bitLimit = 32;
    end
    
    if dt.WordLength > bitLimit
    
        loggedToSingleWord = false;
    end
end

if loggedToSingleWord

    outdata = double(indata);
else
   
    outdata = localConvertMultiWord(indata, dt);
end

outdata = (outdata * dt.Slope ) + dt.Bias;


%---------------------------------------------------------------
function outdata = localConvertMultiWord(indata,dt)
%---------------------------------------------------------------

if isa(indata,'uint64')

    bitsPerChunk = 64;
else
    bitsPerChunk = 32;
end

dimsRaw = size(indata);

numRawElem = prod(dimsRaw);

chunksPerScalar = localGetChunksPerScalar(dt,bitsPerChunk,dimsRaw);

dimsFinal = [ dimsRaw(1)/chunksPerScalar dimsRaw(2:end) ];

numUnpackElem = numRawElem/chunksPerScalar;

tempSigEachCol = reshape(indata,[chunksPerScalar numUnpackElem]);

negateVec = [];

if dt.Signed
   
    [tempSigEachCol,bitsPerChunk,chunksPerScalar] = localSplit64to32(tempSigEachCol);

    [tempSigEachCol,negateVec] = localDoSignTwoComp(tempSigEachCol,dt,chunksPerScalar);

end

tempSigEachCol = double(tempSigEachCol);

scaleVec = 2.^( bitsPerChunk * (0:(chunksPerScalar-1)) );

tempSigEachCol = scaleVec * tempSigEachCol;

if ~isempty(negateVec)
    
    tempSigEachCol = negateVec .* tempSigEachCol;
end

outdata = reshape(tempSigEachCol,dimsFinal);



%--------------------------------------------------------------------
function chunksPerScalar = localGetChunksPerScalar(dt,bitsPerChunk,dimsRaw)
%--------------------------------------------------------------------
% determine the number of chunks per scalar element
% in the old design, 
%   chunks were always uint32
%   number of chunks was always 4 and 
% in the new design
%   chunks vary uint32 or uint64
%   number of is the minimum needed to contain specified wordlength
%
% There is a small chance data was created with old design
% save in a mat file, then loaded in a version based on new design

% formula assuming new design
%
chunksPerScalar = floor( (dt.WordLength - 1) / bitsPerChunk ) + 1;

% See if new formula should be overridden in favor of old design
%   in which case set number or chunks to 4
%
% If new formula calculates 4 chunks, then old or new is moot
%
% If bitsPerChunk is not 32, it can't be old design
% 
if ( chunksPerScalar ~= 4 ) && (bitsPerChunk == 32)
    %
    % Could be old format only if number of rows a multiple of 4
    %
    rowsDiv4 = dimsRaw(1)/4;
    %
    if rowsDiv4 == floor(rowsDiv4)
        %
        % Are rows a multiple of calculated chunksPerScalar
        % if not assume old format
        %
        rowsDivChunksPer = dimsRaw(1)/chunksPerScalar;
        %
        if rowsDivChunksPer ~= floor(rowsDivChunksPer)
            %
            chunksPerScalar = 4;
            %
        end
    end
end


%--------------------------------------------------------------------
function [tempSigEachCol,bitsPerChunk,chunksPerScalar] = localSplit64to32(tempSigEachCol)
%--------------------------------------------------------------------
% Most MATLAB math on 64 bit data types does NOT work
% so split data across twice as many 32 bit data types
% This is needed only for signed data 
%        
if isa(tempSigEachCol,'uint64')
    
    dimsRaw = size(tempSigEachCol);

    numRawElem = prod(dimsRaw);
    
    dims2x = dimsRaw;
    dims2x(1) = 2*dims2x(1);
    
    temp2x = repmat(uint32(0),dims2x);

    bitMaskLS32 = uint64(2^32-1);

    for i = 1:numRawElem
        
        curU64 = tempSigEachCol(i);
        
        msHalf = bitshift(curU64,-32);
        lsHalf = bitand(curU64,bitMaskLS32);
        
        temp2x(2*i-1) = uint32(lsHalf);
        temp2x(2*i  ) = uint32(msHalf);
    end
    
    tempSigEachCol = temp2x;
end

bitsPerChunk = 32;
chunksPerScalar = size(tempSigEachCol,1);


%--------------------------------------------------------------------
function [tempSigEachCol,negateVec] = localDoSignTwoComp(tempSigEachCol,dt,chunksPerScalar)
%--------------------------------------------------------------------

dims = size(tempSigEachCol);

numUnpackElem = prod( dims(2:end) );

negateVec = ones(1,numUnpackElem);
    
maxValue = uint32(2^32-1);

for iElem = 1:numUnpackElem
    
    curIsNeg = localIsNegative(tempSigEachCol,iElem, dt);
    
    if curIsNeg
        
        negateVec(iElem) = -1;
        
        carryValue = uint32(1);
        
        for iChunk = 1:chunksPerScalar

            curChunk = localSignExtendNegative(tempSigEachCol(iChunk,iElem),iChunk, dt);

            curChunk = bitcmp(curChunk);
            
            if carryValue
                
                if curChunk == maxValue
                    
                    curChunk = uint32(0);
                    carryValue = uint32(1);
                else
                    curChunk = curChunk + carryValue;
                    carryValue = uint32(0);
                end
            end
            
            tempSigEachCol(iChunk,iElem) = curChunk;
        end
    end
end



%--------------------------------------------------------------------
function curIsNeg = localIsNegative(tempSigEachCol,iElem, dt)
%--------------------------------------------------------------------
% This is only for signed multiword
% This should only be called after uint64 logging has been 
% split into uint32 logging

bitsPerChunk = 32;

indexSignChunk = floor((dt.WordLength-1)/bitsPerChunk) + 1;

expForSignBitInChunk = dt.WordLength - 1 - bitsPerChunk*(indexSignChunk-1);

bitMaskForSignBitInChunk = uint32( 2^expForSignBitInChunk );

curIsNeg = 0 ~= bitand( tempSigEachCol(indexSignChunk,iElem), bitMaskForSignBitInChunk);


%--------------------------------------------------------------------
function curChunk = localSignExtendNegative(curChunk,iChunk, dt)
%--------------------------------------------------------------------
% This is only for negative signed multiword
% This should only be called after uint64 logging has been 
% split into uint32 logging
%
% The new 8a memory foot print should not need this, BUT it does no harm either.
% But the old memory foot print does.
% Supporting this, eases transition, 
%  AND it supports the unusual situation 
% where the data was logged prior to 8a but used in 8a or later

bitsPerChunk = 32;

indexSignChunk = floor((dt.WordLength-1)/bitsPerChunk) + 1;

if iChunk == indexSignChunk
    
    expForSignBitInChunk = dt.WordLength - 1 - bitsPerChunk*(indexSignChunk-1);

    bitMaskForSignBitInChunk = uint32( (2^bitsPerChunk) - (2^expForSignBitInChunk) );

    curChunk = bitor( curChunk, bitMaskForSignBitInChunk);
    
elseif iChunk > indexSignChunk

    curChunk = uint32( (2^bitsPerChunk) - 1 );
end


%---------------------------------------------------------------
function T = getNumericType(varargin)
%---------------------------------------------------------------
%
% Determine the specified data type

narginchk(1,5);

switch nargin
  case 1
    % A = SIM2FI(IntArray, NumericType)
    T = varargin{1};
    if ~isnumerictype(T)
      error(message('fixed:sim2fi:invalidInputs'));
    end
  case 2
    error(message('fixed:sim2fi:invalidNumberOfInputs'));
  case 3
    % A = SIM2FI(IntArray, Signed, WordLength, FractionLength)
    T = numerictype;
    T.DataType        = 'fixed';
    T.Scaling         = 'BinaryPoint';
    T.Signed          = varargin{1};
    T.WordLength      = varargin{2};
    T.FractionLength  = varargin{3};
  case 4
    % A = SIM2FI(IntArray, Signed, WordLength, Slope, Bias)
    T = numerictype;
    T.DataType        = 'fixed';
    T.Scaling         = 'SlopeBias';
    T.Signed          = varargin{1};
    T.WordLength      = varargin{2};
    T.Slope           = varargin{3};
    T.Bias            = varargin{4};
  case 5
    % A = SIM2FI(IntArray, Signed, WordLength, SlopeAdjustmentFactor, FixedExponent, Bias)
    T = numerictype;
    T.DataType        = 'fixed';
    T.Scaling         = 'SlopeBias';
    T.Signed          = varargin{1};
    T.WordLength      = varargin{2};
    T.SlopeAdjustmentFactor = varargin{3};
    T.FixedExponent   = varargin{4};
    T.Bias            = varargin{5};
end

if T.WordLength > 128
  error(message('fixed:sim2fi:invalidSLFixPtWordLength'));
end
