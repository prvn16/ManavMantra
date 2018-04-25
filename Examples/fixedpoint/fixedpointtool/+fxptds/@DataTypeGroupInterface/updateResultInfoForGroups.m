function updateResultInfoForGroups(this)
   % UPDATERESULTINFOFORGROUPS this function is a scaffolding step to make 
   % sure that the data set classes see the fields hasDTGroup and
   % getDTGruop, see g1457387
   
   % Copyright 2016-2017 The MathWorks, Inc.
   
   % get all groups
   allGroups = this.getGroups();
   
   % set the group related fields on the result, see g1457387
   for index = 1:length(allGroups)
       groupMembers = allGroups{index}.getGroupMembers;
       if length(groupMembers) > 1
           groupID = ['G' int2str(allGroups{index}.id)];
           for mIndex = 1:length(groupMembers)
               groupMembers{mIndex}.setDTGroup(groupID);
           end
       end
   end
end