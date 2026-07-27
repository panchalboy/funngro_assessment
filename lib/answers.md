# Funngro Mobile Engineering Assessment

## Part 1 – Code Review
1. API Call Inside build() (Highest Impact)

Problem Code:
api.fetchEarnings(widget.userId).then((data) {
  setState(() {
    earnings = data;
    loading = false;
  });
});

User Impact:
   The screen will make repeated network requests, causing unnecessary API calls, increased battery and data usage, UI flickering, and poor performance.
Why:
   The build() method can be called many times during the widget lifecycle. Placing the API call inside build() causes a new network request on every rebuild.
Solution:
   Move the API call to initState() or a controller (onInit()) so it executes only once when the screen is created.

2. Stream Subscription Inside build()
Problem Code

api.walletUpdates(widget.userId).listen((update) {
  setState(() {
    earnings.insert(0, update.toEarning());
  });
});

User Impact:
   Multiple stream subscriptions are created, resulting in duplicate updates, memory leaks, unnecessary rebuilds, and degraded performance.
Why:
    Every time the widget rebuilds, a new stream subscription is created while the previous subscriptions remain active.

Solution:
    Create the stream subscription in initState(), store the returned StreamSubscription, and cancel it in dispose().

3. Stream Subscription Never Cancelled
Problem Code:

api.walletUpdates(widget.userId).listen(...);

User Impact:
   The stream continues listening even after the screen is closed, causing memory leaks and unexpected callbacks.
Why:
    The returned StreamSubscription is never stored or cancelled.
Solution:
    Store the StreamSubscription and cancel it in dispose().

4. Using SingleChildScrollView + Column for a Large List
Problem Code:

SingleChildScrollView(
  child: Column(
    children: earnings.map((e) {
      ...
    }).toList(),
  ),
)

User Impact:
    Rendering 800–3,000 items at once will consume excessive memory, cause janky scrolling, and may freeze low-end devices.
Why:
    Column builds every child widget immediately instead of building only the visible ones.
Solution:
    Replace it with ListView.builder() for lazy loading of list items.

5. Building the Entire List Using map().toList()

Problem Code:

children: earnings.map((e) {
  return EarningTile(...);
}).toList(),

User Impact:
    Every rebuild recreates all list items, increasing CPU usage and reducing scrolling performance.
Why:
    map().toList() rebuilds every widget whenever the parent widget rebuilds.
Solution:
        Use ListView.builder() so only visible items are built.

6. Expensive formatCurrency() Inside build()
Problem Code:

final formatted = formatCurrency(e.amount);

User Impact:
    Formatting every item during each rebuild can significantly slow down rendering, especially with thousands of list items.
Why:
    formatCurrency() performs locale parsing and is executed every time the widget rebuilds.
Solution:
   Cache the formatted value or reuse a formatter instance instead of formatting every item during each rebuild.

7. Full Screen Rebuild Using setState()
Problem Code

setState(() {
  e.detail = detail;
});

User Impact:
    Loading the details of a single earning unnecessarily rebuilds the entire screen, reducing UI performance.
Why:
    setState() rebuilds the complete widget tree even though only one item has changed.
Solution:
    Update only the affected item or avoid rebuilding the parent widget if the detail is only needed for navigation.

8. Mutable Model
Problem Code

e.detail = detail;

User Impact:
     Directly modifying model objects makes state management harder and increases the risk of inconsistent UI updates.
Why
   The existing object is mutated instead of creating a new immutable object.
Solution:
    Use immutable models and create a new object whenever data changes.

9. Risk of Calling setState() After Widget Disposal
Problem Code:

setState(() {
  earnings = data;
});

User Impact:
    The application may throw a setState() called after dispose() exception if the user leaves the screen before the asynchronous operation completes.
Why:
    The API request can complete after the widget has already been disposed.
Solution:
    Check mounted before calling setState() or manage the state inside a controller with proper lifecycle handling.

10. Missing Error Handling (Low Priority)
Problem Code

api.fetchEarnings(widget.userId).then((data) {
  setState(() {
    earnings = data;
  });
});

User Impact:
    If the API request fails, the user receives no feedback and cannot retry the operation.
Why:
    The asynchronous call is not wrapped in error handling and no error state is displayed.
Solution:
    Handle exceptions using try-catch and display an appropriate error state with a Retry option.


######

Part 3 — Production scenario

Hi, I wouldn't halt the rollout immediately. Since it's currently at 20%, I'd keep it at 20% while we investigate rather than increasing it. The drop in crash-free users from 99.6% to 98.1% is significant, so I'll check the root cause in Crashlytics first. If the crash is widespread or affects core app usage, we'll halt the rollout and prepare a hotfix. If it's limited to specific devices or conditions, we'll keep the rollout at 20%, release a fix (v6.4.1), and continue the rollout only after confirming the issue is resolved.

####

## Part 4 – Walkthrough Recording

Loom Recording:
https://www.loom.com/share/18cedd9b18dc4122b7d783efb544f01b