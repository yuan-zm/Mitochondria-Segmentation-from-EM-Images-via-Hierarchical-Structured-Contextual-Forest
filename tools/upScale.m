function result = upScale(img,pdSz,m,n)

reImg = img(pdSz+1:end-pdSz,pdSz+1:end-pdSz,pdSz+1:end-pdSz);
m1 = m - pdSz*2; n1 = n - pdSz*2;
result = imresize(reImg,[m1,n1]);
result = padarray(result,[pdSz,pdSz,pdSz],'symmetric');

