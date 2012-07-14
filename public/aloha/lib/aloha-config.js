(function(window, undefined) {
	var jQuery = window.jQuery
	if (window.Aloha === undefined || window.Aloha === null) {
		window.Aloha = {};		
	}
	window.Aloha.settings = {
				"plugins": {
					"format": {
						config : [ 'b', 'i','sub','sup','removeFormat'],
						editables : { '#post_title'	: [ ], },
						removeFormats : [ 'strong', 'em', 'b', 'i', 's', 'cite', 'q', 'code', 'abbr', 'del', 'sub', 'sup']
					},
					"image": {
	   					//config : { 'img': { 'max_width': '50px','max_height': '50px' }},
	   					config : [ 'img' ],
					  	editables : { '#post_title'	: [ ], }
					},
					"list": {
					  	editables : { '#post_title'	: [ ], }
					}
				}
			};
})(window);
