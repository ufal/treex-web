use strict;
use warnings;

use Treex::Web;

my $app = Treex::Web->apply_default_middlewares(Treex::Web->psgi_app);
$app;

