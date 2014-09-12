package Calendar::Saka;

$Calendar::Saka::VERSION = '1.11';

use strict; use warnings;

=head1 NAME

Calendar::Saka - Interface to Indian Calendar.

=head1 VERSION

Version 1.11

=cut

use Data::Dumper;
use POSIX qw/floor/;
use Time::localtime;
use List::Util qw/min/;
use Date::Calc qw/Delta_Days Day_of_Week Add_Delta_Days/;

my $MONTHS = [
    'Chaitra', 'Vaisakha', 'Jyaistha',   'Asadha', 'Sravana', 'Bhadra',
    'Asvina',  'Kartika',  'Agrahayana', 'Pausa',  'Magha',   'Phalguna' ];

my $DAYS = [
    'Ravivara',       'Somvara',   'Mangalavara', 'Budhavara',
    'Brahaspativara', 'Sukravara', 'Sanivara' ];

# Day offset between Saka and Gregorian.
my $START = 80;

# Offset in years from Saka era to Gregorian epoch.
my $SAKA = 78;

my $GREGORIAN_EPOCH = 1721425.5;

sub new {
    my ($class, $yyyy, $mm, $dd) = @_;

    my $self  = {};
    bless $self, $class;

    if (defined($yyyy) && defined($mm) && defined($dd)) {
        _validate_date($yyyy, $mm, $dd)
    }
    else {
        my $today = localtime;
        $yyyy = ($today->year+1900) unless defined $yyyy;
        $mm = ($today->mon+1) unless defined $mm;
        $dd = $today->mday unless defined $dd;
        ($yyyy, $mm, $dd) = $self->from_gregorian($yyyy, $mm, $dd);
    }

    $self->{yyyy} = $yyyy;
    $self->{mm}   = $mm;
    $self->{dd}   = $dd;

    return $self;
}

=head1 DESCRIPTION

Module  to  play  with Saka calendar  mostly  used  in  the South indian, Goa and
Maharashatra. It supports the functionality to add / minus days, months and years
to a Saka date. It can also converts Saka date to Gregorian/Julian date.

The  Saka eras are lunisolar calendars, and feature annual cycles of twelve lunar
months, each month divided into two phases:   the  'bright half' (shukla) and the
'dark half'  (krishna);  these correspond  respectively  to  the  periods  of the
'waxing' and the 'waning' of the moon. Thus, the  period beginning from the first
day  after  the new moon  and  ending on the full moon day constitutes the shukla
paksha or 'bright half' of the month the period beginning from the  day after the
full moon until &  including the next new moon day constitutes the krishna paksha
or 'dark half' of the month.

The  "year zero"  corresponds  to  78 BCE in the Saka calendar. The Saka calendar
begins with the month of Chaitra (March) and the Ugadi/Gudi Padwa festivals  mark
the new year.

Each  month  in  the Shalivahana  calendar  begins with the  'bright half' and is
followed by the 'dark half'.  Thus,  each  month of the Shalivahana calendar ends
with the no-moon day and the new month begins on the day after that.

A variant of the Saka Calendar was reformed & standardized as the Indian National
calendar in 1957. This official  calendar follows the Shalivahan Shak calendar in
beginning from the month of Chaitra and counting years with 78 CE being year zero.
It features a constant number of days in every month with leap years.Saka Calendar
for the month of Phalgun year 1932

            Phalguna [1932]

    Sun  Mon  Tue  Wed  Thu  Fri  Sat
      1    2    3    4    5    6    7
      8    9   10   11   12   13   14
     15   16   17   18   19   20   21
     22   23   24   25   26   27   28
     29   30

=head1 MONTHS

    +-------+------------+
    | Order | Name       |
    +-------+------------+
    |   1   | Chaitra    |
    |   2   | Vaisakha   |
    |   3   | Jyaistha   |
    |   4   | Asadha     |
    |   5   | Sravana    |
    |   6   | Bhadra     |
    |   7   | Asvina     |
    |   8   | Kartika    |
    |   9   | Agrahayana |
    |  10   | Pausa      |
    |  11   | Magha      |
    |  12   | Phalguna   |
    +-------+------------+

=head1 WEEKDAYS

    +---------+-----------+----------------+
    | Weekday | Gregorian | Saka           |
    +---------+-----------+----------------+
    |    0    | Sunday    | Ravivara       |
    |    1    | Monday    | Somvara        |
    |    2    | Tuesday   | Mangalavara    |
    |    3    | Wednesday | Budhavara      |
    |    4    | Thursday  | Brahaspativara |
    |    5    | Friday    | Sukravara      |
    |    6    | Saturday  | Sanivara       |
    +---------+-----------+----------------+

