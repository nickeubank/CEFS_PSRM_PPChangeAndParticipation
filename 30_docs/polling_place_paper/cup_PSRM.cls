\NeedsTeXFormat{LaTeX2e}[1995/12/01]
\ProvidesClass{cup_PSRM}

\newif\if@doublespaced\@doublespacedfalse
\newif\if@cropmarkson\@cropmarksonfalse
\DeclareOption{doublespaced}{\@doublespacedtrue}
\DeclareOption{crop}{\@cropmarksontrue}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass[10pt,twoside,onecolumn,final]{article}

\RequirePackage[T1]{fontenc}
\RequirePackage{amsmath}
\RequirePackage{newtxtext,newtxmath}
\RequirePackage{enumitem}
\RequirePackage{lettrine}
\RequirePackage{ragged2e}
\RequirePackage[style]{abstract}
\RequirePackage[explicit]{titlesec}
\RequirePackage{fancyhdr}
\RequirePackage{textcase}
\PassOptionsToPackage{natbib=true}{biblatex}
\RequirePackage[authordate,backend=biber]{biblatex-chicago}
\RequirePackage[font={it,small},justification=justified,singlelinecheck=false]{caption}
\renewcommand{\tablename}{table}
\DeclareCaptionLabelSeparator{dotquad}{.\quad}
\captionsetup*[table]{labelfont={sc,up},labelsep=quad,position=above,skip=0pt}
\captionsetup*[figure]{labelsep=dotquad}
\RequirePackage[tracking=smallcaps]{microtype}

\RequirePackage{setspace}
\RequirePackage[norule]{footmisc}
\if@doublespaced
  \doublespacing
  \renewcommand{\footnotelayout}{\footnotesize\doublespacing}
  \patchcmd{\thanks}{#1}{\protect\doublespacing\footnotesize#1}{}{}
\fi


\newcommand{\doinumber}[1]{\def\@doinumber{#1}}
\newcommand{\journalname}[1]{\def\@journalname{#1}}
\newcommand{\journalvolume}[1]{\def\@journalvolume{#1}}
\newcommand{\journalissue}[1]{\def\@journalissue{#1}}
\newcommand{\journalcopy}[1]{\def\@journalcopy{#1}}
\newcommand{\fpage}[1]{\def\@fpage{#1}}
\newcommand{\lpage}[1]{\def\@lpage{#1}}

\newcommand{\AND}{{\fontsize{8.5}{10.5}\selectfont\textsc{and}}\space}

\RequirePackage[paperheight=247mm,paperwidth=174mm,top=3cm,left=2cm,bottom=4.3cm,right=3cm,footskip=24pt,headsep=\baselineskip,headheight=24pt,footnotesep=24pt]{geometry}

\if@cropmarkson
  \RequirePackage[a4,center,cam,info]{crop}
\fi

\patchcmd{\thanks}{#1}{\normalsize#1}{}{}
\pretocmd{\@makefnmark}{\normalsize}{}{}
\renewcommand{\footnotelayout}{\normalsize}


\fancyhf{}
\renewcommand{\headrulewidth}{0pt}
\fancyhead[RO]{\emph{\rightmark}\hspace{2em}\thepage}
\fancyhead[LE]{\thepage\hspace{2em}\leftmark}
\pagestyle{fancy}

\fancypagestyle{journalinfo}{%
  \fancyhf{}
\chead{\footnotesize%
  \@journalname\hfill Page \@fpage{} of \@lpage\vskip2pt\hrule\kern3pt%
  \emph{\@journalcopy\hfill\@doinumber}}
}

\patchcmd{\maketitle}{\thispagestyle{plain}}{\thispagestyle{journalinfo}}{}{}


\renewcommand{\@maketitle}{%
  \clearpage\null\vskip2em{\raggedright 
  {\fontsize{15pt}{17pt}\bfseries\selectfont\@title\par}
  \vskip1em%
  \@author\par\vskip2em}%
}

\renewcommand{\abstitlestyle}[1]{}
\renewcommand{\abstracttextfont}{\small\itshape}
\newcommand{\dropping}[2][]{\lettrine[#1]{#2}{}}
\apptocmd{\endabstract}{\vskip4pc}{}{}

\setcounter{secnumdepth}{0}
\titleformat{\section}
  {\scshape\normalsize\mdseries}
  {\thesection}
  {0pt}
  {#1}

\titleformat{\subsection}
  {\itshape\mdseries\normalsize}
  {\thesubsection}
  {0pt}
  {#1}

\titleformat{\subsubsection}[runin]
  {\itshape\mdseries\normalsize}
  {\thesubsubsection}
  {0pt}
  {#1.}

\titlespacing*{\section}{0pt}{2em}{1.5em}

\titlespacing*{\subsection}{0pt}{1.5em}{1em}

\titlespacing*{\subsubsection}{0pt}{1em}{5pt}

\renewcommand{\sectionmark}[1]{}
\renewcommand{\subsectionmark}[1]{}
\renewcommand{\subsubsectionmark}[1]{}


% \newcommand{\fignote}[1]{\justifying\noindent\fontsize{8.5pt}{10pt}\selectfont {\emph{Note:~}}#1 \par}
\newcommand{\fignote}[1]{\justifying\noindent\small{\emph{Note:~}}#1\par}

% \renewcommand\tablebody{\fontsize{9.5}{11}\selectfont }
\AtBeginEnvironment{tabular}{\small}
% \newcommand{\tabnote}[1]{ \vskip5pt \fontsize{9.5pt}{11pt}\selectfont {\it Note:}~#1 \par}
\newcommand{\tabnote}[1]{\vskip5pt{\justifying\noindent\small {\emph{Note:~}#1\par}}}

\newtheorem{theorem}{Theorem}[section]
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{proposition}{Proposition}
\newtheorem{corollary}[theorem]{Corollary}

\newenvironment{proof}[1][Proof]{\begin{trivlist}
\item[\hskip \labelsep {\bfseries #1}]}{\end{trivlist}}
\newenvironment{definition}[1][Definition]{\begin{trivlist}
\item[\hskip \labelsep {\bfseries #1}]}{\end{trivlist}}
\newenvironment{example}[1][Example]{\begin{trivlist}
\item[\hskip \labelsep {\bfseries #1}]}{\end{trivlist}}
\newenvironment{remark}[1][Remark]{\begin{trivlist}
\item[\hskip \labelsep {\bfseries #1}]}{\end{trivlist}}

\newcommand{\qed}{\nobreak \ifvmode \relax \else
      \ifdim\lastskip<1.5em \hskip-\lastskip
      \hskip1.5em plus0em minus0.5em \fi \nobreak
      \vrule height0.75em width0.5em depth0.25em\fi}

\newlist{hypolist}{enumerate}{2}
\setlist[hypolist]{itemsep=0pt,leftmargin=8em,label={\textsc{Hypothesis} \arabic*:}}


\endinput