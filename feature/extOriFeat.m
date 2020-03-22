function  ft = extOriFeat(patch,hpatch,opts)

% 6 is the standard ft number
ft = zeros([size(patch,5),6 * size(patch,4)],'single');
for i = 1:size(patch,4) % patch is a 4-D matrix
    ft(:,6 * (i -1) +1: 6 * i) =  standFt(squeeze(patch(:,:,:,i,:)));
end
clear patch

if(opts.stage==1),haarStage=opts.hrfi;else,haarStage = opts.hrsi;end

[haarCtRd , allHaarLbp, haarRand,hmv ] = getHaarFt(hpatch,haarStage);
ft = [ft,haarCtRd , allHaarLbp, haarRand,hmv];%, allHaarLbp, haarRand ];,hmv
ft = single(ft);
end
