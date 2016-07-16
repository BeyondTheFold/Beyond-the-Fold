# Beyond the Fold

## Overview

Beyond the Fold is a project to visualize a user's path while browsing
the web. It consists of two components:

- A voluntarily installed web extension to monitor a user's relative position
- A visualizing tool that can be used to import the graph from localstorage

The intialial end product was intended to be a physical manifestation of
the paths through time. 

![device](https://github.com/BeyondTheFold/Beyond-the-Fold/blob/master/Images/image-1.jpg)

Each pane of acrylic has a polar coordinate graph containing the path of one's website
visits. 

- Each circular node is a new page visit.
- Each diamond node is a repeated page visit.
- Each connecting line or edge between nodes represents visiting a link from another page

![graph](https://github.com/BeyondTheFold/Beyond-the-Fold/blob/master/Images/image-20.jpg)

## Monitor

The monitor tracks:
- Duration of a page visit
- The parent/child relationship between websites
- The uniqueness of a page visit
- Whether the page was reached via. a web search

## Visualizer

The visualization tool was constructed in a way such that visible page visit's 
(indicated by a node) can be filtered out by the duration of that visit.

## To Do
- Define minimum and maximum anglular separation between nodes
  - calculate number of nodes that can fit within this separation
- Find out why first level nodes are connecting
- Clean up and comment code
- Ensure nodes aren't drawn after specified threshold is met
[x] Find out why local storage isn't being updated immediatly
- Gather data
 
## Short Comings
- Duration is still counted when user walks away from computer




