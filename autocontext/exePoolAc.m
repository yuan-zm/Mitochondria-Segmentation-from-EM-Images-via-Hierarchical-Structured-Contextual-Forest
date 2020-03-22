function [trees,opts] = exePoolAc(data,opts,errorIds,prosp,procz)
center  = ceil(opts.gtWidth{opts.stage} / 2);
[r,c,nImgs] = size(data.img); % nImgs=1;
%extract feature for train
for t = 1: opts.treeNum
    % get train samples index
    xyz = getTraInd(data,opts);
    if (~isempty(errorIds))
        ind =sub2ind([r,c,nImgs],xyz(:,2),xyz(:,1),xyz(:,3));
        ind = unique([ind;errorIds]);
        [y,x,z] = ind2sub([r,c,nImgs],ind);xyz=[x y z];
    end

    [pch ,hpch,lbls] = getImgPatch(data.img,xyz,opts,data.lab);
    imgFt =extOriFeat(pch,hpch,opts);    clear pch hpch
    
    [ppch ,phpch] = getProPatch(data.pro,xyz,opts);
    proFt = extProFeat(ppch,phpch,opts); clear ppch phpch
    
    lbls(lbls ==0) = 2;printSample_Struct(lbls,size(imgFt,2),size(proFt,2)*3);
    allFt = [imgFt,proFt];imgFt = []; proFt = [];%#ok
    
    [ppch ,phpch] = getProPatch(prosp,xyz,opts);
    proFt = extProFeat(ppch,phpch,opts); clear ppch phpch
    allFt = [allFt,proFt]; proFt = [];%#ok
    
    [ppch ,phpch] = getProPatch(procz,xyz,opts);
    proFt = extProFeat(ppch,phpch,opts); clear ppch phpch
    allFt = [allFt,proFt]; proFt = [];%#ok

    
    dwts = zeros([1,size(lbls,1)]);
    dwts(lbls == 1) = 2;    dwts(lbls == 2) = 1;
    
    pTree=struct('minCount',7, 'minChild',11, ...
        'maxDepth',50, 'split','gini','H',2,'dWts',dwts);%
    tl=lbls; labels=cell(size(lbls,4),1);
    for i=1:size(lbls,4), labels{i}=tl(:,:,:,i); end
    pTree.discretize=@(hs,H) discretize(hs,H,opts.nSamples{opts.stage},opts.discretize);
    
    tree=forestTrain(allFt,labels,pTree);
    allFt=[];labels = [];lbls=[]; dwts=[];%#ok
    if(t==1),trees =  tree(ones(1,opts.treeNum));else,trees(t) = tree;end
    fprintf('%d',t);
end
fprintf('-------model done! \n');

