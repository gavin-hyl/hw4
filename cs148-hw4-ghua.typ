// Document Setup
#let title = "CS 148b HW 4 Responses"
#let author = "Gavin Hua"

// Page setup with header
#set page(
  numbering: "1",
  number-align: right,
  header: [
    #smallcaps([#title])
    #h(1fr) #smallcaps([#author])
    #line(length: 100%)
    #v(-10pt)
    #line(length:100%)
  ]
)

// Text formatting
#set par(justify: true)
#set text(
  font: "TeX Gyre Pagella",
  size: 11pt,
)

#let oa = $overline(alpha)$

#v(6pt)

= 1
== 1.2
We minimize the variational bound on the negative LL because the LL itself requires integrating over the denoising trajectory and is thus intractable.

$
  -log p_theta (x_0) &= -log integral p_theta (x_(0:T)) d x_(1:T) &"(marginalization)" \
  &= - log integral q(x_(1:T)|x_0) (p_theta (x_(0:T))) / q(x_(1:T)|x_0) d x_(1:T) \
  &= - log EE_(x_(1:T) ~ q(dot|x_0)) [(p_theta (x_(0:T))) / q(x_(1:T)|x_0)] &"(definition)" \
  &<= EE_(x_(1:T) ~ q(dot|x_0)) [- log (p_theta (x_(0:T))) / q(x_(1:T)|x_0)] &"(Jensen, " -log " convex)" \
  EE_(x_0 ~ q) [-log p_theta (x_0)] &<= EE_(x_0 ~ q, x_(1:T) ~ q(dot|x_0)) [- log (p_theta (x_(0:T))) / q(x_(1:T)|x_0)] \
  &= EE_q [- log (p(x_T) product_(t>=1) p_theta (x_(t-1)|x_t))/(product_(t>=1) q(x_t|x_(t-1)))] &"(MC)" \
  &= EE_q [- log p(x_T) - sum_(t>=1) log (p_theta (x_(t-1)|x_t))/(q(x_t|x_(t-1)))] \
  &=: L
$


== 1.3
(18) is justified above.

(20):
$
  q(x_(t-1)|x_0) / (q(x_(t-1)|x_t, x_0) dot q(x_t|x_0))
  &= q(x_(t-1), x_0) / (q(x_(t-1)|x_t, x_0) dot q(x_t, x_0)) &("Multiply by" q(x_0)) \
  &= q(x_(t-1), x_0) / (q(x_(t-1), x_t, x_0)) &("Bayes' rule")\
  &= 1 / (q(x_t|x_(t-1), x_0)) &("Bayes' rule")\
  &= 1 / q(x_t|x_(t-1)) &("Markov")\
$

(21):
$
  sum_(t>1) log (p_theta (x_(t-1)|x_t))/(q(x_(t-1)|x_t, x_0)) dot q(x_(t-1)|x_0) / q(x_t|x_0) &=
  sum_(t>1) log (p_theta (x_(t-1)|x_t))/(q(x_(t-1)|x_t, x_0)) + sum_(t>1) log q(x_(t-1)|x_0) / q(x_t|x_0) \
  &= sum_(t>1) log (p_theta (x_(t-1)|x_t))/(q(x_(t-1)|x_t, x_0)) + log product_(t>1) q(x_(t-1)|x_0) / q(x_t|x_0) \
  &= log q(x_1|x_0)/q(x_T|x_0) + sum_(t>1) log (p_theta (x_(t-1)|x_t))/(q(x_(t-1)|x_t, x_0)) \
  &= log 1/q(x_T|x_0) + sum_(t>1) log (p_theta (x_(t-1)|x_t))/(q(x_(t-1)|x_t, x_0)) + log q(x_1|x_0)\
$
Combining the dangling terms gives the result.

(22):
We invoke the identity $EE_(X, Y)[f(X, Y)] = EE_X [EE_(Y|X) [f(X, Y)]]$.
Each individual log term can be transformed in the same way with this trick.
Using the first term as an example:
$
  EE_q [- log p(x_T)/q(x_T|x_0)] &= EE_(x_(0:T) ~ q) [- log p(x_T)/q(x_T|x_0)] \
  &= EE_(x_0 ~ q) EE_(x_(1:T) ~ q(dot|x_0)) [- log p(x_T)/q(x_T|x_0)] \
  &= EE_(x_0 ~ q) [D_"KL" (q(x_T|x_0) || p(x_T))] \
  &= EE_q [D_"KL" (q(x_T|x_0) || p(x_T))] \
$

== 1.4
We show this with induction.
The $t=1$ case is trivial so we omit it.
Now assume $q(x_(t-1)|x_0) = cal(N) (x_(t-1); sqrt(oa_(t-1)) x_0, (1-oa_(t-1)) I)$.
The relationship between $x_t, x_(t-1)$ is equivalent to
$
  x_t = sqrt(1-beta_t) x_(t-1) + sqrt(beta_t) epsilon
$
where $epsilon ~ cal(N)(0, I)$.
Since $x_(t-1)$ is normally distributed, $x_t$ is as well.
$
  EE[x_t] = sqrt(1-beta_t) EE [x_(t-1)] = sqrt(1-beta_t) sqrt(oa_(t-1)) x_0 = sqrt(oa_t) x_0 \
  VV[x_t] = alpha_t VV[x_(t-1)] + beta_t I = alpha_t (1-oa_(t-1)) I + (1-alpha_t) I = (1-oa_t) I
$


== 1.5
$
  &q(x_(t-1)|x_0, x_t) \
  &= (q(x_t|x_0, x_(t-1)) q(x_(t-1)|x_0)) / q(x_t|x_0) \
  &= (q(x_t|x_(t-1)) q(x_(t-1)|x_0))/q(x_t|x_0) \
  &prop (q(x_t|x_(t-1)) q(x_(t-1)|x_0)) \
  &prop exp(-1/(2beta_t) ||x_t - sqrt(1-beta_t) x_(t-1)||^2 ) exp(-1/(2(1-oa_(t-1)))||x_(t-1) - sqrt(oa_(t-1))x_0||^2) \
  &prop exp(-1/(2beta_t) (-2 sqrt(1-beta_t) x_t^T x_(t-1) + (1-beta_t) ||x_(t-1)||^2) - 1/(2(1-oa_(t-1)))(||x_(t-1)||^2 - 2 sqrt(oa_(t-1)) x_(t-1)^T x_0))
$

The term quadratic in $||x_(t-1)||^2$ has the coefficient
$
  -1/2 ((1-beta_t)/beta_t + 1/(1-oa_(t-1)))
$
Since the covariance matrix must have the form $c I$ due to repeated Gaussian conditioning, we know that
$
  c = (beta_t (1-oa_(t-1))) / ((1-beta_t) (1-oa_(t-1)) + beta_t) = tilde(beta)_t
$
Collecting the remaining terms gives $tilde(mu)_t (x_t, x_0)$.

== 1.6
All the terms except the last do not depend on $theta$ and therefore can be extracted into $C$.
The quadratic form of a scaled identity matrix is just the scaled $L_2$ norm. 


== 1.7
There is no nontrivial algebra in this step.


== 1.8
#image("assets/1-8.png")



