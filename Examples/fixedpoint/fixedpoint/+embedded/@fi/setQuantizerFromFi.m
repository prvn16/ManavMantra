function setQuantizerFromFi(this,q)
%setQuantizerFromFi Set quantizer from fi
%   setQuantizerFromFi(A,Q) set numeric type and fimath properties in
%   fi object A into quantizer object Q.

%   Thomas A. Bryan
%   Copyright 2003-2012 The MathWorks, Inc.
%     


switch lower(this.DataType)
  case 'fixed'
    if this.Signed
        q.mode = 'fixed';
    else
        q.mode = 'ufixed';
    end
    switch lower(this.Scaling)
      case 'binarypoint'
        q.format = [this.WordLength this.FractionLength];
      case 'slopebias'
        error(message('fixed:fi:quantizerFromFiNoSlopeBias'));
      case 'unspecified'
        error(message('fixed:fi:quantizerFromFiNoUnspecifiedScaling'));
      case 'integer'
        q.format = [this.WordLength 0];
      otherwise
        error(message('fixed:fi:quantizerFromFiBadScaling'));
    end
  case 'scaleddouble'
    if this.Signed
        q.mode = 'ScaledDouble';
    else
        q.mode = 'UnsignedScaledDouble';
    end
    switch lower(this.Scaling)
      case 'binarypoint'
        q.format = [this.WordLength this.FractionLength];
      case 'slopebias'
        error(message('fixed:fi:quantizerFromFiNoSlopeBias'));
      case 'unspecified'
        error(message('fixed:fi:quantizerFromFiNoUnspecifiedScaling'));
      case 'integer'
        q.format = [this.WordLength 0];
      otherwise
        error(message('fixed:fi:quantizerFromFiBadScaling'));
    end
  case 'double'
    q.mode = 'double';
  case 'single'
    q.mode = 'single';
  case 'boolean'
    q.mode = 'boolean';
  case 'int8'
    q.mode = 'fixed';
    q.format = [8 0];
  case 'int16'
    q.mode = 'fixed';
    q.format = [16 0];
  case 'int32'
    q.mode = 'fixed';
    q.format = [32 0];
  case 'uint8'
    q.mode = 'ufixed';
    q.format = [8 0];
  case 'uint16'
    q.mode = 'ufixed';
    q.format = [16 0];
  case 'uint32'
    q.mode = 'ufixed';
    q.format = [32 0];
  otherwise
    error(message('fixed:fi:quantizerFromFiBadDataType'));
end

q.overflowmode = this.OverflowMode;
q.roundmode    = this.RoundMode;
q.WordLength   = this.WordLength;
q.FractionLength = this.FractionLength;

