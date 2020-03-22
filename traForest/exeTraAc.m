function [trees,opts] = exeTraAc(data,opts,errorIds)

if(opts.useParfor),parfor i=1:opts.treeNum,trainTree(opts,data,i,errorIds);end 
else,for i=1: opts.treeNum, trainTree(opts,data,i,errorIds);end; end
for i=1:opts.treeNum
    t=load([opts.treeFn int2str2(i,3) '.mat'],'tree'); t=t.tree;
    if(i==1), trees=t(ones(1,opts.treeNum)); else trees(i)=t; end
end
fprintf('fst ac model done! \n');
end

function trainTree(opts,data,treeInd,errorIds)

[r,c,nImgs] = size(data.img); % nImgs=1;
% get train samples index
xyz = getTraInd(data,opts);
if (~isempty(errorIds))
    ind =sub2ind([r,c,nImgs],xyz(:,2),xyz(:,1),xyz(:,3));
    ind = unique([ind;errorIds]);
    [y,x,z] = ind2sub([r,c,nImgs],ind);xyz=[x y z];
end

%     [pch ,hpch,~] = getImgPatch(data.img,xyz,opts,data.lab);
%     imgFt =extOriFeat(pch,hpch,opts);
%     clear pch hpch
% load label
lbls= single(data.lab(sub2ind([r,c,nImgs],xyz(:,2),xyz(:,1),xyz(:,3))));

[ppch ,phpch] = getProPatch(data.pro,xyz,opts);
proFt = extProFeat(ppch,phpch,opts);    clear ppch phpch

lbls(lbls ==0) = 2; if(treeInd==1),printSample(lbls,0,size(proFt,2));end

%allFt = [imgFt,proFt];imgFt = []; proFt = [];%#ok

dwts=zeros([1,size(lbls,1)]);dwts(lbls==1)=2;dwts(lbls==2)=1;

pTree=struct('minCount',5, 'minChild',8, ...
    'maxDepth',50, 'split','gini','H',2,'dWts',dwts);%
tree=forestTrain(proFt,lbls,pTree); allFt=[];lbls=[]; dwts=[];%#ok
save([opts.treeFn int2str2(treeInd,3) '.mat'],'tree');
fprintf('%d-->',treeInd);
end