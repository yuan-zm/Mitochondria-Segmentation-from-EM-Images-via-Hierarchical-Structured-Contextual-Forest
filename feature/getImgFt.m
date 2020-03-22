function ft=getImgFt(img,xyz,opts)

stg = opts.stage;k1 = size(xyz,1);
ihps=opts.ihs{stg};hri = floor(ihps / 2);
ips = opts.patchSize{stg};ri = floor(ips / 2);

% patch for stand ft
imgChn = getChannel(img);
ft = zeros([k1,6 * size(imgChn,4)],'single');
for chn = 1: size(imgChn,4) % chanenl number
    patch = zeros([ips,ips,ips,k1],'single');
    % get every patch
    for j=1:k1, xy2=xyz(j,:);% xy2=xy1/shrink;
        patch(:,:,:,j)=imgChn(xy2(2)-ri:xy2(2)+ri,xy2(1)-ri:xy2(1)+ri,xy2(3)-ri:xy2(3)+ri,chn);
    end
    % extract stand ft
    ft(:,6 * (chn -1) +1: 6 * chn) =  standFt(patch);
end
%gradientImg = imgChn(:,:,:,end);

clear patch imgChn

% patch for haar ft
hpatch = zeros([ihps,ihps,ihps,k1],'single');
for j=1:k1, xy2=xyz(j,:);% xy2=xy1/shrink;
    hpatch(:,:,:,j)=img(xy2(2)-hri:xy2(2)+hri,xy2(1)-hri:xy2(1)+hri,xy2(3)-hri:xy2(3)+hri);
end

if(opts.stage==1),haarStage=opts.hrfi;else,haarStage = opts.hrsi;end
[haarCtRd , allHaarLbp, haarRand,hmv ] = getHaarFt(hpatch,haarStage);
ft = [ft,haarCtRd , allHaarLbp, haarRand,hmv];%, allHaarLbp, haarRand ];,hmv

%clear hpatch
% 
% grahpatch = zeros([ihps,ihps,ihps,k1],'single');
% for j=1:k1, xy2=xyz(j,:);% xy2=xy1/shrink;
%     grahpatch(:,:,:,j)=gradientImg(xy2(2)-hri:xy2(2)+hri,xy2(1)-hri:xy2(1)+hri,xy2(3)-hri:xy2(3)+hri);
% end
% 
% if(opts.stage==1),haarStage=opts.hrfi;else,haarStage = opts.hrsi;end
% [haarCtRd,allHaarLbp,haarRand,hmv] = getHaarFt(grahpatch,haarStage);
% ft = [ft,haarCtRd,hmv];


ft = single(ft);


