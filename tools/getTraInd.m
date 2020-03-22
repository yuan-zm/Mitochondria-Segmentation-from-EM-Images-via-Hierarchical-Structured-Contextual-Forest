function xy = getTraInd(data,opts)
%%
%this function is to choose the sample index  from data 
%
%
%%
xy = [];
%nPos=opts.nPos; nNeg=opts.nNeg;
shrink=opts.stride;pdsz=opts.padSize;shrink2 = opts.stride2;
[r,c,numPic] = size(data.lab);ii = find(bwdist(data.lab)== 1);
B=false(r,c,numPic);start = opts.start ;
B(ii(1:5:end)) = 1;
B(start:shrink:end,start:shrink:end,start:shrink:end)=1;
B([1:pdsz end-pdsz+1:end],:,:)=0; B(:,[1:pdsz end-pdsz+1:end],:)=0;
B(:,:,[1:pdsz end-pdsz+1:end])=0;
M = data.lab;M(bwdist(M) < 4) = 1;
% get pos samples
ind=find(M.*B); [y,x,z] = ind2sub(size(data.lab),ind);
% k2=min(length(y),ceil(nPos/nImgs));
% rp=randperm(length(y),k2); 
% y=y(rp); x=x(rp);
xy=[xy; x y z ]; posNum = length(y);negNum =round( posNum * opts.negRatio);
B=false(r,c,numPic);
B(start:shrink2:end,start:shrink2:end,start:shrink2:end)=1;
B([1:pdsz end-pdsz+1:end],:,:)=0; B(:,[1:pdsz end-pdsz+1:end],:)=0;
B(:,:,[1:pdsz end-pdsz+1:end])=0;

ind=find(~M.*B); [y,x,z] = ind2sub(size(data.lab),ind);
k2=min(length(y),negNum);
rp=randperm(length(y),k2); y=y(rp); x=x(rp); z=z(rp);
xy=[xy; x y z]; 

