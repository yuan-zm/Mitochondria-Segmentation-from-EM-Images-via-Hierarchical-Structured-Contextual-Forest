function show_saveImg(data,fig,num,subNum,l_i,opts)
%data: dataset
%fig: figure number
%num: which image to show
%subNum: subplot number
%l_i: whether show img and label
if(l_i == 1)
    figure(fig),subplot(531),imshow(data.img(:,:,num),[]),title('img');
    subplot(532),imshow(data.lab(:,:,num)),title('label'); pause(0.0001);
end
eval = evalute_segment_performance(data.lab(:),data.pro(:)>0.5);
fprintf('mean voc is %f in no ac \n',eval.voc);

figure(fig),subplot(5,3,subNum),imshow(data.pro(:,:,num)),title(['voc ' num2str(eval.voc)]);
pause(0.0001);

if(opts.saveStagePro == 1)
if(opts.train==1 )
    pfn = ['./proData/dirtTra_',num2str(subNum - 2),'.mat'];
    if(~exist('./proData','dir')), mkdir('./proData'); end
    proMit = data.pro; save(pfn,'proMit');
else
    pfn = ['./proData/dirtTest_',num2str(subNum - 2),'.mat'];
    if(~exist('./proData','dir')), mkdir('./proData'); end
    proMit = data.pro; save(pfn,'proMit');
end

end