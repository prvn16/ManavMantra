function str = mat2str(a,varargin)
% mat2str Convert a 2-D matrix to a string in MATLAB syntax.
%    STR = mat2str(MAT) converts the 2-D matrix MAT to a MATLAB
%    string so that EVAL(STR) produces the original matrix (to
%    within 15 digits of precision).  Non-scalar matrices are
%    converted to a string containing brackets [].
%
%    STR = mat2str(MAT,N) uses N digits of precision.
%
%    STR = mat2str(MAT, 'class') creates a string with the name of the class
%    of MAT included.  This option ensures that the result of evaluating STR
%    will also contain the class information.
%
%    STR = mat2str(MAT, N, 'class') uses N digits of precision and includes
%    the class information.
%
%    Examples
%
%        a = fi(magic(3))
%        mat2str(a) %  produces the string '[8 1 6; 3 5 7; 4 9 2]'.
%
%        a = fi(magic(3))
%        mat2str(a,'class') % produces the string
%        % fi('numerictype',numerictype(1,16,11),'Value','[8 1 6;3 5 7;4 9 2]')
%
%        a = range(fi([],1,10000,0))
%        mat2str(a,5) % produces the string '[-9.9753e+3009 9.9753e+3009]'
%
%    See also num2str, int2str, sprintf, class, eval.

%   Copyright 2015-2017 The MathWorks, Inc.

    if nargin > 1
        [varargin{:}] = convertStringsToChars(varargin{:});
    end
    
    narginchk(1,3);

    if isempty(varargin)
        % mat2str(a)
        ndigits = default_number_of_digits(a);
        str = a.Value2Inputs(ndigits);
    else
        ndigits = ndigits_input(a,varargin{:});
        value_string = a.Value2Inputs(ndigits);
        if is_class_input(varargin{:})
            T = tostring(a.numerictype);
            str = ['fi(''numerictype'',',T];
            if a.fimathislocal
                F = tostring(a.fimath);
                F = regexprep(F,'...\n','');
                str = [str,',''fimath'',',F,];
            end
            str = [str,',''Value'','];
            str = [str,'''',value_string,'''',')'];
        else
            str = value_string;
        end
        
    end
end

function t = is_class_input(varargin)
    t = false;
    for n = 1:length(varargin)
        if ischar(varargin{n})
            if strcmpi(varargin{n},'class')
                t = true;
            else
                error(message('MATLAB:mat2str:InvalidOptionString',varargin{n}));
            end
        end
    end
end

function ndigits = ndigits_input(a,varargin)
    ndigits = default_number_of_digits(a);
    for n = 1:length(varargin)
        if isnumeric(varargin{n})
            ndigits_input = double(varargin{n});
            if ~isempty(ndigits_input)
                ndigits = ndigits_input(1);
            end
            break
        end
    end
end

function ndigits = default_number_of_digits(a)
    % The default number of digits if none were given.
    ndigits = max(minimum_round_trip_digits(a),20);
end
function min_digits = minimum_round_trip_digits(a)
    % Minimum number of digits to successfully "round trip".
    % Reference: Gnu MPFR documentation, section mpfr_get_str
    % (http://www.mpfr.org/mpfr-current/mpfr.html).
    b = 10;  % Base
    p = a.WordLength;  % Precision (in bits)
    min_digits = 1 + ceil(p*log(2)/log(b)); 
end

% LocalWords:  MPFR 
% LocalWords:  http www mpfr org mpfr current html