function assert(condition, message) {
	if(!condition) {
		throw message || "Assertion failed";
	}
}

function testGetRoot() {
	test_sessions = [];	

	test_sessions.push(createNode(null, [1, 2, 3]));
	test_sessions.push(createNode(0, []));
	test_sessions.push(createNode(0, []));
	test_sessions.push(createNode(0, []));

	assert(getRoot(test_sessions, 0) === 0, 'Root of root node did not root node index');
	assert(getRoot(test_sessions, 1) === 0, 'Root of child incorrect');

  console.log('testGetRoot() passed');
}

function testVisited() {
  sessions.push(createNode(null, [], true, null, 'https://www.google.com'));
  currentIndex = 0;
  assert(visited('https://www.google.com') === 0, 'Previously visited URL not detected');
  
  debugLog('testVisited() passed');
}

function testOpenHandler() {
	// if a new tab or window is opened 
	//    a new root node should be created,
	//    the new node's current key should be true,
	//    the new nodes's previous key should be false

  /*
  openEvent = {
    'target': {'url': 'https://www.google.com'}
  }

  openHandler(openEvent);
  
  assert(sessions.length === 1, 'Child node not added');
  
  console.log('testOpenHandler() passed');
  */

}

function testCloseHander() {
	// if a window or tab is closed
	//		then the duration of the node at the current index should be calculated,
	//		the current index key is set to null,
	//		the previous index key is set to null
}

function testActivationHandler() {

}

function testNavigationHandler() {
	// if a new URL is navigated to and if that URL exists within the current URL
	//		then a child node should be created,
	//		the current index should be the index of the new child node,
	//		and the previous index should be the index of the parent node

	// if a previously navigated to URL is navigated to
	//		then the current index should be the index of the previously visited node

	// if a new URL is navigated to and that URL doesn't exist within the current URL
	//		then a new node should be created as a child of the root node,
	//		the current index should be the index of the new child node,
	//		and the previous index should be NULL


  /* Test duplicate URL visits */
  
  navigationEvents = [];

  navigationEvents.push({
      'target': {'url': 'https://www.google.com'}
  });
  
  navigationEvents.push({
      'target': {'url': 'https://www.google.com'}
  });

  navigationHandler(navigationEvents[0]);
  
  assert(sessions.length === 1, 'Child node was not added');
  assert(sessions[0].parent === null, 'Root node\'s parent is not null');
  assert(currentIndex === 0, 'Current index not defined');

  navigationHandler(navigationEvents[1]);

  assert(sessions.length === 1, 'Repeated node added with redundant URL');

  // reset sessions list
  sessions = [];
  navigationEvents = [];
  currentIndex = null;
  previousIndex = null;
  
  /* Test child URL visit */
  navigationEvents.push({
      'target': {'url': 'https://www.google.com'}
  });
  
}

function sleep(milliseconds) {
	var start = new Date().getTime();
	while(true) {
		if((new Date().getTime() - start) >= milliseconds) {
			break;
		}
	}
}

function testDurationCalculations() {
  // reset sessions list
  sessions = [];

  eventOne = {
      'target': {'url': 'https://www.google.com'}
  };

	navigationHandler(eventOne, 0);

	assert(sessions[0].tab === 0, 'Tab not correctly defined');
	assert(currentIndex === 0, 'Current index incorrectly defined');
	assert(sessions[0].sessionDuration === 0, 'Session duration beginning at ' + sessions[0].duration + ' instead of 0');

	sleep(1000);
	deactivationHandler();

	assert(sessions[0].sessionDuration === 1000, 'Session duration misscalculated');

	eventTwo = {
			'target': {'url': 'https://www.facebook.com'}
	};

	openHandler(eventTwo, 1);

	assert(sessions[1].tab === 1, 'Tab not correctly defined');
	assert(currentIndex === 1, 'Current index incorrectly defined');
	assert(sessions[1].sessionDuration === 0, 'Session duration beginning at ' + sessions[0].duration + ' instead of 0');

	sleep(1000);
	deactivationHandler();
	activationHandler(null, 0);
	
	assert(currentIndex === 0, 'Current index incorrectly defined');
	assert(sessions[0].sessionDuration === 1000, 'Session 0 duration misscalculated');
	assert(sessions[1].sessionDuration === 1000, 'Session 1 duration misscalculated');

  // reset sessions list
  sessions = [];
}

function runTests() {
	testDurationCalculations();
	testGetRoot();
	testOpenHandler();
	testVisited();
	testNavigationHandler();
}
