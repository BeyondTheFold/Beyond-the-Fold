# Beyond the Fold Browsing Monitor

The monitor tracks:
- Duration of a page visit.
- The parent/child relationship between websites.
- The uniqueness of a page visit.
- Whether the page was reached via. a web search.

## Usage

To install and use the browsing monitor you need Safari and developer tools installed.
One cannot distribute self-signed web extensions and getting Apple to sign this
particular extension may be difficult due to perceived invasiveness. After
ensuring developer tools are installed open Safari and execute the following steps:

- Clone the project
- Go to Develop -> Show Extension Builder
- Click the plus sign in the bottom left corner to add an extension
- Select Add Extension 
- Select the directory in the cloned project called `Browsing-Monitor.safariextension`

The browsing monitor is now active and will automatically track you. This data
is being pushed to the SQLite database in Safari's localstorage.

