function setPrintPreferences(inprefs, invalues)
% Internal helper function to set printing preferences

% The function will set the preference (for future use) and the root
% object's corresponding default property 
% Copyright 2015 The MathWorks, Inc.
   
   % valid preference names and the preference type 
   persistent validPrefs;
   if isempty(validPrefs)
      validPrefs.DefaultPaperPositionMode.type = 'string';
      validPrefs.DefaultPaperPositionMode.values = {'auto', 'manual'};
      validPrefs.DefaultPaperPositionMode.rootProp = 'DefaultFigurePaperPositionMode';
   end
   
   if ischar(inprefs) && size(invalues, 1) == 1
       newPrefValues.(inprefs) = invalues; 
       fieldsToSet = fieldnames(newPrefValues);
    end

   for idx = 1:length(fieldsToSet)
       if ~isfield(validPrefs, fieldsToSet{idx})
           error(message('MATLAB:print:InvalidPreferenceName', fieldsToSet{idx}));
       end
   end
 
   for idx = 1:length(fieldsToSet)
      if strcmp(validPrefs.(fieldsToSet{idx}).type, 'string') 
          if ~any(strcmp(newPrefValues.(fieldsToSet{idx}), validPrefs.(fieldsToSet{idx}).values))
              error(message('MATLAB:print:InvalidPreferenceValue', newPrefValues.(fieldsToSet{idx}), fieldsToSet{idx}));
          end
          setpref('FigurePrinting', fieldsToSet{idx}, newPrefValues.(fieldsToSet{idx})); 
      end
      % set current default as well, if there is one 
      if ~isempty(validPrefs.(fieldsToSet{idx}).rootProp)
          set(groot, validPrefs.(fieldsToSet{idx}).rootProp, newPrefValues.(fieldsToSet{idx}));
      end
   end
end