= 2
== 2.2
The term $nabla_x log p(x) = (nabla_x p(x)) / p(x)$ is inaccessible to us through data because the empirical distribution of $p(x)$ is a collection of delta functions.

== 2.3
We need to show the cross term is equal to the trace.
$
  EE [s_theta^T (x) nabla_x log p(x)] &= EE[sum_i 1/p(x) s_i (x) partial_i p(x)] \
  &= sum_i integral s_i (x) partial_i p(x) d x &"(" EE " absorbs " p(x) ")" \
  &= sum_i ( integral [s_i (x) p(x)]_(x_i = -oo)^(x_i = oo) d x_(-i) - integral partial_i s_i (x) p(x) d x ) &"(by parts in " x_i ")" \
  &= -sum_i integral partial_i s_i (x) p(x) d x &"(" p(x) -> 0 " at " oo ")" \
  &= -sum_i EE[partial_i s_i (x)] \
  &= -tr(nabla_x s(x))
$

== 2.4
The trace of the Jacobian is computationally expensive. 

== 2.5
$
  EE[x|tilde(x)] = EE[x-tilde(x)|tilde(x)] + tilde(x)
$
We now show the conditional expectation on the RHS is equal to the $sigma^2$ term.
By definition of conditional expectation,
$
  EE[x-tilde(x)|tilde(x)] &= integral (x-tilde(x)) p(x|tilde(x)) d x \
$
Moreover,
$
  nabla log p_sigma (tilde(x)) &= 1/(p_sigma (tilde(x))) nabla_(tilde(x)) p_sigma (tilde(x))\
  &= 1/(p_sigma (tilde(x))) nabla_(tilde(x)) (integral p(tilde(x)|x) p(x) d x)\
  &= 1/(p_sigma (tilde(x))) (integral nabla_(tilde(x)) p(tilde(x)|x) p(x) d x)\
  &= 1/(p_sigma (tilde(x))) (integral (-(tilde(x) - x)/sigma^2) p(tilde(x)|x) p(x) d x)\
  &= 1/(p_sigma (tilde(x))) (integral ((x - tilde(x))/sigma^2) p(tilde(x)|x) p(x) d x)\
  &= 1/(p_sigma (tilde(x))) (integral ((x - tilde(x))/sigma^2) p(x|tilde(x)) p_sigma (tilde(x)) d x)\
  &= 1/sigma^2 integral (x - tilde(x)) p(x|tilde(x)) d x \
  &= 1/sigma^2 (EE[x|tilde(x)] - tilde(x))
$


== 2.6
We would like to learn the term $nabla log p_sigma (tilde(x))$ so we minimize the MSE between $s_theta (tilde(x))$ and the desired quantity.
The quadratic terms are either the same or do not depend on $theta, sigma$.
Therefore, let us match the cross terms. 
$
  EE_p [s_theta^T (x) nabla_tilde(x) log p(tilde(x)|x)] &= 
  integral p(x) d x integral s_theta^T (tilde(x)) nabla_tilde(x) log p(tilde(x)|x) p(tilde(x)|x) d tilde(x) \
  &= integral p(x) d x integral s_theta^T (tilde(x)) nabla_tilde(x) p(tilde(x)|x) d tilde(x) \
  &= integral d tilde(x) s_theta^T (tilde(x))  nabla_tilde(x) integral p(x) p(tilde(x)|x) d x\
  &= integral s_theta^T (tilde(x)) nabla_tilde(x) p_sigma (tilde(x)) d tilde(x) \
  &= integral s_theta^T (tilde(x)) p_sigma (tilde(x)) nabla_tilde(x) log p_sigma (tilde(x)) d tilde(x) \
  &= EE_p_sigma [s_theta (tilde(x))^T nabla_(tilde(x)) log p_sigma (tilde(x))]
$


== 2.7
The DSM objective aims to fit $nabla log p (tilde(x)|x) = - (tilde(x) - x) / sigma^2 = - epsilon / sigma$ (since $tilde(x) - x = sigma epsilon$).
The DDPM objective aims to fit $epsilon$, so $c(sigma) = -1/sigma$.


== 2.8
Take the discretization timestep to be $eta$.
Sample $x_0 ~ N(0, I)$.
Repeat the following assignment:
$
  z_k ~ N(0, I) \
  x_(k+1) = x_k + eta s_theta (x_k) + sqrt(2 eta) z_k
$
Return $x_K$.
This works because $s_theta$ replaces the unknown score function, and after $K -> oo$ sampling steps $x_K ~ p_sigma approx p$ since $p_sigma$ is a stationary distribution.


= 3
== 3.2
The first is due to a Taylor series expansion since $Delta t$ is small, the second is due to $beta(t)$ being a continuous function. 

== 3.3
The general reverse-time formula for $d x = f d t + g d B_t$
is given by
$
  d x = (f(x, t) - g(t)^2 nabla_x log p_t (x)) d t + g(t) d overline(B)_t
$
Substituting,
$
  d x = (-1/2 beta(t) x - beta(t) nabla_x log p_t (x)) d t + sqrt(beta(t)) d overline(B)_t
$


== 3.4
*Step 1 (Euler–Maruyama discretization in reverse time).*
The reverse VP-SDE from Problem 3.3 is
$
  d x = (-1/2 beta(t) x - beta(t) nabla_x log p_t (x)) d t + sqrt(beta(t)) d overline(B)_t .
$
We integrate this SDE from $t=1$ down to $t=0$, so a single Euler–Maruyama step advances reverse time by one increment, taking the state from index $i+1$ (time $t + Delta t$) to index $i$ (time $t$). Evaluating the drift and diffusion at the start of the step, $x_(i+1)$ at time $t+Delta t$, and using that for a backward step the elapsed (positive) increment is $Delta t$ (equivalently $d t = -Delta t$):
$
  x_i = x_(i+1) - (-1/2 beta(t+Delta t) x_(i+1) - beta(t+Delta t) nabla_x log p_(t+Delta t) (x_(i+1))) Delta t + sqrt(beta(t+Delta t)) sqrt(Delta t) z_(i+1) ,
$
where $z_(i+1) ~ cal(N)(0, I)$ (Euler–Maruyama: the drift scales with $Delta t$, while the Brownian increment $d overline(B)_t$ has standard deviation $sqrt(Delta t)$). The leading minus sign on the drift is because reverse time runs opposite to $t$, i.e. $d t < 0$ over the step while the step length $Delta t > 0$; carrying the minus through flips both interior signs.

Now substitute the discrete schedule $beta_(i+1) = overline(beta)_(i+1) Delta t = beta(t+Delta t) Delta t$ (Song21 App. B & D). Then $beta(t+Delta t) Delta t = beta_(i+1)$ and, for the diffusion term, $sqrt(beta(t+Delta t)) sqrt(Delta t) = sqrt(beta(t+Delta t) Delta t) = sqrt(beta_(i+1))$. Substituting:
$
  x_i = x_(i+1) + 1/2 beta_(i+1) x_(i+1) + beta_(i+1) nabla_x log p_(t+Delta t) (x_(i+1)) + sqrt(beta_(i+1)) z_(i+1) .
$