=head1 METHODS

=head2 as_string()

Return Saka date in human readable format.

    use strict; use warnings;
    use Calendar::Saka;

    my $calendar = Calendar::Saka->new(1932,12,26);
    print "Saka date is " . $calendar->as_string() . "\n";

=cut

sub as_string {
    my ($self) = @_;

    return sprintf("%02d, %s %04d", $self->{dd}, $MONTHS->[$self->{mm}-1], $self->{yyyy});
}

=head2 today()

Return today's date is Sake calendar as list in the format yyyy,mm,dd.

    use strict; use warnings;
    use Calendar::Saka;

    my $calendar = Calendar::Saka->new();
    my ($yyyy, $mm, $dd) = $calendar->today();
    print "Year [$yyyy] Month [$mm] Day [$dd]\n";

=cut

sub today {
    my ($self) = @_;

    my $today = localtime;
    return $self->from_gregorian($today->year+1900, $today->mon+1, $today->mday);
}

=head2 mon()

Return name of the given month according to the Saka Calendar.

    use strict; use warnings;
    use Calendar::Saka;

    my $calendar = Calendar::Saka->new();
    print "Month name: [" . $calendar->mon() . "]\n";

=cut

sub mon {
    my ($self, $mm) = @_;

    $mm = $self->{mm} unless defined $mm;

    _validate_date(2000, $mm, 1);

    return $MONTHS->[$mm-1];
}

=head2 dow()

Get day of the week of the given Saka date, starting with sunday (0).

    use strict; use warnings;
    use Calendar::Saka;

    my $calendar = Calendar::Saka->new();
    print "Day of the week; [" . $calendar->dow() . "]\n";

=cut

sub dow {
    my ($self, $yyyy, $mm, $dd) = @_;

    $yyyy = $self->{yyyy} unless defined $yyyy;
    $mm   = $self->{mm}   unless defined $mm;
    $dd   = $self->{dd}   unless defined $dd;

    _validate_date($yyyy, $mm, $dd);

    my @gregorian = $self->to_gregorian($yyyy, $mm, $dd);
    return Day_of_Week(@gregorian);
}

=head2 days_in_month()

Return number of days in the given year and month of Saka calendar.

    use strict; use warnings;
    use Calendar::Saka;

    my $calendar = Calendar::Saka->new(1932,12,26);
    print "Days is Phalguna 1932: [" . $calendar->days_in_month() . "]\n";
    print "Days is Chaitra  1932: [" . $calendar->days_in_month(1932,1) . "]\n";

=cut

sub days_in_month {
    my ($self, $yyyy, $mm) = @_;

    $yyyy = $self->{yyyy} unless defined $yyyy;
    $mm   = $self->{mm}   unless defined $mm;

    _validate_date($yyyy, $mm, 1);

    my (@start, @end);
    @start = $self->to_gregorian($yyyy, $mm, 1);
    if ($mm == 12) {
        $yyyy += 1;
        $mm    = 1;
    }
    else {
        $mm += 1;
    }

    @end = $self->to_gregorian($yyyy, $mm, 1);

    return Delta_Days(@start, @end);
}

=head2 add_days()

Add given number of days to the Saka date.

    use strict; use warnings;
    use Calendar::Saka;

    my $calendar = Calendar::Saka->new(1932,12,5);
    print "Saka 1:" . $calendar->as_string() . "\n";
    $calendar->add_days(5);
    print "Saka 2:" . $calendar->as_string() . "\n";

=cut

sub add_days {
    my ($self, $no_of_days) = @_;

    die("ERROR: Invalid day count.\n") unless ($no_of_days =~ /^\-?\d+$/);

    my ($yyyy, $mm, $dd) = $self->to_gregorian();
    ($yyyy, $mm, $dd) = Add_Delta_Days($yyyy, $mm, $dd, $no_of_days);
    ($yyyy, $mm, $dd) = $self->from_gregorian($yyyy, $mm, $dd);
    $self->{yyyy} = $yyyy;
    $self->{mm}   = $mm;
    $self->{dd}   = $dd;

    return;
}

=head2 minus_days()

Minus given number of days from the Saka date.

    use strict; use warnings;
    use Calendar::Saka;

    my $calendar = Calendar::Saka->new(1932,12,5);
    print "Saka 1:" . $calendar->as_string() . "\n";
    $calendar->minus_days(2);
    print "Saka 2:" . $calendar->as_string() . "\n";

=cut

sub minus_days {
    my ($self, $no_of_days) = @_;

    die("ERROR: Invalid day count.\n") unless ($no_of_days =~ /^\d+$/);

    return $self->add_days(-1 * $no_of_days);
}

