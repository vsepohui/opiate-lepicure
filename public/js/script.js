
function rus_to_latin (str) {
	var ru = {'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e', 'ё': 'e', 'ж': 'j', 'з': 'z', 'и': 'i', 'й': 'i', 'к': 'k', 'л': 'l', 'м': 'm', 'н': 'n', 'о': 'o', 'п': 'p', 'р': 'r', 'с': 's', 'т': 't', 'у': 'u', 'ф': 'f', 'х': 'h', 'ц': 'c', 'ч': 'ch', 'ш': 'sh', 'щ': 'shch', 'ы': 'y', 'э': 'e', 'ю': 'u', 'я': 'ya'}, n_str = [];str = str.replace(/[ъьЪЬ]+/g, '\'').replace(/й/g, 'i');for ( var i = 0; i < str.length; ++i ) {n_str.push(ru[ str[i] ]|| ru[ str[i].toLowerCase() ] == undefined && str[i]|| ru[ str[i].toLowerCase() ].toUpperCase());}return n_str.join('');
} 

function russian_to_ruzskey () {
	document.documentElement.innerHTML = rus_to_latin(document.documentElement.innerHTML); 
}

function init_post_button_hook () {
	var mutex = 0;
	$('#post_button').click(function (event) {
		event.preventDefault();
		if (mutex % 2 == 1) {
			if ($('#subject').val() && $('#message').val()) {		
				var form = $(this);
				$('#form_post').submit();
			}
			return;
		}
		
		$('#subject').show(604);
		$('#message').show(604);
		
		mutex += 1;
	});
}

var ajax_feed_case_id = null;
var ajax_next_case_id = null;
var user_alias        = null;

function get_ajax_feed_case_id () {
	return ajax_feed_case_id;
}
function set_ajax_feed_case_id(val) {
	ajax_feed_case_id = val;
}

function get_ajax_next_case_id () {
	return ajax_next_case_id;
}

function set_ajax_next_case_id(val) {
	ajax_next_case_id = val;
}

function set_user_alias (val) {
	user_alias = val;
}

function init_ajax_feed(alias, x, y) {
	set_user_alias(alias);
	init_ajax_feed_updater(alias, x);
	init_scroll_feed_hook(alias, y);
}


function init_ajax_feed_updater (alias, case_id) {
	set_ajax_feed_case_id(case_id)
	var timerId = setInterval(function() {
		$.ajax({
			url: "/" + alias + "/ajax/update?case_id=" + get_ajax_feed_case_id(),
		}).done(function(data) {
			if (data) {
				$('#feed').prepend(data);
			}
		});
	}, 5000);
}

	
function init_scroll_feed_hook (alias, case_id) {
	set_ajax_next_case_id(case_id);
	var isLoading = 0;
	var isFinished = false;
	$(window).scroll(function() {
		if($(window).scrollTop() + $(window).height() > $(document).height() - 100) {
			if (!isLoading && !isFinished) {
				isLoading = true;
				
				$.ajax({
					url: '/'+alias+'/ajax/update',
					type: 'GET',
					data: { case_id: get_ajax_next_case_id(), last: 1 },
					success: function(response) {
						if (!response) {
							isFinished = true;
						}
						$('#feed').append(response);
						isLoading = false;
					}
				});
			}
		}
	});
}

function init_main () {
	$('#logout-btn').click( function() {
		$('#form-logout').submit();
	});
	var update_magic_Timer = setInterval(function() {
		$.ajax({
			url: '/ajax/update_magic',
		}).done(function(data) {
			if (data) {
				$("input[name='magic']").val(data);
			}
		});
	}, 30000);
}

function init_books_form() {
	var mutex = 0;
	$('#add_book').click(function (event) {
		event.preventDefault();
		if (mutex % 2 == 1) {
			if ($('#name').val() && $('#year').val()) {		
				var form = $('#form');
				form.submit();
			}
			return;
		}
		$('#name').show(604);
		$('#year').show(604);
		
		mutex += 1;		
	});	
}

function init_books_add_list_form() {
	var mutex = 0;
	$('#post_button').click(function (event) {
		event.preventDefault();
		if (mutex % 2 == 1) {
			if ($('#title').val() && $('#text').val()) {		
				var form = $('#form_post');
				form.submit();
			}
			return;
		}
		$('#title').show(604);
		$('#text').show(604);
		
		mutex += 1;		
	});
}

function init_add_link_button () {
	var mutex = 0;
	$('#add_link').click(function (event) {
		event.preventDefault();
		if (mutex % 2 == 1) {
			if ($('#description').val() && $('#description').val()) {		
				var form = $('#form');
				form.submit();
			}
			return;
		}
		$('#url').show(604);
		$('#description').show(604);
		
		mutex += 1;		
	});	
}

function init_add_album_button () {
	var mutex = 0;
	$('#add_album').click(function (event) {
		event.preventDefault();
		if (mutex % 2 == 1) {
			if ($('#html').val()) {		
				var form = $('#form');
				form.submit();
			}
			return;
		}
		$('#html').show(604);
		$('#post_button').val('Отправить');
		
		mutex += 1;		
	});
}

function init_photos () {
    var $grid = $('.grid').masonry({
        itemSelector: '.grid-item'
        // columnWidth: 300
    });
    
    $grid.imagesLoaded().progress( function() {
        $grid.masonry('layout');
    });

	var mutex = 0;
	$('#upload_photo').click(function (event) {
		event.preventDefault();
		if (mutex % 2 == 1) {
			if ($('#upload').val()) {		
				var form = $('#form');
				form.submit();
			}
			return;
		}
		$('#upload').show(604);

		
		mutex += 1;		
	});	
}


$(function() {
	init_main();
	$('#copy-profile-url').click(function(e) {
		e.preventDefault();
		navigator.clipboard.writeText("https://opiate-lepicure.ru/" + user_alias);
	});
});
