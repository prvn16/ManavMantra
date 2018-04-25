function addTitledBorderToPanel(panel,title)

emptyBorder = javaMethodEDT('createEmptyBorder','javax.swing.BorderFactory');
titledBorder = javaMethodEDT('createTitledBorder','javax.swing.BorderFactory',emptyBorder,title);
javaObjectEDT(titledBorder);
panel.Peer.setBorder(titledBorder);
end