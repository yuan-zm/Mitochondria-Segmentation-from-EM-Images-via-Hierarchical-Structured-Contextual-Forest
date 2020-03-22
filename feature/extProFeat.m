function  ft = extProFeat(patch,hpatch,opts)
%ft = [];
ft = standFt(patch);

if(opts.stage==1),haarStage=opts.hrfp;else,haarStage = opts.hrsp;end
[haarCtRd , allHaarLbp, haarRand,hmv ] = getHaarFt(hpatch,haarStage);
ft = [ft,haarCtRd , allHaarLbp, haarRand,hmv];%, allHaarLbp, haarRand ];,hmv

% ac ft
% auto_maps = AutoContextFeatures(M,opts.offset{1});
% auto_maps = auto_maps(:,:,opts.ranPoints{1});
% acFt = reshape(auto_maps,[],size(auto_maps,3));
% acFt = acFt(ind,:);
% ft = [ft,acFt];
ft = single(ft);
