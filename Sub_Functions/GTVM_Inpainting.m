function [Signal_Recovery_GTVM,Iter_GTVM]=GTVM_Inpainting(H_G,Signal_Measure,Unmeasure,Iter_Max)

Signal_In_GTVM=Signal_Measure;
% Iter_Max=100000;

for i_iter=1:Iter_Max
    Signal_Out_GTVM=H_G*Signal_In_GTVM;
    Signal_Out_GTVM=Signal_Out_GTVM.*Unmeasure+Signal_Measure;
    
    if(max(abs(Signal_Out_GTVM-Signal_In_GTVM))<1e-6)
        Iter_GTVM=i_iter;
        break;
    end
    
    Signal_In_GTVM=Signal_Out_GTVM;
    
end

if(i_iter==Iter_Max)
Iter_GTVM=i_iter;    
end

Signal_Recovery_GTVM=Signal_Out_GTVM;

end