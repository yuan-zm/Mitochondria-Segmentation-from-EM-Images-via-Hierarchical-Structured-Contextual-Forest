
function tr=precessSingleLayer(pre,opts)
t = pre{1}; [r,c,z] = size(t); numPoints = size(pre,1); 
center = ceil(r/2);  prius = floor( opts.gtWidth{opts.stage}/2);
% intetgrate five trees result
tr = zeros([opts.gtWidth{opts.stage},opts.gtWidth{opts.stage},opts.gtWidth{opts.stage},numPoints]);
for treNum = 1:size(pre,2)
    %treeR = pre(:,treNum); 
    treeR =cell2array(pre(:,treNum));treeR(treeR == 2) = 0;
    treeR = treeR(center-prius:center+prius,center-prius:center+prius,center-prius:center+prius,:);
    tr = tr + double(treeR);
end
tr = single(tr / opts.treeNum);


