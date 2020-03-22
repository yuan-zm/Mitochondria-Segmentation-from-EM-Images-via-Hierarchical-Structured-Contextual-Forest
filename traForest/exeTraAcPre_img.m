function [proMit,resL] = exeTraAcPre_img(imgs,pros,mdl,opts)
%numImFt: num of one pic feature

opts.hrfi  = importdata([opts.haarFile int2str2(opts.iter,3) '_img.mat']);
opts.hrfp  = importdata([opts.haarFile int2str2(opts.iter,3) '_pro.mat']);

[r,c,numPic] = size(imgs);
pdsz=opts.padSize;r1= r-2*pdsz;c1 = c-2*pdsz; numPic1 = numPic - 2*pdsz;
rInd = unique([pdsz+1:2:r-pdsz,r-pdsz]);cInd = unique([pdsz+1:2:c-pdsz,c-pdsz]);
rNum = size(rInd,2);cNum = size(cInd,2);
mask = false([r,c]);mask(rInd,cInd) = 1;
[y,x]= find(mask); %z = pdsz + 1:2: numPic -pdsz;
z = unique([pdsz+1:2:numPic-pdsz,numPic-pdsz]);numRes = size(z,2);
proMit = zeros(rNum,cNum,numRes,'single');

parfor i = 1:length(z) %pdsz + 1: 2:numPic -pdsz  % here i is the img num in column
    xyz=[x y repmat(z(i),length(y),1) ]; %repmat(i,length(y),1) is z
    
    imgFt=getImgFt(imgs,xyz,opts);
    proFt = getProFt(pros,xyz,opts);
%     if( opts.useMoreContext == 1 && opts.stage == 2)
%     imgFt = imgFt(:,opts.struAppDel); proFt = proFt(:,opts.struProDel); end 
    [~,sc] = forestApply( [imgFt,proFt], mdl );sc=sc(:,end:-1:1);    
    imgFt = [];proFt = [];%#ok
    proMit(:,:,i) = reshape(sc(:,2),rNum,cNum);   

    if(mod(i,40)==0),fprintf('predict %d -->',i);end
end
[x1,y1,z1] = meshgrid(cInd-pdsz,rInd-pdsz,z-pdsz);
[x2,y2,z2] = meshgrid(1:c1,1:r1,1:numPic1);
proMit_inter = interp3(x1,y1,z1,proMit,x2,y2,z2);
proMit = padarray(proMit_inter,[pdsz,pdsz,pdsz],'symmetric');
resL  =proMit>0.5;
fprintf('----------- \n');
