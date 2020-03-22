function [trees,opts] = exeTraAc_img(data,opts,errorIds)

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
fprintf('fst ac model done! \n');
end

function trainTree(opts,data,treeInd,errorIds)

[r,c,nImgs] = size(data.img); % nImgs=1;
% get train samples index
xyz = getTraInd(data,opts);
if (~isempty(errorIds))
    ind =sub2ind([r,c,nImgs],xyz(:,2),xyz(:,1),xyz(:,3));
    eind = randperm(size(errorIds,1),ceil(size(errorIds,1)/7));
    ind = unique([ind;errorIds(eind)]);
    [y,x,z] = ind2sub([r,c,nImgs],ind);xyz=[x y z];
end

imgFt=getImgFt(data.img,xyz,opts);
proFt = getProFt(data.pro,xyz,opts);

% load label
lbls= single(data.lab(sub2ind([r,c,nImgs],xyz(:,2),xyz(:,1),xyz(:,3))));


lbls(lbls ==0) = 2; if(treeInd==1),printSample(lbls,0,size(proFt,2));end

%allFt = [imgFt,proFt];imgFt = []; proFt = [];%#ok

dwts=zeros([1,size(lbls,1)]);dwts(lbls==1)=2;dwts(lbls==2)=1;

pTree=struct('minCount',15, 'minChild',10, ...
    'maxDepth',50, 'split','gini','H',2,'dWts',dwts);%
tree=forestTrain([imgFt,proFt],lbls,pTree); 
imgFt = []; proFt = [];lbls=[]; dwts=[];%#ok
save([opts.treeFn int2str2(treeInd,3) '.mat'],'tree');
fprintf('%d-->',treeInd);
end