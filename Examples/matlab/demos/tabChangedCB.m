function tabChangedCB(src, eventdata)

% Get the Title of the previous tab
tabName = eventdata.OldValue.Title;

% If 'Loan Data' was the previous tab, update the table and plot
if strcmp(tabName, 'Loan Data')
   % <insert code here to update the amorization table and plot>
end

end