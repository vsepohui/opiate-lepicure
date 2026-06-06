
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

	
function init_scroll_feed_hook (alias) {
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
