function strData = convertNumericToString(numData)
% Convert numeric data to character strings representing that
% data.  DICOM number strings can be at most 16-bytes long and
% should use exponential notation where necessary.
%
% We use a complicated set of rules involving the sign of the data
% and its base-10 logarithm to pick a precision value for SPRINTF
% that maximizes the significant digits and prints at most 16
% characters.
%
% When viewed on a number line, the state transitions for the
% precision value are listed below.  (That is, where do the rules
% for determining the format specifier change?)
%
%   * -1E+14
%   * -1E+0 (aka -1)
%   * -1E-5
%   *  0
%   *  1E-5
%   *  1E+0 (aka 1)
%   *  1E+14

% Copyright 2002-2017 The MathWorks, Inc.

strData = '';
for idx = 1:numel(numData)

    if (numData(idx) == 0)

        % Avoid "log of 0" warnings and needless computations.
        fmtString = '%d';

    else
      
        power10 = floor(log10(abs(double(numData(idx)))));
        
        if (numData >= 0)
          
            % The precision is:
            %   0    <= x < 1E-5  --> %.10G
            %   1E-5 <= x < 1     --> varies
            %   1    <= x < 1E14  --> %.15G
            %   1E14 <= x         --> %.10G
            if (power10 >= 14)
                fmtString = '%.10G';
            else
                precision = max(10, min(15, power10 + 15));
                fmtString = sprintf('%%.%dG', precision);
            end
    
        else
    
            % The precision is:
            %            x < -1E14  --> %.9G
            %   -1E14 <= x < -1     --> %.14G
            %   -1    <= x < -1E-5  --> varies
            %   -1E-5 <= x <  0     --> %.9G
            if (power10 >= 14)
                fmtString = '%.9G';
            else
                precision = max(9, min(14, power10 + 14));
                fmtString = sprintf('%%.%dG', precision);
            end
        end
        
    end

    strData = [strData, '\', sprintf(fmtString, numData(idx))]; %#ok<AGROW>
  
end

% Remove the leading '\' from the first iteration.
strData(1) = '';

end
