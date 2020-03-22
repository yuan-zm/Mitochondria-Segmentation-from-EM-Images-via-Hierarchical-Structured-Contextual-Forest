function [patch ,hpatch,lbls] = getImgPatch(img,xyz,opts,varargin)

stg = opts.stage;
ihps=opts.ihs{stg};hri = floor(ihps / 2);
ips = opts.patchSize{stg};ri = floor(ips / 2);

k1 = size(xyz,1);
if(nargin>3)
    lab = varargin{1};gtWidth=opts.gtWidth{opts.stage}; rg=floor(gtWidth/2);
    lbls=zeros(gtWidth,gtWidth,gtWidth,k1,'uint8');
end

imgChn = getChannel(img);
patch = zeros([ips,ips,ips,size(imgChn,4),k1],'single');
hpatch = zeros([ihps,ihps,ihps,k1],'single');
for j=1:k1, xy2=xyz(j,:);% xy2=xy1/shrink;
    patch(:,:,:,:,j)=imgChn(xy2(2)-ri:xy2(2)+ri,xy2(1)-ri:xy2(1)+ri,xy2(3)-ri:xy2(3)+ri,:);
    hpatch(:,:,:,j)=img(xy2(2)-hri:xy2(2)+hri,xy2(1)-hri:xy2(1)+hri,xy2(3)-hri:xy2(3)+hri);
    if(nargin>3)
        lbls(:,:,:,j)=lab(xy2(2)-rg:xy2(2)+rg,xy2(1)-rg:xy2(1)+rg,xy2(3)-rg:xy2(3)+rg);
    end
end


%patch sz*sz*sz nsample channel