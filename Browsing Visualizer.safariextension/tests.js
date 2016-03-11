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

	//assert(getRoot(test_sessions, 0) === null, 'Root of root node did not return null');
	assert(getRoot(test_sessions, 1) === 0, 'Root of child incorrect');

  console.log('testGetRoot() passed');
}

function testVisited() {
  sessions.push(createNode(null, [], true, null, null, 'https://www.google.com'));
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

testGetRoot();
testOpenHandler();
testVisited();
testNavigationHandler();
