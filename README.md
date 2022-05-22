# APOD
A quick one page app for NASA's APOD

How to run: You can directly launch the Xcode.proj file and run it in any simulator. To run on a device, you need to go to "Signing and Capabilities" tab of project settings and add your own provisioning profile.

# Improvement Areas
1) Better UI: Wasn't sure if SwiftUI was allowed, so used UIKit. Given more time, would focus on improving the UI
2) Better errorHandling: If we get an error from server, ideally should parse out the error and show that to user instead of just code
3) Timezones: NASA API seems to be hosted in US Central TimeZone, would need to fix this by the dateFormatter timezone.
4) APIKey: Currently using the demo key, will need to change to proper developer key for a full fledged app.
5) URL creation is currently simple and hence hardcoded, this can be moved to separate function in the future to add functionality.
