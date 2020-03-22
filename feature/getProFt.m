function ft = getProFt(img,xyz,opts)

stg = opts.stage;
ihps=opts.phs{stg};hri = floor(ihps / 2);
ips = opts.acPatchS{stg};ri = floor(ips / 2);

k1 = size(xyz,1);
patch = zeros([ips,ips,ips,k1],'single');
hpatch = zeros([ihps,ihps,ihps,k1],'single');
for j=1:k1, xy2=xyz(j,:);% xy2=xy1/shrink;
    patch(:,:,:,j)  =img(xy2(2)-ri:xy2(2)+ri,xy2(1)-ri:xy2(1)+ri,xy2(3)-ri:xy2(3)+ri);
    hpatch(:,:,:,j) =img(xy2(2)-hri:xy2(2)+hri,xy2(1)-hri:xy2(1)+hri,xy2(3)-hri:xy2(3)+hri);
    % lbls=cat(3,lbls,M(xy2(2)-rg:xy2(2)+rg,xy2(1)-rg:xy2(1)+rg));
end

ft = standFt(patch);

if(opts.stage==1),haarStage=opts.hrfp;else,haarStage = opts.hrsp;end
[haarCtRd , allHaarLbp, haarRand,hmv ] = getHaarFt(hpatch,haarStage);
ft = [ft,haarCtRd , allHaarLbp, haarRand,hmv];%, allHaarLbp, haarRand ];,hmv

