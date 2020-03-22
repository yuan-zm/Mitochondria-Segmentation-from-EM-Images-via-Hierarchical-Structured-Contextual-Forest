function [proMit,resL] = oriPredict(imgs,mdl,opts)
%numImFt: num of one pic feature
[r,c,numPic] = size(imgs);
pdsz=opts.padSize;r1= r-2*pdsz;c1 = c-2*pdsz; numPic1 = numPic - 2*pdsz;

% mask = false([r,c]);
% mask([pdsz+1:2:end-pdsz],[pdsz+1:2:end-pdsz],:)=1;
% mask(:,)=1;

mask = true([r,c]);
mask([1:pdsz end-pdsz+1:end],:)=0; mask(:,[1:pdsz end-pdsz+1:end])=0;
mask(pdsz:2:end,:)=0;mask(:,pdsz:2:end)=0;
[y,x]= find(mask);   z = pdsz + 1:2: numPic -pdsz;
%z = unique([z ,pdsz + 1,numPic - pdsz]);
gtRidus = floor(opts.gtWidth{opts.stage} / 2);
allPre = cell(length(z),1);

parfor i = 1:length(z) % here i is the img num in column
    xyz=[x y repmat(z(i),length(y),1) ]; 
    [patch ,hpatch] = getImgPatch(imgs,xyz,opts);
    ft = extOriFeat(patch,hpatch,opts);
    [pre,~] = forestApply( ft, mdl );
    %[pre,sc] = forestApply( ft, mdl );
    allPre{i}=pre; imgFt = [];%#ok
    if(mod(i,20)==0),fprintf('fst forest predict %d pic. \n',i);end
end
% initial a cubic for add segment result 
% pay more attention to z!!!  easy to make mistake

vp =floor(opts.gtWidth{opts.stage} / 2) *2; % volume pad size
volumeRes = zeros([size(mask),length(z)*2+vp]);z = z - pdsz+2+1;

count = ones([opts.gtWidth{opts.stage},opts.gtWidth{opts.stage},opts.gtWidth{opts.stage}],'single');
volumeCount = zeros([size(mask),length(z)*2+vp]);

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
imgSz.r = r1;imgSz.c = c1;imgSz.numPic1 = numPic1;

volumeRes = volumeRes./volumeCount; clear volumeCount count
proMit = processVolume(volumeRes,pdsz,imgSz,gtRidus);

proMit = padarray(proMit,[pdsz,pdsz,pdsz],'symmetric');
resL  =proMit>0.5;
fprintf('---------------------------------- \n');