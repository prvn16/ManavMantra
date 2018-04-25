function this = numerictype(varargin)
%NUMERICTYPE Object which encapsulates numeric type information
%   Syntax:
%     T = numerictype
%     T = numerictype(s)
%     T = numerictype(s, w)
%     T = numerictype(s, w, f)
%     T = numerictype(s, w, slope, bias)
%     T = numerictype(s, w, slopeadjustmentfactor, fixedexponent, bias)
%     T = numerictype('boolean')
%     T = numerictype('double')
%     T = numerictype('single')
%     T = numerictype(property1, value1, ...)
%     T = numerictype(s, w, ..., property1, value1, ...)
%     T = numerictype(T1, property1, value1, ...)
%
%   Description:
%     T = numerictype creates a numerictype object.
%
%     T = numerictype(s) creates a numerictype object with Fixed-point:
%     unspecified scaling, Signed property value s, and 16-bit word length. 
%     s can be 
%        0  or false for Signedness = 'Unsigned',
%        1  or true  for Signedness = 'Signed',
%        []          for Signedness = 'Auto'.
%
%     T = numerictype(s,w) creates a numerictype object with Fixed-point:
%     unspecified scaling, Signed property value s, and word length w.
%
%     T = numerictype(s,w,f) creates a numerictype object with Fixed-point:
%     binary point scaling, Signed property value s, word length w and fraction length f.
%
%     T = numerictype(s,w,slope,bias) creates a numerictype object with
%     Fixed-point: slope and bias scaling, Signed property value s, word length w, slope
%     and bias.
%
%     T = numerictype(s,w,slopeadjustmentfactor,fixedexponent,bias) creates
%     a numerictype object with Fixed-point: slope and bias scaling,
%     Signed property value s, word length w, slopeadjustmentfactor, fixedexponent and
%     bias.
%
%     T = numerictype('boolean') creates a boolean numerictype object.
%     T = numerictype('double')  creates a double  numerictype object.
%     T = numerictype('single')  creates a single  numerictype object.
%
%     T = numerictype(property1,value1, ...) creates a numerictype object
%     with specified property/values.
%
%     T = numerictype(s, w, ..., property1, value1, ...) creates a
%     numerictype object with Signed property value s, word length w,
%     etc. and specified property/values.
%
%     The numerictype object properties and values can be set by using the
%     dot notation will the following syntax:
%       T = numerictype;
%       T.PropertyName = Value
%       Value = T.PropertyName
%     For example,
%       T = numerictype
%       T.WordLength = 80
%       w = T.WordLength
%
%     T = numerictype(T1, property1,value1, ...) copies numerictype
%     object T1 to T, and sets T's property/value pairs.
%
%   The valid properties and values are as follows (defaults are set apart
%   by <>)
%
%              DataTypeMode: {<'Fixed-point: binary point scaling'>,
%                             'Fixed-point: slope and bias scaling',
%                             'Fixed-point: unspecified scaling',
%                             'Scaled double: binary point scaling',
%                             'Scaled double: slope and bias scaling',
%                             'Scaled double: unspecified scaling',
%                             'Boolean',
%                             'Double',
%                             'Single'}
%                  DataType: {<'Fixed'>,
%                             'boolean',
%                             'double',
%                             'single'}
%          DataTypeOverride: {<'Inherit'>,
%                             'Off'}
%                   Scaling: {<'BinaryPoint'>,
%                             'SlopeBias',
%                             'Unspecified'}
%                    Signed: {<true>, false}
%                Signedness: {<Signed>, Unsigned, Auto}
%                WordLength: Positive integer, <16>
%            FractionLength: Integer = -FixedExponent, <15>
%             FixedExponent: Integer = -FractionLength, <-15>
%                     Slope: Double, <2^-15>
%     SlopeAdjustmentFactor: Double, <1>, must be greater than or equal to 1 and less than 2
%                      Bias: Double, <0>
%
%   Only fixed-point and integer numeric types are allowed in FI objects.
%
%   Fixed-point numbers are specified by one of the following formulas:
%
%   (1) If
%         DataTypeMode='Fixed-point: binary point scaling'
%         (equivalently, DataType='Fixed', Scaling='BinaryPoint')
%       then
%          Real-world value = (-1)^Signed * 2^(-FractionLength)  * (Stored Integer).
%
%   (2) If
%         DataTypeMode='Fixed-point: slope and bias scaling'
%         (equivalently, DataType='Fixed', Scaling='SlopeBias')
%       then
%         Real-world value = (-1)^Signed * SlopeAdjustmentFactor * 2^FixedExponent * (Stored Integer) + Bias.
%       The Slope is defined by
%         Slope = SlopeAdjustmentFactor * 2^FixedExponent
%
%   Examples:
%
%     T1 = numerictype
%     T2 = numerictype(true, 16, 15) % signed, wordlength = 16, fraclength = 15
%     T3 = numerictype(true, 32, 1.0, 0, 2.0)
%     T4 = numerictype('WordLength', 80, 'FractionLength', 40)
%     T5 = numerictype('Scaling', 'SlopeBias', 'SlopeAdjustmentFactor', 1.8, 'Bias', 10, 'FixedExponent', -14)
%
%     T6 = numerictype
%     T6.WordLength = 80
%     T6.FractionLength = 40
%
%     T7 = numerictype(T6, 'FractionLength', 50)
%
%     T8 = numerictype(false,24,12,'DataType','ScaledDouble')
%
%   See also FI, FIMATH, FIPREF, QUANTIZER, SAVEFIPREF, FORMAT, FIXEDPOINT

