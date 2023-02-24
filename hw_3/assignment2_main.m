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
	end
	    
	function  FA = FA(obj)
            % calculate false alarm rate (FA)
            FA = obj.falseAlarms/(obj.falseAlarms + obj.correctRejections);
	end
   
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
	
	function ROC = plotROC(obj)
            x = [0, obj.FA, 1];
            y = [0, obj.hit_rate, 1];
            ROC = plot( x, y, '-','Marker','*');
            title( 'ROC Curve' )
            xlabel( 'False Alarm Rate' )
            ylabel( 'Hit Rate' )
            xlim( [0, 1] )
            ylim( [0, 1] )
        end
	
	function SDT = plot_sdt(obj)
           x = linspace(-5,5,100);
           Noise = normpdf(x, 0, 1);
           Signal = (normpdf(x, obj.d_prime, 1));
           
           plot(x, Noise, 'c', 'LineWidth', 2)
           hold on
           plot(x, Signal, 'm', 'LineWidth', 2);
          
           xline(obj.d_prime/2 + obj.criterion, '--'); %threshold line C
           plot([0, obj.d_prime],[max(Noise),max(Signal)], 'k', 'LineWidth',2) % D line
           
           title('Signal Detection Theory Plot')
           xlabel('Signal Strength')
           ylabel ('Probability ')
           ylim([0,1]);
           legend({'Signal', 'Noise', 'C Threshold', 'D Line'});

        end
    end
end
