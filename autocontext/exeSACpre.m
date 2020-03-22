function [proMit,resL] = exeSACpre(imgs,pros,mdl,opts,varargin)
dirt=0; dirtPro=[];% tag of direct existance
if(nargin>4),dirtPro = varargin{1}; dirt = 1;end

%numImFt: num of one pic feature
[r,c,numPic] = size(imgs);
pdsz=opts.padSize;r1= r-2*pdsz;c1 = c-2*pdsz; numPic1 = numPic - 2*pdsz;

mask = true([r,c]);
mask([1:pdsz end-pdsz+1:end],:)=0; mask(:,[1:pdsz end-pdsz+1:end])=0;
mask(1:2:end,:)=0;mask(:,1:2:end)=0;
gtRidus = floor(opts.gtWidth{opts.stage}/ 2);
[y,x] = find(mask); z =  pdsz + 1: 2 :numPic - pdsz ;
%z = unique([z ,pdsz + 1,numPic - pdsz]);

% length(z)+4 because we should let the volume top and down plus 2 when the label cubic is 5*5*5
%tr = zeros([opts.preRidues,opts.preRidues,opts.preRidues,length(y),3]);
allPre = cell(length(z),1);
for i = 1:length(z) %pdsz + 1: 2:numPic -pdsz  % here i is the img num in column
    xyz=[x y repmat(z(i),length(y),1) ]; %repmat(i,length(y),1) is z
    
    %     [patch ,hpatch] = getImgPatch(imgs,xyz,opts);
    %     imgFt = extOriFeat(patch,hpatch,opts);patch=[];hpatch=[];
    [ppatch ,phpatch] = getProPatch(pros,xyz,opts);
    proFt = extProFeat(ppatch,phpatch,opts);ppatch=[];phpatch=[];
    
    
    if(dirt==1)
        [ppatch ,phpatch] = getProPatch(dirtPro,xyz,opts);
        dirtproFt = extProFeat(ppatch,phpatch,opts);ppatch=[];phpatch=[];
    end
    
    if( opts.useMoreContext == 1 && opts.stage == 2)
        % imgFt = imgFt(:,opts.finalAppDel);
        proFt = proFt(:,opts.finalProDel); 
    end
    if(dirt==1),allFt = [proFt,dirtproFt]; proFt= []; dirtproFt = [];
    else,       allFt = proFt; proFt= [];    end

    [pre,~] = forestApply(allFt, mdl );
    allPre{i}=pre;
    imgFt = []; proFt = [];%#ok
    if(mod(i-pdsz,20)==0),fprintf('fst forest predict %d pic. \n',i);end
end

% initial a cubic for add segment result
% pay more amlctttention to z!!!  easy to make mistake
vp =floor(opts.gtWidth{opts.stage} / 2) *2; % volume pad size
if(mod(numPic,2)==0),llayer=length(z)*2+vp;else,llayer=length(z)*2+vp-1;end

volumeRes = zeros([size(mask),llayer]);z = z - pdsz+2+1;

count = ones([opts.gtWidth{opts.stage},opts.gtWidth{opts.stage},opts.gtWidth{opts.stage}],'single');
volumeCount = zeros([size(mask),llayer]);
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