*Step 2 (replace the true score by the learned model).*
The score $nabla_x log p_(t+Delta t)(x_(i+1))$ is unknown, so we substitute the approximation $s_theta (x_(i+1), i+1)$ (the learned network at state $x_(i+1)$ and step $i+1$):
$
  x_i = x_(i+1) + 1/2 beta_(i+1) x_(i+1) + beta_(i+1) s_theta (x_(i+1), i+1) + sqrt(beta_(i+1)) z_(i+1) .
$

*Step 3 (collect terms).*
Group the two terms proportional to $x_(i+1)$, leaving the score and noise terms intact:
$
  x_i = (1 + 1/2 beta_(i+1)) x_(i+1) + beta_(i+1) s_theta (x_(i+1), i+1) + sqrt(beta_(i+1)) z_(i+1) .
$
The scalar coefficient of $x_(i+1)$ is $1 + 1/2 beta_(i+1)$: the $+1$ is the identity carried over from $x_(i+1)$ itself, and the $+1/2 beta_(i+1)$ is the contribution of the $-1/2 beta x$ drift over one reverse step (the drift's own minus cancels against the reverse-time minus).

*Step 4 (first-order matching with the Taylor expansion of $1/sqrt(1-beta_(i+1))$).*
We want the prefactor in the DDPM form $1/sqrt(1-beta_(i+1))$. Taylor-expand about $beta_(i+1)=0$:
$
  1/sqrt(1-beta_(i+1)) = (1-beta_(i+1))^(-1/2) = 1 + 1/2 beta_(i+1) + 3/8 beta_(i+1)^2 + O(beta_(i+1)^3) ,
$
so
$
  1 + 1/2 beta_(i+1) = 1/sqrt(1-beta_(i+1)) + O(beta_(i+1)^2) .
$
Thus, to first order in $beta_(i+1)$, the coefficient of $x_(i+1)$ equals $1/sqrt(1-beta_(i+1))$. This is exactly how the $-1/2 beta x$ drift combines with the $1/sqrt(1-beta)$ factor: the linearization of $(1-beta)^(-1/2)$ reproduces the $1 + 1/2 beta$ that the Euler step produced from the drift.

We make the same first-order substitution on the score term. Since $beta_(i+1) = 1/sqrt(1-beta_(i+1)) dot beta_(i+1) (1 + O(beta_(i+1)))$, replacing the bare coefficient $beta_(i+1)$ multiplying $s_theta$ by $beta_(i+1) / sqrt(1-beta_(i+1))$ changes it only by $O(beta_(i+1)^2)$. Pulling the common factor $1/sqrt(1-beta_(i+1))$ out of the $x_(i+1)$ and $s_theta$ terms, and keeping the diffusion term as is (its own correction is higher order), gives
$
  x_i = 1/sqrt(1-beta_(i+1)) (x_(i+1) + beta_(i+1) s_theta (x_(i+1), i+1)) + sqrt(beta_(i+1)) z_(i+1) + O(beta_(i+1)^2) .
$
Dropping the $O(beta_(i+1)^2)$ terms (valid in the small-step limit $beta_(i+1) -> 0$, where $Delta t -> 0$) yields the claimed DDPM-style reverse update rule:
$
  x_i = 1/sqrt(1-beta_(i+1)) (x_(i+1) + beta_(i+1) s_theta (x_(i+1), i+1)) + sqrt(beta_(i+1)) z_(i+1) . #h(1em) qed
$


== 3.5
Recall the SDE-based update rule derived in Problem 3.4 (with $alpha_(i+1) = 1 - beta_(i+1)$):
$
  x_i = 1/sqrt(1-beta_(i+1)) (x_(i+1) + beta_(i+1) s_theta (x_(i+1), i+1)) + sqrt(beta_(i+1)) z_(i+1),
$
and DDPM Algorithm 2 (Ho et al.) with the choice $sigma_t = sqrt(beta_t)$:
$
  x_i = 1/sqrt(alpha_(i+1)) (x_(i+1) - beta_(i+1)/sqrt(1-oa_(i+1)) epsilon_theta (x_(i+1), i+1)) + sqrt(beta_(i+1)) z_(i+1).
$
Both have identical prefactors $1\/sqrt(1-beta_(i+1)) = 1\/sqrt(alpha_(i+1))$ and identical noise terms $sqrt(beta_(i+1)) z_(i+1)$. They differ *only* in the correction term: the SDE form carries $+beta_(i+1) s_theta$, while DDPM carries $- (beta_(i+1)\/sqrt(1-oa_(i+1))) epsilon_theta$. We must reconcile these.

*The two networks parametrize different objects.* The SDE/Langevin viewpoint uses a *score* model $s_theta (x, t) approx nabla_x log p_t (x)$, whereas DDPM trains a *noise* predictor $epsilon_theta (x, t) approx epsilon$, the standard normal noise that was injected. These are not the same function; converting between them requires the factor established in Problem 2.7.

*The conversion factor (Problem 2.7).* In DSM, the perturbation kernel is $tilde(x) = x + sigma epsilon$ with $epsilon ~ cal(N)(0, I)$, and the conditional score is
$
  nabla_(tilde(x)) log p_sigma (tilde(x) | x) = - (tilde(x) - x)/sigma^2 = - epsilon/sigma
$
(differentiating the Gaussian kernel; cf. Problem 2.5). Since the optimal denoiser matches this target, the optimal score relates to the optimal noise predictor by the *fixed* scalar $c(sigma) = -1\/sigma$:
$
  s_theta = c(sigma) epsilon_theta = - epsilon_theta / sigma .
$

*Identifying $sigma$ in the DDPM context.* By the marginal forward kernel (Problem 1.4),
$
  q(x_t | x_0) = cal(N)(sqrt(oa_t) x_0, (1 - oa_t) I) quad => quad x_t = sqrt(oa_t) x_0 + sqrt(1 - oa_t) epsilon,
$
so the standard deviation of the *total* noise added to the clean image $x_0$ at time $t$ is
$
  sigma = sqrt(1 - oa_t).
$
(This is the "$sigma$" the hint refers to: not the per-step $beta_t$, but the cumulative noise level $sqrt(1-oa_t)$.) Hence at time $i+1$,
$
  s_theta (x_(i+1), i+1) = - (epsilon_theta (x_(i+1), i+1)) / sqrt(1 - oa_(i+1)).
$

*Substitution.* Plugging this into the SDE update converts the score correction into a noise correction:
$
  beta_(i+1) s_theta (x_(i+1), i+1)
  = beta_(i+1) dot (- (epsilon_theta (x_(i+1), i+1)) / sqrt(1 - oa_(i+1)))
  = - beta_(i+1)/sqrt(1 - oa_(i+1)) epsilon_theta (x_(i+1), i+1).
$
Therefore the SDE update becomes
$
  x_i = 1/sqrt(1 - beta_(i+1)) (x_(i+1) - beta_(i+1)/sqrt(1 - oa_(i+1)) epsilon_theta (x_(i+1), i+1)) + sqrt(beta_(i+1)) z_(i+1),
$
which is *exactly* DDPM Algorithm 2 with $sigma_(i+1) = sqrt(beta_(i+1))$.

*Conclusion.* The bare coefficient $beta_(i+1)$ in front of the score $s_theta$ is replaced, after the score$arrow.l.r$noise change of variables, by $beta_(i+1)\/sqrt(1 - oa_(i+1))$ in front of $epsilon_theta$. The "missing" multiplicative factor is precisely $1\/sigma = 1\/sqrt(1 - oa_(i+1))$, the score-to-noise conversion constant $c(sigma) = -1\/sigma$ from Problem 2.7 (the sign being absorbed into the score's $-epsilon_theta$). The two algorithms are thus the same update written in two equivalent parametrizations of the same learned quantity.


== 3.6
*(a)* Plain Langevin dynamics is run at a *single fixed* noise level: it iterates $x_(k+1) = x_k + eta s_theta (x_k) + sqrt(2 eta) z_k$ using only the score $nabla_x log p$ (or $nabla_x log p_sigma$) of *one* target distribution, and correctness relies on the chain *mixing* to its stationary distribution as $k -> oo$, which can be slow when $p$ is multimodal or has low-density barriers. The reverse SDE instead exploits the entire *time-indexed family* of scores ${nabla_x log p_t (x)}_(t in [0,1])$ -- a continuum of noise levels interpolating from the data distribution $p_0 approx p_"data"$ to the tractable prior $p_1 approx cal(N)(0, I)$ -- *together with the known forward drift* $f(x,t) = -1/2 beta(t) x$. Because the reverse dynamics
$
  d x = (f(x,t) - g(t)^2 nabla_x log p_t (x)) d t + g(t) d overline(B)_t, quad g(t) = sqrt(beta(t)),
$
*exactly inverts* the forward diffusion, integrating it from $t=1$ to $t=0$ *transports* the prior onto the data manifold along the prescribed reverse trajectory in finite time, with no need to equilibrate to any stationary distribution.

*(b)* This richer information -- scores at *all* noise levels rather than one -- is built directly into both training losses:

- *Song21 Eq. (7):* the (denoising) score-matching objective is an *expectation/integral over the whole continuum* $t in [0,1]$,
$
  cal(L)(theta) = EE_(t ~ cal(U)[0,1]) [ lambda(t) thin EE_(x_0) EE_(x_t | x_0) [ norm(s_theta (x_t, t) - nabla_(x_t) log p_(0 t)(x_t | x_0))^2 ] ],
$
with a per-level weighting $lambda(t)$. The single time-conditioned network $s_theta (x, t)$ is thus trained to match $nabla_x log p_t (x)$ *simultaneously at every noise level*, exactly the family the reverse SDE consumes.

- *DDPM Eq. (14):* the simplified loss is a *sum/expectation over all discrete timesteps* $t in {1, dots, T}$,
$
  L_"simple"(theta) = EE_(t, x_0, epsilon) [ norm(epsilon - epsilon_theta (sqrt(oa_t) x_0 + sqrt(1 - oa_t) epsilon, thin t))^2 ],
$
and the one network $epsilon_theta (x_t, t)$ is *conditioned on* $t$. Since $epsilon_theta$ is equivalent to a (rescaled) score $nabla_(x_t) log q(x_t | x_0)$ at level $t$ (via $nabla_(x_t) log q(x_t|x_0) = -epsilon \/ sqrt(1-oa_t)$), conditioning on $t$ and averaging over all $t$ makes it learn the *entire family of time-marginals* $q(x_t | x_0)$, not a single fixed score -- precisely the extra information that lets the reverse process denoise step-by-step instead of mixing.


== 3.7
Classifier guidance steers an unconditional diffusion model toward a target class $y$ by adding the gradient of a noise-aware classifier to the score. By Bayes' rule, at every noise level $t$,
$
  p_t (x|y) = (p_t (x) p_t (y|x)) / p_t (y) prop p_t (x) p_t (y|x) quad ("Bayes' rule;" p_t (y) "const. in" x).
$
Taking $nabla_x log$ of both sides and using $nabla_x log p_t (y) = 0$ (the marginal $p_t (y)$ does not depend on $x$),
$
  nabla_x log p_t (x|y) &= nabla_x log p_t (x) + nabla_x log p_t (y|x) - underbrace(nabla_x log p_t (y), = 0) \
  &= nabla_x log p_t (x) + nabla_x log p_t (y|x).
$
So the conditional score is the *unconditional* score $nabla_x log p_t (x) approx s_theta (x, t)$ plus the gradient of a *time-dependent classifier* log-likelihood $nabla_x log p_t (y|x_t)$. One therefore trains two models separately: an unconditional diffusion model for $s_theta$, and a classifier $p_t (y|x_t)$ on noised inputs $x_t$ (it must be noise-level aware, since $x_t$ becomes progressively noisier as $t$ grows). At sampling time one substitutes $nabla_x log p_t (x|y) = s_theta (x,t) + nabla_x log p_t (y|x_t)$ into the conditional reverse SDE, so the classifier gradient nudges each reverse step toward regions it assigns high probability to class $y$; a guidance scale $w$ multiplying $nabla_x log p_t (y|x_t)$ sharpens this push, trading sample diversity for class fidelity.

(Optionally, the *classifier-free* variant avoids training a separate classifier: one jointly learns a conditional and unconditional noise model $epsilon_theta (x,t,y)$ and $epsilon_theta (x,t,nothing)$ via conditioning dropout, and guides with $epsilon_theta (x,t,nothing) + w (epsilon_theta (x,t,y) - epsilon_theta (x,t,nothing))$. Since $epsilon_theta approx -sigma(t) nabla_x log p_t$, the identity above gives $epsilon_theta (x,t,y) - epsilon_theta (x,t,nothing) = -sigma(t) nabla_x log p_t (y|x_t)$, i.e. the difference is exactly the classifier-gradient term scaled by $-sigma(t)$, so $w = 0$ recovers unconditional and $w = 1$ recovers conditional sampling.)


= 4

== 4.1
We minimize over all measurable $v_theta : RR^d times [0,1] -> RR^d$. Write $Y := X_1 - X_0$. By the tower property (law of total expectation), conditioning on $X_t$ inside the expectation,
$
  L_"RF" (theta) = integral_0^1 EE[ ||Y - v_theta (X_t, t)||^2 ] d t
  = integral_0^1 EE_(X_t) [ underbrace(EE[ ||Y - v_theta (X_t, t)||^2 | X_t ], R(X_t\, t)) ] d t .
$
The integrand $R(x,t) := EE[ ||Y - v_theta (x,t)||^2 | X_t = x ]$ is nonnegative, and for each fixed $(x,t)$ the only dependence on $theta$ is through the single vector $v := v_theta (x,t) in RR^d$. Hence integration over $t$ and expectation over $X_t$ are monotone (integration of a nonnegative integrand preserves the pointwise order): if a measurable map $v^*$ minimizes $R(x,t)$ for almost every $(x,t)$ w.r.t. the law of $(X_t, t)$, then it minimizes $L_"RF"$. So it suffices to solve, for each fixed $(x,t)$, the static problem
$
  min_(v in RR^d) g(v), quad g(v) := EE[ ||Y - v||^2 | X_t = x ] .
$

*Pointwise minimizer (L2 projection / conditional mean).* Let $m := EE[Y | X_t = x]$, which exists since $Y = X_1 - X_0$ is integrable (assume finite second moments so $R$ is finite). Insert and subtract $m$ and expand the square using $||a - b||^2 = ||a||^2 - 2 a^T b + ||b||^2$:
$
  ||Y - v||^2 &= ||(Y - m) + (m - v)||^2 \
  &= ||Y - m||^2 + 2 (Y - m)^T (m - v) + ||m - v||^2 .
$
Take the conditional expectation $EE[ dot | X_t = x ]$. The vector $m - v$ is deterministic given $X_t = x$ (a fixed function of $x$), so it pulls out of the cross term by linearity:
$
  EE[ 2 (Y - m)^T (m - v) | X_t = x ] = 2 ( underbrace(EE[Y | X_t = x], = m) - m )^T (m - v) = 0 ,
$
which vanishes precisely by the definition of $m$ as the conditional mean. Therefore the bias--variance decomposition holds:
$
  g(v) = EE[ ||Y - v||^2 | X_t = x ] = underbrace(EE[ ||Y - m||^2 | X_t = x ], "conditional variance, indep. of " v) + ||m - v||^2 .
$
The first term does not depend on $v$ and the second satisfies $||m - v||^2 >= 0$ with equality iff $v = m$. Hence $g(v) >= g(m)$ for all $v in RR^d$, and the unique minimizer is $v = m = EE[Y | X_t = x]$.

*First-order check (gradient).* Equivalently, $g$ is strictly convex (Hessian $nabla^2 g = 2 I succ 0$), so its unique stationary point is the global minimizer. Differentiating $g(v) = EE[||Y||^2 | X_t = x] - 2 v^T EE[Y | X_t = x] + ||v||^2$ and setting $nabla_v g = 0$:
$
  nabla_v g(v) = -2 EE[Y | X_t = x] + 2 v = 0 quad => quad v = EE[Y | X_t = x] = m ,
$
confirming the same answer.

*Conclusion.* Define $v^*(x,t) := EE[X_1 - X_0 | X_t = x]$. This map is measurable in $(x,t)$ (it is a regular conditional expectation), so it is an admissible choice of $v_theta$. By the argument above it minimizes $R(x,t)$ for every $(x,t)$, hence pointwise minimizes the integrand of $L_"RF"$; since integration over $t$ and expectation over $X_t$ preserve this pointwise optimality,
$
  v^*(x,t) = EE[ X_1 - X_0 | X_t = x ] in op("argmin")_(v_theta) L_"RF" (theta) .
$
The minimizer is unique up to changes on a set of $(x,t)$ of measure zero under the law of $(X_t, t)$, since the pointwise minimizer is unique wherever the conditional law is defined.


== 4.2
*Part A.* The rectified-flow interpolation is $X_t = (1-t) X_0 + t X_1$, and the optimal velocity field is the conditional expectation of the instantaneous velocity $dot(X)_t = X_1 - X_0$ given the current state (the $L^2$-optimal velocity is the conditional mean):
$
  v^*(x, t) = EE[X_1 - X_0 | X_t = x].
$
From $X_t = (1-t) X_0 + t X_1$ we solve $X_1 = (X_t - (1-t) X_0) / t$, hence
$
  X_1 - X_0 = (X_t - (1-t) X_0)/t - X_0 = (X_t - (1-t) X_0 - t X_0)/t = (X_t - X_0)/t.
$
Taking $EE[dot | X_t = x]$ (and using $EE[X_t | X_t = x] = x$ by measurability) gives
$
  v^*(x, t) = EE[(X_t - X_0)/t | X_t = x] = (x - EE[X_0 | X_t = x]) / t.
$

*Part B.* Condition on $X_1$. The only remaining randomness is $X_0 ~ cal(N)(0, I)$, and $X_t = (1-t) X_0 + t X_1$ is an affine function of $X_0$, so
$
  X_t | X_1 ~ cal(N)(t X_1, (1-t)^2 I) quad ("affine map of a Gaussian").
$
Writing $pi_1$ for the law of $X_1$, the marginal density of $X_t$ is the Gaussian-smoothed density
$
  p_t (x) = integral pi_1(x_1) cal(N)(x; t x_1, (1-t)^2 I) d x_1.
$
Differentiate under the integral (dominated convergence justifies the interchange, the kernel being smooth and integrable). Using $nabla_x cal(N)(x; t x_1, (1-t)^2 I) = -(1/(1-t)^2)(x - t x_1) cal(N)(x; t x_1, (1-t)^2 I)$,
$
  nabla_x p_t (x) &= integral pi_1(x_1) (-1/(1-t)^2)(x - t x_1) cal(N)(x; t x_1, (1-t)^2 I) d x_1 \
  &= -1/(1-t)^2 integral (x - t x_1) pi_1(x_1) cal(N)(x; t x_1, (1-t)^2 I) d x_1.
$
Dividing by $p_t(x)$ and recognizing that $pi_1(x_1) cal(N)(x; t x_1, (1-t)^2 I) \/ p_t(x) = p(x_1 | X_t = x)$ is the posterior over $X_1$ (Bayes' rule), the integral becomes a conditional expectation:
$
  nabla_x log p_t (x) = (nabla_x p_t(x))/p_t(x) = -1/(1-t)^2 (x - t EE[X_1 | X_t = x]).
$
This is exactly Tweedie's formula (Problem 2.5) applied to the kernel $X_t | X_1 ~ cal(N)(t X_1, (1-t)^2 I)$. Now solve the interpolation for $X_0$: from $X_t = (1-t) X_0 + t X_1$ we get $X_0 = (X_t - t X_1)/(1-t)$, so taking $EE[dot | X_t = x]$,
$
  EE[X_0 | X_t = x] = (x - t EE[X_1 | X_t = x])/(1-t).
$
Comparing with the score expression above, $x - t EE[X_1 | X_t = x] = -(1-t)^2 nabla_x log p_t(x)$, hence
$
  EE[X_0 | X_t = x] = (-(1-t)^2 nabla_x log p_t(x))/(1-t) = -(1-t) nabla_x log p_t(x).
$
Substituting into Part A,
$
  v^*(x, t) = (x - EE[X_0 | X_t = x])/t = (x + (1-t) nabla_x log p_t(x))/t.
$

*Part C.* The optimal rectified-flow velocity is an *affine* function of the score: $v^*(x,t) = x/t + ((1-t)/t) nabla_x log p_t(x)$, with coefficients depending only on $t$. Thus knowing $v^*$ is equivalent to knowing the score $nabla_x log p_t$ (each determines the other), so rectified flow and score-based diffusion encode the *same* information about the data. Their deterministic generative dynamics are the same probability-flow ODE written in different coordinates, coinciding up to the time reparameterization / deterministic change of variables that maps the linear-interpolation schedule to the VP-SDE schedule.


== 4.3
Throughout, $v_theta (x,t)$ is the learned velocity field of a rectified flow whose probability-flow ODE is $d X_t = v_theta (X_t, t) d t$, and $(X_0, X_1)$ are the endpoint pairs (noise, data) under some coupling, with linear interpolant $X_t = (1-t) X_0 + t X_1$ so that the *target* velocity along an interpolation line is the constant $X_1 - X_0$ (definition of rectified flow). Write $Phi^s$ for the time-$s$ flow map of this ODE.

*(1) Geometric meaning of the extreme values of $S$.*

Recall
$
  S = 1 - (EE[integral_0^1 ||v_theta (X_t, t) - (X_1 - X_0)||^2 d t]) / (EE[||X_1 - X_0||^2]).
$

$S = 1$: the numerator vanishes, so $v_theta (X_t, t) = X_1 - X_0$ for (almost) all $t$ along every trajectory; the velocity is *constant in time*, hence each path is a straight, constant-speed line, and a single Euler step of size $Delta t = 1$, namely $X_0 |-> X_0 + v_theta (X_0, 0) = X_0 + (X_1 - X_0) = X_1$, integrates the ODE *exactly* (no discretization error).

$S = 0$: the mean-squared deviation of $v_theta$ from the straight displacement equals the displacement energy $EE[||X_1 - X_0||^2]$ itself, i.e. the velocity field is "wrong" on the scale of the data, so the flow is maximally curved / as far from straight as the data scale allows and a one-step Euler integration is useless.

*(2) Why re-pairing (reflow) straightens trajectories.*

The marginal velocity that the regression actually fits is the conditional expectation of the per-pair target given the current state (tower property / least-squares optimum of the flow-matching loss):
$
  v^star (x, t) = EE[X_1 - X_0 mid(|) X_t = x].
$
Under the *original* independent coupling $pi_0 times pi_1$, many interpolation lines pass through the same intermediate point $x$ with *different* displacements $X_1 - X_0$; the lines cross, so the conditioning above averages several distinct directions and $v^star (x, t)$ varies with $t$ along a realized path $=>$ curved trajectories ($S < 1$). After the first training the ODE is deterministic, so it induces the coupling $(X_0, Phi^1 (X_0))$ in which each noise sample maps to a *single* output (definition of a deterministic transport map). Repairing on $(X_0, Phi^1 (X_0))$ gives a coupling whose interpolation lines do *not* cross transversally (a deterministic, monotone-like transport has non-intersecting characteristics), so at each $x$ the conditional expectation $EE[X_1 - X_0 mid(|) X_t = x]$ concentrates on essentially one displacement direction. Hence $v^star$ is more nearly constant along each line, the paths are straighter, and $S$ increases toward $1$. Crucially, reflow preserves the marginals ($Phi^1 (X_0) ~ pi_1$ by construction), so straightening does not change the generated distribution in the ideal case.

*(3) Cost of one reflow round, and why to limit rounds.*

One reflow round costs roughly *(one generation pass) $+$ (one full retraining run)*:

(a) *Data generation:* to build the new pairs one must simulate the learned ODE $X_1 = Phi^1 (X_0)$ for $~ N$ samples. With a $K$-step numerical integrator (e.g. $K approx 100$ Euler steps) this is $approx K dot N$ network evaluations, i.e. $tilde(O)(K N)$ forward passes; this dominates because the original training never needed full trajectory simulation (its targets are the cheap analytic interpolants $X_1 - X_0$).

(b) *Retraining:* a complete optimization run of the flow-matching loss on the $N$ regenerated pairs, comparable in cost to the original training.

So each round adds a generation pass on top of a fresh training run, several times the cost of plain training. One limits the number of rounds for two reasons: the per-round cost above is large, and (more importantly) the regression *targets* are produced by the imperfect previous model rather than by ground-truth data. Each round therefore feeds simulation error and the model's own bias back in as supervision, so approximation error *compounds* across rounds; after one or two rounds the straightness gains saturate while sample-quality degradation from accumulated error can grow, making further rounds a poor trade.


== 4.4
We compare DDPM (Ho et al. 2020) against Rectified Flow (RF; Liu et al. 2022) along four axes. Throughout, RF couples a data sample $X_1 ~ p_"data"$ with noise $X_0 ~ cal(N)(0, I)$, defines the interpolation $X_t = (1-t) X_0 + t X_1$ for $t in [0,1]$, and learns a velocity field $v_theta (x, t)$.

*(1) Training objective.*
DDPM regresses the injected Gaussian noise: with $x_t = sqrt(oa_t) x_0 + sqrt(1-oa_t) epsilon$ and $epsilon ~ cal(N)(0, I)$, the (simplified) loss is
$
  L_"DDPM" = EE_(t, x_0, epsilon) [ ||epsilon - epsilon_theta (x_t, t)||^2 ],
$
so the regression *target $epsilon$ is $t$-dependent* and (equivalently, by Tweedie/the score identity $nabla_(x_t) log q(x_t|x_0) = -epsilon\/sqrt(1-oa_t)$) amounts to learning the score. RF instead regresses the *constant displacement* $X_1 - X_0$ of each pair:
$
  L_"RF" = EE_(t, X_0, X_1) [ ||(X_1 - X_0) - v_theta (X_t, t)||^2 ],
$
whose target $partial_t X_t = X_1 - X_0$ is *time-independent* along a given pair's straight interpolant.

*(2) Inference cost.*
DDPM's reverse path is a *curved, stochastic* trajectory, so an accurate solve needs a fine time discretization (many network evaluations, classically $T tilde 10^3$, hundreds even with fast samplers). RF integrates the deterministic ODE $d x = v_theta (x, t) d t$, whose trajectories are (by construction, and increasingly so after *reflow*) close to straight, so few Euler steps suffice. In the ideal straightened limit ($S = 1$: velocity exactly constant along each trajectory) a *single* Euler step with $Delta t = 1$,
$
  hat(x)_1 = x_0 + 1 dot v_theta (x_0, 0),
$
is *exact*, since for constant $v$ the Euler update incurs zero truncation error.

*(3) Trajectory geometry.*
DDPM evolves along a *curved SDE* (stochastic, with diffusion term $g(t) d overline(B)_t$); RF evolves along a *deterministic ODE* whose paths are *ideally straight lines* $x_0 + t(X_1 - X_0)$. The implication is quantitative: local Euler truncation error scales like $(Delta t)^2 norm(partial_t^2 x)$, and a straight path has $partial_t^2 x = 0$. Thus *straighter $=>$ smaller per-step discretization error $=>$ fewer steps needed* for a target accuracy. (This straightness is exactly what reflow optimizes: it never increases, and generally decreases, transport cost while reducing path curvature.)

*(4) Likelihood evaluation.*
DDPM's training loss yields only the *ELBO*, a variational *lower bound* $log p_theta (x_0) >= -L$ (by Jensen, as in 1.2); the gap is a sum of KL terms and is generally nonzero, so DDPM gives a bound, not the exact log-likelihood. RF's deterministic ODE makes it a *continuous normalizing flow*, so it admits an *exact* likelihood via the instantaneous change-of-variables formula,
$
  log p_1 (x_1) = log p_0 (x_0) - integral_0^1 nabla_x dot v_theta (x_t, t) d t,
$
integrating the divergence (trace of the Jacobian) of the velocity along the trajectory. However, this is *not* delivered by the training objective: it requires solving the ODE and estimating $tr(nabla_x v_theta)$ (e.g. via a Hutchinson estimator), so exact likelihood is available *in principle*, not for free.


= 5

#emph[All code for this part is implemented in #raw("diffusion/vp.py") (submitted to
Gradescope as #raw("VP.py")); the DSM training loss is in #raw("scripts/train_vp.py")
and sampling drivers are in #raw("scripts/sample.py"). All autograder tests in
#raw("tests/test_vp.py") pass. Figures marked #emph[[run]] are produced by the Colab
notebook on an A100 and should be pasted in from #raw("runs/vp/").]

== 5.A.i (Drift and Diffusion Coefficients)
The general Itô SDE is written
$
d x = f(x, t) d t + g(t) d B_t,
$
where $f(x, t)$ is the drift coefficient (the deterministic per-unit-time increment) and $g(t)$ is the diffusion coefficient (the scaling of the Brownian increment). Comparing term-by-term with the VP-SDE
$
d x = -1/2 beta(t) x d t + sqrt(beta(t)) d B_t,
$
we read off the $d t$-coefficient as the drift and the $d B_t$-coefficient as the diffusion:
$
f(x, t) = -1/2 beta(t) x, quad g(t) = sqrt(beta(t)).
$
Note $f$ is linear in $x$ (giving an affine, Gaussian-preserving drift) and $g$ depends only on $t$, not on $x$ (additive noise), which is exactly the structure that yields the closed-form Gaussian perturbation kernel $x_t = c(t) x_0 + sigma(t) epsilon$.


== 5.A.ii ($beta(t)$ and $c(t)$)
For the VP-SDE with the linear noise schedule (Song21 Eqs. 32–33),
$
beta(t) = beta_"min" + (beta_"max" - beta_"min") t, quad t in [0,1].
$

The mean-decay factor of the perturbation kernel is $c(t) = exp(-1/2 integral_0^t beta(s) dif s)$. Evaluating the integral (linear integrand, with antiderivative $beta_"min" s + 1/2 (beta_"max" - beta_"min") s^2$):
$
integral_0^t beta(s) dif s = integral_0^t [beta_"min" + (beta_"max" - beta_"min") s] dif s = beta_"min" t + 1/2 (beta_"max" - beta_"min") t^2 .
$

Hence
$
c(t) = exp(-1/2 ( beta_"min" t + 1/2 (beta_"max" - beta_"min") t^2 )) .
$

This $c(t)$ is the mean-decay factor in the (Gaussian) perturbation kernel
$
x_t = c(t) x_0 + sigma(t) epsilon, quad epsilon ~ cal(N)(0, I), quad sigma(t)^2 = 1 - c(t)^2,
$
where $sigma(t)^2 = 1 - c(t)^2$ enforces the variance-preserving property: with $c(t)^2 + sigma(t)^2 = 1$, a unit-variance $x_0$ gives marginal variance $c(t)^2 dot 1 + sigma(t)^2 = 1$ for all $t$.

Verification at $t = 0$: the integral vanishes ($integral_0^0 beta(s) dif s = 0$), so $c(0) = exp(0) = 1$, giving $x_0 = c(0) x_0 + sigma(0) epsilon = x_0$ with $sigma(0)^2 = 1 - 1 = 0$ (no noise at $t = 0$), as required.


== 5.A.iii (Implementation)
Implemented in #raw("VP.py"): #raw("beta"), #raw("c"), #raw("sigma"), #raw("drift"),
#raw("diffusion"), and #raw("marginal"). The score network is trained with the
likelihood-weighted DSM loss (Song21 Eq. 7); with target score $-epsilon\/sigma(t)$ and
weight $lambda(t) = sigma(t)^2$ this reduces to the clean form
$EE[norm(sigma(t) s_theta (x_t, t) + epsilon)^2]$.

== 5.B (Samplers)
#raw("Euler_Maruyama_sampler") integrates the reverse VP-SDE
$d x = [-1/2 beta(t) x - beta(t) nabla_x log p_t (x)] d t + sqrt(beta(t)) d overline(B)_t$
backward from $t = 1$ to $t approx 0$; at each step
$x <- x + (1/2 beta(t) x + beta(t) s_theta) Delta t + sqrt(beta(t) Delta t) z$, returning the
final mean. #raw("predictor_corrector_sampler") (Algorithm 5 of Song21) alternates one EM
predictor step with #raw("n_corrector") annealed-Langevin corrector steps with step size
$2 (r norm(z) \/ norm(s_theta))^2$ ($r$ = target SNR).

== 5.C.i (Dataset Visualization)
#figure(image("assets/5-c-i-dataset.png", width: 80%))
FashionMNIST contains 60{,}000 training and 10{,}000 test images. Each image is a single-channel
$1 times 28 times 28$ grayscale tensor (we normalize to $[-1, 1]$). There are 10 balanced classes:
T-shirt/top, Trouser, Pullover, Dress, Coat, Sandal, Shirt, Sneaker, Bag, and Ankle boot. The
prior is dominated by centered, roughly symmetric garment silhouettes on a black background.

== 5.C.ii (Training Curves)
#emph[[run] Paste #raw("runs/vp/") loss curve here (log-scale $y$).]
Settings: 50 epochs, learning rate $10^(-4)$, batch size 128, $[beta_min, beta_max] = [0.01, 5.0]$,
Adam, early-stopping patience 10. The weighted DSM loss decreases quickly over the first few epochs
and then plateaus; the best checkpoint (lowest validation loss) is kept.

== 5.C.iii (EM Samples)
#emph[[run] Paste the $8 times 8$ EM grid from
#raw("sample.py --method em --checkpoint runs/vp/best.pt --num_steps 1000").]

== 5.C.iv (PC Samples)
#emph[[run] Paste two $8 times 8$ PC grids, e.g. #raw("--n_corrector 1") and #raw("--n_corrector 3")
(#raw("sample.py --method pc ...")).]

== 5.C.v (Qualitative Discussion)
EM alone leaves visible high-frequency noise at moderate step counts, since it only follows the
first-order reverse-SDE discretization. The PC sampler interleaves Langevin corrector steps that pull
each iterate back onto the data manifold, yielding cleaner, more globally coherent garments; increasing
the corrector count from 1 to 3 sharpens edges further at extra compute cost (too many steps eventually
oversmooths fine texture). Compared with the dataset plot (5.C.i), the model captures the dominant
low-frequency structure well — overall class silhouettes such as trousers, bags, and ankle boots — but
struggles with fine high-frequency detail (logos, sandal straps, fabric texture) and with visually
ambiguous classes (Shirt vs. Coat vs. Pullover).

= 6

#emph[Rectified-flow forward process, loss, Euler sampler, and reflow are implemented in
#raw("diffusion/rectflow.py"); training/reflow drivers are in #raw("scripts/train_rectflow.py"),
KID evaluation in #raw("scripts/eval_kid.py"). All tests in #raw("tests/test_rectflow.py") pass.]

== 6.A (Forward Process and Training Loss)
The rectified-flow forward process draws $x_0 ~ cal(N)(0, I)$, forms $x_t = (1 - t) x_0 + t x_1$ with
$t ~ "Uniform"(0, 1)$, and regresses the (time-independent) velocity $x_1 - x_0$:
$cal(L)_"RF" = EE norm((x_1 - x_0) - v_theta (x_t, t))^2$.
#emph[[run] Paste the combined (RF + VP) training-loss curve, log-scale.]
#strong[Do the loss scales compare directly?] No. The VP/DDPM model regresses the Gaussian noise
$epsilon$ under a $sigma(t)^2$ weighting, whereas rectified flow regresses the velocity $x_1 - x_0$
under a flat (unweighted) MSE. The two targets have different distributions and the objectives use
different weightings, so the #emph[absolute] loss magnitudes are not comparable — only the trend
(monotone decrease and convergence) can be read across the two curves.

== 6.B (Euler Sampler and Full Comparison)
#emph[[run] Fill the KID table (mean $plus.minus$ std, 1k samples via torch-fidelity) and paste the
$8 times 8$ grids for each (method, steps). All grids share the same initial noise $x_0$ per cell.]

#table(
  columns: 4,
  table.header([*Steps*], [*Flow Matching*], [*DDIM*], [*DDPM EM*]),
  [1],    [_[run]_], [_[run]_], [---],
  [5],    [_[run]_], [_[run]_], [---],
  [10],   [_[run]_], [_[run]_], [---],
  [50],   [_[run]_], [_[run]_], [---],
  [100],  [_[run]_], [_[run]_], [---],
  [200],  [_[run]_], [_[run]_], [---],
  [1000], [_[run]_], [_[run]_], [_baseline_],
)

Expected qualitative findings (confirm against your runs):
+ #strong[First recognizable samples.] Flow matching is recognizable at the fewest steps
  ($tilde 5$–$10$), DDIM a bit later ($tilde 10$–$50$); DDPM EM, being stochastic and first-order,
  needs the most ($tilde$ hundreds) before the noise floor is low enough.
+ #strong[Steps to match 1000-step DDPM EM.] Both deterministic samplers reach baseline quality far
  sooner — typically $tilde 50$–$100$ steps for flow matching and DDIM — while DDPM EM needs its full
  $1000$.
+ #strong[At 100 steps.] Flow matching and DDIM are close to each other and to 1000-step DDPM EM. Since
  the #emph[same] model can be sampled to baseline quality with $10 times$ fewer steps using a better
  (deterministic) sampler, the low-step bottleneck is the #emph[sampler / discretization], not the model.
+ #strong[Best vs. fast.] For best quality regardless of speed, pick the lowest-KID cell (1000-step
  DDPM EM, or DDIM/flow at 100–200). For fast generation with acceptable quality, use flow matching at
  a handful of steps (or a single step after reflow, 6.C).

== 6.C (One-Step Generation after Reflow)
#emph[[run] Paste the one-step ($Delta t = 1$) reflow grid and fill the row below.]

#table(
  columns: 5,
  table.header([*Method*], [*Steps*], [*Sample grid*], [*FID*], [*Time (s/64)*]),
  [Rect. Flow — Reflow], [1], [_[run]_], [_[run]_], [_[run]_],
)

