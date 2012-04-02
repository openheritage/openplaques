// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require jquery-1.5.1.min
//= require jquery-ui-1.8.11.custom.min
//= require modernizr-1.7.min
//= require leaflet
//= require RGraph.hbar.js
//= require RGraph.common.zoom.js
//= require RGraph.common.tooltips.js
//= require RGraph.common.resizing.js
//= require RGraph.common.key.js
//= require RGraph.common.effects.js
//= require RGraph.common.dynamic.js
//= require RGraph.common.core.js
//= require RGraph.common.context.js
//= require RGraph.common.annotate.js
//= require_tree .

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function addLoadEvent(func) {
  var oldonload = window.onload;
  if (typeof window.onload != 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      if (oldonload) {
        oldonload();
      }
      func();
    }
  }
}