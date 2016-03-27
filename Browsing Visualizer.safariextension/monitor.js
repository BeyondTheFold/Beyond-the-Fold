// debug flag
var debug = true;

// array to hold all session node objects
var sessions = [];

// flag for identifying child sessions
var childLinkFollowed = false;
var childWithinDomain = false;

// tab count
var tabCount = 0;

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
  sessions = JSON.parse(localStorage.getItem('sessions'));

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
		sessions = [];
		tabCount = 0;
		currentIndex = null;
		previousIndex = null;
		localStorage.removeItem('sessions');
		debugLog('Cleared sessions');
	}
}

function saveSessions() {
  output = {'sessions': []};
  for(var i = 0; i < sessions.length; ++i) {
    var session = sessions[i];
 
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
  
  debugLog('Session saved');
  localStorage.setItem('sessions', JSON.stringify(output));
	debugLog(JSON.stringify(output));
}

function getRoot(sessions, index) {
  if(index === -1 || 
			index === null || 
			typeof sessions === undefined || 
			typeof index === undefined ||
			sessions[index] === null ||
			typeof sessions[index] === undefined) {
    return(null);
  }

  var i = index;
	var iterationCount = 0;
	var maxIteration = sessions.length;
	while(typeof sessions[i].parent !== undefined && sessions[i].parent !== -1) {
		if(iterationCount >= maxIteration) {
			debugLog('getRoot(...) stuck in cycle at ' + String(i) + ' and ' + String(sessions[i].parent));
			return(null);
		}
		++iterationCount;
    i = sessions[i].parent;
		if(i === null) {
			return(0);
		}
  }
  return(i);
}

function getPreviousIndex() {
  debugLog('Searching for previous tab');

  for(var i = 0; i < sessions.length; ++i) {
    if(sessions[i].previous === true) {
      debugLog('Found previous node at ' + String(i));
      
      return(i);
    }
  }
  return(null);
}

function openHandler(openEvent) {
  debugLog("Tab/Page Open");

	// increment tab count
	++tabCount;

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

  previousIndex = null;
  currentIndex = sessions.length - 1;
}

function closeHandler(closeEvent) {
  debugLog("Tab/Page Open");

  saveSessions();
}

function activationHandler(activationEvent) {
  debugLog("Tab/Page Activation");

  // get previously active session index in tab
  previousIndex = getPreviousIndex();
}

function deactivationHandler(deactivationEvent) {
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
  
  // get root index in current tree
  var rootIndex = getRoot(sessions, currentIndex);
  
  if(rootIndex === null || typeof rootIndex === undefined) {
    debugLog('Root node not found');

    return(null);
  }
  
  for(var i = 0; i < sessions.length; ++i) {
    if(sessions[i].url === url && getRoot(sessions, i) === rootIndex) {
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
      sessions[currentIndex].parent = previousIndex;

			// detect if navigated to child is within parent's domain
			if(withinDomain()) {
				sessions[currentIndex].withinParentDomain = true;
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
			'tab': tabCount,
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
      // set parent to previously visited index
      sessions[currentIndex].parent = previousIndex;
			sessions[currentIndex].tab = sessions[previousIndex].tab;
      sessions[previousIndex].current = false;
      sessions[previousIndex].previous = true;
    }
  
    if(childLinkFollowed) {
			handleNavigationToChild();
    }
  }
  
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
		'tab': tabCount,
    'sessionStart': new Date(),
    'sessionDuration': 0,
    'parent': rootIndex,
    'children': [],
    'current': true,
    'previous': false
  });

  previousIndex = rootIndex;
  currentIndex = sessions.length - 1;

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
