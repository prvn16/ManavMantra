function str = qpointstr(this)
%QPOINTSTR Q-point string
%   QPOINTSTR(A) returns the qpoint string that is used in numerictype
%   display 'short'.

%   Copyright 2003-2012 The MathWorks, Inc.

str = '';

if isscaledtype(this)
    if issigned(this) 
        str = [str 's']; 
    else 
        str = [str 'u']; 
    end
    if isscaleddouble(this) 
        str = [str 'flt'];
    end
    switch lower(this.Scaling);
        case 'binarypoint'
            str = [str,num2str(this.WordLength),',',num2str(this.FractionLength)];
        case 'slopebias'
            if isfixed(this) 
                str = [str 'fix'];
            end
            str = [str,num2str(this.WordLength)];
            if this.SlopeAdjustmentFactor==1 && this.Bias==0
                str = [str,'_En',num2str(this.FractionLength)];
            else
                slopestr = num2str(this.Slope,'%0.16g');
                k=findstr(slopestr,'.');slopestr(k)='p';
                bias = num2str(this.Bias,'%0.16g');
                k=findstr(bias,'.');bias(k)='p';
                str = [str,'_S',slopestr,'_B',bias];
            end
        otherwise
            str = [str, num2str(this.WordLength)];
    end    
else
    str = this.DataType;
end

% LocalWords:  qpoint binarypoint slopebias
