function [proMit,resL] = exeTraAcPre(imgs,pros,mdl,opts)
%numImFt: num of one pic feature
[r,c,numPic] = size(imgs);
pdsz=opts.padSize;r1= r-2*pdsz;c1 = c-2*pdsz; numPic1 = numPic - 2*pdsz;

mask = true([r,c]);
mask([1:pdsz end-pdsz+1:end],:)=0; mask(:,[1:pdsz end-pdsz+1:end])=0;
mask(1:2:end,:)=0;mask(:,1:2:end)=0;
[y,x] = find(mask);z =  pdsz + 1: 2 :numPic - pdsz ;

proMit = zeros(r1/2,c1/2,length(z),'single');

parfor i = 1:length(z) %pdsz + 1: 2:numPic -pdsz  % here i is the img num in column
    xyz=[x y repmat(z(i),length(y),1) ]; %repmat(i,length(y),1) is z
    
%     [patch ,hpatch] = getImgPatch(imgs,xyz,opts);
%     imgFt = extOriFeat(patch,hpatch,opts);patch=[];hpatch=[];
    [ppatch ,phpatch] = getProPatch(pros,xyz,opts);
    proFt = extProFeat(ppatch,phpatch,opts);ppatch=[];phpatch=[];
%     if( opts.useMoreContext == 1 && opts.stage == 2)
%     imgFt = imgFt(:,opts.struAppDel); proFt = proFt(:,opts.struProDel); end 
    [~,sc] = forestApply( proFt, mdl );sc=sc(:,end:-1:1);    
    imgFt = [];proFt = [];%#ok
    proMit(:,:,i) = reshape(sc(:,2),r1/2,c1/2); 

    if(mod(i,40)==0),fprintf('predict %d -->',i);end
end
[x1,y1,z1] = meshgrid(1:2:c1,1:2:r1,1:2:numPic1);
[x2,y2,z2] = meshgrid(1:c1,1:r1,1:numPic1);
proMit_inter = interp3(x1,y1,z1,proMit,x2,y2,z2);
proMit_inter(:,end,:) = proMit_inter(:,end-1,:);
proMit_inter(end,:,:) = proMit_inter(end-1,:,:);

%proMit = proMit(pdsz+1:end-pdsz,pdsz+1:end-pdsz,pdsz+1:end-pdsz);
proMit = padarray(proMit_inter,[pdsz,pdsz,pdsz],'symmetric');
resL  =proMit>0.5;
fprintf('----------- \n');
