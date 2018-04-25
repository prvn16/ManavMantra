function display(obj)
%DISPLAY Display an INLINE object.

%   Steven L. Eddins, August 1995
%   Copyright 1984-2002 The MathWorks, Inc. 

isLoose = strcmp(matlab.internal.display.formatSpacing,'loose');

line1 = sprintf('%s =', inputname(1));

if (obj.isEmpty)
  line2 = getString(message('MATLAB:Inline:Inline:DisplayInlineFunctionempty'));
else
  line2 = sprintf(getString(message('MATLAB:Inline:Inline:DisplayInlineFunction', inputname(1))));
  for k = 1:(obj.numArgs-1)
    line2 = sprintf('%s%s,', line2, deblank(obj.args(k,:)));
  end
  line2 = sprintf('%s%s)', line2, deblank(obj.args(obj.numArgs,:)));
  line2 = sprintf('%s = %s', line2, obj.expr);
end

if (isLoose)
  fprintf('\n');
end
fprintf('%s\n', line1);
if (isLoose)
  fprintf('\n');
end
fprintf('     %s\n', line2);
if (isLoose)
  fprintf('\n');
end