=head2 add_months()

Add given number of months to the Saka date.

    use strict; use warnings;
    use Calendar::Saka;

    my $calendar = Calendar::Saka->new(1932,1,1);
    print "Saka 1:" . $calendar->as_string() . "\n";
    $calendar->add_months(2);
    print "Saka 2:" . $calendar->as_string() . "\n";

=cut

sub add_months {
    my ($self, $no_of_months) = @_;

    die("ERROR: Invalid month count.\n") unless ($no_of_months =~ /^\d+$/);

    if (($self->{mm}+$no_of_months) > 12) {
        while (($self->{mm} + $no_of_months) > 12) {
            my $_mm = 12 - $self->{mm};
            $self->{yyyy}++;
            $self->{mm} = 1;
            $no_of_months = $no_of_months - ($_mm + 1);
        }
    }
    $self->{mm} += $no_of_months;

    return;
}

=head2 minus_months()

Minus given number of months from the Saka date.

    use strict; use warnings;
    use Calendar::Saka;

    my $calendar = Calendar::Saka->new(1932,5,1);
    print "Saka 1:" . $calendar->as_string() . "\n";
    $calendar->minus_months(2);
    print "Saka 2:" . $calendar->as_string() . "\n";

=cut

sub minus_months {
    my ($self, $no_of_months) = @_;

    die("ERROR: Invalid month count.\n") unless ($no_of_months =~ /^\d+$/);

    if (($self->{mm}-$no_of_months) < 1) {
        while (($self->{mm}-$no_of_months) < 1) {
            my $_mm = $no_of_months - $self->{mm};
            $self->{yyyy}--;
            $no_of_months = $no_of_months - $self->{mm};
            $self->{mm} = 12;
        }
    }
    $self->{mm} -= $no_of_months;

    return;
}

=head2 add_years()

Add given number of years to the Saka date.

    use strict; use warnings;
    use Calendar::Saka;

    my $calendar = Calendar::Saka->new(1932,1,1);
    print "Saka 1:" . $calendar->as_string() . "\n";
    $calendar->add_years(2);
    print "Saka 2:" . $calendar->as_string() . "\n";

=cut

sub add_years {
    my ($self, $no_of_years) = @_;

    die("ERROR: Invalid year count.\n") unless ($no_of_years =~ /^\d+$/);

    $self->{yyyy} += $no_of_years;

    return;
}

=head2 minus_years()

Minus given number of years from the Saka date.

    use strict; use warnings;
    use Calendar::Saka;

    my $calendar = Calendar::Saka->new(1932,1,1);
    print "Saka 1:" . $calendar->as_string() . "\n";
    $calendar->minus_years(2);
    print "Saka 2:" . $calendar->as_string() . "\n";

=cut

sub minus_years {
    my ($self, $no_of_years) = @_;

    die("ERROR: Invalid year count.\n") unless ($no_of_years =~ /^\d+$/);

    $self->{yyyy} -= $no_of_years;

    return;
}

=head2 get_calendar()

Return calendar for the given year and month in Saka calendar. It  return current
month of Saka calendar if no argument is passed in.

    use strict; use warnings;
    use Calendar::Saka;

    my $calendar = Calendar::Saka->new(1932,1,1);
    print $calendar->get_calendar();

    # Print calendar for year 1932 and month 12.
    print $calendar->get_calendar(1932, 12);

=cut

sub get_calendar {
    my ($self, $yyyy, $mm) = @_;

    $yyyy = $self->{yyyy} unless defined $yyyy;
    $mm   = $self->{mm} unless defined $mm;

    _validate_date($yyyy, $mm, 1);

    my ($calendar, $start_index, $days);
    $calendar = sprintf("\n\t%s [%04d]\n", $MONTHS->[$mm-1], $yyyy);
    $calendar .= "\nSun  Mon  Tue  Wed  Thu  Fri  Sat\n";

    $start_index = $self->dow($yyyy, $mm, 1);
    $days = $self->days_in_month($yyyy, $mm);
    map { $calendar .= "     " } (1..($start_index%=7));
    foreach (1 .. $days) {
        $calendar .= sprintf("%3d  ", $_);
        $calendar .= "\n" unless (($start_index+$_)%7);
    }

    return sprintf("%s\n\n", $calendar);
}

=head2 to_gregorian()

Convert Saka date to Gregorian date and return a list in the format yyyy,mm,dd.

    use strict; use warnings;
    use Calendar::Saka;

    my $calendar = Calendar::Saka->new();
    print "Saka: " . $calendar->as_string() . "\n";
    my ($yyyy, $mm, $dd) = $calendar->to_gregorian();
    print "Gregorian [$yyyy] Month [$mm] Day [$dd]\n";

