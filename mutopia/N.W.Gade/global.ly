
globalNoKey=\notes {
\time 3/4;
\tempo 4=100; % My own suggestion, M.B.
\skip 2.*31;
s4 s4^\fermata s8^\fermata \bar "||"; \break
s8 
\time 2/4;
\tempo 4=130; % My own suggestion, M.B.
\skip 2*224;
s4 s4^\fermata
\bar "|.";
}

global=\notes {
\key f;
\globalNoKey
}

marks= \notes {
\time 3/4;
%\property Thread.textStyle = "Large"
s2.^"\\raisebox{4mm}{\\bfseries\Large Andante con moto}"
\skip 2.*30;
s2 s8 s^"\\raisebox{4mm}{\\bfseries\Large Allegro molto vivace}"
\time 2/4;
\skip 2*12;
\mark "A";
\skip 2*12;
\mark "B";
\skip 2*26;
\mark "C";
\skip 2*24;
\mark "D";
\skip 2*32;
\mark "E";
\skip 2*10;
\mark "F";
\skip 2*26;
\mark "G";
\skip 2*16;
\mark "H";
\skip 2*20;
\mark "I";
\skip 2*12;
\mark "K";
\skip 2*16;
\mark "L";
\skip 2*8;
\mark "M";
\skip 2*11;
%slut
}