Reflow re-pairs each noise sample with its ODE output and retrains, straightening the trajectories. As
a result the one-step reflow FID is dramatically better than one-step rectified flow #emph[without]
reflow (whose single Euler step badly under-integrates a curved path). It remains somewhat worse than
1000-step DDPM EM, but comes close while using $tilde 1000 times$ fewer function evaluations — a large
quality-for-speed win.

== 6.D (Side-by-Side Qualitative Grid)
#emph[[run] Paste the $4 times 8$ grid produced by
#raw("sample.py --method all ... --seed 42") (rows: DDPM EM 1000, RF 100, RF 1, Reflow 1; same 8
seeds across all rows).]
Because the rectified-flow rows are deterministic ODE integrations of the #emph[same] velocity field
family, a fixed initial noise tends to map to semantically similar outputs (same class/shape) across
RF-100, RF-1, and Reflow-1, differing mainly in sharpness. DDPM EM is stochastic, so even with the same
initial $x_0$ its output can drift to a different instance. The flow models generally give cleaner edges,
while DDPM may show different texture/artifact patterns.

= 7

#emph[Part 7 uses OpenAI's guided-diffusion codebase on $256 times 256$ ImageNet models; runs are done
in Colab on an A100 (5–10 min each). Below are the commands and expected observations; paste each
$256 times 2048$ figure from the corresponding #raw(".npz") via
#raw("scripts/guided_diffusion_experiments.py").]

