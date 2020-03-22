function model = mergeTrees( nTrees )
% accumulate trees and merge into final model
treeFn = [opts.modelDir '/tree/tree_'];
for i=1:nTrees
  t=load([treeFn num2str(i) '.mat'],'tree'); t=t.tree;
  if(i==1), trees=t(ones(1,nTrees)); else trees(i)=t; end
end
nNodes=0; for i=1:nTrees, nNodes=max(nNodes,size(trees(i).fids,1)); end
% merge all fields of all trees
Z=zeros(nNodes,nTrees,'uint32');
model.thrs=zeros(nNodes,nTrees,'single');
model.fids=Z; model.child=Z; model.count=Z; model.depth=Z;model.hs=Z;
model.distr = zeros(nNodes,nTrees,'single');

for i=1:nTrees, tree=trees(i); nNodes1=size(tree.fids,1);
  model.fids(1:nNodes1,i) = tree.fids;
  model.thrs(1:nNodes1,i) = tree.thrs;
  model.child(1:nNodes1,i) = tree.child;
  model.count(1:nNodes1,i) = tree.count;
  model.depth(1:nNodes1,i) = tree.depth;
  model.hs(1:nNodes1,i) = tree.hs;
    model.distr(1:nNodes1,i) = tree.hs;
end

end
