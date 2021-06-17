awk ' {if(/BENCHMARK/) 
       { print "#" $0} 
       else 
         {print $0}
       } ' *.sh
