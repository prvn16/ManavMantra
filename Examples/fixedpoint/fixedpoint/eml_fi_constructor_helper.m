function [T,F,val,fiIsautoscaled,pvpairsetdata,fimathislocal] = ...
    eml_fi_constructor_helper(maxWL,slDTOStr,slDTOAppliesToStr,emlInputFimath,datasz,varargin)
% EML_FI_CONSTRUCTOR_HELPER Helper function for MATLAB to construct a
% fi object.

%   Copyright 2003-2013 The MathWorks, Inc.

T = []; F = []; val = [];
fiIsautoscaled = false;
pvpairsetdata = false;
fimathislocal = true;

% To workaround G367399, float fi is passed from MATLAB code generation to MATLAB in three parts -
% value, numerictype & fimath. Create temporary fi object from these info
% here (in MATLAB) and pass it, along with other input arguments, to fi
% constructor.
if (length(varargin)>3 && isnumerictype(varargin{2}) && isfimath(varargin{3}))
    % create temporary fi
    hTemp = fi(varargin{1},varargin{2},varargin{3});
    varargin = {hTemp,varargin{4:end}};
end

try
    % Set the fipref
    [mlDTOStr,mlDTOAppliesToStr] = eml_fipref_helper(slDTOStr,slDTOAppliesToStr);
    
    % Set the default fimath
        defaultFimathForFiConstructors = emlInputFimath;
    origDefaultFimath = fimath;
    %globalfimath(defaultFimathForFiConstructors);
    embedded.fimath.SetGlobalFimath(defaultFimathForFiConstructors);
    h = fi(varargin{:});
    T = numerictype(h);
    F = fimath(h);

    % Reset fipref to original DTO
    eml_fipref_helper(mlDTOStr,mlDTOAppliesToStr);
    
    % Reset the default fimath to its original value
    %globalfimath(origDefaultFimath);
    embedded.fimath.SetGlobalFimath(origDefaultFimath);
    
    % If the value of h has been set by setting the 'Data' property using
    % varargin{1} then val = varargin{1}, otherwise h's value has been set
    % by a PV pair so gets the correct value.
    pvpairsetdata = datasetbypvpair(h);
    if pvpairsetdata && isnumeric(varargin{1}) && ~isequal(size(h),datasz)
        error(message('fixed:coder:fiPVPairsDataPropSizeMustMatchFIFirstInpArgSize'));
    end
    if isequal(LastPropertySet(h),26) && ~pvpairsetdata
        val = varargin{1};
    else
        % If the data was set using a PV pair then simply return the fi.
        % This will maintain precision if WL > 53 bits (instead of casting
        % it to a double)
        val = h;
    end
    fiIsautoscaled = isautoscaled(h);
    fimathislocal = isfimathlocal(h);
    % If fimath is not local and the fi-data was set by a double value set the round and overflow modes of F
    % to nearest & saturate regardless of what it might be. 
    % This will ensure that MATLAB code generation uses these modes to create the
    % fimathless fi from a double-precision real-world value.
    if ~fimathislocal && isequal(LastPropertySet(h),26)
        F.RoundMode = 'nearest';
        F.OverflowMode = 'saturate';
    end
    
    % Check the Numerictype's "DataType" property and error out if it is
    % 'boolean'
    if strcmpi(T.DataType,'boolean')
        % ========================
        % Reset fipref to original DTO
        eml_fipref_helper(mlDTOStr,mlDTOAppliesToStr);
        % Reset the default fimath to its original value
        %globalfimath(origDefaultFimath);
        embedded.fimath.SetGlobalFimath(origDefaultFimath);
        % ========================
        error(message('fixed:coder:unsupportedBooleanNumerictype'));
    end
    % Check the Numerictype's WordLength and error if > EMLFiMaxBits
    if strcmpi(T.DataType,'Fixed') && (T.WordLength >  double(maxWL))      
        error(message('fixed:coder:wordLengthExceedsMaxWL', double(maxWL)));
    end
catch ME
    % ========================
    % Reset fipref to original DTO
    eml_fipref_helper(mlDTOStr,mlDTOAppliesToStr);
    % Reset the default fimath to its original value
    %globalfimath(origDefaultFimath);
    embedded.fimath.SetGlobalFimath(origDefaultFimath);
    % ========================
    ME.rethrow;
end

nout = nargout;
if nout<=1
    T = {T,F,val,fiIsautoscaled};
end

% LocalWords:  Fis DTO h's PV fimathless Numerictype's
