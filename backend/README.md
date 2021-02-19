This is the backend API for nakiri. It is intended to be hosted on heroku.


If you need force-push master, in the root of the repo (not `/backend`) run:

git push heroku `git subtree split --prefix backend master`:master --force

otherwise, a simple subtree push should be fine:

git subtree push --prefix backend heroku master
