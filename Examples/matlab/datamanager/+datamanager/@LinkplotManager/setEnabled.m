function setEnabled(h,status)

for k=1:length(h.Figures)
    h.Figures(k).EventManager.Enable = status;
end
if ~(h.DebugMode)
    if strcmp(status,'on')
        h.LinkListener.setEnabled(true);
    elseif strcmp(status,'off')
        h.LinkListener.setEnabled(false);
    end
end