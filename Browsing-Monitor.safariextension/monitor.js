// ----------------------------------
// Web Browsing Visualization Monitor
// ----------------------------------

// debug flag
var debug = true;

// array to hold all session node objects
var sessions = [];

// flag for identifying child sessions
var childLinkFollowed = false;

// flag for identifying children within a parents domain
var childWithinDomain = false;

// index pointing to current tab
var currentTab = null;

// array of currently opened tabs
var tabs = [];

// previous session index visited on tree
var previousIndex = null;

// current session visited on tree
var currentIndex = null;

function debugLog(output) {
  if(debug === true) {
    console.log(output);
  }
}

function loadSessions() {
  debugLog('Loading sessions from local storage');
  sessions = JSON.parse(localStorage.sessions).sessions;

	console.log(sessions);

  if(sessions === null) {
    sessions = [];
  }
}

var getLocation = function(url) {
  var result = document.createElement('A');
  result.href = url;
  return(result);
}

function createNode(parent, children, current, previous, url, withinParentDomain) {
  return({
    'url': url,
    'sessionStart': new Date(),
    'sessionDuration': 0,
    'parent': parent,
    'withinParentDomain': withinParentDomain,
    'children': children,
    'current': true,
    'previous': false
  });
}

function calculateDuration(index) {
	if(index !== -1 && index !== null) {
		sessions[index].sessionDuration += new Date() - sessions[index].sessionStart;
	}
}

function handleCommand(event) {
	if(event.command == 'save') {
		saveSessions();
	} else if(event.command == 'clear') {
		if(confirm('Are you sure you want to clear all of the sessions?')) {
			sessions = [];
			tabs = [];
			currentTab = null;
			currentIndex = null;
			previousIndex = null;
			localStorage.sessions = '{\'sessions\': []}';
			debugLog('Cleared sessions');
		}
	}
}

function saveSessions() {
  output = {'sessions': []};
	var data = '';

  for(var i = 0; i < sessions.length; ++i) {
    var session = sessions[i];

		// insure root nodes parent's are -1 instead of null
		if(session.parent === null) {
			session.parent = -1;
		}
 
    output.sessions.push({
			'index': i,
      'url': session.url, 
			'tab': session.tab,
      'sessionStart': session.sessionStart, 
      'sessionDuration': session.sessionDuration, 
      'parent': session.parent, 
      'withinParentDomain': session.withinParentDomain,
      'children': session.children
    });
  }

	data = JSON.stringify(output);

  debugLog('Session saved');
  localStorage.sessions = data;
	debugLog(data);
}

function getRoot(sessions, index) {
  if(index === -1 || 
		 index === null || 
		 sessions[index] === null ||
		 typeof sessions === undefined || 
		 typeof index === undefined ||
		 typeof sessions[index] === undefined) {

    return(null);
  }

  var i = index;
	var iterationCount = 0;
	var maxIteration = sessions.length;

	// until root node of session at index is found
	while(true) {

		// detect cycle
		if(iterationCount >= maxIteration) {
			debugLog('error: getRoot(...) stuck in cycle at ' + String(i) + ' and ' + String(sessions[i].parent));
			return(null);
		}

		// if root session reached then return it's index
		if(sessions[i].parent == -1) {
			return(i);
		}

		// increment iteration count for cycle detection
		++iterationCount;

		// move to the next parent node in tree
		if(typeof sessions[i].parent !== undefined) {
			i = sessions[i].parent;
		} else {
			debugLog('error: getRoot(...) found a session with an undefined parent at index' + i);
			break;
		}
  }

	// in the event that finding the root failed
  return(null);
}

function getPreviousIndex(tab) {
  debugLog('Searching for previous tab');

	// search all sessions
  for(var i = 0; i < sessions.length; ++i) {

		// previous session will have same tab index and have previous flag set as true
    if(sessions[i].previous === true && sessions[i].tab = tab) {

      debugLog('Found previous node at ' + String(i));
      
			// return the session
      return(i);
    }
  }

	// failed to find previous session
  return(null);
}

function openHandler(openEvent) {
  debugLog("Tab/Page Open");

  // when new tab or window is opened push parent object
  sessions.push({
		'tab': tabCount,
    'url': openEvent.target.url,
    'sessionStart': new Date(),
    'sessionDuration': 0,
    'parent': -1,
    'withinParentDomain': false,
    'children': [],
    'current': true,
    'previous': false
  });

	// previous index should be null when a new tab/window opens
  previousIndex = null;

	// current index is the last element in the sessions array	
  currentIndex = sessions.length - 1;

	// current session should be stored in tab
	tabs.push(currentIndex);

	// set current tab to newly created tab
	currentTab = tabs.length - 1;
}

function closeHandler(closeEvent) {
  debugLog("Tab/Page Open");

	// tab should be removed from tab list
	tabs.splice(currentTab, currentTab + 1);

	// current tab should be set to null
	currentTab = null;

	// save sessions upon closing a tab/window
  saveSessions();
}

function activationHandler(activationEvent) {
  debugLog("Tab/Page Activation");

	// search for session in tabs with the same url and tab index
	for(var i = 0; i < tabs.length; ++i) {
		if(activationEvent.target.url === sessions[tabs[i]] && 
			 sessions[tabs[i]].tab === i) {

			// current is the session pointed to by tabs list
			currentIndex = tabs[i];
			
			// define current tab
			currentTab = i;
		}
	}

  // get previously active session index in tab
  previousIndex = getPreviousIndex(currentIndex.tab);
}

function deactivationHandler(deactivationEvent) {

	// ensure current index exists
  if(currentIndex !== null && typeof currentIndex !== undefined) {

    // calculate session duration before switching sessions
    calculateDuration(currentIndex);
  }
}