#raw("MODEL_FLAGS=\"--attention_resolutions 32,16,8 --class_cond False --diffusion_steps 1000 \\
  --image_size 256 --learn_sigma True --noise_schedule linear --num_channels 256 \\
  --num_head_channels 64 --num_res_blocks 2 --resblock_updown True --use_fp16 True \\
  --use_scale_shift_norm True\"
SAMPLE_FLAGS=\"--batch_size 8 --num_samples 8 --timestep_respacing 250\"")

== 7.1 (Unconditional Image Generation)
#raw("python scripts/image_sample.py $MODEL_FLAGS \\
  --model_path models/256x256_diffusion_uncond.pt $SAMPLE_FLAGS")
#emph[[run] Paste the $256 times 2048$ figure (8 unconditional samples).] Comments: samples are diverse,
globally coherent natural images; at $256 times 256$ they show realistic large-scale structure with
occasional implausible fine details, typical of an unconditional model with no class signal.

== 7.2 (Progressive Generation)
Use the progressive sampler (e.g. #raw("p_sample_loop_progressive")) and save 8 evenly-spaced
intermediates from $t = T$ (noise) to $t = 0$ (final). #emph[[run] Paste the 8-column timeline.]
Comments: early columns are pure noise; coarse layout/colors emerge first (low frequencies), then
progressively finer edges and texture — the reverse process is coarse-to-fine.

== 7.3 (Noise Interpolation)
Fix the seed so only the initial latent varies; pick $z_0, z_7 ~ cal(N)(0, I)$ whose samples differ
strongly, then sample from $z_i = (1 - i/7) z_0 + (i/7) z_7$, $i = 0, ..., 7$.
#emph[[run] Paste the 8-column interpolation.] Comments: the decoded images vary smoothly between the
two endpoints, indicating the model's latent$->$image map is continuous (semantically meaningful
interpolation rather than abrupt jumps).

