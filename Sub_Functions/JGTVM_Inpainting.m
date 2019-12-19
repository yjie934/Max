function [Signal_Recovery_JGTVM,Iter_JGTVM]=JGTVM_Inpainting(H_J,Signal_Measure,Unmeasure,Iter_Max)

    [M N]=size(Signal_Measure);
    Signal_In_JGTVM=reshape(Signal_Measure,M*N,1);
    Unmeasure_reshape=reshape(Unmeasure,M*N,1);
    Signal_Measure_reshape=reshape(Signal_Measure,M*N,1);
    
%     Iter_Max=100000;
    
    for i_iter=1:Iter_Max
        Signal_Out_JGTVM=H_J*Signal_In_JGTVM;
        Signal_Out_JGTVM=Signal_Out_JGTVM.*Unmeasure_reshape+Signal_Measure_reshape;
        
        if(max(abs(Signal_Out_JGTVM-Signal_In_JGTVM))<1e-6)
           Iter_JGTVM=i_iter;
            break;
        end
        
        Signal_In_JGTVM=Signal_Out_JGTVM;
    end 
    
    if(i_iter==Iter_Max)
      Iter_JGTVM=i_iter;    
    end

    Signal_Recovery_JGTVM=reshape(Signal_Out_JGTVM,M,N);       

end