# Nakiri

## Because friends send friends spammy-ass links.

Nakiri is a macos app that runs silently in the background, cleaning up URLs 
that land on your clipboard so you look like a pro 😎

It removes clicktrackers (URLs that "wrap" other URLs so that they can track 
which links you follow off of the page) and unneccessary query params that can 
associate your movements online to other users, particular advertisment 
campaigns, where you've been on the web, etc.

### Installing

The only way to install Nakiri right now is to build it from scratch using xcode.
There are releases but they're not properly signed.


### Building and Deploying

**www.nakiri.app**

Github deploys this using Pages. Any time you change contents of docs and commit
it to master, the changes will be instantly deployed to www.nakiri.app. Tread
lightly!

The SlicerDefinitions.json file is used by the macos app and should not be moved.
It is used in two ways.

 # For being served over the web
 # As a build step, it is copied from the docs location into the macos app at
   build time. docs/SlicerDefinitions.json is the source of truth of the 
   definitions lib.

**api.nakiri.app** aka backend

The backend (api server) is in the `backend` folder. To run it you should be able
to do the following:

```
cd backend
python setup.py develop
PYTHONPATH=nakiri/ gunicorn nakiri:app
```

In order to push any changes to heroku you can use `make heroku-deploy`. Make 
sure to have commited your changes first! It'll push only the `backend/` folder
to Heroko for deployment.


**macos**

Shouldn't be much to say. You should be able to open this bad boy in xcode and
compile it manually.

As per the above section, the rules engine is copied in from 
docs/SlicerDefinitions.json at buildtime.

The versioning for the app is done both by git tag (git tags refer to app version
at this time, not website or backend version). The app has an update notification
system built into it. It will show that an update is available if the app is
running an older version than what is available on the releases page.
