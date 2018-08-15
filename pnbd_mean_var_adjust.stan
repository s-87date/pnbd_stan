//Copyright 2018 Aaron Goodman <aaronjg@stanford.edu>. Licensed under the GPLv3 or later.

#include /pnbd_data.stan
parameters{
  real log_buy_a;
  real log_buy_b;
  real log_die_a;
  real log_die_b;


  vector[NC] log_lambda_raw;
  vector[NC] log_mu_raw;
}

transformed parameters{
  vector[NC] likelihood;

  real log_r = log_buy_a;
  real log_alpha = log_buy_a - log_buy_b;  
  real log_s = log_die_b;
  real log_beta = log_die_a - log_die_b;

  real r = exp(log_r);
  real alpha = exp(log_alpha);
  real s = exp(log_s);
  real beta = exp(log_beta);

  real tgr = trigamma(r);  
  vector[NC] log_lambda = log_lambda_raw*tgr + digamma(r) - log_alpha;
  real tgs = trigamma(s);
  vector[NC] log_mu = log_mu_raw*tgs + digamma(s) - log_beta;
  
  vector[NC] lambdamu = exp(log_lambda) + exp(log_mu);
#include /pnbdlikelihoodloop.stan
}

model{
  target += NC * log(fabs(tgr));
  target += NC * log(fabs(tgs));

  target += NC*(r * log_alpha - lgamma(r));
  target += r*log_lambda - alpha*exp(log_lambda);
  target += NC*(s * log_beta - lgamma(s));
  target += s*log_mu - beta*exp(log_mu);
  
  target += log_r + log_alpha + log_s + log_beta;
  r ~ normal(1,1);
  alpha ~ normal(1,1);
  s ~ normal(1,1);
  beta ~ normal(1,1);

  target += likelihood;
}
generated quantities{
#include /pnbd_generatedquantities.stan
}
