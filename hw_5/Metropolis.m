classdef Metropolis

    properties
        samples
        logTarget
        initialState
        sigma_steps
    end

    methods
        function self = Metropolis(logTarget, initialState)
            self.logTarget = logTarget;
            self.initialState = initialState;
            self.sigma_steps = 1;
        end

        function self = adapt(self, blockLengths)
            for i = 1:length(blockLengths)
                for j = 1:blockLengths(i)
                    proposal = self.initialState + self.sigma_steps * randn();
                    if self.accept(proposal)
                        self.initialState = proposal;
                    end
                end

                acceptanceRate = sum(self.samples == self.initialState) / length(self.samples);
                if acceptanceRate > 0.5
                    self.sigma_steps = self.sigma_steps * 1.1;
                else
                    self.sigma_steps = self.sigma_steps * 0.9;
                end
            end
        end

        function self = sample(self, n)
            self.samples = zeros(1, n);
            for i = 1:n
                proposal = self.initialState + self.sigma_steps * randn();
                if self.accept(proposal)
                    self.initialState = proposal;
                end
                self.samples(i) = self.initialState;
            end
        end

        function summ = summary(self)
            summ.mean = mean(self.samples);
            summ.c025 = prctile(self.samples, 2.5);
            summ.c975 = prctile(self.samples, 97.5);
        end
    end

    methods (Access = private)
        function yesno = accept(self, proposal)
            logAcceptProb = min(0, self.logTarget(proposal) - self.logTarget(self.initialState));
            if log(rand()) < logAcceptProb
                yesno = true;
            else
                yesno = false;
            end
        end

    end
end
