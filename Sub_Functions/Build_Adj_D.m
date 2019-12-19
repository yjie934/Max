function  A = Build_Adj_D( DIST, options )

kNN = options.kNN + 1;
N = size(DIST,1);

D = zeros(size(DIST));
W = zeros(size(DIST));

for i = 1:N

    z = DIST(:, i);
    [value index] = sort(z, 'ascend');
    D( index(1:kNN) , i) = value(1:kNN);
end
D = D+D';
Index = D~=0;
epson = sum(D(Index))/sum(Index(:));
W(Index) = exp(-D(Index)./epson); 
W = W - diag(diag(W));

if options.weight == 0
    W(find(W ~= 0)) = 1;
end


A = W;
end
