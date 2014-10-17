#!/usr/bin/perl
package IkiWiki::Plugin::serverlist;

use warnings;
use strict;
use IkiWiki 3.00;
use YAML;

sub import {
	hook(type => "preprocess", id => "serverlist", call => \&preprocess);
}

sub preprocess (@){
    my $output = "";
    my %params = @_;

    my %pageYamls;
    foreach my $page (pagespec_match_list($params{page}, $params{pages})){
            my $pageData = readfile(srcfile($page . ".mdwn"));
            my $startIndex = index($pageData, "# YAML");
            my $endIndex = index($pageData, "# ENDYAML");

            if(($startIndex < 0) or ($endIndex < 0)){
                next;
            }

            my $yamlData = substr($pageData, $startIndex, $endIndex-$startIndex);

            my $yamlRef = Load($yamlData);
            $pageYamls{$page} = $yamlRef;
    }

    my $tableData = "Name|IP Address|Services|Maintainers\n";
    foreach my $page (sort(keys(%pageYamls))){
        my $yaml = $pageYamls{$page};
        $tableData .= "[[" . $$yaml{"name"} . "]]|" . $$yaml{"ip-address"} . "|";
        if(@{$$yaml{"services"}}){
            $tableData .= join(", ", @{$$yaml{"services"}});
        } else {
            $tableData .= "**unused**";
        }
        $tableData .= "|";
        if(@{$$yaml{"maintainers"}}){
            $tableData .= join(", ", map { "[[staff/" . $_ . "]]" } @{$$yaml{"maintainers"}});
        } else {
            $tableData .= "*none*";
        }
        $tableData .= "\n";
    }
    $output = IkiWiki::Plugin::table::preprocess("data" => $tableData, %params);
    return $output;
}

1
