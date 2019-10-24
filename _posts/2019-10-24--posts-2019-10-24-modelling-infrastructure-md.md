---
layout: post
published: false
title: _posts/2019-10-24-Modelling-infrastructure.md
subtitle: 'Modelling Infrastructure, some considerations.'
date: '2019-10-24'
---
# Modelling infrastructure, some considerations.

Betting isn't my fulltime job, but I certainly treat it like I would any other investment, this entry is about the infrastructure I built around my own model to make things as easy as possible.

I run a low spec VPS hosted in Europe with Python, Gitlab, Mysql and Apache + PHP7 due to Gitlab[1] I run more RAM than I originally started with and I have an extra 10GB volume for the database. But the original spec would only cost me €2.99 per month and using one of these startup banks (growing in the UK and Europe at least) for the billing so there's no fees to consider and my exchange rate is the highest it can be.