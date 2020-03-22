function lbls = getStructLabel(lab,opts,xyz)
k1 = size(xyz,1);

gtWidth=opts.gtWidth{opts.stage}; rg=floor(gtWidth/2);
lbls=zeros(gtWidth,gtWidth,gtWidth,k1,'uint8');

for j=1:k1, xy2=xyz(j,:);% xy2=xy1/shrink;
    lbls(:,:,:,j)=lab(xy2(2)-rg:xy2(2)+rg,xy2(1)-rg:xy2(1)+rg,xy2(3)-rg:xy2(3)+rg);
end