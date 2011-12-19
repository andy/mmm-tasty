// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var blinks = $A();
function blink(element) {
  var element = $(element);

  blinks.push(element.id);
  blinker(element);
}

function blinker(element) {
  Effect.toggle(element, 'appear', { duration: 0.3, from: 1.0, to: 0.2, afterFinish: function() { if(blinks.include(element.id)) blinker(element); } });
}

function unblink(element) {
  var element = $(element);

  blinks = blinks.without(element.id);
}


var _login_mode = "email";
function login_openid_switcher ( value ) {
  if ( value.match ( /^(http|https)/ ) ) {
      if (_login_mode != "openid") {
  			$('user_password').disabled = true;
  			if ( $('user_password_label') ) {
  			  new Effect.Fade ( 'user_password_label', { duration: 0.5, from: 1.0, to: 0.2 } );
  			}
  			error_message_on('user_password', 'пароль не нужен, поскольку используется OpenID авторизация', true);
        _login_mode = "openid";
      }
  } else if (_login_mode != "email") {
    $('user_password').disabled = false;
    if ( $('user_password_label') ) {
		  new Effect.Appear ( 'user_password_label', { duration: 0.5 } );
		}
		clear_error_message_on('user_password');
    _login_mode = "email";
  }
}

var _errors_on = new Array;

/* Выставляем ошибку на элементе ... */
function error_message_on ( element, message, is_tip ) {
  var element = $(element);
  if ( !element )
    return;

  var element_error = $(element.id + '_error');
  var had_error = _errors_on.indexOf ( element.id ) != -1;

  if ( !element_error )
    return;

  if ( !had_error )
    _errors_on.push ( element.id );

  add_me = is_tip ? 'not_really_big_error' : 'error'
  remove_me = is_tip ? 'error' : 'not_really_big_error'
  element_error.removeClassName(remove_me);
  element_error.addClassName(add_me);

  is_tip ? element.removeClassName('input_error') : element.addClassName('input_error');
  is_tip ? element.addClassName('input_succeed') : element.removeClassName('input_succeed');

  Element.update ( element_error.id + '_content', message);
  Element.show ( element_error );
}

/* Удаляем ошибку с элемента */
function clear_error_message_on ( element ) {
  var element = $(element);
  var element_error = $(element.id + '_error');

  element.removeClassName('input_error');
  element.removeClassName('input_succeed');
  Element.update ( element_error.id + '_content', '');
  Element.hide ( element_error );
  _errors_on = _errors_on.without ( element.id );
}

/* Удаляем все ошибки */
function clear_all_errors ( ) {
  _errors_on.each ( function ( element ) { clear_error_message_on ( element ); } );
}


function remote_request_started(button_element, text) {
  var button_element = $(button_element);
  button_element.value = text;
  button_element.disable();
}

function remote_request_finished(button_element, text) {
  var button_element = $(button_element);
  button_element.value = text;
  button_element.enable();
}

function sidebar_toggle(section) {
  var prefix = 'sidebar_' + section
  Effect.toggle(prefix + '_content', 'blind', { duration: 0.3 });
  Element.toggleClassName(prefix + '_link', 'highlight');
  urchinTracker('/sidebar/' + section);
  return false;
}

/* меняет количество комментариев на странице */
function run_comments_views_update( ) {
  if (typeof comments_views_update == 'undefined')
    return;

  comments_views_update.each( function(object) {
    // var attr = object.attributes;
    var text = object.comments_count;

    if (object.last_comment_viewed > 0 && object.last_comment_viewed != object.comments_count) {
      text = object.last_comment_viewed + '+' + (object.comments_count - object.last_comment_viewed);
    } else if (current_user > 0 && !object.last_comment_viewed && object.comments_count > 0 ) {
      text = '+' + object.comments_count
    }
    var element = $('entry_comments_count_' + object.id);
    if (element)
      Element.update(element, text);
  });
}

/* обновляем количество голосов за показываемые записи */
function run_entry_ratings_update( ) {
  if (typeof entry_ratings_update == 'undefined')
    return;

  entry_ratings_update.each ( function(object) {
    var element = $('entry_rating_' + object.id);
    if (element) Element.update(element, object.value);
  });
}

/* показываем штуки которые имеет смысл показывать только в том случае, если у нас есть какой-то залогиненный пользователь */
function enable_services_for_current_user( ) {
  /* все ссылки котоыре можно показывать текущему пользователю */
  $$(".enable_for_current_user").each( function(element) { element.show(); });

  /* показываем все элементы для которых _текущий_ пользователь является владельцем */
  $$(".enable_for_owner_" + current_user).each( function(element) { element.show(); });
  /* в обратную сторону - прячем все */
  $$(".disable_for_owner_" + current_user).each( function(element) { element.hide(); });

  /* прячем его собственные записи - все равно он за них не сможет голосовать */
  $$(".service_rating_owner_" + current_user).each( function(holder) {
    $$(".entry_voter", holder.id).each( function(element) { element.hide(); });
  });

}

Event.observe(window, 'load', function( ) {
  run_comments_views_update();
  run_entry_ratings_update();
  if(current_user)
    enable_services_for_current_user();
});

