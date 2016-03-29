
function handleLinkClick() {
	console.log('Child link followed');
  safari.self.tab.dispatchMessage('child_link_followed', window.location.hostname);
}

function addLinkListeners() {
	console.log('Adding link listeners');
  var link_elements = document.getElementsByTagName("A");

  for(var i = 0; i < link_elements.length; ++i) {
    link_elements[i].addEventListener('click', handleLinkClick);
  }
}

addLinkListeners();
