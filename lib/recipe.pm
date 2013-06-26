package recipe;
use Dancer ':syntax';
use JSON::PP;
use File::Slurp qw(read_file  write_file);

our $VERSION = '0.1';

get '/' => sub {
    template 'home';
};

get '/contact-us' => sub {
    template 'contact_us', {errors => "Please note! email and message fields are required", 
                            tip_text => "Please use this form to contact us if you 
                                         have any problems using the site or if you 
                                         wanted to report any content on the site"};
};

post '/contact-us' => sub {
    my $file = config->{recipe}{contact_messages};
    my $json = -e $file ? read_file $file : '{}';
    my $data = decode_json $json;
    my $now = time;
    $data->{$now} = {
        name => params->{user},
        email => params->{email},
        message => params->{message},
    };
    write_file $file, encode_json $data;

    redirect '/contact-us-thanks';
};

get '/contact-us-thanks' => sub {
    template 'contact_us_thanks';
};

get '/post-recipe' => sub {
    template 'post-recipe';
};

post '/post-recipe' => sub {
    if (! params->{name} eq '' && ! params->{ingredients} eq '' && ! params->{procedure} eq '') {
        my $file = config->{recipe}{recipes};
        my $json = -e $file ? read_file $file : '{}';
        my $data = decode_json $json;
        my $now = time;
        $data->{$now} = {
            name => params->{name},
            type => params->{type},
            preparation_time => params->{prep_time},
            ingredients => params->{ingredients},
            procedure => params->{procedure},
        };
        write_file $file, encode_json $data;

        redirect '/recipe-listing'; 
    }   
    else {
        template 'post-recipe', {'errors' => 'Please note, Name, Ingredients and Procedure are required fields'};
    }
};

get '/recipe-listing' => sub {
    my $file = config->{recipe}{recipes};
    my $json = -e $file ? read_file $file : '{}';
    my $data = decode_json $json;
    template 'recipe-listing', {'recipes' => $data};
};
true;
