function   res = maxPoolData(data,plsz,pdsz)
fun = @(block_struct) max(block_struct.data(:));

data.pro = data.pro(pdsz+1:end-pdsz,pdsz+1:end-pdsz,pdsz+1:end-pdsz);
data.lab = data.lab(pdsz+1:end-pdsz,pdsz+1:end-pdsz,pdsz+1:end-pdsz);
data.img = data.img(pdsz+1:end-pdsz,pdsz+1:end-pdsz,pdsz+1:end-pdsz);

t1 = blockproc (data.img(:,:,1), [plsz plsz], fun);
res.img = zeros([size(t1),size(data.img,3)],'single');
res.pro = zeros([size(t1),size(data.img,3)],'single');

for i = 1:size(data.img,3)
res.img(:,:,i) = blockproc (data.img(:,:,i), [plsz plsz], fun);
res.pro(:,:,i) = blockproc (data.pro(:,:,i), [plsz plsz], fun);
end
res.lab = imresize(data.lab,0.5);

res.img  = padarray(res.img ,[pdsz,pdsz,pdsz],'symmetric');
res.pro  = padarray(res.pro ,[pdsz,pdsz,pdsz],'symmetric');
res.lab  = padarray(res.lab ,[pdsz,pdsz,pdsz],'symmetric');