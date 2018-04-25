function ageCheckCB(src, eventdata)

if (eventdata.Indices(2) == 2 && ...
      (eventdata.NewData < 0 || eventdata.NewData > 120))
   tableData = src.Data;
   tableData{eventdata.Indices(1), eventdata.Indices(2)} = eventdata.PreviousData;
   src.Data = tableData;                              % set the data back its original value
   warning('Age value must be between 0 and 120.')    % warn the user
end

end