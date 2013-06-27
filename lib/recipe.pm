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
    if (! params->{email} eq '' && ! params->{message} eq '') {
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
    }
    else {
        template 'contact_us', {errors => "Please note! email and message fields are required",
                                tip_text => "Please use this form to contact us if you 
                                             have any problems using the site or if you 
                                             wanted to report any content on the site"};
    }
};

get '/contact-us-thanks' => sub {
    template 'contact_us_thanks';
};

get '/post-recipe' => sub {
    template 'post-recipe', {ingredients_tip => 'Please enter one ingredient per line'};
};

post '/post-recipe' => sub {
    if (! params->{dish} eq '' && ! params->{ingredients} eq '' && ! params->{procedure} eq '') {
        my $file = config->{recipe}{recipes};
        my $json = -e $file ? read_file $file : '{}';
        my $data = decode_json $json;
        my $now = time;
        my @ingredients = split('\r\n', params->{ingredients});
        $data->{$now} = {
            name => params->{dish},
            type => params->{type},
            cuisine => params->{cuisine},
            preparation_time => params->{prep_time},
            ingredients => \@ingredients,
            procedure => params->{procedure},
        };
        write_file $file, encode_json $data;

        redirect '/recipe-listing'; 
    }   
    else {
        template 'post-recipe', {errors => 'Please note, Name, Ingredients and Procedure are required fields',
                                 dish => params->{dish}, prep_time => params->{prep_time}, cuisine => params->{cuisine},
                                 ingredients => params->{ingredients}, procedure => params->{procedure},
                                 ingredients_tip => 'Please enter one ingredient per line'};
    }
};

get '/recipe-listing' => sub {
    my $file = config->{recipe}{recipes};
    my $json = -e $file ? read_file $file : '{}';
    my $data = decode_json $json;
    template 'recipe-listing', {'recipes' => $data, current_page => params->{'page'},   entries_per_page => 3,}
};

true;
