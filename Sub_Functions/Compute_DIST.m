function DIST=Compute_DIST(Coords)
         N=size(Coords,1);
         DIST=zeros(N);
         for i=1:N
             for j=i+1:N
                 DIST(i,j)=distance(Coords(i,2),Coords(i,1),Coords(j,2),Coords(j,1));
                 DIST(j,i)=DIST(i,j);
             end
         end
end