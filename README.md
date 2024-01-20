# TelemetryDeck Viewer

TelemetryDeck Viewer is a macOS and iOS app for interacting with [TelemetryDeck](https://telemetrydeck.com), displaying insights, showing groups and finding out more about your app's customers.

It is written by the TelemetryDeck community and usually lags a bit behind the *official* TelemetryDeck web app client, the [Dashboard](https://dashboard.telemetrydeck.com).

[TelemetryDeck](https://telemetrydeck.com) is an analytics service for apps and web apps. The makers of TelemetryDeck take great care to not ever process or store personally identifiable information, making TelemetryDeck one of the most privacy conscious analytics tools out there. 

## Contributing

We very much welcome your pull requests, both for bug fixes and also for changes and improvements. 

If you have suggestions or found a bug, please [open an issue](https://github.com/TelemetryDeck/TelemetryViewer/issues/new).

We'll mark issues that are especially well-suited for a contribution as [help wanted](https://github.com/TelemetryDeck/TelemetryViewer/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22).

If you want to add or modify a larger feature, please open an issue or a [GitHub discussions thread](https://github.com/TelemetryDeck/TelemetryViewer/discussions/new) first. We can discuss your feature idea with the community and the team and give you the green light so that you'll know with some certainty that your feature will be accepted. If you don't do this beforehand, we might have to reject your PR if it goes too far off our general roadmap.

(Of course you're always free to make your personal fork and use that, regardless of our feelings!)

## Building 

You will need to change the development team and bundle ID to build and run the app with your developer account:

1. Open `Common.xcconfig` and change the value of `DEVELOPER_BUNDLE_ID` to something unique to you.
2. Select all of the targets one by one and switch to "Signing & Capabilities", and set the "Team" to your development team. 

All targets should now build correctly for you.

**Note:** Do not commit these changes / include them in pull requests.

## Pull Request Process

1. Make sure the code you present is properly documented and tested.
2. Try to be as concise as possible. This makes it easier to discuss and evaluate the changes you propose. 
3. Be attentive. Pull requests are base for discussion and will require your feedback. 
4. Pull requests without further interaction may be closed at any point.
5. Do not include changes to `Common.xcconfig` or the `Info.plist` that only exist to allow you to build with your development team.

While your contribution will be under [the license of the project](./LICENSE), be aware that it will most likely end up being part of a compiled binary available in the Apple App Store.
