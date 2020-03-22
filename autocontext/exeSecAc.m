function [trees,opts] = exeSecAc(data,opts,errorIds)

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
    [ppch ,phpch] = getProPatch(data.pro,xyz,opts);
    imgFt =extOriFeat(pch,hpch,opts);
    proFt = extProFeat(ppch,phpch,opts);
    
    center  = ceil(opts.gtWidth / 2);
    %del some apperance feature
    if( opts.useMoreContext == 1 && opts.stage == 2)
        opts.struAppDel =  getFisherInd(imgFt,lbls(center,center,center),opts.appRio);
        imgFt = imgFt(:,opts.struAppDel);
        opts.struProDel =  getFisherInd(proFt,lbls(center,center,center),opts.conRio);
        proFt = proFt(:,opts.struProDel);
    end

    lbls(lbls ==0) = 2;
    printSample_Struct(lbls,size(imgFt,2),size(proFt,2));
    
    allFt = [imgFt,proFt];imgFt = []; proFt = [];%#ok
    
    if(opts.useFisherScore == 1)
        opts.firstFisherACInd =  getFisherInd(allFt,lbls(:),opts.conRio);
        allFt = allFt(:,opts.firstFisherACInd);
    end
    

    dwts = zeros([1,size(lbls,1)]);
    dwts(lbls == 1) = 2;    dwts(lbls == 2) = 1;
    
    pTree=struct('minCount',1, 'minChild',5, ...
        'maxDepth',50, 'split','gini','H',3,'dWts',dwts);
    tl=lbls; labels=cell(size(lbls,4),1);
    for i=1:size(lbls,4), labels{i}=tl(:,:,:,i); end
    pTree.discretize=@(hs,H) discretize(hs,H,opts.nSamples,opts.discretize);
    
    tree=forestTrain(allFt,labels,pTree);
    if(t==1),trees =  tree(ones(1,opts.treeNum));else,trees(t) = tree;end
    
end
fprintf('sec ac model done! \n');

