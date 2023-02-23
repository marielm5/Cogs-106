classdef SignalDetection
    properties
        hits
        misses
        falseAlarms
        correctRejections
    end

    methods
        function obj = SignalDetection(hits, misses, falseAlarms, correctRejections)
            obj.hits = hits;
            obj.misses = misses;
            obj.falseAlarms = falseAlarms;
            obj.correctRejections = correctRejections; 
        end
	
	function H = hit_rate(obj)
            % calculate hit rate (H)
            H = obj.hits/(obj.hits + obj.misses);

	function  FA = FA(obj)
            % calculate false alarm rate (FA)
            FA = obj.falseAlarms/(obj.falseAlarms + obj.correctRejections);
   
        function d_prime = d_prime(obj)
           % calculate d-prime
            d_prime =  norminv(hit_rate(obj)) - norminv(obj.FA());
        end

        function C = criterion(obj)
            % calculate criterion (C)
          C =  -0.5 *(norminv(obj.hit_rate()) + norminv(obj.FA()));
        end

	function Addition = plus (obj1,obj2)
            Addition = SignalDetection(obj1.hits + obj2.hits, obj1.misses + obj2.misses, obj1.falseAlarms + obj2.falseAlarms, obj1.correctRejections +obj2.correctRejections);
        end



    end
end