%   Copyright 2003-2017 The MathWorks, Inc.

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end
    
if nargin > 0 && ~isnumerictype(varargin{1})
    % Split between initial numeric values and pv pairs
    first_char_position = 0;
    for i=1:nargin
        if ischar(varargin{i})
            first_char_position = i;
            break;
        end
    end
    if first_char_position > 1
        % Leading numeric values followed by p/v pairs.  For example,
        % numerictype(true,16,14,'DataType','ScaledDouble') is equivalent to
        %   T = numerictype(true,16,14);
        %   this = numerictype(T,'DataType','ScaledDouble');
        T = numerictype(varargin{1:first_char_position-1});
        this = numerictype(T,varargin{first_char_position:end});
        return
    end
end
    
if nargin == 1 && ischar(varargin{1})
    % numerictype('double'), numerictype('single'), numerictype('boolean')
    % numerictype('sfix32_F1p25_En10')
    this = embedded.numerictype;
    this = resolveNonNumericInput(this, varargin{1});
    
elseif nargin == 3 && strcmpi(varargin{nargin - 1}, 'DataTypeOverride')
    % numerictype('double','DataTypeOverride','Inherit')
    this = createDataTypeStrDTO(varargin{:});
    
elseif nargin > 0 &&  ...
        (isnumeric(varargin{1}) || islogical(varargin{1}))
    % FIXDT-like signature
    % check rest of arguments
    narginchk(1, 7);
    if nargin > 1
        if ~(isnumeric(varargin{2}) && isscalar(varargin{2}))
            error(message('fixed:numerictype:invalidWLInputArg'));
        end
    end
    
    % detect if there is property value pairs
    propIndex = nargin - 1;
    if nargin > 2 && strcmpi(varargin{propIndex}, 'DataTypeOverride')
        % explicitly set DataTypeOverride property
        this = createDataTypeStrDTO(varargin{:});
        return;
    end
    
    valueIndex = nargin;

    for ii = 3 : valueIndex
        if ~isnumeric(varargin{ii})
            error(message('fixed:numerictype:invalidInputArg', varargin{ii}));
        elseif  ~isscalar(varargin{ii})
            error(message('fixed:numerictype:inputMustBeScalar'));
        end
    end
    
    this = embedded.numerictype;
    switch valueIndex
        case 1
            % signed
            % numerictype(true), numerictype(false)
            this.DataTypeMode = 'Fixed-point: unspecified scaling';
            this.SignednessBool = varargin{1};
            this.WordLength     = 16;
        case 2
            % signed, wordlength
            % numerictype(true, 32)
            this.DataTypeMode = 'Fixed-point: unspecified scaling';
            this.SignednessBool = varargin{1};
            this.WordLength     = varargin{2};
        case 3
            % signed, wordlength, fractionlength
            % numerictype(true, 32, 30)
            this.DataTypeMode   = 'Fixed-point: binary point scaling';
            this.SignednessBool = varargin{1};
            this.WordLength     = varargin{2};
            this.FractionLength = varargin{3};
        case 4
            % signed, wordlength, slope, bias
            % numerictype(true, 32, 0.1, 10)
            this.DataTypeMode   = 'Fixed-point: slope and bias scaling';
            this.SignednessBool = varargin{1};
            this.WordLength     = varargin{2};
            this.Slope          = varargin{3};
            this.Bias           = varargin{4};
        case 5
            % signed, wordlength, slopeadjustmentfactor, fixedexponent, bias
            % numerictype(true, 32, 1.2, -30, 10)
            this.DataTypeMode          = 'Fixed-point: slope and bias scaling';
            this.SignednessBool        = varargin{1};
            this.WordLength            = varargin{2};
            saf = varargin{3};
            fe  = varargin{4};
            if (saf < 1) || ( 2 <= saf)
                % Normalize SlopeAdjustmentFactor if necessary
                [saf,additionalExponent]=log2(saf);
                saf = 2 * saf;
                fe = fe + additionalExponent - 1;
            end
            this.SlopeAdjustmentFactor = saf;
            this.FixedExponent         = fe;
            this.Bias                  = varargin{5};
        otherwise
            if nargin < 8
                error(message('fixed:numerictype:noMoreThan5InpArgs'));
            else
                error(message('fixed:numerictype:noMoreThan7InpArgs'));
            end
    end
