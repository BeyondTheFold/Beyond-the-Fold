function handleMessage(message) {
  var link_elements = document.getElementsByTagName("A");
  var links = []; 

  for(var i = 0; i < link_elements.length; ++i) {
    links.push(link_elements[i].getAttribute("href"));
  }

  safari.self.tab.dispatchMessage('links', links);
}

safari.self.addEventListener("message", handleMessage, false);
