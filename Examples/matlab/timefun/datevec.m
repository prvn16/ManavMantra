function [y,mo,d,h,mi,s] = datevec(t,varargin)
%DATEVEC Date components.
%	V = DATEVEC(N) converts one or more date numbers N to date vectors V. N
%	can be a scalar, vector, or multidimensional array of positive date
%	numbers. DATEVEC returns an M-by-6 matrix containing M date vectors,
%	where M is the total number of date numbers in N.
%
%	V = DATEVEC(S,F) converts text representing one or more dates to
%	date vectors V using format F. S can be a cell array of character
%	vectors or a character array where each row corresponds to one date.
%	All of the dates in S must have the same format which must be composed
%	of date format symbols according to Table 2 in DATESTR help.  DATEVEC
%	returns an M-by-6 matrix of date vectors, where M is the number of date
%	character vectors in S.
%
%	Certain formats may not contain enough information to compute a date
%	vector.  In those cases, hours, minutes, and seconds default to 0, days
%	default to 1, months default to January, and years default to the
%	current year. Dates with two character years are interpreted to be
%	within the 100 years centered around the current year.
%
%	V = DATEVEC(S,F,P) or V = DATEVEC(S,P,F) converts S to a date vector V,
%	using the pivot year P and the date format F.  The pivot year is the
%	starting year of the 100-year range in which a two-character year
%	resides.  The default pivot year is the current year minus 50 years.
%
%	[Y,MO,D,H,MI,S] = DATEVEC(...) takes any of the two syntaxes shown
%	above and returns the components of the date vector as individual
%	variables.  
%
%	V = DATEVEC(S) converts text representing one or more dates to date
%	vector V. S must be in one of the date formats 0,1,2,6,13,14,15,16,23
%	as defined by DATESTR. This calling syntax is provided for backward
%	compatibility, and is significantly slower than the syntax which
%	specifies the format character vector. If the format is known, the V =
%	DATEVEC(S,F) syntax should be used.
%
%	V = DATEVEC(S,P) converts S using pivot year P. If the format is known,
%	the V = DATEVEC(S,F,P) or V = DATEVEC(S,P,F) syntax should be used.
%
%	Note 1:  If more than one input argument is used, the first argument
%	must be a character vector representing a date or an array of character
%	vectors representing dates.
%
%	Note 2:  The vectorized calling syntax can offer significant performance
%	improvement for large arrays.
%
%	Examples
%		d = '12/24/1984';
%		t = 725000.00;
%		c = datevec(d) or c = datevec(t) produce c = [1984 12 24 0 0 0].
%		[y,m,d,h,mi,s] = datevec(d) returns y=1984, m=12, d=24, h=0, mi=0, s=0.
%		c = datevec('5/6/03') produces c = [2003 5 6 0 0 0] until 2054.
%		c = datevec('5/6/03',1900) produces c = [1903 5 6 0 0 0].
%		c = datevec('19.05.2000','dd.mm.yyyy') produces c = [2000 5 19 0 0 0].
%
%	See also DATENUM, DATESTR, CLOCK, DATETICK. 

%	Copyright 1984-2016 The MathWorks, Inc.
import matlab.internal.datatypes.stringToLegacyText

narginchk(1,3);
t = stringToLegacyText(t);

% parse input arguments
isdatestr = ~isnumeric(t);
isdateformat = false;
if ~isdatestr && nargin > 1
    warning(message('MATLAB:datevec:Inputs'));
elseif nargin > 1
    for i = 1:length(varargin)
        varargin{i} = stringToLegacyText(varargin{i});
    end
    isdateformat = cellfun('isclass',varargin,'char');
    if (nargin == 3)
        if ~isdateformat(1)
            pivotyear = varargin{1};
        elseif ~isdateformat(2)
            pivotyear = varargin{2};
        elseif isdateformat(1) && isdateformat(2)
            error(message('MATLAB:datevec:DateFormat'));
        end 
    elseif (nargin == 2) && ~isdateformat
        pivotyear = varargin{1};
    end
