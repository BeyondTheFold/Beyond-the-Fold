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

function getRoot(index) {
  debugLog('Searching for root node of node ' + String(index));
  
  if(index === null || typeof index === undefined) {
    console.log('Error: index is null or undefined');
    
    return null;
  }
  
  var i = index;
  while(sessions[i].parent !== null) {
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

function calculateDuration(index) {
  sessions[index].sessionDuration += new Date() - sessions[index].sessionStart;
}

function openHandler(openEvent) {
  console.log("Tab/Page Open");

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
  console.log("Tab/Page Open");

  if(currentIndex !== null) {
    calculateDuration(currentIndex);
  }
}

function activationHandler(activationEvent) {
  console.log("Tab/Page Activation");

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
  console.log('Before Navigation');

  previouslyNavigatedTo = beforeNavigationEvent.target;
}

function visited_recursive(index, url) {
  var children = sessions[index].children;
  
  if(children.length === 0) {
    return null;
  }
  
  if(sessions[index].url === url) {
    return index;
  }
  
  for(var i = 0; i < children.length; ++i) {
    var result = visited_recursive(i, url);
    if(result !== null) {
      return result;
    }
  }
}

function visited(url) {
  debugLog('Searching visited nodes for URL: ' + url);
  
  // get root index in current tree
  var rootIndex = getRoot(currentIndex);
  
  if(rootIndex === null || typeof rootIndex === undefined) {
    debugLog('Root node not found');
    
    return null;
  }
  
  return visited_recursive(rootIndex, url);
}

function navigationHandler(navigationEvent) {
  console.log('Navigation');

  // find if navigated to URL has been visited 
  var visitedIndex = visited(navigationEvent.target.url);
  
  // if URL has been visited
  if(visitedIndex !== null || typeof visitedIndex === undefined) {
    console.log('Revisiting node');
    
    // set context to node visited index
    currentIndex = visitedIndex;
    previousIndex = null;
    sessions[visitedIndex].current = true;
    sessions[vsisitdIndex].previous = false;
  } else {
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
  
    if(currentIndex !== null) {
      // calculate session duration
      sessions[currentIndex].sessionDuration += new Date() - sessions[currentIndex].sessionStart;
   
      // set parent to session tree root
      sessions[currentIndex].parent = getRoot(currentIndex);
   
      // set parent current flag to false
      sessions[currentIndex].current = false;
   
      // set parent previous flag to true
      sessions[currentIndex].previous = true;
    }
  
    // swap index points
    previousIndex = currentIndex;
    currentIndex = sessions.length - 1;
  
    if(nextNavigatedToIsChild) {
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

  console.log(sessions);
}

function beforeSearchHandler(beforeSearchEvent) {
  console.log('Before Search');

  calculateDuration(currentIndex);
  var rootIndex = getRoot(currentIndex);

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
