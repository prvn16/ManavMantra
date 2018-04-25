function disp(this)
%DISP   Display object
%   Refer to the MATLAB DISP reference page for more information.
%
%   See also DISP

%   Thomas A. Bryan, 6 February 2003
%   Copyright 2003-2012 The MathWorks, Inc.

pref = fipref;
fmt0 = get(0,'format'); % MATLAB command-window "format" mode.

% Numeric displays automatically add the loose linefeed, but char arrays
% do not.  However, the user shouldn't be able to tell the difference in
% these displays, so we add an extra linefeed for loose char arrays.
% NumericType and Fimath take care of their own space above.
isloose = strcmpi(get(0,'formatspacing'),'loose');
needextraspace = isloose && ...
    strcmpi(pref.NumericTypeDisplay,'none') && ...
    strcmpi(pref.FimathDisplay,'none');

if needextraspace
    extraspace = ' ';
else
    extraspace = '';
end

fi_number_display(this,pref,fmt0,isloose,extraspace)

fi_numerictype_display(this,pref);

fi_fimath_display(this,pref);

%--------------------------------------------------------------
function  fi_number_display(this,pref,fmt0,isloose,extraspace)

if isempty(this)
    disp('[]')
else
    if isscaleddouble(this)
        fi_scaled_double_disp(this,pref,fmt0,isloose,extraspace);
    else
        fi_non_scaled_double_disp(this,pref,fmt0,isloose,extraspace);
    end
end

%--------------------------------------------------------------
function  fi_scaled_double_disp(this,pref,fmt0,isloose,extraspace);
switch pref.NumberDisplay
  case 'int'
    w = this.WordLength;
    if isloose
        set(0,'formatspacing','compact');
        disp(storedIntegerToDouble(this))
        set(0,'formatspacing','loose');
    else
        disp(storedIntegerToDouble(this));
    end
  case 'none'
    % Just display size information
    sz = size(this);
    str = ['(',num2str(sz(1))];
    for k=2:length(sz)
        str = [str,'x',num2str(sz(k))];
    end
    str = [str,' array)'];
    disp(str)
    disp(extraspace);
  otherwise
    disp(double(this))
end


%--------------------------------------------------------------
function fi_non_scaled_double_disp(this,pref,fmt0,isloose,extraspace);
switch pref.NumberDisplay
  case 'RealWorldValue'
    if strcmpi(fmt0,'hex') && isfixed(this)
        % Display Real-World Value as hex
        disp(hex(this))
        disp(extraspace);
    elseif strcmpi(fmt0,'rational') && isfixed(this)
        % Display Real-World Value as rational
        if this.SlopeAdjustmentFactor~=1
            str1 = sprintf('%f * ',this.Slope);
        else
            str1 = sprintf('1/2^%d * ',this.FractionLength);
        end
        disp(str1);
        disp(extraspace);
        disp(this.num2sdec);
        if this.Bias~=0
            disp(sprintf('\n%+f',this.Bias));
        end
        disp(extraspace);
    else
        % Display Real-World Value as a float
        %
        % MATLAB displays single and double to different precisions, even when
        % they have the same value.  For example, try
        % format long g
        % pi                  % 3.14159265358979
        % single(pi)          % 3.141593
        % double(single(pi))  % 3.14159274101257
        % double(single(pi))==single(pi)  % true
        if isloose
            set(0,'formatspacing','compact');
        end
        if issingle(this)
            disp(single(this))
        elseif isboolean(this)
            disp(logical(this))
        else
            disp(double(this))
        end
        if isloose
            set(0,'formatspacing','loose');
        end
    end
  case 'int'
    w = this.WordLength;
    if isfloat(this) || w<=64
        if isloose
            set(0,'formatspacing','compact');
            disp(storedInteger(this))
            set(0,'formatspacing','loose');
        else
            disp(storedIntegerToDouble(this));
        end
    else
        disp(num2sdec(this));
        disp(extraspace);
    end
  case 'hex'
    disp(hex(this))
    disp(extraspace);
  case 'bin'
    disp(bin(this))
    disp(extraspace);
  case 'dec'
    disp(dec(this))
    disp(extraspace);
  case 'none'
    % Just display size information
    sz = size(this);
    str = ['(',num2str(sz(1))];
    for k=2:length(sz)
        str = [str,'x',num2str(sz(k))];
    end
    str = [str,' array)'];
    disp(str)
    disp(extraspace);
end

%--------------------------------------------------------------
function  fi_numerictype_display(this,pref)
switch pref.NumericTypeDisplay
  case {'qpoint', 'short'}
    disp(['      ',qpointstr(this)]);
  case 'none'
  otherwise
    disp(numerictype(this))
end


%--------------------------------------------------------------
function  fi_fimath_display(this,pref)
useLocalFimath = isfimathlocal(this);
if useLocalFimath
    if isscaledtype(this)
        switch pref.FimathDisplay
          case 'full'
            disp(fimath(this))
          case 'none'
        end
    end
end

%--------------------------------------------------------------

% LocalWords:  formatspacing qpoint
