\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{TDP003mall}[2016/06/03 TDP003 Project template]

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

\LoadClass{article}

\RequirePackage{fontspec}
\RequirePackage[usenames,x11names,svgnames]{xcolor}
\RequirePackage{fancyhdr}
\RequirePackage[colorlinks=false, hidelinks]{hyperref}
\RequirePackage{tabularx}
\RequirePackage{titling}
\RequirePackage{fullpage}
\RequirePackage{lastpage}
\RequirePackage{tikz}
\RequirePackage{parskip}
\RequirePackage[swedish]{babel}
\setlength{\headsep}{20pt}
\setlength{\headheight}{40pt}

% Workaround for erroneous capitalization in the TOC.
\addto\captionsswedish{\def\contentsname{Innehåll}}

\pagestyle{fancy}
\newlength{\borderwidth}
\setlength{\borderwidth}{3cm}

\renewcommand{\maketitlehooka}{%
  \begin{tikzpicture}[overlay]
    \node [anchor=south west] (lith) at (-3,1) {\includegraphics[width=\borderwidth]{lith}};
    \node [rectangle,fill=black!5!white,minimum height=21cm,text width=\borderwidth,anchor=north west] (border) at (lith.south west) {};
    \node [anchor=south west] at (border.south west) {\includegraphics[width=\borderwidth]{ida}};
   \end{tikzpicture}
   }
\pretitle{\begin{center}{\color{DarkBlue}\usefont{T1}{arial}{bx}{n}\fontsize{28pt}{1em}\selectfont TDP003 Projekt: Egna\\[.3em]datormiljön}\end{center}\vspace{100pt}\begin{center}\Huge\bfseries}
\posttitle{\end{center}}
\preauthor{\begin{center}\normalsize}
\postauthor{\end{center}\vfill}
\predate{\begin{center}Höstterminen 2022\\\version{}\end{center}\begin{center}}
\postdate{\end{center}}
\lhead{\thedate}
\chead{\thetitle}
\lfoot{\version{}}
\rfoot{\thepage\ / \pageref{LastPage}}
\cfoot{}

\newcommand{\projectpage}{%
  \begin{titlingpage}%
    \addtolength{\textwidth}{-3cm}\addtolength{\hoffset}{2cm}%
    \maketitle%
  \end{titlingpage}%
}

\endinput
