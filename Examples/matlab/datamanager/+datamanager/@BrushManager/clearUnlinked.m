function clearUnlinked(h,ax,objs)

if nargin<=2
    objs = datamanager.getAllBrushableObjs(ax);
end

for k=1:length(objs)
    if ~isempty(findprop(handle(objs(k)),'BrushData'))
       bData = get(objs(k),'BrushData');
       set(objs(k),'BrushData',uint8(zeros(size(bData))));
    end
end
