---
layout: post
title: Butter up your P&L
published: false
subtitle: Do you loathe admin?
date: '2019-09-24'
---
The humble P&L is undoubtably one of the most important items you need to have in your inventory, one of the others being bankers. Others are well aware of the need for this item and in the pursuit of their profit, they offer services part ready made P&L and part premium services in the form of selling picks or access to data.

To the best of my knowledge, there isn't a free or *freemium* service which will automatically grade your picks, they may even suspend your account if you fail to do so yourself. Paid services may do, but for myself in paticular I've never seen one which would do this for esports. So I made my own.

My own solution was different to what I'm proposing here, being based on MySQL, Python and PHP. I'm going to use Google Sheets in this article, spreadsheets should be familiar to anyone with a P&L and in this perfect computer world I've just dreamt up, we don't need to back it up. **But** you should if it's truly important to you.

## For a one time fee

Of nothing, we can create our own automatically graded P&L. Utilising Google sheets and the `python` packages [BeautifulSoup](https://pypi.org/project/beautifulsoup4/), [gspread_pd](https://pypi.org/project/gspread-pandas/) and [pyppeteer](https://pypi.org/project/pyppeteer/). 

I'm going to create a P&L based on football (soccer) and pull scores down from the Premier League results section at [FlashScore.com](https://www.flashscore.com/football/england/premier-league/results/), I picked FlashScore for a few simple reasons

- **Simple results layout** Navigating to their page for current season (2019-2020) results on the English Premier League, it's a simple 1 page layout, previous weeks are eventually cached away and served by clicking a `show more` link but there are better sources specifically for historic football data which don't require scraping.

- **Clean URLs** FlashScore employs some very simple conventions in their URLs, take for example *football/england/premier-league/*, if I wanted instead the National League it becomes *football/england/national-league*. Contrast this against WhoScored who also add in their specific unique identifiers the same division becomes *Regions/252/Tournaments/2/England-Premier-League*

### Admin

I will attempt to document as much as possible, but on an A-Z style guide, you should consider this guide starting somewhere around **X**. 

- `gspread_pd` requires a token in order to pull down your spreadsheet. Setup is available in this guide [Using OAuth2 for Authentication](https://gspread.readthedocs.io/en/latest/oauth2.html). You need to share the spreadsheet as well from google sheets (gsheets) using the email contained in the json key e.g. someone\@someone-1234.iam.gserviceaccount.com

- New to scraping, not new to scraping. Refresh yourself [How to prevent getting blacklisted while scraping](https://www.scrapehero.com/how-to-prevent-getting-blacklisted-while-scraping/)

- I am **not** making use of proxies with this.

## Inspect element

The inspect element tool isn't just good for degenerates to fake their betting slips, it's also handy in pulling out specifics about a website under the hood.

![pnl_inspect_element_1.png]({{site.baseurl}}/img/pnl_inspect_element_1.png)
<p align="center">*Fig. 1 Each result row has some common classes*</p>

Clicking around the first result row shows me the following in Fig. 1 there's a `div` (think of it as a container if you're not familiar with html) with a unique identifier (g_1_4tJXu8C7) and the classes `event__match event__match--static event__match--oneLine`.

Classes are none unique and should be style elements, if thats true or not in this case doesn't matter, we can use them as selectors in BeautifulSoup.

![inspect element]({{site.baseurl}}/img/pnl_inspect_element.png)
*Fig. 2 The Spanish Inquisition*

This second div is a larger container for the whole data table, I've shown it here as later on it's a quick workaround to one of the results being missing, but common in most sites now there will be a container div with other smaller divs nested within it.  

## Pulling down data

The behaviour of the site makes me believe it's running some kind of javascript framework, I downed tools on web development a long time ago, so all I can really say on the matter is, sites using these frameworks won't render fully or at all when using requests or similar module. This is also true if you're using `R` for scraping.

I'm using pyppeteer, a python clone of the node.js api puppeteer. There's no reason you couldn't substitute this for Selenium since pyppeteer seems like a hobby project which may or may not receive further development in the future.

{% highlight python linenos %}
from gateway import pypp # custom package check the repo in the appendix
from asyncio import get_event_loop as gel

def main():

	# Using the lxml parser for BeautifulSoup
    # attr is the classes discovered earlier as containing each row of data
    # path and the True flag take a fullsize screenshot of what the browser is seeing
	url = 'https://www.flashscore.com/football/england/premier-league/'
    lib = 'lxml'
    attr = 'sportName soccer'
    path = 'pypp.png'
    
    view_source = gel().run_until_complete(pypp(url, lib, attr, path, True))
    
    return

{% endhighlight %}

Once the browser has finished rendering it will drop a screenshot in the working directory, I check it to make sure I haven't been redirected to another page and it's not being stopped by a CAPTCHA. 

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
    
    # Pull out every result row from the main container
    # bs4.select returns a list
    rows = view_source.select('.event_match')
    
    # empty list
    results = []
    
    # dump 1 row and look at each class
    for row in rows[0]:
    	print(row)
    
    # loop over each result in rows and clean up
    for row in rows:
    	unique_id = str(row['id']).replace('g_1_','') # more on this later
        
        # .select_one returns the first tag that matches
        # it's also not a list - get_text() will strip away any html for us.
        datetime = row.select_one('.event__time').get_text()
        home_team = row.select_one('.event__participant--home').get_text()
        away_team = row.select_one('.event__participant--away').get_text()
        
        # No other <span> elements exist so can safely use .select
        # and return a list. From said list, use slicing to get home and away score
        home_goal = row.select('span')[0]
        away_goal = row.select('span')[1]
        
        results.append([unique_id, datetime, home_team, away_team, home_goal, away_goal])
    
    return

{% endhighlight %}

If you print the list what you'll get is almost there, the `<span>` tags haven't been removed, and there's this awful time format they've decided to use. I've added two functions to chop this up and return something cleaner.

{% highlight python linenos %}
import re
from dateutil.parser import parse

def isodate(datelist):
	return parse(datelist[0] + '.' + datelist[1] + '.2019', dayfirst=True)

def strip_html(this):
	expression = re.compile(r'<.*?>')
    return expression.sub('', str(this))

# the loop would now include/change

for row in rows:
	timestamp = isodate(str(datetime).split('.'))
    home_goal = strip_html(row.select('span')[0])
    away_goal = strip_html(row.select('span')[1])

print(result[0])
# ['4tJXu8C7', datetime.datetime(2019, 9, 22, 0, 0), 'Arsenal', 'Aston Villa', '3', '2']

{% endhighlight %}
