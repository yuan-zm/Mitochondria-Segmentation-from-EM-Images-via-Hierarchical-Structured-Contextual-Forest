function trees = train(data,opts)

hrInd= getHaarInd(opts.ihs{1});opts.hrfi =hrInd;
save([opts.haarFile int2str2(opts.iter,3) '_img.mat'],'hrInd');clear hrInd


if(opts.useParfor),parfor i=1:opts.treeNum, trainTree(opts,data,i);end
else,for i=1: opts.treeNum,trainTree(opts,data,i);end; end

for i=1: opts.treeNum
    t=load([opts.treeFn int2str2(i,3) '.mat'],'tree'); t=t.tree;
    if(i==1), trees=t(ones(1,opts.treeNum)); else trees(i)=t; end
end
fprintf('no ac model done! \n');
end

function trainTree(opts,data,treeInd)
[r,c,nImgs] = size(data.img); % nImgs=1;

% get train samples index
xyz = getTraInd(data,opts);
ft=getImgFt(data.img,xyz,opts);

lbls= data.lab(sub2ind([r,c,nImgs],xyz(:,2),xyz(:,1),xyz(:,3)));
lbls = uint8(lbls);lbls(lbls == 0) = 2;
if(treeInd==1),printSample(lbls,size(ft,2));end

dwts=zeros([1,size(lbls,1)]);dwts(lbls==1)=2;dwts(lbls==2)= 1;
pTree=struct('minCount',10, 'minChild',15, ...
    'maxDepth',50, 'split','gini','H',2,'dWts',dwts);% 'H',2,,'M',15

tree=forestTrain(ft,lbls,pTree);
save([opts.treeFn int2str2(treeInd,3) '.mat'],'tree');
if(opts.useParfor==0),fprintf('%d-->',treeInd); end
end
