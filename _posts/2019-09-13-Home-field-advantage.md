---
layout: post
title: Home Field Advantage
subtitle: Does it exist in CounterStrike?
published: true
---

It's a pretty simply principle, that is, until you look closer and uncover findings such as; *Referee decisions concerning penalty decisions are also more likely not to be correct when the match takes place in a stadium without a running track.* (Dohmen, 2005, p. 2). And thus starts a road of data mining, which stadiums have running tracks, was there mention to the number of lanes? All in an attempt to better quantify the simple Home Field Advantage (HFA). If that's you, stop. Don't do it yourself, come back from the edge.

## Exploring advantages in CounterStrike

Given that the Home Advantage is a given in any simple rating system, can it applied to CounterStrike? Home Advantage can be defined for our purposes as carrying a statistically significant advantage over playing at an away venue. 

What can be considered *Home* in the game of CounterStrike? 

LAN is the truest home of the game CounterStrike, not just for its teams but for the game itself. The ability to run unencumbered on a LAN gives the full experience of CounterStrike, since the release of QuakeWorld (a Quake MP client) in 1998, client-server architecture has always been a technical challenge for fast-paced multiplayer games. Anyone with further interest in this area I suggest [*Fast-Paced Multiplayer (Part I): Client-Server Game Architecture*](https://www.gabrielgambetta.com/client-server-game-architecture.html) (Gambetta, Unknown) or [*I Shot You First: Networking the Gameplay of HALO: REACH*](https://www.gdcvault.com/play/1014345/I-Shot-You-First-Networking) (Aldrigde, 2011)

In the final stage of the SL Berlin Major we saw representatives from majority American, Australian, Brazilian, Danish, Finnish, French, Kazakh, Russian, Serbian and Swedish teams. Along with mixed European teams (FaZe, mousesports) while not researched here, I suggest that the physical location be disregarded, further investigation may show some weak positive or negative correlation it would also remove the ability to measure online play.  

It would possibly be fruitless to define Home Advantage in the traditional terms used by other sports, and it would definitely overlook an obvious feature of tournament play in CS:GO, namely the veto.

I suggest Home Advantage be defined as the `map chosen` in the veto process of a `Best of 3 (Bo3)`, will carry an `advantage` for the team choosing the map. Best of 1 (Bo1) will be taken as neutral ground and Best of 5s (Bo5) are not common enough in CounterStrike yet to be considered.

### The Data

Using a database of results, and using `year = 2019` as our first filter, we get the following groups

| Results by Format |||
| --- |:--:|:--:|
| Format | Count | Unique Teams |
| Best of 5 | 46 | 73 |
| Best of 2 | 148 | 49 |
| Best of 1 | 2072 | 503  |
| Best of 3 | 2939 | 739 |
*Fig. 1 Results grouped by format*

On the face of it, 739 unique teams is a good chunk, compared with a quick skim of 7 professional football leagues in 7 European Countries yields only 120 teams. Spend enough time with the data (*like me, I don't suggest it*) and you'll soon realise if you hadn't before, that a large % of these *teams* are infact going to be mix teams which have come together for a short period of time - typically the first few rounds of a tournament HLTV deems worth recording. 

Including these teams in our population is going to create noise as they will only play a small number of games, consider the shape of this histogram below.

!missing
*Fig. 2 Data binning decided with the Freedman–Diaconis rule*

Dealing with this amount of skew, is beyond the scope of this mini series. Instead I'll suggest an alternative data set. 

The 2nd data set still taken from `2019` further filtering was done by taking a list of HLTVs Top 30 rankings at the end of each month - current week was used for September. Which gives us HLTV Top 30 "Top 47" and passed as 2 lists meaning all results are between teams which featured in the Top 30 in 2019. Maps which ended in overtime were also removed.

| Alternative Data Set |
| --- |:--:|:--:|
| Format | Count | Unique Teams |
| Best of 3 | 1001 | 47 |
*Fig. 3 Results grouped by format*

Using the available veto data, teams have been swapped to the designations Home & Away, we can see both 3DMAX and AGO have swapped roles between Inferno and Overpass. Spirit and Syman only have 1 map, the 2nd went into overtime. 

```
>>> df.head()
      home_t     away_t  map_name  home  away
0      3DMAX        AGO   Inferno    16    12
1        AGO      3DMAX  Overpass    13    16
2     Spirit      Syman     Dust2    16    11
3  Winstrike    AVANGAR     Dust2     5    16
4    AVANGAR  Winstrike     Cache    13    16
```

Making use of `pandas` a 2nd dataframe is produced with Home Avg Win % and Away Avg Win % for each team. 


{% highlight python linenos %}
# Create a unique list of teams from both columns
teams = pd.unique(df[['home_t','away_t']].values.ravel('K'))

# Loop through each team
for team in teams:
  # Create a panda series holding the value True or False
  home_total = df.apply(lambda t: True if t['home_t'] == team else False, axis=1)
  home_win = df.apply(lambda t: True if t['home_t'] == team and t['home'] == 16 else False, axis=1)
  
  # Count all the values which were true
  home_total_count = len(home_total[home_total == True].index)
  home_win_count = len(home_win[home_win == True].index)
  
  # 60% of the time, it works every time.
  home_win_percentage = home_win_count/home_total_count
  
  # Same logic for away teams, finally push to a list and pass to pandas.

# Peek at the final result
df.head()
        team  home  away
0      3DMAX  0.50  0.33
1        AGO  0.50  0.28
2     Spirit  0.29  0.24
3  Winstrike  0.34  0.50
4    AVANGAR  0.47  0.48
{% endhighlight %}

### Testing for Validity

If formulas look Greek to you, then `python` or `R` have you covered. I'd say if you're new to statistics, it's important to understand the concepts here than it is the pure maths, since either language will do the math for you. But do not use them long term as a crutch.

{% highlight python linenos %}
import pandas as pd
from scipy import stats
df = pd.read_csv("load/t_test.csv")
stats.ttest_ind(df['home'], df['away'])
Ttest_indResult(statistic=2.177434703635481, pvalue=0.032006620596829065)
{% endhighlight %}

The result is in and `P` < `0.05` therefore the null hypothesis can be rejected and accept my suggested alternate. There is a home **map** advantage at play in our results.

___
**References**

Dohmen, Thomas. Social Pressure Influences Decisions of Individuals Evidence from the Behavior of Football Referees. IZA, 2005.
