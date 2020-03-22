function [proMit,resL] = autoPredict2(imgs,pros,opts,acM)
%numImFt: num of one pic feature

[r,c,numPic] = size(imgs);
pdsz=opts.padSize;r1= r-2*pdsz;c1 = c-2*pdsz;numPic1 = numPic - 2*pdsz;

mask = true([r,c]);
mask([1:pdsz end-pdsz+1:end],:)=0; mask(:,[1:pdsz end-pdsz+1:end])=0;
mask(1:2:end,:)=0;mask(:,1:2:end)=0;

[y,x] = find(mask); z = pdsz + 1:2: numPic -pdsz;  allPro = [];
parfor i =  1:length(z) % here i is the img num in column
    xyz=[x y repmat(z(i),length(y),1) ]; %repmat(i,length(y),1) is z

    [patch ,hpatch] = getImgPatch(imgs,xyz,opts);
    imgFt = extOriFeat(patch,hpatch,opts);
    [ppatch ,phpatch] = getProPatch(pros,xyz,opts);
    proFt = extProFeat(ppatch,phpatch,opts);
    if( opts.useMoreContext == 1)
        imgFt = imgFt(:,opts.secAppDel); proFt = proFt(:,opts.secProDel);
    end
    
    [~,sc]=forestApply([imgFt,proFt],acM );sc=sc(:,end:-1:1);%pre(pre==2) = 0;
    imgFt = [];proFt = []; allPro = [allPro ;sc(:,2)];  %#ok
    if(mod(i,20)==0),fprintf('ac forest predict %d pic. \n',i);end
end
[x1,y1,z1] = meshgrid(1:2:c1,1:2:r1,1:2:numPic1);
[x2,y2,z2] = meshgrid(1:c1,1:r1,1:numPic1);
proMit = reshape(allPro,size(x1));
proMit_inter = interp3(x1,y1,z1,proMit,x2,y2,z2);
proMit_inter(:,end,:) = proMit_inter(:,end-1,:);
proMit_inter(end,:,:) = proMit_inter(end-1,:,:);

%proMit = proMit(pdsz+1:end-pdsz,pdsz+1:end-pdsz,pdsz+1:end-pdsz);
proMit = padarray(proMit_inter,[pdsz,pdsz,pdsz],'symmetric');
resL = proMit>0.5;
fprintf('---------------------------------- \n');
