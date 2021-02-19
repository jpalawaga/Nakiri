#!/usr/bin/make

heroku-deploy:
	git subtree push --prefix backend heroku master
