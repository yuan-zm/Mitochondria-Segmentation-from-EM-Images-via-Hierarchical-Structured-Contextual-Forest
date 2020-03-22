function fisherInd =  getFisherInd(ft,lab,ratio)

fshierSc2 = fsFisher(ft,lab);
sc2 = fshierSc2.W;
sc2(isnan(sc2)) = 0;
[~,ind] = sort(sc2,'descend');
ftNum = round(size(ind,2) * ratio);
fisherInd = ind(:,1:ftNum);

end