end

if isdatestr && isempty(t)
    if nargout <= 1
        y = zeros(0,6);
	else
		[y,mo,d,h,mi,s] = deal(zeros(0,0));
    end;
	warning(message('MATLAB:datevec:EmptyDate'));
    return;
end

% branch to appropriate date string parser
if  isdatestr
    % a date format string was specified
    % map date format to ICU date format tokens
    if ischar(t)
        % convert to cellstring.
        t = cellstr(t);
    end
    if ~iscellstr(t)
        %At this point we should have a cell array.  Otherwise error.
        error(message('MATLAB:datevec:NotAStringArray'));
    end
    icu_dtformat = {};
    if ~any(isdateformat)
        format = getformat(t);
        if ~isempty(format)
            icu_dtformat = matlab.internal.datetime.cnv2icudf(format);
        end
    else
        icu_dtformat = matlab.internal.datetime.cnv2icudf(stringToLegacyText(varargin{isdateformat}));
    end
    if ~isempty(icu_dtformat) 
        % call ICU MEX function to parse date character vector to date vector
        if nargin < 2 || (nargin == 2 && any(isdateformat)) || isempty(pivotyear)
            y = dtstr2dtvecmx(t,icu_dtformat);
        else
            showyr = strfind(icu_dtformat, 'y'); 
            if ~isempty(showyr)
                wrtYr =  numel(showyr);
                if showyr(end) - showyr(1) >= wrtYr
                    error(message('MATLAB:datevec:YearFormat'));
                end
                switch wrtYr
                    case 4,
                        icu_dtformat = strrep(icu_dtformat,'yyyy','yy');
                    case 3,
                        icu_dtformat = strrep(icu_dtformat,'yyy','yy');
                end
            end
            y = dtstr2dtvecmx(t,icu_dtformat,pivotyear);
        end
        if nargout > 1
            mo = y(:,2);
            d  = y(:,3);
            h  = y(:,4);
            mi = y(:,5);
            s  = y(:,6);
            y  = y(:,1);
        end
    else
        %last resort!!!
       if ischar(t)
          m = size(t,1);
       else
          m = length(t);
       end
       y = zeros(m,6);
       t = lower(t);
       ampmtokens = lower(getampmtokensmx);
       amtok = ampmtokens{1};
       pmtok = ampmtokens{2};
       M = lower(getmonthnamesmx('shortloc'));
       M0 = lower(getmonthnamesmx('short')); % list of English short month names.

       for i = 1:m
           % Convert date input to date vector
           % Initially, the six fields are all unknown.
           c(1,1:6) = NaN;
           pm = -1; % means am or pm is not in datestr
           if ischar(t)
               str = t(i,:);
           else
               str = t{i};
           end
           d = [' ' str ' '];

           % Replace 'a ' or 'am', 'p ' or 'pm' with ': '.
           % If e is before 'p ', it could be Sep.
           pat = 'a |am|(?<=[^e])p |pm';
           idx = regexp(d, pat, 'start'); 
           if ~isempty(idx)
               idx = idx(end);               
               pm = strcmp(d(idx), 'p');
           elseif (strcmp(amtok, 'am') == 0 || strcmp(pmtok, 'pm') == 0 )
               %Search for local am/pm tokens
               pat = [regexptranslate('escape', amtok) '|' regexptranslate('escape',pmtok)  '|'];
               idx = regexp(d, pat, 'start');
               if ~isempty(idx)
                    idx = idx(end);
                    pm = strncmp(d(idx:end), pmtok, length(pmtok));
               end
           end          
           if ~isempty(idx)
               if d(idx-1) == ' '
                    d(idx-1:idx+1) = ':  ';
               else
                    d(idx:idx+1) = ': ';
               end
           end

           % Any remaining letters must be in the month field
           p = find(isletter(d));

           % Test length of character vector to catch a bogus date character vector.
           % Get index of month in list of months of year
           % replace with spaces, month name in date character vector.
           % If English month name lookup fails, fall back on 
           % list of local month names.
           if ~isempty(p) && numel(d)>4
               k = min(p);
               if length(d) >= k+ 3 && d(k+3) == '.', d(k+3) = ' '; end
               monthidx = [];
               if length(d) >= k+2
                    monthidx = ~cellfun('isempty',strfind(M0,d(k:k+2)));
                   if ~any(monthidx)
                       monthidx = ~cellfun('isempty',strfind(M,d(k:k+2)));
                   end
               end
               if ~any(monthidx)
                   error(message('MATLAB:datevec:MonthOfYear'));
               end               
               c(2) = find(monthidx);
               d(p) = char(' '*ones(size(p)));
           end

           % Find all nonnumbers.
           p = find((d < '0' | d > '9') & (d ~= '.'));

           % Pick off and classify numeric fields, one by one.
           % Colons delinate hour, minutes and seconds.

           k = 1;
           while k < length(p)
               if d(p(k)) ~= ' ' && d(p(k)+1) == '-'
                   f = str2double(d(p(k)+1:p(k+2)-1));
                   k = k+1;
               else
                   f = str2double(d(p(k)+1:p(k+1)-1));
               end
               if ~isnan(f)
                   if d(p(k))==':' || d(p(k+1))==':'
                       if isnan(c(4))
                           c(4) = f;             % hour
                           % Add 12 if pm specified and hour isn't 12
                           if pm == 1 && f ~= 12 
                               c(4) = f+12;
                           elseif pm == 0 && f == 12
                               c(4) = 0;
                           end
                       elseif isnan(c(5))
                           c(5) = f;             % minutes
                       elseif isnan(c(6)) 
                           c(6) = f;             % seconds
                       else
                           error(message('MATLAB:datevec:NumberOfTimeFields', str));
                       end
                   elseif isnan(c(2))
                       if f > 12
                           c(1) = f;    %year
                       else
                           c(2) = f;    % month
                       end
                   elseif isnan(c(3))
                       c(3) = f;                % date
                   elseif isnan(c(1))
                       if (f >= 0) && (p(k+1)-p(k) == 3) % two char year
                           if nargin < 2
                               clk = clock;
                               pivotyear = clk(1)-50;  %(current year-50 years)
                           end
                           % Moving 100 year window centered around current year
                           c(1) = pivotyear+rem(f+100-rem(pivotyear,100),100);
                       else
                           c(1) = f;             % year
                       end
                   else
                       error(message('MATLAB:datevec:NumberOfDateFields', str));
                   end
               end
               k = k+1;
           end

           if sum(isnan(c)) >= 5
               error(message('MATLAB:datevec:ParseDateString', str));
           end
          % If any field has not been specified
           if isnan(c(1)), clk = clock; c(1) = clk(1); end
           if isnan(c(2)), c(2) = 1; end;
           if isnan(c(3)), c(3) = 1; end;
           if isnan(c(4)), c(4) = 0; end;               
           if isnan(c(5)), c(5) = 0; end;                   
           if isnan(c(6)), c(6) = 0; end;

           % Normalize components to correct ranges.
           y(i,:) = datevecmx(datenummx(c));
       end
       if nargout > 1
           mo = y(:,2);
           d  = y(:,3);
           h  = y(:,4);
           mi = y(:,5);
           s  = y(:,6);
           y  = y(:,1);
       end
    end