== 7.4 (Conditional Image Generation)
#raw("CLASSIFIER_FLAGS=\"--classifier_scale 1.0 --classifier_path models/256x256_classifier.pt \\
  --classifier_attention_resolutions 32,16,8 --classifier_depth 2 --classifier_width 128 \\
  --classifier_pool attention --classifier_resblock_updown True \\
  --classifier_use_scale_shift_norm True\"
python scripts/classifier_sample.py $MODEL_FLAGS $CLASSIFIER_FLAGS \\
  --model_path models/256x256_diffusion_uncond.pt $SAMPLE_FLAGS")
#emph[[run] Paste 8 class-conditional samples (8 random ImageNet classes).] Comments: each image now
clearly depicts its target class; classifier guidance trades a little diversity for much stronger class
adherence relative to 7.1.

== 7.5 (Classifier Scale Sweep)
Sweep #raw("--classifier_scale") over 8 increasing values (e.g. $0.5, 1, 2, 4, 6, 8, 10, 12$) with the
same seed/initial state; produce 2 rows $times$ 8 columns. #emph[[run] Paste the $512 times 2048$
figure.] Comments: small scales give diverse but weakly class-aligned samples; increasing the scale
sharpens class identity and fidelity but reduces diversity and eventually introduces saturation/
over-guidance artifacts — the classic fidelity–diversity trade-off.
