
function [hs,segs] = discretize( segs, nClasses, nSamples, type )
% % Convert a set of segmentations into a set of labels in [1,nClasses].
% persistent cache; w=size(segs{1},1); assert(size(segs{1},2)==w);
% 
% if(~isempty(cache) && cache{1}==w), [~,is1,is2]=deal(cache{:}); else
%   % compute all possible lookup inds for w x w patches
%   is=1:w^6; is1=floor((is-1)/w/w/w); is2=is-is1*w*w*w; is1=is1+1;
%   kp=is2>is1; is1=is1(kp); is2=is2(kp); cache={w,is1,is2};
% end

w=size(segs{1},1); assert(size(segs{1},2)==w);
%get label
%center = ceil(w^3 / 2);
hs = cell2array(segs);hs = reshape(hs,[],size(hs,4))';
%hs = label(:,center)==label;

% is=1:w^6; is1=floor((is-1)/w/w/w); is2=is-is1*w*w*w; is1=is1+1;
% kp=is2>is1; is1=is1(kp); is2=is2(kp); 

 
% calculate label probability 
ltp = single(hs); ltp(ltp==2) = 0; 
lpp = sum(ltp,1)/ size(hs,1); 

%ltn = ~ltp; 
lpn = 1 - lpp;

alp = ltp.*lpp; aln =( ~ltp ).*lpn;
al = [alp,aln];al(al==0) = NaN;
P = prod(al,2,'omitnan');
[~,maxind] = max(P);
 segs=segs{maxind};
 
% tt1 = ltp.* lhp; tt2 = ltn.*lhn;
% tt = [tt1,tt2];
% for i=1:size(tt,1)
%     tpp = tt(tt~=0);
% 
% 
% 
% % compute n binary codes zs of length nSamples
% nSamples=min(nSamples,length(is1)); kp=randperm(length(is1),nSamples);
% n=length(segs); is1=is1(kp); is2=is2(kp); zs=false(n,nSamples);
% for i=1:n, zs(i,:)=segs{i}(is1)==segs{i}(is2); end
% 
% zs=bsxfun(@minus,zs,sum(zs,1)/n); zs=zs(:,any(zs,1));
% if(isempty(zs)), hs=ones(n,1,'uint32'); segs=segs{1}; return; end
% % find most representative segs (closest to mean)
% [~,ind]=min(sum(zs.*zs,2)); segs=segs{ind};
% end