elseif nargout <= 1
   % date number was specified 
   y = datevecmx(t);
elseif nargout == 3
    % date number was specified and first three date fields for output
   [y,mo,d] = datevecmx(t);
else
   % date number was specified and all six date fields for output
   [y,mo,d,h,mi,s] = datevecmx(t);
end
end

function [format] = getformat(str)
  format = '';
  formatstr = cell(11,1);
  formatstr(1) = {'dd-mmm-yyyy HH:MM:SS'};
  formatstr(2) = {'dd-mmm-yyyy'};
  formatstr(3) = {'mm/dd/yy'};
  formatstr(4) = {'mm/dd'};
  formatstr(5) = {'HH:MM:SS'};
  formatstr(6) = {'HH:MM:SS PM'};
  formatstr(7) = {'HH:MM'};
  formatstr(8) = {'HH:MM PM'};
  formatstr(9) = {'mm/dd/yyyy'};
  formatstr(10) = {'dd-mmm-yyyy HH:MM'};  %used by finance
  formatstr(11) = {'dd-mmm-yy'};  %used by finance
  
  AlphaFormats = [1 1 0 0 0 1 0 1 0 1 1];
  %[1 2 6 8 10 11];
  SlashFormats = [ 0 0 1 1 0 0 0 0 1 0 0];
  %[3 4 9];
  TwoSlashFormats = [ 0 0 1 0 0 0 0 0 1 0 0];
  %[3 9];
  DashFormats = [ 1 1 0 0 0 0 0 0 0 1 1];
  %[1 2 10 11];
  ColonFormats = [1 0 0 0 1 1 1 1 0 1 0];
  %[1 5 6 7 8 10];
  TwoColonFormats = [1 0 0 0 1 1 0 0 0 0 0];
  %[1 5 6];
  SpaceFormats = [1 0 0 0 0 1 0 1 0 1 0];
  %[1 6 8 10];
  
  bMask = [ 1 1 1 1 1 1 1 1 1 1 1];
  
  if length(str) > 1
      str = str(1,1);
  end
  str = strtrim(char(str));
  slashes = strfind(str, '/');
  if ~isempty(slashes)
	  bMask = bMask & SlashFormats;
	  if (~isempty(slashes) && slashes(1) == 2)
		  if (length(slashes) > 1 && slashes(2) == 4)
			  str = ['0' str(1:slashes(1)) '0' str(slashes(1)+1:end)];
		  else
			  str = ['0' str];
		  end
	  elseif (length(slashes) > 1 && slashes(2) - slashes(1) == 2)
		  str = [str(1:slashes(1)) '0' str(slashes(1)+1:end)];
	  end
	  if length(slashes) > 1
		  bMask = bMask & TwoSlashFormats;
	  else
		  bMask = bMask & ~TwoSlashFormats;
	  end
  else
	  bMask = bMask & ~SlashFormats;
  end
  
  dashes = strfind(str,'-');
  if ~isempty(dashes)
	  bMask = bMask & DashFormats;
	  if (~isempty(dashes) && dashes(1) == 2)
		str = ['0' str];
	  end
  else
	  bMask = bMask & ~DashFormats;	  
  end
  
  colons = strfind(str,':');
  if ~isempty(colons)
	  bMask = bMask & ColonFormats;
	  if (~isempty(colons)) && (colons(1) == 2) && (length(str) - colons(end) <= 3)
		str = ['0' str];
	  end
	  if length(colons) > 1
		  bMask = bMask & TwoColonFormats;
	  else
		  bMask = bMask & ~TwoColonFormats;
	  end	  
  else
	  bMask = bMask & ~ColonFormats;
  end      
  
  spaces = strfind(str,' ');
  if ~isempty(spaces)
	  bMask = bMask & SpaceFormats;
  else
	  bMask = bMask & ~SpaceFormats;
  end
  
  for i = 1:11
      if bMask(i)
          try
              dtnumber = datenum(str, char(formatstr(i)));
              str1 = dateformverify(dtnumber,char(formatstr(i)), false);
              if (strcmpi(str, strtrim(str1)) == 1)
                  format = char(formatstr(i));
                  break;
              end
          catch exception  %#ok<NASGU>
          end
          if AlphaFormats(i)
              try
                  str1 = dateformverify(dtnumber,char(formatstr(i)),true);
                  if (strcmpi(str, strtrim(str1)) == 1)
                      format = char(formatstr(i));
                      break;
                  end
              catch exception %#ok<NASGU>
              end
          end
      end
  end
end 
