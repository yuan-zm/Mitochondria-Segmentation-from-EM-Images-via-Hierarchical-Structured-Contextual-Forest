function [tree,opts] = exeFstAc2(data,opts,errorIds,param)

traImgInd = param.ind{2};
[r,c,nImgs] = size(data.img(:,:,traImgInd)); % nImgs=1;
%extract feature for train
for t = 1: opts.treeNum
    lbls = [];imgFt = []; proFt = [];
    for i =1:nImgs
        M = data.lab(:,:,traImgInd(i));thisImg = data.img(:,:,traImgInd(i));
        thisPro = data.pro(:,:,traImgInd(i));
        % get train samples index
        xy = getTraInd(M,nImgs,opts);
        if (~isempty(errorIds))
            ind = sub2ind([r,c],xy(:,2),xy(:,1));
            ind = unique([ind;errorIds{i}]);
            [y,x] = ind2sub([r,c],ind); xy = [x y];
        end
        [pch ,hpch] = getImgPatch(thisImg,xy,opts);
        [ppch ,phpch] = getProPatch(thisPro,xy,opts);
        
        lbls= [lbls;M(sub2ind([r,c],xy(:,2),xy(:,1)))]; %#ok
        imgFt =[imgFt; extOriFeat(pch,hpch,opts)]; %#ok
        proFt =[proFt; extProFeat(ppch,phpch,opts)]; %#ok
        if(mod(i,20)==0),fprintf('fst ac extract %d pic & pro! \n',i);end
    end
    %del some apperance feature
    if( opts.useMoreContext == 2)
        opts.fstAppDel =  getFisherInd(imgFt,lbls(:),opts.appRio);
        imgFt = imgFt(:,opts.fstAppDel);
    end
    lbls(lbls ==0) = 2;
    printSample(lbls,size(imgFt,2),size(proFt,2));
    
    allFt = [imgFt,proFt];imgFt = []; proFt = [];
    
    if(opts.useFisherScore == 1)
        opts.firstFisherACInd =  getFisherInd(allFt,lbls(:),opts.conRio);
        allFt = allFt(:,opts.firstFisherACInd);
    end
    
    pTree=struct('minCount',1, 'minChild',5, ...
        'maxDepth',50, 'split','gini');
    lbls(lbls == 0) = 2;
    tree=forestTrain(allFt,lbls,pTree);% tree.hs=cell2array(tree.hs);
    if(t==1),trees =  tree(ones(1,opts.treeNum));else,trees(t) = tree;end
end

fprintf('fst ac model done! \n');

