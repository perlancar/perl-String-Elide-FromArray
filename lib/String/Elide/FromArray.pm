package String::Elide::FromArray;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Exporter qw(import);
our @EXPORT_OK = qw(elide);

sub _elide_str {
    my ($str, $len, $opts) = @_;
    $opts //= {};
    $opts->{marker} //= '..';

    return $str if length($str) <= $len;
    my $l = $len - length($opts->{marker});
    $str = ($l > 0 ? substr($str, 0, $l) : '') . $opts->{marker};
    return $str if length($str) <= $len;
    substr($str, 0, $len);
}

sub elide {
    my ($ary, $len, $opts) = @_;
    $opts //= {};
    $opts->{marker}      //= '..';
    $opts->{list_marker} //= '..';
    $opts->{item_marker} //= '..';
    $opts->{sep}         //= ', ';

    my @ary;
    if ($opts->{max_item_len}) {
        @ary = map { _elide_str($_, $opts->{max_item_len},
                                {marker=>$opts->{item_marker}}) } @$ary;
    } else {
        @ary = @$ary;
    }

    my $str;
    if ($opts->{max_items}) {
        if (@ary > $opts->{max_items}) {
            splice @ary, $opts->{max_items};
            push @ary, $opts->{list_marker};
        }
    }
    $str = join($opts->{sep}, @ary);

    if (length($str) <= $len) {
        return $str;
    } else {
        return _elide_str($str, $len, {marker=>$opts->{marker}});
    }
}

1;
# ABSTRACT: Truncate string containing list of items

=head1 SYNOPSIS

 use String::Elide::FromArray qw(elide);

                                        #     01234567890123456
 elide([qw/foo/],                  11); # -> "foo"
 elide([qw/foo bar/],              11); # -> "foo, bar"
 elide([qw/foo bar baz/],          11); # -> "foo, bar,.."

 elide([qw/foo bar baz/],          15); # -> "foo, bar, baz"
 elide([qw/foo bar baz qux/],      15); # -> "foo, bar, baz.."

 elide([qw/foo bar baz qux/],      15, {max_items => 2});
                                        # -> "foo, bar, .."

 elide([qw/foo bar baz qux/],      15, {max_items => 2, list_marker => 'etc'});
                                        # -> "foo, bar, etc"

 elide([qw/foo bar baz/],          11, {sep => '|'});
                                        # -> "foo|bar|baz"

 elide([qw/foo bar baz/],          11, {marker=>"--"});
                                        # -> "foo, bar,--"

 elide([qw/aaa bbbbb/],            11, {max_item_len=>4});
                                        # -> "aaa, bb.."

 elide([qw/aaa bbbbb c d e/],      11, {max_item_len=>4, item_marker=>"*"});
                                        # -> "aaa, bbb*.."


=head1 DESCRIPTION

This module provides a single function C<elide()> to truncate a string
containing list of items. You provide the array containing the items.


=head1 FUNCTIONS

=head2 elide(\@ary, $len[, \%opts]) => str

Join C<@ary> using C<sep> (default is C<, >), the truncate the resulting string
so it has a maximum length of C<$len>. Some options are available:

=over

=item * sep => str (default: ', ')

String used to join the items.

=item * marker => str (default: '..')

String added at the end of elided string.

=item * max_item_len => int

If specified, then each item will be elided first.

=item * item_marker => str (default: '..')

String added at the end of elided string.

=item * max_items => int

If specified, only join at most this number of items.

=item * list_marker => str (default: '..')

Last item added when number of items exceeds C<max_items>.

=back


=head1 SEE ALSO

L<Text::Elide>, L<String::Truncate>, L<String::Elide::Parts>

=cut
