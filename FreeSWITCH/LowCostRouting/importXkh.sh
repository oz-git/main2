#!/bin/sh
cd /home/lcr/
/bin/rm -fv /home/lcr/Kody_*
/usr/bin/wget http://www.rossvyaz.ru/docs/articles/Kody_DEF-9kh.csv
/usr/bin/wget http://www.rossvyaz.ru/docs/articles/Kody_ABC-3kh.csv
/usr/bin/wget http://www.rossvyaz.ru/docs/articles/Kody_ABC-4kh.csv
/usr/bin/wget http://www.rossvyaz.ru/docs/articles/Kody_ABC-8kh.csv
/usr/bin/perl /home/lcr/importXkh.pl
#/usr/bin/perl /home/lcr/update_9kh.pl
#/usr/bin/perl /home/lcr/update_348kh.pl

