function s1 = stringvectorize(q,s)
%STRINGVECTORIZE Convert "matrix" of strings to "column" of strings
%
%   STRINGVECTORIZE(S) converts "matrix" of strings to "column" of strings. 
%
%   Example:
%     s = ['8  1  6'
%          '3  5  7'  
%          '4  9  2'];
%
%     q = quantizer;
%     stringvectorize(s)
%   % returns
%   %      ['8'
%   %       '3'
%   %       '4'
%   %       '1'
%   %       '5'
%   %       '9'
%   %       '6'
%   %       '7'
%   %       '2'];
%
%   See also QUANTIZER

%   Thomas A. Bryan
%   Copyright 1999-2006 The MathWorks, Inc.

[m,n] = stringsize(q,s);
if isempty(s)
  s1 = s;
else
  [ri,ci] = find(s == 'i');
  if isempty(ci)
    % Real
    % Remove leading and trailing blanks
    s = deblank(strjust(s,'left'));
    % Find inter-column blanks
    [rb,cb] = find(s == ' ');
    cb = unique(cb);
    if isempty(cb);
      % No inter-column blanks.  This is already a column.
      s1 = s;
    else
      % 
      s1 = [];
      cwords = cb(diff(cb)~=1);
      % make sure cwords is a column vector
      cwords = cwords(:);
      cwords = [1;[cwords;cb(end)]+1];
      for k = 1:length(cwords)-1
        s1 = strvcat(s1,deblank(strjust(s(:,cwords(k):cwords(k+1)-1),'left')));
      end
      s1 = strvcat(s1,deblank(strjust(s(:,cwords(end):end),'left')));
    end
  else
    % Complex
    ci = unique(ci);
    s1 = s(:,1:ci(1));
    for k=2:length(ci);
      s1 = [s1;deblank(strjust(s(:,ci(k-1)+1:ci(k)),'left'))];
    end
    % Remove the leading and trailing blanks
    s1 = deblank(strjust(s1,'left'));
  end  
end
