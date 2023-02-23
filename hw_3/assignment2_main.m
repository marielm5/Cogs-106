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
   
        function d_prime = d_prime(obj)
            hitRate = obj.hits / (obj.hits + obj.misses);
            falseAlarmRate = obj.falseAlarms / (obj.falseAlarms + obj.correctRejections);
            d_prime = (norminv(hitRate) - norminv(falseAlarmRate));
        end

        function criterion = criterion(obj)
            hitRate = obj.hits / (obj.hits + obj.misses);
            falseAlarmRate = obj.falseAlarms / (obj.falseAlarms + obj.correctRejections);
            criterion = -0.5 * (norminv(hitRate) + norminv(falseAlarmRate));
        end
    end
end
