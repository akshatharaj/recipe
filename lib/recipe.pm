package recipe;
use Dancer ':syntax';
use JSON -convert_blessed_universally;
use File::Slurp qw(read_file  write_file);

our $VERSION = '0.1';

get '/' => sub {
    template 'home';
};

get '/contact-us' => sub {
    template 'contact_us', {errors => "Please note! email and message fields are required"};
};

post '/contact-us' => sub {
    my $file = config->{recipe}{contact_messages};
    my $json = -e $file ? read_file $file : '{}';
    my $data = from_json $json;
    my $now = time;
    $data->{$now} = {
        name => params->{user},
        email => params->{email},
        message => params->{message},
    };
    write_file $file, to_json $data;

    redirect '/contact-us-thanks';
};

get '/contact-us-thanks' => sub {
    template 'contact_us_thanks';
};

true;
