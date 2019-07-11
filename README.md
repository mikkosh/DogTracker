# DogTracker
Connect IQ DogTracker application for Garmin devices

## Why?
It enables real time sharing of dog (or other tracked asset) location data. It's also a proof of concept :)

## What it does
The application can be installed on a Garmin Connect IQ compatible device that can connect to a handheld dog tracker. I personally use Garmin Astro GPS tracker and a Garmin Fenix 5X plus watch.

Watch application receives the asset (dog) location data via Ant+ messages from Astro. It then displays the data (there's an asset list view and a map view) and if the application is configured (a beacon URL is set in Garmin Connect App settings) it will send the asset locations to the configured URL in a HTTP POST message. The sample beacon saves the location data in a JSON file and and when the script is accessed from the web, displays a map where the asset locations can be seen.

## Dependencies
- This app uses the AntAssetTracker monkey barrel that can be found here (https://github.com/mikkosh/AntAssetTracker). The barrel location must be configured in the Eclipse settings before compiling the app.
- To fully utilise the possibilities of the DogTracker, the user should set the beacon url in Garmin Connect and set up a working beacon (there's a bad sample included) somewhere to collect and display the data.

## Note
- The app is not "production ready", there's a ton of stuff that could be better. I've tested it with several dog traking collars (DC 40 and T5) and it can track multiple collars.
- The beacon sample code is a quick draft and should not be put on a live server. It's meant to be used as a local testing script and barely works.
