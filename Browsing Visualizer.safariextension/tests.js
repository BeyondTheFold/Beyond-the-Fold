
function testOpenHandler() {
	// if a new tab or window is opened 
	//		then a new tree should be pushed on the list of trees,
	//      a new root node should be created on that tree,
	//      the new tree's current node should be NULL,
	//      the new tree's previous node should be NULL

}

function testCloseHander() {
	// if a window or tab is closed
	//		then the duration of the node at the current index should be calculated,
	//		the current index should be set to null,
	//		the previous index should be set to null
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
}
