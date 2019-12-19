clc;
clear;

rng('default');

addpath('.\Data');
addpath('.\Sub_Functions');

load('Sea_Temperature.mat');

Pick_Time=5;
Unmeasure_Rate=0.5;

Signal_Oral=Signal(:,(Pick_Time-4):Pick_Time);
[M,N]=size(Signal_Oral);
DIST=Compute_DIST(Coords);
 
Measure=zeros(M,N);
Unmeasure=zeros(M,N);

for i_Set_Unmeaure=1:size(Signal_Oral,2)
    [Measure(:,i_Set_Unmeaure),Unmeasure(:,i_Set_Unmeaure)]=crossvalind('LeaveMOut',size(Signal_Oral,1),round(Unmeasure_Rate*size(Signal_Oral,1)));
end
Signal_Measure=Measure.*Signal_Oral;

%%%%%%%Build Graph Model of Topology Structure%%%%%%%%%%
OPTS_Graph.kNN = 5;      %Need to Design%
OPTS_Graph.weight = 1;
OPTS_Graph.distance = 'euclidean';
[A_G] = Build_Adj_D( DIST, OPTS_Graph );

W_G = diag( 1./ sum( A_G, 1) )*A_G;
I_G=eye(size(W_G,1));
Wt_G=(I_G-W_G)'*(I_G-W_G);
alpha_GTVM=1/abs(max(eig(Wt_G)));
H_G=I_G-alpha_GTVM*Wt_G;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Fix the Bug of No Time-varying learning information%
if(sum(all(Measure==1,2))==0)
    Measure_Total=sum(Measure,2);
    Measure_Fix_Index=find(Measure_Total==max(Measure_Total));
    Measure_Fix=Measure_Fix_Index(randi(size(Measure_Fix_Index,1)));
    Signal_Measure(Measure_Fix,:)=Signal_Oral(Measure_Fix,:);
    Measure(Measure_Fix,:)=ones(1,N);
    Unmeasure(Measure_Fix,:)=zeros(1,N);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%Build Graph Model of Time Varying%%%%%%%%%%%%%%%
A_T=[0 1 0 0 0;1 0 1 0 0;0 1 0 1 0;0 0 1 0 1;0 0 0 1 0]; %Line Graph Model%
Measure_Node=find(all(Measure==1,2));
Signal_Measure_Nodes=Signal_Measure(Measure_Node,:);
if(size(Signal_Measure_Nodes,1)~=1)
    Signal_Measure_Nodes=mean(Signal_Measure_Nodes);
end
W_T=zeros(size(A_T));
for i=1:4
    W_T(i,i+1)=Signal_Measure_Nodes(1,i+1)/Signal_Measure_Nodes(1,i);
end
W_T=W_T+W_T';
I_T=eye(size(W_T,1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%------------- Joint Graph Model ---------%%%%%%%%%%%%%%%%%%%%%
W_J=kron(W_T,A_G)+kron(W_T,I_G)+kron(I_T,A_G);
W_J=diag( 1./ sum( W_J, 1) )*W_J;
I_J=eye(size(W_J,1));
Wt_J=(I_J-W_J)'*(I_J-W_J);
alpha_JGTVM=1/abs((max(eig(Wt_J))));
H_J=I_J-alpha_JGTVM*Wt_J;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Iter_Max=100000;

%%%%%%% GTVM %%%%%%%%%%%%%%%%%%%%%%%%%
[Signal_Recovery_GTVM,Iter_GTVM]=GTVM_Inpainting(H_G,Signal_Measure,Unmeasure,Iter_Max);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%% JGTVM %%%%%%%%%%%%%%%%%%%%%%%%%
[Signal_Recovery_JGTVM,Iter_JGTVM]=JGTVM_Inpainting(H_J,Signal_Measure,Unmeasure,Iter_Max);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%Performance Evaluation%%%%%%%%%%%%%%%%%%%%%%%%%
RMSE_JGTVM=norm(reshape((Signal_Recovery_JGTVM-Signal_Oral),M*N,1))/sqrt(M*N);
RMSE_GTVM=norm(reshape((Signal_Recovery_GTVM-Signal_Oral),M*N,1))/sqrt(M*N);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Final_Result(1,1)=Unmeasure_Rate;
Final_Result(1,2)=RMSE_JGTVM;
Final_Result(1,3)=RMSE_GTVM;
Final_Result(1,4)=Iter_JGTVM;
Final_Result(1,5)=Iter_GTVM;

disp(Final_Result);