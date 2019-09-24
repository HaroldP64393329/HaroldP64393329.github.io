---
layout: post
title: Butter up your P&L
published: false
subtitle: Do you loathe admin?
date: '2019-09-24'
---
The humble P&L is undoubtably one of the most important items you need to have in your inventory, one of the others being bankers. Everyone is well aware of the need and as is custom, a few services exist which offer a P&L like service with bells and whistles strapped on to entice people to spend money.

To the best of my knowledge, there isn't a free or *freemium* service which will automatically grade your picks, they may even suspend your account if you fail to do so. Paid services may do, but for myself in paticular I've never seen one which would do this for esports. Also I don't really have any interest in publishing my locks...

## For a one time fee

Of nothing, we can create our own automatically graded P&L. Utilising Google sheets and the `python` packages [BeautifulSoup](https://pypi.org/project/beautifulsoup4/), [gspread_pd](https://pypi.org/project/gspread-pandas/) and [pyppeteer](https://pypi.org/project/pyppeteer/). 

I'm going to create a P&L based on football (soccer) and pull scores down from the Premier League results section at [FlashScore.com](https://www.flashscore.com/football/england/premier-league/results/), I picked FlashScore for a few simple reasons

- **Simple results layout** Navigating to their page for current season (2019-2020) results on the English Premier League, it's a simple 1 page layout, previous weeks are eventually cached away and served by clicking a `show more` link but there are better sources specifically for historic football data which don't require scraping.

- **Clean URLs** FlashScore employs some very simple conventions in their URLs, take for example *football/england/premier-league/*, if I wanted instead the National League it becomes *football/england/national-league*. Contrast this against WhoScored who also add in their specific unique identifiers the same division becomes *Regions/252/Tournaments/2/England-Premier-League*

### Admin

I will attempt to document as much as possible, but on an A-Z style guide, you should consider this guide starting somewhere around **X**. 

- `gspread_pd` requires a token in order to pull down your spreadsheet. Setup is available via [Using OAuth2 for Authentication](https://gspread.readthedocs.io/en/latest/oauth2.html). **You need to share the spreadsheet as well from google sheets (gsheets) using the email contained in the json key** e.g. someone\@someone-1234.iam.gserviceaccount.com

- New to scraping, not new to scraping. Refresh yourself [How to prevent getting blacklisted while scraping](https://www.scrapehero.com/how-to-prevent-getting-blacklisted-while-scraping/)

- I am **not** making use of proxies with this.


## Inspect element

The inspect element tool isn't just good for degenerates to fake their betting slips, it's also handy in pulling out specifics about a website under the hood.

![pnl_inspect_element_1.png]({{site.baseurl}}/img/pnl_inspect_element_1.png)
*Fig. 1 Each result row has some common classes*

Clicking around the first result row shows me the following in Fig. 1 there's a `div` (think of it as a container if you're familiar with html) with a unique identifier (g_1_4tJXu8C7) and the classes `event__match event__match--static event__match--oneLine`.

Classes are none unique and should be style elements, if thats true or not in this case doesn't matter, we can use them as selectors in BeautifulSoup.

![inspect element]({{site.baseurl}}/img/pnl_inspect_element.png)
*Fig. 1 The Spanish Inquisition*

What the above shows me is as well as having a unique identifier (g_1_4tJXu8C7) the row also has the classes `event__match event__match--static event__match--oneLine`. I can feed this to my scraper and see what it brings back.

{% highlight python linenos %}
from gateway import pypp # custom package check the repo in the appendix
from asyncio import get_event_loop as gel

def main():

	# Using the lxml parser for BeautifulSoup
    # attr is the classes discovered earlier as containing each row of data
    # path and the True flag take a fullsize screenshot of what the browser is seeing
	url = 'https://www.flashscore.com/football/england/premier-league/'
    lib = 'lxml'
    attr = 'event__match event__match--static event__match--oneLine'
    path = 'pypp.png'
    
    view_source = gel().run_until_complete(pypp(url, lib, attr, path, True))
    
    

{% endhighlight %}
