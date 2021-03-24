use rand::seq::SliceRandom;
use rand::Rng;

static PREFIXES: &[(&str, u32)] = &[
    ("", 10),
    ("ANSI ", 2),
    ("Apple", 2),
    ("Auto", 2),
    ("Cloud ", 10),
    ("Common ", 5),
    ("Emacs ", 1),
    ("Holy", 1),
    ("ISO ", 5),
    ("Linear ", 1),
    ("Liquid ", 1),
    ("Meta", 2),
    ("Microsoft ", 10),
    ("Object ", 10),
    ("Objective ", 10),
    ("Standard ", 1),
    ("Turbo ", 10),
    ("Visual ", 10),
    ("Win", 1),
    ("Wolfram ", 1),
];

static ROOTS: &[&str] = &[
    "A",
    "APL",
    "Ada",
    "Agda",
    "Algol",
    "Alonzo",
    "B",
    "Basic",
    "Blaise",
    "C",
    "COBOL",
    "Church",
    "Clojure",
    "Coq",
    "Curry",
    "D",
    "E",
    "Elm",
    "Erlang",
    "Euclid",
    "F",
    "Fermat",
    "Forth",
    "Fortran",
    "Futhark",
    "Gauss",
    "Go",
    "Haskell",
    "Hilbert",
    "J",
    "Java",
    "K",
    "Lisp",
    "ML",
    "Naur",
    "Neumann",
    "Newton",
    "OCaml",
    "PHP",
    "Pascal",
    "Perl",
    "Prolog",
    "Python",
    "R",
    "Riemann",
    "Rust",
    "Scheme",
    "Scratch",
    "Smalltalk",
    "SQL",
    "Swift",
    "Turing",
];

static SUFFIXES: &[(&str, u32)] = &[
    (" .NET", 5),
    (" 0x", 1),
    (" 11", 1),
    (" 2", 1),
    (" 3", 1),
    (" 4", 1),
    (" 5", 1),
    (" 58", 1),
    (" 6", 1),
    (" 68", 1),
    (" 7", 1),
    (" 77", 1),
    (" 8", 1),
    (" 9", 1),
    (" 99", 1),
    (" Query Language", 3),
    (" with Classes", 5),
    ("", 50),
    ("#", 5),
    ("*", 2),
    ("++", 5),
    ("--", 1),
    ("script", 15),
];

fn main() {
    // prepare a non-deterministic random number generator:
    let mut rng = rand::thread_rng();

    let mut result = String::new();

    result.push_str(
        PREFIXES
            .choose_weighted(&mut rng, |item| item.1)
            .map(|item| item.0)
            .unwrap_or(&""),
    );

    loop {
        if rng.gen_range(1, 10) == 9 {
            result.push_str(
                PREFIXES
                    .choose_weighted(&mut rng, |item| item.1)
                    .map(|item| item.0)
                    .unwrap_or(&""),
            );
        } else {
            break;
        }
    }

    if let Some(root) = std::env::args().skip(1).next() {
        result.push_str(&root);
    } else {
        result.push_str(ROOTS.choose(&mut rng).unwrap_or(&""));
    }

    result.push_str(
        SUFFIXES
            .choose_weighted(&mut rng, |item| item.1)
            .map(|item| item.0)
            .unwrap_or(&""),
    );

    println!("{}", result);
}