else
    % PV pair signature (with or w/o initial numerictype)
    n1=0;
    if nargin > 0 && ( isnumerictype(varargin{1}) || isa(varargin{1},'Simulink.NumericType'))
      if isa(varargin{1},'Simulink.NumericType')
           this = embedded.numerictype;
           S = varargin{1};
           this.DataTypeMode   = S.DataTypeMode;
           this.SignednessBool = S.SignednessBool;
           this.WordLength     = S.WordLength;
           this.FixedExponent  = S.FixedExponent;
           this.SlopeAdjustmentFactor = S.SlopeAdjustmentFactor;
           this.Bias           = S.Bias;
       else
           this = varargin{1};
       end
       n1=n1+1;
    else
        this = embedded.numerictype;
    end
    n2 = nargin - n1;
    if fix(n2/2)~=n2/2
        error(message('fixed:numerictype:invalidPVPairs'));
    end
    for k=(n1+1):2:n2
        try
            this.(varargin{k}) = varargin{k+1};
        catch ME
            error(message('fixed:numerictype:invalidPVPairs'));
        end
    end
end


function DataType = ResolveFixPtType(dataTypeNameStr)

pos = 1;

signed   = 0;
slope    = 1;
fraction = 1;
exponent = 0;
bias     = 0;
isscaleddouble = false;

switch dataTypeNameStr(pos)
    case 's'
        signed = 1;
        pos = 5;
    case 'u'
        signed = 0;
        pos = 5;
    case 'f'
        pos = 4;
        isscaleddouble = true;
        if (dataTypeNameStr(pos) == 's')
            signed  = 1;
            pos = 5;
        elseif (dataTypeNameStr(pos) == 'u')
            pos = 5;
        else
            % must be a custom float
            DataType = eval(['float(',strrep(dataTypeNameStr(pos:end),'E',','),')']);
            return
        end
    otherwise
        error(message('fixed:numerictype:unrecogDTNameStr', dataTypeNameStr));
end

end_pos = length(dataTypeNameStr);

sep = strfind(dataTypeNameStr(pos:end), '_');

if isempty(sep)
    next_pos = end_pos;
else
    next_pos = pos+sep(1)-2;
end

try
    WordLength = eval(dataTypeNameStr(pos:next_pos));
catch
    WordLength = 0;
end

pos = next_pos + 2;

while (pos < end_pos)
    sep = strfind(dataTypeNameStr(pos:end), '_');
    
    if isempty(sep)
        next_pos = end_pos;
    else
        next_pos = pos+sep(1)-2;
    end
    
    switch dataTypeNameStr(pos)
        case 'S'
            slope = ...
                eval(strrep(strrep(dataTypeNameStr(pos+1: next_pos),'p','.'),'n','-'));
        case 'E'
            exponent = ...
                eval(strrep(strrep(dataTypeNameStr(pos+1: next_pos),'p','.'),'n','-'));
        case 'B'
            bias = ...
                eval(strrep(strrep(dataTypeNameStr(pos+1: next_pos),'p','.'),'n','-'));
        case 'F'
            fraction = ...
                eval(strrep(strrep(dataTypeNameStr(pos+1: next_pos),'p','.'),'n','-'));
        otherwise
            error(message('fixed:numerictype:unrecogDTNameStr', dataTypeNameStr));
    end
    pos = next_pos + 2;
