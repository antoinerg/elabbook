/*
	HUMANIZED MESSAGES 1.0
	idea - http://www.humanized.com/weblog/2006/09/11/monolog_boxes_and_transparent_messages
	home - http://humanmsg.googlecode.com
*/

var humanMsg = {
	setup: function(appendTo, logName, msgOpacity) {
		humanMsg.msgID = 'humanMsg';
		humanMsg.logID = 'humanMsgLog';

		// appendTo is the element the msg is appended to
		if (appendTo == undefined)
			appendTo = 'body';

		// The text on the Log tab
		if (logName == undefined)
			logName = 'Message Log';

		// Opacity of the message
		humanMsg.msgOpacity = 0.8;

		// Inject the message structure
		jQuery(appendTo).append('<div id="'+humanMsg.logID+'"><p>'+logName+'</p><ul></ul></div>');
		
		jQuery('#'+humanMsg.logID+' p').click(
			function() { jQuery(this).siblings('ul').slideToggle() }
		);

		// Initialy show
		jQuery('#'+humanMsg.logID+' p').siblings('ul').slideToggle();	
	},
	displayMsg: function(msg) {
		if (msg == '')
			return;

		jQuery('#'+humanMsg.logID)
			.show().children('ul').prepend('<li>'+msg+'</li>')	// Prepend message to log
			.children('li:first').slideDown(200)			// Slide it down
	
		if ( jQuery('#'+humanMsg.logID+' ul').css('display') == 'none') {
			jQuery('#'+humanMsg.logID+' p').animate({ bottom: 0 }, 200, 'linear', function() {
				jQuery(this).animate({ bottom: 0 }, 300, function() { jQuery(this).css({ bottom: 0 }) })
			})
		}
			
	}
};

jQuery(document).ready(function(){
	humanMsg.setup();
})