function beforeNavigationHandler(beforeNavigationEvent) {
  debugLog('Before Navigation');

  previouslyNavigatedTo = beforeNavigationEvent.target;
}

function visited(url) {
  debugLog('Searching visited nodes for URL: ' + url);

	// ignores revisted redirects
	if(url === "") {
		return(null);
	}
  
	// search sesions for session with matching url and tab index
  for(var i = 0; i < sessions.length; ++i) {
    if(sessions[i].url === url && sessions[i].tab === sessions[currentIndex].tab) {
      return(i);
    }
  }
 
  return(null);
}

function naiveStringMatch(a, b) {
	var n = a.length;
	var m = b.length;
	for(var i = 0; i <= n - m; ++i) {
		var j = 0;
		while(j <= m && a[i + j] === b[j]) {
			++j;
			if(j >= m) {
				return(true);
			}
		}
	}

	return(false);
}

function withinDomain() {
	var childHref = getLocation(sessions[currentIndex].url);
	var parentHref = getLocation(sessions[previousIndex].url);

	var i;
	for(i = 0; i < childHref.hostname.length; ++i) {
		if(childHref.hostname[i] === '.') {
			break;
		}
	}
	
	var childHost = childHref.hostname.substring(i + 1, childHref.hostname.length - 4);

	if(naiveStringMatch(parentHref.hostname, childHost)) {
		debugLog("Pattern " + childHost + " matched in parent hostname " + parentHref.hostname);
		return(true);
	} 
	
	debugLog("Pattern " + childHost + " not matched in parent hostname " + parentHref.hostname);

	return(false);
}

function handleNavigationToChild() {
      debugLog('Visited child URL');
      
      // set new node's parent to previous index
			if(previousIndex == null) {
				sessions[currentIndex].parent = -1;
			} else {
				sessions[currentIndex].parent = previousIndex;
			}

			// detect if navigated to child is within parent's domain
			if(withinDomain()) {
				sessions[currentIndex].withinParentDomain = true;
			} else { 
				sessions[currentIndex].withinParentDomain = false;
			}

      // push child index onto parent child array
      sessions[previousIndex].children.push(currentIndex);
  
      // de-activate parent
      sessions[previousIndex].active = false;
  
      // reset flags
      childLinkFollowed = false;
      childWithinDomain = false;
}

function navigationHandler(navigationEvent, tab) {
  debugLog('Navigation');

	// save sessions
	saveSessions();

  // find if navigated to URL has been visited 
  var visitedIndex = visited(navigationEvent.target.url);

  if(currentIndex !== null && typeof currentIndex !== undefined) {
    // calculate session duration before switching sessions
    calculateDuration(currentIndex);
  }

  // if URL has been visited
  if(visitedIndex !== null && typeof visitedIndex !== undefined) {
    debugLog('Revisiting node');

    // set context to node visited index
    currentIndex = visitedIndex;
    previousIndex = null;
    sessions[visitedIndex].current = true;
    sessions[visitedIndex].previous = false;
  } else {
    debugLog('Visiting new node');
    
    // create new session object
    sessions.push({
      'url': navigationEvent.target.url,
			'tab': currentTab,
      'sessionStart': new Date(),
      'sessionDuration': 0,
      'parent': -1,
      'withinParentDomain': false,
      'children': [],
      'current': true,
      'previous': false
    });

    // swap index points
    previousIndex = currentIndex;
    currentIndex = sessions.length - 1;

    // set parent current flag to false
    sessions[currentIndex].current = true;
   
    // set parent previous flag to true
    sessions[currentIndex].previous = false;
    
    if(previousIndex !== null) {
			// patch parent node child if parent was redirect
			if(sessions[previousIndex].url === "") {
				sessions[previousIndex].children.push(currentIndex);
				sessions[currentIndex].parent = previousIndex;
			}

			sessions[currentIndex].tab = sessions[previousIndex].tab;
      sessions[previousIndex].current = false;
      sessions[previousIndex].previous = true;
    }
  
    if(childLinkFollowed) {
			handleNavigationToChild();
    }
  }

	// current tab should now point at current index
	tabs[currentTab] = currentIndex;

  debugLog(sessions);
}

function beforeSearchHandler(beforeSearchEvent) {
  debugLog('Before Search');

  // calculate session duration before switching sessions
  calculateDuration(currentIndex);

  // get root session index of current session
  var rootIndex = getRoot(sessions, currentIndex);

  sessions.push({
    'url': beforeSearchEvent.target.url,
		'tab': currentTab,
    'sessionStart': new Date(),
    'sessionDuration': 0,
    'parent': rootIndex,
    'children': [],
    'current': true,
    'withinParentDomain': false,
    'previous': false
  });

  previousIndex = rootIndex;
  currentIndex = sessions.length - 1;
	tabs[currentTab] = currentIndex;

	if(previousIndex !== -1 || previousIndex !== null) {
		sessions[currentIndex].tab = sessions[previousIndex].tab;
	}
}

function messageHandler(message) {
  debugLog(message);

  if(message.name === 'child_link_followed') {
    childLinkFollowed = true;
  }
}

//loadSessions();
safari.application.addEventListener("message", messageHandler, false);
safari.application.addEventListener("open", openHandler, true);
safari.application.addEventListener("close", closeHandler, true);
safari.application.addEventListener("activate", activationHandler, true);
safari.application.addEventListener("deactivate", deactivationHandler, true);
safari.application.addEventListener("navigate", navigationHandler, true);
safari.application.addEventListener("beforeNavigate", beforeNavigationHandler, true);
safari.application.addEventListener("beforeSearch", beforeSearchHandler, true);
safari.application.addEventListener('command', handleCommand, false);
