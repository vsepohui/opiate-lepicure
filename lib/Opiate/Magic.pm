package Opiate::Magic;

use 5.022;
use warnings;

use Data::Validate::Email qw(is_email);
use JSON::XS;
use Mojo::Home;
use utf8;


sub new {
	my $class = shift;
	state $self = bless {}, $class;
	return $self;
}

sub dir {
	my $self = shift;
	
	state $dir;
	unless ($dir) {
		my $home = Mojo::Home->new;
		$home->detect;
		$dir = "$home";
	}
	return $dir;
}


sub json {
	my $class = shift;
	state $json = JSON::XS->new->utf8;
	return $json->latin1;
}

sub json_decode {
	my $class = shift;
	my $text = shift;
	return eval {$class->json->decode($text)};
}

sub json_encode {
	my $class = shift;
	my $perl = shift;
	my $text = $class->json->encode($perl);
	return $text;
}

sub generate_random_string {
	my $self   = shift;
    my $length = shift;
    
    my @chars = ('a'..'z', 'A'..'Z', '0'..'9'); # Define your character set
    my $random_string = '';
    
    for (1..$length) {
        $random_string .= $chars[rand @chars];
    }
    return $random_string;
}

sub crypt_password {
	my $self = shift;
	my $pass = shift;
	my $salt = $self->generate_random_string(8);
	return crypt($pass, $salt) . $salt;
}

sub check_password {
	my $self = shift;
	my $hash = shift;
	my $pass = shift;
	my $salt = substr($hash, length($hash) - 8);
	return $hash eq (crypt($pass, $salt) . $salt);
}


sub reverse_list {
	my @list = @_;
	
	my $s = scalar @list;
	my @r;
	for (1..$s) {
		push @r, $list[$s - $_];
	}
	
	return @r;
}

sub rus_to_translit {
	my $text = shift; 
	my %translit_map = (
		'а' => 'a',   'б' => 'b',   'в' => 'v',   'г' => 'g',
		'д' => 'd',   'е' => 'e',   'ё' => 'yo',  'ж' => 'zh',
		'з' => 'z',   'и' => 'i',   'й' => 'y',   'к' => 'k',
		'л' => 'l',   'м' => 'm',   'н' => 'n',   'о' => 'o',
		'п' => 'p',   'р' => 'r',   'с' => 's',   'т' => 't',
		'у' => 'u',   'ф' => 'f',   'х' => 'kh',  'ц' => 'ts',
		'ч' => 'ch',  'ш' => 'sh',  'щ' => 'shch','ъ' => '',
		'ы' => 'y',   'ь' => '',    'э' => 'e',   'ю' => 'yu',
		'я' => 'ya',
		
		'А' => 'A',   'Б' => 'B',   'В' => 'V',   'Г' => 'G',
		'Д' => 'D',   'E' => 'E',   'Ё' => 'Yo',  'Ж' => 'Zh',
		'З' => 'Z',   'И' => 'I',   'Й' => 'Y',   'К' => 'K',
		'Л' => 'L',   'М' => 'M',   'Н' => 'N',   'О' => 'O',
		'П' => 'P',   'Р' => 'R',   'С' => 'S',   'Т' => 'T',
		'У' => 'U',   'Ф' => 'F',   'Х' => 'Kh',  'Ц' => 'Ts',
		'Ч' => 'Ch',  'Ш' => 'Sh',  'Щ' => 'Shch','Ъ' => '',
		'Ы' => 'Y',   'Ь' => '',    'Э' => 'E',   'Ю' => 'Yu',
		'Я' => 'Ya'
	);

	my $pattern = join '|', sort { length $b <=> length $a } keys %translit_map;

	$text =~ s/($pattern)/$translit_map{$1}/g;

	return $text;
}

1;
