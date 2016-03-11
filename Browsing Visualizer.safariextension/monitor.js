console.log('Monitor Starting');

// debug flag
var debug = true;

// array to hold all session node objects
var sessions = [];

// flag for identifying child sessions
var nextNavigatedToIsChild = false;

// previous session index visited on tree
var previousIndex = null;

// current session visited on tree
var currentIndex = null;

function debugLog(output) {
  if(debug === true) {
    console.log(output);
  }
}

function createNode(parent, children, current, previous, tab, url) {
  return({
    'tab': tab,
    'url': url,
    'sessionStart': new Date(),
    'sessionDuration': 0,
    'parent': parent,
    'children': children,
    'current': true,
    'previous': false
  });
}

/*
// restore session
var tabs = safari.application.activeBrowserWindow.tabs;
var activeTab = safari.application.activeBrowserWindow.activeTab;
var current;
for(var i = 0; i < tabs.length; ++i) {
  // if tab is the active tap set the current key value to true
  if(tabs[i] == activeTab) {
    current = true;
    currentIndex = i;
  } else {
    current = false;
  }
  
  sessions.push(createNode(null, [], current, null, tabs[i], tabs[i].url));
}
*/

function calculateDuration(index) {
  sessions[index].sessionDuration += new Date() - sessions[index].sessionStart;
}

function saveSessions() {
  output = [];
  for(var i = 0; i < sessions.length; ++i) {
    var session = sessions[i];
    
    // filter out nodes representing redirects
    if(session[i].duration > 0) {
      output.push({
        'url': session.url, 
        'sessionStart': session.sessionStart, 
        'sessionDuration': session.sessionDuration, 
        'parent': session.parent, 
        'child': session.child
      });
    }
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

function getCurrentIndex() {
  debugLog('Searching for current tab');
  
  for(var i = 0; i < sessions.length; ++i) {
    if(sessions[i].current === true) {
      debugLog('Found current node at ' + String(i));
      
      return(i);
    }
  }
  return(null);
}

function getIndexOfTab(tab) {
  for(var i = 0; i < sessions.length; ++i) {
    if(sessions[i].tab === tab) {
      return(i);
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

function openHandler(openEvent) {
  debugLog("Tab/Page Open");

  // when new tab or window is opened push parent object
  sessions.push({
    'tab': openEvent.target,
    'url': openEvent.target.url,
    'sessionStart': new Date(),
    'sessionDuration': 0,
    'parent': null,
    'children': [],
    'current': true,
    'previous': false
  });

  previousIndex = null;
  currentIndex = sessions.length - 1;
}

function closeHandler(closeEvent) {
  debugLog("Tab/Page Open");

  if(currentIndex !== null) {
    calculateDuration(currentIndex);
  }
  
  saveSessions();
}

function activationHandler(activationEvent) {
  debugLog("Tab/Page Activation");

  // get current active session index for tab
  currentIndex = getCurrentIndex();

  // get previously active session index in tab
  previousIndex = getPreviousIndex();
  
}

function deactivationHandler(deactivationEvent) {
  if(currentIndex !== null) {
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

function navigationHandler(navigationEvent) {
  debugLog('Navigation');

  // find if navigated to URL has been visited 
  var visitedIndex = visited(navigationEvent.target.url);
  
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
      'children': [],
      'current': true,
      'previous': false
    });
  
    // swap index points
    previousIndex = currentIndex;
    currentIndex = sessions.length - 1;
  
    // calculate session duration
    sessions[currentIndex].sessionDuration += new Date() - sessions[currentIndex].sessionStart;
    

   
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
  
    if(nextNavigatedToIsChild) {
      debugLog('Visited child URL');
      
      // set new node's parent to previous index
      sessions[currentIndex].parent = previousIndex;
  
      // push child index onto parent child array
      sessions[previousIndex].children.push(currentIndex);
  
      // de-activate parent
      sessions[previousIndex].active = false;
  
      // reset flag
      nextNavigatedToIsChild = false;
    }
  }
  
  debugLog(sessions);
}

function beforeSearchHandler(beforeSearchEvent) {
  debugLog('Before Search');

  calculateDuration(currentIndex);
  var rootIndex = getRoot(sessions, currentIndex);

  sessions.push({
    'tab': beforeSearchEvent.target,
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
  if(message.name == 'child_link_followed') {
    nextNavigatedToIsChild = true;
  }
}

safari.application.addEventListener("message", messageHandler, false);
safari.application.addEventListener("open", openHandler, true);
safari.application.addEventListener("close", closeHandler, true);
safari.application.addEventListener("activate", activationHandler, true);
safari.application.addEventListener("deactivate", deactivationHandler, true);
safari.application.addEventListener("navigate", navigationHandler, true);
safari.application.addEventListener("beforeNavigate", beforeNavigationHandler, true);
safari.application.addEventListener("beforeSearch", beforeSearchHandler, true);
safari.application.addEventListener('command', saveSessions, false);
