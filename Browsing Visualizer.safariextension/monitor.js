console.log('Monitor Starting');

// debug flag
var debug = false;

// array to hold all session node objects
var sessions = [];

// flag for identifying child sessions
var childLinkFollowed = false;
var childWithinDomain = false;

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

function createNode(parent, children, current, previous, url, withinParentDomain, tab) {
  return({
    'tab': tab,
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
  sessions[index].sessionDuration += new Date() - sessions[index].sessionStart;
}

function saveSessions() {
  output = [];
  for(var i = 0; i < sessions.length; ++i) {
    var session = sessions[i];
 
		/*   
    output.push({
			'index': session.index,
			'tab': session.tab,
      'url': session.url, 
      'sessionStart': session.sessionStart, 
      'sessionDuration': session.sessionDuration, 
      'parent': session.parent, 
      'withinParentDomain': session.withinParentDomain,
      'child': session.child
    });
		*/
  }
  
  debugLog('Session saved');
  localStorage.setItem('sessions', JSON.stringify(output));
  console.log(localStorage.getItem('sessions'));
}

function getRoot(sessions, index) {
  if(index === null || typeof index === undefined) {
    return(null);
  }
  
  var i = index;
	var iterationCount = 0;
	var maxIteration = sessions.length;
  while(sessions[i].parent !== null && typeof sessions[i].parent !== undefined) {
		if(iterationCount >= maxIteration) {
			debugLog('getRoot(...) stuck in cycle at ' + String(i) + ' and ' + String(sessions[i].parent));
			return(null);
		}
		++iterationCount;
    i = sessions[i].parent;
  }
  return(i);
}

function getCurrentIndex(tab) {
  debugLog('Searching for current tab');
  
  if(tab !== null && typeof tab !== undefined) {
    for(var i = 0; i < sessions.length; ++i) {
      if(sessions[i].tab === tab && sessions[i].current === true) {
        debugLog('Found current node at ' + String(i));
        
        return(i);
      }
    }
  }

  return(null);
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

function openHandler(openEvent, tab) {
  debugLog("Tab/Page Open");

  // when new tab or window is opened push parent object
  sessions.push({
    'tab': openEvent.target,
    'url': openEvent.target.url,
    'sessionStart': new Date(),
    'sessionDuration': 0,
    'parent': null,
    'withinParentDomain': false,
    'children': [],
    'current': true,
    'previous': false
  });

  previousIndex = null;
  currentIndex = sessions.length - 1;

  // for testing purposes
  if(tab !== null && typeof tab !== undefined) {
    sessions[currentIndex].tab = tab;
  }
}

function closeHandler(closeEvent) {
  debugLog("Tab/Page Open");

  saveSessions();
}

function activationHandler(activationEvent, tab) {
  debugLog("Tab/Page Activation");

  // get current active session index for tab
  if(tab === null || typeof tab === undefined) {
    currentIndex = getCurrentIndex(activationEvent.target);
  } else {
    // for testing purposes
    currentIndex = getCurrentIndex(tab);
   }

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
      'tab': navigationEvent.target,
      'url': navigationEvent.target.url,
      'sessionStart': new Date(),
      'sessionDuration': 0,
      'parent': null,
      'withinParentDomain': false,
      'children': [],
      'current': true,
      'previous': false
    });

    // swap index points
    previousIndex = currentIndex;
    currentIndex = sessions.length - 1;

    // for testing purposes
    if(tab !== null && typeof tab !== undefined) {
      sessions[currentIndex].tab = tab;
    }
  
    // set parent current flag to false
    sessions[currentIndex].current = true;
   
    // set parent previous flag to true
    sessions[currentIndex].previous = false;
    
    if(previousIndex !== null) {
      // set parent to previously visited index
      sessions[currentIndex].parent = previousIndex;
      sessions[previousIndex].current = false;
      sessions[previousIndex].previous = true;
    }
  
    if(childLinkFollowed) {
      debugLog('Visited child URL');
      
      // set new node's parent to previous index
      sessions[currentIndex].parent = previousIndex;

      var childHref = getLocation(sessions[currentIndex].url);
      var parentHref = getLocation(sessions[previousIndex].url);

      if(childHref.hostname === parentHref.hostname) {
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
    'sessionStart': new Date(),
    'sessionDuration': 0,
    'parent': rootIndex,
    'children': [],
    'current': true,
    'previous': false
  });

  previousIndex = rootIndex;
  currentIndex = sessions.length - 1;
}

function messageHandler(message) {
  debugLog(message);

  if(message.name === 'child_link_followed') {
    childLinkFollowed = true;
  }
}

loadSessions();
safari.application.addEventListener("message", messageHandler, false);
safari.application.addEventListener("open", openHandler, true);
safari.application.addEventListener("close", closeHandler, true);
safari.application.addEventListener("activate", activationHandler, true);
safari.application.addEventListener("deactivate", deactivationHandler, true);
safari.application.addEventListener("navigate", navigationHandler, true);
safari.application.addEventListener("beforeNavigate", beforeNavigationHandler, true);
safari.application.addEventListener("beforeSearch", beforeSearchHandler, true);
safari.application.addEventListener('command', saveSessions, false);