=cut

sub to_gregorian {
    my ($self, $yyyy, $mm, $dd) = @_;

    $yyyy = $self->{yyyy} unless defined $yyyy;
    $mm   = $self->{mm}   unless defined $mm;
    $dd   = $self->{dd}   unless defined $dd;

    _validate_date($yyyy, $mm, $dd);

    return _julian_to_gregorian($self->to_julian($yyyy, $mm, $dd));
}

=head2 from_gregorian()

Convert Gregorian date to Saka date and return a list in the format yyyy,mm,dd.

    use strict; use warnings;
    use Calendar::Saka;

    my $calendar = Calendar::Saka->new();
    print "Saka 1: " . $calendar->as_string() . "\n";
    my ($yyyy, $mm, $dd) = $calendar->from_gregorian(2011, 3, 17);
    print "Saka 2: Year[$yyyy] Month [$mm] Day [$dd]\n";

=cut

sub from_gregorian {
    my ($self, $yyyy, $mm, $dd) = @_;

    _validate_date($yyyy, $mm, $dd);

    return $self->from_julian(_gregorian_to_julian($yyyy, $mm, $dd));
}

=head2 to_julian()

Convert Julian date to Saka date and return a list in the format yyyy,mm,dd.

    use strict; use warnings;
    use Calendar::Saka;

    my $calendar = Calendar::Saka->new();
    print "Saka  : " . $calendar->as_string() . "\n";
    print "Julian: " . $calendar->to_julian() . "\n";

=cut

sub to_julian {
    my ($self, $yyyy, $mm, $dd) = @_;

    $yyyy = $self->{yyyy} unless defined $yyyy;
    $mm   = $self->{mm}   unless defined $mm;
    $dd   = $self->{dd}   unless defined $dd;

    _validate_date($yyyy, $mm, $dd);

    my ($gyear, $gday, $start, $julian);
    $gyear = $yyyy + 78;
    $gday  = (_is_leap($gyear)) ? (21) : (22);
    $start = _gregorian_to_julian($gyear, 3, $gday);

    if ($mm == 1) {
        $julian = $start + ($dd - 1);
    }
    else {
        my ($chaitra, $_mm);
        $chaitra = (_is_leap($gyear)) ? (31) : (30);
        $julian = $start + $chaitra;
        $_mm = $mm - 2;
        $_mm = min($_mm, 5);
        $julian += $_mm * 31;

        if ($mm >= 8) {
            $_mm     = $mm - 7;
            $julian += $_mm * 30;
        }
        $julian += $dd - 1;
    }

    return $julian;
}

=head2 from_julian()

Convert Julian date to Saka date and return a list in the format yyyy,mm,dd.

    use strict; use warnings;
    use Calendar::Saka;

    my $calendar = Calendar::Saka->new();
    print "Saka 1: " . $calendar->as_string() . "\n";
    my $julian = $calendar->to_julian();
    my ($yyyy, $mm, $dd) = $calendar->from_julian($julian);
    print "Saka 2: Year[$yyyy] Month [$mm] Day [$dd]\n";

=cut

sub from_julian {
    my ($self, $julian) = @_;

    my ($day, $month, $year);
    my ($chaitra, $yyyy, $yday, $mday);
    $julian = floor($julian) + 0.5;
    $yyyy   = (_julian_to_gregorian($julian))[0];
    $yday   = $julian - _gregorian_to_julian($yyyy, 1, 1);
    $chaitra = _days_in_chaitra($yyyy);
    $year   = $yyyy - $SAKA;

    if ($yday < $START) {
        $year--;
        $yday += $chaitra + (31 * 5) + (30 * 3) + 10 + $START;
    }

    $yday -= $START;
    if ($yday < $chaitra) {
        $month = 1;
        $day   = $yday + 1;
    }
    else {
        $mday = $yday - $chaitra;
        if ($mday < (31 * 5)) {
            $month = floor($mday / 31) + 2;
            $day   = ($mday % 31) + 1;
        }
        else {
            $mday -= 31 * 5;
            $month = floor($mday / 30) + 7;
            $day   = ($mday % 30) + 1;
        }
    }

    return ($year, $month, $day);
}

sub _gregorian_to_julian {
    my ($yyyy, $mm, $dd) = @_;

    return ($GREGORIAN_EPOCH - 1) +
           (365 * ($yyyy - 1)) +
           floor(($yyyy - 1) / 4) +
           (-floor(($yyyy - 1) / 100)) +
           floor(($yyyy - 1) / 400) +
           floor((((367 * $mm) - 362) / 12) +
           (($mm <= 2) ? 0 : (_is_leap($yyyy) ? -1 : -2)) +
                 $dd);
}

