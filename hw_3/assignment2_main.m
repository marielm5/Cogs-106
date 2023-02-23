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

	function Multiplication = mtimes(obj,k)
            Multiplication = SignalDetection(obj.hits .* k, obj.misses .* k, obj.falseAlarms .* k, obj.correctRejections .* k);
        end

function ROC = plot_roc(obj)
            labels = [ones(obj.misses + obj.hits,1); zeros(obj.falseAlarms + obj.correctRejections,1)];
            %vector for signal observation (1) and noise (0)
            scores = [ones(obj.hits, 1); zeros(obj.misses, 1); zeros(obj.falseAlarms, 1); ones(obj.correctRejections, 1)];
            % vector for performance; positive examples(1) and negative examples (0)
            
            [FA_rate, Hit_rate] = perfcurve(labels, scores, 1); 
            ROC = plot(FA_rate, Hit_rate, 'Marker','*');
            xlabel('False Alarm');
            ylabel('Hit Rate');
            title('ROC Curve');
        end

    end
end
