use strict;

use Test::Exception tests => 1; 
use App::Manager;

dies_ok( sub{ App::Manager->new() }, 'die while instantiation abstract App::Manager' );



