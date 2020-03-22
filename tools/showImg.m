function showImg(data,fig,num,subNum,l_i)
%data: dataset
%fig: figure number
%num: which image to show
%subNum: subplot number
%l_i: whether show img and label
if(l_i == 1)
    figure(fig),subplot(331),imshow(data.img(:,:,num),[]),title('img');
    subplot(332),imshow(data.lab(:,:,num)),title('label'); pause(0.0001);
end
eval = evalute_segment_performance(data.lab(:),data.pro(:)>0.5);
fprintf('mean voc is %f in no ac \n',eval.voc);

figure(fig),subplot(3,3,subNum),imshow(data.pro(:,:,num)),title(['voc ' num2str(eval.voc)]);
pause(0.0001);

