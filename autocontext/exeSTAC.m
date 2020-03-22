function [trees,opts] = exeSTAC(data,opts,errorIds,secStage)
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
    
    [~ ,~,lbls] = getImgPatch(data.img,xyz,opts,data.lab);
    %     imgFt =extOriFeat(pch,hpch,opts);
    %     clear pch hpch
    %     if( opts.useMoreContext == 1 && opts.stage == 2 && secStage==1)
    %         opts.struAppDel =  getFisherInd(imgFt,lbls(center,center,center),opts.appRio);
    %         imgFt = imgFt(:,opts.struAppDel);
    %     end
    %     % we can't use else here, because fst stage use this function
    %     if( opts.useMoreContext == 1 && opts.stage == 2 && secStage~=1)
    %         imgFt = imgFt(:,opts.struAppDel);
    %     end
    [ppch ,phpch] = getProPatch(data.pro,xyz,opts);
    proFt = extProFeat(ppch,phpch,opts); clear ppch phpch
    
    %del some apperance feature
    if( opts.useMoreContext == 1 && opts.stage == 2 && secStage==1)
        opts.struProDel =  getFisherInd(proFt,lbls(center,eecenter,center),opts.conRio);
        proFt = proFt(:,opts.struProDel);
    end
    if( opts.useMoreContext == 1 && opts.stage == 2 && secStage~=1)
        proFt = proFt(:,opts.struProDel);
    end
    if(~isempty(data.dirtPro))
        [ppch ,phpch] = getProPatch(data.dirtPro,xyz,opts);
        dirproFt = extProFeat(ppch,phpch,opts);
        clear ppch phpch
        if( opts.useMoreContext == 1 && opts.stage == 2)
            opts.finalProDel =  getFisherInd(dirproFt,lbls(center,center,center,:),opts.conRio);
            dirproFt = dirproFt(:,opts.finalProDel);
        end
        allFt = [proFt,dirproFt];dirproFt = []; proFt = [];%#ok
    else
        allFt = proFt; proFt = [];
    end
    
    lbls(lbls ==0) = 2;
    if(t==1),printSample_Struct(lbls,[],size(proFt,2));end
    
    % allFt = [imgFt,proFt];imgFt = []; proFt = [];%#ok
 
    dwts=zeros([1,size(lbls,1)]);dwts(lbls==1)=2;dwts(lbls == 2) = 1;

    pTree=struct('minCount',8, 'minChild',8, ...
        'maxDepth',50, 'split','gini','H',2,'dWts',dwts);%
    tl=lbls;labels=cell(size(lbls,4),1);
    for i=1:size(lbls,4), labels{i}=tl(:,:,:,i); end
    pTree.discretize=@(hs,H) discretize(hs,H,opts.nSamples{opts.stage},opts.discretize);
    
    tree=forestTrain(allFt,labels,pTree);
    allFt=[];labels = [];lbls=[]; dwts=[];%#ok
    if(t==1),trees =  tree(ones(1,opts.treeNum));else,trees(t) = tree;end
end
fprintf('fst ac model done! \n');

