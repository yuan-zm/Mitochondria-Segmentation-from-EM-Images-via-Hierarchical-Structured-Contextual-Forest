function   res = maxPoolPro(img,plsz,pdsz)
   img = img(pdsz+1:end-pdsz,pdsz+1:end-pdsz,pdsz+1:end-pdsz);

fun = @(block_struct) max(block_struct.data(:));
t1 = blockproc (img(:,:,1), [plsz plsz], fun);
res = zeros([size(t1),size(img,3)],'single');
parfor i = 1:size(img,3)
res(:,:,i) = blockproc (img(:,:,i), [plsz plsz], fun);
end
res = padarray(res,[pdsz,pdsz,pdsz],'symmetric');
