function prefs = getPrintPreferences()
% Internal helper function to get printing preference values

% Copyright 2015 The MathWorks, Inc.

   strFields = {'DefaultPaperPositionMode', 'auto'; };
   for idx = 1:size(strFields, 1)
      if ispref('FigurePrinting', strFields{idx, 1})
          prefValue = getpref('FigurePrinting', strFields{idx, 1});
      else
          prefValue = 'unset';
      end
      prefs.(strFields{idx, 1}) = prefValue;
   end
end