end


if ( slope == 1 && fraction == 1 && bias == 0 )
    if isscaleddouble
        DataType = numerictype('Signed', signed, 'WordLength',WordLength, ...
            'FixedExponent',exponent,'DataType','scaleddouble', ...
            'Scaling','binarypoint');
    else
        DataType = numerictype('Signed', signed, 'WordLength',WordLength, ...
            'FixedExponent',exponent,'Scaling','binarypoint');
    end
else
    
    TotalSlope = slope * fraction * 2^exponent;
    
    [fff,eee] = log2( TotalSlope );
    
    fff = 2 * fff;
    eee = eee - 1;
    
    if isscaleddouble
        DataType = numerictype('Signed', signed, 'WordLength',WordLength, ...
            'FixedExponent',eee, 'DataType','scaleddouble', ...
            'Scaling','slopebias', 'SlopeAdjustmentFactor',fff);
    else
        DataType = numerictype('Signed', signed, 'WordLength',WordLength, ...
            'FixedExponent',eee, 'Scaling','slopebias', ...
            'SlopeAdjustmentFactor',fff);
    end
    
    DataType.Bias = bias;
end

function DataType = dtInt(DataType,isSigned,wordLength)
    DataType.DataTypeMode = 'Fixed-point: binary point scaling';
    DataType.SignednessBool = isSigned;
    DataType.WordLength = wordLength;
    DataType.FixedExponent = 0;

function DataType = getFromBuiltInTypesStr(DataType, dataTypeNameStr)

switch lower(dataTypeNameStr)
    
    case 'double'
        DataType.DataTypeMode = 'Double';
        
    case {'single','float'}
        DataType.DataTypeMode = 'Single';
        
        
    case 'float16'
        if fifeature('NumerictypeSupportFloat16') == 1
            DataType.DataTypeMode = 'Float16';
        else
            error(message('fixed:numerictype:unrecogDTNameStr', dataTypeNameStr));
        end
        
    case {'boolean','bool','logical'}
        DataType.DataTypeMode = 'Boolean';
        
    case 'int64'
        DataType = dtInt(DataType,true,64);
        
    case 'int32'
        DataType = dtInt(DataType,true,32);
        
    case 'int16'
        DataType = dtInt(DataType,true,16);
        
    case 'int8'
        DataType = dtInt(DataType,true,8);
        
    case 'uint64'    
        DataType = dtInt(DataType,false,64);
        
    case 'uint32'
        DataType = dtInt(DataType,false,32);
        
    case 'uint16'
        DataType = dtInt(DataType,false,16);
        
    case 'uint8'
        DataType = dtInt(DataType,false,8);        
        
    otherwise
        
        if (strncmp(dataTypeNameStr, 'sfix', 4) || ...
                strncmp(dataTypeNameStr, 'ufix', 4) || ...
                strncmp(dataTypeNameStr, 'flt',  3))
            
            DataType = ResolveFixPtType(dataTypeNameStr);
            
        else
            error(message('fixed:numerictype:unrecogDTNameStr', dataTypeNameStr));
        end
end

function DataType = resolveNonNumericInput(DataType, firstInputArg)

dataTypeNameStr = firstInputArg;

DataType = getFromBuiltInTypesStr(DataType, dataTypeNameStr);


function propVal = parseDTOPropValuePair(valArg)
if strcmpi(valArg, 'inherit') || strcmpi(valArg, 'off')
    propVal = valArg;
else
    error(message('fixed:numerictype:invalidDTOSetting'));
end

function DataType = createDataTypeStrDTO(varargin)
valueIndex = nargin - 2;
try
    DataType = numerictype(varargin{1:valueIndex});
    propVal = parseDTOPropValuePair(varargin{nargin});
    DataType.DataTypeOverride = propVal;
catch exMsg
    throw(exMsg);
end
