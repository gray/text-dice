#!/usr/bin/env perl
use strict;
use warnings;

use Benchmark     qw(timethese);
use Capture::Tiny qw(capture_stdout);

use String::Similarity  ();
use Text::Brew          ();
use Text::Compare       ();
use Text::Dice          ();
use Text::Levenshtein   ();
use Text::LevenshteinXS ();
use Text::WagnerFischer ();

my @strings;

my %algos = (
    Similarity    => sub { String::Similarity::similarity(@strings) },
    Brew          => sub {
        Text::Brew::distance(@strings, { -output => 'distance' });
    },
    Compare       => sub {
        my $tc = Text::Compare->new;
        $tc->similarity(@strings);
    },
    Dice          => sub { Text::Dice::coefficient(@strings) },
    Levenshtein   => sub { Text::Levenshtein::fastdistance(@strings) },
    LevenshteinXS => sub { Text::LevenshteinXS::distance(@strings) },
    WagnerFischer => sub { Text::WagnerFischer::distance(@strings) },
);

my @tests = (
    ['2 short strings',  'france', 'republic of france'],
    ['utf-8 strings',  "\x{00DF}france", "republic of france\x{00DF}"],
    [
        '1 long, 1 short string',
        'Structural Assessment: The Role of Large and Full-Scale Testing'x100,
        'Web Aplications',
    ],
    [
        '1 short, 1 long string',
        'Web Aplications',
        'Structural Assessment: The Role of Large and Full-Scale Testing'x100,
    ],
);

for my $test (@tests) {
    printf "%s\n", $test->[0];
    @strings = @$test[1..2];
    Benchmark::cmpthese -2, \ %algos;
    print "\n";
}

__END__

=head1 BENCHMARKS

  2 short strings
                  Rate Compare    Brew WagnerFischer Levenshtein  Dice LevenshteinXS Similarity
  Compare          486/s      --    -31%          -63%        -88%  -98%         -100%      -100%
  Brew             700/s     44%      --          -46%        -83%  -98%         -100%      -100%
  WagnerFischer   1299/s    167%     86%            --        -69%  -96%         -100%      -100%
  Levenshtein     4127/s    750%    490%          218%          --  -87%         -100%      -100%
  Dice           31096/s   6301%   4345%         2294%        653%    --          -96%       -97%
  LevenshteinXS 871438/s 179289% 124477%        66980%      21013% 2702%            --       -11%
  Similarity    978326/s 201293% 139757%        75208%      23603% 3046%           12%         --

  utf-8 strings
                  Rate Compare    Brew WagnerFischer Levenshtein  Dice Similarity LevenshteinXS
  Compare          329/s      --    -16%          -49%        -84%  -98%      -100%         -100%
  Brew             389/s     19%      --          -39%        -81%  -97%      -100%         -100%
  WagnerFischer    640/s     95%     64%            --        -69%  -96%      -100%         -100%
  Levenshtein     2041/s    521%    424%          219%          --  -86%       -99%         -100%
  Dice           14721/s   4381%   3681%         2199%        621%    --       -92%          -96%
  Similarity    177069/s  53802%  45384%        27554%       8577% 1103%         --          -57%
  LevenshteinXS 411162/s 125063% 105516%        64114%      20049% 2693%       132%            --

  1 long, 1 short string
                  Rate    Brew WagnerFischer Levenshtein Compare  Dice LevenshteinXS Similarity
  Brew          0.448/s      --          -55%        -85%    -97% -100%         -100%      -100%
  WagnerFischer  1.01/s    124%            --        -65%    -93% -100%         -100%      -100%
  Levenshtein    2.92/s    550%          190%          --    -79%  -99%         -100%      -100%
  Compare        13.9/s   2994%         1278%        376%      --  -94%          -99%       -99%
  Dice            249/s  55491%        24663%       8447%   1697%    --          -74%       -81%
  LevenshteinXS   963/s 214679%        95571%      32922%   6841%  286%            --       -27%
  Similarity     1320/s 294179%       130984%      45145%   9410%  429%           37%         --

  1 short, 1 long string
                  Rate    Brew WagnerFischer Levenshtein Compare Similarity  Dice LevenshteinXS
  Brew          0.525/s      --          -58%        -87%    -97%      -100% -100%         -100%
  WagnerFischer  1.25/s    138%            --        -69%    -92%       -99% -100%         -100%
  Levenshtein    3.98/s    658%          218%          --    -76%       -97%  -99%         -100%
  Compare        16.3/s   2999%         1201%        309%      --       -86%  -94%          -98%
  Similarity      119/s  22600%         9433%       2894%    632%         --  -57%          -87%
  Dice            275/s  52245%        21882%       6804%   1589%       131%    --          -71%
  LevenshteinXS   953/s 181492%        76159%      23850%   5760%       700%  247%            --

=cut
