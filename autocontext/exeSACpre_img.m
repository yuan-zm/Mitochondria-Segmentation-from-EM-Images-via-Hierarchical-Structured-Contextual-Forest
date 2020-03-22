function [proMit,resL] = exeSACpre_img(imgs,pros,mdl,opts,varargin)
%numImFt: num of one pic feature

opts.hrfi  = importdata([opts.haarFile int2str2(opts.iter,3) '_img.mat']);
opts.hrfp  = importdata([opts.haarFile int2str2(opts.iter,3) '_pro.mat']);


[r,c,numPic] = size(imgs);
pdsz=opts.padSize;r1= r-2*pdsz;c1 = c-2*pdsz; numPic1 = numPic - 2*pdsz;
rInd = unique([pdsz+1:2:r-pdsz,r-pdsz]);cInd = unique([pdsz+1:2:c-pdsz,c-pdsz]);
rNum = size(rInd,2); cNum = size(cInd,2);
mask = false([r,c]);mask(rInd,cInd) = 1;
[y,x]= find(mask); %z = pdsz + 1:2: numPic -pdsz;
z = unique([pdsz+1:2:numPic-pdsz,numPic-pdsz]);numRes = size(z,2);

%z = unique([z ,pdsz + 1,numPic - pdsz]);
gtRidus = floor(opts.gtWidth{opts.stage}/ 2);
allPre = cell(length(z),1);
parfor i = 1:length(z) %pdsz + 1: 2:numPic -pdsz  % here i is the img num in column
    xyz=[x y repmat(z(i),length(y),1) ]; %repmat(i,length(y),1) is z
    
    imgFt=getImgFt(imgs,xyz,opts);
    proFt = getProFt(pros,xyz,opts);

    [pre,~] = forestApply([imgFt,proFt], mdl );
    allPre{i}=pre;
    imgFt = []; proFt = [];%#ok
    if(mod(i-pdsz,20)==0),fprintf('fst forest predict %d pic. \n',i);end
end

% initial a cubic for add segment result
% pay more amlctttention to z!!!  easy to make mistake
volumeRes = zeros(size(pros));volumeCount = zeros(size(pros));
count = ones([opts.gtWidth{opts.stage},opts.gtWidth{opts.stage},opts.gtWidth{opts.stage}],'single');


for j = 1: length(z)
    % get one layer result ,this result is for overlap
    tr=precessSingleLayer(allPre{j},opts); %
    %np : num of points
    for np = 1:length(y)
        volumeRes(y(np)-gtRidus:y(np)+gtRidus,...
            x(np)-gtRidus:x(np)+gtRidus, ...
            z(j)-gtRidus:z(j)+gtRidus) =...
            volumeRes(y(np)-gtRidus:y(np)+gtRidus, ...
            x(np)-gtRidus:x(np)+gtRidus,...
            z(j)-gtRidus:z(j)+gtRidus )...
            + tr(:,:,:,np);
        
        volumeCount(y(np)-gtRidus:y(np)+gtRidus,...
            x(np)-gtRidus:x(np)+gtRidus, ...
            z(j)-gtRidus:z(j)+gtRidus) =...
            volumeCount(y(np)-gtRidus:y(np)+gtRidus, ...
            x(np)-gtRidus:x(np)+gtRidus,...
            z(j)-gtRidus:z(j)+gtRidus )...
            + count(:,:,:);
    end
end
imgSz.r = r1;imgSz.c = c1;
imgSz.numPic1 = numPic1;
volumeRes = volumeRes./volumeCount; clear volumeCount count
proMit = processVolume(volumeRes,pdsz,imgSz,gtRidus);

proMit = padarray(proMit,[pdsz,pdsz,pdsz],'symmetric');
resL  =proMit>0.5;
fprintf('---------------------------------- \n');
