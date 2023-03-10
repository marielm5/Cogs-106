classdef SignalDetection
    %  Implements four core Signal Detection Theory formulas: Hit Rate, False Alarm Rate, d-prime, and Criterion.

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

        function FA = FA(obj)
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

        function ROC = oldplotROC(obj)
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

%% New Assignmnet 4 Methods

        function ell = nLogLikelihood(obj, hitRate, falseAlarmRate)
            ell = - (obj.hits * log(hitRate) + obj.misses * log(1 - hitRate) ...
                + obj.falseAlarms * log(falseAlarmRate) ...
                + obj.correctRejections * log(1 - falseAlarmRate));
        end
    end

    methods (Static)
        function sdtList = simulate(dprime, criteriaList, signalCount, noiseCount)
            sdtList = [];
            for i = 1:length(criteriaList)
                k = criteriaList(i) + (dprime / 2);
                hit_r = 1 - (normcdf(k - dprime));
                fa_r = 1 - (normcdf(k));

                hits = binornd(signalCount, hit_r);
                misses = signalCount - hits;
                falseAlarms = binornd(noiseCount, fa_r);
                correctRejections = noiseCount - falseAlarms;
                sdtList = [sdtList; SignalDetection(hits, misses, falseAlarms, correctRejections)];
            end
        end

        function hitRate = rocCurve(falseAlarmRate, a)
            hitRate = [];
            for i = 1:length(falseAlarmRate)
                hitRate = normcdf(a + norminv(falseAlarmRate));
            end
        end

        function rocLoss = rocLoss(a, sdtList)
            ell = [];
            for i = 1:length(sdtList)
                obs_FARate = FA(sdtList(i));
                pre_HitRate = SignalDetection.rocCurve(obs_FARate,a);
                ell =  [ell; nLogLikelihood(sdtList(i), pre_HitRate, obs_FARate)];
            end
            rocLoss = sum(ell);
        end

        function plotroc = plot_roc(sdtList)
            hold on;
            for i = 1:length(sdtList)
                x = sdtList(i).FA();
                y = sdtList(i).hit_rate();
                scatter(x, y, 'filled', 'MarkerFaceColor','k' );
            end
            line([0, 1], [0, 1],'LineStyle', '--');
            grid on
            hold off;

            title( 'ROC Curve' )
            xlabel('False Alarm Rate');
            ylabel('Hit Rate');
            xlim([0, 1]);
            ylim([0, 1]);
        end

        function fit_a = fit_roc(sdtList)
            a_func = @(a)(SignalDetection.rocLoss(a, sdtList));
            start = 0;
            fit_a= fminsearch(a_func, start);

            SignalDetection.plot_roc(sdtList);
            hold on;
            x = linspace(0, 1);
            y = SignalDetection.rocCurve(x, fit_a);
            plot(x, y, 'LineWidth', 2);
            hold off;

        end
    end
end