sub _julian_to_gregorian {
    my ($julian) = @_;

    my $wjd        = floor($julian - 0.5) + 0.5;
    my $depoch     = $wjd - $GREGORIAN_EPOCH;
    my $quadricent = floor($depoch / 146097);
    my $dqc        = $depoch % 146097;
    my $cent       = floor($dqc / 36524);
    my $dcent      = $dqc % 36524;
    my $quad       = floor($dcent / 1461);
    my $dquad      = $dcent % 1461;
    my $yindex     = floor($dquad / 365);
    my $year       = ($quadricent * 400) + ($cent * 100) + ($quad * 4) + $yindex;

    $year++ unless (($cent == 4) || ($yindex == 4));

    my $yearday = $wjd - _gregorian_to_julian($year, 1, 1);
    my $leapadj = (($wjd < _gregorian_to_julian($year, 3, 1)) ? 0 : ((_is_leap($year) ? 1 : 2)));
    my $month   = floor(((($yearday + $leapadj) * 12) + 373) / 367);
    my $day     = ($wjd - _gregorian_to_julian($year, $month, 1)) + 1;

    return ($year, $month, $day);
}

sub _is_leap {
    my ($yyyy) = @_;

    return (($yyyy % 4) == 0) &&
        (!((($yyyy % 100) == 0) && (($yyyy % 400) != 0)));
}

sub _days_in_chaitra {
    my ($yyyy) = @_;

    (_is_leap($yyyy)) ? (return 31) : (return 30);
}

sub _validate_date {
    my ($yyyy, $mm, $dd) = @_;

    die("ERROR: Invalid year [$yyyy].\n")
        unless (defined($yyyy) && ($yyyy =~ /^\d{4}$/) && ($yyyy > 0));
    die("ERROR: Invalid month [$mm].\n")
        unless (defined($mm) && ($mm =~ /^\d{1,2}$/) && ($mm >= 1) && ($mm <= 12));
    die("ERROR: Invalid day [$dd].\n")
        unless (defined($dd) && ($dd =~ /^\d{1,2}$/) && ($dd >= 1) && ($dd <= 31));
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 REPOSITORY

L<https://github.com/Manwar/Calendar-Saka>

=head1 BUGS

Please  report any bugs or feature requests to C<bug-calendar-saka at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Calendar-Saka>.
I will be notified, and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Calendar::Saka

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Calendar-Saka>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Calendar-Saka>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Calendar-Saka>

=item * Search CPAN

L<http://search.cpan.org/dist/Calendar-Saka/>

=back

=head1 ACKNOWLEDGEMENTS

This module is based on javascript code written by John Walker founder of Autodesk,
Inc. and co-author of AutoCAD.

=head1 LICENSE AND COPYRIGHT

Copyright 2011 - 2014 Mohammad S Anwar.

This  program  is  free software; you can redistribute it and/or modify it under
the  terms  of the the Artistic License (2.0). You may obtain a copy of the full
license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any  use,  modification, and distribution of the Standard or Modified Versions is
governed by this Artistic License.By using, modifying or distributing the Package,
you accept this license. Do not use, modify, or distribute the Package, if you do
not accept this license.

If your Modified Version has been derived from a Modified Version made by someone
other than you,you are nevertheless required to ensure that your Modified Version
 complies with the requirements of this license.

This  license  does  not grant you the right to use any trademark,  service mark,
tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge patent license
to make,  have made, use,  offer to sell, sell, import and otherwise transfer the
Package with respect to any patent claims licensable by the Copyright Holder that
are  necessarily  infringed  by  the  Package. If you institute patent litigation
(including  a  cross-claim  or  counterclaim) against any party alleging that the
Package constitutes direct or contributory patent infringement,then this Artistic
License to you shall terminate on the date that such litigation is filed.

Disclaimer  of  Warranty:  THE  PACKAGE  IS  PROVIDED BY THE COPYRIGHT HOLDER AND
CONTRIBUTORS  "AS IS'  AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES. THE IMPLIED
WARRANTIES    OF   MERCHANTABILITY,   FITNESS   FOR   A   PARTICULAR  PURPOSE, OR
NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY YOUR LOCAL LAW. UNLESS
REQUIRED BY LAW, NO COPYRIGHT HOLDER OR CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL,  OR CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE
OF THE PACKAGE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1; # End of Calendar::Saka
