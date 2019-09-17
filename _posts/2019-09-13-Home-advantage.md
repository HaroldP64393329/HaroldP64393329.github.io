---
layout: post
title: Home Advantage
published: true
subtitle: Does it exisit in CounterStrike?
date: '2019-09-14'
---
How do you quantify something for inclusion in a model? Model or modelling shouldn't be a new term for anyone involved in the domain of predicting sporting events, just don't confuse it with *data science*, we're not selling adverts... 

Typically people fall into two categories, Computer Group[1]: The Next Generation and No Computer Group: I can use my brain. I'm poking fun but there are a lot of savvy people who may lack the ability but fundamentally understand the benefit of a model, there's also those who believe it just cannot be done due to *reasons*.

Hopefully what I'm going to outline here, is less about the accuracy of the predictor but the process by which you can form a statistically supported opinion on if X is related to Y. Let's get to it.

## Background

The idea of home advantage is pretty simple, do sports teams have greater success at home? The general answer is yes they do, in quantifying why researchers have findings such as *Referee decisions concerning penalty decisions are also more likely not to be correct when the match takes place in a stadium without a running track.* (Dohmen, 2005, p. 2)

CounterStrike has no ingame referee, the server with preconfigured settings acts as judge, jury and executioner (of code). And CounterStrike games have no home, so whats left?

LAN is the truest home of the game CounterStrike, not for its teams but for the game itself. The ability to run unencumbered on a LAN gives the full experience of CounterStrike, since the release of QuakeWorld (a Quake MP client) in 1998, client-server architecture has always been a technical challenge for fast-paced multiplayer games. Anyone with further interest in this area I suggest [*Fast-Paced Multiplayer (Part I): Client-Server Game Architecture*](https://www.gabrielgambetta.com/client-server-game-architecture.html) (Gambetta, Unknown) and [*I Shot You First: Networking the Gameplay of HALO: REACH*](https://www.gdcvault.com/play/1014345/I-Shot-You-First-Networking) (Aldrigde, 2011)

So what about the teams themselves? At the StarLadder Berlin Major, the final 16 didn't have 1 single German representative. Wether played online or LAN, there's next to nothing that would realistically replace a home stadium. What we do have in it's place is the veto system employed by numerous Tournament Organisers (TOs).

## The Question

Does the traditional belief of an underlying advantage for the home team have statistical significance when determined as the map chosen in a Best of 3 (bo3)?

## Hypothesis

H0 (Null hypothesis): there is no significant difference in the odds of winning the map picked by 'home' team vs. not having picked the map. 
HA (Alternative hypothesis): there is a statistically significant difference in the odds of winning the map picked by 'home'.

## Data

All results will be from a Best of 3 (bo3) game. Assuming the veto data is available it is very simple to identify the team which picked each map, the third map will be disregaded as neutral ground. All results are from 2019. 

### There's always a problem.

Being very familar with the population I knew full well, this would be problematic. Consider the following mean and standard deviation (sd) `9.271394`, `12.44979` respectively. Seems skewed to put it lightly. 

![Total games played histogram]({{site.baseurl}}/img/hfa_histogram_1.png)
*Fig. 1 histogram of games played count, binned simply by whole number [1,2,3]*

The above histogram illustrates the problem, to further illustrate the problem I picked a team at random. This group of 5 players calling themselves `chebran` played exactly 2 games during the DreamHack Open qualifier (France), they played a bo1 and a single bo3 to qualify. According to a HLTV news article they reached out publically for sponsorship and gained this in the form of a PC parts company called Instinct. 

For the DreamHack Open Tour they played under the name `Instinct Gaming` being eliminated in the Group Stage, which for the DreamHack format is again, 1 bo1 and 1 bo3. 4 months later 3 of the 5 people on this *team* appeared in another tournament qualifier under the name `FiveG` but only in 1 bo1.

Let's take another example, this time it's a stable roster currently under the name Aristocracy, they've so far in 2019 also competed as Kinguin and devils.one, totalling all these games (bo3) together raises them up from just 20 games to 37.

I added some adjustments which tracks groups of players through the year and groups together results where they played together but did so under different team names, it's an imperfect solution as there are other considerations but for the basis of this article, it will be "good enough".

### Sample size

In 2019 there were 3804 bo3s which fit my criteria, I don't need every result in the population to test independence, `R` or `python` will take all the grunt work out.

{% highlight python linenos %}
import numpy as np
from statsmodels.stats.power import TTestIndPower

onep = TTestIndPower()

# win %
mean_home = 0.5507361
mean_away = 0.4492639

difference = 0.053252

# sd
# in the data they're identical
sd = 0.4974845849

# simplified cohen's d for equal sample sizes
# sqrt((sd1^2) + (sd2^2) / 2)
sd_pooled = np.sqrt(sd/2)

cohens = difference / sd_pooled
alpha = 0.05
power = 0.95
ratio = 1.0 # 3804/3804

# get sample size
sample_size = onep.solve_power(cohens, power=power, nobs1=None, ratio=ratio, alpha=alpha)
sample_size
2280.6432656464485

{% endhighlight %}

In order to be confident (95% confident or *alpha*) that H0 can be rejected and be confident (95% again or *power*) that it wasn't a false negative (home advantage exists but it was missed). 61% of the results need to sampled. And the data is **hella ugly** needs some help getting into shape.

### Bootstrapping

Everyone is throwing around machine learning lingo nowadays so why should I be any different? Anyway...

{% highlight python linenos %}
sample_home = []
sample_away = []
sample=2281

for _ in range(1000):
	boot_mean = np.random.choice(ht_win_array, size=sample).mean()
    sample_home.append(boot_mean)
    
for _ in range(1000):
	boot_mean = np.random.choice(at_win_array, size=sample).mean()
    sample_away.append(boot_mean)
 
# Our survey says?
statst.ttest_ind(sample_home, sample_away)
Ttest_indResult(statistic=214.41707249765153, pvalue=0.0)

{% endhighlight %}

![article-home-adv-win-rates.png]({{site.baseurl}}/img/article-home-adv-win-rates.png)

### In conclusion

With a `p-value < 0.01` HA can be accepted, there is a statiscal advantage to the map picked and the odds of winning it. Which sounds pretty obvious to anyone familiar with CS, but obvious doesn't really cut it in statistical terms. And if the end goal is to quantify something in a model that will be used for sports prediction, you want to be sure *something* exists and by what confidence.

___

**References**

Dohmen, Thomas. Social Pressure Influences Decisions of Individuals Evidence from the Behavior of Football Referees. IZA, 2005.

HLTV (2019). *Instinct to support chebran at DreamHack Open Tours*. Retrieved from https://www.hltv.org/news/26703/instinct-to-support-chebran-at-dreamhack-open-tours