// fixPNG(); http://www.tigir.com/js/fixpng.js (author Tigirlas Igor)
function fixPNG(element) {
	if (/MSIE (5\.5|6).+Win/.test(navigator.userAgent))
	{
		var src;

		if (element.tagName=='IMG')
		{
			if (/\.png(\?[0-9]+)?$/.test(element.src))
			{
				src = element.src;
				element.src = asset_host + "/images/blank.gif";
			}
		}
		else
		{
			src = element.currentStyle.backgroundImage.match(/url\("(.+\.png(\?[0-9]+)?)"\)/i)
			if (src)
			{
				src = src[1];
				element.runtimeStyle.backgroundImage="none";
			}
		}

		if (src) element.runtimeStyle.filter = "progid:DXImageTransform.Microsoft.AlphaImageLoader(src='" + src + "',sizingMethod='scale')";
	}
}

var reply_to_comments = new Array;
var reply_to_string = null;

function _update_comment_textarea( ) {
  comment = $('comment_comment');

  if(reply_to_comments.length > 0) {
    reply_to_string = '<b>' + reply_to_comments.map( function(id) { return $('comment_author_'+id).innerHTML; } ).join(', ') + ':</b>';
    if (comment.value.match(/^<b>.*:<\/b>/)) {
      comment.value = comment.value.replace(/^<b>.*:<\/b>/i, reply_to_string);
    } else {
      comment.value = reply_to_string + ' ' + comment.value;
    }
  } else if (comment.value.match(/^<b>.*:<\/b>/)) {
    comment.value = comment.value.replace(/^<b>.*:<\/b>/i, '');
  }
}

function reply_to_comment(id) {
  Element.show('replying_to_comment_' + id);
  Element.hide('reply_to_comment_' + id);
  if(reply_to_comments.indexOf(id) == -1) reply_to_comments.push(id);
  $('comment_reply_to').value = reply_to_comments.join(',');
  _update_comment_textarea();
}

function do_not_reply_to_comment(id) {
  Element.hide('replying_to_comment_' + id);
  Element.show('reply_to_comment_' + id);
  if(reply_to_comments.indexOf(id) != -1) reply_to_comments = reply_to_comments.without(id);
  $('comment_reply_to').value = reply_to_comments.join(',');
  _update_comment_textarea();
}

/* safari label fix */
// if (navigator.userAgent.indexOf('Safari') != -1) {
//   Event.observe(window, 'load', function() {
//     var lock = false;
//     var elements = document.getElementsByTagName('label');
//     $A(elements).each( function(element) {
//       Event.observe(element, 'click', function() {
//        var input = (this.htmlFor ? $(this.htmlFor) : this.getElementsByTagName('input')[0]);
//        if (input && !lock) {
//          input.focus();
//          lock = true;
//          if(input.click) input.click();
//          lock = false;
//        }
//       }); });
//   } );
// }


/* http://lojjic.net/script-library/TextAreaResizer.js */
/*
**  TextAreaResizer script by Jason Johnston (jj@lojjic.net)
**  Created August 2003.  Use freely, but give me credit.
**
**  This script adds a handle below textareas that the user
**  can drag with the mouse to resize the textarea.
*/

function TextAreaResizer(elt) {
	this.element = elt;
	this.create();
}
TextAreaResizer.prototype = {
	create : function() {
		var elt = this.element;
		var thisRef = this;

		var h = this.handle = document.createElement("div");
		h.className = "textarea-resizer";
		h.title = "Drag to resize text box";
		h.addEventListener("mousedown", function(evt){thisRef.dragStart(evt);}, false);
		elt.parentNode.insertBefore(h, elt.nextSibling);
	},

	dragStart : function(evt) {
		var thisRef = this;
		this.dragStartY = evt.clientY;
		this.dragStartH = parseFloat(document.defaultView.getComputedStyle(this.element, null).getPropertyValue("height"));
		document.addEventListener("mousemove", this.dragMoveHdlr=function(evt){thisRef.dragMove(evt);}, false);
		document.addEventListener("mouseup", this.dragStopHdlr=function(evt){thisRef.dragStop(evt);}, false);
	},

	dragMove : function(evt) {
		this.element.style.height = this.dragStartH + evt.clientY - this.dragStartY + "px";
	},

	dragStop : function(evt) {
		document.removeEventListener("mousemove", this.dragMoveHdlr, false);
		document.removeEventListener("mouseup", this.dragStopHdlr, false);
	},

	destroy : function() {
		var elt = this.element;
		elt.parentNode.removeChild(this.handle);
		elt.style.height = "";
	}
};

Event.observe(window, 'load', function() {
  $$('.resizeable').each(function(element) { new TextAreaResizer(element); });
});
// TextAreaResizer.scriptSheetSelector = "textarea";

/* ie hover fix */
function makeHover(classList) {
  classList.each(function(item) {
    if ($$('.' + item).length) {
      $$('.' + item).each(function(node) {
        node.onmouseover=function() { this.className+=" hover"; }
        node.onmouseout=function() { this.className=this.className.replace (" hover", ""); }
      });
    }
  });
}

if(/MSIE/.test(navigator.userAgent) && !window.opera) {
  Event.observe(window, 'load', function() {
    var classes = new Array('post_body');
    makeHover(classes);
  });
}

/* hide all flash object on page */
function toggle_flash(visibility) {
  var embeds = document.getElementsByTagName('embed');
  for(i = 0; i < embeds.length; i++) {
    embeds[i].style.visibility = visibility;
  }

  var objects = document.getElementsByTagName('object');
  for(i = 0; i < objects.length; i++) {
    objects[i].style.visibility = visibility;
  }
}

function hide_flash() {
  toggle_flash('hidden');
}

function show_flash() {
  toggle_flash('visible')
}