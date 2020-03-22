function [trees,opts] = exeSTAC_img(data,opts,errorIds)

hrInd= getHaarInd(opts.ihs{1});opts.hrfi =hrInd;
save([opts.haarFile int2str2(opts.iter,3) '_img.mat'],'hrInd');
hrInd= getHaarInd(opts.phs{1});opts.hrfp =hrInd;
save([opts.haarFile int2str2(opts.iter,3) '_pro.mat'],'hrInd');clear hrInd


if(opts.useParfor),parfor i=1:opts.treeNum,trainTree(opts,data,i,errorIds);end
else,for i=1: opts.treeNum, trainTree(opts,data,i,errorIds);end; end
for i=1:opts.treeNum
    t=load([opts.treeFn int2str2(i,3) '.mat'],'tree'); t=t.tree;
    if(i==1), trees=t(ones(1,opts.treeNum)); else trees(i)=t; end
end
fprintf('model done! \n');
end

function trainTree(opts,data,treeInd,errorIds)

%center  = ceil(opts.gtWidth{opts.stage} / 2);
[r,c,nImgs] = size(data.img);
xyz = getTraInd(data,opts);
if (~isempty(errorIds))
    ind =sub2ind([r,c,nImgs],xyz(:,2),xyz(:,1),xyz(:,3));
    eind = randperm(size(errorIds,1),ceil(size(errorIds,1)/7));
    ind = unique([ind;errorIds(eind)]);
    [y,x,z] = ind2sub([r,c,nImgs],ind);xyz=[x y z];
end

imgFt=getImgFt(data.img,xyz,opts);
proFt = getProFt(data.pro,xyz,opts);
lbls = getStructLabel(data.lab,opts,xyz);

lbls(lbls ==0) = 2;
if(treeInd==1),printSample_Struct(lbls,size(imgFt,2),size(proFt,2));end

allFt = [imgFt,proFt];imgFt = []; proFt = [];%#ok

dwts=zeros([1,size(lbls,1)]);dwts(lbls==1)=2;dwts(lbls == 2) = 1;

pTree=struct('minCount',18, 'minChild',15, ...
    'maxDepth',50, 'split','gini','H',2,'dWts',dwts);%
tl=lbls;labels=cell(size(lbls,4),1);
for i=1:size(lbls,4), labels{i}=tl(:,:,:,i); end
pTree.discretize=@(hs,H) discretize(hs,H,opts.nSamples{opts.stage},opts.discretize);
tree=forestTrain(allFt,labels,pTree);
save([opts.treeFn int2str2(treeInd,3) '.mat'],'tree');
fprintf('%d-->',treeInd);
end

