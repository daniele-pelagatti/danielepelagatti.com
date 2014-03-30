$(document).ready(function() {

	var showHide = function() {
		ga('send', 'event', 'show-menu-button', 'click');

		if( $('menu').hasClass('force-show') ) { 
			$('menu').removeClass('force-show')
		} else { 
			$('menu').addClass('force-show') 
		} 
		if( $('.show-menu').hasClass('force-hide') ) {
			$('.show-menu').removeClass('force-hide') 
		} else { 
			$('.show-menu').addClass('force-hide')
		}
	};

	var onSocialMenuClick = function(event) {
		ga('send', 'event', event.currentTarget.className.split(" ").join("-") , 'click');
	}
	var onInfoPopupLinkClick = function(event) {
		ga('send', 'event', "info-page-"+event.currentTarget.innerHTML.toLowerCase().split(" ").join("-") , 'click');
	}
	var onNoWebGLWarningClick = function(event) {
		ga('send', 'event', "no-webgl-warning-button" , 'click');
	}
	var hide = function() {
		$('menu').removeClass('force-show') 
		$('.show-menu').removeClass('force-hide') 
	}
	
	$(".show-menu").click(showHide);
	$(".no-webgl-warning-button").click(onNoWebGLWarningClick);
	$("nav a").click(hide);
	$(".socialMenu a").click(onSocialMenuClick);
	$("#about a").click(onInfoPopupLinkClick);
	$(".website-info-button").leanModal({ top : 40, overlay : 0.4, closeButton: ".modal_close" })
});


WebFontConfig = {
	google: { 
		families: [ 'Open+Sans:300italic,400italic,600italic,700italic,800italic,400,300,600,700,800:latin','Open+Sans+Condensed:300,300italic,700:latin' ] 
	},
	custom: {
		families: ['FontAwesome'],
		urls: ["http://weloveiconfonts.com/api/?family=fontawesome"]	
	}
};
(function() {
	var wf = document.createElement('script');
	wf.src = ('https:' == document.location.protocol ? 'https' : 'http') + '://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js';
	wf.type = 'text/javascript';
	wf.async = 'true';
	var s = document.getElementsByTagName('script')[0];
	s.parentNode.insertBefore(wf, s);
})();