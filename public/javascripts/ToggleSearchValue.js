$(document).ready(function() {
		var search_cell = $("#primary_search");
		var smaller_search_value = "Search"
		var larger_search_value = "Search for a person, place or organisation"
		
		$(window).resize( function(){
			var search_cell_width = $(search_cell).width();
			if (search_cell_width < 370) {
				$("#phrase").attr("placeholder",smaller_search_value);
			} else {
				$("#phrase").attr("placeholder",larger_search_value);
			}
		})
 });